// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';
import 'package:eshop_multivendor/Helper/Constant.dart';
import 'package:eshop_multivendor/Helper/routes.dart';
import 'package:eshop_multivendor/Model/personalChatHistory.dart';
import 'package:eshop_multivendor/Provider/SettingProvider.dart';
import 'package:eshop_multivendor/Provider/UserProvider.dart';
import 'package:eshop_multivendor/Screen/Dashboard/Dashboard.dart';
import 'package:eshop_multivendor/cubits/personalConverstationsCubit.dart';
import 'package:eshop_multivendor/repository/NotificationRepository.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:eshop_multivendor/Model/message.dart' as msg;

import '../../Helper/String.dart';
import '../../Provider/chatProvider.dart';
import '../../Provider/pushNotificationProvider.dart';
import '../../main.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
FirebaseMessaging messaging = FirebaseMessaging.instance;

class PushNotificationService {
  late BuildContext context;

  PushNotificationService({required this.context});

  Future<void> initialise() async {
    permission();
    FirebaseMessaging.onBackgroundMessage(myBackgroundMessageHandler);
    initLocalNotifications();
    initFirebaseMessaging();
    setDeviceToken();
  }

  void permission() async {
    await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    // await messaging.setForegroundNotificationPresentationOptions(
    //   alert: true,
    //   badge: true,
    //   sound: true,
    // );
  }

  void initLocalNotifications() {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('mipmap/notification');
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings();
    const DarwinInitializationSettings initializationSettingsMacOS =
        DarwinInitializationSettings();
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
      macOS: initializationSettingsMacOS,
    );

    flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse:
          (NotificationResponse notificationResponse) async {
        if (notificationResponse.payload != null) {
          List<String> pay = notificationResponse.payload!.split(',');

          //If the type is chat
          if (pay[0] == 'chat') {
            String payload = notificationResponse.payload ?? '';
            payload = payload.replaceFirst('${pay[0]},', '');

            if (converstationScreenStateKey.currentState?.mounted ?? false) {
              Navigator.of(context).pop();
            }
            final message = msg.Message.fromJson(jsonDecode(payload));
            
            Routes.navigateToConverstationScreen( 
                context: context,
                isGroup: false,
                personalChatHistory: PersonalChatHistory(
                    unreadMsg: '1',
                    opponentUserId: message.fromId,
                    opponentUsername: message.sendersName,
                    image: message.picture));
          } else {
            handleNotificationPayload(pay);
          }
        } else {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => MyApp(sharedPreferences: prefs),
            ),
          );
        }
      },
    );
  }

  void _onTapChatNotification({required RemoteMessage message}) {
    if ((converstationScreenStateKey.currentState?.mounted) ?? false) {
      Navigator.of(context).pop();
    }

    final messages = jsonDecode(message.data['message']) as List;

    if (messages.isEmpty) {
      return;
    }

    final messageDetails =
        msg.Message.fromJson(jsonDecode(json.encode(messages.first)));

    Routes.navigateToConverstationScreen(
        context: context,
        isGroup: false,
        personalChatHistory: PersonalChatHistory(
            unreadMsg: '1',
            opponentUserId: messageDetails.fromId,
            opponentUsername: messageDetails.sendersName,
            image: messageDetails.picture));
  }

  void initFirebaseMessaging() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      handleIncomingMessage(message);
    });

    FirebaseMessaging.onBackgroundMessage(myBackgroundMessageHandler);

    messaging.getInitialMessage().then((RemoteMessage? message) async {
      if ((message?.data['type'] ?? '') == 'chat') {
        _onTapChatNotification(message: message!);
      } else {
        bool back = await Provider.of<SettingProvider>(context, listen: false)
            .getPrefrenceBool(ISFROMBACK);
        if (message != null) {
          if (back) {
            handleNotificationPayload([
              message.data['type'] ?? '',
              message.data['type_id'] ?? '',
              message.data['link'] ?? ''
            ]);
            Provider.of<SettingProvider>(context, listen: false)
                .setPrefrenceBool(ISFROMBACK, false);
          }
        }
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      if ((message.data['type'] ?? '') == 'chat') {
        _onTapChatNotification(message: message);
      } else {

        SharedPreferences prefs = await SharedPreferences.getInstance();
        handleNotificationPayload([
          message.data['type'] ?? '',
          message.data['type_id'] ?? '',
          message.data['link']
        ]);
        Provider.of<SettingProvider>(context, listen: false)
            .setPrefrenceBool(ISFROMBACK, false);
      }
    });
  }

  void setDeviceToken(
      {bool clearSessionToken = false, SettingProvider? settingProvider}) {
    if (clearSessionToken) {
      settingProvider ??= Provider.of<SettingProvider>(context, listen: false);
      settingProvider.setPrefrence(FCMTOKEN, '');
    }
    messaging.getToken().then((token) async {
      context.read<PushNotificationProvider>().registerToken(token, context);
    });
  }

  Future<void> handleNotificationPayload(List<String> payload) async {
    String type = payload[0];
    String id = payload[1];
    String urlLink = payload[2];

    switch (type) {
      case 'products':
        context
            .read<PushNotificationProvider>()
            .getProduct(id, 0, 0, true, context);
        break;
      case 'categories':
        if (Dashboard.dashboardScreenKey.currentState != null) {
          Dashboard.dashboardScreenKey.currentState!.changeTabPosition(1);
        }
        break;
      case 'wallet':
        Routes.navigateToMyWalletScreen(context);
        break;
      case 'order':
      case 'place_order':
        Routes.navigateToMyOrderScreen(context);
        break;
      case 'ticket_message':
        Routes.navigateToChatScreen(context, id, '');
        break;

      case 'ticket_status':
        Routes.navigateToCustomerSupportScreen(context);
        break;
      case 'notification_url':
        try {
          if (await canLaunchUrl(Uri.parse(urlLink))) {
            await launchUrl(Uri.parse(urlLink),
                mode: LaunchMode.externalApplication);
          } else {
            throw 'Could not launch $urlLink';
          }
        } catch (e) {
          throw 'Something went wrong';
        }
        break;
      default:
        Routes.navigateToSplashScreen(context);
    }
  }

  void handleIncomingMessage(RemoteMessage message) {
    UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: false);
    
    var data = message.notification!;
    var title = data.title?.toString() ?? '';
    var body = data.body?.toString() ?? '';
    var image = message.data['image'] ?? '';
    var type = message.data['type'] ?? '';
    var id = message.data['type_id'] ?? '';
    var urlLink = message.data['link'] ?? '';



    if (type == 'chat') {
      /*
              [{"id":"267","from_id":"2","to_id":"8","is_read":"1","message":"Geralt of rivia","type":"person","media":"","date_created":"2023-07-19 13:15:26","picture":"dikshita","senders_name":"dikshita","position":"right","media_files":"","text":"Geralt of rivia"}]
          */

      final messages = jsonDecode(message.data['message']) as List;

      String payload = '';
      if (messages.isNotEmpty) {
        payload = jsonEncode(messages.first);
      }

      if (converstationScreenStateKey.currentState?.mounted ?? false) {
        final state = converstationScreenStateKey.currentState!;
        if (state.widget.isGroup) {
          if (messages.isNotEmpty) {
            if (state.widget.groupDetails?.groupId != messages.first['to_id']) {
              // context
              //     .read<GroupConverstationsCubit>()
              //     .markNewMessageArrivedInGroup(
              //         groupId: messages.first['to_id'].toString());
              // generateChatLocalNotification(
              //     title: title, body: body, payload: payload);
            } else {
              state.addMessage(
                  message: msg.Message.fromJson(Map.from(messages.first)));
            }
          }
        } else {
          if (messages.isNotEmpty) {
            //
            if (state.widget.personalChatHistory?.getOtherUserId() !=
                messages.first['from_id']) {
              generateChatLocalNotification(
                  title: title, body: body, payload: payload);

              context
                  .read<PersonalConverstationsCubit>()
                  .updateUnreadMessageCounter(
                    userId: messages.first['from_id'].toString(),
                  );
            } else {
              state.addMessage(
                  message: msg.Message.fromJson(Map.from(messages.first)));
            }
          }
        }
      } else {
        //senders_name
        generateChatLocalNotification(
            title: title, body: body, payload: payload);

        //Update the unread message counter
        if (messages.isNotEmpty) {
          if (messages.first['type'] == 'person') {
            context
                .read<PersonalConverstationsCubit>()
                .updateUnreadMessageCounter(
                  userId: messages.first['from_id'].toString(),
                );
          } else {}
        }
      }
    } else if (type == 'ticket_status') {
      generateSimpleNotification(title, body, type, id, urlLink);
      // Routes.navigateToCustomerSupportScreen(context);
    } else if (type == 'ticket_message') {
      generateSimpleNotification(title, body, type, id, urlLink);
      if (CUR_TICK_ID == id &&
          context.read<ChatProvider>().chatstreamdata != null) {
        var parsedJson = json.decode(message.data['chat']);
        parsedJson = parsedJson[0];
        Map<String, dynamic> sendata = {
          'id': parsedJson[ID],
          'title': parsedJson[TITLE],
          'message': parsedJson[MESSAGE],
          'user_id': parsedJson[USER_ID],
          'name': parsedJson[NAME],
          'date_created': parsedJson[DATE_CREATED],
          'attachments': parsedJson['attachments']
        };
        var chat = {'data': sendata};
        if (parsedJson[USER_ID] != userProvider.userId) {
          context
              .read<ChatProvider>()
              .chatstreamdata!
              .sink
              .add(jsonEncode(chat));
        }
      }
    } else if (image != null && image != 'null' && image != '') {
      generateImageNotification(title, body, image, type, id, urlLink);
    } else {
      generateSimpleNotification(title, body, type, id, urlLink);
    }
  }

  Future<void> generateImageNotification(String title, String msg, String image,
      String type, String id, String url) async {
    var largeIconPath = await _downloadAndSaveImage(image, 'largeIcon');
    var bigPicturePath = await _downloadAndSaveImage(image, 'bigPicture');
    var bigPictureStyleInformation = BigPictureStyleInformation(
      FilePathAndroidBitmap(bigPicturePath),
      hideExpandedLargeIcon: true,
      contentTitle: title,
      htmlFormatContentTitle: true,
      summaryText: msg,
      htmlFormatSummaryText: true,
    );
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'big text channel id',
      'big text channel name',
      channelDescription: 'big text channel description',
      largeIcon: FilePathAndroidBitmap(largeIconPath),
      styleInformation: bigPictureStyleInformation,
      playSound: true,
    );
     var iosDetail = const DarwinNotificationDetails();
      var platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iosDetail,
    );
   
    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      msg,
      platformChannelSpecifics,
      payload: '$type,$id,$url',
    );
  }

  Future<void> generateSimpleNotification(
      String title, String msg, String type, String id, String url) async {
    var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
      'your channel id',
      'your channel name',
      channelDescription: 'your channel description',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
      playSound: true,
    );
    var iosDetail = const DarwinNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iosDetail,
    );
    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      msg,
      platformChannelSpecifics,
      payload: '$type,$id,$url',
    );
  }

  void generateChatLocalNotification(
      {required String title,
      required String body,
      required String payload}) async {
    var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
      'your channel id',
      'your channel name',
      channelDescription: 'your channel description',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
      playSound: true,
    );
    var iosDetail = const DarwinNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iosDetail,
    );
    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
      payload: 'chat,$payload',
    );
  }

  Future<String> _downloadAndSaveImage(String url, String fileName) async {
    var directory = await getApplicationDocumentsDirectory();
    var filePath = '${directory.path}/$fileName';
    var response = await http.get(Uri.parse(url));
    var file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);
    return filePath;
  }
}

@pragma('vm:entry-point')
Future<void> myBackgroundMessageHandler(RemoteMessage message) async {
  setPrefrenceBool(ISFROMBACK, true);
  if (message.data['type'].toString() == 'chat') {
    final messages = jsonDecode(message.data['message']) as List;
    NotificationRepository.addChatNotification(
        message: jsonEncode(messages.first));
  }
}
