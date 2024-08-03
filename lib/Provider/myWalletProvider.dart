import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Helper/Constant.dart';
import '../Helper/String.dart';
import '../Model/Transaction_Model.dart';
import '../Model/getWithdrawelRequest/withdrawTransactiponsModel.dart';
import '../repository/userRepository.dart';
import 'UserProvider.dart';

enum MyWalletStatus {
  initial,
  inProgress,
  isSuccsess,
  isFailure,
  isMoreLoading,
}

class MyWalletProvider extends ChangeNotifier {
  MyWalletStatus _transactionStatus = MyWalletStatus.initial;
  List<TransactionModel> walletTransactionList = [];
  List<WithdrawTransaction> walletWithdrawalRequestList = [];
  String errorMessage = '';
  int transactionListOffset = 0;
  int requestTransactionListOffset = 0;
  final int _transactionsPerPage = perPage;

  bool walletTransactionHasMoreData = false,
      walletTransactionIsLoadingMore = false,
      isLoading = true,
      _currentSelectedFilterIsTransaction = true;

  set setCurrentSelectedFilterIsTransaction(value) {
    _currentSelectedFilterIsTransaction = value;
    notifyListeners();
  }

  get getCurrentSelectedFilterIsTransaction =>
      _currentSelectedFilterIsTransaction;

  get getCurrentStatus => _transactionStatus;

  changeStatus(MyWalletStatus status) {
    _transactionStatus = status;
    notifyListeners();
  }

  changeWalletTransactionIsLoadingMoreTo(bool value) {
    walletTransactionIsLoadingMore = value;
    notifyListeners();
  }

  //
  //This method is used to fetchWalletTransactions
  Future<void> getUserWalletTransactions({
    required BuildContext context,
    required bool walletTransactionIsLoadingMore,
  }) async {
    try {
      var parameter = {
        LIMIT: _transactionsPerPage.toString(),
        OFFSET: transactionListOffset.toString(),
        // USER_ID: context.read<UserProvider>().userId,
        TRANS_TYPE: WALLET,
      };

      if (!walletTransactionIsLoadingMore) {
        parameter[OFFSET] = '0';
        walletTransactionList.clear();
        changeStatus(MyWalletStatus.inProgress);
      }

      Map<String, dynamic> result =
          await UserRepository.fetchUserWalletTransaction(parameter: parameter);
      List<TransactionModel> tempList = [];

      for (var element in (result['walletTransactionList'] as List)) {
        tempList.add(element);
      }

      walletTransactionList.addAll(tempList);

      print("new wallet balance***${result['balance']}");
      context.read<UserProvider>().setBalance(result['balance']);
      if (int.parse(result['totalTransactions']) > transactionListOffset) {
        transactionListOffset += _transactionsPerPage;
        walletTransactionHasMoreData = true;
      } else {
        walletTransactionHasMoreData = false;
      }
      changeStatus(MyWalletStatus.isSuccsess);
    } catch (e) {
      errorMessage = e.toString();
      changeStatus(MyWalletStatus.isFailure);
    }
  }

//This method is used to get user wallet amount withdrawal request transactions
  Future<void> fetchUserWalletAmountWithdrawalRequestTransactions({
    required BuildContext context,
    required bool walletTransactionIsLoadingMore,
  }) async {
    try {
      Map<String, dynamic>  parameter = {
        // USER_ID: context.read<UserProvider>().userId,
      };

      if (!walletTransactionHasMoreData) {
        walletWithdrawalRequestList.clear();
        changeStatus(MyWalletStatus.inProgress);
      }
      Map<String, dynamic> result =
          await UserRepository.getUserWalletAmountWithdrawalRequestTransactions(
        parameter: parameter,
      );
      List<WithdrawTransaction> tempList = [];

      for (var element
          in (result['walletAmountRequestTransactionList'] as List)) {
        tempList.add(element);
      }

      walletWithdrawalRequestList.addAll(tempList);

      if (int.parse(result['totalWalletAmountRequestTransactions']) >
          requestTransactionListOffset) {
        requestTransactionListOffset += _transactionsPerPage;
        walletTransactionHasMoreData = true;
      } else {
        walletTransactionHasMoreData = false;
      }
      changeStatus(MyWalletStatus.isSuccsess);
    } catch (e) {
      errorMessage = e.toString();
      changeStatus(MyWalletStatus.isFailure);
    }
  }
}
