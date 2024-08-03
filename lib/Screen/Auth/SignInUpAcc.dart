import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:eshop_multivendor/Screen/Profile/widgets/languageBottomSheet.dart';
import 'package:eshop_multivendor/widgets/applogo.dart';
import 'package:eshop_multivendor/widgets/bottomSheet.dart';
import 'package:eshop_multivendor/widgets/desing.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../Helper/Constant.dart';
import '../../Helper/String.dart';
import '../../Helper/routes.dart';

import '../Language/languageSettings.dart';
import 'SendOtp.dart';

class SignInUpAcc extends StatefulWidget {
  const SignInUpAcc({Key? key}) : super(key: key);

  @override
  _SignInUpAccState createState() => _SignInUpAccState();
}

class _SignInUpAccState extends State<SignInUpAcc> {
  @override
  void initState() {
    super.initState();
  }

  _subLogo() {
    return Padding(
      padding: EdgeInsetsDirectional.only(top: deviceHeight! * 0.15),
      child: const AppLogo(),
    );
  }

  welcomeEshopTxt() {
    return Padding(
      padding: const EdgeInsetsDirectional.only(top: 30.0),
      child: Text(
        '${getTranslated(context, 'WELCOME')} $appName',
        style: Theme.of(context).textTheme.titleMedium!.copyWith(
              color: Theme.of(context).colorScheme.fontColor,
              fontWeight: FontWeight.bold,
              fontFamily: 'ubuntu',
            ),
      ),
    );
  }

  eCommerceforBusinessTxt() {
    return Padding(
      padding: const EdgeInsetsDirectional.only(
        top: 5.0,
      ),
      child: Text(
        getTranslated(context, 'ECOMMERCE_APP_FOR_ALL_BUSINESS'),
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.titleSmall!.copyWith(
              color: Theme.of(context).colorScheme.fontColor,
              fontWeight: FontWeight.normal,
              fontFamily: 'ubuntu',
            ),
      ),
    );
  }

  signInBtn() {
    return CupertinoButton(
      child: Container(
        width: deviceWidth! * 0.40,
        height: 52,
        alignment: FractionalOffset.center,
        decoration: const BoxDecoration(
          color: colors.whiteTemp,
          borderRadius: BorderRadius.all(
            Radius.circular(
              circularBorderRadius10,
            ),
          ),
        ),
        child: Text(
          getTranslated(context, 'Sign in'),
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleSmall!.copyWith(
                color: colors.primary,
                fontWeight: FontWeight.bold,
                fontSize: textFontSize15,
                fontFamily: 'ubuntu',
              ),
        ),
      ),
      onPressed: () {
        Routes.navigateToLoginScreen(
          context,
          isPop: false,
        );
      },
    );
  }

  createAccBtn() {
    return CupertinoButton(
      child: Container(
        width: deviceWidth! * 0.4,
        height: 52,
        alignment: FractionalOffset.center,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [colors.grad1Color, colors.grad2Color],
              stops: [0, 1]),
          borderRadius:
              BorderRadius.all(Radius.circular(circularBorderRadius10)),
        ),
        child: Text(
          getTranslated(context, 'Register'),
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleSmall!.copyWith(
                color: colors.whiteTemp,
                fontWeight: FontWeight.bold,
                fontSize: textFontSize15,
                fontFamily: 'ubuntu',
              ),
        ),
      ),
      onPressed: () {
        Navigator.of(context).push(
          CupertinoPageRoute(
            builder: (BuildContext context) => SendOtp(
              title: getTranslated(context, 'SEND_OTP_TITLE'),
            ),
          ),
        );
      },
    );
  }

  languageInBtn() {
    return Container(
      padding: const EdgeInsets.only(top: 13),
      alignment: Alignment.topRight,
      child: CupertinoButton(
        child: InkWell(
          onTap: ()=> CustomBottomSheet.showBottomSheet(
                child: LanguageBottomSheet(),
                context: context,
                enableDrag: true),
          child: Container(
            width: 150,
            height: 50,
            alignment: FractionalOffset.center,
            decoration: const BoxDecoration(
              color: colors.whiteTemp,
              borderRadius: BorderRadius.all(
                Radius.circular(circularBorderRadius10),
              ),
            ),
            child: Text(
             getTranslated(context, 'CHANGE_LANGUAGE_LBL'),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'ubuntu',
                  ),
            ),
          ),
        ),
        onPressed: () {
          Navigator.pushNamedAndRemoveUntil(context, '/home', (r) => false);
        },
      ),
    );
  }
     _getDrawerItem(String title, String img) {
    return Card(
      elevation: 0.1,
      child: ListTile(
        trailing: const Icon(
          Icons.navigate_next,
          color: colors.primary,
        ),
        leading: SvgPicture.asset(
          DesignConfiguration.setSvgPath(img),
          height: 25,
          width: 25,
          colorFilter: const ColorFilter.mode(colors.primary, BlendMode.srcIn),
        ),
        dense: true,
        title: Text(
          title,
          style: TextStyle(
            color: Theme.of(context).colorScheme.lightBlack,
            fontSize: textFontSize15,
          ),
        ),
        onTap: () {
         if (title == getTranslated(context, 'CHANGE_LANGUAGE_LBL')) {
            CustomBottomSheet.showBottomSheet(
                child: LanguageBottomSheet(),
                context: context,
                enableDrag: true);
          } 
        },
      ),
    );
  }


  skipSignInBtn() {
    return Container(
      padding: const EdgeInsets.only(top: 13),
      alignment: Alignment.topRight,
      child: CupertinoButton(
        child: Container(
          width: 60,
          height: 50,
          alignment: FractionalOffset.center,
          decoration: const BoxDecoration(
            color: colors.whiteTemp,
            borderRadius: BorderRadius.all(
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
          Navigator.pushNamedAndRemoveUntil(context, '/home', (r) => false);
        },
      ),
    );
  }

  bottomBtn() {
    return Padding(
      padding: EdgeInsets.only(top: deviceHeight! * 0.28),
      child: Row(
        children: [
          Expanded(child: createAccBtn()),
          Expanded(child: signInBtn()),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    deviceHeight = MediaQuery.of(context).size.height;
    deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Container(
        color: Theme.of(context).colorScheme.lightWhite,
        padding: const EdgeInsetsDirectional.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
      
                languageInBtn(),
               const SizedBox(width: 70,),
                skipSignInBtn(),],),
              
              _subLogo(),
              welcomeEshopTxt(),
              eCommerceforBusinessTxt(),
              bottomBtn()
            ],
          ),
        ),
      ),
    );
  }

}
