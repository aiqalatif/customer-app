import 'package:flutter/material.dart';
import '../../../Helper/Color.dart';
import '../../../Helper/Constant.dart';
import '../../../Helper/String.dart';
import '../../../Model/Order_Model.dart';
import '../../Language/languageSettings.dart';

getPlaced(String pDate, BuildContext context) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      const Icon(
        Icons.circle,
        color: colors.primary,
        size: 15,
      ),
      Container(
        margin: const EdgeInsetsDirectional.only(start: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              getTranslated(context, 'ORDER_NPLACED'),
              style: const TextStyle(fontSize: textFontSize8),
            ),
            Text(
              pDate,
              style: const TextStyle(fontSize: textFontSize8),
            ),
          ],
        ),
      ),
    ],
  );
}

getProcessed(String? prDate, String? cDate, BuildContext context) {
  return cDate == null
      ? Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 30,
                  child: VerticalDivider(
                    thickness: 2,
                    color: prDate == null ? Colors.grey : colors.primary,
                  ),
                ),
                Icon(
                  Icons.circle,
                  color: prDate == null ? Colors.grey : colors.primary,
                  size: 15,
                ),
              ],
            ),
            Container(
              margin: const EdgeInsetsDirectional.only(start: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    getTranslated(context, 'ORDER_PROCESSED'),
                    style: const TextStyle(fontSize: textFontSize8),
                  ),
                  Text(
                    prDate ?? ' ',
                    style: const TextStyle(fontSize: textFontSize8),
                  ),
                ],
              ),
            ),
          ],
        )
      : prDate == null
          ? const SizedBox()
          : Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 30,
                      child: VerticalDivider(
                        thickness: 2,
                        color: colors.primary,
                      ),
                    ),
                    Icon(
                      Icons.circle,
                      color: colors.primary,
                      size: 15,
                    ),
                  ],
                ),
                Container(
                  margin: const EdgeInsetsDirectional.only(start: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        getTranslated(context, 'ORDER_PROCESSED'),
                        style: const TextStyle(fontSize: textFontSize8),
                      ),
                      Text(
                        prDate,
                        style: const TextStyle(fontSize: textFontSize8),
                      ),
                    ],
                  ),
                ),
              ],
            );
}

getShipped(
  String? sDate,
  String? cDate,
  BuildContext context,
) {
  return cDate == null
      ? Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Column(
              children: [
                SizedBox(
                  height: 30,
                  child: VerticalDivider(
                    thickness: 2,
                    color: sDate == null ? Colors.grey : colors.primary,
                  ),
                ),
                Icon(
                  Icons.circle,
                  color: sDate == null ? Colors.grey : colors.primary,
                  size: 15,
                ),
              ],
            ),
            Container(
              margin: const EdgeInsetsDirectional.only(start: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    getTranslated(context, 'ORDER_SHIPPED'),
                    style: const TextStyle(fontSize: textFontSize8),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    sDate ?? ' ',
                    style: const TextStyle(fontSize: textFontSize8),
                  ),
                ],
              ),
            ),
          ],
        )
      : sDate == null
          ? const SizedBox()
          : Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Column(
                  children: [
                    SizedBox(
                      height: 30,
                      child: VerticalDivider(
                        thickness: 2,
                        color: colors.primary,
                      ),
                    ),
                    Icon(
                      Icons.circle,
                      color: colors.primary,
                      size: 15,
                    ),
                  ],
                ),
                Container(
                  margin: const EdgeInsetsDirectional.only(start: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        getTranslated(context, 'ORDER_SHIPPED'),
                        style: const TextStyle(fontSize: textFontSize8),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        sDate,
                        style: const TextStyle(fontSize: textFontSize8),
                      ),
                    ],
                  ),
                ),
              ],
            );
}

