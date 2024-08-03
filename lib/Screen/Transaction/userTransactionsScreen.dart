import 'dart:async';
import 'package:eshop_multivendor/Provider/userWalletProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Helper/Color.dart';
import '../../Helper/String.dart';
import '../../Model/Transaction_Model.dart';
import '../../widgets/appBar.dart';
import '../../widgets/desing.dart';
import '../Language/languageSettings.dart';
import '../../widgets/simmerEffect.dart';
import 'Widget/TransactionListIteams.dart';

class UserTransactions extends StatefulWidget {
  const UserTransactions({Key? key}) : super(key: key);

  @override
  _UserTransactionsState createState() => _UserTransactionsState();
}

class _UserTransactionsState extends State<UserTransactions>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  bool isLoadingMore = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Animation? buttonSqueezeanimation;
  AnimationController? buttonController;
  ScrollController controller = ScrollController();

  @override
  void initState() {
    Future.delayed(Duration.zero).then((value) => context
        .read<UserTransactionProvider>()
        .getUserTransaction(context, customOffset: 0));

    controller.addListener(_scrollListener);

    buttonController = AnimationController(
        duration: const Duration(milliseconds: 2000), vsync: this);

    buttonSqueezeanimation = Tween(
      begin: deviceWidth! * 0.7,
      end: 50.0,
    ).animate(CurvedAnimation(
      parent: buttonController!,
      curve: const Interval(
        0.0,
        0.150,
      ),
    ));
    super.initState();
  }

  @override
  void dispose() {
    buttonController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.white,
        key: _scaffoldKey,
        appBar:
            getSimpleAppBar(getTranslated(context, 'MYTRANSACTION'), context),
        body: Consumer<UserTransactionProvider>(
          builder: (context, value, child) {
            if (value.getCurrentStatus == TransactionStatus.isSuccsess) {
              return showContent(value.userTransactions);
            } else if (value.getCurrentStatus == TransactionStatus.isFailure) {
              return Center(
                child: Text(
                  getTranslated(context, 'ERROR'),
                  style: const TextStyle(
                    fontFamily: 'ubuntu',
                  ),
                ),
              );
            }
            return const ShimmerEffect();
          },
        ));
  }

  showContent(List<TransactionModel>? transactionsList) {
    return transactionsList!.isEmpty
        ? DesignConfiguration.getNoItem(context)
        : Stack(
            children: [
              ListView.builder(
                shrinkWrap: true,
                controller: controller,
                itemCount: transactionsList.length,
                physics: const AlwaysScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return ListIteamOfTransaction(
                    transactionModelData: transactionsList,
                    index: index,
                    isLoadingMore: isLoadingMore,
                  );
                },
              ),
            ],
          );
  }

  _scrollListener() async {
    if (controller.offset >= controller.position.maxScrollExtent &&
        !controller.position.outOfRange &&
        !isLoadingMore) {
      if (mounted) {
        if (context.read<UserTransactionProvider>().hasMoreData) {
          setState(() {
            isLoadingMore = true;
          });

          await context
              .read<UserTransactionProvider>()
              .getUserTransaction(context)
              .then(
            (value) {
              setState(
                () {
                  isLoadingMore = false;
                },
              );
            },
          );
        }
      }
    }
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
