import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:flutter/material.dart';
import '../../../Helper/Constant.dart';
import '../../../Model/Transaction_Model.dart';
import '../../../widgets/desing.dart';
import '../../Language/languageSettings.dart';
import '../../../widgets/validation.dart';

class ListIteamOfTransaction extends StatelessWidget {
  List<TransactionModel> transactionModelData;
  int index;
  bool isLoadingMore;
  ListIteamOfTransaction(
      {Key? key,
      required this.isLoadingMore,
      required this.index,
      required this.transactionModelData})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color back;
    if (transactionModelData[index].status!.toLowerCase().contains('success')) {
      back = Colors.green;
    } else if (transactionModelData[index]
        .status!
        .toLowerCase()
        .contains('failed')) {
      back = Colors.red;
    } else {
      back = Colors.orange;
    }
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            padding: const EdgeInsets.all(5.0),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(circularBorderRadius5),
                border: Border.all(
                    width: 0.5,
                    color: Theme.of(context).disabledColor,
                    style: BorderStyle.solid)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        '${getTranslated(context, 'AMOUNT')} : ${DesignConfiguration.getPriceFormat(context, double.parse(transactionModelData[index].amt!))!}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.fontColor,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'ubuntu',
                        ),
                      ),
                    ),
                    Text(
                      transactionModelData[index].date!,
                      style: const TextStyle(
                        fontFamily: 'ubuntu',
                      ),
                    ),
                  ],
                ),
                const Divider(thickness: 0.5),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          '${getTranslated(context, 'ORDER_ID_LBL')} : ${transactionModelData[index].orderId!}',
                          style: const TextStyle(
                            fontFamily: 'ubuntu',
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: back,
                          borderRadius: const BorderRadius.all(
                            Radius.circular(circularBorderRadius4),
                          ),
                        ),
                        child: Text(
                          StringValidation.capitalize(
                              transactionModelData[index].status!),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.fontColor,
                            fontFamily: 'ubuntu',
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                transactionModelData[index].type!.isNotEmpty
                    ? Text(
                        '${getTranslated(context, 'PAYMENT_METHOD_LBL')} : ${transactionModelData[index].type!}',
                        style: const TextStyle(
                          fontFamily: 'ubuntu',
                        ),
                      )
                    : const SizedBox(),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: transactionModelData[index].msg!.isNotEmpty
                      ? Text(
                          '${getTranslated(context, 'MSG')} : ${transactionModelData[index].msg!}',
                          style: const TextStyle(
                            fontFamily: 'ubuntu',
                          ),
                        )
                      : const SizedBox(),
                ),
                transactionModelData[index].txnID != '' &&
                        transactionModelData[index].txnID!.isNotEmpty
                    ? Text(
                        '${getTranslated(context, 'Txn_id')} : ${transactionModelData[index].txnID!}',
                        style: const TextStyle(
                          fontFamily: 'ubuntu',
                        ),
                      )
                    : const SizedBox(),
              ],
            ),
          ),
        ),
        isLoadingMore && index == transactionModelData.length - 1
            ? const SizedBox(
                height: 100,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            : const SizedBox()
      ],
    );
  }
}
