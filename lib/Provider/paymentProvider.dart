import 'dart:async';
import 'dart:io';

import 'package:eshop_multivendor/Provider/CartProvider.dart';
import 'package:eshop_multivendor/Provider/UserProvider.dart';
import 'package:eshop_multivendor/Screen/StripeService/Stripe_Service.dart';
import 'package:eshop_multivendor/repository/paymentMethodRepository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_paystack/flutter_paystack.dart';
import 'package:provider/provider.dart';

import '../Helper/String.dart';
import '../Model/Model.dart';
import '../Screen/Payment/Widget/PaymentRadio.dart';
import '../widgets/networkAvailablity.dart';

class PaymentProvider extends ChangeNotifier {
  final paystackPlugin = PaystackPlugin();
  List<String?> paymentMethodList = [];
  List<Model> timeSlotList = [];
  List<RadioModel> timeModel = [];
  List<RadioModel> payModel = [];
  List<RadioModel> timeModelList = [];
  String? allowDay;
  List<String> paymentIconList = [
    Platform.isIOS ? 'applepay' : 'gpay',
    'cod_payment',
    'paypal',
    'payu',
    'rozerpay',
    'paystack',
    'flutterwave',
    'stripe',
    'paytm',
    'banktransfer',
    'midtrans',
    'myfatoorah',
    'instamojo',
    'phonepe'
  ];
  bool codAllowed = true;
  bool isLoading = true;
  String? startingDate;
  String? bankName, bankNo, acName, acNo, exDetails;
  late bool cod,
      paypal,
      razorpay,
      paumoney,
      paystack,
      flutterwave,
      stripe,
      paytm = true,
      gpay = false,
      bankTransfer = true,
      midtrans,
      myfatoorah,
      instamojo,
      phonepe;

