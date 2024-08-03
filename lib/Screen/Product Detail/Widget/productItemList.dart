import 'package:eshop_multivendor/Provider/Favourite/FavoriteProvider.dart';
import 'package:eshop_multivendor/Provider/UserProvider.dart';
import 'package:eshop_multivendor/Screen/Dashboard/Dashboard.dart';
import 'package:eshop_multivendor/Screen/Language/languageSettings.dart';
import 'package:eshop_multivendor/widgets/customfevoritebuttonforCards.dart';
import 'package:eshop_multivendor/widgets/ratingCardForProduct.dart';
import 'package:eshop_multivendor/widgets/snackbar.dart';
import 'package:eshop_multivendor/widgets/star_rating.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import '../../../Helper/Constant.dart';
import '../../../Helper/String.dart';
import '../../../../Model/Section_Model.dart';
import '../../../widgets/desing.dart';
import '../productDetail.dart';
import '../../../Helper/Color.dart';

class ProductItemView extends StatelessWidget {
  int index;
  List<Product> productList;
  String from;
  int valueofsetfav;
  Function setFav;
  Function removeFav;
  Function setState;
  ProductItemView(
      {Key? key,
      required this.productList,
      required this.from,
      required this.index,
      required this.removeFav,
      required this.setFav,
      required this.setState,
      required this.valueofsetfav})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (index < productList.length) {
      String? offPer;
      double price =
          double.parse(productList[index].prVarientList![0].disPrice!);
      if (price == 0) {
        price = double.parse(productList[index].prVarientList![0].price!);
      } else {
        double off =
            double.parse(productList[index].prVarientList![0].price!) - price;
        offPer = ((off * 100) /
                double.parse(productList[index].prVarientList![0].price!))
            .toStringAsFixed(2);
      }

      double width = deviceWidth! * 0.45;
      return SizedBox(
        height: 255,
        width: width,
        child: Card(
          shape: RoundedRectangleBorder(
            side:
                BorderSide(color: Theme.of(context).colorScheme.gray, width: 1),
            borderRadius: BorderRadius.circular(3),
          ),
          // color:  Theme.of(context).colorScheme.gray,
          elevation: 0.2,
          margin: const EdgeInsetsDirectional.only(bottom: 5, end: 8),
          child: InkWell(
            borderRadius: BorderRadius.circular(circularBorderRadius10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                    flex: 6,
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius:
                              BorderRadius.circular(circularBorderRadius5),
                          child: Hero(
                            transitionOnUserGestures: true,
                            tag:
                                '$heroTagUniqueString$from$index${productList[index].id}0',
                            child: DesignConfiguration.getCacheNotworkImage(
                              boxFit: BoxFit.cover,
                              context: context,
                              heightvalue: double.maxFinite,
                              widthvalue: double.maxFinite,
                              placeHolderSize: width,
                              imageurlString: productList[index].image!,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: CustomFevoriteButtonForCart(model: productList[index])
                          ),
                        if (productList[index].noOfRating! !=
                            '0')
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: RatingCartForProduct(noOfRating: productList[index].noOfRating!, totalRating: productList[index].rating!)
                          ),
                      ],
                    )),
                const Divider(
                  thickness: 0.5,
                  height: 0,
                ),
                Expanded(
                    flex: 2,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 145,
                          padding: const EdgeInsetsDirectional.only(
                            start: 10.0,
                            top: 8,
                          ),
                          child: Text(
                            productList[index].name!,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall!
                                .copyWith(
                                  color:
                                      Theme.of(context).colorScheme.fontColor,
                                  fontSize: textFontSize12,
                                  fontWeight: FontWeight.w400,
                                  fontFamily: 'ubuntu',
                                  fontStyle: FontStyle.normal,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsetsDirectional.only(
                              start: 5.0, top: 5, bottom: 10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                ' ${DesignConfiguration.getPriceFormat(context, price)!}',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontSize: textFontSize14,
                                  fontWeight: FontWeight.w700,
                                  fontStyle: FontStyle.normal,
                                  fontFamily: 'ubuntu',
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsetsDirectional.only(
                                    start: 5.0,
                                    // top: 5,
                                  ),
                                  child: Row(
                                    children: <Widget>[
                                      Text(
                                        double.parse(productList[index]
                                                    .prVarientList![0]
                                                    .disPrice!) !=
                                                0
                                            ? '${DesignConfiguration.getPriceFormat(context, double.parse(productList[index].prVarientList![0].price!))}'
                                            : '',
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelSmall!
                                            .copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .lightBlack,
                                              fontFamily: 'ubuntu',
                                              decoration:
                                                  TextDecoration.lineThrough,
                                              decorationColor:
                                                  colors.darkColor3,
                                              decorationStyle:
                                                  TextDecorationStyle.solid,
                                              decorationThickness: 2,
                                              letterSpacing: 0,
                                              fontSize: textFontSize10,
                                              fontWeight: FontWeight.w400,
                                              fontStyle: FontStyle.normal,
                                            ),
                                      ),
                                      Text(
                                        offPer != null ? '  $offPer%' : ' ',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelSmall!
                                            .copyWith(
                                              fontFamily: 'ubuntu',
                                              color: colors.green,
                                              letterSpacing: 0,
                                              fontSize: textFontSize10,
                                              fontWeight: FontWeight.w400,
                                              fontStyle: FontStyle.normal,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ))
              ],
            ),
            onTap: () {
              Product model = productList[index];
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => ProductDetail(
                    model: model,
                    secPos: 0,
                    index: index,
                    list: false,
                  ),
                ),
              );
            },
          ),
        ),
      );
    } else {
      return const SizedBox();
    }
  }
}
