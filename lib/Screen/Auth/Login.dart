import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:eshop_multivendor/Provider/CartProvider.dart';
import 'package:eshop_multivendor/Provider/Favourite/FavoriteProvider.dart';
import 'package:eshop_multivendor/Provider/SettingProvider.dart';
import 'package:eshop_multivendor/Provider/Theme.dart';
import 'package:eshop_multivendor/Provider/UserProvider.dart';
import 'package:eshop_multivendor/Provider/homePageProvider.dart';
import 'package:eshop_multivendor/Screen/Auth/SendOtp.dart';
import 'package:eshop_multivendor/cubits/appSettingsCubit.dart';
import 'package:eshop_multivendor/widgets/applogo.dart';
import 'package:eshop_multivendor/widgets/systemChromeSettings.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import '../../Helper/Color.dart';
import '../../Helper/Constant.dart';
import '../../Helper/String.dart';
import '../../Helper/routes.dart';
import '../../Provider/authenticationProvider.dart';
import '../../Provider/productDetailProvider.dart';
import '../../widgets/ButtonDesing.dart';
import '../../widgets/desing.dart';
import '../../widgets/snackbar.dart';
import '../Language/languageSettings.dart';
import '../../widgets/networkAvailablity.dart';
import '../../widgets/security.dart';
import '../../widgets/validation.dart';
import '../Dashboard/Dashboard.dart';
import '../NoInterNetWidget/NoInterNet.dart';
import '../PrivacyPolicy/Privacy_Policy.dart';
import '../PushNotification/PushNotificationService.dart';

class Login extends StatefulWidget {
  final Widget? classType;
  final bool isPop;
  final bool? isRefresh;

