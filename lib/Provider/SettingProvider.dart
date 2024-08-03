import 'package:eshop_multivendor/Provider/UserProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Helper/String.dart';

class SettingProvider {
  late SharedPreferences _sharedPreferences;

  SettingProvider(SharedPreferences sharedPreferences) {
    _sharedPreferences = sharedPreferences;
  }

  String get email => _sharedPreferences.getString(EMAIL) ?? '';

  String? get userId => _sharedPreferences.getString(ID);

  String get userName => _sharedPreferences.getString(USERNAME) ?? '';

  String get mobile => _sharedPreferences.getString(MOBILE) ?? '';

  String get profileUrl => _sharedPreferences.getString(IMAGE) ?? '';
  String get loginType => _sharedPreferences.getString(TYPE) ?? '';

  String? get token => _sharedPreferences.getString(TOKEN);

  setPrefrence(String key, String value) {
    _sharedPreferences.setString(key, value);
  }

  getSessionValue(String key) async {
    return _sharedPreferences.getString(key);
  }

  Future<String?> getPrefrence(String key) async {
    return _sharedPreferences.getString(key);
  }

  void setPrefrenceBool(String key, bool value) async {
    _sharedPreferences.setBool(key, value);
  }

  setPrefrenceList(String key, String query) async {
    List<String> valueList = await getPrefrenceList(key);
    if (!valueList.contains(query)) {
      if (valueList.length > 4) valueList.removeAt(0);
      valueList.add(query);

      _sharedPreferences.setStringList(key, valueList);
    }
  }

  removeValuePrefrenceList(String key, String query) async {
    List<String> valueList = await getPrefrenceList(key);

    valueList.removeWhere((item) => item == query);

    _sharedPreferences.setStringList(key, valueList);
  }

  Future<List<String>> getPrefrenceList(String key) async {
    return _sharedPreferences.getStringList(key) ?? [];
  }

  Future<bool> getPrefrenceBool(String key) async {
    return _sharedPreferences.getBool(key) ?? false;
  }

  Future<void> clearUserSession(BuildContext context) async {
    String? getTheme = await getPrefrence(APP_THEME);
    String? getLanguage = await getPrefrence(LAGUAGE_CODE);

    UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: false);

    context.read<UserProvider>().setPincode('');
    userProvider.setUserId('');
    userProvider.setName('');
    userProvider.setBalance('');
    userProvider.setCartCount('');
    userProvider.setProfilePic('');
    userProvider.setMobile('');
    userProvider.setEmail('');
    userProvider.setLoginType('');
    userProvider.setReferCode('');
    await _sharedPreferences.clear();
    setPrefrenceBool(ISFIRSTTIME, true);
    setPrefrence(APP_THEME, getTheme!);
    setPrefrence(LAGUAGE_CODE, getLanguage!);
  }

  Future<void> setCurrentSellerID(String value) async {
    setPrefrence('CurrentSellerID', value);
  }

  Future<String?> getCurrentSellerID(String value) async {
    return _sharedPreferences.getString('CurrentSellerID');
  }

  Future<void> saveUserDetail(
      String userId,
      String? name,
      String? email,
      String? mobile,
      String? city,
      String? area,
      String? address,
      String? pincode,
      String? latitude,
      String? longitude,
      String? image,
      String? type,
      String? referCode,
      String? token,
      BuildContext context) async {
    final waitList = <Future<void>>[];
    waitList.add(_sharedPreferences.setString(ID, userId));
    waitList.add(_sharedPreferences.setString(USERNAME, name ?? ''));
    waitList.add(_sharedPreferences.setString(EMAIL, email ?? ''));
    waitList.add(_sharedPreferences.setString(MOBILE, mobile ?? ''));
    waitList.add(_sharedPreferences.setString(CITY, city ?? ''));
    waitList.add(_sharedPreferences.setString(AREA, area ?? ''));
    waitList.add(_sharedPreferences.setString(ADDRESS, address ?? ''));
    waitList.add(_sharedPreferences.setString(PINCODE, pincode ?? ''));
    waitList.add(_sharedPreferences.setString(LATITUDE, latitude ?? ''));
    waitList.add(_sharedPreferences.setString(LONGITUDE, longitude ?? ''));
    waitList.add(_sharedPreferences.setString(IMAGE, image ?? ''));
    waitList.add(_sharedPreferences.setString(TYPE, type ?? ''));
    waitList.add(_sharedPreferences.setString(REFERCODE, referCode ?? ''));
    if (token != null) {
      waitList.add(_sharedPreferences.setString(TOKEN, token));
    }

    UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: false);

    userProvider.setUserId(userId);
    userProvider.setName(name ?? '');
    userProvider.setBalance('');
    userProvider.setCartCount('');
    userProvider.setProfilePic(image ?? '');
    userProvider.setMobile(mobile ?? '');
    userProvider.setEmail(email ?? '');
    userProvider.setLoginType(type ?? '');
    userProvider.setReferCode(referCode ?? '');
    await Future.wait(waitList);
  }
}

setPrefrenceBool(String key, bool value) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setBool(key, value);
}
