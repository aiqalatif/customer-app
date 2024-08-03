import 'dart:io';

import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:external_path/external_path.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../../../Helper/Constant.dart';
import '../../../Helper/String.dart';
import '../../../Helper/routes.dart';
import '../../../Model/Order_Model.dart';
import '../../../Provider/Order/UpdateOrderProvider.dart';
import '../../../widgets/desing.dart';
import '../../Language/languageSettings.dart';
import '../../../widgets/snackbar.dart';
import 'BottomSheetWidget.dart';
import 'OrderStatusData.dart';

class ProductItemWidget extends StatefulWidget {
  OrderItem orderItem;
  OrderModel model;
  String id;
  Function updateNow;

  ProductItemWidget({
    Key? key,
    required this.id,
    required this.model,
    required this.orderItem,
    required this.updateNow,
  }) : super(key: key);

  @override
  State<ProductItemWidget> createState() => _ProductItemWidgetState();
}

class _ProductItemWidgetState extends State<ProductItemWidget> {
  String filePath = '';
  List<String> statusList = [
    'awaiting',
    'received',
    'processed',
    'shipped',
    'delivered',
    'cancelled',
    'returned'
  ];

  setSanckBarNow(String msg) {
    setSnackbar(msg, context);
    context.read<UpdateOrdProvider>().reviewPhotos.clear();
    context.read<UpdateOrdProvider>().changeStatus(UpdateOrdStatus.isSuccsess);
  }

