import 'dart:async';
import 'package:eshop_multivendor/Provider/Favourite/UpdateFavProvider.dart';
import 'package:eshop_multivendor/widgets/customfevoritebuttonforCards.dart';
import 'package:eshop_multivendor/widgets/ratingCardForProduct.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Helper/Color.dart';
import '../Helper/Constant.dart';
import '../Helper/String.dart';
import '../Model/Section_Model.dart';
import '../Provider/CartProvider.dart';
import '../Provider/Favourite/FavoriteProvider.dart';
import '../Provider/UserProvider.dart';
import 'desing.dart';
import '../Screen/Language/languageSettings.dart';
import 'networkAvailablity.dart';
import 'snackbar.dart';
import 'star_rating.dart';
import '../Screen/Dashboard/Dashboard.dart';
import '../Screen/Product Detail/productDetail.dart';
import '../Screen/ProductList&SectionView/ProductList.dart';
import 'package:collection/src/iterable_extensions.dart';

class GridViewProductListWidget extends StatefulWidget {
  List<Product>? productList;
  final int index;
  bool pad;

  Function setState;

  GridViewProductListWidget({
    Key? key,
    this.productList,
    required this.index,
    required this.pad,
    required this.setState,
  }) : super(key: key);

  @override
  State<GridViewProductListWidget> createState() =>
      _GridViewProductListWidgetState();
}

class _GridViewProductListWidgetState extends State<GridViewProductListWidget> {
  final TextEditingController controllerText = TextEditingController();

   @override
  void dispose() {
    controllerText.dispose();

    super.dispose();
  }

