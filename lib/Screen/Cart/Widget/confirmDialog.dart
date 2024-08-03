import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../Model/Section_Model.dart';
import '../../../Provider/CartProvider.dart';
import '../../../widgets/desing.dart';
import '../../Language/languageSettings.dart';

class GetContent extends StatelessWidget {
  const GetContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<SectionModel> tempCartListForTestCondtion =
        context.read<CartProvider>().cartList;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 20.0, 0, 2.0),
            child: Text(
              getTranslated(context, 'CONFIRM_ORDER'),
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    color: Theme.of(context).colorScheme.fontColor,
                    fontFamily: 'ubuntu',
                  ),
            )),
        Divider(color: Theme.of(context).colorScheme.lightBlack),
        Padding(
          padding: const EdgeInsets.fromLTRB(20.0, 0, 20.0, 0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    getTranslated(context, 'SUBTOTAL'),
                    style: Theme.of(context).textTheme.titleSmall!.copyWith(
                          color: Theme.of(context).colorScheme.lightBlack2,
                          fontFamily: 'ubuntu',
                        ),
                  ),
                  Text(
                    DesignConfiguration.getPriceFormat(
                        context, context.read<CartProvider>().oriPrice)!,
                    style: Theme.of(context).textTheme.titleSmall!.copyWith(
                          color: Theme.of(context).colorScheme.fontColor,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'ubuntu',
                        ),
                  )
                ],
              ),
              if (tempCartListForTestCondtion[0].productList![0].productType !=
                  'digital_product')
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      getTranslated(context, 'DELIVERY_CHARGE'),
                      style: Theme.of(context).textTheme.titleSmall!.copyWith(
                            color: Theme.of(context).colorScheme.lightBlack2,
                            fontFamily: 'ubuntu',
                          ),
                    ),
                    Text(
                      DesignConfiguration.getPriceFormat(context,
                          context.read<CartProvider>().deliveryCharge)!,
                      style: Theme.of(context).textTheme.titleSmall!.copyWith(
                            color: Theme.of(context).colorScheme.fontColor,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'ubuntu',
                          ),
                    )
                  ],
                ),
              context.read<CartProvider>().isPromoValid!
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          getTranslated(context, 'PROMO_CODE_DIS_LBL'),
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall!
                              .copyWith(
                                color:
                                    Theme.of(context).colorScheme.lightBlack2,
                                fontFamily: 'ubuntu',
                              ),
                        ),
                        Text(
                          DesignConfiguration.getPriceFormat(
                              context, context.read<CartProvider>().promoAmt)!,
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall!
                              .copyWith(
                                color: Theme.of(context).colorScheme.fontColor,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'ubuntu',
                              ),
                        )
                      ],
                    )
                  : const SizedBox(),
              context.read<CartProvider>().isUseWallet!
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          getTranslated(context, 'WALLET_BAL'),
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall!
                              .copyWith(
                                fontFamily: 'ubuntu',
                                color:
                                    Theme.of(context).colorScheme.lightBlack2,
                              ),
                        ),
                        Text(
                          DesignConfiguration.getPriceFormat(context,
                              context.read<CartProvider>().usedBalance)!,
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall!
                              .copyWith(
                                fontFamily: 'ubuntu',
                                color: Theme.of(context).colorScheme.fontColor,
                                fontWeight: FontWeight.bold,
                              ),
                        )
                      ],
                    )
                  : const SizedBox(),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      getTranslated(context, 'TOTAL_PRICE'),
                      style: Theme.of(context).textTheme.titleSmall!.copyWith(
                            color: Theme.of(context).colorScheme.lightBlack2,
                            fontFamily: 'ubuntu',
                          ),
                    ),
                    Text(
                      '${DesignConfiguration.getPriceFormat(context, context.read<CartProvider>().totalPrice)!} ',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.fontColor,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'ubuntu',
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: TextField(
                  controller: context.read<CartProvider>().noteController,
                  style: Theme.of(context).textTheme.titleSmall,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                    border: InputBorder.none,
                    filled: true,
                    fillColor: colors.primary.withOpacity(0.1),
                    hintText: getTranslated(context, 'NOTE'),
                  ),
                ),
              ),
              tempCartListForTestCondtion[0].productType != 'digital_product'
                  ? const SizedBox()
                  : Container(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: TextField(
                        controller:
                            context.read<CartProvider>().emailController,
                        style: Theme.of(context).textTheme.titleSmall,
                        decoration: InputDecoration(
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 10),
                          border: InputBorder.none,
                          filled: true,
                          fillColor: colors.primary.withOpacity(0.1),
                          hintText: 'Enter Email Id',
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ],
    );
  }
}