  Future<void> getdateTime(
    BuildContext context,
    Function updateNow,
  ) async {
    isNetworkAvail = await isNetworkAvailable();
    if (isNetworkAvail) {
      timeSlotList.clear();
      try {
        var parameter = {
          TYPE: PAYMENT_METHOD,
          // USER_ID: context.read<UserProvider>().userId
        };
        Map<String, dynamic> result =
            await PaymentRepository.getDataTimeSettings(parameter: parameter);
        bool error = result['error'];

        if (!error) {
          var data = result['data'];
          var timeSlot = data['time_slot_config'];
          allowDay = timeSlot['allowed_days'];
          print("timeslot: ${timeSlot['is_time_slots_enabled']}");
          context.read<CartProvider>().isTimeSlot =
              timeSlot['is_time_slots_enabled'] == '1' ? true : false;
          startingDate = timeSlot['starting_date'];
          codAllowed = data['is_cod_allowed'] == 1 ? true : false;

          var timeSlots = data['time_slots'];
          timeSlotList = (timeSlots as List)
              .map((timeSlots) => Model.fromTimeSlot(timeSlots))
              .toList();

          if (timeSlotList.isNotEmpty) {
            for (int i = 0; i < timeSlotList.length; i++) {
              if (context.read<CartProvider>().selectedDate != null) {
                DateTime today = DateTime.parse(startingDate!);

                DateTime date = today.add(
                    Duration(days: context.read<CartProvider>().selectedDate!));

                DateTime cur = DateTime.now();
                DateTime tdDate = DateTime(cur.year, cur.month, cur.day);

                if (date == tdDate) {
                  DateTime cur = DateTime.now();
                  String time = timeSlotList[i].lastTime!;
                  DateTime last = DateTime(
                    cur.year,
                    cur.month,
                    cur.day,
                    int.parse(time.split(':')[0]),
                    int.parse(time.split(':')[1]),
                    int.parse(time.split(':')[2]),
                  );

                  if (cur.isBefore(last)) {
                    timeModel.add(
                      RadioModel(
                        isSelected:
                            i == context.read<CartProvider>().selectedTime
                                ? true
                                : false,
                        name: timeSlotList[i].name,
                        img: '',
                      ),
                    );
                  }
                } else {
                  timeModel.add(
                    RadioModel(
                      isSelected: i == context.read<CartProvider>().selectedTime
                          ? true
                          : false,
                      name: timeSlotList[i].name,
                      img: '',
                    ),
                  );
                }
              } else {
                timeModel.add(
                  RadioModel(
                    isSelected: i == context.read<CartProvider>().selectedTime
                        ? true
                        : false,
                    name: timeSlotList[i].name,
                    img: '',
                  ),
                );
              }
            }
          }

          var payment = data['payment_method'];
          cod = codAllowed ? payment['cod_method'] == '1' : false;
          paypal = payment['paypal_payment_method'] == '1' ? true : false;
          paumoney = payment['payumoney_payment_method'] == '1' ? true : false;
          flutterwave =
              payment['flutterwave_payment_method'] == '1' ? true : false;
          razorpay = payment['razorpay_payment_method'] == '1' ? true : false;
          paystack = payment['paystack_payment_method'] == '1' ? true : false;
          stripe = payment['stripe_payment_method'] == '1' ? true : false;
          paytm = payment['paytm_payment_method'] == '1' ? true : false;
          bankTransfer = payment['direct_bank_transfer'] == '1' ? true : false;
          midtrans = payment['midtrans_payment_method'] == '1' ? true : false;
          instamojo = payment['instamojo_payment_method'] == '1' ? true : false;
          myfatoorah =
              payment['myfaoorah_payment_method'] == '1' ? true : false;
          phonepe = payment['phonepe_payment_method'] == '1' ? true : false;

          if (myfatoorah) {
            context.read<CartProvider>().myfatoorahToken =
                payment['myfatoorah_token'];
            context.read<CartProvider>().myfatoorahPaymentMode =
                payment['myfatoorah_payment_mode'];
            context.read<CartProvider>().myfatoorahSuccessUrl =
                payment['myfatoorah__successUrl'];
            context.read<CartProvider>().myfatoorahErrorUrl =
                payment['myfatoorah__errorUrl'];
            context.read<CartProvider>().myfatoorahLanguage =
                payment['myfatoorah_language'];
            context.read<CartProvider>().myfatoorahCountry =
                payment['myfatoorah_country'];
          }
          if (midtrans) {
            context.read<CartProvider>().midTranshMerchandId =
                payment['midtrans_merchant_id'];
            context.read<CartProvider>().midtransPaymentMethod =
                payment['midtrans_payment_method'];
            context.read<CartProvider>().midtransPaymentMode =
                payment['midtrans_payment_mode'];
            context.read<CartProvider>().midtransServerKey =
                payment['midtrans_server_key'];
            context.read<CartProvider>().midtrashClientKey =
                payment['midtrans_client_key'];
          }
          if (razorpay) {
            context.read<CartProvider>().razorpayId =
                payment['razorpay_key_id'];
          }
          if (paystack) {
            context.read<CartProvider>().paystackId =
                payment['paystack_key_id'];

            paystackPlugin.initialize(
                publicKey: context.read<CartProvider>().paystackId!);
          }
          if (stripe) {
            context.read<CartProvider>().stripeId =
                payment['stripe_publishable_key'];
            context.read<CartProvider>().stripeSecret =
                payment['stripe_secret_key'];
            context.read<CartProvider>().stripeCurCode =
                payment['stripe_currency_code'];
            context.read<CartProvider>().stripeMode =
                payment['stripe_mode'] ?? 'test';
            StripeService.secret = context.read<CartProvider>().stripeSecret;
            StripeService.init(context.read<CartProvider>().stripeId,
                context.read<CartProvider>().stripeMode);
          }
          if (paytm) {
            context.read<CartProvider>().paytmMerId =
                payment['paytm_merchant_id'];
            context.read<CartProvider>().paytmMerKey =
                payment['paytm_merchant_key'];
            context.read<CartProvider>().payTesting =
                payment['paytm_payment_mode'] == 'sandbox' ? true : false;
          }

          if (bankTransfer) {
            bankName = payment['bank_name'];
            bankNo = payment['bank_code'];
            acName = payment['account_name'];
            acNo = payment['account_number'];
            exDetails = payment['notes'];
          }

          if (instamojo) {
            context.read<CartProvider>().instamojoPaymentMode =
                payment['instamojo_payment_mode'];
          }
          if (phonepe) {
            context.read<CartProvider>().phonePeAppId =
                payment["phonepe_app_id"];
            context.read<CartProvider>().phonePeMode =
                payment["phonepe_payment_mode"];
            context.read<CartProvider>().phonePeMerId =
                payment["phonepe_marchant_id"];
          }

          for (int i = 0; i < paymentMethodList.length; i++) {
            payModel.add(
              RadioModel(
                isSelected: i == context.read<CartProvider>().selectedMethod
                    ? true
                    : false,
                name: paymentMethodList[i],
                img: paymentIconList[i],
              ),
            );
          }
        } else {}

        isLoading = false;
        updateNow();
      } on TimeoutException catch (_) {}
    } else {
      isNetworkAvail = false;
      updateNow();
    }
  }

