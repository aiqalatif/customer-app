import '../Helper/ApiBaseHelper.dart';
import '../Helper/Constant.dart';
import '../Helper/String.dart';

class AuthRepository {
  //
  //This method is used to fetch System policies {e.g. Privacy Policy, T&C etc..}
  static Future<Map<String, dynamic>> fetchLoginData({
    required Map<String, dynamic> parameter,
  }) async {
    try {
      var loginDetail =
          await ApiBaseHelper().postAPICall(getUserLoginApi, parameter);

      return loginDetail;
    } on Exception catch (e) {
      throw ApiException('$errorMesaage${e.toString()}');
    }
  }

  static Future<Map<String, dynamic>> fetchSocialLoginData({
    required Map<String, dynamic> parameter,
  }) async {
    try {
      var loginDetail =
          await ApiBaseHelper().postAPICall(signUpUserApi, parameter);

      return loginDetail;
    } on Exception catch (e) {
      throw ApiException('$errorMesaage${e.toString()}');
    }
  }

  //validate referl code
  static Future<Map<String, dynamic>> validateReferal({
    required Map<String, dynamic> parameter,
  }) async {
    try {
      var result =
          await ApiBaseHelper().postAPICall(validateReferalApi, parameter);

      return result;
    } on Exception catch (e) {
      throw ApiException('$errorMesaage${e.toString()}');
    }
  }

  static Future<Map<String, dynamic>> fetchverificationData({
    required Map<String, dynamic> parameter,
  }) async {
    try {
      var loginDetail =
          await ApiBaseHelper().postAPICall(getVerifyUserApi, parameter);

      return loginDetail;
    } on Exception catch (e) {
      throw ApiException('$errorMesaage${e.toString()}');
    }
  }

  static Future<void> verifyOtp({
    required String mobileNumber,
    required String otp,
  }) async {
    try {
      var response = await ApiBaseHelper().postAPICall(getVerifyOtpApi,
          {MOBILE: mobileNumber.replaceAll(' ', ''), OTP: otp});
      if (response['error'] == true) {
        throw ApiException(response['message']);
      }
    } on Exception catch (e) {
      throw ApiException(e.toString());
    }
  }

  static Future<void> resendOtp({
    required String mobileNumber,
  }) async {
    try {
      var response = await ApiBaseHelper().postAPICall(
          getResendOtpApi, {MOBILE: mobileNumber.replaceAll(' ', '')});
      if (response['error'] == true) {
        throw ApiException(response['message']);
      }
    } on Exception catch (e) {
      throw ApiException(e.toString());
    }
  }

  static Future<Map<String, dynamic>> fetchSingUpData({
    required Map<String, dynamic> parameter,
  }) async {
    try {
      var loginDetail =
          await ApiBaseHelper().postAPICall(getUserSignUpApi, parameter);

      return loginDetail;
    } on Exception catch (e) {
      throw ApiException('$errorMesaage${e.toString()}');
    }
  }

  static Future<Map<String, dynamic>> fetchFetchReset({
    required Map<String, dynamic> parameter,
  }) async {
    try {
      var loginDetail =
          await ApiBaseHelper().postAPICall(getResetPassApi, parameter);

      return loginDetail;
    } on Exception catch (e) {
      throw ApiException('$errorMesaage${e.toString()}');
    }
  }
}
