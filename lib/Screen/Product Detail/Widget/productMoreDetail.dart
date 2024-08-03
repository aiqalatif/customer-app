import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:eshop_multivendor/widgets/desing.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../Helper/Constant.dart';
import '../../../Helper/String.dart';
import '../../../Model/Section_Model.dart';
import '../../../Provider/productDetailProvider.dart';
import '../../Language/languageSettings.dart';

// ignore: must_be_immutable
class ProductMoreDetail extends StatelessWidget {
  Product? model;
  Function update;
  ProductMoreDetail({Key? key, this.model, required this.update})
      : super(key: key);

  _desc(Product? model, BuildContext context) {
    return model!.desc != '' && model.desc != null
        ? Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: HtmlWidget(
                model.desc!,
                onTapUrl: (String? url) async {
                  if (await canLaunchUrl(Uri.parse(url!))) {
                    await launchUrl(Uri.parse(url));
                    return true;
                  } else {
                    throw 'Could not launch $url';
                  }
                },
                onErrorBuilder: (context, element, error) =>
                    Text('$element error: $error'),
                onLoadingBuilder: (context, element, loadingProgress) =>
                    DesignConfiguration.showCircularProgress(
                        true, Theme.of(context).primaryColor),
                renderMode: RenderMode.column,
              ),
            ),
          )
        : const SizedBox();
  }

  _attr(Product? model) {
    return model!.attributeList!.isNotEmpty
        ? ListView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: model.attributeList!.length,
            itemBuilder: (context, i) {
              return Padding(
                padding: EdgeInsetsDirectional.only(
                    start: 25.0,
                    top: 10.0,
                    bottom: model.madein != '' && model.madein!.isNotEmpty
                        ? 0.0
                        : 7.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 1,
                      child: Text(
                        model.attributeList![i].name!,
                        style: Theme.of(context).textTheme.titleSmall!.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .fontColor
                                  .withOpacity(0.7),
                            ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsetsDirectional.only(start: 5.0),
                        child: Text(
                          model.attributeList![i].value!,
                          textAlign: TextAlign.start,
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall!
                              .copyWith(
                                color: Theme.of(context).colorScheme.lightBlack,
                              ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          )
        : const SizedBox();
  }

  _madeIn(Product? model, BuildContext context) {
    String? madeIn = model!.madein;

    return madeIn != '' && madeIn!.isNotEmpty
        ? Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ListTile(
              trailing: Text(madeIn),
              dense: true,
              title: Text(
                getTranslated(context, 'MADE_IN'),
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
          )
        : const SizedBox();
  }

  @override
  Widget build(BuildContext context) {
    return model!.attributeList!.isNotEmpty ||
            (model!.desc != '' && model!.desc != null) ||
            model!.madein != '' && model!.madein!.isNotEmpty
        ? Container(
            color: Theme.of(context).colorScheme.white,
            padding: const EdgeInsets.only(top: 10.0),
            child: InkWell(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsetsDirectional.only(
                      start: 15.0,
                      end: 15.0,
                      bottom: 15,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          getTranslated(context, 'Product Details'),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Ubuntu',
                            fontStyle: FontStyle.normal,
                            fontSize: textFontSize16,
                            color: Theme.of(context).colorScheme.fontColor,
                          ),
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              !context.read<ProductDetailProvider>().seeView
                                  ? Icons.add
                                  : Icons.remove,
                              size: 18,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            InkWell(
                              child: Text(
                                !context.read<ProductDetailProvider>().seeView
                                    ? getTranslated(context, 'See More')
                                    : getTranslated(context, 'See Less'),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .copyWith(
                                      color: colors.primary,
                                      fontWeight: FontWeight.w400,
                                      fontFamily: 'Ubuntu',
                                      fontStyle: FontStyle.normal,
                                      fontSize: textFontSize14,
                                    ),
                              ),
                              onTap: () {
                                context.read<ProductDetailProvider>().seeView =
                                    !context
                                        .read<ProductDetailProvider>()
                                        .seeView;

                                update();
                              },
                            ),
                            // Icon(
                            //   Icons.keyboard_arrow_right,
                            //   size: 18,
                            //   color: Theme.of(context).colorScheme.primary,
                            // ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  !context.read<ProductDetailProvider>().seeView
                      ? Container(
                          padding: EdgeInsets.only(bottom: 15),
                          height: 100,
                          width: deviceWidth! - 10,
                          child: SingleChildScrollView(
                            physics: const NeverScrollableScrollPhysics(),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _desc(model, context),
                                model!.desc != '' && model!.desc != null
                                    ? const Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 10.0,
                                        ),
                                        child: Divider(
                                          height: 3.0,
                                        ),
                                      )
                                    : const SizedBox(),
                                _attr(model),
                                model!.madein != '' && model!.madein!.isNotEmpty
                                    ? const Divider()
                                    : const SizedBox(),
                                _madeIn(model, context),
                              ],
                            ),
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.only(left: 5.0, right: 5.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _desc(model, context),
                              // model!.desc != '' && model!.desc != null
                              //     ? const Divider(
                              //         height: 3.0,
                              //       )
                              //     : const SizedBox(),
                              _attr(model),
                              model!.madein != '' && model!.madein!.isNotEmpty
                                  ? const Divider()
                                  : const SizedBox(),
                              _madeIn(model, context),
                            ],
                          ),
                        ),
                  // Row(
                  //   children: [
                  //     InkWell(
                  //       child: Padding(
                  //         padding: const EdgeInsetsDirectional.only(
                  //             start: 15, top: 10, end: 2, bottom: 15),
                  //         child: Text(
                  //           !context.read<ProductDetailProvider>().seeView
                  //               ? getTranslated(context, 'See More'): getTranslated(context, 'See Less'),
                  //           style:
                  //               Theme.of(context).textTheme.bodySmall!.copyWith(
                  //                     color: colors.primary,
                  //                     fontWeight: FontWeight.w400,
                  //                     fontFamily: 'Ubuntu',
                  //                     fontStyle: FontStyle.normal,
                  //                     fontSize: textFontSize14,
                  //                   ),
                  //         ),
                  //       ),
                  //       onTap: () {
                  //         context.read<ProductDetailProvider>().seeView =
                  //             !context.read<ProductDetailProvider>().seeView;

                  //         update();
                  //       },
                  //     ),
                  //     Icon(
                  //       Icons.keyboard_arrow_right,
                  //       size: 18,
                  //       color: Theme.of(context).colorScheme.primary,
                  //     ),
                  //   ],
                  // ),
                ],
              ),
            ),
          )
        : const SizedBox();
  }
}
