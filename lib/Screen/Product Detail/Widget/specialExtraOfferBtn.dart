import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../../Helper/Constant.dart';
import '../../../Helper/String.dart';
import '../../../Model/Section_Model.dart';
import '../../../widgets/desing.dart';
import '../../Language/languageSettings.dart';

class SpeciExtraBtnDetails extends StatelessWidget {
  Product? model;
  SpeciExtraBtnDetails({Key? key, this.model}) : super(key: key);

  getImageWithHeading(String image, String heading, BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(
        start: 7.0,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: const EdgeInsetsDirectional.only(bottom: 5.0),
            child: ClipRRect(
              child: SvgPicture.asset(
                DesignConfiguration.setSvgPath(image),
                height: 32.0,
                width: 32.0,
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                    Theme.of(context).colorScheme.fontColor.withOpacity(0.7),
                    BlendMode.srcIn),
              ),
            ),
          ),
          Container(
            alignment: Alignment.center,
            width: MediaQuery.of(context).size.width * (0.22),
            child: Text(
              heading,
              style: const TextStyle(
                fontSize: textFontSize12,
              ),
              //overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              maxLines: 3,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String? cod = model!.codAllowed;
    if (cod == '1') {
      cod = 'COD';
    } else {
      cod = getTranslated(context, 'COD Not Allowed');
    }

    String? cancellable = model!.isCancelable;
    if (cancellable == '1') {
      cancellable =
          '${getTranslated(context, "Cancellable Till")} ${model!.cancleTill!}';
    } else {
      cancellable = getTranslated(context, 'No Cancellable');
    }

    String? returnable = model!.isReturnable;
    if (returnable == '1') {
      returnable =
          '${RETURN_DAYS!} ${getTranslated(context, "Days Returnable")}';
    } else {
      returnable = getTranslated(context, 'No Returnable');
    }

    String? guarantee = model!.gurantee;
    String? warranty = model!.warranty;

    return Container(
      color: Theme.of(context).colorScheme.white,
      width: deviceWidth,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
        child: Row(
          children: [
            model!.codAllowed == '1'
                ? Expanded(
                    child: getImageWithHeading(
                      'cod',
                      cod,
                      context,
                    ),
                  )
                : Container(
                    width: 0,
                  ),
            Expanded(
              child: getImageWithHeading(
                model!.isCancelable == '1' ? 'cancelable' : 'notcancelable',
                cancellable,
                context,
              ),
            ),
            Expanded(
              child: getImageWithHeading(
                model!.isReturnable == '1' ? 'returnable' : 'notreturnable',
                returnable,
                context,
              ),
            ),
            guarantee != '' && guarantee!.isNotEmpty
                ? Expanded(
                    child: getImageWithHeading(
                      'guarantee',
                      '$guarantee Guarantee',
                      context,
                    ),
                  )
                : Container(
                    width: 0,
                  ),
            warranty != '' && warranty!.isNotEmpty
                ? Expanded(
                    child: getImageWithHeading(
                      'warranty',
                      '$warranty Warranty',
                      context,
                    ),
                  )
                : Container(
                    width: 0,
                  )
          ],
        ),
      ),
    );
  }
}
