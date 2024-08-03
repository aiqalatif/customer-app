import 'dart:developer';

import 'package:eshop_multivendor/Helper/ApiBaseHelper.dart';
import 'package:eshop_multivendor/Screen/Payment/Widget/PaymentRadio.dart';
import 'package:eshop_multivendor/Screen/StripeService/Stripe_Service.dart';
import 'package:eshop_multivendor/Provider/SettingProvider.dart';
import 'package:eshop_multivendor/repository/paymentMethodRepository.dart';
import 'package:eshop_multivendor/repository/systemRepository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_paystack/flutter_paystack.dart';
import 'package:provider/provider.dart';
import '../Helper/String.dart';
import '../Screen/Language/languageSettings.dart';

enum SystemProviderPolicyStatus {
  initial,
  inProgress,
  isSuccsess,
  isFailure,
  isMoreLoading,
}

class SystemProvider extends ChangeNotifier {
  SystemProviderPolicyStatus _systemProviderPolicyStatus =
      SystemProviderPolicyStatus.initial;
  List<String> langCode = [
    'en',
    'zh',
    'es',
    'fr',
    'hi',
    'ar',
    'ru',
    'ja',
    'de'
  ];

  int currentLanguage = 0, selectedPaymentMethodIndex = 0;

  String errorMessage = '';
  String policy = '';

  String? midtransPaymentMode,
      midtransPaymentMethod,
      midtrashClientKey,
      midTranshMerchandId,
      midtransServerKey;

  String? myfatoorahToken,
      myfatoorahPaymentMode,
      myfatoorahSuccessUrl,
      myfatoorahErrorUrl,
      myfatoorahLanguage,
      myfatoorahCosuntry;

  bool? isPaypalEnable,
      isRazorpayEnable,
      isPhonepeEnable,
      paumoney,
      isPayStackEnable,
      isFlutterWaveEnable,
      isStripeEnable,
      isPaytmEnable,
      isMidtrashEnable,
      isMyFatoorahEnable,
      isInstamojoEnable,
      isPaytmOnTestMode = true;

  String? razorpayId,
      payStackKeyID,
      stripePublishKey,
      stripeSecretKey,
      stripePaymentMode = 'test',
      stripeCurrencyCode,
      paytmMerchantID,
      paytmMerchantKey,
      selectedPaymentMethodName,
      paytmMerId,
      phonePeMode,
      phonePeMerId,
      phonePeAppId;
  List<String?> paymentMethodList = [];
  List<String> paymentIconList = [
    'paypal',
    'rozerpay',
    'paystack',
    'flutterwave',
    'stripe',
    'paytm',
    'midtrans',
    'myfatoorah',
    'instamojo',
    'phonepe'
  ];
  List<RadioModel> payModel = [];

  get getCurrentStatus => _systemProviderPolicyStatus;

  changeStatus(SystemProviderPolicyStatus status) {
    _systemProviderPolicyStatus = status;
    notifyListeners();
  }

  //get System Policies
  Future getSystemPolicies(String policyType) async {
    try {
      changeStatus(SystemProviderPolicyStatus.inProgress);

      var parameter = {TYPE: policyType};
      var result = await SystemRepository.fetchSystemPolicies(
          parameter: parameter, policyType: policyType);
      policy = result['policy'][policyType][0].toString();

      changeStatus(SystemProviderPolicyStatus.isSuccsess);
    } catch (e) {
      errorMessage = e.toString();

      changeStatus(SystemProviderPolicyStatus.isFailure);
    }
  }

  Future<Locale> changeCurrentLanguage(
      {required int selectedLanguageIndex}) async {
    Locale locale = await setLocale(langCode[selectedLanguageIndex]);
    return locale;
  }

  getCurrentLanguage({required BuildContext context}) async {
    SettingProvider settingsProvider =
        Provider.of<SettingProvider>(context, listen: false);

    String getLanguage =
        await settingsProvider.getPrefrence(LAGUAGE_CODE) ?? '';
    currentLanguage = langCode.indexOf(getLanguage == '' ? 'en' : getLanguage);
    notifyListeners();
  }