  Future<Map<String, dynamic>> payWithPaytm({
    required String userID,
    required String orderID,
    required String paymentAmount,
    required String paytmCallBackURL,
    required String paytmMerchantID,
    required bool isTestingModeEnable,
  }) async {
    try {
      var parameter = {
        AMOUNT: paymentAmount,
        // USER_ID: userID,
        ORDER_ID: orderID
      };
      Map<dynamic, dynamic> paytmResponse =
          await PaymentRepository.payWithPaytm(
                  apiParameter: parameter,
                  paytmCallbackURL: paytmCallBackURL,
                  paytmMerchantID: paytmMerchantID,
                  paytmOrderID: orderID,
                  paytmTransactionAmount: paymentAmount,
                  isTestingModeEnable: isTestingModeEnable)
              .then(
        (value) {
          return value;
        },
      ).onError(
        (error, stackTrace) {
          return {};
        },
      );

      Map<String, dynamic> response = {
        'error': true,
        'status': false,
        'message': 'Something went Wrong'
      };

      if (paytmResponse['errorCode'] == null) {
        if (paytmResponse['STATUS'] == 'TXN_SUCCESS') {
          response['error'] = false;
          response['status'] = true;
          response['message'] = 'Transaction Successful';
        } else {
          response['error'] = true;
          response['status'] = false;
          response['message'] = 'Transaction Failed';
        }
      } else {
        response['error'] = paytmResponse['error'];
        response['message'] = paytmResponse['RESPMSG'];
      }

/*       if (paytmResponse['error']) {
        response['error'] = paytmResponse['error'];
        response['message'] = paytmResponse['errorMessage'];
      } else {
        if (paytmResponse['response'] != null) {
          if (paytmResponse['response']['STATUS'] == 'TXN_SUCCESS') {
            response['error'] = false;
            response['status'] = true;
            response['message'] = 'Transaction Successful';
          } else if (paytmResponse['response']['STATUS'] == 'TXN_FAILURE') {
            response['error'] = true;
            response['status'] = false;
            response['message'] = 'Transaction Failed';
          }
        }
      } */
      return response;
    } catch (e) {
      return {
        'error': true,
        'status': false,
        'message': 'Something went Wrong'
      };
    }
  }

