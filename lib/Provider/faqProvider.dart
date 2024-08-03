import 'package:eshop_multivendor/Provider/UserProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Helper/String.dart';
import '../repository/faqRepository.dart';

enum FaQProviderStatus {
  initial,
  inProgress,
  isSuccsess,
  isFailure,
}

class FaQProvider extends ChangeNotifier {
  String? currentProductId, question;
  String errorMessage = '';
  changeStatus(FaQProviderStatus status) {
    notifyListeners();
  }

  setProdId(String? value) {
    currentProductId = value;
    notifyListeners();
  }

  setquestion(String? value) {
    question = value;
    notifyListeners();
  }

  // add new Q.
  Future<Map<String, dynamic>> setFaqsQue(BuildContext context) async {
    try {
      var parameter = {
        // USER_ID: context.read<UserProvider>().userId,
        PRODUCT_ID: currentProductId,
        QUESTION: question
      };

      var result =
          await FaqRepository.setFaqsQueOnProduct(parameter: parameter);
      return result;
    } catch (e) {
      errorMessage = e.toString();
      return {};
    }
  }

  Future<Map<String, dynamic>> fetchProductFaqs(BuildContext context) async {
    try {
      var parameter = {
        // USER_ID: context.read<UserProvider>().userId,
        PRODUCT_ID: currentProductId,
      };

      var result =
          await FaqRepository.getFaqsQueOnProduct(parameter: parameter);
      return result;
    } catch (e) {
      errorMessage = e.toString();
      return {};
    }
  }
}
