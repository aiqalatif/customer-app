import 'dart:core';
import 'package:eshop_multivendor/Helper/ApiBaseHelper.dart';
import '../../Helper/Constant.dart';
import '../../Helper/String.dart';

class UpdateFavRepository {
  ///This method is used to getfav

  static Future<dynamic> removeFavorite({
    required Map<String, dynamic> parameter,
  }) async {
    try {
      var result = await ApiBaseHelper().postAPICall(removeFavApi, parameter);

      return result;
    } on Exception catch (e) {
      throw ApiException('$errorMesaage${e.toString()}');
    }
  }

  static Future<dynamic> addFavorite({
    required Map<String, dynamic> parameter,
  }) async {
    try {
      var result = await ApiBaseHelper().postAPICall(setFavoriteApi, parameter);

      return result;
    } on Exception catch (e) {
      throw ApiException(
        '$errorMesaage${e.toString()}',
      );
    }
  }
}