  @override
  Widget build(BuildContext context) {
    String? pDate,
        prDate,
        sDate,
        dDate,
        cDate,
        rDate,
        aDate,
        repDate,
        reapDate,
        redDate;

    if (widget.orderItem.listStatus!.contains(WAITING)) {
      aDate = widget
          .orderItem.listDate![widget.orderItem.listStatus!.indexOf(WAITING)];
    }
    if (widget.orderItem.listStatus!.contains(PLACED)) {
      pDate = widget
          .orderItem.listDate![widget.orderItem.listStatus!.indexOf(PLACED)];
    }
    if (widget.orderItem.listStatus!.contains(PROCESSED)) {
      prDate = widget
          .orderItem.listDate![widget.orderItem.listStatus!.indexOf(PROCESSED)];
    }
    if (widget.orderItem.listStatus!.contains(SHIPED)) {
      sDate = widget
          .orderItem.listDate![widget.orderItem.listStatus!.indexOf(SHIPED)];
    }
    if (widget.orderItem.listStatus!.contains(DELIVERD)) {
      dDate = widget
          .orderItem.listDate![widget.orderItem.listStatus!.indexOf(DELIVERD)];
    }
    if (widget.orderItem.listStatus!.contains(CANCLED)) {
      cDate = widget
          .orderItem.listDate![widget.orderItem.listStatus!.indexOf(CANCLED)];
    }
    if (widget.orderItem.listStatus!.contains(RETURNED)) {
      rDate = widget
          .orderItem.listDate![widget.orderItem.listStatus!.indexOf(RETURNED)];
    }
    if (widget.orderItem.listStatus!.contains(RETURN_REQ_PENDING)) {
      repDate = widget.orderItem
          .listDate![widget.orderItem.listStatus!.indexOf(RETURN_REQ_PENDING)];
    }
    if (widget.orderItem.listStatus!.contains(RETURN_REQ_APPROVED)) {
      reapDate = widget.orderItem
          .listDate![widget.orderItem.listStatus!.indexOf(RETURN_REQ_APPROVED)];
    }
    if (widget.orderItem.listStatus!.contains(RETURN_REQ_DECLINE)) {
      redDate = widget.orderItem
          .listDate![widget.orderItem.listStatus!.indexOf(RETURN_REQ_DECLINE)];
    }
    List att = [], val = [];
    if (widget.orderItem.attr_name!.isNotEmpty) {
      att = widget.orderItem.attr_name!.split(',');
      val = widget.orderItem.varient_values!.split(',');
    }

    int caclabelTillIndex = statusList
        .indexWhere((element) => element == widget.orderItem.canclableTill);

    int curStatusIndex =
        statusList.indexWhere((element) => element == widget.orderItem.status);

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(circularBorderRadius7),
                  child: DesignConfiguration.getCacheNotworkImage(
                    boxFit: BoxFit.cover,
                    context: context,
                    heightvalue: 90.0,
                    widthvalue: 90.0,
                    imageurlString: widget.orderItem.image!,
                    placeHolderSize: 90,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.orderItem.name!,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium!
                              .copyWith(
                                  color:
                                      Theme.of(context).colorScheme.lightBlack,
                                  fontWeight: FontWeight.normal),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        widget.orderItem.attr_name!.isNotEmpty
                            ? ListView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: att.length,
                                itemBuilder: (context, index) {
                                  return Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          att[index].trim() + ':',
                                          overflow: TextOverflow.ellipsis,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleSmall!
                                              .copyWith(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .lightBlack2),
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsetsDirectional.only(
                                                start: 5.0),
                                        child: Text(
                                          val[index],
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleSmall!
                                              .copyWith(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .lightBlack,
                                              ),
                                        ),
                                      )
                                    ],
                                  );
                                },
                              )
                            : const SizedBox(),
                        Row(
                          children: [
                            Text(
                              '${getTranslated(context, 'QUANTITY_LBL')}:',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall!
                                  .copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .lightBlack2),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsetsDirectional.only(start: 5.0),
                              child: Text(
                                widget.orderItem.qty!,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall!
                                    .copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .lightBlack,
                                    ),
                              ),
                            )
                          ],
                        ),
                        Text(
                          DesignConfiguration.getPriceFormat(
                              context, double.parse(widget.orderItem.price!))!,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium!
                              .copyWith(
                                  color: Theme.of(context).colorScheme.blue),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
            Divider(
              color: Theme.of(context).colorScheme.lightBlack,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  pDate != null
                      ? getPlaced(pDate, context)
                      : getPlaced(aDate ?? '', context),
                  widget.orderItem.productType == 'digital_product'
                      ? const SizedBox()
                      : getProcessed(prDate, cDate, context),
                  widget.orderItem.productType == 'digital_product'
                      ? const SizedBox()
                      : getShipped(sDate, cDate, context),
                  widget.orderItem.productType == 'digital_product'
                      ? const SizedBox()
                      : getDelivered(dDate, cDate, context),
                  widget.orderItem.productType == 'digital_product'
                      ? widget.orderItem.downloadAllowed == '1'
                          ? cDate == null
                              ? Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Column(
                                      children: [
                                        SizedBox(
                                          height: 30,
                                          child: VerticalDivider(
                                            thickness: 2,
                                            color: dDate == null
                                                ? Colors.grey
                                                : colors.primary,
                                          ),
                                        ),
                                        Icon(
                                          Icons.circle,
                                          color: dDate == null
                                              ? Colors.grey
                                              : colors.primary,
                                          size: 15,
                                        ),
                                      ],
                                    ),
                                    Container(
                                      margin: const EdgeInsetsDirectional.only(
                                          start: 10),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            getTranslated(
                                                context, 'ORDER_DELIVERED'),
                                            style: const TextStyle(
                                                fontSize: textFontSize8),
                                            textAlign: TextAlign.center,
                                          ),
                                          Text(
                                            dDate ?? ' ',
                                            style: const TextStyle(
                                                fontSize: textFontSize8),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                )
                              : const SizedBox()
                          : const SizedBox()
                      : const SizedBox(),
                  widget.orderItem.productType == 'digital_product'
                      ? widget.orderItem.downloadAllowed != '1'
                          ? cDate == null
                              ? Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Column(
                                      children: [
                                        SizedBox(
                                          height: 30,
                                          child: VerticalDivider(
                                            thickness: 2,
                                            color: dDate == null
                                                ? Colors.grey
                                                : colors.primary,
                                          ),
                                        ),
                                        Icon(
                                          Icons.circle,
                                          color: dDate == null
                                              ? Colors.grey
                                              : colors.primary,
                                          size: 15,
                                        ),
                                      ],
                                    ),
                                    Container(
                                      margin: const EdgeInsetsDirectional.only(
                                          start: 10),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            getTranslated(
                                                context, 'ORDER_DELIVERED'),
                                            style: const TextStyle(
                                                fontSize: textFontSize8),
                                            textAlign: TextAlign.center,
                                          ),
                                          Text(
                                            dDate ?? ' ',
                                            style: const TextStyle(
                                                fontSize: textFontSize8),
                                            textAlign: TextAlign.center,
                                          ),
                                          Text(
                                            getTranslated(context,
                                                'PLEASE_CHECK_YOUR_MAIL_FOR_INSTRUCTIONS'),
                                            style: TextStyle(
                                                fontSize: textFontSize8),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                )
                              : const SizedBox()
                          : const SizedBox()
                      : const SizedBox(),
                  getCanceled(cDate, context),
                  getReturneRequestPending(
                      widget.orderItem, repDate, widget.model, context),
                  getReturneRequestApproved(
                      widget.orderItem, reapDate, widget.model, context),
                  getReturneRequestDecline(
                      widget.orderItem, redDate, widget.model, context),
                  getReturned(widget.orderItem, rDate, widget.model, context),
                ],
              ),
            ),
            widget.orderItem.downloadAllowed == '1' &&
                    widget.orderItem.status == DELIVERD
                ? downloadProductFile(context, widget.orderItem.id!)
                : const SizedBox(),
            Divider(
              color: Theme.of(context).colorScheme.lightBlack,
            ),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${getTranslated(context, "STORE_NAME")} : ",
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.lightBlack,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "${getTranslated(context, "OTP")} : ",
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.lightBlack,
                            fontWeight: FontWeight.bold),
                      ),
                      widget.orderItem.courier_agency! != ''
                          ? Text(
                              "${getTranslated(context, 'COURIER_AGENCY')}: ",
                              style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.lightBlack,
                                  fontWeight: FontWeight.bold),
                            )
                          : const SizedBox(),
                      widget.orderItem.tracking_id! != ''
                          ? Text(
                              "${getTranslated(context, 'TRACKING_ID')}: ",
                              style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.lightBlack,
                                  fontWeight: FontWeight.bold),
                            )
                          : const SizedBox(),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        child: Text(
                          '${widget.orderItem.store_name}',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.lightBlack2,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        onTap: () {
                          print(widget.orderItem.seller_name);
                          print(widget.orderItem.seller_no_of_ratings);
                          Routes.navigateToSellerProfileScreen(
                            context,
                            widget.orderItem.seller_id,
                            widget.orderItem.seller_profile,
                            widget.orderItem.seller_name,
                            widget.orderItem.seller_rating,
                            widget.orderItem.seller_name,
                            widget.orderItem.store_description,
                            '0',
                            widget.orderItem.seller_no_of_ratings,
                          );
                        },
                      ),
                      Text(
                        '${widget.orderItem.item_otp} ',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.lightBlack2,
                        ),
                      ),
                      widget.orderItem.courier_agency! != ''
                          ? Text(
                              widget.orderItem.courier_agency!,
                              style: TextStyle(
                                color:
                                    Theme.of(context).colorScheme.lightBlack2,
                              ),
                            )
                          : const SizedBox(),
                      widget.orderItem.tracking_id! != ''
                          ? RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: '',
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .lightBlack,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  TextSpan(
                                    text: widget.orderItem.tracking_id!,
                                    style: const TextStyle(
                                        color: colors.primary,
                                        decoration: TextDecoration.underline),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () async {
                                        var url =
                                            '${widget.orderItem.tracking_url}';

                                        if (await canLaunchUrlString(url)) {
                                          await launchUrlString(url);
                                        } else {
                                          setSnackbar(
                                              getTranslated(
                                                  context, 'URL_ERROR'),
                                              context);
                                        }
                                      },
                                  )
                                ],
                              ),
                            )
                          : const SizedBox(),
                    ],
                  ),
                ),
              ],
            ),
            // Consumer<UpdateOrdProvider>(
            //   builder: (context, value, child) {
            //     return Container(
            //       padding: const EdgeInsetsDirectional.only(
            //         start: 20.0,
            //         end: 20.0,
            //         top: 5,
            //       ),
            //       height: value.files.isNotEmpty ? 180 : 0,
            //       child: Row(
            //         children: [
            //           Expanded(
            //             child: ListView.builder(
            //               shrinkWrap: true,
            //               itemCount: value.files.length,
            //               scrollDirection: Axis.horizontal,
            //               itemBuilder: (context, i) {
            //                 return InkWell(
            //                   child: Stack(
            //                     alignment: AlignmentDirectional.topEnd,
            //                     children: [
            //                       Image.file(
            //                         value.files[i],
            //                         width: 180,
            //                         height: 180,
            //                       ),
            //                       Container(
            //                         color:
            //                             Theme.of(context).colorScheme.black26,
            //                         child: const Icon(
            //                           Icons.clear,
            //                           size: 15,
            //                         ),
            //                       ),
            //                     ],
            //                   ),
            //                   onTap: () {
            //                     setState(() {
            //                       value.files.removeAt(i);
            //                     });
            //                   },
            //                 );
            //               },
            //             ),
            //           ),
            //           InkWell(
            //             child: Container(
            //               padding: const EdgeInsets.symmetric(
            //                   horizontal: 10, vertical: 2),
            //               decoration: BoxDecoration(
            //                 color: Theme.of(context).colorScheme.lightWhite,
            //                 borderRadius: const BorderRadius.all(
            //                   Radius.circular(circularBorderRadius4),
            //                 ),
            //               ),
            //               child: Text(
            //                 getTranslated(context, 'SUBMIT_LBL')!,
            //                 style: TextStyle(
            //                     color: Theme.of(context).colorScheme.fontColor),
            //               ),
            //             ),
            //             onTap: () {
            //               if (value.getCurrentStatus !=
            //                   UpdateOrdStatus.inProgress) {
            //                 Future.delayed(Duration.zero).then(
            //                   (value) => context
            //                       .read<UpdateOrdProvider>()
            //                       .sendBankProof(widget.id, context),
            //                 );
            //               }
            //             },
            //           ),
            //         ],
            //       ),
            //     );
            //   },
            // ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (widget.orderItem.status == DELIVERD)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        openBottomSheet(
                          context,
                          widget.orderItem,
                          setSanckBarNow,
                        );
                      },
                      icon: const Icon(Icons.rate_review_outlined,
                          color: colors.primary),
                      label: Text(
                        widget.orderItem.userReviewRating != '0'
                            ? getTranslated(context, 'UPDATE_REVIEW_LBL'): getTranslated(context, 'WRITE_REVIEW_LBL'),
                        style: const TextStyle(color: colors.primary),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                            color: Theme.of(context).colorScheme.btnColor),
                      ),
                    ),
                  ),
                if (!widget.orderItem.listStatus!.contains(DELIVERD) &&
                    (!widget.orderItem.listStatus!.contains(RETURNED)) &&
                    widget.orderItem.isCancle == '1' &&
                    widget.orderItem.isAlrCancelled == '0' &&
                    curStatusIndex <= caclabelTillIndex)
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: OutlinedButton(
                        onPressed: context
                                .read<UpdateOrdProvider>()
                                .isReturnClick
                            ? () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext cxt) {
                                    return AlertDialog(
                                      title: Text(
                                        getTranslated(cxt, 'ARE_YOU_SURE?'),
                                        style: TextStyle(
                                            color: Theme.of(cxt)
                                                .colorScheme
                                                .fontColor),
                                      ),
                                      content: Text(
                                        getTranslated(cxt,
                                            'Would you like to cancel this product?'),
                                        style: TextStyle(
                                          color: Theme.of(cxt)
                                              .colorScheme
                                              .fontColor,
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          child: Text(
                                            getTranslated(cxt, 'YES'),
                                            style: const TextStyle(
                                                color: colors.primary),
                                          ),
                                          onPressed: () {
                                            Routes.pop(cxt);

                                            cxt
                                                .read<UpdateOrdProvider>()
                                                .isReturnClick = false;
                                            cxt
                                                .read<UpdateOrdProvider>()
                                                .changeStatus(
                                                    UpdateOrdStatus.inProgress);
                                            /* setSnackbar(
                                                getTranslated(context,
                                                    'Status Updated Successfully')!,
                                                context);*/
                                            /*Future.delayed(Duration.zero).then(
                                              (value) => */
                                            cxt
                                                .read<UpdateOrdProvider>()
                                                .cancelOrder(
                                                    widget.orderItem.id!,
                                                    updateOrderItemApi,
                                                    CANCLED,
                                                    context);
                                            widget.updateNow();
                                            /*  ),
                                            );*/
                                          },
                                        ),
                                        TextButton(
                                          child: Text(
                                            getTranslated(cxt, 'NO'),
                                            style: const TextStyle(
                                                color: colors.primary),
                                          ),
                                          onPressed: () {
                                            Routes.pop(cxt);
                                            /* context
                                                .read<UpdateOrdProvider>()
                                                .changeStatus(UpdateOrdStatus.inProgress);*/
                                            setState(() {});
                                          },
                                        )
                                      ],
                                    );
                                  },
                                );
                              }
                            : null,
                        child: Text(
                          getTranslated(context, 'ITEM_CANCEL'),
                        ),
                      ),
                    ),
                  )
                else
                  ((widget.orderItem.listStatus!.contains(DELIVERD) &&
                              widget.orderItem.productType !=
                                  'digital_product') &&
                          widget.orderItem.isReturn == '1' &&
                          widget.orderItem.isAlrReturned == '0' &&
                          (!widget.orderItem.listStatus!
                                  .contains(RETURN_REQ_DECLINE) &&
                              !widget.orderItem.listStatus!
                                  .contains(RETURN_REQ_APPROVED) &&
                              !widget.orderItem.listStatus!
                                  .contains(RETURN_REQ_PENDING)))
                      ? Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: OutlinedButton(
                            onPressed: context
                                    .read<UpdateOrdProvider>()
                                    .isReturnClick
                                ? () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext ctx) {
                                        return AlertDialog(
                                          title: Text(
                                            getTranslated(
                                                ctx, 'ARE_YOU_SURE?'),
                                            style: TextStyle(
                                                color: Theme.of(ctx)
                                                    .colorScheme
                                                    .fontColor),
                                          ),
                                          content: Text(
                                            getTranslated(ctx,
                                                'WOULD_RETURN_PRODUCT_LBL'),
                                            style: TextStyle(
                                                color: Theme.of(ctx)
                                                    .colorScheme
                                                    .fontColor),
                                          ),
                                          actions: [
                                            TextButton(
                                              child: Text(
                                                getTranslated(ctx, 'YES'),
                                                style: const TextStyle(
                                                    color: colors.primary),
                                              ),
                                              onPressed: () {
                                                Routes.pop(ctx);
                                                ctx
                                                    .read<UpdateOrdProvider>()
                                                    .isReturnClick = false;
                                                ctx
                                                    .read<UpdateOrdProvider>()
                                                    .changeStatus(
                                                        UpdateOrdStatus
                                                            .inProgress);

                                                ctx
                                                    .read<UpdateOrdProvider>()
                                                    .cancelOrder(
                                                      widget.orderItem.id!,
                                                      updateOrderItemApi,
                                                      RETURNED,
                                                      context,
                                                    );

                                                widget.updateNow();
                                              },
                                            ),
                                            TextButton(
                                              child: Text(
                                                getTranslated(ctx, 'NO'),
                                                style: const TextStyle(
                                                    color: colors.primary),
                                              ),
                                              onPressed: () {
                                                Routes.pop(ctx);
                                              },
                                            )
                                          ],
                                        );
                                      },
                                    );
                                  }
                                : null,
                            child: Text(getTranslated(context, 'ITEM_RETURN')),
                          ),
                        )
                      : const SizedBox(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> Checkpermission(AsyncSnapshot snapshot) async {
    var status = await Permission.storage.status;

    if (status != PermissionStatus.granted) {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.storage,
      ].request();

      if (statuses[Permission.storage] == PermissionStatus.granted) {
        FileDirectoryPrepare(snapshot);
        return true;
      }
    } else {
      FileDirectoryPrepare(snapshot);
      return true;
    }
    return false;
  }

  Future<void> FileDirectoryPrepare(AsyncSnapshot snapshot) async {
    if (Platform.isIOS) {
      Directory target = await getApplicationDocumentsDirectory();
      filePath = target.path.toString();
    } else {
      if (snapshot.hasData) {
        filePath = (snapshot.data as List<Directory>).first.path;
      }
    }
  }

  Future<bool> checkPermission() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      var result = await Permission.storage.request();
      if (result.isGranted) {
        return true;
      } else {
        return false;
      }
    } else {
      return true;
    }
  }

  downloadProductFile(BuildContext context, String orderiteamID) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () async {
              context
                  .read<UpdateOrdProvider>()
                  .getDownloadLink(
                    context,
                    orderiteamID,
                  )
                  .then((value) async {
                if (!value) {
                  if (context
                          .read<UpdateOrdProvider>()
                          .currentLinkForDownload !=
                      '') {
                    bool hasPermission = await checkPermission();

                    String target = Platform.isAndroid && hasPermission
                        ? (await ExternalPath.getExternalStoragePublicDirectory(
                            ExternalPath.DIRECTORY_DOWNLOADS,
                          ))
                        : (await getApplicationDocumentsDirectory()).path;

                    String fileName = context
                        .read<UpdateOrdProvider>()
                        .currentLinkForDownload
                        .substring(context
                                .read<UpdateOrdProvider>()
                                .currentLinkForDownload
                                .lastIndexOf('/') +
                            1);
                    String filePath = '$target/$fileName';

                    File file = File(filePath);
                    bool hasExisted = await file.exists();

                    if (hasExisted) {
                      await OpenFilex.open(filePath);
                    }

                    setSnackbar(
                        getTranslated(context, 'Downloading'), context);
                    await FlutterDownloader.enqueue(
                      url: context
                          .read<UpdateOrdProvider>()
                          .currentLinkForDownload,
                      savedDir: target,
                      fileName: fileName,
                      // headers: {'auth': 'test_for_sql_encoding'},
                      showNotification: true,
                      openFileFromNotification: true,
                    ).onError((error, stackTrace) {
                      setSnackbar('Error: $error', context);
                      return null;
                    }).catchError((error, stackTrace) {
                      context
                          .read<UpdateOrdProvider>()
                          .changeStatus(UpdateOrdStatus.isSuccsess);
                      // Handle error appropriately
                    }).whenComplete(() {
                      context
                          .read<UpdateOrdProvider>()
                          .changeStatus(UpdateOrdStatus.isSuccsess);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            getTranslated(context, 'OPEN_DOWNLOAD_FILE_LBL'),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.black),
                          ),
                          action: SnackBarAction(
                            label: getTranslated(context, 'VIEW'),
                            textColor: Theme.of(context).colorScheme.fontColor,
                            onPressed: () async {
                              await OpenFilex.open(filePath);
                            },
                          ),
                          backgroundColor: Theme.of(context).colorScheme.white,
                          elevation: 1.0,
                        ),
                      );

                      context
                          .read<UpdateOrdProvider>()
                          .cancelOrder(
                            widget.orderItem.id!,
                            updateOrderItemApi,
                            'delivered',
                            context,
                          )
                          .then(
                            (value) {},
                          );

                      // You can add code to handle completion here.
                    });
                  } else {
                    context
                        .read<UpdateOrdProvider>()
                        .changeStatus(UpdateOrdStatus.isSuccsess);
                    setSnackbar(
                        'something wrong file is not available yet .', context);
                  }
                }
              });
            },
            icon: const Icon(Icons.download, color: colors.primary),
            label: Text(
              getTranslated(context, 'DOWNLOAD'),
              style: const TextStyle(color: colors.primary),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Theme.of(context).colorScheme.btnColor),
            ),
          ),
        ),
      ],
    );
  }

