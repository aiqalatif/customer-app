import 'package:eshop_multivendor/Helper/ApiBaseHelper.dart';
import 'package:eshop_multivendor/Screen/StripeService/Stripe_Service.dart';
import 'package:flutter/cupertino.dart';

//import 'package:paytm/paytm.dart';
import 'package:paytm_allinonesdk/paytm_allinonesdk.dart';
import '../Helper/Constant.dart';
import '../Helper/String.dart';

class PaymentRepository {
  //
//This method is used to fetch available payment methods
  static Future<Map<String, dynamic>>
      fetchAvailablePaymentMethodsAndPaymentGatewayIDs({
    required Map<String, dynamic> parameter,
  }) async {
    try {
      var systemSetting =
          await ApiBaseHelper().postAPICall(getSettingApi, parameter);

      return {
        'error': systemSetting['error'],
        'message': systemSetting['message'],
        'paymentMethods': systemSetting['data']['payment_method']
      };
    } on Exception catch (e) {
      throw ApiException('$errorMesaage${e.toString()}');
    }
  }

//This method is used to pay with paytm
  static Future<Map<dynamic, dynamic>> payWithPaytm({
    required Map<String, dynamic> apiParameter,
    required String paytmCallbackURL,
    required String paytmMerchantID,
    required String paytmOrderID,
    required String paytmTransactionAmount,
    required bool isTestingModeEnable,
  }) async {
    try {
      Map<dynamic, dynamic> response = await ApiBaseHelper()
          .postAPICall(getPytmChecsumkApi, apiParameter)
          .then(
        (paytmResponseFromAPI) async {
          var paytmResponse = await AllInOneSdk.startTransaction(
              paytmMerchantID,
              paytmOrderID,
              paytmTransactionAmount.toString(),
              paytmResponseFromAPI['txn_token']!,
              paytmCallbackURL,
              isTestingModeEnable,
              false);
          /* Map<dynamic, dynamic> paytmResponse = await Paytm.payWithPaytm(
            callBackUrl: paytmCallbackURL,
            mId: paytmMerchantID,
            orderId: paytmOrderID,
            txnToken: paytmResponseFromAPI['txn_token']!,
            txnAmount: paytmTransactionAmount.toString(),
            staging: isTestingModeEnable,
          ); */
          return paytmResponse!;
        },
      );
      return response;
    } catch (e) {
      throw ApiException('$errorMesaage${e.toString()}');
    }
  }

  //
//This method is used to pay with stripe
  static Future<StripeTransactionResponse> payWithStripe({
    required String currencyCode,
    required String stripeTransactionAmount,
    required String paymentFor,
    required BuildContext context,
  }) async {
    try {
      var response = await StripeService.payWithPaymentSheet(
          amount: (int.parse(stripeTransactionAmount) * 100).toString(),
          currency: currencyCode,
          from: paymentFor,
          context: context);

      return response;
    } catch (e) {
      throw ApiException('$errorMesaage${e.toString()}');
    }
  }

  //
  //This method is used to get paypal payment gateway link
  static Future<String> getPaypalPaymentGatewayLink({
    required Map<String, dynamic> apiParameter,
  }) async {
    try {
      var response =
          await ApiBaseHelper().postAPICall(paypalTransactionApi, apiParameter);
      if (!response['error']) {
        return response['data'];
      }
      return '';
    } catch (e) {
      throw ApiException('$errorMesaage${e.toString()}');
    }
  }

  //
  //This method is used to get flutterWave payment gateway link
  static Future<String> getFlutterWavePaymentGatewayLink({
    required Map<String, dynamic> apiParameter,
  }) async {
    try {
      var response =
          await ApiBaseHelper().postAPICall(flutterwaveApi, apiParameter);
      if (!response['error']) {
        return response['link'];
      }
      return '';
    } catch (e) {
      throw ApiException('$errorMesaage${e.toString()}');
    }
  }

  static Future<String> getInstamojoGatewayLink({
    required Map<String, dynamic> apiParameter,
  }) async {
    try {
      var response = await ApiBaseHelper()
          .postAPICall(getInstamojoWebviewApi, apiParameter);
      if (!response['error']) {
        if (response['data']['longurl'] != null &&
            response['data']['longurl'] != '') {
          return response['data']['longurl'];
        } else {
          return '';
        }
      }
      return '';
    } catch (e) {
      throw ApiException('$errorMesaage${e.toString()}');
    }
  }

  //
  //This method is used to get user wallet amount
  static Future<String> fetchUserCurrentBalance({
    required Map<String, dynamic> apiParameter,
  }) async {
    try {
      var response =
          await ApiBaseHelper().postAPICall(getWalTranApi, apiParameter);
      if (!response['error']) {
        return response['balance'];
      }
      return '';
    } catch (e) {
      throw ApiException('$errorMesaage${e.toString()}');
    }
  }

  //call midtrans p[ayment success api
  static Future<String> midtranswWebHook({
    required Map<String, dynamic> apiParameter,
  }) async {
    try {
      var response =
          await ApiBaseHelper().postAPICall(midtransBebhookApi, apiParameter);

      return response['message'];
    } catch (e) {
      throw ApiException('$errorMesaage${e.toString()}');
    }
  }

  //getOrderDate and time and other settings
  //
  static Future<Map<String, dynamic>> getDataTimeSettings({
    required var parameter,
  }) async {
    try {
      var responseData = await ApiBaseHelper().postAPICall(
        getSettingApi,
        parameter,
      );

      return responseData;
    } on Exception catch (e) {
      throw ApiException('$errorMesaage${e.toString()}');
    }
  }

  static Future<Map> getPhonePeDetails({
    required String userId,
    required String type,
    required String mobile,
    String? amount,
    required String orderId,
    required String transationId,
  }) async {
    try {
      var responseData = await ApiBaseHelper().postAPICall(
        getPhonePeDetailsApi,
        {
          'type': type,
          'mobile': mobile,
          if (amount != null) 'amount': amount,
          'order_id': orderId,
          'transation_id': transationId,
          'user_id': userId
        },
      );
      return responseData;
    } on Exception catch (e) {
      throw ApiException('$errorMesaage${e.toString()}');
    }
  }
}
