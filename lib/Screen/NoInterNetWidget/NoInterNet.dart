import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../Helper/Color.dart';
import '../../widgets/ButtonDesing.dart';
import '../../widgets/desing.dart';
import '../Language/languageSettings.dart';

class NoInterNet extends StatelessWidget {
  dynamic setStateNoInternate;
  Animation<dynamic>? buttonSqueezeanimation;
  AnimationController? buttonController;
  NoInterNet(
      {Key? key,
      required this.buttonController,
      required this.buttonSqueezeanimation,
      required this.setStateNoInternate})
      : super(key: key);

  noIntImage() {
    return SvgPicture.asset(
      DesignConfiguration.setSvgPath('no_internet'),
      fit: BoxFit.contain,
    );
  }

  noIntText(BuildContext context) {
    return Text(
      getTranslated(context, 'NO_INTERNET'),
      style: Theme.of(context).textTheme.headlineSmall!.copyWith(
            color: colors.primary,
            fontWeight: FontWeight.normal,
            fontFamily: 'ubuntu',
          ),
    );
  }

  noIntDec(BuildContext context) {
    return Container(
      padding:
          const EdgeInsetsDirectional.only(top: 30.0, start: 30.0, end: 30.0),
      child: Text(
        getTranslated(context, 'NO_INTERNET_DISC'),
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.titleLarge!.copyWith(
              color: Theme.of(context).colorScheme.lightBlack2,
              fontWeight: FontWeight.normal,
              fontFamily: 'ubuntu',
            ),
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
            noIntImage(),
            noIntText(context),
            noIntDec(context),
            AppBtn(
              title: getTranslated(context, 'TRY_AGAIN_INT_LBL'),
              btnAnim: buttonSqueezeanimation,
              btnCntrl: buttonController,
              onBtnSelected: setStateNoInternate,
            )
          ],
        ),
      ),
    );
  }
}