/*downloadProductFile(BuildContext context, String orderiteamID) {
    return FutureBuilder<List<Directory>?>(
      future: context.read<UpdateOrdProvider>().externalStorageDirectories,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        return Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () async {
                  context
                      .read<UpdateOrdProvider>()
                      .getDownloadLink(
                        context,
                        orderiteamID,
                      )
                      .then(
                    (value) async {
                      if (!value) {
                        if (context
                                .read<UpdateOrdProvider>()
                                .currentLinkForDownload !=
                            '') {
                          context
                              .read<UpdateOrdProvider>()
                              .changeStatus(UpdateOrdStatus.inProgress);
                          bool checkpermission =
                              await Checkpermission(snapshot);
                          if (checkpermission) {
                            if (Platform.isIOS) {
                              Directory target =
                                  await getApplicationDocumentsDirectory();
                              filePath = target.path.toString();
                            } else {
                              final externalDirectory =
                                  await getExternalStorageDirectory();
                              var dir = await Directory(
                                      '${externalDirectory!.path}/Download')
                                  .create();
                              if (snapshot.hasData) {
                                filePath = dir.path;
                                // snapshot.data!
                                //     .map((Directory d) => d.path)
                                //     .join(', ');
                              }
                            }
                            String fileName = context
                                .read<UpdateOrdProvider>()
                                .currentLinkForDownload
                                .substring(context
                                        .read<UpdateOrdProvider>()
                                        .currentLinkForDownload
                                        .lastIndexOf('/') +
                                    1);
                            File file = File('$filePath/$fileName');
                            bool hasExisted = await file.exists();
                            if (hasExisted) {
                              final openFile =
                                  await OpenFilex.open('$filePath/$fileName');
                            }
                            setSnackbar(getTranslated(context, 'Downloading')!,
                                context);
                            final taskid = await FlutterDownloader.enqueue(
                              url: context
                                  .read<UpdateOrdProvider>()
                                  .currentLinkForDownload,
                              savedDir: filePath,
                              headers: {'auth': 'test_for_sql_encoding'},
                              showNotification: true,
                              openFileFromNotification: true,
                            ).onError((error, stackTrace) {
                              context
                                  .read<UpdateOrdProvider>()
                                  .changeStatus(UpdateOrdStatus.isSuccsess);
                              setSnackbar('Error : $error', context);
                              return null;
                            }).catchError((error, stackTrace) {
                              context
                                  .read<UpdateOrdProvider>()
                                  .changeStatus(UpdateOrdStatus.isSuccsess);
                            }).whenComplete(() {
                              context
                                  .read<UpdateOrdProvider>()
                                  .changeStatus(UpdateOrdStatus.isSuccsess);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    getTranslated(
                                        context, 'OPEN_DOWNLOAD_FILE_LBL')!,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .black),
                                  ),
                                  action: SnackBarAction(
                                    label: getTranslated(context, 'VIEW')!,
                                    textColor:
                                        Theme.of(context).colorScheme.fontColor,
                                    onPressed: () async {
                                      await OpenFilex.open(filePath);
                                    },
                                  ),
                                  backgroundColor:
                                      Theme.of(context).colorScheme.white,
                                  elevation: 1.0,
                                ),
                              );
                              context
                                  .read<UpdateOrdProvider>()
                                  .cancelOrder(
                                    widget.orderItem.id!,
                                    updateOrderItemApi,
                                    'delivered',
                                    context,
                                  )
                                  .then(
                                    (value) {},
                                  );
                            });
                          } else {
                            // ignore: use_build_context_synchronously
                            context
                                .read<UpdateOrdProvider>()
                                .changeStatus(UpdateOrdStatus.isSuccsess);
                            setSnackbar('permission is not given for download.',
                                context);
                          }
                        } else {
                          setSnackbar(
                              'something wrong file is not available yet .',
                              context);
                        }
                      }
                    },
                  );
                },
                icon: const Icon(Icons.download, color: colors.primary),
                label: const Text(
                  'Download',
                  style: TextStyle(color: colors.primary),
                ),
                style: OutlinedButton.styleFrom(
                  side:
                      BorderSide(color: Theme.of(context).colorScheme.btnColor),
                ),
              ),
            ),
          ],
        );
      },
    );
  }*/
}
