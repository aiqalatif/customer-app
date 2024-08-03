import 'dart:async';
import 'package:eshop_multivendor/Provider/Theme.dart';
import 'package:eshop_multivendor/Screen/PrivacyPolicy/Privacy_Policy.dart';
import 'package:eshop_multivendor/Screen/Auth/Verify_Otp.dart';
import 'package:eshop_multivendor/widgets/applogo.dart';
import 'package:eshop_multivendor/widgets/systemChromeSettings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl_phone_field/country_picker_dialog.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:provider/provider.dart';
import '../../Helper/Color.dart';
import '../../Helper/Constant.dart';
import '../../Helper/String.dart';
import '../../Provider/authenticationProvider.dart';
import '../../widgets/ButtonDesing.dart';
import '../../widgets/snackbar.dart';
import '../../widgets/validation.dart';
import '../Language/languageSettings.dart';
import '../../widgets/networkAvailablity.dart';
import '../NoInterNetWidget/NoInterNet.dart';

// ignore: must_be_immutable
class SendOtp extends StatefulWidget {
  String? title;
  String? mobileNo;

  SendOtp({Key? key, this.title, this.mobileNo}) : super(key: key);

  @override
  _SendOtpState createState() => _SendOtpState();
}

class _SendOtpState extends State<SendOtp> with TickerProviderStateMixin {
  bool visible = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final mobileController = TextEditingController();
  //final ccodeController = TextEditingController();
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  String? mobile, id, countrycode, countryName, mobileno;
  Animation? buttonSqueezeanimation;
  AnimationController? buttonController;
  bool acceptTnC = false;

  void validateAndSubmit() async {
    if (validateAndSave()) {
      _playAnimation();
      checkNetwork();
    }
  }

  Future<void> _playAnimation() async {
    try {
      await buttonController!.forward();
      // ignore: empty_catches
    } on TickerCanceled {}
  }

