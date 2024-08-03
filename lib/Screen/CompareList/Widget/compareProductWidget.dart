import 'package:eshop_multivendor/Helper/String.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../../../Helper/Color.dart';
import '../../../Helper/Constant.dart';
import '../../../Model/Section_Model.dart';
import '../../../widgets/desing.dart';
import '../../Language/languageSettings.dart';

// ignore: must_be_immutable
class OutOffStockLableWidget extends StatelessWidget {
  String? availability;
  OutOffStockLableWidget({Key? key, this.availability}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.center,
      child: availability == '0'
          ? Container(
              color: colors.white70,
              padding: const EdgeInsets.all(2),
              child: Text(
                getTranslated(context, 'OUT_OF_STOCK_LBL'),
                style: Theme.of(context).textTheme.titleSmall!.copyWith(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'ubuntu',
                    ),
              ),
            )
          : const SizedBox(),
    );
  }
}

getRattingIcons(BuildContext context, String? rating) {
  return Padding(
    padding: const EdgeInsets.only(top: 8.0),
    child: RatingBarIndicator(
      rating: double.parse(rating!),
      itemBuilder: (context, index) => const Icon(
        Icons.star,
        color: colors.primary,
      ),
      itemCount: 5,
      itemSize: 12.0,
      direction: Axis.horizontal,
    ),
  );
}

commanField(String? madeIn, String heading, BuildContext context) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 5.0),
    child: Row(
      children: [
        Expanded(
          child: Text(
            heading,
            style: Theme.of(context).textTheme.titleSmall!.copyWith(
                  fontFamily: 'ubuntu',
                ),
          ),
        ),
        Expanded(
          child: Text(
            madeIn != '' && madeIn!.isNotEmpty ? madeIn : '-',
            maxLines: 1,
            softWrap: true,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'ubuntu',
            ),
          ),
        ),
      ],
    ),
  );
}

isCancelable(String? pos, BuildContext context) {
  return Padding(
    padding:
        const EdgeInsetsDirectional.only(start: 5.0, end: 5.0, bottom: 10.0),
    child: Row(
      children: [
        Expanded(
          child: Text(
            getTranslated(context, 'CANCELLABLE'),
            style: Theme.of(context).textTheme.titleSmall!.copyWith(
                  fontFamily: 'ubuntu',
                ),
          ),
        ),
        Expanded(
          child: Text(
            pos ?? '-',
            maxLines: 1,
            softWrap: true,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'ubuntu',
            ),
          ),
        ),
      ],
    ),
  );
}

isReturnable(String? returnable, BuildContext context) {
  if (returnable == '1') {
    returnable = '${RETURN_DAYS!} Days';
  } else {
    returnable = 'No';
  }
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 5.0),
    child: Row(
      children: [
        Expanded(
          child: Text(
            getTranslated(context, 'RETURNABLE'),
            style: Theme.of(context).textTheme.titleSmall!.copyWith(
                  fontFamily: 'ubuntu',
                ),
          ),
        ),
        Expanded(
          child: Text(
            returnable,
            style: const TextStyle(
              fontFamily: 'ubuntu',
            ),
          ),
        ),
      ],
    ),
  );
}

getImagePart(String? image, int index, String? id, BuildContext context) {
  return Hero(
    tag: '$heroTagUniqueString$heroTagUniqueString$index${id}0',
    child: ClipRRect(
      // borderRadius: const BorderRadius.only(
      //   topLeft: Radius.circular(circularBorderRadius5),
      //   topRight: Radius.circular(circularBorderRadius5),
      // ),
      child: DesignConfiguration.getCacheNotworkImage(
        boxFit: BoxFit.cover,
        context: context,
        heightvalue: 150,
        widthvalue: 150,
        placeHolderSize: deviceWidth! * 0.5,
        imageurlString: image!,
      ),
    ),
  );
}

getPriceFields(
  Product model,
  BuildContext context,
  double price,
) {
  return Padding(
    padding: const EdgeInsetsDirectional.only(start: 5.0, bottom: 5),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          '${DesignConfiguration.getPriceFormat(context, price)!}',
          style: const TextStyle(
            color: colors.primary,
            fontFamily: 'ubuntu',
          ),
          
        ),
        Text(
          double.parse(model.prVarientList![model.selVarient!].disPrice!) != 0
              ? '  ${DesignConfiguration.getPriceFormat(context,
                  double.parse(model.prVarientList![model.selVarient!].price!))!}'
              : '',
          style: Theme.of(context).textTheme.labelSmall!.copyWith(
                decoration: TextDecoration.lineThrough,
                decorationColor: colors.darkColor3,
                decorationStyle: TextDecorationStyle.solid,
                decorationThickness: 2,
                letterSpacing: 1,
                fontFamily: 'ubuntu',
              ),
        ),
      ],
    ),
  );
}

getProductName(String? name) {
  return Padding(
    padding: const EdgeInsets.all(5.0),
    child: Text(
      '${name!}\n',
      textAlign: TextAlign.center,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        fontFamily: 'ubuntu',
      ),
    ),
  );
}

getListViewIteam(String attribute, String value) {
  return Row(
    children: [
      Flexible(
        child: Text(
          '$attribute:',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontFamily: 'ubuntu',
          ),
        ),
      ),
      Expanded(
        child: Padding(
          padding: const EdgeInsetsDirectional.only(start: 5.0),
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: 'ubuntu',
            ),
          ),
        ),
      )
    ],
  );
}
