import 'dart:core';
import 'package:eshop_multivendor/Helper/ApiBaseHelper.dart';
import '../Helper/Constant.dart';
import '../Helper/String.dart';
import '../Model/Faqs_Model.dart';

class FaqsRepository {
  ///This method is used to getFaqs
  static Future<Map<String, dynamic>> fetchFaqs({
    required Map<String, dynamic> parameter,
  }) async {
    try {
      var faqsList = await ApiBaseHelper().postAPICall(getFaqsApi, parameter);
      return {
        'totalFaqs': faqsList['total'].toString(),
        'faqsList': (faqsList['data'] as List)
            .map((faqsData) => (FaqsModel.fromProfileFaq(faqsData)))
            .toList()
      };
    } on Exception catch (e) {
      throw ApiException('$errorMesaage${e.toString()}');
    }
  }
}
