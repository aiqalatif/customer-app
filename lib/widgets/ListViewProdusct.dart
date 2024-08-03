import 'dart:async';
import 'package:eshop_multivendor/Provider/Favourite/UpdateFavProvider.dart';
import 'package:eshop_multivendor/Screen/ProductList&SectionView/ProductList.dart';
import 'package:eshop_multivendor/widgets/customfevoritebuttonforCards.dart';
import 'package:eshop_multivendor/widgets/ratingCardForProduct.dart';
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
import 'package:collection/src/iterable_extensions.dart';

class ListIteamListWidget extends StatefulWidget {
  List<Product>? productList;
  final int index;
  int? length;
  Function setState;
  ListIteamListWidget({
    Key? key,
    this.productList,
    required this.index,
    required this.setState,
    this.length,
  }) : super(key: key);

  @override
  State<ListIteamListWidget> createState() => _ListIteamListWidgetState();
}

class _ListIteamListWidgetState extends State<ListIteamListWidget> {
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
        apiBaseHelper.postAPICall(removeFavApi, parameter).then(
          (getdata) {
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
            isProgress = false;
            widget.setState();
          },
        );
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
        apiBaseHelper.postAPICall(setFavoriteApi, parameter).then(
          (getdata) {
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
                      widget.productList![index].prVarientList![0].id!,
                    );
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
                    widget.productList![index].prVarientList![0].id!,
                  );
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
      Product model = widget.productList![widget.index!];

      totalProduct = model.total;

      // if (controllerText.length < widget.index! + 1) {
      //   controllerText.add(TextEditingController());
      // }

      List att = [], val = [];
      if (model.prVarientList![0].attr_name != null) {
        att = model.prVarientList![0].attr_name!.split(',');
        val = model.prVarientList![0].varient_value!.split(',');
      }

