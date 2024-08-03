import 'dart:convert';
import 'dart:core';
import 'dart:io';
import 'package:eshop_multivendor/Model/Section_Model.dart';
import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart';
import 'package:eshop_multivendor/Helper/ApiBaseHelper.dart';
import 'package:eshop_multivendor/Model/Transaction_Model.dart';
import 'package:mime/mime.dart';
import 'package:http/http.dart';
import '../Helper/Constant.dart';
import '../Helper/String.dart';
import '../Model/getWithdrawelRequest/withdrawTransactiponsModel.dart';
import '../widgets/security.dart';

class UserRepository {
  ///This method is used to getTransactionsOfUSer
  static Future<Map<String, dynamic>> fetchUserTransaction({
    required Map<String, dynamic> parameter,
  }) async {
    try {
      var transactionsList =
          await ApiBaseHelper().postAPICall(getWalTranApi, parameter);

      return {
        'totalTransactions': transactionsList['total'].toString(),
        'transactionsList': (transactionsList['data'] as List)
            .map((transactionsData) =>
                (TransactionModel.fromJson(transactionsData)))
            .toList()
      };
    } on Exception catch (e) {
      throw ApiException('$errorMesaage${e.toString()}');
    }
  }

  //
  //This method is used to fetch user wallet transactions
  static Future<Map<String, dynamic>> fetchUserWalletTransaction(
      {required Map<String, dynamic> parameter}) async {
    try {
      var requestAmountTransactionsList =
          await ApiBaseHelper().postAPICall(getWalTranApi, parameter);
      print(
          "transaction balance***${requestAmountTransactionsList['balance']}");

      return {
        'totalTransactions': requestAmountTransactionsList['total'].toString(),
        'walletTransactionList': (requestAmountTransactionsList['data'] as List)
            .map((transactionsData) =>
                (TransactionModel.fromJson(transactionsData)))
            .toList(),
        'balance': requestAmountTransactionsList['balance'],
      };
    } on Exception catch (e) {
      throw ApiException('$errorMesaage${e.toString()}');
    }
  }

  //
  //This method is used to send Amount withdrawal request
  static Future<Map<String, dynamic>> sendAmountWithdrawRequest(
      {required Map<String, dynamic> parameter}) async {
    try {
      var amountRequestData = await ApiBaseHelper()
          .postAPICall(sendWithdrawalRequestApi, parameter);

      return {
        'error': amountRequestData['error'],
        'message': amountRequestData['message'].toString(),
        'newBalance': amountRequestData['data'].toString()
      };
    } on Exception catch (e) {
      throw ApiException('$errorMesaage${e.toString()}');
    }
  }

//
//This method is used to get user wallet amount withdrawal request transactions
  static Future<Map<String, dynamic>>
      getUserWalletAmountWithdrawalRequestTransactions(
          {required Map<String, dynamic> parameter}) async {
    try {
      var requestTransactionsList =
          await ApiBaseHelper().postAPICall(getWithdrawalRequestApi, parameter);

      return {
        'totalWalletAmountRequestTransactions':
            requestTransactionsList['total'].toString(),
        'walletAmountRequestTransactionList':
            (requestTransactionsList['data'] as List)
                .map((requestTransactionsData) =>
                    (WithdrawTransaction.fromJson(requestTransactionsData)))
                .toList()
      };
    } on Exception catch (e) {
      throw ApiException('$errorMesaage${e.toString()}');
    }
  }

  //This method is used to update user profile
  static Future<Map<String, dynamic>> updateUser(
      {required String userID,
      oldPwd,
      newPwd,
      username,
      userEmail,
      userMob}) async {
    try {
      var data = {};
      if ((oldPwd != '') && (newPwd != '')) {
        data[OLDPASS] = oldPwd;
        data[NEWPASS] = newPwd;
      }
      if (username != '') {
        data[USERNAME] = username;
      }
      if (userEmail != '') {
        data[EMAIL] = userEmail;
      }
      if (userMob != '') {
        data[MOBILE] = userMob;
      }

      final result = await ApiBaseHelper().postAPICall(getUpdateUserApi, data);

      bool error = result['error'];
      String? msg = result['message'];

      return {'error': error, 'message': msg};
    } catch (e) {
      throw ApiException('$errorMesaage${e.toString()}');
    }
  }

  //This method is used to update user profile picture
  static Future<Map<String, dynamic>> updateUserProfilePicture(
      {required File image, required BuildContext context}) async {
    try {
      var request = MultipartRequest('POST', (getUpdateUserApi));
      request.headers.addAll(headers ?? {});
      // request.fields[USER_ID] = context.read<UserProvider>().userId!;

      final mimeType = lookupMimeType(image.path);

      var extension = mimeType!.split('/');

      var pic = await MultipartFile.fromPath(
        IMAGE,
        image.path,
        contentType: MediaType('image', extension[1]),
      );
      request.files.add(pic);
      var response = await request.send();
      var responseData = await response.stream.toBytes();
      var responseString = String.fromCharCodes(responseData);
      var getdata = json.decode(responseString);
      return {
        'error': getdata['error'],
        'message': getdata['message'],
        'data': getdata['data']
      };
    } catch (e) {
      throw ApiException('$errorMesaage${e.toString()}');
    }
  }

  //this method is used to deleteUserAccount
  static Future<Map<String, dynamic>> deleteUserAccount(
      {required Map<String, dynamic> parameter}) async {
    try {
      var response =
          await ApiBaseHelper().postAPICall(deleteUserApi, parameter);
      return {'error': response['error'], 'message': response['message']};
    } catch (e) {
      throw ApiException('$errorMesaage${e.toString()}');
    }
  }

  static Future<Map<String, dynamic>> deleteSocialUserAccount(
      {required Map<String, dynamic> parameter}) async {
    try {
      var response =
          await ApiBaseHelper().postAPICall(deleteSocialAccApi, parameter);
      return {'error': response['error'], 'message': response['message']};
    } catch (e) {
      throw ApiException('$errorMesaage${e.toString()}');
    }
  }

  static Future<Map<String, dynamic>> fetchFavouriteProducts(
      {required Map<String, dynamic> parameter}) async {
    try {
      var favouriteData =
          await ApiBaseHelper().postAPICall(getFavApi, parameter);

      return {
        'error': favouriteData['error'],
        'message': favouriteData['message'],
        'favouriteList': (favouriteData['data'] as List)
            .map((favouriteProducts) => (Product.fromJson(favouriteProducts)))
            .toList()
      };
    } catch (e) {
      throw ApiException('$errorMesaage${e.toString()}');
    }
  }
}
