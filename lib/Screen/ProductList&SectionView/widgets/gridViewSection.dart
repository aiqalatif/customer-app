import 'dart:async';
import 'package:eshop_multivendor/Helper/ApiBaseHelper.dart';
import 'package:eshop_multivendor/Provider/UserProvider.dart';
import 'package:eshop_multivendor/widgets/customfevoritebuttonforCards.dart';
import 'package:eshop_multivendor/widgets/ratingCardForProduct.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../Helper/Color.dart';
import '../../../Helper/Constant.dart';
import '../../../Helper/String.dart';
import '../../../Model/Section_Model.dart';
import '../../../Provider/CartProvider.dart';
import '../../../Provider/Favourite/FavoriteProvider.dart';
import '../../../widgets/desing.dart';
import '../../Language/languageSettings.dart';
import '../../../widgets/networkAvailablity.dart';
import '../../../widgets/snackbar.dart';
import '../../../widgets/star_rating.dart';
import '../../Dashboard/Dashboard.dart';
import '../../Product Detail/productDetail.dart';
import '../SectionList.dart';
import 'package:collection/src/iterable_extensions.dart';

class GridViewWidget extends StatefulWidget {
  final int? index;
  SectionModel? section_model;
  final int from;
  Function setState;

  GridViewWidget({
    Key? key,
    this.index,
    this.section_model,
    required this.from,
    required this.setState,
  }) : super(key: key);

  @override
  State<GridViewWidget> createState() => _GridViewWidgetState();
}

class _GridViewWidgetState extends State<GridViewWidget> {
  final TextEditingController controllerText = TextEditingController();
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    controllerText.dispose();

