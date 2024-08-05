import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:eshop_multivendor/Helper/ApiBaseHelper.dart';
import 'package:eshop_multivendor/Screen/converstationListScreen.dart';
import 'package:eshop_multivendor/Screen/converstationScreen.dart';
import 'package:external_path/external_path.dart';
import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

//Your application name
const String appName = 'DsiStars';

//please add your panel's API base URL here (you can find from settings->client APIs)
const String baseUrl = 'https://admin.dsistars.com/app/v1/api/';
const String chatBaseUrl = 'https://admin.dsistars.com/app/v1/Chat_Api/';

//for codecanyon demo app only, don't change it
const bool isDemoApp = false;

//Your package name
const String packageName = 'eShop.multivendor.customer';
const String iosPackage = 'wrteam.eshop.multivendor';

//Playstore link of your application
const String androidLink = 'https://play.google.com/store/apps/details?id=';

//Appstore link of your application
const String iosLink = 'your ios link here';

//Appstore id
const String appStoreId = '123456789';

//Link for share product (get From Firebase)
const String deepLinkUrlPrefix = 'https://eshopmultivendorwrteam.page.link';
const String deepLinkName = 'eshop.com';

const double allowableTotalFileSizesInChatMediaInMB = 15.0;

//Set labguage
String defaultLanguage = 'en';

//Set country code
String defaultCountryCode = 'IN';

//Time settings
const int timeOut = 50;
const int perPage = 10;

//FontSize
const double textFontSize7 = 7;
const double textFontSize8 = 8;
const double textFontSize9 = 9;
const double textFontSize10 = 10;
const double textFontSize11 = 11;
const double textFontSize12 = 12;
const double textFontSize13 = 13;
const double textFontSize14 = 14;
const double textFontSize15 = 15;
const double textFontSize16 = 16;
const double textFontSize18 = 18;
const double textFontSize20 = 20;
const double textFontSize23 = 23;
const double textFontSize30 = 30;
//Radius
const double circularBorderRadius1 = 1;
const double circularBorderRadius3 = 3;
const double circularBorderRadius4 = 4;
const double circularBorderRadius5 = 5;
const double circularBorderRadius7 = 7;
const double circularBorderRadius8 = 8;
const double circularBorderRadius10 = 10;
const double circularBorderRadius20 = 20;
const double circularBorderRadius25 = 25;
const double circularBorderRadius30 = 30;
const double circularBorderRadius40 = 40;
const double circularBorderRadius50 = 50;
const double circularBorderRadius100 = 100;

//General Error Message
const String errorMesaage = 'Something went wrong, Error : ';

//Bank detail hint text
const String bankDetail =
    'Bank Details:\nAccount No :123XXXXX\nIFSC Code: 123XXX \nName: Abc Bank';

//Api class instance
ApiBaseHelper apiBaseHelper = ApiBaseHelper();

///Below declared variables and functions are useful for chat feature
///Chat Features utility
///

const String messagesLoadLimit = '30';

GlobalKey<ConverstationScreenState> converstationScreenStateKey =
    GlobalKey<ConverstationScreenState>();

GlobalKey<ConverstationListScreenState> converstationListScreenStateKey =
    GlobalKey<ConverstationListScreenState>();

bool isSameDay(
    {required DateTime dateTime,
    required bool takeCurrentDate,
    DateTime? givenDate}) {
  final dateToCompare = takeCurrentDate ? DateTime.now() : givenDate!;
  return (dateToCompare.day == dateTime.day) &&
      (dateToCompare.month == dateTime.month) &&
      (dateToCompare.year == dateTime.year);
}

String formatDateYYMMDD({required DateTime dateTime}) {
  return "${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}";
}

String formatDate(DateTime dateTime) {
  return "${dateTime.day.toString().padLeft(2, '0')}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.year}";
}

//Key to store all queue notifications of chat messages in shared pref.
const String queueNotificationOfChatMessagesSharedPrefKey =
    'queueNotificationOfChatMessages';

Future<bool> hasStoragePermissionGiven() async {
  if (Platform.isIOS) {
    bool permissionGiven = await Permission.storage.isGranted;
    if (!permissionGiven) {
      permissionGiven = (await Permission.storage.request()).isGranted;
      return permissionGiven;
    }
    return permissionGiven;
  }
  final deviceInfoPlugin = DeviceInfoPlugin();
  final androidDeviceInfo = await deviceInfoPlugin.androidInfo;
  if (androidDeviceInfo.version.sdkInt < 33) {
    bool permissionGiven = await Permission.storage.isGranted;
    if (!permissionGiven) {
      permissionGiven = (await Permission.storage.request()).isGranted;
      return permissionGiven;
    }
    return permissionGiven;
  } else {
    bool permissionGiven = await Permission.photos.isGranted;
    if (!permissionGiven) {
      permissionGiven = (await Permission.photos.request()).isGranted;
      return permissionGiven;
    }
    return permissionGiven;
  }
}

Future<String> getExternalStoragePath() async {
  return Platform.isAndroid
      ? (await ExternalPath.getExternalStoragePublicDirectory(
          ExternalPath.DIRECTORY_DOWNLOADS))
      : (await getApplicationDocumentsDirectory()).path;
}

Future<String> getTempStoragePath() async {
  return (await getTemporaryDirectory()).path;
}

Future<String> checkIfFileAlreadyDownloaded(
    {required String fileName,
    required String fileExtension,
    required bool downloadedInExternalStorage}) async {
  final filePath = downloadedInExternalStorage
      ? await getExternalStoragePath()
      : await getTempStoragePath();
  final File file = File('$filePath/$fileName.$fileExtension');

  return (await file.exists()) ? file.path : '';
}

///
///End of chat features utility
///
