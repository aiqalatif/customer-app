import 'dart:async';
import 'package:eshop_multivendor/widgets/ratingCardForProduct.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../Helper/Color.dart';
import '../../../Helper/Constant.dart';
import '../../../Helper/String.dart';
import '../../SQLiteData/SqliteData.dart';
import '../../../Model/Section_Model.dart';
import '../../../Provider/CartProvider.dart';
import '../../../Provider/Favourite/FavoriteProvider.dart';
import '../../../Provider/Favourite/UpdateFavProvider.dart';
import '../../../Provider/UserProvider.dart';
import '../../../widgets/desing.dart';
import '../../Language/languageSettings.dart';
import '../../../widgets/networkAvailablity.dart';
import '../../../widgets/snackbar.dart';
import '../../../widgets/star_rating.dart';
import '../../Product Detail/productDetail.dart';
import 'package:collection/src/iterable_extensions.dart';

class FavProductData extends StatefulWidget {
  int? index;
  List<Product> favList = [];
  Function updateNow;

  FavProductData({
    Key? key,
    required this.index,
    required this.updateNow,
    required this.favList,
  }) : super(key: key);

  @override
  State<FavProductData> createState() => _FavProductDataState();
}

class _FavProductDataState extends State<FavProductData> {
  var db = DatabaseHelper();

  removeFromCart(
    int index,
    List<Product> favList,
    BuildContext context,
  ) async {
    isNetworkAvail = await isNetworkAvailable();
    if (isNetworkAvail) {
      if (context.read<UserProvider>().userId != '') {
        if (mounted) {
          context
              .read<UpdateFavProvider>()
              .changeStatus(UpdateFavStatus.inProgress);
        }
        int qty;
        qty = (int.parse(
                context.read<FavoriteProvider>().controllerText[index].text) -
            int.parse(favList[index].qtyStepSize!));

        if (qty < favList[index].minOrderQuntity!) {
          qty = 0;
        }

        var parameter = {
          PRODUCT_VARIENT_ID:
              favList[index].prVarientList![favList[index].selVarient!].id,
          // USER_ID: context.read<UserProvider>().userId,
          QTY: qty.toString()
        };

        apiBaseHelper.postAPICall(manageCartApi, parameter).then(
          (getdata) {
            bool error = getdata['error'];
            String? msg = getdata['message'];
            if (!error) {
              var data = getdata['data'];

              String? qty = data['total_quantity'];

              context.read<UserProvider>().setCartCount(data['cart_count']);
              favList[index]
                  .prVarientList![favList[index].selVarient!]
                  .cartCount = qty.toString();

              var cart = getdata['cart'];
              List<SectionModel> cartList = (cart as List)
                  .map((cart) => SectionModel.fromCart(cart))
                  .toList();
              context.read<CartProvider>().setCartlist(cartList);
            } else {
              setSnackbar(msg!, context);
            }

            if (mounted) {
              context
                  .read<UpdateFavProvider>()
                  .changeStatus(UpdateFavStatus.isSuccsess);
              widget.updateNow();
            }
          },
          onError: (error) {
            setSnackbar(error.toString(), context);
            context
                .read<UpdateFavProvider>()
                .changeStatus(UpdateFavStatus.isSuccsess);
            widget.updateNow();
          },
        );
      } else {
        context
            .read<UpdateFavProvider>()
            .changeStatus(UpdateFavStatus.inProgress);
        int qty;

        qty = (int.parse(
                context.read<FavoriteProvider>().controllerText[index].text) -
            int.parse(favList[index].qtyStepSize!));

        if (qty < favList[index].minOrderQuntity!) {
          qty = 0;

          db.removeCart(
              favList[index].prVarientList![favList[index].selVarient!].id!,
              favList[index].id!,
              context);
          context.read<CartProvider>().removeCartItem(
              favList[index].prVarientList![favList[index].selVarient!].id!);
        } else {
          context.read<CartProvider>().updateCartItem(
              favList[index].id!,
              qty.toString(),
              favList[index].selVarient!,
              favList[index].prVarientList![favList[index].selVarient!].id!);
          db.updateCart(
            favList[index].id!,
            favList[index].prVarientList![favList[index].selVarient!].id!,
            qty.toString(),
          );
        }
        context
            .read<UpdateFavProvider>()
            .changeStatus(UpdateFavStatus.isSuccsess);
        widget.updateNow();
      }
    } else {
      if (mounted) {
        isNetworkAvail = false;
        widget.updateNow();
      }
    }
  }