      double price = double.parse(model.prVarientList![0].disPrice!);
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
      return Padding(
          padding:
              const EdgeInsetsDirectional.only(start: 5.0, end: 2.0, top: 5.0),
          child: Consumer<CartProvider>(
            builder: (context, data, _) {
              final tempId = data.cartList.firstWhereOrNull((cp) =>
                  cp.id == model.id &&
                  cp.varientId == model.prVarientList![0].id!);

              if (tempId != null) {
                controllerText.text = tempId.qty!;
              } else {
                controllerText.text = '0';
              }

              return Card(
                elevation: 0,
                child: InkWell(
                  borderRadius: BorderRadius.circular(circularBorderRadius10),
                  child: Stack(
                    children: <Widget>[
                      IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          // mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Hero(
                              tag:
                                  '$heroTagUniqueString${widget.index}${model.id}',
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
                                      boxFit: BoxFit.cover,
                                      context: context,
                                      heightvalue: 125.0,
                                      widthvalue: 110.0,
                                      imageurlString: model.image!,
                                      placeHolderSize: 125,
                                    ),
                                    Positioned.fill(
                                      child: model.prVarientList![0]
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
                                    top: 10.0, start: 5.0, end: 35),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  // mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      widget.productList![widget.index!].name!,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium!
                                          .copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .fontColor,
                                              fontFamily: 'ubuntu',
                                              // fontWeight: FontWeight.w400,
                                              // fontStyle: FontStyle.normal,
                                              fontSize: textFontSize12),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(
                                      height: 8,
                                    ),
                                    Row(
                                      // mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          DesignConfiguration.getPriceFormat(
                                              context, price)!,
                                          style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                            fontSize: textFontSize14,
                                            fontWeight: FontWeight.w700,
                                            fontStyle: FontStyle.normal,
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 8,
                                        ),
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
                                                fontSize: textFontSize10,
                                                fontWeight: FontWeight.w400,
                                                fontStyle: FontStyle.normal,
                                              ),
                                        ),
                                        const SizedBox(
                                          width: 8,
                                        ),
                                        off != 0
                                            ? Text(
                                                '${off.toStringAsFixed(2)}%',
                                                style: TextStyle(
                                                  color: colors.green,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: textFontSize9,
                                                ),
                                              )
                                            : const SizedBox()
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    widget.productList![widget.index!].noOfRating! != '0'
                                    ? SizedBox(
                                      width: 80,
                                      child: RatingCartForProduct(
                                          noOfRating: widget
                                              .productList![widget.index!].noOfRating!,
                                          totalRating: widget
                                              .productList![widget.index!].rating!),
                                    ) :const SizedBox(
                                      height: 30,
                                    ),
                                    
                                    const SizedBox(
                                      height: 8,
                                    ),
                                    if (cartBtnList)
                                      model.prVarientList![0].availability ==
                                              '0'
                                          ? const SizedBox()
                                          : controllerText
                                                      .text ==
                                                  '0'
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
                                                                context,
                                                                'ADD'),
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
                                                  ))
                                              : Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: <Widget>[
                                                    InkWell(
                                                      child: Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          color:
                                                              Theme.of(context)
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
                                                        child: Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  4.0),
                                                          child: Icon(
                                                            Icons.remove,
                                                            size: 15,
                                                            color: Theme.of(
                                                                    context)
                                                                .colorScheme
                                                                .black,
                                                          ),
                                                        ),
                                                      ),
                                                      onTap: () {
                                                        if (isProgress ==
                                                                false &&
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
                                                            textAlign: TextAlign
                                                                .center,
                                                            readOnly: true,
                                                            style: TextStyle(
                                                                fontSize:
                                                                    textFontSize12,
                                                                color: Theme.of(
                                                                        context)
                                                                    .colorScheme
                                                                    .fontColor),
                                                            controller:
                                                                controllerText,
                                                            decoration:
                                                                const InputDecoration(
                                                              border:
                                                                  InputBorder
                                                                      .none,
                                                            ),
                                                          ),
                                                          PopupMenuButton<
                                                              String>(
                                                            tooltip: '',
                                                            icon: const Icon(
                                                              Icons
                                                                  .arrow_drop_down,
                                                              size: 0,
                                                            ),
                                                            onSelected:
                                                                (String value) {
                                                              if (isProgress ==
                                                                  false) {
                                                                addToCart(
                                                                    widget
                                                                        .index!,
                                                                    value,
                                                                    2);
                                                              }
                                                            },
                                                            itemBuilder:
                                                                (BuildContext
                                                                    context) {
                                                              return model
                                                                  .itemsCounter!
                                                                  .map<
                                                                      PopupMenuItem<
                                                                          String>>(
                                                                (String value) {
                                                                  return PopupMenuItem(
                                                                    value:
                                                                        value,
                                                                    child: Text(
                                                                      value,
                                                                      style:
                                                                          TextStyle(
                                                                        color: Theme.of(context)
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
                                                        decoration:
                                                            BoxDecoration(
                                                          color:
                                                              Theme.of(context)
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
                                                        child: Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  4.0),
                                                          child: Icon(
                                                            Icons.add,
                                                            size: 15,
                                                            color: Theme.of(
                                                                    context)
                                                                .colorScheme
                                                                .black,
                                                          ),
                                                        ),
                                                      ),
                                                      onTap: () {
                                                        if (isProgress ==
                                                            false) {
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
                              ),
                            ),
                          ],
                        ),
                      ),
                      // if (widget.productList![widget.index!].noOfRating! != '0')
                      //   Positioned(
                      //       bottom: 5,
                      //       right: 5,
                      //       child: RatingCartForProduct(
                      //           noOfRating: widget
                      //               .productList![widget.index!].noOfRating!,
                      //           totalRating: widget
                      //               .productList![widget.index!].rating!)),
                      
                      Positioned(
                          top: 0,
                          right: 0,
                          child: CustomFevoriteButtonForCart(model: model)),
                    ],
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
                ),
              );
            },
          ));
    } else {
      return const SizedBox();
    }
  }
}
