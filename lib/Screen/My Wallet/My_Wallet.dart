import 'dart:async';
import 'package:eshop_multivendor/Provider/UserProvider.dart';
import 'package:eshop_multivendor/Provider/myWalletProvider.dart';
import 'package:eshop_multivendor/Provider/systemProvider.dart';
import 'package:eshop_multivendor/Screen/My%20Wallet/Widgets/myWalletDialog.dart';
import 'package:eshop_multivendor/Screen/My%20Wallet/Widgets/walletTransactionItem.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Helper/Color.dart';
import '../../Helper/Constant.dart';
import '../../Helper/String.dart';
import '../../Model/Transaction_Model.dart';
import '../../Model/getWithdrawelRequest/withdrawTransactiponsModel.dart';
import '../../widgets/ButtonDesing.dart';
import '../../widgets/desing.dart';
import '../Language/languageSettings.dart';
import '../../widgets/simmerEffect.dart';
import 'Widgets/withdrawRequestItem.dart';

class MyWallet extends StatefulWidget {
  const MyWallet({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return StateWallet();
  }
}

//GlobalKey<StateWallet>? walletPageState;

class StateWallet extends State<MyWallet> with TickerProviderStateMixin {
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Animation? buttonSqueezeanimation;
  AnimationController? buttonController;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  ScrollController controller = ScrollController();