  Future<Map<String, dynamic>> payWithStripe({
    required String paymentAmount,
    required String currencyCode,
    required String paymentFor,
    required BuildContext context,
  }) async {
    try {
      StripeTransactionResponse stripeResponse =
          await PaymentRepository.payWithStripe(
              currencyCode: currencyCode,
              stripeTransactionAmount: paymentAmount,
              paymentFor: paymentFor,
              context: context);

      Map<String, dynamic> response = {
        'error': true,
        'status': false,
        'message': 'Something went Wrong'
      };

      if (stripeResponse.status == 'succeeded') {
        response['error'] = false;
        response['status'] = true;
        response['message'] = 'Transaction Successful';
      } else {
        response['error'] = true;
        response['status'] = false;
        response['message'] = stripeResponse.message;
      }

      return response;
    } catch (e) {
      return {
        'error': true,
        'status': false,
        'message': 'Something went Wrong'
      };
    }
  }

  Future<Map<String, dynamic>> payWithPayStack({
    required int paymentAmount,
    required String userEmail,
    required String reference,
    required String payStackID,
    required BuildContext context,
  }) async {
    try {
      await paystackPlugin.initialize(publicKey: payStackID);

      Charge charge = Charge()
        ..amount = paymentAmount
        ..email = userEmail
        ..reference = reference;

      CheckoutResponse response = await paystackPlugin.checkout(
        context,
        method: CheckoutMethod.card,
        charge: charge,
      );
      if (response.status) {
        return {
          'error': false,
          'message': 'Transaction Successful',
          'status': true
        };
      } else {
        return {
          'error': false,
          'message': response.message,
          'status': true,
        };
      }
    } catch (e) {
      return {
        'error': true,
        'status': false,
        'message': e.toString(),
      };
    }
  }

  Future<String> getPaypalGatewayLink({
    required String userID,
    required String orderID,
    required String paymentAmount,
  }) async {
    try {
      var parameter = {
        AMOUNT: paymentAmount,
        // USER_ID: userID,
        ORDER_ID: orderID
      };
      String paypalPaymentGatewayLink =
          await PaymentRepository.getPaypalPaymentGatewayLink(
        apiParameter: parameter,
      );
      return paypalPaymentGatewayLink;
    } catch (e) {
      return '';
    }
  }

  Future<String> getFlutterWaveGatewayLink({
    required String userID,
    required String paymentAmount,
    required String unioqueOrderId,
  }) async {
    try {
      var parameter = {
        AMOUNT: paymentAmount,
        // USER_ID: userID,
        ORDERID: unioqueOrderId,
      };
      String flutterWavePaymentGatewayLink =
          await PaymentRepository.getFlutterWavePaymentGatewayLink(
        apiParameter: parameter,
      );
      return flutterWavePaymentGatewayLink;
    } catch (e) {
      return '';
    }
  }

  Future<String> getInstamojoGatewayLink({
    required String userID,
    required String paymentAmount,
    required String unioqueOrderId,
  }) async {
    try {
      var parameter = {
        AMOUNT: paymentAmount,
        // USER_ID: userID,
        ORDERID: unioqueOrderId,
      };
      String flutterWavePaymentGatewayLink =
          await PaymentRepository.getInstamojoGatewayLink(
        apiParameter: parameter,
      );
      return flutterWavePaymentGatewayLink;
    } catch (e) {
      return '';
    }
  }

  Future<String> getUserCurrentBalance(BuildContext context) async {
    await Future.delayed(const Duration(seconds: 1));
    try {
      var parameter = {
        LIMIT: '1',
        OFFSET: '0',
        // USER_ID: context.read<UserProvider>().userId,
        TRANS_TYPE: WALLET
      };

      String currentBalance = await PaymentRepository.fetchUserCurrentBalance(
        apiParameter: parameter,
      );

      return currentBalance;
    } catch (e) {
      return '';
    }
  }

// call after payment success

  Future<String> midtransWebhook(String orderId) async {
    await Future.delayed(const Duration(seconds: 1));
    try {
      var parameter = {
        ORDER_ID: orderId,
      };

      String msg = await PaymentRepository.midtranswWebHook(
        apiParameter: parameter,
      );
      return msg;
    } catch (e) {
      return '';
    }
  }
}
