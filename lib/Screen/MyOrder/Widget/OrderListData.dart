import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../Helper/Constant.dart';
import '../../../Helper/String.dart';
import '../../../Model/Order_Model.dart';
import '../../../Provider/Order/OrderProvider.dart';
import '../../../widgets/desing.dart';
import '../../OrderDetail/OrderDetail.dart';

class OrderListData extends StatelessWidget {
  int index;
  OrderItem orderItem;
  int len;
  OrderModel searchOrder;
  String searchText;

  OrderListData(
      {Key? key,
      required this.index,
      required this.searchOrder,
      required this.orderItem,
      required this.len,
      required this.searchText})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (orderItem != null) {
      String? sDate = orderItem.listDate!.last;
      String? proStatus = orderItem.listStatus!.last;
      if (proStatus == 'received') {
        proStatus = 'order placed';
      }
      if (proStatus == 'return_request_pending') {
        proStatus = 'return request pending';
      }
      if (proStatus == 'return_request_approved') {
        proStatus = 'return request approved';
      }
      if (proStatus == 'return_request_decline') {
        proStatus = 'return request decline';
      }
      String name = orderItem.name ?? '';
      name = "$name ${len > 1 ? " and more items" : ""} ";

      return Card(
        elevation: 0,
        child: InkWell(
          borderRadius: BorderRadius.circular(circularBorderRadius7),
          child: Column(
            children: <Widget>[
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Hero(
                    tag:
                        '$heroTagUniqueString$index${orderItem.id}${orderItem.image}',
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(circularBorderRadius7),
                          topLeft: Radius.circular(circularBorderRadius7)),
                      child: DesignConfiguration.getCacheNotworkImage(
                        boxFit: BoxFit.cover,
                        context: context,
                        heightvalue: 100.0,
                        widthvalue: 100.0,
                        imageurlString: orderItem.image!,
                        placeHolderSize: 90,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 9,
                    child: Padding(
                      padding: const EdgeInsetsDirectional.only(
                          start: 10.0, end: 5.0, bottom: 8.0, top: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            '$proStatus on $sDate',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall!
                                .copyWith(
                                  color:
                                      Theme.of(context).colorScheme.lightBlack,
                                  fontFamily: 'ubuntu',
                                ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsetsDirectional.only(top: 10.0),
                            child: Text(
                              name,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall!
                                  .copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .lightBlack2,
                                    fontFamily: 'ubuntu',
                                    fontWeight: FontWeight.normal,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                  const Padding(
                    padding: EdgeInsets.only(right: 3.0),
                    child: Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: colors.primary,
                      size: 15,
                    ),
                  )
                ],
              ),
            ],
          ),
          onTap: () async {
            FocusScope.of(context).unfocus();
            final result = await Navigator.push(
              context,
              CupertinoPageRoute(
                  builder: (context) => OrderDetail(model: searchOrder)),
            );

            if (result == 'update') {
              context.read<OrderProvider>().hasMoreData = true;
              context.read<OrderProvider>().OrderOffset = 0;
              Future.delayed(Duration.zero).then(
                (value) => context.read<OrderProvider>().getOrder(
                      context,
                      searchText,
                    ),
              );
            }
          },
        ),
      );
    } else {
      return const SizedBox();
    }
  }
}
