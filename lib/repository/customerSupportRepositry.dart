import '../Helper/ApiBaseHelper.dart';
import '../Helper/Constant.dart';
import '../Helper/String.dart';

class CustomerSupportRepository {
  //
  static Future<Map<String, dynamic>> editOrAddAPI({
    required var parameter,
    required bool edit,
  }) async {
    try {
      var responseData = await ApiBaseHelper().postAPICall(
        edit ? editTicketApi : addTicketApi,
        parameter,
      );

      return responseData;
    } on Exception catch (e) {
      throw ApiException('$errorMesaage${e.toString()}');
    }
  }

  //
  static Future<Map<String, dynamic>> getType() async {
    try {
      var responseData =
          await ApiBaseHelper().postAPICall(getTicketTypeApi, {});

      return responseData;
    } on Exception catch (e) {
      throw ApiException('$errorMesaage${e.toString()}');
    }
  }

  
  //
  static Future<Map<String, dynamic>> getTicket({
    required var parameter,
  }) async {
    try {
      var responseData =
          await ApiBaseHelper().postAPICall(getTicketApi, parameter);

      return responseData;
    } on Exception catch (e) {
      throw ApiException('$errorMesaage${e.toString()}');
    }
  }
}
