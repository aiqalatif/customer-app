// ignore_for_file: must_be_immutable
import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../../Helper/Constant.dart';
import '../../../widgets/desing.dart';
import '../../Language/languageSettings.dart';

class StarRatingProductDetailPage extends StatelessWidget {
  String totalRating, noOfRatings;
  bool needToShowNoOfRatings;

  StarRatingProductDetailPage(
      {Key? key,
      required this.totalRating,
      required this.noOfRatings,
      required this.needToShowNoOfRatings})
      : super(key: key);

  getSVGImage(String svg) {
    return Padding(
      padding: const EdgeInsets.only(right: 5.0),
      child: SvgPicture.asset(
        DesignConfiguration.setSvgPath(svg),
        height: 14,
        width: 14,
      ),
    );
  }

  getHalfStar(String value) {
    return value == '1' || value == '2' || value == '3'
        ? getSVGImage('d_star')
        : value == '4' || value == '5' || value == '6'
            ? getSVGImage('c_star')
            : value == '7' || value == '8' || value == '9'
                ? getSVGImage('b_star')
                : getSVGImage('e_star');
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (int i = 0; i < 5; i++)
          totalRating[0] == '0'
              ? getHalfStar('emptystar')
              : totalRating[0] == '1'
                  ? i == 0
                      ? getSVGImage('a_star')
                      : i == 1
                          ? getHalfStar(totalRating[2])
                          : getHalfStar('emptystar')
                  : totalRating[0] == '2'
                      ? i < 2
                          ? getSVGImage('a_star')
                          : i == 2
                              ? getHalfStar(totalRating[2])
                              : getHalfStar('emptystar')
                      : totalRating[0] == '3'
                          ? i < 3
                              ? getSVGImage('a_star')
                              : i == 3
                                  ? getHalfStar(totalRating[2])
                                  : getHalfStar('emptystar')
                          : totalRating[0] == '4'
                              ? i < 4
                                  ? getSVGImage('a_star')
                                  : i == 4
                                      ? getHalfStar(totalRating[2])
                                      : getHalfStar('emptystar')
                              : totalRating[0] == '5'
                                  ? getSVGImage('a_star')
                                  : const SizedBox(),
        const SizedBox(
          width: 5.0,
        ),
        Flexible(
          child: Text(
            '$totalRating',
            style: TextStyle(
              color: Theme.of(context).colorScheme.black,
              fontWeight: FontWeight.w500,
              fontStyle: FontStyle.normal,
              fontSize: textFontSize14,
            ),
          ),
        ),
        needToShowNoOfRatings
            ? const SizedBox(
                width: 8.0,
              )
            : const SizedBox(),
        needToShowNoOfRatings
            ? Flexible(
                child: Text(
                  '|  $noOfRatings ${getTranslated(context, 'Rattings')}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.lightBlack,
                    fontWeight: FontWeight.w400,
                    fontStyle: FontStyle.normal,
                    fontSize: textFontSize12,
                  ),
                ),
              )
            : const SizedBox(),
      ],
    );
  }
}
