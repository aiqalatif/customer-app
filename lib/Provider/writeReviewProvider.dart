import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:eshop_multivendor/Provider/UserProvider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../Helper/String.dart';
import '../Helper/routes.dart';
import '../Screen/Language/languageSettings.dart';
import '../widgets/networkAvailablity.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import '../widgets/security.dart';
import '../widgets/snackbar.dart';

class WriteReviewProvider extends ChangeNotifier {
  double curRating = 0.0;
  List<File> reviewPhotos = [];
  TextEditingController commentTextController = TextEditingController();
  setcurrentRatting(double value) {
    curRating = value;
  }

  setreviewPhotos(value) {
    reviewPhotos = value;
  }

  getReviewPhotoatindex(int index) {
    return reviewPhotos[index];
  }

  Future<void> setRating(
    var productID,
    BuildContext context,
    BuildContext screenContext,
    Function update,
  ) async {
    isNetworkAvail = await isNetworkAvailable();
    if (isNetworkAvail) {
      try {
        var request = http.MultipartRequest('POST', setRatingApi);
        request.headers.addAll(headers ?? {});
        // request.fields[USER_ID] = context.read<UserProvider>().userId!;
        request.fields[PRODUCT_ID] = productID;

        if (reviewPhotos.isNotEmpty) {
          for (var i = 0; i < reviewPhotos.length; i++) {
            final mimeType = lookupMimeType(getReviewPhotoatindex(i).path);

            var extension = mimeType!.split('/');

            var pic = await http.MultipartFile.fromPath(
              IMGS,
              getReviewPhotoatindex(i).path,
              contentType: MediaType('image', extension[1]),
            );

            request.files.add(pic);
          }
        }

        if (commentTextController.text != '') {
          request.fields[COMMENT] = commentTextController.text;
        }
        if (curRating != 0) request.fields[RATING] = curRating.toString();
        var response = await request.send();
        var responseData = await response.stream.toBytes();
        var responseString = String.fromCharCodes(responseData);
        var getdata = json.decode(responseString);
        bool error = getdata['error'];
        String? msg = getdata['message'];

        if (!error) {
          Routes.pop(context);
          setSnackbar(msg!, screenContext);
        } else {
          setSnackbar(msg!, screenContext);
        }
        commentTextController.text = '';
        reviewPhotos.clear();
      } on TimeoutException catch (_) {
        setSnackbar(
          getTranslated(context, 'somethingMSg'),
          screenContext,
        );
      }
    } else {
      isNetworkAvail = false;
      update();
    }
  }
}
