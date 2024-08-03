import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../../Helper/Constant.dart';
import '../../../Helper/String.dart';
import '../../../Helper/routes.dart';
import '../../../Model/Section_Model.dart';
import '../../../Provider/CartProvider.dart';
import '../../../Provider/productDetailProvider.dart';
import '../../../widgets/desing.dart';
import '../../Language/languageSettings.dart';
import '../productDetail.dart';
import 'productRattingUI.dart';
import 'package:collection/src/iterable_extensions.dart';

class GetNameWidget extends StatelessWidget {
  String name;

  GetNameWidget({Key? key, required this.name}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 15.0,
        right: 15.0,
        top: 16.0,
      ),
      child: Text(
        name,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.lightBlack,
          fontSize: textFontSize14,
        ),
      ),
    );
  }
}

class GetTitleWidget extends StatelessWidget {
  String title;

  GetTitleWidget({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 10.0,
        left: 15.0,
        right: 15.0,
        bottom: 15.0,
      ),
      child: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w400,
          color: Theme.of(context).colorScheme.black,
          fontSize: textFontSize16,
        ),
      ),
    );
  }
}

class GetIncludeTaxWidget extends StatelessWidget {
  const GetIncludeTaxWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5),
      child: Text(
        "(${getTranslated(context, 'INCLUDED_TAX')})",
        style: Theme.of(context).textTheme.bodySmall!.copyWith(
            color: Theme.of(context).colorScheme.lightBlack2, fontSize: 10),
      ),
    );
  }
}

class GetPrice extends StatelessWidget {
  var pos, from;
  Product? model;

  GetPrice({Key? key, this.from, this.pos, this.model}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double discountPrice = double.parse(
      model!.prVarientList![pos].disPrice!,
    );
    double nodisPrice = double.parse(
      model!.prVarientList![pos].price!,
    );

    if (discountPrice == 0) {
      nodisPrice = double.parse(
        model!.prVarientList![pos].price!,
      );
    }

    if (discountPrice != 0) {
      double off = (double.parse(model!.prVarientList![pos].price!) -
              double.parse(model!.prVarientList![pos].disPrice!))
          .toDouble();

      off = off * 100 / double.parse(model!.prVarientList![pos].price!);
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  '${DesignConfiguration.getPriceFormat(context, discountPrice)!} ',
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        color: colors.primary,
                        fontWeight: FontWeight.w700,
                        fontStyle: FontStyle.normal,
                        fontSize: textFontSize20,
                      ),
                ),
                const SizedBox(width: 10),
                off != 0.00
                    ? Row(children: [ Text(
                        '${DesignConfiguration.getPriceFormat(context, double.parse(model!.prVarientList![pos].price!))!} ',
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                              decoration: TextDecoration.lineThrough,
                              decorationColor: colors.darkColor3,
                              decorationStyle: TextDecorationStyle.solid,
                              decorationThickness: 2,
                              letterSpacing: 0,
                              color: Theme.of(context)
                                  .colorScheme
                                  .fontColor
                                  .withOpacity(0.7),
                              fontStyle: FontStyle.normal,
                              fontSize: textFontSize13,
                              fontWeight: FontWeight.w300,
                            ),
                      ),
                    Text(
                        ' ${off.toStringAsFixed(2)}% OFF',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.labelSmall!.copyWith(
                              color: colors.green,
                              letterSpacing: 0,
                              fontWeight: FontWeight.w400,
                              fontStyle: FontStyle.normal,
                              fontSize: textFontSize13,
                            ),
                      )],)
                    : const SizedBox(),
                const SizedBox(width: 0),
                from
                    ? Consumer<CartProvider>(
                        builder: (context, data, _) {
                          final tempId = data.cartList.firstWhereOrNull((cp) =>
                              cp.id == model!.id &&
                              cp.varientId ==
                                  model!
                                      .prVarientList![model!.selVarient!].id!);

                          if (!context
                              .read<ProductDetailProvider>()
                              .qtyChange) {
                            if (tempId != null) {
                              qtyController.text = tempId.qty!;
                            } else {
                              String qty = model!
                                  .prVarientList![model!.selVarient!]
                                  .cartCount!;
                              if (qty == '0') {
                                qtyController.text =
                                    model!.minOrderQuntity.toString();
                              } else {
                                qtyController.text = qty;
                              }
                            }
                          } else {
                            context.read<ProductDetailProvider>().qtyChange =
                                false;
                          }

                          return Padding(
                            padding: const EdgeInsetsDirectional.only(
                              start: 3.0,
                              bottom: 5,
                              top: 3,
                            ),
                            child: model!.availability == '0'
                                ? const SizedBox()
                                : const Row(
                                    children: [],
                                  ),
                          );
                        },
                      )
                    : const SizedBox(),
              ],
            ),
          ],
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              '${DesignConfiguration.getPriceFormat(context, nodisPrice)!} ',
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w700,
                    fontStyle: FontStyle.normal,
                    fontSize: textFontSize20,
                  ),
            ),
          ],
        ),
      );
    }
  }
}

class GetRatttingWidget extends StatelessWidget {
  String ratting;
  String noOfRatting;

  GetRatttingWidget(
      {Key? key, required this.noOfRatting, required this.ratting})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsetsDirectional.only(
              start: 15.0,
              end: 5.0,
              top: 15.0,
              bottom: 15.0,
            ),
            child: StarRatingProductDetailPage(
              totalRating: ratting,
              noOfRatings: noOfRatting,
              needToShowNoOfRatings: true,
            ),
          ),
        ),
      ],
    );
  }
}

getDivider(double height, BuildContext context) {
  return Divider(
    height: height,
    color: Theme.of(context).colorScheme.lightWhite,
  );
}

class SaveExtraWithOffers extends StatelessWidget {
  Function update;

  SaveExtraWithOffers({Key? key, required this.update}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.only(top: 5.0),
        color: Theme.of(context).colorScheme.white,
        child: InkWell(
          onTap: () async {
            Routes.navigateToPromoCodeScreen(context, 'Profile', update);
          },
          child: Padding(
            padding: const EdgeInsetsDirectional.only(
              bottom: 8.0,
              top: 8.0,
              start: 8.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  getTranslated(context, 'Save extra with offers'),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.black,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Ubuntu',
                    fontStyle: FontStyle.normal,
                    fontSize: textFontSize16,
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_right,
                  size: 30,
                  color: Theme.of(context).colorScheme.black,
                ),
              ],
            ),
          ),
        )
        /* InkWell(
        onTap: () async {
          Routes.navigateToPromoCodeScreen(context, 'Profile', update);
        },
        child: ListTile(
          dense: true,
          title: Row(
            children: [
              Text(
                getTranslated(context, 'Save extra with offers')!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.black,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Ubuntu',
                  fontStyle: FontStyle.normal,
                  fontSize: textFontSize16,
                ),
              ),
            ],
          ),
          trailing: Icon(
            Icons.keyboard_arrow_right,
            size: 30,
            color: Theme.of(context).colorScheme.black,
          ),
        ),
      ),*/
        );
  }
}

class SimmerSingle extends StatelessWidget {
  const SimmerSingle({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8.0,
      ),
      child: Shimmer.fromColors(
        baseColor: Theme.of(context).colorScheme.simmerBase,
        highlightColor: Theme.of(context).colorScheme.simmerHigh,
        child: Container(
          width: deviceWidth! * 0.45,
          height: 250,
          color: Theme.of(context).colorScheme.white,
        ),
      ),
    );
  }
}
