import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:eshop_multivendor/Screen/Manage%20Address/Manage_Address.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../Provider/CartProvider.dart';
import '../../Language/languageSettings.dart';
import '../../AddAddress/Add_Address.dart';

// ignore: must_be_immutable
class SetAddress extends StatefulWidget {
  Function update;

  SetAddress({Key? key, required this.update}) : super(key: key);

  @override
  State<SetAddress> createState() => _SetAddressState();
}

class _SetAddressState extends State<SetAddress> {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(Icons.location_on),
                Padding(
                  padding: const EdgeInsetsDirectional.only(start: 8.0),
                  child: Text(
                    getTranslated(context, 'SHIPPING_DETAIL'),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.fontColor,
                      fontFamily: 'ubuntu',
                    ),
                  ),
                ),
              ],
            ),
            const Divider(),
            context.read<CartProvider>().addressList.isNotEmpty
                ? Padding(
                    padding: const EdgeInsetsDirectional.only(start: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                context
                                    .read<CartProvider>()
                                    .addressList[context
                                        .read<CartProvider>()
                                        .selectedAddress!]
                                    .name!,
                                style: const TextStyle(
                                  fontFamily: 'ubuntu',
                                ),
                              ),
                            ),
                            InkWell(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Text(
                                  getTranslated(context, 'CHANGE'),
                                  style: const TextStyle(
                                    color: colors.primary,
                                    fontFamily: 'ubuntu',
                                  ),
                                ),
                              ),
                              onTap: () async {
                                Navigator.push(
                                  context,
                                  CupertinoPageRoute(
                                    builder: (context) => const ManageAddress(
                                      home: false,
                                    ),
                                  ),
                                ).then((value) {
                                  context.read<CartProvider>().checkoutState!(
                                    () {
                                      context.read<CartProvider>().deliverable =
                                          false;
                                      context
                                              .read<CartProvider>()
                                              .isShippingDeliveryChargeApplied =
                                          false;
                                    },
                                  );
                                  /* if (context
                                      .read<CartProvider>()
                                      .isAddressChange!) {
                                    context
                                        .read<CartProvider>()
                                        .checkDeliverable(
                                            widget.update, context);
                                  }*/
                                  if (mounted) widget.update();
                                });
                                /* Routes.navigateToManageAddressScreen(
                                    context, false);
                                */
                              },
                            ),
                          ],
                        ),
                        Text(
                          '${context.read<CartProvider>().addressList[context.read<CartProvider>().selectedAddress!].address!}, ${context.read<CartProvider>().addressList[context.read<CartProvider>().selectedAddress!].area!}, ${context.read<CartProvider>().addressList[context.read<CartProvider>().selectedAddress!].city!}, ${context.read<CartProvider>().addressList[context.read<CartProvider>().selectedAddress!].state!}, ${context.read<CartProvider>().addressList[context.read<CartProvider>().selectedAddress!].country!}, ${context.read<CartProvider>().addressList[context.read<CartProvider>().selectedAddress!].pincode!}',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall!
                              .copyWith(
                                color: Theme.of(context).colorScheme.lightBlack,
                              ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5.0),
                          child: Row(
                            children: [
                              Text(
                                context
                                    .read<CartProvider>()
                                    .addressList[context
                                        .read<CartProvider>()
                                        .selectedAddress!]
                                    .mobile!,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .copyWith(
                                      fontFamily: 'ubuntu',
                                      color: Theme.of(context)
                                          .colorScheme
                                          .lightBlack,
                                    ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  )
                : Padding(
                    padding: const EdgeInsetsDirectional.only(start: 8.0),
                    child: InkWell(
                      child: Text(
                        getTranslated(context, 'ADDADDRESS'),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.fontColor,
                          fontFamily: 'ubuntu',
                        ),
                      ),
                      onTap: () async {
                        ScaffoldMessenger.of(context).removeCurrentSnackBar();
                        Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (context) => AddAddress(
                              update: false,
                              index: context
                                  .read<CartProvider>()
                                  .addressList
                                  .length,
                              fromProfile: false,
                            ),
                          ),
                        ).then((value) {
                          context.read<CartProvider>().checkoutState!(
                            () {
                              context.read<CartProvider>().deliverable = false;
                              context
                                  .read<CartProvider>()
                                  .isShippingDeliveryChargeApplied = false;
                            },
                          );
                          /*if (context.read<CartProvider>().isAddressChange!) {
                            context
                                .read<CartProvider>()
                                .checkDeliverable(widget.update, context);
                          }*/
                          if (mounted) widget.update();
                        });
                      },
                    ),
                  )
          ],
        ),
      ),
    );
  }
}
