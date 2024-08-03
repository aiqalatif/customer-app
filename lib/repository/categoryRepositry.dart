import '../Helper/ApiBaseHelper.dart';
import '../Helper/Constant.dart';
import '../Helper/String.dart';

class CategoryRepository {
  // get data for product list
  static Future<Map<String, dynamic>> getCategory({
    required var parameter,
  }) async {
    try {
      var responseData =
          await ApiBaseHelper().postAPICall(getCatApi, parameter);

      return responseData;
    } on Exception catch (e) {
      throw ApiException('$errorMesaage${e.toString()}');
    }
  }
} 
