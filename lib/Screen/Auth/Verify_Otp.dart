import 'dart:async';
import 'package:eshop_multivendor/Helper/ApiBaseHelper.dart';
import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:eshop_multivendor/Screen/Auth/Set_Password.dart';
import 'package:eshop_multivendor/Screen/Auth/SignUp.dart';
import 'package:eshop_multivendor/cubits/appSettingsCubit.dart';
import 'package:eshop_multivendor/repository/authRepository.dart';
import 'package:eshop_multivendor/widgets/applogo.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sms_autofill/sms_autofill.dart';
import '../../Helper/Constant.dart';
import '../../Helper/String.dart';
import '../../widgets/ButtonDesing.dart';
import '../../widgets/snackbar.dart';
import '../Language/languageSettings.dart';
import '../../widgets/networkAvailablity.dart';

class VerifyOtp extends StatefulWidget {
  const VerifyOtp(
      {Key? key,
      required String this.mobileNumber,
      this.countryCode,
      this.title})
      : super(key: key);

  final String? mobileNumber, countryCode, title;

  @override
  _MobileOTPState createState() => _MobileOTPState();
}

class _MobileOTPState extends State<VerifyOtp> with TickerProviderStateMixin {
  AnimationController? buttonController;
  Animation? buttonSqueezeanimation;
  final dataKey = GlobalKey();
  bool isCodeSent = false;
  bool isSMSGatewayOn = false;
  String? otp;
  String? password;
  String signature = '';

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  bool resendClickable = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _verificationId = ''; // Initialize with an empty string

  @override
  void dispose() {
    buttonController!.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    getSingature();
    Future.delayed(Duration.zero, () {
      isSMSGatewayOn = context.read<AppSettingsCubit>().isSMSGatewayActive();
      if (!isSMSGatewayOn) {
        _onVerifyCode();
      } else {
        isCodeSent = true;
      }
    });

    Future.delayed(const Duration(seconds: 60)).then(
      (_) {
        resendClickable = true;
      },
    );
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

  Future<void> getSingature() async {
    signature = await SmsAutoFill().getAppSignature;
    SmsAutoFill().listenForCode;
  }

  Future<void> resendOtp() async {
    isNetworkAvail = await isNetworkAvailable();
    if (isNetworkAvail) {
      if (resendClickable) {
        resendClickable = false;
        if (isSMSGatewayOn) {
          bool didResend = false;
          try {
            await AuthRepository.resendOtp(
                mobileNumber: widget.mobileNumber ?? '');
            didResend = true;
          } on ApiException catch (e) {
            setSnackbar(e.toString(), context);
          }
          if (didResend) {
            setSnackbar(getTranslated(context, 'OTP_RESENT'), context);
            Future.delayed(const Duration(seconds: 60)).then(
              (_) {
                resendClickable = true;
              },
            );
          } else {
            resendClickable = true;
          }
        } else {
          _onVerifyCode();
        }
      } else {
        setSnackbar(getTranslated(context, 'OTPWR'), context);
      }
    } else {
      if (mounted) setState(() {});
      if (!isSMSGatewayOn) {
        Future.delayed(const Duration(seconds: 60)).then(
          (_) async {
            isNetworkAvail = await isNetworkAvailable();
            if (isNetworkAvail) {
              if (resendClickable) {
                _onVerifyCode();
              } else {
                setSnackbar(getTranslated(context, 'OTPWR'), context);
              }
            } else {
              await buttonController!.reverse();
              setSnackbar(getTranslated(context, 'somethingMSg'), context);
            }
          },
        );
      }
    }
  }

  Widget verifyBtn() {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Center(
        child: AppBtn(
          title: getTranslated(context, 'VERIFY_AND_PROCEED'),
          btnAnim: buttonSqueezeanimation,
          btnCntrl: buttonController,
          onBtnSelected: () async {
            FocusScope.of(context).unfocus();
            _onFormSubmitted();
          },
        ),
      ),
    );
  }