  Future<void> checkNetwork() async {
    isNetworkAvail = await isNetworkAvailable();
    if (isNetworkAvail) {
      Future.delayed(Duration.zero).then(
        (value) => context
            .read<AuthenticationProvider>()
            .getVerifyUser(mobileController.text,
                isForgotPassword:
                    widget.title == getTranslated(context, 'FORGOT_PASS_TITLE'))
            .then(
          (
            value,
          ) async {
            bool? error = value['error'];
            String? msg = value['message'];
            await buttonController!.reverse();

            if (widget.title == getTranslated(context, 'SEND_OTP_TITLE')) {
              if (!error!) {
                setSnackbar(msg!, context);
                Future.delayed(const Duration(seconds: 1)).then(
                  (_) {
                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (context) => VerifyOtp(
                          mobileNumber: mobileController.text,
                          countryCode: countrycode,
                          title: getTranslated(context, 'SEND_OTP_TITLE'),
                        ),
                      ),
                    );
                  },
                );
              } else {
                setSnackbar(msg!, context);
              }
            }
            if (widget.title == getTranslated(context, 'FORGOT_PASS_TITLE')) {
              if (!error!) {
                // settingsProvider.setPrefrence(MOBILE, mobileController.text);
                // settingsProvider.setPrefrence(COUNTRY_CODE, countrycode!);
                Future.delayed(const Duration(seconds: 1)).then(
                  (_) {
                    Navigator.pushReplacement(
                      context,
                      CupertinoPageRoute(
                        builder: (context) => VerifyOtp(
                          mobileNumber: mobileController.text,
                          countryCode: countrycode,
                          title: getTranslated(context, 'FORGOT_PASS_TITLE'),
                        ),
                      ),
                    );
                  },
                );
              } else {
                setSnackbar(getTranslated(context, 'FIRSTSIGNUP_MSG'), context);
              }
            }
          },
        ),
      );
    } else {
      Future.delayed(const Duration(seconds: 2)).then(
        (_) async {
          if (mounted) {
            setState(
              () {
                isNetworkAvail = false;
              },
            );
          }
          await buttonController!.reverse();
        },
      );
    }
  }

  bool validateAndSave() {
    final form = _formkey.currentState!;
    form.save();
    if (mobileController.text.toString().trim().isEmpty) {
      setSnackbar(getTranslated(context, 'MOB_REQUIRED'), context);
      return false;
    } else if (form.validate()) {
      return true;
    }
    return false;
  }

  @override
  void dispose() {
    buttonController!.dispose();
    super.dispose();
  }

  setStateNoInternate() async {
    _playAnimation();

    Future.delayed(const Duration(seconds: 2)).then(
      (_) async {
        isNetworkAvail = await isNetworkAvailable();
        if (isNetworkAvail) {
          Navigator.pushReplacement(
            context,
            CupertinoPageRoute(builder: (BuildContext context) => super.widget),
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

  Widget verifyCodeTxt() {
    return Padding(
      padding: const EdgeInsets.only(top: 13.0),
      child: Text(
        getTranslated(context, 'SEND_VERIFY_CODE_LBL'),
        style: Theme.of(context).textTheme.titleSmall!.copyWith(
              color: Theme.of(context).colorScheme.fontColor.withOpacity(0.4),
              fontWeight: FontWeight.bold,
              fontFamily: 'ubuntu',
            ),
        overflow: TextOverflow.ellipsis,
        softWrap: true,
        maxLines: 3,
      ),
    );
  }

  setCodeWithMono() {
    return Padding(
        padding: const EdgeInsets.only(top: 45),
        child: IntlPhoneField(
          style: Theme.of(context).textTheme.titleSmall!.copyWith(
              color: Theme.of(context).colorScheme.fontColor,
              fontWeight: FontWeight.normal),
          controller: mobileController,
          readOnly: widget.mobileNo == null ? false : true,
          autofocus: widget.mobileNo == null ? true : false,
          enabled: true,
          decoration: InputDecoration(
            hintStyle: Theme.of(context).textTheme.titleSmall!.copyWith(
                color: Theme.of(context).colorScheme.fontColor,
                fontWeight: FontWeight.normal),
            hintText: getTranslated(context, 'MOBILEHINT_LBL'),
            border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(circularBorderRadius7)),
            fillColor: Theme.of(context).colorScheme.lightWhite,
            filled: true,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
          ),
          validator: (phoneNumber) {
            return StringValidation.validateMobIntl(
                phoneNumber,
                getTranslated(context, 'MOB_REQUIRED'),
                getTranslated(context, 'VALID_MOB'));
          },
          initialCountryCode: defaultCountryCode,
          onSaved: (phoneNumber) {
            setState(() {
              countrycode =
                  phoneNumber!.countryCode.toString().replaceFirst('+', '');

              mobile = phoneNumber.number;
            });
          },
          onCountryChanged: (country) {
            setState(() {
              countrycode = country.dialCode;
            });
          },
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          autovalidateMode: AutovalidateMode.onUserInteraction,
          disableLengthCheck: true,
          showDropdownIcon: false,
          keyboardType: TextInputType.number,
          flagsButtonMargin: const EdgeInsets.only(left: 20, right: 20),
          pickerDialogStyle: PickerDialogStyle(
              padding: const EdgeInsets.only(left: 10, right: 10),
              countryNameStyle: Theme.of(context)
                  .textTheme
                  .titleMedium!
                  .copyWith(
                      color: Theme.of(context).colorScheme.fontColor,
                      fontWeight: FontWeight.normal)),
        ));
  }

  bool isValidPhoneNumber(String phoneNumber) {
    if (phoneNumber.length != 10) {
      return false;
    }

    return int.tryParse(phoneNumber) != null;
  }

/*  Widget setCodeWithMono() {
    return Padding(
      padding: const EdgeInsets.only(top: 45),
      child: Container(
        height: 53,
        width: double.maxFinite,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.lightWhite,
          borderRadius: BorderRadius.circular(circularBorderRadius10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Expanded(
              flex: 2,
              child: setCountryCode(),
            ),
            Expanded(
              flex: 4,
              child: setMono(),
            )
          ],
        ),
      ),
    );
  }

  Widget setCountryCode() {
    double width = deviceWidth!;
    double height = deviceHeight! * 0.9;
    return CountryCodePicker(
      showCountryOnly: false,
      searchStyle: TextStyle(
        color: Theme.of(context).colorScheme.fontColor,
      ),
      flagWidth: 20,
      boxDecoration: BoxDecoration(
        color: Theme.of(context).colorScheme.white,
      ),
      searchDecoration: InputDecoration(
        hintText: getTranslated(context, 'COUNTRY_CODE_LBL'),
        hintStyle: TextStyle(color: Theme.of(context).colorScheme.fontColor),
        fillColor: Theme.of(context).colorScheme.fontColor,
      ),
      showOnlyCountryWhenClosed: false,
      initialSelection: defaultCountryCode,
      dialogSize: Size(width, height),
      alignLeft: true,
      textStyle: TextStyle(
          color: Theme.of(context).colorScheme.fontColor,
          fontWeight: FontWeight.bold),
      onChanged: (CountryCode countryCode) {
        countrycode = countryCode.toString().replaceFirst('+', '');
        countryName = countryCode.name;
      },
      onInit: (code) {
        countrycode = code.toString().replaceFirst('+', '');
      },
    );
  }*/

/*  Widget setMono() {
    return TextFormField(
      keyboardType: TextInputType.number,
      controller: mobileController,
      style: Theme.of(context).textTheme.titleSmall!.copyWith(
          color: Theme.of(context).colorScheme.fontColor,
          fontWeight: FontWeight.normal),
      maxLength: 15,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      validator: (val) => StringValidation.validateMob(
          val!,
          getTranslated(context, 'MOB_REQUIRED'),
          getTranslated(context, 'VALID_MOB')),
      onSaved: (String? value) {
        context.read<AuthenticationProvider>().setMobileNumber(value);
        mobile = value;
      },
      decoration: InputDecoration(
        counter: SizedBox(),
        hintText: getTranslated(context, 'MOBILEHINT_LBL'),
        hintStyle: Theme.of(context).textTheme.titleSmall!.copyWith(
            color: Theme.of(context).colorScheme.fontColor,
            fontWeight: FontWeight.normal),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        focusedBorder: UnderlineInputBorder(
          borderSide: const BorderSide(color: colors.primary),
          borderRadius: BorderRadius.circular(circularBorderRadius7),
        ),
        border: InputBorder.none,
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.lightWhite,
          ),
        ),
      ),
    );
  }*/

  Widget verifyBtn() {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: Center(
        child: AppBtn(
          title: widget.title == getTranslated(context, 'SEND_OTP_TITLE')
              ? getTranslated(context, 'SEND_OTP')
              : getTranslated(context, 'CONTINUE'),
          btnAnim: buttonSqueezeanimation,
          btnCntrl: buttonController,
          onBtnSelected: () async {
            FocusScope.of(context).unfocus();
            if (widget.title == getTranslated(context, 'FORGOT_PASS_TITLE') ||
                acceptTnC) {
              validateAndSubmit();
            } else {
              setSnackbar(getTranslated(context, 'agreeTCFirst'), context);
            }
          },
        ),
      ),
    );
  }

  Widget termAndPolicyTxt() {
    if (widget.title != getTranslated(context, 'FORGOT_PASS_TITLE')) {
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
      return SizedBox.shrink();
    }
  }

  /*  Widget termAndPolicyTxt() {
    return widget.title == getTranslated(context, 'SEND_OTP_TITLE')
        ? SizedBox(
            height: deviceHeight! * 0.18,
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  getTranslated(context, 'CONTINUE_AGREE_LBL')!,
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        color: Theme.of(context).colorScheme.fontColor,
                        fontWeight: FontWeight.normal,
                        fontFamily: 'ubuntu',
                      ),
                ),
                const SizedBox(
                  height: 3.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (context) => PrivacyPolicy(
                              title: getTranslated(context, 'TERM'),
                            ),
                          ),
                        );
                      },
                      child: Text(
                        getTranslated(context, 'TERMS_SERVICE_LBL')!,
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                              color: Theme.of(context).colorScheme.fontColor,
                              decoration: TextDecoration.underline,
                              fontWeight: FontWeight.normal,
                              fontFamily: 'ubuntu',
                            ),
                        overflow: TextOverflow.clip,
                        softWrap: true,
                        maxLines: 1,
                      ),
                    ),
                    const SizedBox(
                      width: 5.0,
                    ),
                    Text(
                      getTranslated(context, 'AND_LBL')!,
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            color: Theme.of(context).colorScheme.fontColor,
                            fontWeight: FontWeight.normal,
                            fontFamily: 'ubuntu',
                          ),
                    ),
                    const SizedBox(
                      width: 5.0,
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (context) => PrivacyPolicy(
                              title: getTranslated(context, 'PRIVACY'),
                            ),
                          ),
                        );
                      },
                      child: Text(
                        getTranslated(context, 'PRIVACY')!,
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                              color: Theme.of(context).colorScheme.fontColor,
                              decoration: TextDecoration.underline,
                              fontWeight: FontWeight.normal,
                              fontFamily: 'ubuntu',
                            ),
                        overflow: TextOverflow.clip,
                        softWrap: true,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )
        : const SizedBox();
  }
 */
  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      SystemChromeSettings.setSystemChromes(
          isDarkTheme: Provider.of<ThemeNotifier>(context, listen: false)
                  .getThemeMode() ==
              ThemeMode.dark);
    });
    if (widget.mobileNo != null) {
      setState(() {
        mobileController.text = widget.mobileNo!;
        mobile = widget.mobileNo!;
      });
    }

    super.initState();
    buttonController = AnimationController(
        duration: const Duration(milliseconds: 2000), vsync: this);

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

  @override
  Widget build(BuildContext context) {
    deviceHeight = MediaQuery.of(context).size.height;
    deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      key: _scaffoldKey,
      backgroundColor: Theme.of(context).colorScheme.white,
      //bottomNavigationBar: termAndPolicyTxt(),
      body: isNetworkAvail
          ? Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  top: 23,
                  left: 23,
                  right: 23,
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Form(
                  key: _formkey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      getLogo(),
                      signUpTxt(),
                      verifyCodeTxt(),
                      setCodeWithMono(),
                      verifyBtn(),
                      termAndPolicyTxt()
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

  Widget getLogo() {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.only(top: 60),
      child: const AppLogo(),
    );
  }

  Widget signUpTxt() {
    return Padding(
      padding: const EdgeInsetsDirectional.only(
        top: 40.0,
      ),
      child: Text(
        widget.title == getTranslated(context, 'SEND_OTP_TITLE')
            ? getTranslated(context, 'SIGN_UP_LBL')
            : getTranslated(context, 'FORGOT_PASSWORDTITILE'),
        style: Theme.of(context).textTheme.titleLarge!.copyWith(
              color: Theme.of(context).colorScheme.fontColor,
              fontWeight: FontWeight.bold,
              fontSize: textFontSize23,
              fontFamily: 'ubuntu',
              letterSpacing: 0.8,
            ),
      ),
    );
  }
}
