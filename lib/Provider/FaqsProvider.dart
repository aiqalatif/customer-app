import 'package:eshop_multivendor/Model/Faqs_Model.dart';
import 'package:flutter/material.dart';
import '../Helper/Constant.dart';
import '../Helper/String.dart';
import '../repository/faqsRepository.dart';

enum FaqsStatus {
  initial,
  inProgress,
  isSuccsess,
  isFailure,
  isMoreLoading,
}

class FaqsProvider extends ChangeNotifier {
  FaqsStatus _faqsStatus = FaqsStatus.initial;
  List<FaqsModel> faqsList = [];
  String errorMessage = '';
  int _faqsListOffset = 0;
  final int _faqsPerPage = perPage;

  bool hasMoreData = false;

  get getCurrentStatus => _faqsStatus;

  changeStatus(FaqsStatus status) {
    _faqsStatus = status;
    notifyListeners();
  }

  Future<void> getFaqs({required bool isLoadingMore}) async {
    try {
      if (isLoadingMore) {
        changeStatus(FaqsStatus.inProgress);
      }

      var parameter = {
        LIMIT: _faqsPerPage.toString(),
        OFFSET: _faqsListOffset.toString(),
      };

      Map<String, dynamic> result =
          await FaqsRepository.fetchFaqs(parameter: parameter);
      List<FaqsModel> tempList = [];

      for (var element in (result['faqsList'] as List)) {
        tempList.add(element);
      }

      faqsList.addAll(tempList);

      if (int.parse(result['totalFaqs']) > _faqsListOffset) {
        _faqsListOffset += _faqsPerPage;
        hasMoreData = true;
      } else {
        hasMoreData = false;
      }
      changeStatus(FaqsStatus.isSuccsess);
    } catch (e) {
      errorMessage = e.toString();
      changeStatus(FaqsStatus.isFailure);
    }
  }
}
