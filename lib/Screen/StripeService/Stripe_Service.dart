import 'dart:convert';
import 'dart:math';
import 'package:eshop_multivendor/Provider/CartProvider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../../Provider/UserProvider.dart';

class StripeTransactionResponse {
  final String? message, status;
  bool? success;

  StripeTransactionResponse({
    this.message,
    this.success,
    this.status,
  });
}

class StripeService {
  static String apiBase = 'https://api.stripe.com/v1';
  static String paymentApiUrl = '${StripeService.apiBase}/payment_intents';
  static String? secret;

  static Map<String, String> headers = {
    'Authorization': 'Bearer ${StripeService.secret}',
    'Content-Type': 'application/x-www-form-urlencoded'
  };

  static init(String? stripeId, String? stripeMode) async {
    Stripe.publishableKey = stripeId ?? '';
    Stripe.merchantIdentifier = 'App Identifier';
    await Stripe.instance.applySettings();
  }

  static Future<StripeTransactionResponse> payWithPaymentSheet(
      {String? amount,
      String? currency,
      String? from,
      BuildContext? context,
      String? awaitedOrderId}) async {
    try {
      //create Payment intent
      var paymentIntent = await (StripeService.createPaymentIntent(
        amount: amount,
        currency: currency,
        from: from,
        context: context,
        awaitedOrderID: awaitedOrderId,
      ));
      //setting up Payment Sheet
      //6.0.0
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntent!['client_secret'],

          applePay: const PaymentSheetApplePay(
            merchantCountryCode: 'IN',
          ),
          googlePay: const PaymentSheetGooglePay(
            merchantCountryCode: 'IN',
            testEnv: true,
          ),
          // merchantCountryCode: 'IN',
          style: ThemeMode.light,
          merchantDisplayName: 'Test',
        ),
      );

      //open payment sheet
      await Stripe.instance.presentPaymentSheet();

      //store paymentID of customer
      // stripePayId = paymentIntent['id'];
      context!.read<CartProvider>().stripePayId = paymentIntent['id'];
      print("stripePayId****${context.read<CartProvider>().stripePayId}");

      //confirm payment
      var response = await http.post(
          Uri.parse(
              '${StripeService.paymentApiUrl}/${context.read<CartProvider>().stripePayId}'),
          headers: headers);

      var getdata = json.decode(response.body);
      var statusOfTransaction = getdata['status'];

      if (statusOfTransaction == 'succeeded') {
        return StripeTransactionResponse(
            message: 'Transaction successful',
            success: true,
            status: statusOfTransaction);
      } else if (statusOfTransaction == 'pending' ||
          statusOfTransaction == 'captured') {
        return StripeTransactionResponse(
            message: 'Transaction pending',
            success: true,
            status: statusOfTransaction);
      } else {
        return StripeTransactionResponse(
            message: 'Transaction failed',
            success: false,
            status: statusOfTransaction);
      }
    } on PlatformException catch (err) {
      return StripeService.getPlatformExceptionErrorResult(err);
    } catch (err) {
      return StripeTransactionResponse(
        message: 'Transaction failed: ${err.toString()}',
        success: false,
        status: 'fail',
      );
    }
  }

  static getPlatformExceptionErrorResult(err) {
    String message = 'Something went wrong';
    if (err.code == 'cancelled') {
      message = 'Transaction cancelled';
    }

    return StripeTransactionResponse(
        message: message, success: false, status: 'cancelled');
  }

  static Future<Map<String, dynamic>?> createPaymentIntent({
    String? amount,
    String? currency,
    String? from,
    BuildContext? context,
    String? awaitedOrderID,
  }) async {
    String orderId =
        'wallet-refill-user-${context!.read<UserProvider>().userId}-${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(900) + 100}';

    try {
      Map<String, dynamic> parameter = {
        'amount': amount,
        'currency': currency,
        'payment_method_types[]': 'card',
        'description': from,
      };
      if (from == 'wallet') parameter['metadata[order_id]'] = orderId;
      if (from == 'order') parameter['metadata[order_id]'] = awaitedOrderID;

      var response = await http.post(Uri.parse(StripeService.paymentApiUrl),
          body: parameter, headers: StripeService.headers);
      return jsonDecode(response.body.toString());
    } catch (err) {}
    return null;
  }
}
