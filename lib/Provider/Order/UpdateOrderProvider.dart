import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:eshop_multivendor/Provider/UserProvider.dart';
import 'package:eshop_multivendor/repository/Order/UpdateOrderRepository.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Helper/String.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:http/http.dart' as http;
import '../../Screen/Language/languageSettings.dart';
import '../../widgets/security.dart';
import '../../widgets/snackbar.dart';

enum UpdateOrdStatus {
  initial,
  inProgress,
  isSuccsess,
  isFailure,
}

class UpdateOrdProvider extends ChangeNotifier {
  Future<List<Directory>?>? externalStorageDirectories;
  UpdateOrdStatus _UpdateOrdStatus = UpdateOrdStatus.initial;
  String errorMessage = '';
  bool isReturnClick = true;
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  ScrollController controller = ScrollController();
  Animation? buttonSqueezeanimation;
  AnimationController? buttonController;
  late TabController tabController;
  List<File> files = [];
  String updatedComment = '';
  List<File> reviewPhotos = [];
  double curRating = 0.0;
  TextEditingController commentTextController = TextEditingController();
  GlobalKey<FormState> commentTextFieldKey = GlobalKey<FormState>();
  String currentLinkForDownload = '';

  get getCurrentStatus => _UpdateOrdStatus;

  // meesage of cancelation
  String? msg;

  changeStatus(UpdateOrdStatus status) {
    _UpdateOrdStatus = status;
    notifyListeners();
  }

  Future<void> cancelOrder(
      String ordId, Uri api, String status, BuildContext context) async {
    try {
      changeStatus(UpdateOrdStatus.inProgress);
      var parameter = {ORDERID: ordId, STATUS: status};

      var result = await UpdateOrderRepository.cancelOrder(
          parameter: parameter, api: api);

      bool error = result['error'];

      if (!error) {
        setSnackbar(result['message'], context);
        changeStatus(UpdateOrdStatus.isSuccsess);
        Future.delayed(const Duration(seconds: 1)).then((_) async {
          Navigator.pop(context, 'update');
        });
      } else {
        setSnackbar(result['message'], context);
        changeStatus(UpdateOrdStatus.isFailure);
      }
      isReturnClick = true;
    } catch (e) {
      errorMessage = e.toString();
      setSnackbar(errorMessage, context);
      changeStatus(UpdateOrdStatus.isFailure);
    }
  }

/*  Future<void> changeOrderStatus(
    String ordId,
    Uri api,
    String status,
    BuildContext context,
  ) async {
    try {
      changeStatus(UpdateOrdStatus.inProgress);
      var parameter = {ORDERID: ordId, STATUS: status};

      var result = await UpdateOrderRepository.cancelOrder(
          parameter: parameter, api: api);

      bool error = result['error'];
      setSnackbar(result['message'], context);
      if (!error) {
        Future.delayed(const Duration(seconds: 1)).then(
          (_) async {
            Navigator.pop(context, 'update');
          },
        );
      }
      isReturnClick = true;
      changeStatus(UpdateOrdStatus.isSuccsess);
    } catch (e) {
      errorMessage = e.toString();

      changeStatus(UpdateOrdStatus.isFailure);
    }
  }*/

  Future<bool> getDownloadLink(
      BuildContext context, String orderIteamId) async {
    try {
      changeStatus(UpdateOrdStatus.inProgress);
      var parameter = {
        'order_item_id': orderIteamId,
      };

      var result = await UpdateOrderRepository.cancelOrder(
          parameter: parameter, api: downloadLinkHashApi);

      bool error = result['error'];
      setSnackbar(result['message'], context);
      print('error downloading order**$error');
      if (!error) {
        currentLinkForDownload = result['data'];
      }
      //isReturnClick = true;
      changeStatus(UpdateOrdStatus.isSuccsess);
      return error;
    } catch (e) {
      errorMessage = e.toString();
      changeStatus(UpdateOrdStatus.isFailure);
      return true;
    }
  }

  Future<void> sendBankProof(String id, BuildContext context) async {
    try {
      changeStatus(UpdateOrdStatus.inProgress);
      var request = await UpdateOrderRepository.sendBankProof();
      request.headers.addAll(headers);
      request.fields[ORDER_ID] = id;
      for (var i = 0; i < files.length; i++) {
        final mimeType = lookupMimeType(files[i].path);
        var extension = mimeType!.split('/');
        var pic = await http.MultipartFile.fromPath(
          ATTACH,
          files[i].path,
          contentType: MediaType('image', extension[1]),
        );
        request.files.add(pic);
      }
      var response = await request.send();
      var responseData = await response.stream.toBytes();
      var responseString = String.fromCharCodes(responseData);
      var getdata = json.decode(responseString);
      String msg = getdata['message'];
      changeStatus(UpdateOrdStatus.isSuccsess);
      files.clear();

      print("msg***$msg");
      setSnackbar(msg, context);
    } on TimeoutException catch (_) {
      setSnackbar(
        getTranslated(context, 'somethingMSg'),
        context,
      );
    }
  }

  Future<void> setRating(
    double rating,
    var productID,
    BuildContext context,
  ) async {
    try {
      changeStatus(UpdateOrdStatus.inProgress);
      var request = await UpdateOrderRepository.setRating();
      request.headers.addAll(headers);
      // request.fields[USER_ID] = context.read<UserProvider>().userId!;
      request.fields[PRODUCT_ID] = productID;

      if (reviewPhotos.isNotEmpty) {
        for (var i = 0; i < reviewPhotos.length; i++) {
          final mimeType = lookupMimeType(reviewPhotos[i].path);
          var extension = mimeType!.split('/');
          var pic = await http.MultipartFile.fromPath(
            IMGS,
            reviewPhotos[i].path,
            contentType: MediaType(
              'image',
              extension[1],
            ),
          );

          request.files.add(pic);
        }
      }

      if (updatedComment != '') request.fields[COMMENT] = updatedComment;
      if (rating != 0) request.fields[RATING] = rating.toString();
      var response = await request.send();

      var responseData = await response.stream.toBytes();

      var responseString = String.fromCharCodes(responseData);

      var getdata = json.decode(responseString);

      getdata['error'];
      msg = getdata['message'];
      setSnackbar(
        getTranslated(context, msg!),
        context,
      );
      changeStatus(UpdateOrdStatus.isSuccsess);
    } on TimeoutException catch (_) {
      changeStatus(UpdateOrdStatus.isSuccsess);
      setSnackbar(
        getTranslated(context, 'somethingMSg'),
        context,
      );
    }
  }
}
