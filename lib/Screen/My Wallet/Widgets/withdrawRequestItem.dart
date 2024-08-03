import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:flutter/material.dart';
import '../../../Helper/Constant.dart';
import '../../../Helper/String.dart';
import '../../../Model/getWithdrawelRequest/withdrawTransactiponsModel.dart';
import '../../../widgets/desing.dart';
import '../../Language/languageSettings.dart';
import '../../../widgets/validation.dart';

class WithdrawRequestItem extends StatelessWidget {
  WithdrawTransaction withdrawItem;
  WithdrawRequestItem({Key? key, required this.withdrawItem}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color back;
    if (withdrawItem.status == 'success' || withdrawItem.status == ACCEPTEd) {
      back = Colors.green;
    } else if (withdrawItem.status == PENDINg) {
      back = Colors.orange;
    } else {
      back = Colors.red;
    }

    return Card(
      elevation: 0,
      margin: const EdgeInsets.all(5.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(circularBorderRadius4),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    "${getTranslated(context, "AMOUNT")} : ${DesignConfiguration.getPriceFormat(context, double.parse(withdrawItem.amountRequested!))!}",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.black,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'ubuntu',
                    ),
                  ),
                  const Spacer(),
                  Text(
                    withdrawItem.dateCreated!,
                    style: const TextStyle(
                      fontFamily: 'ubuntu',
                    ),
                  ),
                ],
              ),
              const Divider(),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    "${getTranslated(context, "ID_LBL")} : ${withdrawItem.id!}",
                    style: const TextStyle(
                      fontFamily: 'ubuntu',
                    ),
                  ),
                  const Spacer(),
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                    decoration: BoxDecoration(
                      color: back,
                      borderRadius: const BorderRadius.all(
                        Radius.circular(circularBorderRadius4),
                      ),
                    ),
                    child: Text(
                      StringValidation.capitalize(withdrawItem.status!),
                      style: TextStyle(
                        fontFamily: 'ubuntu',
                        color: Theme.of(context).colorScheme.white,
                      ),
                    ),
                  )
                ],
              ),
              withdrawItem.paymentAddress != null &&
                      withdrawItem.paymentAddress!.isNotEmpty
                  ? Text(
                      "${getTranslated(context, "Payment Address")} : ${withdrawItem.paymentAddress!}.",
                      style: const TextStyle(
                        fontFamily: 'ubuntu',
                      ),
                    )
                  : const SizedBox(),
              withdrawItem.paymentType != null &&
                      withdrawItem.paymentType!.isNotEmpty
                  ? Text(
                      "${getTranslated(context, "Payment Type")} : ${withdrawItem.paymentType!}",
                      style: const TextStyle(
                        fontFamily: 'ubuntu',
                      ),
                    )
                  : const SizedBox(),
              withdrawItem.remarks != null
                  ? Text(
                      '${getTranslated(context, 'Remark')}: ${withdrawItem.remarks}',
                      style: const TextStyle(
                        fontFamily: 'ubuntu',
                      ),
                    )
                  : const SizedBox(),
            ],
          ),
        ),
      ),
    );
  }
}
