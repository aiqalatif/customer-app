import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import '../../../Provider/homePageProvider.dart';

void hideAppbarAndBottomBarOnScroll(
  ScrollController scrollBottomBarController,
  BuildContext context,
) {
  scrollBottomBarController.addListener(
    () {
      if (scrollBottomBarController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        if (!context.read<HomePageProvider>().animationController.isAnimating) {
          context.read<HomePageProvider>().animationController.forward();
          context.read<HomePageProvider>().showAppAndBottomBars(false);
        }
      } else {
        if (!context.read<HomePageProvider>().animationController.isAnimating) {
          context.read<HomePageProvider>().animationController.reverse();
          context.read<HomePageProvider>().showAppAndBottomBars(true);
        }
      }
    },
  );
}
