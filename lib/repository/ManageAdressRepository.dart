import 'dart:core';
import 'package:eshop_multivendor/Helper/ApiBaseHelper.dart';
import '../Helper/Constant.dart';
import '../Helper/String.dart';
import '../Model/User.dart';

class ManageAddrRepository {
  ///This method is used to getFaqs
  static Future<Map<String, dynamic>> fetchAddress({
    required Map<String, dynamic> parameter,
  }) async {
    try {
      var addressList =
          await ApiBaseHelper().postAPICall(getAddressApi, parameter);

      return {
        'addressList': (addressList['data'] as List)
            .map((addressData) => (User.fromAddress(addressData)))
            .toList()
      };
    } on Exception catch (e) {
      throw ApiException('$errorMesaage${e.toString()}');
    }
  }

  static Future<Map<String, dynamic>> updateAddress({
    required Map<String, dynamic> parameter,
  }) async {
    try {
      var response =
          await ApiBaseHelper().postAPICall(updateAddressApi, parameter);

      return {
        'error': response['error'] as bool,
        'msg': response['message'].toString()
      };
    } on Exception catch (e) {
      throw ApiException('$errorMesaage${e.toString()}');
    }
  }

  static Future<Map<String, dynamic>> deleteAddress({
    required Map<String, dynamic> parameter,
  }) async {
    try {
      var response =
          await ApiBaseHelper().postAPICall(deleteAddressApi, parameter);

      return {
        'error': response['error'] as bool,
        'msg': response['message'].toString()
      };
    } on Exception catch (e) {
      throw ApiException('$errorMesaage${e.toString()}');
    }
  }
}
