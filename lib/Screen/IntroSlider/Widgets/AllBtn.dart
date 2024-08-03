import 'package:eshop_multivendor/Screen/Auth/SignInUpAcc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../Helper/Color.dart';
import '../../../Helper/Constant.dart';
import '../../../Helper/String.dart';
import '../../../Provider/SettingProvider.dart';
import '../../Language/languageSettings.dart';

class SliderBtn extends StatelessWidget {
  int currentPage;
  PageController pageController;
  List sliderList;
  SliderBtn(
      {Key? key,
      required this.currentPage,
      required this.pageController,
      required this.sliderList})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: getList(sliderList, context, currentPage)),
          Center(
              child: Padding(
            padding: const EdgeInsetsDirectional.only(bottom: 18.0),
            child: Padding(
              padding: const EdgeInsets.only(top: 25),
              child: CupertinoButton(
                child: Container(
                  width: 90,
                  height: 40,
                  alignment: FractionalOffset.center,
                  decoration: BoxDecoration(
                      gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [colors.grad1Color, colors.grad2Color],
                          stops: [0, 1]),
                      borderRadius:
                          BorderRadius.circular(circularBorderRadius50)),
                  child: currentPage == 0 || currentPage == 1
                      ? Text(
                          getTranslated(context, 'NEXT_LBL'),
                          style: const TextStyle(
                            color: colors.whiteTemp,
                            fontFamily: 'ubuntu',
                          ),
                        )
                      : Text(
                          getTranslated(context, 'GET_STARTED'),
                          style: const TextStyle(
                            color: colors.whiteTemp,
                            fontFamily: 'ubuntu',
                          ),
                        ),
                ),
                onPressed: () {
                  if (currentPage == 2) {
                    setPrefrenceBool(ISFIRSTTIME, true);
                    Navigator.pushReplacement(
                      context,
                      CupertinoPageRoute(
                          builder: (context) => const SignInUpAcc()),
                    );
                  } else {
                    currentPage = currentPage + 1;
                    pageController.animateToPage(currentPage,
                        curve: Curves.decelerate,
                        duration: const Duration(milliseconds: 300));
                  }
                },
              ),
            ),
          )),
        ],
      ),
    );
  }
}

skipBtn(BuildContext context, int currentPage) {
  return currentPage == 0 || currentPage == 1
      ? Padding(
          padding: const EdgeInsetsDirectional.only(top: 20.0, end: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              InkWell(
                onTap: () {
                  setPrefrenceBool(ISFIRSTTIME, true);
                  Navigator.pushReplacement(
                    context,
                    CupertinoPageRoute(
                        builder: (context) => const SignInUpAcc()),
                  );
                },
                child: Row(
                  children: [
                    Text(
                      getTranslated(context, 'SKIP'),
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            color: Theme.of(context).colorScheme.fontColor,
                            fontFamily: 'ubuntu',
                          ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Theme.of(context).colorScheme.fontColor,
                      size: 12.0,
                    ),
                  ],
                ),
              ),
            ],
          ),
        )
      : Container(
          margin: const EdgeInsetsDirectional.only(top: 50.0),
          height: 15,
        );
}

List<Widget> getList(List slideList, BuildContext context, int currentPage) {
  List<Widget> childs = [];

  for (int i = 0; i < slideList.length; i++) {
    childs.add(
      AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: currentPage == i ? 30.0 : 10.0,
        height: 5,
        margin: const EdgeInsets.symmetric(horizontal: 3.0),
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(circularBorderRadius10),
          color: currentPage == i
              ? Theme.of(context).colorScheme.fontColor
              : Theme.of(context).colorScheme.fontColor.withOpacity(
                    (0.5),
                  ),
        ),
      ),
    );
  }
  return childs;
}
