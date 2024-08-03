import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:eshop_multivendor/Screen/Auth/Login.dart';
import 'package:eshop_multivendor/repository/pushnotificationRepositry.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import '../../../Helper/Constant.dart';
import '../../../Helper/String.dart';
import '../../../Helper/routes.dart';
import '../../../Provider/Favourite/FavoriteProvider.dart';
import '../../../Provider/SettingProvider.dart';
import '../../../Provider/UserProvider.dart';
import '../../../widgets/desing.dart';
import '../../Language/languageSettings.dart';
import '../../../widgets/snackbar.dart';
import '../../../widgets/validation.dart';
import '../../Dashboard/Dashboard.dart';
import '../../Auth/SendOtp.dart';

class MyProfileDialog {
  static showLogoutDialog(BuildContext context) async {
    final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    final GoogleSignIn googleSignIn = GoogleSignIn();
    await DesignConfiguration.dialogAnimate(
      context,
      StatefulBuilder(
        builder: (BuildContext context, StateSetter setStater) {
          return AlertDialog(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(
                  circularBorderRadius5,
                ),
              ),
            ),
            content: Text(
              getTranslated(context, 'LOGOUTTXT'),
              style: Theme.of(context)
                  .textTheme
                  .titleMedium!
                  .copyWith(color: Theme.of(context).colorScheme.fontColor),
            ),
            actions: <Widget>[
              TextButton(
                child: Text(
                  getTranslated(context, 'NO'),
                  style: Theme.of(context).textTheme.titleSmall!.copyWith(
                      color: Theme.of(context).colorScheme.lightBlack,
                      fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              ),
              TextButton(
                child: Text(
                  getTranslated(context, 'YES'),
                  style: Theme.of(context).textTheme.titleSmall!.copyWith(
                      color: Theme.of(context).colorScheme.fontColor,
                      fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  NotificationRepository.updateFcmID(parameter: {
                    FCM_ID: '-',
                    // USER_ID: context.read<UserProvider>().userId ?? ''
                  });
                  SettingProvider settingProvider =
                      Provider.of<SettingProvider>(context, listen: false);
                  if (context.read<UserProvider>().loginType != PHONE_TYPE) {
                    if (context.read<UserProvider>().loginType == GOOGLE_TYPE) {
                      googleSignIn.signOut();
                    } else {
                      firebaseAuth.signOut();
                    }
                  }
                  settingProvider.clearUserSession(context);

                  context.read<FavoriteProvider>().setFavlist([]);

                  Navigator.of(context).pop();
                  if (Dashboard.dashboardScreenKey.currentState != null) {
                    Dashboard.dashboardScreenKey.currentState!
                        .changeTabPosition(0);
                  }
                },
              )
            ],
          );
        },
      ),
    );
  }

  static showDeleteAccountDialog(BuildContext cxt) async {
    await DesignConfiguration.dialogAnimate(
      cxt,
      StatefulBuilder(
        builder: (BuildContext context, setState) {
          return DeleteAccountDialog(
            cxt: cxt,
          );
        },
      ),
    );
  }

  static showDeleteWarningAccountDialog(BuildContext parentcontext) async {
    await DesignConfiguration.dialogAnimate(
      parentcontext,
      StatefulBuilder(
        builder: (BuildContext cxt, setState) {
          return AlertDialog(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(circularBorderRadius5),
              ),
            ),
            content: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  getTranslated(cxt, 'DeleteAccount'),
                  style: Theme.of(cxt).textTheme.titleSmall!.copyWith(
                        color: Theme.of(cxt).colorScheme.error,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  getTranslated(
                    cxt,
                    'DELETE_ACCOUNT_WARNING',
                  ),
                  style: Theme.of(cxt).textTheme.titleSmall!.copyWith(),
                )
              ],
            ),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    child: Text(
                      getTranslated(cxt, 'NO'),
                      style: Theme.of(cxt).textTheme.titleSmall!.copyWith(
                            color: Theme.of(cxt).colorScheme.lightBlack,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    onPressed: () {
                      Navigator.of(parentcontext).pop(false);
                    },
                  ),
                  TextButton(
                    child: Text(
                      getTranslated(cxt, 'YES'),
                      style: Theme.of(cxt).textTheme.titleSmall!.copyWith(
                            color: Theme.of(cxt).colorScheme.error,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    onPressed: () {
                      if (cxt.read<UserProvider>().loginType == PHONE_TYPE) {
                        Routes.pop(cxt);
                        if (isDemoApp) {
                          setSnackbar(
                              getTranslated(parentcontext,
                                  'DEMO_VERSION_NOT_ALLOWED_DELETE_ACC_LBL'),
                              parentcontext);
                          return;
                        }
                        showDeleteAccountDialog(parentcontext);
                      } else {
                        User? currentUser = FirebaseAuth.instance.currentUser;

                        if (currentUser != null) {
                          currentUser.delete().then((value) async {
                            Routes.pop(parentcontext);

                            parentcontext
                                .read<UserProvider>()
                                .deleteSocialUserAccount(
                                    userId: parentcontext
                                        .read<UserProvider>()
                                        .userId!)
                                .then(
                              (value) {
                                if (!value!['error']) {
                                  SettingProvider settingProvider =
                                      Provider.of<SettingProvider>(
                                          parentcontext,
                                          listen: false);
                                  settingProvider
                                      .clearUserSession(parentcontext);

                                  parentcontext
                                      .read<FavoriteProvider>()
                                      .setFavlist([]);
                                  Future.delayed(Duration.zero, () {
                                    Navigator.of(parentcontext)
                                        .pushAndRemoveUntil(
                                            CupertinoPageRoute(
                                                builder: (BuildContext cxt) =>
                                                    const Login(
                                                      isPop: false,
                                                    )),
                                            (Route<dynamic> route) => false);
                                    setSnackbar(
                                        getTranslated(
                                            parentcontext, 'RELOGIN_REQ'),
                                        parentcontext);
                                  });
                                } else {
                                  setSnackbar(value['message'], parentcontext);
                                }
                              },
                            );
                          });
                        } else {
                          Navigator.of(cxt, rootNavigator: true).pop(true);
                          setSnackbar(
                              getTranslated(parentcontext, 'RELOGIN_REQ'),
                              parentcontext);
                        }
                      }
                    },
                  )
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class DeleteAccountDialog extends StatelessWidget {
  BuildContext cxt;

  DeleteAccountDialog({
    Key? key,
    required this.cxt,
  }) : super(key: key);

  final passwordController = TextEditingController();
  String? verifyPassword;
  FocusNode? passFocus = FocusNode();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(circularBorderRadius5),
        ),
      ),
      content: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            getTranslated(context, 'Please Verify Password'),
            style: Theme.of(context).textTheme.titleSmall!.copyWith(
                  color: Theme.of(context).colorScheme.fontColor,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(
            height: 25,
          ),
          Align(
            alignment: Alignment.center,
            child: Form(
              key: formKey,
              child: TextFormField(
                style: TextStyle(
                    color: Theme.of(context)
                        .colorScheme
                        .fontColor
                        .withOpacity(0.7),
                    fontWeight: FontWeight.bold,
                    fontSize: textFontSize13),
                onFieldSubmitted: (v) {
                  FocusScope.of(context).requestFocus(passFocus);
                },
                keyboardType: TextInputType.text,
                obscureText: true,
                controller: passwordController,
                focusNode: passFocus,
                textInputAction: TextInputAction.next,
                onChanged: (String? value) {
                  verifyPassword = value;
                },
                onSaved: (String? value) {
                  verifyPassword = value;
                },
                inputFormatters: [
                  FilteringTextInputFormatter.deny(RegExp('[ ]')),
                ],
                validator: (val) => StringValidation.validatePass(
                    val!,
                    getTranslated(context, 'PWD_REQUIRED'),
                    getTranslated(context, 'PASSWORD_VALIDATION'),
                    onlyRequired: true),
                decoration: InputDecoration(
                  errorMaxLines: 4,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 13,
                    vertical: 5,
                  ),
                  suffixIconConstraints:
                      const BoxConstraints(minWidth: 40, maxHeight: 20),
                  hintText: getTranslated(context, 'PASSHINT_LBL'),
                  hintStyle: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .fontColor
                          .withOpacity(0.3),
                      fontWeight: FontWeight.bold,
                      fontSize: textFontSize13),
                  fillColor: Theme.of(context).colorScheme.lightWhite,
                  filled: true,
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(circularBorderRadius10),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
      actions: [
        Selector<UserProvider, String>(
          selector: (_, provider) => provider.mob,
          builder: (context, userMobile, child) {
            return TextButton(
              child: Text(
                getTranslated(context, 'DELETE_NOW'),
                style: Theme.of(context).textTheme.titleSmall!.copyWith(
                      color: Theme.of(context).colorScheme.error,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              onPressed: () async {
                final form = formKey.currentState!;
                form.save();
                if (form.validate()) {
                  Routes.pop(context);
                  cxt
                      .read<UserProvider>()
                      .deleteUserAccount(
                          userId: context.read<UserProvider>().userId!,
                          mobileNumber: userMobile,
                          password: verifyPassword!)
                      .then(
                    (value) {
                      if (!value!['error']) {
                        verifyPassword = '';
                        SettingProvider settingProvider =
                            Provider.of<SettingProvider>(cxt, listen: false);
                        settingProvider.clearUserSession(cxt);

                        cxt.read<FavoriteProvider>().setFavlist([]);
                        Navigator.pushReplacement(
                          cxt,
                          CupertinoPageRoute(
                            builder: (BuildContext cxt) => SendOtp(
                              title: getTranslated(cxt, 'SEND_OTP_TITLE'),
                            ),
                          ),
                        );
                      } else {
                        verifyPassword = '';
                        setSnackbar(value['message'], cxt);
                      }
                    },
                  );
                }
              },
            );
          },
        )
      ],
    );
  }
}
