import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import '../Helper/Color.dart';
import '../Helper/Constant.dart';
import '../Helper/routes.dart';
import '../Provider/UserProvider.dart';
import '../Screen/Cart/Cart.dart';
import '../Screen/Cart/Widget/clearTotalCart.dart';
import 'desing.dart';
import '../Screen/Language/languageSettings.dart';

getAppBar(String title, BuildContext context, Function setState,
    {Widget? classType, Function()? onTap}) {
      double size = MediaQuery.of(context).size.width;
  return AppBar(
    titleSpacing: 0,
    // systemOverlayStyle: SystemUiOverlayStyle(
    //                 statusBarColor: Theme.of(context).colorScheme.white),
    backgroundColor: Theme.of(context).colorScheme.white,
    // leadingWidth: 50,
    leading: Builder(
      builder: (BuildContext context) {
        return InkWell(
            // borderRadius: BorderRadius.circular(circularBorderRadius4),
            onTap: onTap ??
                () => classType != null
                    ? Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) => classType),
                        (route) => false)
                    : Navigator.of(context).pop(),
            child:  Icon(
              Icons.arrow_back_ios_rounded,
              color: Theme.of(context).colorScheme.fontColor,
            ),
          );
        
      },
    ),
    title: Text(
      title,
      style: TextStyle(
        color: Theme.of(context).colorScheme.fontColor,
        fontWeight: FontWeight.normal,
        fontFamily: 'ubuntu',
      ),
    ),
    actions: <Widget>
    [
      title == getTranslated(context, 'FAVORITE') 
          ? const SizedBox()
          : GestureDetector(
            child: Padding(
              padding:  EdgeInsets.only(left: size * 0.02),
              child: SvgPicture.asset(
                  DesignConfiguration.setSvgPath('desel_fav'),
                  colorFilter:
                       ColorFilter.mode(Theme.of(context).colorScheme.fontColor, BlendMode.srcIn),
                ),
            ),
              onTap: () {
                Routes.navigateToFavoriteScreen(context);
              },
          ),
          // IconButton(
          //     padding: const EdgeInsets.all(0),
          //     icon: SvgPicture.asset(
          //       DesignConfiguration.setSvgPath('desel_fav'),
          //       colorFilter:
          //            ColorFilter.mode(Theme.of(context).colorScheme.fontColor, BlendMode.srcIn),
          //     ),
          //     onPressed: () {
          //       Routes.navigateToFavoriteScreen(context);
          //     },
          //   ),
      Selector<UserProvider, String>(
        builder: (context, data, child) {
          return  IconButton(
            icon: Stack(
              children: [
                Center(
                  child: SvgPicture.asset(
                    DesignConfiguration.setSvgPath('appbarCart'),
                    colorFilter:
                         ColorFilter.mode(Theme.of(context).colorScheme.fontColor, BlendMode.srcIn),
                  ),
                ),
                (data.isNotEmpty && data != '0')
                    ? Positioned(
                        bottom: 20,
                        right: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: colors.primary,
                          ),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(3),
                              child: Text(
                                data,
                                style: const TextStyle(
                                  fontSize: textFontSize7,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'ubuntu',
                                  color: colors.whiteTemp,
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                    : const SizedBox()
              ],
            ),
            onPressed: () {
              cartTotalClear(context);
              Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (context) => const Cart(
                    fromBottom: false,
                  ),
                ),
              ).then(
                (value) {
                  setState;
                },
              );
            },
          );
        },
        selector: (_, HomePageProvider) => HomePageProvider.curCartCount,
      )
    ],
  );
}
getappbarforcart(String title,
  BuildContext context,){
  return AppBar(
    toolbarHeight: 50,
    titleSpacing: 0,
    backgroundColor: Theme.of(context).colorScheme.white,
    elevation: 0.8 ,
    shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(10), // Radius for bottom left and right corners
            ),
          ),
    title: Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).colorScheme.fontColor,
          fontWeight: FontWeight.normal,
          fontFamily: 'ubuntu',
        ),
      ),
    ),
  );
  
}
getSimpleAppBar(
  String title,
  BuildContext context,
) {
  return AppBar(
    // systemOverlayStyle: SystemUiOverlayStyle(
    //                 statusBarColor: Theme.of(context).colorScheme.white),
    titleSpacing: 0,
    backgroundColor: Theme.of(context).colorScheme.white,
    leading: Builder(
      builder: (BuildContext context) {
        return Container(
          margin: const EdgeInsets.all(10),
          child: InkWell(
            borderRadius: BorderRadius.circular(circularBorderRadius4),
            onTap: () => Navigator.of(context).pop(),
            child:  Center(
              child: Icon(
                Icons.arrow_back_ios_rounded,
                color: Theme.of(context).colorScheme.fontColor,
              ),
            ),
          ),
        );
      },
    ),
    title: Text(
      title,
      style: TextStyle(
        color: Theme.of(context).colorScheme.fontColor,
        fontWeight: FontWeight.normal,
        fontFamily: 'ubuntu',
      ),
    ),
  );
}
