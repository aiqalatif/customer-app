import 'dart:core';
import 'package:eshop_multivendor/Helper/ApiBaseHelper.dart';
import 'package:eshop_multivendor/Model/Order_Model.dart';
import '../../Helper/Constant.dart';
import '../../Helper/String.dart';

class OrderRepository {
  ///This method is used to getOrder
  static Future<Map<String, dynamic>> fetchOrder({
    required Map<String, dynamic> parameter,
  }) async {
    try {
      var orderList = await ApiBaseHelper().postAPICall(getOrderApi, parameter);

      return {
        'error': orderList['error'] as bool,
        'totalOrder': orderList['total'].toString(),
        'orderList': (orderList['data'] as List)
            .map((orderData) => (OrderModel.fromJson(orderData)))
            .toList()
      };
    } on Exception catch (e) {
      throw ApiException('$errorMesaage${e.toString()}');
    }
  }

  static Future<String> getInvoiceHtml({
    required String orderId,
  }) async {
    try {
      var response = await ApiBaseHelper().postAPICall(getOrderInvoiceApi, {
        'order_id': orderId,
      });
      return response['data'];
    } on Exception catch (e) {
      throw ApiException('$errorMesaage${e.toString()}');
    }
  }
}
