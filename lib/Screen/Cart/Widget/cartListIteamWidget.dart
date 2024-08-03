import 'package:eshop_multivendor/Provider/UserProvider.dart';
import 'package:eshop_multivendor/Screen/Product%20Detail/productDetail.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../Helper/Color.dart';
import '../../../Helper/Constant.dart';
import '../../../Helper/String.dart';
import '../../../Model/Section_Model.dart';
import '../../../Provider/CartProvider.dart';
import '../../../Provider/SettingProvider.dart';
import '../../../widgets/desing.dart';
import '../../Language/languageSettings.dart';
import '../../Dashboard/Dashboard.dart';

// ignore: must_be_immutable
class CartListViewLayOut extends StatefulWidget {
  int index;
  Function setState;
  Function saveForLatter;

  CartListViewLayOut({
    Key? key,
    required this.index,
    required this.setState,
    required this.saveForLatter,
  }) : super(key: key);

  @override
  State<CartListViewLayOut> createState() => _CartListViewLayOutState();
}

class _CartListViewLayOutState extends State<CartListViewLayOut> {
  @override
  Widget build(BuildContext context) {
    List<SectionModel> cartList = context.read<CartProvider>().cartList;
    int index = widget.index;
    int selectedPos = 0;
    for (int i = 0;
        i < cartList[index].productList![0].prVarientList!.length;
        i++) {
      if (cartList[index].varientId ==
          cartList[index].productList![0].prVarientList![i].id) selectedPos = i;
    }

    String? offPer;
    double price = double.parse(
        cartList[index].productList![0].prVarientList![selectedPos].disPrice!);
    if (price == 0) {
      price = double.parse(
          cartList[index].productList![0].prVarientList![selectedPos].price!);
    } else {
      double off = (double.parse(cartList[index]
              .productList![0]
              .prVarientList![selectedPos]
              .price!)) -
          price;
      offPer = (off *
              100 /
              double.parse(cartList[index]
                  .productList![0]
                  .prVarientList![selectedPos]
                  .price!))
          .toStringAsFixed(2);
    }

    cartList[index].perItemPrice = price.toString();

    if (context.read<CartProvider>().controller.length < index + 1) {
      context.read<CartProvider>().controller.add(TextEditingController());
    }
    if (cartList[index].productList![0].availability != '0') {
      cartList[index].perItemTotal =
          (price * double.parse(cartList[index].qty!)).toString();
      context.read<CartProvider>().controller[index].text =
          cartList[index].qty!;
    }
    List att = [], val = [];
    if (cartList[index].productList![0].prVarientList![selectedPos].attr_name !=
        '') {
      att = cartList[index]
          .productList![0]
          .prVarientList![selectedPos]
          .attr_name!
          .split(',');
      val = cartList[index]
          .productList![0]
          .prVarientList![selectedPos]
          .varient_value!
          .split(',');
    }

    if (cartList[index].productList![0].attributeList!.isEmpty) {
      if (cartList[index].productList![0].availability == '0') {
        context.read<CartProvider>().isAvailable = false;
      }
    } else {
      if (cartList[index]
              .productList![0]
              .prVarientList![selectedPos]
              .availability ==
          '0') {
        context.read<CartProvider>().isAvailable = false;
      }
    }

    double total = (price *
        double.parse(cartList[index]
            .productList![0]
            .prVarientList![selectedPos]
            .cartCount!));

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 1.0,
      ),
      child: Card(
        elevation: 0.1,
        child: Column(
          children: [
            InkWell(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Hero(
                    tag:
                        '$heroTagUniqueString$heroTagUniqueString$index${cartList[index].productList![0].id}',
                    child: ClipRRect(
                      borderRadius: const BorderRadius.all(
                        Radius.circular(circularBorderRadius4),
                        // bottomLeft: Radius.circular(circularBorderRadius4),
                      ),
                      child: Stack(
                        children: [
                          DesignConfiguration.getCacheNotworkImage(
                              boxFit: BoxFit.cover,
                              context: context,
                              heightvalue: 100.0,
                              widthvalue: 100.0,
                              imageurlString: cartList[index]
                                              .productList![0]
                                              .type ==
                                          'variable_product' &&
                                      cartList[index]
                                          .productList![0]
                                          .prVarientList![selectedPos]
                                          .images!
                                          .isNotEmpty
                                  ? cartList[index]
                                      .productList![0]
                                      .prVarientList![selectedPos]
                                      .images![0]
                                  : cartList[index].productList![0].image!,
                              placeHolderSize: null),
                          Positioned.fill(
                            child: cartList[index]
                                        .productList![0]
                                        .prVarientList![selectedPos]
                                        .availability ==
                                    '0'
                                ? Container(
                                    height: 55,
                                    color: colors.white70,
                                    padding: const EdgeInsets.all(2),
                                    child: Center(
                                      child: Text(
                                        getTranslated(
                                            context, 'OUT_OF_STOCK_LBL'),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall!
                                            .copyWith(
                                              fontFamily: 'ubuntu',
                                              color: colors.red,
                                              fontWeight: FontWeight.bold,
                                            ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  )
                                : const SizedBox(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsetsDirectional.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsetsDirectional.only(
                                      top: 0.0, end: 5),
                                  child: Text(
                                    cartList[index].productList![0].name!,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall!
                                        .copyWith(
                                          fontFamily: 'ubuntu',
                                          color: Theme.of(context)
                                              .colorScheme
                                              .fontColor,
                                          fontWeight: FontWeight.w400,
                                          fontStyle: FontStyle.normal,
                                        ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          // cartList[index]
                          //                 .productList![0]
                          //                 .prVarientList![selectedPos]
                          //                 .attr_name !=
                          //             null &&
                          //         cartList[index]
                          //             .productList![0]
                          //             .prVarientList![selectedPos]
                          //             .attr_name!
                          //             .isNotEmpty
                          //     ? ListView.builder(
                          //         physics: const NeverScrollableScrollPhysics(),
                          //         shrinkWrap: true,
                          //         itemCount: att.length,
                          //         itemBuilder: (context, index) {
                          //           return Row(
                          //             children: [
                          //               Flexible(
                          //                 child: Text(
                          //                   att[index].trim() + ':',
                          //                   overflow: TextOverflow.ellipsis,
                          //                   style: Theme.of(context)
                          //                       .textTheme
                          //                       .titleSmall!
                          //                       .copyWith(
                          //                         fontFamily: 'ubuntu',
                          //                         color: Theme.of(context)
                          //                             .colorScheme
                          //                             .lightBlack,
                          //                       ),
                          //                 ),
                          //               ),
                          //               Padding(
                          //                 padding:
                          //                     const EdgeInsetsDirectional.only(
                          //                         start: 5.0),
                          //                 child: Text(
                          //                   val[index],
                          //                   style: Theme.of(context)
                          //                       .textTheme
                          //                       .titleSmall!
                          //                       .copyWith(
                          //                           color: Theme.of(context)
                          //                               .colorScheme
                          //                               .lightBlack,
                          //                           fontFamily: 'ubuntu',
                          //                           fontWeight:
                          //                               FontWeight.bold),
                          //                 ),
                          //               )
                          //             ],
                          //           );
                          //         },
                          //       )
                          //     : const SizedBox(),
                        
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Row(
                              children: <Widget>[
                                Text(
                                  '${DesignConfiguration.getPriceFormat(context, price)!} ',
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primaryContainer,
                                    fontWeight: FontWeight.bold,
                                    fontSize: textFontSize12,
                                    fontFamily: 'ubuntu',
                                  ),
                                ),
                                Text(
                                  double.parse(cartList[index]
                                              .productList![0]
                                              .prVarientList![selectedPos]
                                              .disPrice!) !=
                                          0
                                      ? DesignConfiguration.getPriceFormat(
                                          context,
                                          double.parse(cartList[index]
                                              .productList![0]
                                              .prVarientList![selectedPos]
                                              .price!),
                                        )!
                                      : '',
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelSmall!
                                      .copyWith(
                                          fontFamily: 'ubuntu',
                                          decoration:
                                              TextDecoration.lineThrough,
                                          decorationColor:
                                              colors.darkColor3,
                                          decorationStyle:
                                              TextDecorationStyle.solid,
                                          decorationThickness: 2,
                                          letterSpacing: 0.7),
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                offPer != null
                                    ? offPer != 0
                                        ? Text(
                                            '${offPer}%',
                                            style: const TextStyle(
                                              color: colors.green,
                                              fontWeight: FontWeight.bold,
                                              fontSize: textFontSize9,
                                            ),
                                          )
                                        : const SizedBox()
                                    : const SizedBox()
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          cartList[index].productList![0].availability ==
                                      '1' ||
                                  cartList[index]
                                          .productList![0]
                                          .stockType ==
                                      ''
                              ? Row(
                                  children: <Widget>[
                                    Row(
                                      children: <Widget>[
                                        cartList[index]
                                                    .productList![0]
                                                    .type ==
                                                'digital_product'
                                            ? const SizedBox()
                                            : InkWell(
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .white,
                                                    border: Border.all(
                                                        color: Theme.of(
                                                                context)
                                                            .colorScheme
                                                            .gray,
                                                        width: 1),
                                                    borderRadius:
                                                        const BorderRadiusDirectional
                                                            .all(
                                                      Radius.circular(
                                                          circularBorderRadius7),
                                                    ),
                                                  ),
                                                  // shape: RoundedRectangleBorder(
                                                  //   borderRadius: BorderRadius.circular(
                                                  //       circularBorderRadius50),
                                                  // ),
                                                  child: Padding(
                                                    padding:
                                                        EdgeInsets.all(5.0),
                                                    child: Icon(
                                                      Icons.remove,
                                                      size: 15,
                                                      color:
                                                          Theme.of(context)
                                                              .colorScheme
                                                              .black,
                                                    ),
                                                  ),
                                                ),
                                                onTap: () {
                                                  if (context
                                                          .read<
                                                              CartProvider>()
                                                          .isProgress ==
                                                      false) {
                                                    if (context
                                                            .read<
                                                                UserProvider>()
                                                            .userId !=
                                                        '') {
                                                      context
                                                          .read<
                                                              CartProvider>()
                                                          .removeFromCart(
                                                            index: index,
                                                            remove: false,
                                                            cartList:
                                                                cartList,
                                                            move: false,
                                                            selPos:
                                                                selectedPos,
                                                            context:
                                                                context,
                                                            update: widget
                                                                .setState,
                                                            promoCode: context
                                                                .read<
                                                                    CartProvider>()
                                                                .promoC
                                                                .text,
                                                          );
                                                    } else {
                                                      if ((int.parse(cartList[
                                                                  index]
                                                              .productList![
                                                                  0]
                                                              .prVarientList![
                                                                  selectedPos]
                                                              .cartCount!)) >
                                                          1) {
                                                        context
                                                            .read<
                                                                CartProvider>()
                                                            .addAndRemoveQty(
                                                              qty: cartList[
                                                                      index]
                                                                  .productList![
                                                                      0]
                                                                  .prVarientList![
                                                                      selectedPos]
                                                                  .cartCount!,
                                                              from: 2,
                                                              totalLen: cartList[
                                                                          index]
                                                                      .productList![
                                                                          0]
                                                                      .itemsCounter!
                                                                      .length *
                                                                  int.parse(cartList[
                                                                          index]
                                                                      .productList![
                                                                          0]
                                                                      .qtyStepSize!),
                                                              index: index,
                                                              price: price,
                                                              selectedPos:
                                                                  selectedPos,
                                                              total: total,
                                                              cartList:
                                                                  cartList,
                                                              itemCounter: int.parse(cartList[
                                                                      index]
                                                                  .productList![
                                                                      0]
                                                                  .qtyStepSize!),
                                                              context:
                                                                  context,
                                                              update: widget
                                                                  .setState,
                                                            );
                                                        widget.setState();
                                                      }
                                                    }
                                                  }
                                                },
                                              ),
                                        cartList[index]
                                                    .productList![0]
                                                    .type ==
                                                'digital_product'
                                            ? const SizedBox()
                                            : SizedBox(
                                                width: 30,
                                                height: 20,
                                                child: Stack(
                                                  children: [
                                                    TextField(
                                                      textAlign:
                                                          TextAlign.center,
                                                      readOnly: true,
                                                      style: TextStyle(
                                                          fontSize:
                                                              textFontSize12,
                                                          color: Theme.of(
                                                                  context)
                                                              .colorScheme
                                                              .fontColor),
                                                      controller: context
                                                          .read<
                                                              CartProvider>()
                                                          .controller[index],
                                                      decoration:
                                                          const InputDecoration(
                                                        border: InputBorder
                                                            .none,
                                                      ),
                                                    ),
                                                    PopupMenuButton<String>(
                                                      tooltip: '',
                                                      icon: const Icon(
                                                        Icons
                                                            .arrow_drop_down,
                                                        size: 1,
                                                      ),
                                                      onSelected:
                                                          (String value) {
                                                        if (context
                                                                .read<
                                                                    CartProvider>()
                                                                .isProgress ==
                                                            false) {
                                                          if (context
                                                                  .read<
                                                                      UserProvider>()
                                                                  .userId !=
                                                              '') {
                                                            context.read<CartProvider>().addToCart(
                                                                index:
                                                                    index,
                                                                qty: value,
                                                                cartList:
                                                                    cartList,
                                                                context:
                                                                    context,
                                                                update: widget
                                                                    .setState);
                                                          } else {
                                                            context.read<CartProvider>().addAndRemoveQty(
                                                                qty: value,
                                                                from: 3,
                                                                totalLen: cartList[index]
                                                                        .productList![
                                                                            0]
                                                                        .itemsCounter!
                                                                        .length *
                                                                    int.parse(cartList[index]
                                                                        .productList![
                                                                            0]
                                                                        .qtyStepSize!),
                                                                index:
                                                                    index,
                                                                price:
                                                                    price,
                                                                selectedPos:
                                                                    selectedPos,
                                                                total:
                                                                    total,
                                                                cartList:
                                                                    cartList,
                                                                itemCounter: int.parse(cartList[
                                                                        index]
                                                                    .productList![
                                                                        0]
                                                                    .qtyStepSize!),
                                                                context:
                                                                    context,
                                                                update: widget
                                                                    .setState);
                                                          }
                                                        }
                                                      },
                                                      itemBuilder:
                                                          (BuildContext
                                                              context) {
                                                        return cartList[
                                                                index]
                                                            .productList![0]
                                                            .itemsCounter!
                                                            .map<
                                                                PopupMenuItem<
                                                                    String>>(
                                                          (String value) {
                                                            return PopupMenuItem(
                                                              value: value,
                                                              child: Text(
                                                                value,
                                                                style:
                                                                    TextStyle(
                                                                  color: Theme.of(
                                                                          context)
                                                                      .colorScheme
                                                                      .fontColor,
                                                                  fontFamily:
                                                                      'ubuntu',
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                        ).toList();
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              ),
                                        cartList[index]
                                                    .productList![0]
                                                    .type ==
                                                'digital_product'
                                            ? const SizedBox()
                                            : InkWell(
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .white,
                                                    border: Border.all(
                                                        color: Theme.of(
                                                                context)
                                                            .colorScheme
                                                            .gray,
                                                        width: 1),
                                                    borderRadius:
                                                        const BorderRadiusDirectional
                                                            .all(
                                                      Radius.circular(
                                                          circularBorderRadius7),
                                                    ),
                                                  ),
                                                  // shape: RoundedRectangleBorder(
                                                  //   borderRadius: BorderRadius.circular(
                                                  //       circularBorderRadius50),
                                                  // ),
                                                  child: Padding(
                                                    padding:
                                                        EdgeInsets.all(5.0),
                                                    child: Icon(
                                                      Icons.add,
                                                      size: 15,
                                                      color:
                                                          Theme.of(context)
                                                              .colorScheme
                                                              .black,
                                                    ),
                                                  ),
                                                ),
                                                onTap: () {
                                                  if (context
                                                          .read<
                                                              CartProvider>()
                                                          .isProgress ==
                                                      false) {
                                                    if (context
                                                            .read<
                                                                UserProvider>()
                                                            .userId !=
                                                        '') {
                                                      context.read<CartProvider>().addToCart(
                                                          index: index,
                                                          qty: (int.parse(cartList[
                                                                          index]
                                                                      .qty!) +
                                                                  int.parse(cartList[
                                                                          index]
                                                                      .productList![
                                                                          0]
                                                                      .qtyStepSize!))
                                                              .toString(),
                                                          cartList:
                                                              cartList,
                                                          context: context,
                                                          update: widget
                                                              .setState);
                                                    } else {
                                                      context
                                                          .read<
                                                              CartProvider>()
                                                          .addAndRemoveQty(
                                                            qty: cartList[
                                                                    index]
                                                                .productList![
                                                                    0]
                                                                .prVarientList![
                                                                    selectedPos]
                                                                .cartCount!,
                                                            from: 1,
                                                            totalLen: cartList[
                                                                        index]
                                                                    .productList![
                                                                        0]
                                                                    .itemsCounter!
                                                                    .length *
                                                                int.parse(cartList[
                                                                        index]
                                                                    .productList![
                                                                        0]
                                                                    .qtyStepSize!),
                                                            index: index,
                                                            price: price,
                                                            selectedPos:
                                                                selectedPos,
                                                            total: total,
                                                            cartList:
                                                                cartList,
                                                            itemCounter: int
                                                                .parse(cartList[
                                                                        index]
                                                                    .productList![
                                                                        0]
                                                                    .qtyStepSize!),
                                                            context:
                                                                context,
                                                            update: widget
                                                                .setState,
                                                          );
                                                    }
                                                  }
                                                },
                                              )
                                      ],
                                    ),
                                  ],
                                )
                              : const SizedBox(),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            onTap: (){
              Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => ProductDetail(
                index: index,
                model: cartList[index].productList![0],
                selectedVarientId: selectedPos,
                list: false,
                fromCart: true,
              ),
            ),
          );
            },
            ),
            const Padding(
              padding: EdgeInsets.only(top: 8.0),
              child: Divider(
                height: 0,
              ),
            ),
            IntrinsicHeight(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: InkWell(
                      child: Row(
                        children: [
                          Icon(Icons.delete_outlined,
                              color:
                                  Theme.of(context).colorScheme.fontColor),
                          Text(
                            getTranslated(context, 'REMOVE'),
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall!
                                .copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .fontColor,
                                  fontFamily: 'ubuntu',
                                ),
                          )
                        ],
                      ),
                      onTap: () async {
                    if (context.read<CartProvider>().isProgress == false) {
                      if (context.read<UserProvider>().userId != '') {
                        context.read<CartProvider>().deleteFromCart(
                            index: index,
                            cartList: cartList,
                            move: false,
                            selPos: selectedPos,
                            context: context,
                            update: widget.setState,
                            promoCode:
                                context.read<CartProvider>().promoC.text,
                            from: 1);
                      } else {
                        if (singleSellerOrderSystem) {
                          if (cartList.length == 1) {
                            context
                                .read<SettingProvider>()
                                .setCurrentSellerID('');
                            CurrentSellerID = '';
                          }
                        }
                        db.removeCart(
                            cartList[index]
                                .productList![0]
                                .prVarientList![selectedPos]
                                .id!,
                            cartList[index].id!,
                            context);
        
                        context.read<CartProvider>().removeCartItem(
                            cartList[index]
                                .productList![0]
                                .prVarientList![selectedPos]
                                .id!);
                        /* cartList.removeWhere((item) =>
                                        item.varientId ==
                                        cartList[index].varientId);*/
                        context.read<CartProvider>().oriPrice =
                            context.read<CartProvider>().oriPrice - total;
                        context.read<CartProvider>().productIds =
                            (await db.getCart())!;
        
                        widget.setState();
                      }
                    }
                  },
                    ),
                  ),
                  const VerticalDivider(),
                  Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: InkWell(
                      child: Row(
                        children: [
                          Icon(
                            Icons.move_to_inbox,
                            color: Theme.of(context).colorScheme.fontColor,
                          ),
                          Text(
                            " ${getTranslated(context, 'SAVEFORLATER_BTN')}",
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall!
                                .copyWith(
                                  color:
                                      Theme.of(context).colorScheme.fontColor,
                                  fontFamily: 'ubuntu',
                                ),
                          )
                        ],
                      ),
                    onTap: (){
                    if (singleSellerOrderSystem) {
                      if (cartList.length == 1) {
                        context
                            .read<SettingProvider>()
                            .setCurrentSellerID('');
                        CurrentSellerID = '';
                      }
                    }
                    if (!context.read<CartProvider>().saveLater &&
                        !context.read<CartProvider>().isProgress) {
                      if (context.read<UserProvider>().userId != '') {
                        context.read<CartProvider>().saveLater = true;
                        widget.setState();
                        context.read<CartProvider>().saveForLater(
                            update: widget.setState,
                            fromSave: false,
                            id: cartList[index]
                                        .productList![0]
                                        .availability ==
                                    '0'
                                ? cartList[index]
                                    .productList![0]
                                    .prVarientList![selectedPos]
                                    .id!
                                : cartList[index].varientId,
                            price:
                                double.parse(cartList[index].perItemTotal!),
                            context: context,
                            qty: cartList[index]
                                        .productList![0]
                                        .availability ==
                                    '0'
                                ? '1'
                                : cartList[index].qty,
                            save: '1',
                            curItem: cartList[index],
                            promoCode:
                                context.read<CartProvider>().promoC.text,
                            selIndex: cartList[index]
                                        .productList![0]
                                        .availability ==
                                    '0'
                                ? selectedPos
                                : null);
                      } else {
                        () async {
                          context.read<CartProvider>().saveLater = true;
                          context.read<CartProvider>().setProgress(true);
                          await widget.saveForLatter(
                            index: index,
                            selectedPos: selectedPos,
                            total: total,
                            cartList: cartList,
                          );
                        }();
                      }
                    } else {}}
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
