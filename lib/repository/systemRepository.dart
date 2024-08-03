import '../Helper/ApiBaseHelper.dart';
import '../Helper/Constant.dart';
import '../Helper/String.dart';

class SystemRepository {
  //
  //This method is used to fetch System policies {e.g. Privacy Policy, T&C etc..}
  static Future<Map<String, dynamic>> fetchSystemPolicies(
      {required Map<String, dynamic> parameter,
      required String policyType}) async {
    try {
      var policy = await ApiBaseHelper().postAPICall(getSettingApi, parameter);

      return {'policy': policy['data']};
    } on Exception catch (e) {
      throw ApiException('$errorMesaage${e.toString()}');
    }
  }

//
//This method is used to fetch system settings
  static Future<Map<String, dynamic>> fetchSystemSetting({
    required Map<String, dynamic> parameter,
  }) async {
    try {
      var systemSetting =
          await ApiBaseHelper().postAPICall(getSettingApi, parameter);

      return {
        'error': systemSetting['error'],
        'message': systemSetting['message'],
        'systemSetting': systemSetting['data']
      };
    } on Exception catch (e) {
      throw ApiException('$errorMesaage${e.toString()}');
    }
  }
}
