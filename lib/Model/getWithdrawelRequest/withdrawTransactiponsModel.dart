import 'package:intl/intl.dart';

import '../../Helper/String.dart';

class WithdrawTransaction {
  String? id,
      userId,
      paymentType,
      paymentAddress,
      amountRequested,
      remarks,
      status,
      dateCreated;

  WithdrawTransaction({
    this.id,
    this.userId,
    this.paymentType,
    this.paymentAddress,
    this.amountRequested,
    this.remarks,
    this.status,
    this.dateCreated,
  });


  factory WithdrawTransaction.fromJson(Map<String, dynamic> json) {
    String date = json[DATE_CREATED];

    date = DateFormat('dd-MM-yyyy').format(
      DateTime.parse(date),
    );
    String? st = json[STATUS];
    if (st == '0') {
      st = PENDINg;
    } else if (st == '1') {
      st = ACCEPTEd;
    } else if (st == '2') {
      st = REJECTEd;
    }
    return WithdrawTransaction(
      id: json[ID],
      amountRequested: json[AMOUNT_REQUEST],
      status: st,
      dateCreated: date,
      userId: json[USER_ID],
      paymentType: json[PAYMERNT_TYPE],
      paymentAddress: json[PAYMENT_ADD],
      remarks: json[Remark],
    );
  }
}
