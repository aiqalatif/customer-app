import 'dart:core';
import 'package:eshop_multivendor/Helper/ApiBaseHelper.dart';
import '../../Helper/Constant.dart';
import '../../Helper/String.dart';
import '../../Model/Section_Model.dart';

class FavRepository {
  ///This method is used to getfav
  static Future<Map<String, dynamic>> fetchFavorite({
    required Map<String, dynamic> parameter,
  }) async {
    try {
      var favList = await ApiBaseHelper().postAPICall(getFavApi, parameter);

      return {
        'error': favList['error'] as bool,
        'totalFav': favList['total'].toString(),
        'favList': (favList['data'] as List)
            .map((favData) => (Product.fromJson(favData)))
            .toList()
      };
    } on Exception catch (e) {
      throw ApiException('$errorMesaage${e.toString()}');
    }
  }
}