  monoVarifyText() {
    return Padding(
      padding: const EdgeInsetsDirectional.only(
        top: 60.0,
      ),
      child: Text(
        getTranslated(context, 'MOBILE_NUMBER_VARIFICATION'),
        style: Theme.of(context).textTheme.titleLarge!.copyWith(
              color: Theme.of(context).colorScheme.fontColor,
              fontWeight: FontWeight.bold,
              fontSize: textFontSize23,
              letterSpacing: 0.8,
              fontFamily: 'ubuntu',
            ),
      ),
    );
  }

  otpText() {
    return Padding(
      padding: const EdgeInsetsDirectional.only(
        top: 13.0,
      ),
      child: Text(
        getTranslated(context, 'SENT_VERIFY_CODE_TO_NO_LBL'),
        style: Theme.of(context).textTheme.titleSmall!.copyWith(
              color: Theme.of(context).colorScheme.fontColor.withOpacity(0.5),
              fontWeight: FontWeight.bold,
              fontFamily: 'ubuntu',
            ),
      ),
    );
  }

  mobText() {
    return Padding(
      padding: const EdgeInsetsDirectional.only(top: 5.0),
      child: Text(
        '+${widget.countryCode}-${widget.mobileNumber}',
        style: Theme.of(context).textTheme.titleSmall!.copyWith(
              color: Theme.of(context).colorScheme.fontColor.withOpacity(0.5),
              fontWeight: FontWeight.bold,
              fontFamily: 'ubuntu',
            ),
      ),
    );
  }

  Widget otpLayout() {
    return Padding(
      padding: const EdgeInsetsDirectional.only(top: 30),
      child: PinFieldAutoFill(
        decoration: BoxLooseDecoration(
            textStyle: TextStyle(
                fontSize: textFontSize20,
                color: Theme.of(context).colorScheme.fontColor),
            radius: const Radius.circular(circularBorderRadius4),
            gapSpace: 15,
            bgColorBuilder: FixedColorBuilder(
                Theme.of(context).colorScheme.lightWhite.withOpacity(0.4)),
            strokeColorBuilder: FixedColorBuilder(
                Theme.of(context).colorScheme.fontColor.withOpacity(0.2))),
        currentCode: otp,
        codeLength: 6,
        onCodeChanged: (String? code) {
          otp = code;
        },
        onCodeSubmitted: (String code) {
          otp = code;
        },
      ),
    );
  }

