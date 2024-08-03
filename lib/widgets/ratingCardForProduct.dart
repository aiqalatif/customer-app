import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:eshop_multivendor/Helper/Constant.dart';
import 'package:flutter/material.dart';

class RatingCartForProduct extends StatelessWidget {
  String totalRating;
  String noOfRating;
  RatingCartForProduct(
      {Key? key, required this.noOfRating, required this.totalRating})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.only(right: 5, bottom: 5, top: 5),
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.white,
          border:
              Border.all(color: Theme.of(context).colorScheme.gray, width: 1),
          borderRadius: const BorderRadiusDirectional.all(
            Radius.circular(circularBorderRadius7),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Icon(
              Icons.star_rate,
              size: 15,
              color: colors.primary,
            ),
            Text(
              ' $totalRating',
              style: const TextStyle(fontSize: textFontSize11),
            ),
            Text(
              ' | $noOfRating',
              style: const TextStyle(fontSize: textFontSize11),
            ),
          ],
        ));
  }
}
