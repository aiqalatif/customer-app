import 'package:eshop_multivendor/Helper/String.dart';

class AppSettingsModel {
  bool isAppleLoginAllowed;
  bool isGoogleLoginAllowed;
  bool isSMSGatewayActive;
  bool isCityWiseDeliveribility;

  AppSettingsModel({
    required this.isAppleLoginAllowed,
    required this.isGoogleLoginAllowed,
    required this.isSMSGatewayActive,
    required this.isCityWiseDeliveribility,
  });

  factory AppSettingsModel.fromMap(Map<String, dynamic> map) {
    final data = map['systemSetting']['system_settings'][0];
    final fullResponseData = map['systemSetting'];
    return AppSettingsModel(
      isAppleLoginAllowed: data[APPLE_LOGIN] == '1',
      isGoogleLoginAllowed: data[GOOGLE_LOGIN] == '1',
      isSMSGatewayActive: fullResponseData['authentication_settings'] != null &&
              fullResponseData['authentication_settings'].isNotEmpty
          ? fullResponseData['authentication_settings'][0]
                      ['authentication_method']
                  .toString()
                  .toLowerCase() ==
              'sms'
          : false,
      isCityWiseDeliveribility: data['city_wise_deliverability'] == '1',
    );
  }
}
