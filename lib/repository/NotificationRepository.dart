import 'dart:core';
import 'package:eshop_multivendor/Helper/ApiBaseHelper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Helper/Constant.dart';
import '../Helper/String.dart';
import '../Model/Notification_Model.dart';

class NotificationRepository {
  ///This method is used to getNotifi
  static Future<Map<String, dynamic>> fetchNotification({
    required Map<String, dynamic> parameter,
  }) async {
    try {
      var notificationList =
          await ApiBaseHelper().postAPICall(getNotificationApi, parameter);

      return {
        'totalNoti': notificationList['total'].toString(),
        'notiList': (notificationList['data'] as List)
            .map((NotifiData) => (NotificationModel.fromJson(NotifiData)))
            .toList()
      };
    } on Exception catch (e) {
      throw ApiException('$errorMesaage${e.toString()}');
    }
  }

  static void addChatNotification({required String message}) async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    await sharedPreferences.reload();
    List<String> notificationMessages = sharedPreferences
            .getStringList(queueNotificationOfChatMessagesSharedPrefKey) ??
        List.from([]);

    notificationMessages.add(message);

    await sharedPreferences.setStringList(
        queueNotificationOfChatMessagesSharedPrefKey, notificationMessages);
  }

  static void clearChatNotifications() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    await sharedPreferences.reload();
    sharedPreferences
        .setStringList(queueNotificationOfChatMessagesSharedPrefKey, []);
  }

  static Future<List<String>> getChatNotifications() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    await sharedPreferences.reload();
    List<String> notificationMessages = sharedPreferences
            .getStringList(queueNotificationOfChatMessagesSharedPrefKey) ??
        List.from([]);
    return notificationMessages;
  }
}