getDelivered(
  String? dDate,
  String? cDate,
  BuildContext context,
) {
  return cDate == null
      ? Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Column(
              children: [
                SizedBox(
                  height: 30,
                  child: VerticalDivider(
                    thickness: 2,
                    color: dDate == null ? Colors.grey : colors.primary,
                  ),
                ),
                Icon(
                  Icons.circle,
                  color: dDate == null ? Colors.grey : colors.primary,
                  size: 15,
                ),
              ],
            ),
            Container(
              margin: const EdgeInsetsDirectional.only(start: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    getTranslated(context, 'ORDER_DELIVERED'),
                    style: const TextStyle(fontSize: textFontSize8),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    dDate ?? ' ',
                    style: const TextStyle(fontSize: textFontSize8),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        )
      : const SizedBox();
}

getCanceled(String? cDate, BuildContext context) {
  return cDate != null
      ? Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Column(
              children: [
                SizedBox(
                  height: 30,
                  child: VerticalDivider(
                    thickness: 2,
                    color: colors.primary,
                  ),
                ),
                Icon(
                  Icons.cancel_rounded,
                  color: colors.primary,
                  size: 15,
                ),
              ],
            ),
            Container(
              margin: const EdgeInsetsDirectional.only(start: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    getTranslated(context, 'ORDER_CANCLED'),
                    style: const TextStyle(fontSize: textFontSize8),
                  ),
                  Text(
                    cDate,
                    style: const TextStyle(fontSize: textFontSize8),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        )
      : const SizedBox();
}

getReturned(
  OrderItem item,
  String? rDate,
  OrderModel model,
  BuildContext context,
) {
  return item.listStatus!.contains(RETURNED)
      ? Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Column(
              children: [
                SizedBox(
                  height: 30,
                  child: VerticalDivider(
                    thickness: 2,
                    color: colors.primary,
                  ),
                ),
                Icon(
                  Icons.cancel_rounded,
                  color: colors.primary,
                  size: 15,
                ),
              ],
            ),
            Container(
              margin: const EdgeInsetsDirectional.only(start: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    getTranslated(context, 'ORDER_RETURNED'),
                    style: const TextStyle(fontSize: textFontSize8),
                  ),
                  Text(
                    rDate ?? ' ',
                    style: const TextStyle(fontSize: textFontSize8),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        )
      : const SizedBox();
}

getReturneRequestPending(
  OrderItem item,
  String? repDate,
  OrderModel model,
  BuildContext context,
) {
  return item.listStatus!.contains(RETURN_REQ_PENDING)
      ? Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Column(
              children: [
                SizedBox(
                  height: 30,
                  child: VerticalDivider(
                    thickness: 2,
                    color: colors.primary,
                  ),
                ),
                Icon(
                  Icons.pending,
                  color: colors.primary,
                  size: 15,
                ),
              ],
            ),
            Container(
              margin: const EdgeInsetsDirectional.only(start: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    getTranslated(context, 'RETURN_REQUEST_PENDING_LBL'),
                    style: const TextStyle(fontSize: textFontSize8),
                  ),
                  Text(
                    repDate ?? ' ',
                    style: const TextStyle(fontSize: textFontSize8),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        )
      : const SizedBox();
}

getReturneRequestApproved(
  OrderItem item,
  String? reapDate,
  OrderModel model,
  BuildContext context,
) {
  return item.listStatus!.contains(RETURN_REQ_APPROVED)
      ? Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Column(
              children: [
                SizedBox(
                  height: 30,
                  child: VerticalDivider(
                    thickness: 2,
                    color: colors.primary,
                  ),
                ),
                Icon(
                  Icons.approval,
                  color: colors.primary,
                  size: 15,
                ),
              ],
            ),
            Container(
              margin: const EdgeInsetsDirectional.only(start: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    getTranslated(context, 'RETURN_REQUEST_APPROVED_LBL'),
                    style: const TextStyle(fontSize: textFontSize8),
                  ),
                  Text(
                    reapDate ?? ' ',
                    style: const TextStyle(fontSize: textFontSize8),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        )
      : const SizedBox();
}

getReturneRequestDecline(
  OrderItem item,
  String? redDate,
  OrderModel model,
  BuildContext context,
) {
  return item.listStatus!.contains(RETURN_REQ_DECLINE)
      ? Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Column(
              children: [
                SizedBox(
                  height: 30,
                  child: VerticalDivider(
                    thickness: 2,
                    color: colors.primary,
                  ),
                ),
                Icon(
                  Icons.cancel_rounded,
                  color: colors.primary,
                  size: 15,
                ),
              ],
            ),
            Container(
              margin: const EdgeInsetsDirectional.only(start: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    getTranslated(context, 'RETURN_REQUEST_DECLINE_LBL'),
                    style: const TextStyle(fontSize: textFontSize8),
                  ),
                  Text(
                    redDate ?? ' ',
                    style: const TextStyle(fontSize: textFontSize8),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        )
      : const SizedBox();
}