  _removeFav(int index, Product model) async {
    isNetworkAvail = await isNetworkAvailable();
    if (isNetworkAvail) {
      try {
        if (mounted) {
          index == -1
              ? model.isFavLoading = true
              : widget.productList![index].isFavLoading = true;
          widget.setState();
        }

        var parameter = {
          // USER_ID: context.read<UserProvider>().userId,
          PRODUCT_ID: model.id
        };
        apiBaseHelper.postAPICall(removeFavApi, parameter).then((getdata) {
          bool error = getdata['error'];
          String? msg = getdata['message'];
          if (!error) {
            index == -1
                ? model.isFav = '0'
                : widget.productList![index].isFav = '0';
            context
                .read<FavoriteProvider>()
                .removeFavItem(model.prVarientList![0].id!);
            setSnackbar(msg!, context);
          } else {
            setSnackbar(msg!, context);
          }

          if (mounted) {
            index == -1
                ? model.isFavLoading = false
                : widget.productList![index].isFavLoading = false;
            widget.setState();
          }
        }, onError: (error) {
          setSnackbar(error.toString(), context);
        });
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

  _setFav(int index, Product model) async {
    isNetworkAvail = await isNetworkAvailable();
    if (isNetworkAvail) {
      try {
        if (mounted) {
          index == -1
              ? model.isFavLoading = true
              : widget.productList![index].isFavLoading = true;
          widget.setState();
        }

        var parameter = {
          // USER_ID: context.read<UserProvider>().userId,
          PRODUCT_ID: model.id
        };
        apiBaseHelper.postAPICall(setFavoriteApi, parameter).then((getdata) {
          bool error = getdata['error'];
          String? msg = getdata['message'];
          if (!error) {
            index == -1
                ? model.isFav = '1'
                : widget.productList![index].isFav = '1';

            context.read<FavoriteProvider>().addFavItem(model);
            setSnackbar(msg!, context);
          } else {
            setSnackbar(msg!, context);
          }

          if (mounted) {
            index == -1
                ? model.isFavLoading = false
                : widget.productList![index].isFavLoading = false;
            widget.setState();
          }
        }, onError: (error) {
          setSnackbar(error.toString(), context);
        });
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
    isNetworkAvail = await isNetworkAvailable();
    if (isNetworkAvail) {
      if (context.read<UserProvider>().userId != '') {
        if (mounted) {
          isProgress = true;
          widget.setState();
        }

        int qty;

        qty = (int.parse(controllerText.text) -
            int.parse(widget.productList![index].qtyStepSize!));

        if (qty < widget.productList![index].minOrderQuntity!) {
          qty = 0;
        }

        var parameter = {
          PRODUCT_VARIENT_ID: widget.productList![index].prVarientList![0].id,
          // USER_ID: context.read<UserProvider>().userId,
          QTY: qty.toString()
        };

        apiBaseHelper.postAPICall(manageCartApi, parameter).then((getdata) {
          bool error = getdata['error'];
          String? msg = getdata['message'];
          if (!error) {
            var data = getdata['data'];

            String? qty = data['total_quantity'];

            context.read<UserProvider>().setCartCount(data['cart_count']);
            widget.productList![index].prVarientList![0].cartCount =
                qty.toString();

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
        }, onError: (error) {
          setSnackbar(error.toString(), context);
          isProgress = false;
        });
        widget.setState();
      } else {
        isProgress = true;
        widget.setState();

        int qty;

        qty = (int.parse(controllerText.text) -
            int.parse(widget.productList![index].qtyStepSize!));

        if (qty < widget.productList![index].minOrderQuntity!) {
          qty = 0;
          db.removeCart(widget.productList![index].prVarientList![0].id!,
              widget.productList![index].id!, context);
          context
              .read<CartProvider>()
              .removeCartItem(widget.productList![index].prVarientList![0].id!);
        } else {
          context.read<CartProvider>().updateCartItem(
              widget.productList![index].id!,
              qty.toString(),
              0,
              widget.productList![index].prVarientList![0].id!);
          db.updateCart(
            widget.productList![index].id!,
            widget.productList![index].prVarientList![0].id!,
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
    isNetworkAvail = await isNetworkAvailable();
    if (isNetworkAvail) {
      if (context.read<UserProvider>().userId != '') {
        if (mounted) {
          isProgress = true;
          widget.setState();
        }

        if (int.parse(qty) < widget.productList![index].minOrderQuntity!) {
          qty = widget.productList![index].minOrderQuntity.toString();

          setSnackbar("${getTranslated(context, 'MIN_MSG')}$qty", context);
        }

        var parameter = {
          // USER_ID: context.read<UserProvider>().userId,
          PRODUCT_VARIENT_ID: widget.productList![index].prVarientList![0].id,
          QTY: qty
        };

        apiBaseHelper.postAPICall(manageCartApi, parameter).then(
          (getdata) {
            bool error = getdata['error'];
            String? msg = getdata['message'];
            if (!error) {
              var data = getdata['data'];

              String? qty = data['total_quantity'];
              context.read<UserProvider>().setCartCount(data['cart_count']);
              widget.productList![index].prVarientList![0].cartCount =
                  qty.toString();

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
            if (mounted) {
              isProgress = false;
              widget.setState();
            }
          },
        );
      } else {
        isProgress = true;
        widget.setState();

        if (singleSellerOrderSystem) {
          if (CurrentSellerID == '' ||
              CurrentSellerID == widget.productList![index].seller_id) {
            CurrentSellerID = widget.productList![index].seller_id!;
            if (from == 1) {
              List<Product>? prList = [];
              prList.add(widget.productList![index]);
              context.read<CartProvider>().addCartItem(
                    SectionModel(
                      qty: qty,
                      productList: prList,
                      varientId:
                          widget.productList![index].prVarientList![0].id!,
                      id: widget.productList![index].id,
                      sellerId: widget.productList![index].seller_id,
                    ),
                  );
              db.insertCart(
                widget.productList![index].id!,
                widget.productList![index].prVarientList![0].id!,
                qty,
                context,
              );
              setSnackbar(
                  getTranslated(context, 'PRODUCT_ADDED_TO_CART_LBL'), context);
            } else {
              if (int.parse(qty) >
                  int.parse(widget.productList![index].itemsCounter!.last)) {
                setSnackbar(
                    "${getTranslated(context, 'MAXQTY')} ${widget.productList![index].itemsCounter!.last}",
                    context);
              } else {
                context.read<CartProvider>().updateCartItem(
                    widget.productList![index].id!,
                    qty,
                    0,
                    widget.productList![index].prVarientList![0].id!);
                db.updateCart(
                  widget.productList![index].id!,
                  widget.productList![index].prVarientList![0].id!,
                  qty,
                );
                setSnackbar(getTranslated(context, 'Cart Update Successfully'),
                    context);
              }
            }
          } else {
            setSnackbar(
                getTranslated(context, 'only Single Seller Product Allow'),
                context);
          }
        } else {
          if (from == 1) {
            List<Product>? prList = [];
            prList.add(widget.productList![index]);
            context.read<CartProvider>().addCartItem(
                  SectionModel(
                    qty: qty,
                    productList: prList,
                    varientId: widget.productList![index].prVarientList![0].id!,
                    id: widget.productList![index].id,
                    sellerId: widget.productList![index].seller_id,
                  ),
                );
            db.insertCart(
              widget.productList![index].id!,
              widget.productList![index].prVarientList![0].id!,
              qty,
              context,
            );
            setSnackbar(
                  getTranslated(context, 'PRODUCT_ADDED_TO_CART_LBL'), context);
          } else {
            if (int.parse(qty) >
                int.parse(widget.productList![index].itemsCounter!.last)) {
              setSnackbar(
                  "${getTranslated(context, 'MAXQTY')} ${widget.productList![index].itemsCounter!.last}",
                  context);
            } else {
              context.read<CartProvider>().updateCartItem(
                  widget.productList![index].id!,
                  qty,
                  0,
                  widget.productList![index].prVarientList![0].id!);
              db.updateCart(
                widget.productList![index].id!,
                widget.productList![index].prVarientList![0].id!,
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
    if (widget.index! < widget.productList!.length) {
      Product productmodel = widget.productList![widget.index!];

      print('cartBtn list***$cartBtnList******${0}');

      totalProduct = productmodel.total;

      // if (controllerText.length < widget.index! + 1) {
      //   controllerText.add(TextEditingController());
      // }

      double price = double.parse(productmodel.prVarientList![0].disPrice!);
      if (price == 0) {
        price = double.parse(productmodel.prVarientList![0].price!);
      }

      double off = 0;
      if (productmodel.prVarientList![0].disPrice! != '0') {
        off = (double.parse(productmodel.prVarientList![0].price!) -
                double.parse(productmodel.prVarientList![0].disPrice!))
            .toDouble();
        off = off * 100 / double.parse(productmodel.prVarientList![0].price!);
      }

      // if (controllerText.length < widget.index! + 1) {
      //   controllerText.add(TextEditingController());
      // }
      // remove it
      // controllerText[widget.index!].text =
      //     productmodel.prVarientList![0].cartCount!;

      List att = [], val = [];
      if (productmodel.prVarientList![0].attr_name != null) {
        att = productmodel.prVarientList![0].attr_name!.split(',');
        val = productmodel.prVarientList![0].varient_value!.split(',');
      }
      double width = deviceWidth! * 0.5;

      return Consumer<CartProvider>(
        builder: (context, data, _) {
          final tempId = data.cartList.firstWhereOrNull((cp) =>
              cp.id == productmodel.id &&
              cp.varientId == productmodel.prVarientList![0].id!);

          if (tempId != null) {
            controllerText.text = tempId.qty!;
          } else {
            controllerText.text = '0';
          }

          return InkWell(
            child: Card(
              shape: RoundedRectangleBorder(
                side: BorderSide(
                    color: Theme.of(context).colorScheme.gray, width: 1),
                borderRadius: BorderRadius.circular(3),
              ),
              elevation: 0.2,
              margin: EdgeInsetsDirectional.only(
                  bottom: 10, end: 10, start: widget.pad ? 10 : 0),
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
                                '$heroTagUniqueString${widget.index}${productmodel.id}',
                            child: DesignConfiguration.getCacheNotworkImage(
                              boxFit: BoxFit.cover,
                              context: context,
                              heightvalue: double.maxFinite,
                              widthvalue: double.maxFinite,
                              placeHolderSize: width,
                              imageurlString: productmodel.image!,
                            ),
                          ),
                        ),
                        Positioned.fill(
                          child:
                              productmodel.prVarientList![0].availability == '0'
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
                        if (widget.productList![widget.index!].noOfRating! !=
                            '0')
                          Positioned(
                              bottom: 0,
                              right: 0,
                              child: RatingCartForProduct(
                                  noOfRating: widget
                                      .productList![widget.index!].noOfRating!,
                                  totalRating: widget
                                      .productList![widget.index!].rating!)),
                        Positioned(
                          top: 0,
                          right: 0,
                          child:
                              CustomFevoriteButtonForCart(model: productmodel),
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
                              widget.productList![widget.index!].name!,
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
                                          double.parse(widget
                                                      .productList![
                                                          widget.index!]
                                                      .prVarientList![0]
                                                      .disPrice!) !=
                                                  0
                                              ? '${DesignConfiguration.getPriceFormat(context, double.parse(widget.productList![widget.index!].prVarientList![0].price!))}'
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
                            // StarRating(
                            //   totalRating:
                            //       widget.productList![widget.index!].rating!,
                            //   noOfRatings:
                            //       widget.productList![widget.index!].noOfRating!,
                            //   needToShowNoOfRatings: true,
                            // ),
                            const SizedBox(
                              height: 8,
                            ),
                            if (cartBtnList)
                              productmodel.prVarientList![0].availability == '0'
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
                                                          productmodel
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
                                          // Card(
                                          //   elevation: 1,
                                          //   shape: RoundedRectangleBorder(
                                          //     borderRadius:
                                          //         BorderRadius.circular(
                                          //             circularBorderRadius50),
                                          //   ),
                                          //   child: const Padding(
                                          //     padding: EdgeInsets.all(8.0),
                                          //     child: Icon(
                                          //       Icons.shopping_cart_outlined,
                                          //       size: 15,
                                          //     ),
                                          //   ),
                                          // ),
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
                                                    return productmodel
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
                                              // shape: RoundedRectangleBorder(
                                              //   borderRadius:
                                              //       BorderRadius.circular(
                                              //           circularBorderRadius7),
                                              // ),
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
                                                                productmodel
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
              Product model = widget.productList![widget.index!];
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
