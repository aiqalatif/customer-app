import 'dart:async';
import 'dart:io';
import 'package:eshop_multivendor/Provider/UserProvider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

//this class use for connect with sql database and insert data and fetch data from database

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper.internal();

  factory DatabaseHelper() => _instance;

  final String CART_TABLE = 'tblcart';
  final String SAVEFORLATER_TABLE = 'tblsaveforlater';
  final String FAVORITE_TABLE = 'tblfavorite';
  final String MOSTLIKE_TABLE = 'tblmostlike';
  final String MOSTFAV_TABLE = 'tblmostfav';

  final String PID = 'PID';
  final String VID = 'VID';
  final String QTY = 'QTY';

  // final String SellerID = 'SID';

  static Database? _db;

  DatabaseHelper.internal();

  Future<Database?> get db async {
    if (_db != null) {
      return _db;
    }
    _db = await initDb();

    return _db;
  }

  //connect with sql database
  Future<Database> initDb() async {
    var databasesPath = await getDatabasesPath();
    var path = join(databasesPath, 'eShop.db');

    // Check if the database exists
    var exists = await databaseExists(path);
    if (!exists) {
      // Make sure the parent directory exists
      try {
        await Directory(dirname(path)).create(recursive: true);
      } catch (_) {}

      // Copy from asset
      ByteData data = await rootBundle.load(join('assets', 'eShop.db'));
      List<int> bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

      // Write and flush the bytes written
      await File(path).writeAsBytes(bytes, flush: true);
    } else {}
    // open the database
    var db = await openDatabase(path, readOnly: false);

    return db;
  }

  Future<bool?> getFavById(String pid) async {
    bool count = false;
    final db1 = await db;
    var result = await db1!
        .rawQuery('SELECT * FROM $FAVORITE_TABLE WHERE $PID = ?', [pid]);

    if (result.isNotEmpty) {
      count = true;
    }
    return count;
  }

  addAndRemoveFav(String pid, bool isAdd) async {
    final db1 = await db;
    if (isAdd) {
      addFavorite(pid);
    } else {
      db1!.rawQuery('DELETE FROM $FAVORITE_TABLE WHERE $PID = $pid');
      getFav();
    }
  }

  addFavorite(String pid) async {
    final db1 = await db;
    Map<String, dynamic> row = {
      DatabaseHelper._instance.PID: pid,
    };
    db1!.insert(FAVORITE_TABLE, row);
  }

  addMostFav(String pid) async {
    final db1 = await db;
    Map<String, dynamic> row = {
      DatabaseHelper._instance.PID: pid,
    };

    List<Map> result = await db1!.query(DatabaseHelper._instance.MOSTFAV_TABLE);

    if (result.length >= 10) {
      bool? check = await checkMostFavExists(pid);

      if (!check!) {
        db1.rawQuery('DELETE FROM $MOSTFAV_TABLE WHERE $PID = ?',
            [result[result.length - 1][PID]]).then((value) async {
          db1.insert(MOSTFAV_TABLE, row);
        });
      }
    } else {
      bool? check = await checkMostFavExists(pid);

      if (!check!) {
        db1.insert(MOSTFAV_TABLE, row);
      }
    }
  }

  addMostLike(String pid) async {
    final db1 = await db;
    Map<String, dynamic> row = {
      DatabaseHelper._instance.PID: pid,
    };

    List<Map> result =
        await db1!.query(DatabaseHelper._instance.MOSTLIKE_TABLE);

    if (result.length >= 10) {
      bool? check = await checkMostLikeExists(pid);

      if (!check!) {
        db1.rawQuery('DELETE FROM $MOSTLIKE_TABLE WHERE $PID = ?',
            [result[result.length - 1][PID]]).then((value) async {
          db1.insert(MOSTLIKE_TABLE, row);
        });
      }
    } else {
      bool? check = await checkMostLikeExists(pid);

      if (!check!) {
        db1.insert(MOSTLIKE_TABLE, row);
      }
    }
  }

  Future<bool?> checkMostFavExists(String pid) async {
    final db1 = await db;
    var result = await db1!
        .rawQuery('SELECT * FROM $MOSTFAV_TABLE WHERE $PID = ?', [pid]);
    if (result.isNotEmpty) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool?> checkMostLikeExists(String pid) async {
    final db1 = await db;
    var result = await db1!
        .rawQuery('SELECT * FROM $MOSTLIKE_TABLE WHERE $PID = ?', [pid]);
    if (result.isNotEmpty) {
      return true;
    } else {
      return false;
    }
  }

  Future<List<String>?> getMostFav() async {
    List<String> ids = [];
    final db1 = await db;

    List<Map> result = await db1!.query(DatabaseHelper._instance.MOSTFAV_TABLE);

    for (var row in result) {
      ids.add(row[PID]);
    }
    return ids;
  }

  Future<List<String>?> getMostLike() async {
    List<String> ids = [];
    final db1 = await db;

    List<Map> result =
        await db1!.query(DatabaseHelper._instance.MOSTLIKE_TABLE);

    for (var row in result) {
      ids.add(row[PID]);
    }
    return ids;
  }

  Future<List<Map>> getOffFav() async {
    final db1 = await db;

    List<Map> result =
        await db1!.query(DatabaseHelper._instance.FAVORITE_TABLE);

    return result;
  }

  Future<List<String>?> getFav() async {
    List<String> ids = [];
    final db1 = await db;

    List<Map> result =
        await db1!.query(DatabaseHelper._instance.FAVORITE_TABLE);

    for (var row in result) {
      ids.add(row[PID]);
    }
    return ids;
  }

  clearFav() async {
    final db1 = await db;
    db1!.execute('DELETE FROM $FAVORITE_TABLE');
  }

  //insert cart data in table
  insertCart(
    String pid,
    String vid,
    String qty,
    BuildContext context,
  ) async {
    var dbClient = await db;
    String? check;

    check = await checkCartItemExists(pid, vid);

    checkSaveForLaterExistsRemove(pid, vid);

    if (check != '0') {
      updateCart(
        pid,
        vid,
        qty,
      );
    } else {
      String query =
          "INSERT INTO $CART_TABLE ($PID,$VID,$QTY) SELECT '$pid','$vid','$qty' WHERE NOT EXISTS(SELECT $PID,$VID FROM $CART_TABLE WHERE $PID = '$pid' AND $VID='$VID')";
      dbClient!.execute(query);

      await getTotalCartCount(context);
    }
  }

  updateCart(
    String pid,
    String vid,
    String qty,
  ) async {
    final db1 = await db;
    Map<String, dynamic> row = {
      DatabaseHelper._instance.QTY: qty,
    };

    db1!.update(
      CART_TABLE,
      row,
      where: '$VID = ? AND $PID = ?',
      whereArgs: [vid, pid],
    );
    //isCheck=true;
  }

  removeCart(String vid, String pid, BuildContext context) async {
    final db1 = await db;

    db1!.rawQuery(
        'DELETE FROM $CART_TABLE WHERE $VID = ? AND $PID = ?', [vid, pid]);
    await getTotalCartCount(context);
  }

  clearCart() async {
    final db1 = await db;
    db1!.execute('DELETE FROM $CART_TABLE');
  }

  Future<String?> checkCartItemExists(String pid, String vid) async {
    final db1 = await db;
    var result = await db1!.rawQuery(
        'SELECT * FROM $CART_TABLE WHERE $VID = ? AND $PID = ?', [vid, pid]);
    if (result.isNotEmpty) {
      return result[0][QTY].toString();
    } else {
      return '0';
    }
  }

  Future<List<String>?> getCart() async {
    List<String> ids = [];
    final db1 = await db;

    List<Map> result = await db1!.query(DatabaseHelper._instance.CART_TABLE);

    for (var row in result) {
      ids.add(row[VID]);
    }

    return ids;
  }

  getTotalCartCount(BuildContext context) async {
    final db1 = await db;

    List<Map> result = await db1!.query(DatabaseHelper._instance.CART_TABLE);

    print('result length**${result.length}');

    context.read<UserProvider>().setCartCount(result.length.toString());
  }

  Future<List<Map>> getOffCart() async {
    final db1 = await db;

    List<Map> result = await db1!.query(DatabaseHelper._instance.CART_TABLE);

    return result;
  }

  Future<List<Map>> getOffSaveLater() async {
    final db1 = await db;

    List<Map> result =
        await db1!.query(DatabaseHelper._instance.SAVEFORLATER_TABLE);

    return result;
  }

  Future<List<String>?> getSaveForLater() async {
    List<String> ids = [];
    final db1 = await db;

    List<Map> result =
        await db1!.query(DatabaseHelper._instance.SAVEFORLATER_TABLE);

    for (var row in result) {
      ids.add(row[VID]);
    }

    return ids;
  }

  addToSaveForLater(String pid, String vid, String qty) async {
    var dbClient = await db;

    String query =
        "INSERT INTO $SAVEFORLATER_TABLE ($PID,$VID,$QTY) SELECT '$pid','$vid','$qty' WHERE NOT EXISTS(SELECT $PID,$VID FROM $CART_TABLE WHERE $PID = '$pid' AND $VID='$VID')";
    dbClient!.execute(query);
  }

  checkSaveForLaterExistsRemove(String pid, String vid) async {
    final db1 = await db;
    var result = await db1!.rawQuery(
        'SELECT * FROM $SAVEFORLATER_TABLE WHERE $VID = ? AND $PID = ?',
        [vid, pid]);

    if (result.isNotEmpty) {
      removeSaveForLater(vid, pid);
    }
  }

  Future<String?> checkSaveForLaterExists(String pid, String vid) async {
    final db1 = await db;
    var result = await db1!.rawQuery(
        'SELECT * FROM $SAVEFORLATER_TABLE WHERE $VID = ? AND $PID = ?',
        [vid, pid]);

    if (result.isNotEmpty) {
      return result[0][QTY].toString();
    } else {
      return '0';
    }
  }

  moveToCartOrSaveLater(
      String from, String vid, String pid, BuildContext context) async {
    String? qty = '';
    if (from == 'cart') {
      qty = await checkCartItemExists(pid, vid);
      addToSaveForLater(pid, vid, qty!);
      await removeCart(vid, pid, context);
    } else {
      qty = await checkSaveForLaterExists(pid, vid);
      insertCart(pid, vid, qty!, context);
      await removeSaveForLater(vid, pid);
    }
  }

  removeSaveForLater(String vid, String pid) async {
    final db1 = await db;
    db1!.rawQuery('DELETE FROM $SAVEFORLATER_TABLE WHERE $VID = ? AND $PID = ?',
        [vid, pid]);
  }

  clearSaveForLater() async {
    final db1 = await db;
    db1!.execute('DELETE FROM $SAVEFORLATER_TABLE');
  }

  //close connection of database
  Future close() async {
    var dbClient = await db;
    return dbClient!.close();
  }
}