  @override
  void initState() {
    super.initState();
    // walletPageState = GlobalKey<StateWallet>();
    Future.delayed(
      Duration.zero,
      () {
        context.read<SystemProvider>().paymentMethodList = [
          getTranslated(context, 'PAYPAL_LBL'),
          getTranslated(context, 'RAZORPAY_LBL'),
          getTranslated(context, 'PAYSTACK_LBL'),
          getTranslated(context, 'FLUTTERWAVE_LBL'),
          getTranslated(context, 'STRIPE_LBL'),
          getTranslated(context, 'PAYTM_LBL'),
          getTranslated(context, 'MidTrans'),
          getTranslated(context, 'My Fatoorah'),
          getTranslated(context, 'instamojo_lbl'),
          getTranslated(context, 'PHONEPE_LBL')
        ];

        context.read<SystemProvider>().fetchAvailablePaymentMethodsAndAssignIDs(
            settingType: PAYMENT_METHOD);
      },
    );

    controller.addListener(_scrollListener);
    buttonController = AnimationController(
        duration: const Duration(milliseconds: 2000), vsync: this);

    buttonSqueezeanimation = Tween(
      begin: deviceWidth! * 0.7,
      end: 50.0,
    ).animate(
      CurvedAnimation(
        parent: buttonController!,
        curve: const Interval(
          0.0,
          0.150,
        ),
      ),
    );

    Future.delayed(Duration.zero).then(
      (value) async {
        context.read<MyWalletProvider>().getUserWalletTransactions(
              context: context,
              walletTransactionIsLoadingMore: false,
            );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        titleSpacing: 0,
        backgroundColor: Theme.of(context).colorScheme.white,
        leading: Builder(
          builder: (BuildContext context) {
            return Container(
              margin: const EdgeInsets.all(10),
              child: InkWell(
                borderRadius: BorderRadius.circular(circularBorderRadius4),
                onTap: () => Navigator.of(context).pop(),
                child:  Center(
                  child: Icon(
                    Icons.arrow_back_ios_rounded,
                    color: Theme.of(context).colorScheme.fontColor,
                  ),
                ),
              ),
            );
          },
        ),
        title: Text(
          getTranslated(context, 'MYWALLET'),
          style: TextStyle(
            color: Theme.of(context).colorScheme.fontColor,
            fontWeight: FontWeight.normal,
            fontFamily: 'ubuntu',
          ),
        ),
        actions: <Widget>[
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            decoration: DesignConfiguration.shadow(),
            child: InkWell(
              borderRadius: BorderRadius.circular(circularBorderRadius4),
              onTap: () {
                MyWalletDialog.showFilterDialog(context);
              },
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Icon(
                  Icons.filter_alt_outlined,
                  color: Theme.of(context).colorScheme.primary,
                  size: 25,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Consumer<MyWalletProvider>(
        builder: (context, value, child) {
          if (value.getCurrentStatus == MyWalletStatus.isFailure) {
            return Center(
              child: Text(
                value.errorMessage,
                style: const TextStyle(
                  fontFamily: 'ubuntu',
                ),
              ),
            );
          } else if (value.getCurrentStatus == MyWalletStatus.isSuccsess) {
            return showContent(
                value.walletTransactionList, value.walletWithdrawalRequestList);
          }
          return const ShimmerEffect();
        },
      ),
    );
  }

  Future<void> _playAnimation() async {
    try {
      await buttonController!.forward();
    } on TickerCanceled {}
  }

  @override
  void dispose() {
    buttonController!.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    await context
        .read<MyWalletProvider>()
        .fetchUserWalletAmountWithdrawalRequestTransactions(
            walletTransactionIsLoadingMore: false, context: context);

    await context.read<MyWalletProvider>().getUserWalletTransactions(
        context: context, walletTransactionIsLoadingMore: false);
    return;
  }

  updateTransaction() async {
    await context.read<MyWalletProvider>().getUserWalletTransactions(
        context: context, walletTransactionIsLoadingMore: false);
  }

  _scrollListener() async {
    if (controller.offset >= controller.position.maxScrollExtent &&
        !controller.position.outOfRange &&
        !context.read<MyWalletProvider>().walletTransactionIsLoadingMore) {
      if (mounted) {
        if (context.read<MyWalletProvider>().walletTransactionHasMoreData) {
          context
              .read<MyWalletProvider>()
              .changeWalletTransactionIsLoadingMoreTo(true);

          await context
              .read<MyWalletProvider>()
              .getUserWalletTransactions(
                  context: context, walletTransactionIsLoadingMore: true)
              .then(
            (value) {
              context
                  .read<MyWalletProvider>()
                  .changeWalletTransactionIsLoadingMoreTo(false);
            },
          );
        }
      }
    }
  }

  showContent(List<TransactionModel> walletTransactionList,
      List<WithdrawTransaction> withdrawList) {
    return RefreshIndicator(
      color: colors.primary,
      key: _refreshIndicatorKey,
      onRefresh: _refresh,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: Card(
              elevation: 1,
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.account_balance_wallet,
                          color: Theme.of(context).colorScheme.fontColor,
                        ),
                        Text(
                          ' ${getTranslated(context, 'CURBAL_LBL')}',
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall!
                              .copyWith(
                                color: Theme.of(context).colorScheme.fontColor,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'ubuntu',
                              ),
                        ),
                      ],
                    ),
                    Consumer<UserProvider>(
                      builder: (context, userProvider, _) {
                        return Text(
                          ' ${DesignConfiguration.getPriceFormat(
                            context,
                            double.parse(userProvider.curBalance),
                          )!}',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge!
                              .copyWith(
                                fontFamily: 'ubuntu',
                                color: Theme.of(context).colorScheme.fontColor,
                                fontWeight: FontWeight.bold,
                              ),
                        );
                      },
                    ),
                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: SimBtn(
                            borderRadius: circularBorderRadius5,
                            size: 0.8,
                            title: getTranslated(context, 'ADD_MONEY'),
                            onBtnSelected: () async {
                              MyWalletDialog.showAddMoneyDialog(
                                  context /* , updateTransaction */);

                              /*   .then(
                                (value) async {
                                  if (value['message'] != '') {
                                    setSnackbar(value['message'], context);
                                  }
                                  setState(
                                    () {
                                      _isLoading = true;
                                    },
                                  );
                                  offset = 0;
                                  total = 0;
                                  await context
                                      .read<MyWalletProvider>()
                                      .fetchUserWalletAmountWithdrawalRequestTransactions(
                                          walletTransactionIsLoadingMore: false,
                                          context: context);
                                  await context
                                      .read<MyWalletProvider>()
                                      .getUserWalletTransactions(
                                          context: context,
                                          walletTransactionIsLoadingMore:
                                              false);
                                  setState(() {});
                                  return;
                                },
                              ); */
                            },
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: SimBtn(
                            borderRadius: circularBorderRadius5,
                            size: 0.8,
                            title: getTranslated(context, 'Withdraw'),
                            onBtnSelected: () {
                              MyWalletDialog.showWithdrawAmountDialog(context);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5.0),
            child: Text(
              context
                      .watch<MyWalletProvider>()
                      .getCurrentSelectedFilterIsTransaction
                  ? getTranslated(context, 'WALLET_TRANSACTION_HISTORY')
                  : getTranslated(context, 'Wallet History'),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: 'ubuntu',
              ),
            ),
          ),
          context
                  .watch<MyWalletProvider>()
                  .getCurrentSelectedFilterIsTransaction
              ? walletTransactionList.isEmpty
                  ? DesignConfiguration.getNoItem(context)
                  : Expanded(
                      child: ListView.builder(
                        controller: controller,
                        shrinkWrap: true,
                        itemCount: walletTransactionList.length,
                        physics: const BouncingScrollPhysics(),
                        itemBuilder: (context, index) {
                          return (index == walletTransactionList.length &&
                                  context
                                      .watch<MyWalletProvider>()
                                      .walletTransactionIsLoadingMore)
                              ? const Center(child: CircularProgressIndicator())
                              : WalletTransactionItem(
                                  transactionData: walletTransactionList[index],
                                );
                        },
                      ),
                    )
              : withdrawList.isNotEmpty
                  ? Expanded(
                      child: ListView.builder(
                        controller: controller,
                        shrinkWrap: true,
                        itemCount: withdrawList.length,
                        physics: const BouncingScrollPhysics(),
                        itemBuilder: (context, index) {
                          return (index == withdrawList.length &&
                                  context
                                      .watch<MyWalletProvider>()
                                      .walletTransactionIsLoadingMore)
                              ? const Center(child: CircularProgressIndicator())
                              : WithdrawRequestItem(
                                  withdrawItem: withdrawList[index],
                                );
                        },
                      ),
                    )
                  : DesignConfiguration.getNoItem(context),
        ],
      ),
    );
  }
}