  Future<Map<String, dynamic>> getSystemSettings({String? userID}) async {
    try {
      Map<String, dynamic> parameter = {};
      // if (userID != '') {
      //   parameter = {USER_ID: userID};
      // }
      var data =
          await SystemRepository.fetchSystemSetting(parameter: parameter);

      if (!data['error']) {
        var systemData = data['systemSetting']['system_settings'][0];

        supportedLocale = systemData['supported_locals'];

        cartBtnList = systemData['cart_btn_on_list'] == '1' ? true : false;
        refer = systemData['is_refer_earn_on'] == '1' ? true : false;
        CUR_CURRENCY = systemData['currency'];
        DECIMAL_POINTS = systemData['decimal_point'];

        RETURN_DAYS = systemData['max_product_return_days'];
        MAX_ITEMS = systemData['max_items_cart'];
        MIN_AMT = systemData['min_amount'];
        CUR_DEL_CHR = systemData['delivery_charge'];
        Is_APP_IN_MAINTANCE = systemData['is_customer_app_under_maintenance'];
        MAINTENANCE_MESSAGE = systemData['message_for_customer_app'];
        singleSellerOrderSystem =
            systemData['is_single_seller_order'] == '1' ? true : false;
        String? isVersionSystemOn = systemData['is_version_system_on'];
        extendImg = systemData['expand_product_images'] == '1' ? true : false;
        MIN_ALLOW_CART_AMT = systemData[MIN_CART_AMT];
        ISFLAT_DEL = systemData['area_wise_delivery_charge'].toString() == '0'
            ? true
            : false;

        IS_SHIPROCKET_ON = data['systemSetting']['shipping_method'][0]
            ['shiprocket_shipping_method'];

        IS_LOCAL_ON = data['systemSetting']['shipping_method'][0]
            ['local_shipping_method'];

        /*  if (userID != '') {
          
          REFER_CODE = data['systemSetting']['user_data'][0]['referral_code'];
        } */
        Map<String, dynamic> response = {
          'error': data['error'],
          'message': data['message'],
          'isVersionSystemOn': isVersionSystemOn,
          'androidVersion': systemData['current_version'],
          'iOSVersion': systemData['current_version_ios'],
          'isAppUnderMaintenance': Is_APP_IN_MAINTANCE,
        };

        Map<String, dynamic> tempData = data['systemSetting'];
        if (tempData.containsKey(TAG)) {
          response['tagList'] = List<String>.from(data['systemSetting'][TAG]);
        }

        if (userID != '') {
          response['cartCount'] = data['systemSetting']['user_data'][0]
                  ['cart_total_items']
              .toString();
          response['userBalance'] =
              data['systemSetting']['user_data'][0]['balance'] ?? '0';
          response['referCode'] =
              data['systemSetting']['user_data'][0]['referral_code'];

          response['pinCode'] = data['systemSetting']['user_data'][0][PINCODE];
        }
        return response;
      }
      return {'error': data['error'], 'message': data['message']};
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<void> fetchAvailablePaymentMethodsAndAssignIDs(
      {required String settingType}) async {
    try {
      var parameter = {TYPE: settingType};
      var result = await PaymentRepository
          .fetchAvailablePaymentMethodsAndPaymentGatewayIDs(
              parameter: parameter);

      if (!result['error']) {
        var payment = result['paymentMethods'];
        isPaypalEnable = payment['paypal_payment_method'] == '1' ? true : false;
        paumoney = payment['payumoney_payment_method'] == '1' ? true : false;
        isFlutterWaveEnable =
            payment['flutterwave_payment_method'] == '1' ? true : false;
        isRazorpayEnable =
            payment['razorpay_payment_method'] == '1' ? true : false;
        isPhonepeEnable =
            payment['phonepe_payment_method'] == '1' ? true : false;
        isPayStackEnable =
            payment['paystack_payment_method'] == '1' ? true : false;
        isStripeEnable = payment['stripe_payment_method'] == '1' ? true : false;
        isPaytmEnable = payment['paytm_payment_method'] == '1' ? true : false;
        isMidtrashEnable =
            payment['midtrans_payment_method'] == '1' ? true : false;
        isMyFatoorahEnable =
            payment['myfaoorah_payment_method'] == '1' ? true : false;

        isInstamojoEnable =
            payment['instamojo_payment_method'] == '1' ? true : false;

        if (isRazorpayEnable!) razorpayId = payment['razorpay_key_id'];
        if (isPayStackEnable!) {
          payStackKeyID = payment['paystack_key_id'];
          PaystackPlugin().initialize(publicKey: payStackKeyID!);
        }

        if (isPhonepeEnable ?? false) {
          phonePeAppId = payment['phonepe_app_id'];
          phonePeMode = payment['phonepe_payment_mode'];
          phonePeMerId = payment['phonepe_marchant_id'];
        }
        if (isMidtrashEnable!) {
          midTranshMerchandId = payment['midtrans_merchant_id'];
          midtransPaymentMethod = payment['midtrans_payment_method'];
          midtransPaymentMode = payment['midtrans_payment_mode'];
          midtransServerKey = payment['midtrans_server_key'];
          midtrashClientKey = payment['midtrans_client_key'];
        }
        if (isMyFatoorahEnable!) {
          myfatoorahToken = payment['myfatoorah_token'];
          myfatoorahPaymentMode = payment['myfatoorah_payment_mode'];
          myfatoorahSuccessUrl = payment['myfatoorah__successUrl'];
          myfatoorahErrorUrl = payment['myfatoorah__errorUrl'];
          myfatoorahLanguage = payment['myfatoorah_language'];
          myfatoorahCosuntry = payment['myfatoorah_country'];
        }

        if (isStripeEnable!) {
          stripePublishKey = payment['stripe_publishable_key'];
          stripeSecretKey = payment['stripe_secret_key'];
          stripeCurrencyCode = payment['stripe_currency_code'];
          stripePaymentMode = payment['stripe_mode'] ?? 'test';
          StripeService.secret = stripeSecretKey;
          StripeService.init(stripePublishKey, stripePaymentMode);
        }
        if (isPaytmEnable!) {
          paytmMerchantID = payment['paytm_merchant_id'];
          paytmMerchantKey = payment['paytm_merchant_key'];
          isPaytmOnTestMode =
              payment['paytm_payment_mode'] == 'sandbox' ? true : false;
        }

        for (int i = 0; i < paymentMethodList.length; i++) {
          payModel.add(
            RadioModel(
              isSelected: false,
              name: paymentMethodList[i],
              img: paymentIconList[i],
            ),
          );
        }
      }
    } catch (e) {}
  }
}
