import 'dart:core';
import 'package:eshop_multivendor/Helper/ApiBaseHelper.dart';
import '../Helper/Constant.dart';
import '../Helper/String.dart';
import '../Model/Section_Model.dart';

class FavRepository {
  ///This method is used to getfav
  static Future<Map<String, dynamic>> fetchFavorite({
    required Map<String, dynamic> parameter,
  }) async {
    try {
      var favList = await ApiBaseHelper().postAPICall(getFavApi, parameter);

      return {
        'totalFav': favList['total'].toString(),
        'favList': (favList['data'] as List)
            .map((favData) => (Product.fromJson(favData)))
            .toList()
      };
    } on Exception catch (e) {
      throw ApiException('$errorMesaage${e.toString()}');
    }
  }

  ///This method is used to setFavorate
  static Future<Map<String, dynamic>> setFavorate({
    required Map<String, dynamic> parameter,
  }) async {
    try {
      var result = await ApiBaseHelper().postAPICall(setFavoriteApi, parameter);

      return result;
    } on Exception catch (e) {
      throw ApiException('$errorMesaage${e.toString()}');
    }
  }

  ///This method is used to setFavorate
  static Future<Map<String, dynamic>> setOfflineFavorateProducts({
    required Map<String, dynamic> parameter,
  }) async {
    try {
      var result = await ApiBaseHelper().postAPICall(getProductApi, parameter);

      return result;
    } on Exception catch (e) {
      throw ApiException('$errorMesaage${e.toString()}');
    }
  }
}
