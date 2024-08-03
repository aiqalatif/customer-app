import 'package:intl/intl.dart';

import '../Helper/String.dart';

class TransactionModel {
  String? id, amt, status, msg, date, type, txnID, orderId;

  TransactionModel(
      {this.id,
      this.amt,
      this.status,
      this.msg,
      this.date,
      this.type,
      this.txnID,
      this.orderId});

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    String date = json[TRN_DATE];

    date = DateFormat('dd-MM-yyyy HH:mm:ss').format(DateTime.parse(date));
    return TransactionModel(
      orderId: json[ORDER_ID],
      amt: json[AMOUNT],
      status: json[STATUS],
      msg: json[MESSAGE],
      type: json[TYPE],
      txnID: json[TXNID],
      id: json[ID],
      date: date,
    );
  }

  factory TransactionModel.fromReqJson(Map<String, dynamic> json) {
    String date = json[DATE];

    date = DateFormat('dd-MM-yyyy').format(DateTime.parse(date));
    String? st = json[STATUS];

    return TransactionModel(
      id: json[ID],
      amt: json['amount_requested'],
      status: st,
      msg: json[MSG],
      date: date,
    );
  }
}
