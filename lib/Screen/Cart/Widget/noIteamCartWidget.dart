import 'package:eshop_multivendor/Screen/Dashboard/Dashboard.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../../Helper/Color.dart';
import '../../../Helper/Constant.dart';
import '../../../Helper/String.dart';
import '../../../widgets/desing.dart';
import '../../Language/languageSettings.dart';

class EmptyCart extends StatelessWidget {
  const EmptyCart({Key? key}) : super(key: key);

  noCartImage(BuildContext context) {
    return SvgPicture.asset(
      DesignConfiguration.setSvgPath('empty_cart'),
      fit: BoxFit.contain,
    );
  }

  noCartText(BuildContext context) {
    return Text(
      getTranslated(context, 'NO_CART'),
      style: Theme.of(context).textTheme.headlineSmall!.copyWith(
            color: colors.primary,
            fontWeight: FontWeight.normal,
            fontFamily: 'ubuntu',
          ),
    );
  }

  noCartDec(BuildContext context) {
    return Container(
      padding:
          const EdgeInsetsDirectional.only(top: 30.0, start: 30.0, end: 30.0),
      child: Text(
        getTranslated(context, 'CART_DESC'),
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.titleLarge!.copyWith(
              color: Theme.of(context).colorScheme.lightBlack2,
              fontWeight: FontWeight.normal,
              fontFamily: 'ubuntu',
            ),
      ),
    );
  }

  shopNow(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(top: 28.0),
      child: CupertinoButton(
        child: Container(
          width: deviceWidth! * 0.7,
          height: 45,
          alignment: FractionalOffset.center,
          decoration: const BoxDecoration(
            color: colors.primary,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [colors.primary, colors.primary],
              stops: [0, 1],
            ),
            borderRadius: BorderRadius.all(
              Radius.circular(
                circularBorderRadius50,
              ),
            ),
          ),
          child: Text(
            getTranslated(context, 'SHOP_NOW'),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  color: Theme.of(context).colorScheme.white,
                  fontWeight: FontWeight.normal,
                  fontFamily: 'ubuntu',
                ),
          ),
        ),
        onPressed: () async {
          Navigator.popUntil(context, (route) => route.isFirst);
          if (Dashboard.dashboardScreenKey.currentState != null) {
            Dashboard.dashboardScreenKey.currentState!.changeTabPosition(0);
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            noCartImage(context),
            noCartText(context),
            noCartDec(context),
            shopNow(context)
          ],
        ),
      ),
    );
  }
}
