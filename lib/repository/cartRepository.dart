import 'package:eshop_multivendor/Helper/ApiBaseHelper.dart';
import 'package:eshop_multivendor/Model/Section_Model.dart';
import '../Helper/Constant.dart';
import '../Helper/String.dart';

class CartRepository {
  static Future<Map<String, dynamic>> clearCart(
      {required Map<String, dynamic> parameter}) async {
    try {
      var cartData = await ApiBaseHelper().postAPICall(clearCartApi, parameter);
      return cartData;
    } catch (e) {
      throw ApiException('$errorMesaage${e.toString()}');
    }
  }

  static Future<Map<String, dynamic>> fetchUserCart(
      {required Map<String, dynamic> parameter}) async {
    try {
      var cartData = await ApiBaseHelper().postAPICall(getCartApi, parameter);
      return cartData;
    } catch (e) {
      throw ApiException('$errorMesaage${e.toString()}');
    }
  }

  static Future<Map<String, dynamic>> fetchUserOfflineCart(
      {required Map<String, dynamic> parameter}) async {
    try {
      var offlineCartData =
          await ApiBaseHelper().postAPICall(getProductApi, parameter);
      return {
        'error': offlineCartData['error'],
        'message': offlineCartData['message'],
        'offlineCartList': (offlineCartData['data'] as List)
            .map((data) => Product.fromJson(data))
            .toList()
      };
    } catch (e) {
      throw ApiException('$errorMesaage${e.toString()}');
    }
  }

  static Future<Map<String, dynamic>> manageCartAPICall({
    required Map<String, dynamic> parameter,
  }) async {
    try {
      var result = await ApiBaseHelper().postAPICall(manageCartApi, parameter);

      return result;
    } on Exception catch (e) {
      throw ApiException('$errorMesaage${e.toString()}');
    }
  }

  static Future<Map<String, dynamic>> deleteProductFromCartAPICall({
    required Map<String, dynamic> parameter,
  }) async {
    try {
      var result =
          await ApiBaseHelper().postAPICall(deleteProductFrmCartApi, parameter);

      return result;
    } on Exception catch (e) {
      throw ApiException('$errorMesaage${e.toString()}');
    }
  }

  static Future<Map<String, dynamic>> checkDeliverable({
    required Map<String, dynamic> parameter,
  }) async {
    try {
      var result = await ApiBaseHelper()
          .postAPICall(checkShipRocketChargesOnProduct, parameter);

      return result;
    } on Exception catch (e) {
      throw ApiException('$errorMesaage${e.toString()}');
    }
  }
}