  Widget resendText() {
    return Padding(
      padding: const EdgeInsetsDirectional.only(top: 30.0),
      child: Row(
        children: [
          Text(
            getTranslated(context, 'DIDNT_GET_THE_CODE'),
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  color:
                      Theme.of(context).colorScheme.fontColor.withOpacity(0.5),
                  fontWeight: FontWeight.bold,
                  fontFamily: 'ubuntu',
                ),
          ),
          InkWell(
            onTap: () async {
              await buttonController!.reverse();
              resendOtp();
            },
            child: Text(
              getTranslated(context, 'RESEND_OTP'),
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
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

  Widget getLogo() {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.only(top: 60),
      child: const AppLogo(),
    );
  }

  void _onVerifyCode() async {
    if (mounted) {
      setState(
        () {
          isCodeSent = true;
        },
      );
    }
    PhoneVerificationCompleted verificationCompleted() {
      return (AuthCredential phoneAuthCredential) {
        _firebaseAuth.signInWithCredential(phoneAuthCredential).then(
          (UserCredential value) {
            if (value.user != null) {
              /*  SettingProvider settingsProvider =
                  Provider.of<SettingProvider>(context, listen: false);
               */
              setSnackbar(getTranslated(context, 'OTPMSG'), context);
              /*  settingsProvider.setPrefrence(MOBILE, widget.mobileNumber!);
              settingsProvider.setPrefrence(COUNTRY_CODE, widget.countryCode!); */
              if (widget.title == getTranslated(context, 'SEND_OTP_TITLE')) {
                Future.delayed(const Duration(seconds: 2)).then((_) {
                  Navigator.pushReplacement(
                      context,
                      CupertinoPageRoute(
                          builder: (context) => SignUp(
                                mobileNumber: widget.mobileNumber!,
                                countryCode: widget.countryCode!,
                              )));
                });
              } else if (widget.title ==
                  getTranslated(context, 'FORGOT_PASS_TITLE')) {
                Future.delayed(const Duration(seconds: 2)).then(
                  (_) {
                    Navigator.pushReplacement(
                      context,
                      CupertinoPageRoute(
                        builder: (context) => SetPass(
                          mobileNumber: widget.mobileNumber!,
                        ),
                      ),
                    );
                  },
                );
              }
            } else {
              setSnackbar(getTranslated(context, 'OTPERROR'), context);
            }
          },
        ).catchError(
          (error) {
            setSnackbar(error.toString(), context);
          },
        );
      };
    }

    PhoneVerificationFailed verificationFailed() {
      return (FirebaseAuthException authException) {
        if (mounted) {
          setState(
            () {
              isCodeSent = false;
            },
          );
        }
      };
    }

    PhoneCodeSent codeSent() {
      return (String verificationId, [int? forceResendingToken]) async {
        // _verificationId = verificationId;

        setState(
          () {
            _verificationId = verificationId; // Assign the value here
          },
        );
      };
    }

    PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout() {
      return (String verificationId) {
        // _verificationId = verificationId;

        setState(
          () {
            resendClickable = true;
            _verificationId = verificationId; // Assign the value here
          },
        );
      };
    }

    await _firebaseAuth.verifyPhoneNumber(
      phoneNumber: '+${widget.countryCode}${widget.mobileNumber}',
      timeout: const Duration(seconds: 60),
      verificationCompleted: verificationCompleted(),
      verificationFailed: verificationFailed(),
      codeSent: codeSent(),
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout(),
    );
  }

  void _onFormSubmitted() async {
    String code = otp!.trim();
    if (code.length == 6) {
      _playAnimation();
      try {
        bool wasOtpVerified = false;

        if (isSMSGatewayOn) {
          try {
            await AuthRepository.verifyOtp(
                mobileNumber: widget.mobileNumber ?? '', otp: code);
            wasOtpVerified = true;
          } on ApiException catch (e) {
            setSnackbar(e.toString(), context);
            await buttonController!.reverse();
            return;
          }
        } else {
          AuthCredential authCredential = PhoneAuthProvider.credential(
              verificationId: _verificationId, smsCode: code);
          UserCredential value =
              await _firebaseAuth.signInWithCredential(authCredential);
          wasOtpVerified = value.user != null;
        }

        if (wasOtpVerified) {
          /*    SettingProvider settingsProvider =
              Provider.of<SettingProvider>(context, listen: false); */

          await buttonController!.reverse();
          setSnackbar(getTranslated(context, 'OTPMSG'), context);
          // settingsProvider.setPrefrence(MOBILE, widget.mobileNumber!);
          // settingsProvider.setPrefrence(COUNTRY_CODE, widget.countryCode!);
          if (widget.title == getTranslated(context, 'SEND_OTP_TITLE')) {
            Future.delayed(const Duration(seconds: 2)).then((_) {
              Navigator.pushReplacement(
                  context,
                  CupertinoPageRoute(
                      builder: (context) => SignUp(
                            mobileNumber: widget.mobileNumber!,
                            countryCode: widget.countryCode!,
                          )));
            });
          } else if (widget.title ==
              getTranslated(context, 'FORGOT_PASS_TITLE')) {
            Future.delayed(const Duration(seconds: 2)).then(
              (_) {
                Navigator.pushReplacement(
                  context,
                  CupertinoPageRoute(
                    builder: (context) => SetPass(
                      mobileNumber: widget.mobileNumber!,
                    ),
                  ),
                );
              },
            );
          }
        } else {
          setSnackbar(getTranslated(context, 'OTPERROR'), context);
          await buttonController!.reverse();
        }
      } catch (_) {
        setSnackbar(getTranslated(context, 'WRONGOTP'), context);

        await buttonController!.reverse();
      }
    } else {
      setSnackbar(getTranslated(context, 'ENTEROTP'), context);
    }
  }

  Future<void> _playAnimation() async {
    try {
      await buttonController!.forward();
    } on TickerCanceled {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      key: _scaffoldKey,
      backgroundColor: Theme.of(context).colorScheme.white,
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
              top: 23,
              left: 23,
              right: 23,
              bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              getLogo(),
              monoVarifyText(),
              otpText(),
              mobText(),
              otpLayout(),
              resendText(),
              verifyBtn(),
            ],
          ),
        ),
      ),
    );
  }
}