  Future<void> addToCart(
    String qty,
    int from,
    // List<Product> favList,
  ) async {
    isNetworkAvail = await isNetworkAvailable();
    if (isNetworkAvail) {
      if (context.read<UserProvider>().userId != '') {
        if (mounted) {
          context
              .read<UpdateFavProvider>()
              .changeStatus(UpdateFavStatus.inProgress);
        }

        /*String qty =
              (int.parse(widget.favList[widget.index!].prVarientList![0].cartCount!) +
                      int.parse(widget.favList[widget.index!].qtyStepSize!))
                  .toString();*/

        if (int.parse(qty) < widget.favList[widget.index!].minOrderQuntity!) {
          qty = widget.favList[widget.index!].minOrderQuntity.toString();
          setSnackbar("${getTranslated(context, 'MIN_MSG')}$qty", context);
        }

        var parameter = {
          PRODUCT_VARIENT_ID: widget.favList[widget.index!]
              .prVarientList![widget.favList[widget.index!].selVarient!].id,
          // USER_ID: context.read<UserProvider>().userId,
          QTY: qty,
        };
        apiBaseHelper.postAPICall(manageCartApi, parameter).then(
          (getdata) {
            bool error = getdata['error'];
            String? msg = getdata['message'];
            if (!error) {
              var data = getdata['data'];

              String? qty = data['total_quantity'];
              context.read<UserProvider>().setCartCount(data['cart_count']);

              widget
                  .favList[widget.index!]
                  .prVarientList![widget.favList[widget.index!].selVarient!]
                  .cartCount = qty.toString();

              widget.favList[widget.index!].prVarientList![0].cartCount =
                  qty.toString();
              context
                  .read<FavoriteProvider>()
                  .controllerText[widget.index!]
                  .text = qty.toString();
              var cart = getdata['cart'];
              List<SectionModel> cartList = (cart as List)
                  .map((cart) => SectionModel.fromCart(cart))
                  .toList();
              context.read<CartProvider>().setCartlist(cartList);
            } else {
              setSnackbar(msg!, context);
            }

            if (mounted) {
              context
                  .read<UpdateFavProvider>()
                  .changeStatus(UpdateFavStatus.isSuccsess);
            }
          },
          onError: (error) {
            setSnackbar(error.toString(), context);
          },
        );
      } else {
        if (singleSellerOrderSystem) {
          if (CurrentSellerID == '' ||
              CurrentSellerID == widget.favList[widget.index!].seller_id!) {
            CurrentSellerID = widget.favList[widget.index!].seller_id!;

            context
                .read<UpdateFavProvider>()
                .changeStatus(UpdateFavStatus.inProgress);
            if (from == 1) {
              List<Product>? prList = [];
              prList.add(widget.favList[widget.index!]);
              context.read<CartProvider>().addCartItem(
                    SectionModel(
                      qty: qty,
                      productList: prList,
                      varientId: widget
                          .favList[widget.index!]
                          .prVarientList![
                              widget.favList[widget.index!].selVarient!]
                          .id!,
                      id: widget.favList[widget.index!].id,
                      sellerId: widget.favList[widget.index!].seller_id,
                    ),
                  );
              db.insertCart(
                widget.favList[widget.index!].id!,
                widget
                    .favList[widget.index!]
                    .prVarientList![widget.favList[widget.index!].selVarient!]
                    .id!,
                qty,
                context,
              );
              context
                  .read<FavoriteProvider>()
                  .controllerText[widget.index!]
                  .text = qty.toString();
              widget.updateNow();
              setSnackbar(
                  getTranslated(context, 'PRODUCT_ADDED_TO_CART_LBL'), context);
            } else {
              if (int.parse(qty) >
                  widget.favList[widget.index!].itemsCounter!.length) {
                setSnackbar(
                    '${getTranslated(context, "Max Quantity is")}-${int.parse(qty) - 1}',
                    context);
              } else {
                context.read<CartProvider>().updateCartItem(
                      widget.favList[widget.index!].id!,
                      qty,
                      widget.favList[widget.index!].selVarient!,
                      widget
                          .favList[widget.index!]
                          .prVarientList![
                              widget.favList[widget.index!].selVarient!]
                          .id!,
                    );
                db.updateCart(
                  widget.favList[widget.index!].id!,
                  widget
                      .favList[widget.index!]
                      .prVarientList![widget.favList[widget.index!].selVarient!]
                      .id!,
                  qty,
                );
              }
              context
                  .read<FavoriteProvider>()
                  .controllerText[widget.index!]
                  .text = qty.toString();
              setSnackbar(
                  getTranslated(context, 'Cart Update Successfully'), context);
            }
          } else {
            setSnackbar(
                getTranslated(context, 'only Single Seller Product Allow'),
                context);
          }
        } else {
          context
              .read<UpdateFavProvider>()
              .changeStatus(UpdateFavStatus.inProgress);
          if (from == 1) {
            List<Product>? prList = [];
            prList.add(widget.favList[widget.index!]);
            context.read<CartProvider>().addCartItem(
                  SectionModel(
                    qty: qty,
                    productList: prList,
                    varientId: widget
                        .favList[widget.index!]
                        .prVarientList![
                            widget.favList[widget.index!].selVarient!]
                        .id!,
                    id: widget.favList[widget.index!].id,
                    sellerId: widget.favList[widget.index!].seller_id,
                  ),
                );
            db.insertCart(
              widget.favList[widget.index!].id!,
              widget
                  .favList[widget.index!]
                  .prVarientList![widget.favList[widget.index!].selVarient!]
                  .id!,
              qty,
              context,
            );
            context
                .read<FavoriteProvider>()
                .controllerText[widget.index!]
                .text = qty.toString();
            widget.updateNow();
            setSnackbar(
                getTranslated(context, 'PRODUCT_ADDED_TO_CART_LBL'), context);
          } else {
            if (int.parse(qty) >
                widget.favList[widget.index!].itemsCounter!.length) {
              setSnackbar(
                  '${getTranslated(context, "Max Quantity is")}-${int.parse(qty) - 1}',
                  context);
            } else {
              context.read<CartProvider>().updateCartItem(
                    widget.favList[widget.index!].id!,
                    qty,
                    widget.favList[widget.index!].selVarient!,
                    widget
                        .favList[widget.index!]
                        .prVarientList![
                            widget.favList[widget.index!].selVarient!]
                        .id!,
                  );
              db.updateCart(
                widget.favList[widget.index!].id!,
                widget
                    .favList[widget.index!]
                    .prVarientList![widget.favList[widget.index!].selVarient!]
                    .id!,
                qty,
              );
            }
            context
                .read<FavoriteProvider>()
                .controllerText[widget.index!]
                .text = qty.toString();
            setSnackbar(
                getTranslated(context, 'Cart Update Successfully'), context);
          }
        }
        context
            .read<UpdateFavProvider>()
            .changeStatus(UpdateFavStatus.isSuccsess);
        widget.updateNow();
      }
    } else {
      isNetworkAvail = false;

      widget.updateNow();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.index! < widget.favList.length && widget.favList.isNotEmpty) {
      if (context.read<FavoriteProvider>().controllerText.length <
          widget.index! + 1) {
        context
            .read<FavoriteProvider>()
            .controllerText
            .add(TextEditingController());
      }

      double price = double.parse(widget.favList[widget.index!]
          .prVarientList![widget.favList[widget.index!].selVarient!].disPrice!);
      if (price == 0) {
        price = double.parse(widget.favList[widget.index!]
            .prVarientList![widget.favList[widget.index!].selVarient!].price!);
      }
      double off = 0;
      if (widget
              .favList[widget.index!]
              .prVarientList![widget.favList[widget.index!].selVarient!]
              .disPrice !=
          '0') {
        off = (double.parse(widget
                    .favList[widget.index!]
                    .prVarientList![widget.favList[widget.index!].selVarient!]
                    .price!) -
                double.parse(
                  widget
                      .favList[widget.index!]
                      .prVarientList![widget.favList[widget.index!].selVarient!]
                      .disPrice!,
                ))
            .toDouble();
        off = off *
            100 /
            double.parse(widget
                .favList[widget.index!]
                .prVarientList![widget.favList[widget.index!].selVarient!]
                .price!);
      }
      return Consumer<CartProvider>(
        builder: (context, data, _) {
          final tempId = data.cartList.firstWhereOrNull((cp) =>
              cp.id == widget.favList[widget.index!].id &&
              cp.varientId ==
                  widget
                      .favList[widget.index!]
                      .prVarientList![widget.favList[widget.index!].selVarient!]
                      .id!);

          if (tempId != null) {
            context
                .read<FavoriteProvider>()
                .controllerText[widget.index!]
                .text = tempId.qty!;
          } else {
            context
                .read<FavoriteProvider>()
                .controllerText[widget.index!]
                .text = '0';
          }

          /*  SectionModel? tempId = data.firstWhereOrNull((cp) =>
                cp.id == widget.favList[widget.index!].id &&
                cp.varientId ==
                    widget
                        .favList[widget.index!]
                        .prVarientList![
                            widget.favList[widget.index!].selVarient!]
                        .id!);
            if (tempId != null) {
              context
                  .read<FavoriteProvider>()
                  .controllerText[widget.index!]
                  .text = tempId.qty!.toString();
            } else {
              if (context.read<UserProvider>().userId!= null) {
                context
                        .read<FavoriteProvider>()
                        .controllerText[widget.index!]
                        .text =
                    widget
                        .favList[widget.index!]
                        .prVarientList![
                            widget.favList[widget.index!].selVarient!]
                        .cartCount!;
              } else {
                context
                    .read<FavoriteProvider>()
                    .controllerText[widget.index!]
                    .text = '0';
              }
            } */
          return 
           Card(
                elevation: 0,
                child: InkWell(
                  borderRadius: BorderRadius.circular(circularBorderRadius10),
                  // splashColor: colors.primary.withOpacity(0.2),
                  child: Stack(
                    children: [
                      IntrinsicHeight(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Hero(
                              tag:
                                  '$heroTagUniqueString${widget.index}!${widget.favList[widget.index!].id}${widget.index} ${widget.favList[widget.index!].name}',
                              child: ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  topLeft:
                                      Radius.circular(circularBorderRadius4),
                                  bottomLeft:
                                      Radius.circular(circularBorderRadius4),
                                ),
                                child: Stack(
                                  children: [
                                    DesignConfiguration.getCacheNotworkImage(
                                      context: context,
                                      boxFit: BoxFit.cover,
                                      heightvalue: 100.0,
                                      widthvalue: 100.0,
                                      placeHolderSize: 100,
                                      imageurlString:
                                          widget.favList[widget.index!].image!,
                                    ),
                                    Positioned.fill(
                                      child: widget.favList[widget.index!]
                                                  .availability ==
                                              '0'
                                          ? Container(
                                              height: 55,
                                              color: colors.white70,
                                              padding: const EdgeInsets.all(2),
                                              child: Center(
                                                child: Text(
                                                  getTranslated(context,
                                                      'OUT_OF_STOCK_LBL'),
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodySmall!
                                                      .copyWith(
                                                        fontFamily: 'ubuntu',
                                                        color: colors.red,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            )
                                          : const SizedBox(),
                                    ),
                                    // off != 0
                                    //     ? GetDicountLabel(discount: off)
                                    //     : const SizedBox(),
                                  ],
                                ),
                              ),
                            ),
                            const VerticalDivider(
                              width: 0.2,
                              color: Colors.grey,
                              thickness: 0.2,
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsetsDirectional.only(
                                    top: 5.0, start: 5.0, end: 35),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      widget.favList[widget.index!].name!,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall!
                                          .copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .fontColor,
                                            fontFamily: 'ubuntu',
                                            fontWeight: FontWeight.w400,
                                            fontStyle: FontStyle.normal,
                                            fontSize: textFontSize15,
                                          ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          DesignConfiguration.getPriceFormat(
                                              context, price)!,
                                          style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'ubuntu',
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 8,
                                        ),
                                        Text(
                                          double.parse(widget
                                                      .favList[widget.index!]
                                                      .prVarientList![0]
                                                      .disPrice!) !=
                                                  0
                                              ? DesignConfiguration
                                                  .getPriceFormat(
                                                  context,
                                                  double.parse(
                                                    widget
                                                        .favList[widget.index!]
                                                        .prVarientList![0]
                                                        .price!,
                                                  ),
                                                )!
                                              : '',
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelSmall!
                                              .copyWith(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .lightBlack,
                                                fontFamily: 'ubuntu',
                                                decoration:
                                                    TextDecoration.lineThrough,
                                                decorationColor:
                                                    colors.darkColor3,
                                                decorationStyle:
                                                    TextDecorationStyle.solid,
                                                decorationThickness: 2,
                                                letterSpacing: 0,
                                              ),
                                        ),
                                        const SizedBox(
                                          width: 8,
                                        ),
                                        off != 0
                                            ? Text(
                                                '${off.toStringAsFixed(2)}%',
                                                style: const TextStyle(
                                                  color: colors.green,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: textFontSize9,
                                                ),
                                              )
                                            : const SizedBox()
                                      ],
                                    ),
                                    const SizedBox(height: 20,),
                                    if (cartBtnList)
                                  
                                    context
                                                .read<FavoriteProvider>()
                                                .controllerText[widget.index!]
                                                .text ==
                                            '0' && (widget.favList[widget.index!]
                                                      .availability ==
                                                  '' ||
                                              widget.favList[widget.index!]
                                                      .availability ==
                                                  '1')
                                          ? InkWell(
                                                  onTap: () async {
                                                    print(
                                                        'get fav current status***${context.read<UpdateFavProvider>().getCurrentStatus}');
                                                    if (context
                                                            .read<
                                                                UpdateFavProvider>()
                                                            .getCurrentStatus !=
                                                        UpdateFavStatus
                                                            .inProgress) {
                                                      await addToCart(
                                                        '1',
                                                        1,
                                                      ); /* .then(
                                (value) {
                                  Future.delayed(const Duration(seconds: 3))
                                      .then(
                                    (_) async {
                                      /* context
                                            .read<UserProvider>()
                                            .setCartCount(context
                                                    .read<UpdateFavProvider>()
                                                    .cartCount ??
                                                '0');*/
          
                                      widget.updateNow();
                                    },
                                  );
                                },
                              ); */
                                                    }
                                                  },
                                                  child: Container(
                                                    height: 25,
                                                    width: 80,
                                                    decoration: BoxDecoration(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .white,
                                                      border: Border.all(
                                                          color:
                                                              Theme.of(context)
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
                                                    child: Row(
                                                      children: [
                                                        Expanded(
                                                          flex: 3,
                                                          child: Text(
                                                            getTranslated(
                                                                context, 'ADD'),
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .titleMedium!
                                                                .copyWith(
                                                                  color: Theme.of(
                                                                          context)
                                                                      .colorScheme
                                                                      .black,
                                                                  fontSize:
                                                                      textFontSize13,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .normal,
                                                                  fontFamily:
                                                                      'ubuntu',
                                                                ),
                                                          ),
                                                        ),
                                                        Expanded(
                                                            flex: 1,
                                                            child: Container(
                                                              height: 35,
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: Theme.of(
                                                                        context)
                                                                    .colorScheme
                                                                    .gray,
                                                                border: Border.all(
                                                                    color: Theme.of(
                                                                            context)
                                                                        .colorScheme
                                                                        .gray,
                                                                    width: 1),
                                                                borderRadius:
                                                                    const BorderRadiusDirectional
                                                                        .only(
                                                                  bottomEnd: Radius
                                                                      .circular(
                                                                          circularBorderRadius7),
                                                                  topEnd: Radius
                                                                      .circular(
                                                                          circularBorderRadius7),
                                                                ),
                                                              ),
                                                              child: Icon(
                                                                Icons.add,
                                                                color: Theme.of(
                                                                        context)
                                                                    .colorScheme
                                                                    .black,
                                                                size: 15,
                                                              ),
                                                            ))
                                                      ],
                                                    ),
                                                  ),
                                                  )
                                          : const SizedBox(),
                                   
                                    context
                                                .read<FavoriteProvider>()
                                                .controllerText[widget.index!]
                                                .text !=
                                            '0'
                                        ?
                                         widget.favList[widget.index!]
                                                          .availability ==
                                                      '0'
                                                  ? const SizedBox()
                                                  : cartBtnList
                                                      ? Row(
                                                        children: <Widget>[
                                                          InkWell(
                                                            child:
                                                                Container(
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: Theme.of(
                                                                        context)
                                                                    .colorScheme
                                                                    .white,
                                                                border: Border.all(
                                                                    color: Theme.of(context)
                                                                        .colorScheme
                                                                        .gray,
                                                                    width:
                                                                        1),
                                                                borderRadius:
                                                                    const BorderRadiusDirectional
                                                                        .all(
                                                                  Radius.circular(
                                                                      circularBorderRadius7),
                                                                ),
                                                              ),
                                                              child:
                                                                  Padding(
                                                                padding:
                                                                    EdgeInsets.all(
                                                                        4.0),
                                                                child:
                                                                    Icon(
                                                                  Icons
                                                                      .remove,
                                                                  size:
                                                                      15,
                                                                  color: Theme.of(context)
                                                                      .colorScheme
                                                                      .black,
                                                                ),
                                                              ),
                                                            ),
                                                            onTap: () {
                                                              if (int.parse(context.read<FavoriteProvider>().controllerText[widget.index!].text) >
                                                                      0 &&
                                                                  context.read<UpdateFavProvider>().getCurrentStatus !=
                                                                      UpdateFavStatus.inProgress) {
                                                                removeFromCart(
                                                                  widget
                                                                      .index!,
                                                                  widget
                                                                      .favList,
                                                                  context,
                                                                );
                                                              }
                                                            },
                                                          ),
                                                          Container(
                                                            width: 37,
                                                            height: 20,
                                                            decoration:
                                                                BoxDecoration(
                                                              color: Theme.of(
                                                                      context)
                                                                  .colorScheme
                                                                  .white,
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                      circularBorderRadius5),
                                                            ),
                                                            child: Stack(
                                                              children: [
                                                                TextField(
                                                                  textAlign:
                                                                      TextAlign.center,
                                                                  readOnly:
                                                                      true,
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        textFontSize12,
                                                                    color: Theme.of(context)
                                                                        .colorScheme
                                                                        .fontColor,
                                                                  ),
                                                                  controller: context
                                                                      .read<FavoriteProvider>()
                                                                      .controllerText[widget.index!],
                                                                  decoration:
                                                                      const InputDecoration(
                                                                    border:
                                                                        InputBorder.none,
                                                                  ),
                                                                ),
                                                                PopupMenuButton<
                                                                    String>(
                                                                  tooltip:
                                                                      '',
                                                                  icon:
                                                                      const Icon(
                                                                    Icons
                                                                        .arrow_drop_down,
                                                                    size:
                                                                        1,
                                                                  ),
                                                                  onSelected:
                                                                      (String
                                                                          value) {
                                                                    if (context.read<UpdateFavProvider>().getCurrentStatus !=
                                                                        UpdateFavStatus.inProgress) {
                                                                      addToCart(
                                                                        value,
                                                                        2,
                                                                      );
                                                                    }
                                                                  },
                                                                  itemBuilder:
                                                                      (BuildContext
                                                                          context) {
                                                                    return widget
                                                                        .favList[widget.index!]
                                                                        .itemsCounter!
                                                                        .map<PopupMenuItem<String>>(
                                                                      (String
                                                                          value) {
                                                                        return PopupMenuItem(
                                                                          value: value,
                                                                          child: Text(
                                                                            value,
                                                                            style: TextStyle(
                                                                              fontFamily: 'ubuntu',
                                                                              color: Theme.of(context).colorScheme.fontColor,
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
                                                          InkWell(
                                                            child:
                                                                Container(
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: Theme.of(
                                                                        context)
                                                                    .colorScheme
                                                                    .white,
                                                                border: Border.all(
                                                                    color: Theme.of(context)
                                                                        .colorScheme
                                                                        .gray,
                                                                    width:
                                                                        1),
                                                                borderRadius:
                                                                    const BorderRadiusDirectional
                                                                        .all(
                                                                  Radius.circular(
                                                                      circularBorderRadius7),
                                                                ),
                                                              ),
                                                              child:
                                                                  Padding(
                                                                padding:
                                                                    EdgeInsets.all(
                                                                        4.0),
                                                                child:
                                                                    Icon(
                                                                  Icons
                                                                      .add,
                                                                  size:
                                                                      15,
                                                                  color: Theme.of(context)
                                                                      .colorScheme
                                                                      .black,
                                                                ),
                                                              ),
                                                            ),
                                                            onTap:
                                                                () async {
                                                              print(
                                                                  'current fav status***${context.read<UpdateFavProvider>().getCurrentStatus}');
                                                              if (context
                                                                      .read<
                                                                          UpdateFavProvider>()
                                                                      .getCurrentStatus !=
                                                                  UpdateFavStatus
                                                                      .inProgress) {
                                                                addToCart(
                                                                  (int.parse(context.read<FavoriteProvider>().controllerText[widget.index!].text) +
                                                                          int.parse(widget.favList[widget.index!].qtyStepSize!))
                                                                      .toString(),
                                                                  2,
                                                                );
                                                              }
                                                            },
                                                          )
                                                        ],
                                                      )
                                                      : const SizedBox()
                                        : const SizedBox(),
                                  
                                  ],
                                ),
                              ),
                            ),
                          
                          
                          ],
                        ),
                      
                      ),
                      if (widget.favList[widget.index!].noOfRating! != '0')
                        Positioned(
                            bottom: 5,
                            right: 5,
                            child: RatingCartForProduct(
                                noOfRating:
                                    widget.favList[widget.index!].noOfRating!,
                                totalRating:
                                    widget.favList[widget.index!].rating!)),
                      
                      Positioned.directional(
                        textDirection: Directionality.of(context),
                        end: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.only(
                            right: 5,
                            top: 5.0,
                          ),
                          alignment: Alignment.topRight,
                          child: InkWell(
                            child: Icon(
                              Icons.close,
                              color: Theme.of(context).colorScheme.fontColor,
                            ),
                            onTap: () {
                              if (context.read<UserProvider>().userId != '') {
                                Future.delayed(Duration.zero).then(
                                  (value) => context
                                      .read<UpdateFavProvider>()
                                      .removeFav(
                                          widget.favList[widget.index!].id!,
                                          widget.favList[widget.index!]
                                              .prVarientList![0].id!,
                                          context),
                                );
                              } else {
                                db.addAndRemoveFav(
                                    widget.favList[widget.index!].id!, false);
                                context.read<FavoriteProvider>().removeFavItem(
                                    widget.favList[widget.index!]
                                        .prVarientList![0].id!);

                                setSnackbar(
                                    getTranslated(
                                        context, 'Removed from favorite'),
                                    context);
                              }
                            },
                          ),
                        ),
                      ),
                   
                    ],
                  ),
                
                  onTap: () {
                    Product model = widget.favList[widget.index!];
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (_, __, ___) => ProductDetail(
                          model: model,
                          secPos: 0,
                          index: widget.index!,
                          list: true,
                        ),
                      ),
                    );
                  },
                  ),
              );
            
          // Stack(
          //   // clipBehavior: Clip.none,
          //   children: [
          //     ],
          // );
        },
      );
    } else {
      return const SizedBox();
    }
  }
}
