import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../Helper/ApiBaseHelper.dart';
import '../Helper/String.dart';
import '../Screen/Language/languageSettings.dart';
import '../repository/authRepository.dart';
import '../widgets/snackbar.dart';

class AuthenticationProvider extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  // value for parameter
  String? mobilennumberPara, passwordPara;

  // singup data
  String? name, countrycode, referCode, friendCode, sinUpPassword, singUPemail;
  // for reset password
  String? newPassword;

  // data
  bool? error;
  String errorMessage = '';
  String? password,
      mobile,
      username,
      email,
      id,
      mobileno,
      city,
      area,
      pincode,
      address,
      latitude,
      longitude,
      image,
      loginType;

  final _chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  final Random _rnd = Random();
  int count = 1;
  get mobilenumbervalue => mobilennumberPara;
  setMobileNumber(String? value) {
    mobilennumberPara = value;
    notifyListeners();
  }

  setNewPassword(String? value) {
    newPassword = value;
    notifyListeners();
  }

  setSingUp(String? value) {
    singUPemail = value;
    notifyListeners();
  }

  setfriendCode(String? value) {
    friendCode = value;
    notifyListeners();
  }

  setsinUpPassword(String? value) {
    sinUpPassword = value;
    notifyListeners();
  }

  setcountrycode(String? value) {
    countrycode = value;
    notifyListeners();
  }

  setUserName(String? value) {
    name = value;
    notifyListeners();
  }

  setLoginType(String? value) {
    loginType = value;
    notifyListeners();
  }

  setreferCode(String? value) {
    referCode = value;
    notifyListeners();
  }

  setPassword(String? value) {
    passwordPara = value;
    notifyListeners();
  }

  Future<Map<String, dynamic>> loginAuth(
      {required String firebaseId,
      required String name,
      required String email,
      required String type,
      required String mobile}) async {
    try {
      final body = {
        NAME: name,
        TYPE: type,
      };

      if (mobile != '') {
        body[MOBILE] = mobile;
      }

      if (email != '') {
        body[EMAIL] = email;
      }
      if (firebaseId != '') {
        body[FCM_ID] = firebaseId;
      }

      var getData = AuthRepository.fetchSocialLoginData(parameter: body);

      return getData;
    } catch (e) {
      print('auth error');
      throw ApiException(e.toString());
    }
  }

  Future<Map<String, dynamic>> socialSignInUser(
      {required String type, required BuildContext context}) async {
    Map<String, dynamic> result = {};

    try {
      if (type == GOOGLE_TYPE) {
        UserCredential? userCredential = await signInWithGoogle(context);
        if (userCredential != null) {
          result['user'] = userCredential.user!;
        } else {
          throw ApiException(getTranslated(context, 'somethingMSg'));
        }
      } else if (type == APPLE_TYPE) {
        UserCredential? userCredential = await signInWithApple(context);
        if (userCredential != null) {
          result['user'] = userCredential.user!;
        } else {
          throw ApiException(getTranslated(context, 'somethingMSg'));
        }
      }

      return result;
    } on SocketException catch (_) {
      throw ApiException(getTranslated(context, 'somethingMSg'));
    } on FirebaseAuthException catch (e) {
      throw ApiException(e.toString());
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<UserCredential?> signInWithGoogle(BuildContext context) async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      setSnackbar(getTranslated(context, 'somethingMSg'), context);

      return null;
    }
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final UserCredential userCredential =
        await _firebaseAuth.signInWithCredential(credential);
    return userCredential;
  }

  String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<UserCredential?> signInWithApple(BuildContext context) async {
    try {
      final rawNonce = generateNonce();
      final nonce = sha256ofString(rawNonce);

      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        rawNonce: rawNonce,
      );

      final UserCredential authResult =
          await FirebaseAuth.instance.signInWithCredential(oauthCredential);

      return authResult;
    } on FirebaseAuthException catch (authError) {
      setSnackbar(authError.message!, context);

      return null;
    } on FirebaseException catch (e) {
      setSnackbar(e.toString(), context);

      return null;
    } catch (e) {
      String errorMessage = e.toString();

      if (errorMessage == 'Null check operator used on a null value') {
        //if user goes back from selecting Account
        //in case of User gmail not selected & back to Login screen
        setSnackbar(getTranslated(context, 'CANCEL_USER_MSG'), context);

        return null;
      } else {
        setSnackbar(errorMessage, context);

        return null;
      }
    }
  }

  //get System Policies
  Future<Map<String, dynamic>> getLoginData() async {
    try {
      var parameter = {MOBILE: mobilennumberPara, PASSWORD: passwordPara};
      var result = await AuthRepository.fetchLoginData(parameter: parameter);

      errorMessage = result['message'];
      error = result['error'];
      if (!error!) {
        var getdata = result['data'][0];
        id = getdata[ID];
        username = getdata[USERNAME];
        email = getdata[EMAIL];
        mobile = getdata[MOBILE];
        city = getdata[CITY];
        area = getdata[AREA];
        address = getdata[ADDRESS];
        pincode = getdata[PINCODE];
        latitude = getdata[LATITUDE];
        longitude = getdata[LONGITUDE];
        image = getdata[IMAGE];
        loginType = getdata[TYPE];

        return result;
      } else {
        return result;
      }
    } catch (e) {
      errorMessage = e.toString();
      return {};
    }
  }

  //for login
  Future<Map<String, dynamic>> getVerifyUser(String mobile,
      {required bool isForgotPassword}) async {
    try {
      var parameter = {
        MOBILE: mobile.replaceAll(' ', ''),
        'is_forgot_password': isForgotPassword ? '1' : '0',
      };
      var result =
          await AuthRepository.fetchverificationData(parameter: parameter);

      return result;
    } catch (e) {
      errorMessage = e.toString();
      return {};
    }
  }

  //for singUp
  Future<Map<String, dynamic>> getSingUPData() async {
    try {
      var parameter = {
        MOBILE: mobilennumberPara!.replaceAll(' ', ''),
        NAME: name,
        EMAIL: singUPemail,
        PASSWORD: sinUpPassword,
        COUNTRY_CODE: countrycode,
        REFERCODE: referCode,
        FRNDCODE: friendCode
      };

      var result = await AuthRepository.fetchSingUpData(parameter: parameter);
      return result;
    } catch (e) {
      errorMessage = e.toString();
      return {};
    }
  }

  // for reset password
  Future<Map<String, dynamic>> getReset(String mobile) async {
    try {
      var parameter = {
        MOBILENO: mobile,
        NEWPASS: newPassword,
      };

      var result = await AuthRepository.fetchFetchReset(parameter: parameter);
      return result;
    } catch (e) {
      errorMessage = e.toString();
      return {};
    }
  }

  Future<void> generateReferral(
    BuildContext context,
  ) async {
    String refer = getRandomString(8);
    context.read<AuthenticationProvider>().setreferCode(refer);

    try {
      var data = {
        REFERCODE: refer,
      };
      var result = await AuthRepository.validateReferal(parameter: data);

      bool error = result['error'];

      if (!error) {
        referCode = refer;
        context.read<AuthenticationProvider>().setreferCode(refer);
      } else {
        if (count < 5) {
          generateReferral(context);
        }
        count++;
      }
    } on TimeoutException catch (_) {}
  }

  String getRandomString(int length) => String.fromCharCodes(
        Iterable.generate(
          length,
          (_) => _chars.codeUnitAt(
            _rnd.nextInt(
              _chars.length,
            ),
          ),
        ),
      );
}
