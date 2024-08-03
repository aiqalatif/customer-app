import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../Helper/Color.dart';
import '../../../Helper/Constant.dart';
import '../../../Provider/Order/UpdateOrderProvider.dart';
import '../../Language/languageSettings.dart';

class GetSubHeadingsTabBar extends StatelessWidget {
  const GetSubHeadingsTabBar({
    Key? key,
  }) : super(key: key);

  getTab(
    String title,
    int index,
    BuildContext context,
  ) {
    return Container(
      padding: const EdgeInsets.all(5.0),
      height: 35,
      child: Center(
        child: Text(
          title,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: TabBar(
        controller: context.read<UpdateOrdProvider>().tabController,
        tabs: [
          getTab(
            getTranslated(context, 'ALL_DETAILS'),
            0,
            context,
          ),
          getTab(
            getTranslated(context, 'PROCESSING'),
            1,
            context,
          ),
          getTab(
            getTranslated(context, 'SHIPPED'),
            2,
            context,
          ),
          getTab(
            getTranslated(context, 'DELIVERED'),
            3,
            context,
          ),
          getTab(
            getTranslated(context, 'CANCELLED'),
            4,
            context,
          ),
          getTab(
            getTranslated(context, 'RETURNED'),
            5,
            context,
          ),
        ],
        indicator: BoxDecoration(
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(circularBorderRadius50),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [colors.grad1Color, colors.grad2Color],
            stops: [0, 1],
          ),
        ),
        isScrollable: true,
        unselectedLabelColor: Theme.of(context).colorScheme.fontColor,
        labelColor: Theme.of(context).colorScheme.white,
        automaticIndicatorColorAdjustment: true,
        indicatorPadding: const EdgeInsets.symmetric(horizontal: 1.0),
      ),
    );
  }
}
