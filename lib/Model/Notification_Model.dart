
import 'package:intl/intl.dart';

import '../Helper/String.dart';

class NotificationModel {
  String? id, title, desc, img, typeId, date, type;

  NotificationModel({
    this.id,
    this.title,
    this.desc,
    this.img,
    this.typeId,
    this.date,
    this.type,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    String date = json[DATE];

    date = DateFormat('dd-MM-yyyy').format(DateTime.parse(date));
    return NotificationModel(
      id: json[ID],
      title: json[TITLE],
      desc: json[MESSAGE],
      img: json[IMAGE],
      typeId: json[TYPE_ID],
      type: json[TYPE],
      date: date,
    );
  }
}
