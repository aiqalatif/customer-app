import 'dart:async';
import 'package:eshop_multivendor/widgets/applogo.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../Helper/Color.dart';
import '../../Helper/Constant.dart';
import '../../Helper/String.dart';
import '../../Helper/routes.dart';
import '../../Provider/authenticationProvider.dart';
import '../../widgets/ButtonDesing.dart';
import '../../widgets/snackbar.dart';
import '../Language/languageSettings.dart';
import '../../widgets/networkAvailablity.dart';
import '../../widgets/validation.dart';
import '../NoInterNetWidget/NoInterNet.dart';
import 'Login.dart';

class SetPass extends StatefulWidget {
  final String mobileNumber;

  const SetPass({
    Key? key,
    required this.mobileNumber,
  }) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

bool isShowPass = true;
bool isShowConPass = true;

class _LoginPageState extends State<SetPass> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final confirmpassController = TextEditingController();
  final passwordController = TextEditingController();
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  String? password, comfirmpass;
  Animation? buttonSqueezeanimation;
  AnimationController? buttonController;
  void validateAndSubmit() async {
    if (validateAndSave()) {
      _playAnimation();
      checkNetwork();
    }
  }

  Future<void> checkNetwork() async {
    context.read<AuthenticationProvider>().setNewPassword(password);
    isNetworkAvail = await isNetworkAvailable();
    if (isNetworkAvail) {
      Future.delayed(Duration.zero).then(
        (value) => context
            .read<AuthenticationProvider>()
            .getReset(widget.mobileNumber)
            .then(
          (
            value,
          ) async {
            bool? error = value['error'];
            String? msg = value['message'];
            await buttonController!.reverse();
            if (!error!) {
              setSnackbar(getTranslated(context, 'PASS_SUCCESS_MSG'), context);
              Future.delayed(const Duration(seconds: 1)).then(
                (_) {
                  Routes.pop(context);
                  Navigator.pushReplacement(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => const Login(isPop: false),
                    ),
                  );
                },
              );
            } else {
              setSnackbar(msg!, context);
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
                  builder: (BuildContext context) => super.widget));
        } else {
          await buttonController!.reverse();
          if (mounted) setState(() {});
        }
      },
    );
  }

  forgotpassTxt() {
    return Padding(
      padding: const EdgeInsetsDirectional.only(
        top: 40.0,
      ),
      child: Align(
        alignment: Alignment.topLeft,
        child: Text(
          getTranslated(context, 'FORGOT_PASSWORDTITILE'),
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
                color: Theme.of(context).colorScheme.fontColor,
                fontWeight: FontWeight.bold,
                fontSize: textFontSize23,
                letterSpacing: 0.8,
                fontFamily: 'ubuntu',
              ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    buttonController!.dispose();
    super.dispose();
  }

  setPass() {
    return Padding(
        padding: const EdgeInsets.only(top: 40),
        child: TextFormField(
          style: TextStyle(
            color: Theme.of(context).colorScheme.fontColor.withOpacity(0.7),
            fontWeight: FontWeight.bold,
            fontSize: textFontSize13,
          ),
          keyboardType: TextInputType.text,
          obscureText: isShowPass,
          controller: passwordController,
          textCapitalization: TextCapitalization.none,
          inputFormatters: [
            FilteringTextInputFormatter.deny(RegExp('[ ]')),
          ],
          validator: (val) => StringValidation.validatePass(
            val!,
            getTranslated(context, 'PWD_REQUIRED'),
            getTranslated(context, 'PASSWORD_VALIDATION'),
            onlyRequired: false,
          ),
          onSaved: (String? value) {
            context.read<AuthenticationProvider>().setNewPassword(value);
            password = value;
          },
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(circularBorderRadius10),
            ),

            errorMaxLines: 4,
            contentPadding: const EdgeInsets.fromLTRB(
                13, 17, 40, 17), // Adjust the padding as needed
            hintText: getTranslated(context, 'PASSHINT_LBL'),
            hintStyle: TextStyle(
              color: Theme.of(context).colorScheme.fontColor.withOpacity(0.3),
              fontWeight: FontWeight.bold,
              fontSize: textFontSize13,
            ),
            fillColor: Theme.of(context).colorScheme.lightWhite,
            filled: true,

            suffixIcon: InkWell(
              onTap: () {
                setState(() {
                  isShowPass = !isShowPass;
                });
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
          ),
        ));
  }

  setConfirmpss() {
    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: TextFormField(
        style: TextStyle(
            color: Theme.of(context).colorScheme.fontColor.withOpacity(0.7),
            fontWeight: FontWeight.bold,
            fontSize: textFontSize13),
        keyboardType: TextInputType.text,
        obscureText: isShowConPass,
        controller: confirmpassController,
        validator: (value) {
          if (value!.isEmpty) {
            return getTranslated(context, 'CON_PASS_REQUIRED_MSG');
          }
          if (value != password) {
            return getTranslated(context, 'CON_PASS_NOT_MATCH_MSG');
          } else {
            return null;
          }
        },
        onSaved: (String? value) {
          comfirmpass = value;
        },
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 13,
            vertical: 17,
          ),
          hintText: getTranslated(context, 'CONFIRMPASSHINT_LBL'),
          hintStyle: TextStyle(
              color: Theme.of(context).colorScheme.fontColor.withOpacity(0.3),
              fontWeight: FontWeight.bold,
              fontSize: textFontSize13),
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(circularBorderRadius10),
          ),
          fillColor: Theme.of(context).colorScheme.lightWhite,
          filled: true,
          suffixIcon: InkWell(
            onTap: () {
              setState(
                () {
                  isShowConPass = !isShowConPass;
                },
              );
            },
            child: Padding(
              padding: const EdgeInsetsDirectional.only(end: 10.0),
              child: Icon(
                !isShowConPass ? Icons.visibility : Icons.visibility_off,
                color: Theme.of(context).colorScheme.fontColor.withOpacity(0.4),
                size: 22,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
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

  Future<void> _playAnimation() async {
    try {
      await buttonController!.forward();
    } on TickerCanceled {}
  }

  setPassBtn() {
    return Center(
      child: Padding(
        padding: const EdgeInsetsDirectional.only(top: 20.0, bottom: 20.0),
        child: AppBtn(
          title: getTranslated(context, 'SET_PASSWORD'),
          btnAnim: buttonSqueezeanimation,
          btnCntrl: buttonController,
          onBtnSelected: () async {
            FocusScope.of(context).unfocus();
            validateAndSubmit();
          },
        ),
      ),
    );
  }

  expandedBottomView() {
    return Expanded(
      child: SingleChildScrollView(
        child: Form(
          key: _formkey,
          child: Card(
            elevation: 0.5,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(circularBorderRadius10)),
            margin: const EdgeInsetsDirectional.only(
              start: 20.0,
              end: 20.0,
              top: 20.0,
            ),
            child: Column(
              children: [
                forgotpassTxt(),
                setPass(),
                setConfirmpss(),
                setPassBtn(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Theme.of(context).colorScheme.white,
      key: _scaffoldKey,
      body: isNetworkAvail
          ? Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                    top: 23,
                    left: 23,
                    right: 23,
                    bottom: MediaQuery.of(context).viewInsets.bottom),
                child: Form(
                  key: _formkey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      getLogo(),
                      forgotpassTxt(),
                      setPass(),
                      setConfirmpss(),
                      setPassBtn(),
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
}
