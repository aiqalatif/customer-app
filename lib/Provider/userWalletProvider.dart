import 'package:eshop_multivendor/Helper/ApiBaseHelper.dart';
import 'package:eshop_multivendor/Provider/UserProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Helper/Constant.dart';
import '../Helper/String.dart';
import '../Model/Transaction_Model.dart';
import '../repository/userRepository.dart';

enum TransactionStatus {
  initial,
  inProgress,
  isSuccsess,
  isFailure,
  isMoreLoading,
}

class UserTransactionProvider extends ChangeNotifier {
  TransactionStatus _transactionStatus = TransactionStatus.initial;
  List<TransactionModel> userTransactions = [];
  String errorMessage = '';
  int _transactionListOffset = 0;
  final int _transactionPerPage = perPage;

  bool hasMoreData = false;

  get getCurrentStatus => _transactionStatus;

  changeStatus(TransactionStatus status) {
    _transactionStatus = status;
    notifyListeners();
  }

  Future<void> getUserTransaction(BuildContext context,
      {int? customOffset}) async {
    try {
      if (customOffset != null) {
        _transactionListOffset = customOffset;
      }
      if (!hasMoreData) {
        changeStatus(TransactionStatus.inProgress);
      }

      var parameter = {
        LIMIT: _transactionPerPage.toString(),
        OFFSET: _transactionListOffset.toString(),
        // USER_ID: context.read<UserProvider>().userId,
      };

      Map<String, dynamic> result =
          await UserRepository.fetchUserTransaction(parameter: parameter);
      List<TransactionModel> tempList = [];

      for (var element in (result['transactionsList'] as List)) {
        tempList.add(element);
      }

      if (_transactionListOffset == 0) {
        userTransactions.clear();
      }

      userTransactions.addAll(tempList);

      if (int.parse(result['totalTransactions']) > _transactionListOffset) {
        _transactionListOffset += _transactionPerPage;
        hasMoreData = true;
      } else {
        hasMoreData = false;
      }
      changeStatus(TransactionStatus.isSuccsess);
    } catch (e) {
      errorMessage = e.toString();

      changeStatus(TransactionStatus.isFailure);
    }
  }

  Future<Map<String, dynamic>> sendAmountWithdrawRequest(
      {required String userID,
      required String withdrawalAmount,
      required String bankDetails}) async {
    try {
      changeStatus(TransactionStatus.inProgress);

      var parameter = {
        // USER_ID: userID,
        AMOUNT: withdrawalAmount,
        PAYMENT_ADD: bankDetails
      };

      Map<String, dynamic>? response =
          await UserRepository.sendAmountWithdrawRequest(parameter: parameter)
              .then(
        (requestData) {
          if (!requestData['error']) {
            changeStatus(TransactionStatus.isSuccsess);
            return {
              'message': requestData['message'],
              'newBalance': requestData['newBalance'],
            };
          } else {
            return {
              'message': requestData['message'],
              'newBalance': '',
            };
          }
        },
      ).onError(
        (error, stackTrace) {
          changeStatus(TransactionStatus.isFailure);
          return {
            'message': error.toString(),
            'newBalance': '',
          };
        },
      );
      return response;
    } catch (e) {
      changeStatus(TransactionStatus.isFailure);
      throw ApiException(e.toString());
    }
  }
}
