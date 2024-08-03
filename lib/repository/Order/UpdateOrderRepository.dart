import '../../Helper/ApiBaseHelper.dart';
import '../../Helper/Constant.dart';
import 'package:http/http.dart' as http;

import '../../Helper/String.dart';

class UpdateOrderRepository {
  ///This method is used to cancelOrder
  static Future<dynamic> cancelOrder(
      {required Map<String, dynamic> parameter, required Uri api}) async {
    try {
      var result = await ApiBaseHelper().postAPICall(api, parameter);

      return result;
    } on Exception catch (e) {
      throw ApiException('$errorMesaage${e.toString()}');
    }
  }

  static Future<dynamic> sendBankProof() async {
    try {
      var request = http.MultipartRequest('POST', setBankProofApi);

      return request;
    } on Exception catch (e) {
      throw ApiException('$errorMesaage${e.toString()}');
    }
  }

  static Future<dynamic> setRating() async {
    try {
      var request = http.MultipartRequest('POST', setRatingApi);

      return request;
    } on Exception catch (e) {
      throw ApiException('$errorMesaage${e.toString()}');
    }
  }
}
