import '../Helper/ApiBaseHelper.dart';
import '../Helper/Constant.dart';
import '../Helper/String.dart';
import '../Model/Section_Model.dart';

class PromoCodeRepository {
  //
  ///This method is used to get PromoCodes
  static Future<Map<String, dynamic>> fetchPromoCodes({
    required Map<String, dynamic> parameter,
  }) async {
    try {
      var promoCodeList =
          await ApiBaseHelper().postAPICall(getPromoCodeApi, parameter);
      return {
        'totalPromoCodes': promoCodeList['total'].toString(),
        'promoCodeList': (promoCodeList['promo_codes'] as List)
            .map((promoCodeData) => (Promo.fromJson(promoCodeData)))
            .toList()
      };
    } on Exception catch (e) {
      throw ApiException('$errorMesaage${e.toString()}');
    }
  }

  //
  ///This method is used to validate PromoCodes
  static Future<Map<String, dynamic>> validatePromoCodes({
    required Map<String, dynamic> parameter,
  }) async {
    try {
      var validateOutPut =
          await ApiBaseHelper().postAPICall(validatePromoApi, parameter);

      return validateOutPut;
    } on Exception catch (e) {
      throw ApiException('$errorMesaage${e.toString()}');
    }
  }
}