  const Login({Key? key, this.classType, required this.isPop, this.isRefresh})
      : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<Login> with TickerProviderStateMixin {
  bool acceptTnC = false;
  bool socialLoginLoading = false;
  AnimationController? buttonController;
  Animation? buttonSqueezeanimation;
  String? countryName;
  bool isShowPass = true;
  final mobileController =
      TextEditingController(text: isDemoApp ? '1212121212' : null);
  FocusNode? passFocus, monoFocus = FocusNode();
  final passwordController =
      TextEditingController(text: isDemoApp ? '12345678' : null);

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void dispose() {
    buttonController!.dispose();
    super.dispose();
  }

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      SystemChromeSettings.setSystemChromes(
          isDarkTheme: Provider.of<ThemeNotifier>(context, listen: false)
                  .getThemeMode() ==
              ThemeMode.dark);
    });

    super.initState();
    buttonController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    buttonSqueezeanimation = Tween(
      begin: deviceWidth! * 0.7,
      end: 50.0,
    ).animate(
      CurvedAnimation(
        parent: buttonController!,
        curve: const Interval(
          0.0,
          0.150,
        ),
      ),
    );
  }

  void validateAndSubmit() async {
    if (validateAndSave()) {
      _playAnimation();
      checkNetwork();
    }
  }

  saveAndNavigate(var getdata, String token) async {
    SettingProvider settingProvider =
        Provider.of<SettingProvider>(context, listen: false);
    settingProvider.saveUserDetail(
      getdata[ID],
      getdata[USERNAME],
      getdata[EMAIL],
      getdata[MOBILE],
      getdata[CITY],
      getdata[AREA],
      getdata[ADDRESS],
      getdata[PINCODE],
      getdata[LATITUDE],
      getdata[LONGITUDE],
      getdata[IMAGE],
      getdata[TYPE],
      getdata[REFERCODE],
      token,
      context,
    );
    Future.delayed(Duration.zero, () {
      PushNotificationService(context: context).setDeviceToken(
          clearSessionToken: true, settingProvider: settingProvider);
    });

    offFavAdd().then(
      (value) async {
        db.clearFav();
        context.read<FavoriteProvider>().setFavlist([]);
        List cartOffList = await db.getOffCart();
        if (singleSellerOrderSystem && cartOffList.isNotEmpty) {
          forLoginPageSingleSellerSystem = true;
          offSaveAdd().then(
            (value) {
              clearYouCartDialog();
            },
          );
        } else {
          offCartAdd().then(
            (value) {
              db.clearCart();
              offSaveAdd().then(
                (value) {
                  db.clearSaveForLater();
                  if (widget.isPop) {
                    if (widget.isRefresh != null) {
                      Navigator.pop(context, 'refresh');
                    } else {
                      context.read<HomePageProvider>().getFav(context);
                      context
                          .read<CartProvider>()
                          .getUserCart(save: '0', context: context);

                      Future.delayed(const Duration(seconds: 2))
                          .whenComplete(() {
                        Navigator.of(context).pop();
                      });
                    }
                  } else {
                    Dashboard.dashboardScreenKey = GlobalKey();
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) =>
                                widget.classType ??
                                Dashboard(
                                  key: Dashboard.dashboardScreenKey,
                                )),
                        (route) => false);
                  }
                },
              );
            },
          );
        }
      },
    );
  }

  Future<void> checkNetwork() async {
    isNetworkAvail = await isNetworkAvailable();
    if (isNetworkAvail) {
      Future.delayed(Duration.zero).then(
        (value) => context.read<AuthenticationProvider>().getLoginData().then(
          (
            value,
          ) async {
            bool error = value['error'];
            String? errorMessage = value['message'];
            await buttonController!.reverse();
            if (!error) {
              setSnackbar(errorMessage!, context);
              var getdata = value['data'][0];
              saveAndNavigate(getdata, value[TOKEN]);
            } else {
              setSnackbar(errorMessage!, context);
            }
          },
        ),
      );
    } else {
      Future.delayed(const Duration(seconds: 2)).then(
        (_) async {
          await buttonController!.reverse();
          if (mounted) {
            setState(
              () {
                isNetworkAvail = false;
              },
            );
          }
        },
      );
    }
  }

  clearYouCartDialog() async {
    await DesignConfiguration.dialogAnimate(
      context,
      StatefulBuilder(
        builder: (BuildContext context, StateSetter setStater) {
          return PopScope(
            canPop: false,
            child: AlertDialog(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(
                    circularBorderRadius5,
                  ),
                ),
              ),
              title: Text(
                getTranslated(context,
                    'Your cart already has an items of another seller would you like to remove it ?'),
                softWrap: true,
                overflow: TextOverflow.ellipsis,
                maxLines: 3,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.fontColor,
                  fontWeight: FontWeight.normal,
                  fontSize: textFontSize16,
                  fontFamily: 'ubuntu',
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: SvgPicture.asset(
                        DesignConfiguration.setSvgPath('appbarCart'),
                        colorFilter: const ColorFilter.mode(
                            colors.primary, BlendMode.srcIn),
                        height: 50,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        child: Text(
                          getTranslated(context, 'CANCEL'),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.lightBlack,
                            fontSize: textFontSize15,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'ubuntu',
                          ),
                        ),
                        onPressed: () {
                          Routes.pop(context);
                          db.clearSaveForLater();
                          Navigator.pushNamedAndRemoveUntil(
                              context, '/home', (r) => false);
                        },
                      ),
                      TextButton(
                        child: Text(
                          getTranslated(context, 'Clear Cart'),
                          style: const TextStyle(
                            color: colors.primary,
                            fontSize: textFontSize15,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'ubuntu',
                          ),
                        ),
                        onPressed: () {
                          if (context.read<UserProvider>().userId != '') {
                            context.read<UserProvider>().setCartCount('0');
                            context
                                .read<ProductDetailProvider>()
                                .clearCartNow(context)
                                .then(
                              (value) async {
                                if (context
                                        .read<ProductDetailProvider>()
                                        .error ==
                                    false) {
                                  if (context
                                          .read<ProductDetailProvider>()
                                          .snackbarmessage ==
                                      'Data deleted successfully') {
                                  } else {
                                    setSnackbar(
                                        context
                                            .read<ProductDetailProvider>()
                                            .snackbarmessage,
                                        context);
                                  }
                                } else {
                                  setSnackbar(
                                      context
                                          .read<ProductDetailProvider>()
                                          .snackbarmessage,
                                      context);
                                }
                                Routes.pop(context);
                                await offCartAdd();
                                db.clearSaveForLater();
                                Dashboard.dashboardScreenKey = GlobalKey();
                                Navigator.pushNamedAndRemoveUntil(
                                  context,
                                  '/home',
                                  (r) => false,
                                );
                              },
                            );
                          } else {
                            Routes.pop(context);
                            db.clearSaveForLater();
                            Dashboard.dashboardScreenKey = GlobalKey();
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              '/home',
                              (r) => false,
                            );
                          }
                        },
                      )
                    ],
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  skipSignInBtn() {
    return Container(
      alignment: AlignmentDirectional.topEnd,
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.lightWhite,
            borderRadius: const BorderRadius.all(
              Radius.circular(circularBorderRadius10),
            ),
          ),
          child: Text(
            getTranslated(context, 'SKIP_SIGNIN_LBL'),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleSmall!.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'ubuntu',
                ),
          ),
        ),
        onPressed: () {
          Dashboard.dashboardScreenKey = GlobalKey();
          Navigator.pushNamedAndRemoveUntil(context, '/home', (r) => false);
        },
      ),
    );
  }

  bool validateAndSave() {
    final form = _formkey.currentState!;
    form.save();
    if (form.validate()) {
      return true;
    }
    return false;
  }

  setStateNoInternate() async {
    _playAnimation();

    Future.delayed(const Duration(seconds: 2)).then(
      (_) async {
        isNetworkAvail = await isNetworkAvailable();
        if (isNetworkAvail) {
          Navigator.pushReplacement(
            context,
            CupertinoPageRoute(
              builder: (BuildContext context) => super.widget,
            ),
          );
        } else {
          await buttonController!.reverse();
          if (mounted) {
            setState(
              () {},
            );
          }
        }
      },
    );
  }

  Future<void> offFavAdd() async {
    List favOffList = await db.getOffFav();
    if (favOffList.isNotEmpty) {
      for (int i = 0; i < favOffList.length; i++) {
        _setFav(favOffList[i]['PID']);
      }
    }
  }

  Future<void> offCartAdd() async {
    List cartOffList = await db.getOffCart();
    if (cartOffList.isNotEmpty) {
      for (int i = 0; i < cartOffList.length; i++) {
        addToCartCheckout(cartOffList[i]['VID'], cartOffList[i]['QTY']);
      }
    }
  }

  Future<void> addToCartCheckout(String varId, String qty) async {
    isNetworkAvail = await isNetworkAvailable();
    if (isNetworkAvail) {
      try {
        var parameter = {
          PRODUCT_VARIENT_ID: varId,
          // USER_ID: context.read<UserProvider>().userId,
          QTY: qty,
        };

        Response response =
            await post(manageCartApi, body: parameter, headers: headers)
                .timeout(const Duration(seconds: timeOut));
        if (response.statusCode == 200) {
          var getdata = json.decode(response.body);
          if (getdata['message'] == 'One of the product is out of stock.') {
            homePageSingleSellerMessage = true;
          }
        }
      } on TimeoutException catch (_) {
        setSnackbar(getTranslated(context, 'somethingMSg'), context);
      }
    } else {
      if (mounted) isNetworkAvail = false;

      setState(() {});
    }
  }

  Future<void> offSaveAdd() async {
    List saveOffList = await db.getOffSaveLater();

    if (saveOffList.isNotEmpty) {
      for (int i = 0; i < saveOffList.length; i++) {
        saveForLater(saveOffList[i]['VID'], saveOffList[i]['QTY']);
      }
    }
  }

  saveForLater(String vid, String qty) async {
    isNetworkAvail = await isNetworkAvailable();
    if (isNetworkAvail) {
      try {
        var parameter = {
          PRODUCT_VARIENT_ID: vid,
          // USER_ID: context.read<UserProvider>().userId,
          QTY: qty,
          SAVE_LATER: '1'
        };
        Response response =
            await post(manageCartApi, body: parameter, headers: headers)
                .timeout(const Duration(seconds: timeOut));
        var getdata = json.decode(response.body);
        bool error = getdata['error'];
        String? msg = getdata['message'];
        if (!error) {
        } else {
          setSnackbar(msg!, context);
        }
      } on TimeoutException catch (_) {
        setSnackbar(getTranslated(context, 'somethingMSg'), context);
      }
    } else {
      if (mounted) {
        setState(
          () {
            isNetworkAvail = false;
          },
        );
      }
    }
  }

  signInTxt() {
    return Padding(
      padding: const EdgeInsetsDirectional.only(
        top: 40.0,
      ),
      child: Text(
        "${getTranslated(context, 'WELCOME')} $appName",
        style: Theme.of(context).textTheme.titleLarge!.copyWith(
              color: Theme.of(context).colorScheme.fontColor,
              fontWeight: FontWeight.bold,
              fontSize: textFontSize20,
              letterSpacing: 0.8,
              fontFamily: 'ubuntu',
            ),
      ),
    );
  }

  signInSubTxt() {
    return Padding(
      padding: const EdgeInsetsDirectional.only(
        top: 13.0,
      ),
      child: Text(
        getTranslated(context, 'INFO_FOR_LOGIN'),
        style: Theme.of(context).textTheme.titleSmall!.copyWith(
              color: Theme.of(context).colorScheme.fontColor.withOpacity(0.38),
              fontWeight: FontWeight.bold,
              fontFamily: 'ubuntu',
            ),
      ),
    );
  }

  setMobileNo() {
    return Padding(
      padding: const EdgeInsets.only(top: 40),
      child: TextFormField(
        onFieldSubmitted: (v) {
          FocusScope.of(context).requestFocus(passFocus);
        },
        style: TextStyle(
            color: Theme.of(context).colorScheme.fontColor.withOpacity(0.7),
            fontWeight: FontWeight.bold,
            fontSize: textFontSize13),
        keyboardType: TextInputType.number,
        controller: mobileController,
        focusNode: monoFocus,
        textInputAction: TextInputAction.next,
        maxLength: 15,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          counter: const SizedBox(),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 13,
            vertical: 5,
          ),
          hintText: getTranslated(
            context,
            'MOBILEHINT_LBL',
          ),
          hintStyle: TextStyle(
              color: Theme.of(context).colorScheme.fontColor.withOpacity(0.3),
              fontWeight: FontWeight.bold,
              fontSize: textFontSize13),
          fillColor: Theme.of(context).colorScheme.lightWhite,
          filled: true,
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(circularBorderRadius10),
          ),
        ),
        validator: (val) => StringValidation.validateMob(
            val!,
            getTranslated(context, 'MOB_REQUIRED'),
            getTranslated(context, 'VALID_MOB')),
        onSaved: (String? value) {
          context.read<AuthenticationProvider>().setMobileNumber(value);
        },
      ),
    );
  }

  setPass() {
    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: TextFormField(
        style: TextStyle(
            color: Theme.of(context).colorScheme.fontColor.withOpacity(0.7),
            fontWeight: FontWeight.bold,
            fontSize: textFontSize13),
        onFieldSubmitted: (v) {
          passFocus!.unfocus();
        },
        keyboardType: TextInputType.text,
        obscureText: isShowPass,
        controller: passwordController,
        focusNode: passFocus,
        textInputAction: TextInputAction.next,
        inputFormatters: [
          FilteringTextInputFormatter.deny(RegExp('[ ]')),
        ],
        validator: (val) => StringValidation.validatePass(
            val!,
            getTranslated(context, 'PWD_REQUIRED'),
            getTranslated(context, 'PASSWORD_VALIDATION'),
            onlyRequired: true),
        onSaved: (String? value) {
          context.read<AuthenticationProvider>().setPassword(value);
        },
        decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 13,
              vertical: 5,
            ),
            suffixIcon: InkWell(
              onTap: () {
                setState(
                  () {
                    isShowPass = !isShowPass;
                  },
                );
              },
              child: Padding(
                padding: const EdgeInsetsDirectional.only(end: 10.0),
                child: Icon(
                  !isShowPass ? Icons.visibility : Icons.visibility_off,
                  color:
                      Theme.of(context).colorScheme.fontColor.withOpacity(0.4),
                  size: 22,
                ),
              ),
            ),
            suffixIconConstraints:
                const BoxConstraints(minWidth: 40, maxHeight: 20),
            hintText: getTranslated(context, 'PASSHINT_LBL'),
            hintStyle: TextStyle(
                color: Theme.of(context).colorScheme.fontColor.withOpacity(0.3),
                fontWeight: FontWeight.bold,
                fontSize: textFontSize13),
            fillColor: Theme.of(context).colorScheme.lightWhite,
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(circularBorderRadius10),
            ),
            filled: true,
            errorMaxLines: 4),
      ),
    );
  }

  forgetPass() {
    return Padding(
      padding: const EdgeInsetsDirectional.only(top: 30.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (context) => SendOtp(
                    title: getTranslated(context, 'FORGOT_PASS_TITLE'),
                  ),
                ),
              );
            },
            child: Text(
              getTranslated(context, 'FORGOT_PASSWORD_LBL'),
              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: textFontSize13,
                    fontFamily: 'ubuntu',
                  ),
            ),
          ),
        ],
      ),
    );
  }

  signInUser({
    required String type,
  }) async {
    try {
      final result = await context
          .read<AuthenticationProvider>()
          .socialSignInUser(type: type, context: context);
      final user = result['user'] as User;

      Map<String, dynamic> userDataTest = await context
          .read<AuthenticationProvider>()
          .loginAuth(
              mobile: user.providerData[0].phoneNumber ?? '',
              email: user.providerData[0].email ?? '',
              firebaseId: user.providerData[0].uid ?? '',
              name: user.providerData[0].displayName ??
                  (type == APPLE_TYPE ? 'Apple User' : ''),
              type: type);

      bool error = userDataTest['error'];
      String? msg = userDataTest['message'];

      setState(() {
        socialLoginLoading = false;
      });
      if (!error) {
        setSnackbar(msg!, context);

        var userdata = userDataTest['data'];
        saveAndNavigate(userdata, userDataTest[TOKEN]);
      } else {
        setSnackbar(msg!, context);
      }
    } catch (e) {
      setState(() {
        socialLoginLoading = false;
      });
      signOut(type);
      setSnackbar(e.toString(), context);
    }
  }

  Future<void> signOut(String type) async {
    _firebaseAuth.signOut();
    if (type == GOOGLE_TYPE) {
      _googleSignIn.signOut();
    } else {
      _firebaseAuth.signOut();
    }
  }

  Widget orDivider() {
    if (context.read<AppSettingsCubit>().isGoogleLoginOn() ||
        (Platform.isIOS &&
            context.read<AppSettingsCubit>().isAppleLoginAllowed())) {
      return Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Row(
          children: [
            Flexible(
              child: Divider(
                indent: 30,
                endIndent: 15,
                color: Theme.of(context).colorScheme.fontColor.withOpacity(0.6),
              ),
            ),
            Text(
              getTranslated(context, 'OR_LOGIN_WITH_LBL'),
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  color:
                      Theme.of(context).colorScheme.fontColor.withOpacity(0.8)),
            ),
            Flexible(
                child: Divider(
              indent: 15,
              endIndent: 30,
              color: Theme.of(context).colorScheme.fontColor.withOpacity(0.6),
            )),
          ],
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget termAndPolicyTxt() {
    if (context.read<AppSettingsCubit>().isGoogleLoginOn() ||
        (Platform.isIOS &&
            context.read<AppSettingsCubit>().isAppleLoginAllowed())) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 0.0, left: 25.0, right: 25.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Checkbox(
                    activeColor: colors.primary,
                    value: acceptTnC,
                    onChanged: (newValue) {
                      setState(() => acceptTnC = newValue!);
                    }),
                Expanded(
                    child: RichText(
                  text: TextSpan(
                    text: getTranslated(context, 'CONTINUE_AGREE_LBL'),
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        color: Theme.of(context).colorScheme.fontColor,
                        fontWeight: FontWeight.normal),
                    children: [
                      TextSpan(
                        text:
                            "\n${getTranslated(context, 'TERMS_SERVICE_LBL')}",
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            color: Theme.of(context).colorScheme.fontColor,
                            decoration: TextDecoration.underline,
                            fontWeight: FontWeight.normal),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.push(
                                context,
                                CupertinoPageRoute(
                                    builder: (context) => PrivacyPolicy(
                                          title: getTranslated(context, 'TERM'),
                                        )));
                          },
                      ),
                      TextSpan(
                        text: "  ${getTranslated(context, 'AND_LBL')}  ",
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            color: Theme.of(context).colorScheme.fontColor,
                            fontWeight: FontWeight.normal),
                      ),
                      TextSpan(
                          text: getTranslated(context, 'PRIVACY'),
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall!
                              .copyWith(
                                  color:
                                      Theme.of(context).colorScheme.fontColor,
                                  decoration: TextDecoration.underline,
                                  fontWeight: FontWeight.normal),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.push(
                                  context,
                                  CupertinoPageRoute(
                                      builder: (context) => PrivacyPolicy(
                                            title: getTranslated(
                                                context, 'PRIVACY'),
                                          )));
                            }),
                    ],
                  ),
                )),
              ],
            ),
          ],
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget socialLoginBtn() {
    return Padding(
        padding: const EdgeInsets.only(top: 40, bottom: 30),
        child: Center(
          child: Column(
            //crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (context.read<AppSettingsCubit>().isGoogleLoginOn())
                InkWell(
                  child: Container(
                    height: 45,
                    alignment: Alignment.center,
                    width: deviceWidth! * 0.7,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: colors
                              .primary), /* color: Theme.of(context).colorScheme.lightWhite*/
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          DesignConfiguration.setSvgPath('google_button'),
                          height: 22,
                          width: 22,
                        ),
                        Padding(
                          padding: const EdgeInsetsDirectional.only(start: 15),
                          child: Text(
                              getTranslated(context, 'CONTINUE_WITH_GOOGLE'),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium!
                                  .copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .fontColor,
                                      fontWeight: FontWeight.normal)),
                        )
                      ],
                    ),
                  ),
                  onTap: () async {
                    if (acceptTnC) {
                      isNetworkAvail = await isNetworkAvailable();
                      if (isNetworkAvail) {
                        setState(() {
                          socialLoginLoading = true;
                        });
                        signInUser(type: GOOGLE_TYPE);
                      } else {
                        Future.delayed(const Duration(seconds: 2))
                            .then((_) async {
                          await buttonController!.reverse();
                          if (mounted) {
                            setState(() {
                              isNetworkAvail = false;
                            });
                          }
                        });
                      }
                    } else {
                      setSnackbar(
                          getTranslated(context, 'agreeTCFirst'), context);
                    }
                  },
                ),
              if (Platform.isIOS &&
                  context.read<AppSettingsCubit>().isAppleLoginAllowed())
                Padding(
                  padding: const EdgeInsets.only(top: 25),
                  child: InkWell(
                    child: Container(
                      height: 45,
                      alignment: Alignment.center,
                      width: deviceWidth! * 0.7,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: colors.primary)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            DesignConfiguration.setSvgPath('apple_logo'),
                            height: 22,
                            width: 22,
                          ),
                          Padding(
                            padding:
                                const EdgeInsetsDirectional.only(start: 15),
                            child: Text(
                                getTranslated(context, 'CONTINUE_WITH_APPLE'),
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium!
                                    .copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .fontColor,
                                        fontWeight: FontWeight.normal)),
                          )
                        ],
                      ),
                    ),
                    onTap: () async {
                      if (acceptTnC) {
                        isNetworkAvail = await isNetworkAvailable();
                        if (isNetworkAvail) {
                          setState(() {
                            socialLoginLoading = true;
                          });
                          signInUser(type: APPLE_TYPE);
                        } else {
                          Future.delayed(const Duration(seconds: 2))
                              .then((_) async {
                            await buttonController!.reverse();
                            if (mounted) {
                              setState(() {
                                isNetworkAvail = false;
                              });
                            }
                          });
                        }
                      } else {
                        setSnackbar(
                            getTranslated(context, 'agreeTCFirst'), context);
                      }
                    },
                  ),
                )
            ],
          ),
        ));
  }

  setDontHaveAcc() {
    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            getTranslated(context, 'DONT_HAVE_AN_ACC'),
            style: Theme.of(context).textTheme.titleSmall!.copyWith(
                  color: Theme.of(context).colorScheme.fontColor,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'ubuntu',
                ),
          ),
          InkWell(
            onTap: () {
              Navigator.of(context).push(
                CupertinoPageRoute(
                  builder: (BuildContext context) => SendOtp(
                    title: getTranslated(context, 'SEND_OTP_TITLE'),
                  ),
                ),
              );
            },
            child: Text(
              getTranslated(context, 'SIGN_UP_LBL'),
              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'ubuntu',
                  ),
            ),
          )
        ],
      ),
    );
  }

  loginBtn() {
    return Center(
      child: Consumer<AuthenticationProvider>(
        builder: (context, value, child) {
          return AppBtn(
            title: getTranslated(context, 'SIGNIN_LBL'),
            btnAnim: buttonSqueezeanimation,
            btnCntrl: buttonController,
            onBtnSelected: () async {
              FocusScope.of(context).unfocus();
              if (passFocus != null) {
                passFocus!.unfocus();
              }
              if (monoFocus != null) {
                monoFocus!.unfocus();
              }
              validateAndSubmit();
            },
          );
        },
      ),
    );
  }

  Widget getLogo() {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.only(top: 10),
      child: const AppLogo(),
    );
  }

  Future<void> _playAnimation() async {
    try {
      await buttonController!.forward();
    } on TickerCanceled {}
  }

  _setFav(String pid) async {
    isNetworkAvail = await isNetworkAvailable();
    if (isNetworkAvail) {
      try {
        var parameter = {
          // USER_ID: context.read<UserProvider>().userId,
          PRODUCT_ID: pid
        };
        Response response =
            await post(setFavoriteApi, body: parameter, headers: headers)
                .timeout(const Duration(seconds: timeOut));

        var getdata = json.decode(response.body);

        bool error = getdata['error'];
        String? msg = getdata['message'];
        if (!error) {
          setSnackbar(msg!, context);
        } else {
          setSnackbar(msg!, context);
        }
      } on TimeoutException catch (_) {
        setSnackbar(getTranslated(context, 'somethingMSg'), context);
      }
    } else {
      if (mounted) {
        setState(
          () {
            isNetworkAvail = false;
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Theme.of(context).colorScheme.white,
      key: _scaffoldKey,
      body: isNetworkAvail
          ? SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  left: 23,
                  right: 23,
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Form(
                  key: _formkey,
                  child: Stack(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          skipSignInBtn(),
                          getLogo(),
                          signInTxt(),
                          signInSubTxt(),
                          setMobileNo(),
                          setPass(),
                          forgetPass(),
                          loginBtn(),
                          setDontHaveAcc(),
                          orDivider(),
                          socialLoginBtn(),
                          termAndPolicyTxt(),
                          const SizedBox(
                            height: 40,
                          ),
                        ],
                      ),
                      if (socialLoginLoading)
                        Positioned.fill(
                          child: Center(
                              child: DesignConfiguration.showCircularProgress(
                                  socialLoginLoading, colors.primary)),
                        ),
                    ],
                  ),
                ),
              ),
            )
          : NoInterNet(
              setStateNoInternate: setStateNoInternate,
              buttonSqueezeanimation: buttonSqueezeanimation,
              buttonController: buttonController,
            ),
    );
  }
}
