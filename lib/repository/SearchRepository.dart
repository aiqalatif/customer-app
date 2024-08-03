import 'dart:core';
import 'package:eshop_multivendor/Helper/ApiBaseHelper.dart';
import '../Helper/String.dart';
import '../../Model/Section_Model.dart';
import '../Helper/Constant.dart';

class SearchRepository {
  ///This method is used to get search product
  static Future<Map<String, dynamic>> fetchSearch({
    required Map<String, dynamic> parameter,
  }) async {
    try {
      var SearchList =
          await ApiBaseHelper().postAPICall(getProductApi, parameter);

      return {
        'error': SearchList['error'] as bool,
        'search': SearchList['search'] as String,
        'searchList': (SearchList['data'] as List)
            .map((searchData) => (Product.fromJson(searchData)))
            .toList()
      };
    } on Exception catch (e) {
      throw ApiException('$errorMesaage${e.toString()}');
    }
  }

  static Future<Map<String, dynamic>> fetchSeller({
    required Map<String, dynamic> parameter,
  }) async {
    try {
      var sellerList =
          await ApiBaseHelper().postAPICall(getSellerApi, parameter);

      return {
        'error': sellerList['error'] as bool,
        'totalSeller': sellerList['total'].toString(),
        'sellerList': (sellerList['data'] as List)
            .map((sellerData) => (Product.fromJson(sellerData)))
            .toList()
      };
    } on Exception catch (e) {
      throw ApiException('$errorMesaage${e.toString()}');
    }
  }
}