    super.dispose();
  }

  removeFav(
    int index,
  ) async {
    isNetworkAvail = await isNetworkAvailable();
    if (isNetworkAvail) {
      try {
        widget.section_model!.productList![index].isFavLoading = true;
        widget.setState();

        var parameter = {
          PRODUCT_ID: widget.section_model!.productList![index].id
        };
        ApiBaseHelper().postAPICall(removeFavApi, parameter).then((getdata) {
          bool error = getdata['error'];
          String? msg = getdata['message'];
          if (!error) {
            widget.section_model!.productList![index].isFav = '0';

            context.read<FavoriteProvider>().removeFavItem(widget
                .section_model!.productList![index].prVarientList![0].id!);
            setSnackbar(msg!, context);
          } else {
            setSnackbar(msg!, context);
          }

          widget.section_model!.productList![index].isFavLoading = false;
          widget.setState();
        }, onError: (error) {
          setSnackbar(error.toString(), context);
        });
      } on TimeoutException catch (_) {
        setSnackbar(getTranslated(context, 'somethingMSg'), context);
      }
    } else {
      isNetworkAvail = false;
      widget.setState();
    }
  }

  _setFav(int index) async {
    isNetworkAvail = await isNetworkAvailable();
    if (isNetworkAvail) {
      try {
        if (mounted) {
          widget.section_model!.productList![index].isFavLoading = true;
          widget.setState();
        }

        var parameter = {
          PRODUCT_ID: widget.section_model!.productList![index].id
        };

        ApiBaseHelper().postAPICall(setFavoriteApi, parameter).then(
          (getdata) {
            bool error = getdata['error'];
            String? msg = getdata['message'];
            if (!error) {
              widget.section_model!.productList![index].isFav = '1';
              context
                  .read<FavoriteProvider>()
                  .addFavItem(widget.section_model!.productList![index]);
              setSnackbar(msg!, context);
            } else {
              setSnackbar(msg!, context);
            }

            if (mounted) {
              widget.section_model!.productList![index].isFavLoading = false;
              widget.setState();
            }
          },
          onError: (error) {
            setSnackbar(error.toString(), context);
          },
        );
      } on TimeoutException catch (_) {
        setSnackbar(getTranslated(context, 'somethingMSg'), context);
      }
    } else {
      if (mounted) {
        isNetworkAvail = false;
        widget.setState();
      }
    }
  }

  removeFromCart(int index) async {
    Product model;
    if (widget.from == 1) {
      model = widget.section_model!.productList![index];
    } else {
      model = widget.section_model!.productList![index];
    }
    isNetworkAvail = await isNetworkAvailable();
    if (isNetworkAvail) {
      if (context.read<UserProvider>().userId != '') {
        try {
          if (mounted) {
            isProgress = true;
            widget.setState();
          }

          int qty;

          qty =
              (int.parse(controllerText.text) - int.parse(model.qtyStepSize!));

          if (qty < model.minOrderQuntity!) {
            qty = 0;
          }

          var parameter = {
            PRODUCT_VARIENT_ID: model.prVarientList![0].id,
            QTY: qty.toString()
          };
          ApiBaseHelper().postAPICall(manageCartApi, parameter).then(
            (getdata) {
              bool error = getdata['error'];
              String? msg = getdata['message'];
              if (!error) {
                var data = getdata['data'];

                String? qty = data['total_quantity'];

                userProvider.setCartCount(data['cart_count']);
                model.prVarientList![0].cartCount = qty.toString();

                var cart = getdata['cart'];
                List<SectionModel> cartList = (cart as List)
                    .map((cart) => SectionModel.fromCart(cart))
                    .toList();
                context.read<CartProvider>().setCartlist(cartList);
              } else {
                setSnackbar(msg!, context);
              }
              if (mounted) {
                isProgress = false;
                widget.setState();
              }
            },
            onError: (error) {
              setSnackbar(error.toString(), context);
            },
          );
        } on TimeoutException catch (_) {
          setSnackbar(getTranslated(context, 'somethingMSg'), context);
          if (mounted) {
            isProgress = false;
            widget.setState();
          }
        }
      } else {
        isProgress = true;
        widget.setState();

        int qty;

        qty = (int.parse(controllerText.text) - int.parse(model.qtyStepSize!));

        if (qty < model.minOrderQuntity!) {
          qty = 0;
          context
              .read<CartProvider>()
              .removeCartItem(model.prVarientList![0].id!);
          db.removeCart(model.prVarientList![0].id!, model.id!, context);
        } else {
          context.read<CartProvider>().updateCartItem(
              model.id!, qty.toString(), 0, model.prVarientList![0].id!);
          db.updateCart(
            model.id!,
            model.prVarientList![0].id!,
            qty.toString(),
          );
        }
        isProgress = false;
        widget.setState();
      }
    } else {
      if (mounted) {
        isNetworkAvail = false;
        widget.setState();
      }
    }
  }

  Future<void> addToCart(int index, String qty, int from) async {
    Product model;
    if (widget.from == 1) {
      model = widget.section_model!.productList![index];
    } else {
      model = widget.section_model!.productList![index];
    }
    isNetworkAvail = await isNetworkAvailable();
    if (isNetworkAvail) {
      if (context.read<UserProvider>().userId != '') {
        try {
          if (mounted) {
            isProgress = true;
            widget.setState();
          }

          if (int.parse(qty) < model.minOrderQuntity!) {
            qty = model.minOrderQuntity.toString();

            setSnackbar("${getTranslated(context, 'MIN_MSG')}$qty", context);
          }

          var parameter = {
            PRODUCT_VARIENT_ID: model.prVarientList![0].id,
            QTY: qty
          };

          ApiBaseHelper().postAPICall(manageCartApi, parameter).then(
            (getdata) {
              bool error = getdata['error'];
              String? msg = getdata['message'];
              if (!error) {
                var data = getdata['data'];

                String? qty = data['total_quantity'];

                userProvider.setCartCount(data['cart_count']);
                model.prVarientList![0].cartCount = qty.toString();

                var cart = getdata['cart'];

                List<SectionModel> cartList = (cart as List)
                    .map((cart) => SectionModel.fromCart(cart))
                    .toList();
                context.read<CartProvider>().setCartlist(cartList);
              } else {
                setSnackbar(msg!, context);
              }
              if (mounted) {
                isProgress = false;
                widget.setState();
              }
            },
            onError: (error) {
              setSnackbar(error.toString(), context);
            },
          );
        } on TimeoutException catch (_) {
          setSnackbar(getTranslated(context, 'somethingMSg'), context);
          if (mounted) {
            isProgress = false;
            widget.setState();
          }
        }
      } else {
        isProgress = true;
        widget.setState();

        if (singleSellerOrderSystem) {
          if (CurrentSellerID == '' || CurrentSellerID == model.seller_id) {
            CurrentSellerID = model.seller_id!;
            if (from == 1) {
              List<Product>? prList = [];
              prList.add(model);
              context.read<CartProvider>().addCartItem(
                    SectionModel(
                      qty: qty,
                      productList: prList,
                      varientId: model.prVarientList![0].id!,
                      id: model.id,
                      sellerId: model.seller_id,
                    ),
                  );
              db.insertCart(
                model.id!,
                model.prVarientList![0].id!,
                qty,
                context,
              );
              setSnackbar(
                  getTranslated(context, 'PRODUCT_ADDED_TO_CART_LBL'), context);
            } else {
              if (int.parse(qty) > int.parse(model.itemsCounter!.last)) {
                setSnackbar(
                    "${getTranslated(context, 'MAXQTY')} ${int.parse(model.itemsCounter!.last)}",
                    context);
              } else {
                context.read<CartProvider>().updateCartItem(
                    model.id!, qty, 0, model.prVarientList![0].id!);
                db.updateCart(
                  model.id!,
                  model.prVarientList![0].id!,
                  qty,
                );
                setSnackbar(getTranslated(context, 'Cart Update Successfully'),
                    context);
              }
            }
          }
        } else {
          if (from == 1) {
            List<Product>? prList = [];
            prList.add(model);
            context.read<CartProvider>().addCartItem(
                  SectionModel(
                    qty: qty,
                    productList: prList,
                    varientId: model.prVarientList![0].id!,
                    id: model.id,
                    sellerId: model.seller_id,
                  ),
                );
            db.insertCart(
              model.id!,
              model.prVarientList![0].id!,
              qty,
              context,
            );
            setSnackbar(
                getTranslated(context, 'PRODUCT_ADDED_TO_CART_LBL'), context);
          } else {
            if (int.parse(qty) > int.parse(model.itemsCounter!.last)) {
              setSnackbar(
                  "${getTranslated(context, 'MAXQTY')} ${int.parse(model.itemsCounter!.last)}",
                  context);
            } else {
              context.read<CartProvider>().updateCartItem(
                  model.id!, qty, 0, model.prVarientList![0].id!);
              db.updateCart(
                model.id!,
                model.prVarientList![0].id!,
                qty,
              );
              setSnackbar(
                  getTranslated(context, 'Cart Update Successfully'), context);
            }
          }
        }
        isProgress = false;
        widget.setState();
      }
    } else {
      if (mounted) {
        isNetworkAvail = false;
        widget.setState();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.index! < widget.section_model!.productList!.length) {
      Product model = widget.section_model!.productList![widget.index!];

      double width = deviceWidth! * 0.5 - 20;
      double price = double.parse(model.prVarientList![0].disPrice!);
      List att = [], val = [];
      if (model.prVarientList![0].attr_name != null) {
        att = model.prVarientList![0].attr_name!.split(',');
        val = model.prVarientList![0].varient_value!.split(',');
      }

      if (price == 0) {
        price = double.parse(model.prVarientList![0].price!);
      }

      double off = 0;
      if (model.prVarientList![0].disPrice! != '0') {
         off = (double.parse(model.prVarientList![0].price!) -
              double.parse(model.prVarientList![0].disPrice!))
          .toDouble();
      off = off * 100 / double.parse(model.prVarientList![0].price!);
      }
      
      return Consumer<CartProvider>(
        builder: (context, data, _) {
          final tempId = data.cartList.firstWhereOrNull((cp) =>
              cp.id == model.id && cp.varientId == model.prVarientList![0].id!);

          if (tempId != null) {
            controllerText.text = tempId.qty!;
          } else {
            controllerText.text = '0';
          }

          return  InkWell(
            child: Card(
              shape: RoundedRectangleBorder(
                side: BorderSide(
                    color: Theme.of(context).colorScheme.gray, width: 1),
                borderRadius: BorderRadius.circular(3),
              ),
              elevation: 0.2,
              margin: EdgeInsetsDirectional.only(
                  bottom: 10, end: 10, ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    flex: cartBtnList ? 4 : 6,
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      clipBehavior: Clip.none,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(circularBorderRadius5),
                            topRight: Radius.circular(circularBorderRadius5),
                          ),
                          child: Hero(
                            tag:
                                '$heroTagUniqueString${widget.index}${model.id}',
                            child: DesignConfiguration.getCacheNotworkImage(
                              boxFit: BoxFit.cover,
                              context: context,
                              heightvalue: double.maxFinite,
                              widthvalue: double.maxFinite,
                              placeHolderSize: width,
                              imageurlString: model.image!,
                            ),
                          ),
                        ),
                        Positioned.fill(
                          child:
                              model.prVarientList![0].availability == '0'
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
                                                color: colors.red,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'ubuntu',
                                              ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    )
                                  : const SizedBox(),
                        ),
                        const Divider(
                          height: 1,
                        ),
                        if (widget.section_model!.productList![widget.index!].noOfRating! !=
                            '0')
                          Positioned(
                              bottom: 0,
                              right: 0,
                              child: RatingCartForProduct(
                                  noOfRating: widget.section_model!.productList![widget.index!].noOfRating!,
                                  totalRating: widget.section_model!.productList![widget.index!].rating!)),
                        Positioned(
                          top: 0,
                          right: 0,
                          child:
                              CustomFevoriteButtonForCart(model: model),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsetsDirectional.only(
                            start: 5.0, top: 10, end: 5),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.section_model!.productList![widget.index!].name!,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall!
                                  .copyWith(
                                    color:
                                        Theme.of(context).colorScheme.fontColor,
                                    fontSize: textFontSize12,
                                    fontWeight: FontWeight.w400,
                                    fontStyle: FontStyle.normal,
                                    fontFamily: 'ubuntu',
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              softWrap: true,
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            Row(
                              children: [
                                Text(
                                  '${DesignConfiguration.getPriceFormat(context, price)!}',
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    fontSize: textFontSize14,
                                    fontWeight: FontWeight.w700,
                                    fontStyle: FontStyle.normal,
                                    fontFamily: 'ubuntu',
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsetsDirectional.only(
                                      start: 5.0,
                                      // top: 5,
                                    ),
                                    child: Row(
                                      children: <Widget>[
                                        Text(
                                          double.parse(widget.section_model!.productList![
                                                          widget.index!]
                                                      .prVarientList![0]
                                                      .disPrice!) !=
                                                  0
                                              ? '${DesignConfiguration.getPriceFormat(context, double.parse(widget.section_model!.productList![widget.index!].prVarientList![0].price!))}'
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
                                                fontSize: textFontSize9,
                                                fontWeight: FontWeight.w400,
                                                fontStyle: FontStyle.normal,
                                              ),
                                        ),
                                        off != 0
                                            ? Text(
                                                '  ${off.toStringAsFixed(2)}%',
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .labelSmall!
                                                    .copyWith(
                                                      fontFamily: 'ubuntu',
                                                      color: colors.green,
                                                      letterSpacing: 0,
                                                      fontSize: textFontSize9,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontStyle:
                                                          FontStyle.normal,
                                                    ),
                                              )
                                            : SizedBox()
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            if (cartBtnList)
                              model.prVarientList![0].availability == '0'
                                  ? const SizedBox()
                                  : controllerText.text == '0'
                                      ? InkWell(
                                          onTap: () {
                                            if (isProgress == false) {
                                              addToCart(
                                                widget.index!,
                                                (int.parse(controllerText
                                                            .text) +
                                                        int.parse(
                                                          model
                                                              .qtyStepSize!,
                                                        ))
                                                    .toString(),
                                                1,
                                              );
                                            }
                                          },
                                          child: Container(
                                            height: 25,
                                            width: 90,
                                            decoration: BoxDecoration(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .white,
                                              border: Border.all(
                                                  color: Theme.of(context)
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
                                                    textAlign: TextAlign.center,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .titleMedium!
                                                        .copyWith(
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .black,
                                                          fontSize:
                                                              textFontSize9,
                                                          fontWeight:
                                                              FontWeight.normal,
                                                          fontFamily: 'ubuntu',
                                                        ),
                                                  ),
                                                ),
                                                Expanded(
                                                    flex: 1,
                                                    child: Container(
                                                      height: 35,
                                                      decoration: BoxDecoration(
                                                        color: Theme.of(context)
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
                                                          bottomEnd:
                                                              Radius.circular(
                                                                  circularBorderRadius7),
                                                          topEnd: Radius.circular(
                                                              circularBorderRadius7),
                                                        ),
                                                      ),
                                                      child: Icon(
                                                        Icons.add,
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .black,
                                                        size: 15,
                                                      ),
                                                    ))
                                              ],
                                            ),
                                          )
                                          )
                                      : Row(
                                        children: <Widget>[
                                          InkWell(
                                            child: Container(
                                              decoration: BoxDecoration(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .white,
                                              border: Border.all(
                                                  color: Theme.of(context)
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
                                              //   borderRadius:
                                              //       BorderRadius.circular(
                                              //           circularBorderRadius7),
                                              // ),
                                              child:  Padding(
                                                padding:
                                                    EdgeInsets.all(4.0),
                                                child: Icon(
                                                  Icons.remove,
                                                  size: 15,
                                                  color: Theme.of(context).colorScheme.black,
                                                ),
                                              ),
                                            ),
                                            onTap: () {
                                              if (isProgress == false &&
                                                  (int.parse(controllerText
                                                          .text) >
                                                      0)) {
                                                removeFromCart(
                                                    widget.index!);
                                              }
                                            },
                                          ),
                                          Container(
                                            width: 37,
                                            height: 20,
                                            decoration: BoxDecoration(
                                              color: Theme.of(context)
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
                                                  readOnly: true,
                                                  style: TextStyle(
                                                      fontSize:
                                                          textFontSize12,
                                                      color:
                                                          Theme.of(context)
                                                              .colorScheme
                                                              .fontColor),
                                                  controller:
                                                      controllerText,
                                                  decoration:
                                                      const InputDecoration(
                                                    border:
                                                        InputBorder.none,
                                                  ),
                                                ),
                                                PopupMenuButton<String>(
                                                  tooltip: '',
                                                  icon: const Icon(
                                                    Icons.arrow_drop_down,
                                                    size: 0,
                                                  ),
                                                  onSelected:
                                                      (String value) {
                                                    if (isProgress ==
                                                        false) {
                                                      addToCart(
                                                          widget.index!,
                                                          value,
                                                          2);
                                                    }
                                                  },
                                                  itemBuilder: (BuildContext
                                                      context) {
                                                    return model
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
                                          InkWell(
                                            child: Container(
                                              decoration: BoxDecoration(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .white,
                                              border: Border.all(
                                                  color: Theme.of(context)
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
                                              child:  Padding(
                                                padding:
                                                    EdgeInsets.all(4.0),
                                                child: Icon(
                                                  Icons.add,
                                                  size: 15,
                                                  color: Theme.of(context).colorScheme.black,
                                                ),
                                              ),
                                            ),
                                            onTap: () {
                                              if (isProgress == false) {
                                                addToCart(
                                                    widget.index!,
                                                    (int.parse(controllerText
                                                                .text) +
                                                            int.parse(
                                                                model
                                                                    .qtyStepSize!))
                                                        .toString(),
                                                    2);
                                              }
                                            },
                                          )
                                        ],
                                      ),
                          ],
                        ),
                      ))
                ],
              ),
            ),
            onTap: () {
              Product model = widget.section_model!.productList![widget.index!];
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => ProductDetail(
                    model: model,
                    index: widget.index,
                    secPos: 0,
                    list: true,
                  ),
                ),
              );
            },
          );
       },
      );
    } else {
      return const SizedBox();
    }
  }
}

