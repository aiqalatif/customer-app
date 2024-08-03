import 'dart:async';

import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:eshop_multivendor/Helper/Constant.dart';
import 'package:eshop_multivendor/Model/Section_Model.dart';
import 'package:eshop_multivendor/Screen/Language/languageSettings.dart';
import 'package:flutter/material.dart';

class ProductStatesticsAnimatedContainer extends StatefulWidget {
  final ProductStatistics statistics;
  const ProductStatesticsAnimatedContainer({Key? key, required this.statistics})
      : super(key: key);

  @override
  State<ProductStatesticsAnimatedContainer> createState() =>
      _ProductStatesticsAnimatedContainerState();
}

class _ProductStatesticsAnimatedContainerState
    extends State<ProductStatesticsAnimatedContainer>
    with SingleTickerProviderStateMixin {
  Duration singleAnimationDuration = const Duration(milliseconds: 2000);

  Timer? timer; //animation timer
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<double> _scaleAnimation;
  List<Widget>? statisticsWidgets ;
  bool loading = true;
  @override
  void initState() {
    timer = Timer.periodic(singleAnimationDuration, (timer) {
      if (currentWidgetIndex < (statisticsWidgets!.length - 1)) {
         currentWidgetIndex = currentWidgetIndex + 1;
      } else {
        currentWidgetIndex = 0;
      }
      _controller.reset();
      _controller.forward();
      setState(() {});
    });
    _controller = AnimationController(
      duration: singleAnimationDuration -
          const Duration(milliseconds: 800), //millisecond wait for user to view
      vsync: this,
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.forward();

    Future.delayed(Duration.zero, () {
      statisticsWidgets = [
        if (widget.statistics.totalInCart != '0')
          _itemWidget(
              icon: Icons.rocket_launch,
              count: widget.statistics.totalInCart,
              text: " ${getTranslated(context, 'PEOPLE_HAVE_ADDED_IN_CART')}"),
        if (widget.statistics.totalFavourites != '0')
          _itemWidget(
              icon: Icons.favorite,
              count: widget.statistics.totalFavourites,
              text:
                  " ${getTranslated(context, 'PEOPLE_HAVE_ADDED_IN_FAVOURITES')}"),
        if (widget.statistics.totalOrders != '0')
          _itemWidget(
              icon: Icons.shopping_cart_rounded,
              count: widget.statistics.totalOrders,
              text:
                  " ${getTranslated(context, 'ITEMS_SOLD_IN_LAST_30_DAYS')}"),
      ];
      setState(() {
        loading = false;
      });
    });

    super.initState();
  }

  @override
  void dispose() {
    if (timer != null) {
      timer!.cancel();
    }
    _controller.dispose();
    super.dispose();
  }

  _itemWidget({
    required IconData icon,
    required String count,
    required String text,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: colors.primary,
          size: 14,
        ),
        const SizedBox(
          width: 5,
        ),
        Flexible(
          child: Text.rich(
            TextSpan(
              text: count,
              style: const TextStyle(
                fontFamily: 'ubuntu',
                fontWeight: FontWeight.bold,
                fontSize: textFontSize14,
                color: colors.primary,
              ),
              children: [
                TextSpan(
                  text: text,
                  style: TextStyle(
                    fontFamily: 'ubuntu',
                    fontSize: textFontSize14,
                    fontWeight: FontWeight.normal,
                    color: Theme.of(context).colorScheme.fontColor,
                  ),
                ),
              ],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'ubuntu',
              fontSize: textFontSize14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  int currentWidgetIndex = 0;
  // List<Widget> statisticsWidgets = [];
  @override
  Widget build(BuildContext context) {
    return (widget.statistics.totalFavourites == '0' &&
            widget.statistics.totalInCart == '0' &&
            widget.statistics.totalOrders == '0')
        ? const SizedBox.shrink() //if there is no data
        : AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Opacity(
                opacity: _opacityAnimation.value,
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: loading
                      ?
                       CircularProgressIndicator()
                      : statisticsWidgets!.isNotEmpty
                       ? statisticsWidgets![currentWidgetIndex]
                       : const SizedBox()
                    ),
                  ),
                ),
              );
            });
  }
}
