import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:eshop_multivendor/Helper/ApiBaseHelper.dart';
import 'package:eshop_multivendor/Helper/Constant.dart';
import 'package:eshop_multivendor/Provider/CartProvider.dart';
import 'package:eshop_multivendor/Provider/SettingProvider.dart';
import 'package:eshop_multivendor/Provider/UserProvider.dart';
import 'package:eshop_multivendor/Screen/WebView/instamojo_webview.dart';
import 'package:eshop_multivendor/Screen/homePage/widgets/hideAppBarBottom.dart';
import 'package:eshop_multivendor/repository/paymentMethodRepository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_paystack/flutter_paystack.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:http_parser/http_parser.dart';
import 'package:lottie/lottie.dart';
import 'package:mime/mime.dart';
import 'package:my_fatoorah/my_fatoorah.dart';
//import 'package:paytm/paytm.dart';
import 'package:paytm_allinonesdk/paytm_allinonesdk.dart';
import 'package:phonepe_payment_sdk/phonepe_payment_sdk.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../../Helper/Color.dart';
import '../../Helper/String.dart';
import '../../Helper/routes.dart';
import '../../Model/Model.dart';
import '../../Model/Section_Model.dart';
import '../../Model/User.dart';
import '../../Provider/paymentProvider.dart';
import '../../Provider/productListProvider.dart';
import '../../Provider/promoCodeProvider.dart';
import '../../repository/cartRepository.dart';
import '../../widgets/ButtonDesing.dart';
import '../../widgets/appBar.dart';
import '../../widgets/desing.dart';
import '../../widgets/networkAvailablity.dart';
import '../../widgets/security.dart';
import '../../widgets/simmerEffect.dart';
import '../../widgets/snackbar.dart';
import '../Dashboard/Dashboard.dart';
import '../Language/languageSettings.dart';
import '../Manage Address/Manage_Address.dart';
import '../NoInterNetWidget/NoInterNet.dart';
import '../Payment/Payment.dart';
import '../StripeService/Stripe_Service.dart';
import '../WebView/PaypalWebviewActivity.dart';
import '../WebView/midtransWebView.dart';
import 'Widget/attachPrescriptionImageWidget.dart';
import 'Widget/bankTransferContentWidget.dart';
import 'Widget/cartIteamWidget.dart';
import 'Widget/cartListIteamWidget.dart';
import 'Widget/confirmDialog.dart';
import 'Widget/noIteamCartWidget.dart';
import 'Widget/orderSummeryWidget.dart';
import 'Widget/paymentWidget.dart';
import 'Widget/saveLaterIteamWidget.dart';
import 'Widget/setAddress.dart';

class Cart extends StatefulWidget {
  final bool fromBottom;

  const Cart({Key? key, required this.fromBottom}) : super(key: key);

  @override
  State<StatefulWidget> createState() => StateCart();
}

//String? stripePayId;

class StateCart extends State<Cart> with TickerProviderStateMixin {
  bool _isCartLoad = true,
      /*_placeOrder = true, */
      _isSaveLoad = true;

  Animation? buttonSqueezeanimation;
  AnimationController? buttonController;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  String? msg;
  bool _isLoading = true;
  Razorpay? _razorpay;
  final paystackPlugin = PaystackPlugin();
  final ScrollController _scrollControllerOnCartItems = ScrollController();
  final ScrollController _scrollControllerOnSaveForLaterItems =
      ScrollController();

//  bool isAvailable = true;
  String razorpayOrderId = '';
  String? rozorpayMsg;

  // String orderId = '';

  Future<void> cartFun({
    required int index,
    required int selectedPos,
    required double total,
  }) async {
    db.moveToCartOrSaveLater(
      'save',
      context
          .read<CartProvider>()
          .saveLaterList[index]
          .productList![0]
          .prVarientList![selectedPos]
          .id!,
      context.read<CartProvider>().saveLaterList[index].id!,
      context,
    );

    context.read<CartProvider>().productIds.add(context
        .read<CartProvider>()
        .saveLaterList[index]
        .productList![0]
        .prVarientList![selectedPos]
        .id!);
    context.read<CartProvider>().productIds.remove(context
        .read<CartProvider>()
        .saveLaterList[index]
        .productList![0]
        .prVarientList![selectedPos]
        .id!);
    context.read<CartProvider>().oriPrice =
        context.read<CartProvider>().oriPrice + total;
    context
        .read<CartProvider>()
        .addCartItem(context.read<CartProvider>().saveLaterList[index]);
    context.read<CartProvider>().saveLaterList.removeAt(index);

    context.read<CartProvider>().addCart = false;
    context.read<CartProvider>().setProgress(false);
    setState(() {});
  }

  Future<void> saveForLaterFun({
    required int index,
    required int selectedPos,
    required double total,
    required List<SectionModel> cartList,
  }) async {
    db.moveToCartOrSaveLater(
      'cart',
      cartList[index].productList![0].prVarientList![selectedPos].id!,
      cartList[index].id!,
      context,
    );
    context
        .read<CartProvider>()
        .productIds
        .add(cartList[index].productList![0].prVarientList![selectedPos].id!);
    context.read<CartProvider>().productIds.remove(
        cartList[index].productList![0].prVarientList![selectedPos].id!);
    context.read<CartProvider>().oriPrice =
        context.read<CartProvider>().oriPrice - total;
    context.read<CartProvider>().saveLaterList.add(
          SectionModel(
            id: cartList[index].id,
            varientId: cartList[index].varientId,
            qty: '1',
            sellerId: cartList[index].sellerId,
            productList: cartList[index].productList,
          ),
        );
    context.read<CartProvider>().removeCartItem(
        cartList[index].productList![0].prVarientList![selectedPos].id!);

    context.read<CartProvider>().saveLater = false;
    context.read<CartProvider>().setProgress(false);
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CartProvider>().setprescriptionImages([]);
      context.read<CartProvider>().selectedMethod = null;
      context.read<CartProvider>().selectedMethod = null;
      context.read<CartProvider>().payMethod = null;
      context.read<CartProvider>().deliverable = false;
      context.read<CartProvider>().isShippingDeliveryChargeApplied = false;
      context.read<CartProvider>().promocode = null;
      context.read<CartProvider>().promoC.clear();
      context.read<CartProvider>().isAvailable = true;
      callApi();
    });
    buttonController = AnimationController(
        duration: const Duration(milliseconds: 2000), vsync: this);
    buttonSqueezeanimation = Tween(
      begin: deviceWidth! * 0.7,
      end: 50.0,
    ).animate(
      CurvedAnimation(
        parent: buttonController!,
        curve: const Interval(
          0.0,
          0.150,
        ),
      ),
    );

    Future.delayed(Duration.zero).then(
        (value) {
          hideAppbarAndBottomBarOnScroll(
            _scrollControllerOnCartItems,
            context,
          );
        },
      );
  }

  callApi() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (mounted) {
        context.read<CartProvider>().setProgress(false);
      }

      if (context.read<UserProvider>().email != '') {
        context.read<CartProvider>().emailController.text =
            context.read<UserProvider>().email;
      }

      if (context.read<UserProvider>().userId != '') {
        _getCart('0');
        _getSaveLater('1');
      } else {
        context.read<CartProvider>().productIds = (await db.getCart())!;
        _getOffCart();
        context.read<CartProvider>().productVariantIds =
            (await db.getSaveForLater())!;
        _getOffSaveLater();
      }
      setState(() {});
    });
  }

  Future<void> _refresh() async {
    if (mounted) {
      setState(() {
        _isCartLoad = true;
        _isSaveLoad = true;
      });
    }
    context.read<CartProvider>().isAvailable = true;
    if (context.read<UserProvider>().userId != '') {
      clearAll();
      _getCart('0');
      return _getSaveLater('1');
    } else {
      context.read<CartProvider>().oriPrice = 0;
      context.read<CartProvider>().saveLaterList.clear();
      context.read<CartProvider>().productIds = (await db.getCart())!;
      await _getOffCart();
      context.read<CartProvider>().productVariantIds =
          (await db.getSaveForLater())!;
      await _getOffSaveLater();
    }
  }

  clearAll() {
    context.read<UserProvider>().setCartCount('0');
    context.read<CartProvider>().totalPrice = 0;

    context.read<CartProvider>().oriPrice = 0;
    context.read<CartProvider>().taxPer = 0;
    context.read<CartProvider>().deliveryCharge = 0;
    context.read<CartProvider>().addressList.clear();

    context.read<CartProvider>().setCartlist([]);
    context.read<CartProvider>().setProgress(false);

    context.read<CartProvider>().promoAmt = 0;
    context.read<CartProvider>().remWalBal = 0;
    context.read<CartProvider>().usedBalance = 0;
    context.read<CartProvider>().payMethod = null;
    context.read<CartProvider>().isPromoValid = false;
    context.read<CartProvider>().isUseWallet = false;
    context.read<CartProvider>().isPayLayShow = true;
    context.read<CartProvider>().selectedMethod = null;
    context.read<CartProvider>().deliverable = false;
    context.read<CartProvider>().codDeliverChargesOfShipRocket = 0.0;
    context.read<CartProvider>().prePaidDeliverChargesOfShipRocket = 0.0;
    context.read<CartProvider>().isLocalDelCharge = null;
    context.read<CartProvider>().isShippingDeliveryChargeApplied = false;
    context.read<CartProvider>().shipRocketDeliverableDate = '';
    context.read<CartProvider>().isAddressChange = null;
    context.read<CartProvider>().noteController.clear();
    context.read<CartProvider>().promoC.clear();
    context.read<CartProvider>().promocode = null;
  }

  @override
  void dispose() {
    buttonController!.dispose();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<CartProvider>().noteController.dispose();
        context.read<CartProvider>().emailController.clear();
        context.read<CartProvider>().promoC.dispose();
        context.read<CartProvider>().setProgress(false);

        for (int i = 0;
            i < context.read<CartProvider>().controller.length;
            i++) {
          context.read<CartProvider>().controller[i].dispose();
        }
      }
    });
    _scrollControllerOnCartItems.removeListener(() {});
    _scrollControllerOnSaveForLaterItems.removeListener(() {});
    if (_razorpay != null) _razorpay!.clear();
    super.dispose();
  }

  Future<void> _playAnimation() async {
    try {
      await buttonController!.forward();
    } on TickerCanceled {}
  }

  setStateNow() {
    setState(() {});
  }

  setStateNoInternate() async {
    _playAnimation();
    Future.delayed(const Duration(seconds: 2)).then(
      (_) async {
        isNetworkAvail = await isNetworkAvailable();
        if (isNetworkAvail) {
          callApi();
          // Navigator.pushReplacement(
          //   context,
          //   CupertinoPageRoute(builder: (BuildContext context) => super.widget),
          // );
        } else {
          await buttonController!.reverse();
          if (mounted) setState(() {});
        }
      },
    );
  }

  updatePromo(String promo) {
    setState(
      () {
        //context.read<CartProvider>().isPromoLen = false;
        context.read<CartProvider>().promoC.text = promo;
      },
    );
  }

  callShowOverlayMethod() {
    _showOverlay(context);
  }

  void _showOverlay(BuildContext context) async {
    OverlayState? overlayState = Overlay.of(context);
    late OverlayEntry overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              color: Theme.of(context).colorScheme.black26,
            ),
            Lottie.asset(
              DesignConfiguration.setLottiePath('celebrate'),
            ),
            Positioned(
              top: MediaQuery.of(context).size.height * 0.3,
              left: MediaQuery.of(context).size.width * 0.1,
              right: MediaQuery.of(context).size.width * 0.1,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.35,
                decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).colorScheme.white,
                    ),
                    borderRadius: BorderRadius.circular(circularBorderRadius20),
                    color: Theme.of(context).colorScheme.white),
                child: Material(
                  color: Colors.transparent,
                  child: Column(
                    children: [
                      Container(
                        child: Lottie.asset(
                            DesignConfiguration.setLottiePath('promocode'),
                            height: 150,
                            width: 150),
                      ),
                      Text(
                        '${context.read<CartProvider>().promocode} applied',
                        style: TextStyle(
                          fontSize: textFontSize16,
                          color: Theme.of(context).colorScheme.fontColor,
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Text(
                        '${getTranslated(context, 'You saved')} ${DesignConfiguration.getPriceFormat(context, context.read<CartProvider>().promoAmt)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: textFontSize18,
                          color: Theme.of(context).colorScheme.fontColor,
                        ),
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Text(
                        getTranslated(context, 'with this coupon code'),
                        style: TextStyle(
                          fontSize: textFontSize12,
                          color: Theme.of(context).colorScheme.fontColor,
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            getTranslated(context, 'woohoo! Thanks'),
                            style: const TextStyle(
                              fontSize: textFontSize12,
                              color: colors.red,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    overlayState.insert(overlayEntry);

    await Future.delayed(const Duration(seconds: 4));
    overlayEntry.remove();
  }

  @override
  Widget build(BuildContext context) {
    deviceHeight = MediaQuery.of(context).size.height;
    deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: widget.fromBottom
          ? getappbarforcart(getTranslated(context, 'MY_CART'), context)
          : getSimpleAppBar(getTranslated(context, 'CART'), context),
      body: isNetworkAvail
          ? Consumer<UserProvider>(builder: (context, data, child) {
              return data.userId != ''
                  ? Stack(
                      children: <Widget>[
                        _showContent(context),
                        Selector<CartProvider, bool>(
                          builder: (context, data, child) {
                            return DesignConfiguration.showCircularProgress(
                                data, colors.primary);
                          },
                          selector: (_, provider) => provider.isProgress,
                        ),
                      ],
                    )
                  : Stack(
                      children: <Widget>[
                        _showContent1(context),
                        Selector<CartProvider, bool>(
                          builder: (context, data, child) {
                            return DesignConfiguration.showCircularProgress(
                                data, colors.primary);
                          },
                          selector: (_, provider) => provider.isProgress,
                        ),
                      ],
                    );
            })
          : NoInterNet(
              setStateNoInternate: setStateNoInternate,
              buttonSqueezeanimation: buttonSqueezeanimation,
              buttonController: buttonController,
            ),
    );
  }

  Future<void> _getCart(String save) async {
    isNetworkAvail = await isNetworkAvailable();

    if (isNetworkAvail) {
      try {
        var parameter = {
          // USER_ID: context.read<UserProvider>().userId,
          SAVE_LATER: save,
          ONLY_DEL_CHARGE: '0'
        };

        apiBaseHelper.postAPICall(getCartApi, parameter).then((getdata) {
          bool error = getdata['error'];
          String? msg = getdata['message'];
          if (!error) {
            var data = getdata['data'];

            context.read<CartProvider>().oriPrice =
                double.parse(getdata[SUB_TOTAL]);

            context.read<CartProvider>().taxPer =
                double.parse(getdata[TAX_PER]);

            if (IS_SHIPROCKET_ON == '0') {
              context.read<CartProvider>().totalPrice =
                  context.read<CartProvider>().oriPrice;
            } else {
              context.read<CartProvider>().totalPrice =
                  context.read<CartProvider>().deliveryCharge +
                      context.read<CartProvider>().oriPrice;
            }

            /*context.read<CartProvider>().totalPrice =
                context.read<CartProvider>().deliveryCharge +
                    context.read<CartProvider>().oriPrice;*/

            List<SectionModel> cartList = (data as List)
                .map((data) => SectionModel.fromCart(data))
                .toList();

            context.read<CartProvider>().setCartlist(cartList);

            if (getdata.containsKey(PROMO_CODES)) {
              var promo = getdata[PROMO_CODES];
              context.read<CartProvider>().promoList =
                  (promo as List).map((e) => Promo.fromJson(e)).toList();
            }

            for (int i = 0; i < cartList.length; i++) {
              context
                  .read<CartProvider>()
                  .controller
                  .add(TextEditingController());
            }
            setState(() {});
          } else {
            if (msg != 'Cart Is Empty !') setSnackbar(msg!, context);
          }
          if (mounted) {
            setState(() {
              _isCartLoad = false;
            });
          }
          if (context.read<CartProvider>().cartList.isNotEmpty &&
              context
                      .read<CartProvider>()
                      .cartList[0]
                      .productList![0]
                      .productType !=
                  'digital_product') {
            _getAddress();
          } else {
            setState(() {
              _isLoading = false;
            });
          }
        }, onError: (error) {
          setSnackbar(error.toString(), context);
        });
      } on TimeoutException catch (_) {
        setSnackbar(getTranslated(context, 'somethingMSg'), context);
      }
    } else {
      if (mounted) {
        setState(
          () {
            isNetworkAvail = false;
          },
        );
      }
    }
  }

  Future<void> _getOffCart() async {
    if (context.read<CartProvider>().productIds.isNotEmpty) {
      isNetworkAvail = await isNetworkAvailable();

      if (isNetworkAvail) {
        var parameter = {
          'product_variant_ids':
              context.read<CartProvider>().productIds.join(',')
        };
        context.read<ProductListProvider>().setProductListParameter(parameter);
        Future.delayed(Duration.zero).then(
          (value) => context.read<ProductListProvider>().getProductList().then(
            (
              value,
            ) async {
              bool error = value['error'];
              if (!error) {
                var data = value['data'];
                setState(() {
                  context.read<CartProvider>().setCartlist([]);

                  context.read<CartProvider>().oriPrice = 0;
                });

                List<Product> cartList = (data as List)
                    .map((data) => Product.fromJson(data))
                    .toList();
                for (int i = 0; i < cartList.length; i++) {
                  for (int j = 0; j < cartList[i].prVarientList!.length; j++) {
                    if (context
                        .read<CartProvider>()
                        .productIds
                        .contains(cartList[i].prVarientList![j].id)) {
                      String qty = (await db.checkCartItemExists(
                          cartList[i].id!, cartList[i].prVarientList![j].id!))!;

                      List<Product>? prList = [];
                      cartList[i].prVarientList![j].cartCount = qty;
                      prList.add(cartList[i]);

                      context.read<CartProvider>().addCartItem(
                            SectionModel(
                              id: cartList[i].id,
                              varientId: cartList[i].prVarientList![j].id,
                              qty: qty,
                              productList: prList,
                              sellerId: cartList[i].seller_id,
                            ),
                          );

                      double price =
                          double.parse(cartList[i].prVarientList![j].disPrice!);
                      if (price == 0) {
                        price =
                            double.parse(cartList[i].prVarientList![j].price!);
                      }
                      double total =
                          qty == '' ? price : (price * int.parse(qty));

                      setState(
                        () {
                          context.read<CartProvider>().oriPrice =
                              context.read<CartProvider>().oriPrice + total;
                        },
                      );
                    }
                  }
                }
                setState(() {});
              }
              if (mounted) {
                setState(
                  () {
                    _isCartLoad = false;
                  },
                );
              }
            },
            onError: (error) {
              setSnackbar(error.toString(), context);
            },
          ),
        );
      } else {
        if (mounted) {
          setState(
            () {
              isNetworkAvail = false;
            },
          );
        }
      }
    } else {
      context.read<CartProvider>().setCartlist([]);
      setState(
        () {
          _isCartLoad = false;
        },
      );
    }
  }

  Future<void> _getOffSaveLater() async {
    if (context.read<CartProvider>().productVariantIds.isNotEmpty) {
      isNetworkAvail = await isNetworkAvailable();

      if (isNetworkAvail) {
        var parameter = {
          'product_variant_ids':
              context.read<CartProvider>().productVariantIds.join(',')
        };
        context.read<ProductListProvider>().setProductListParameter(parameter);

        Future.delayed(Duration.zero).then(
          (value) => context.read<ProductListProvider>().getProductList().then(
            (
              value,
            ) async {
              bool error = value['error'];
              if (!error) {
                var data = value['data'];
                context.read<CartProvider>().saveLaterList.clear();
                List<Product> cartList = (data as List)
                    .map((data) => Product.fromJson(data))
                    .toList();
                for (int i = 0; i < cartList.length; i++) {
                  for (int j = 0; j < cartList[i].prVarientList!.length; j++) {
                    if (context
                        .read<CartProvider>()
                        .productVariantIds
                        .contains(cartList[i].prVarientList![j].id)) {
                      String qty = (await db.checkSaveForLaterExists(
                          cartList[i].id!, cartList[i].prVarientList![j].id!))!;
                      List<Product>? prList = [];
                      prList.add(cartList[i]);
                      context.read<CartProvider>().saveLaterList.add(
                            SectionModel(
                              id: cartList[i].id,
                              varientId: cartList[i].prVarientList![j].id,
                              qty: qty,
                              productList: prList,
                              sellerId: cartList[i].seller_id,
                            ),
                          );
                    }
                  }
                }

                setState(() {});
              }
              if (mounted) {
                setState(
                  () {
                    _isSaveLoad = false;
                  },
                );
              }
            },
            onError: (error) {
              setSnackbar(error.toString(), context);
            },
          ),
        );
      } else {
        if (mounted) {
          setState(
            () {
              isNetworkAvail = false;
            },
          );
        }
      }
    } else {
      setState(
        () {
          _isSaveLoad = false;
        },
      );
      context.read<CartProvider>().saveLaterList = [];
    }
  }

  Future<void> _getSaveLater(String save) async {
    isNetworkAvail = await isNetworkAvailable();
    if (isNetworkAvail) {
      try {
        var parameter = {
          // USER_ID: context.read<UserProvider>().userId,
          SAVE_LATER: save,
          ONLY_DEL_CHARGE: '0'
        };
        apiBaseHelper.postAPICall(getCartApi, parameter).then((getdata) {
          bool error = getdata['error'];
          String? msg = getdata['message'];
          if (!error) {
            var data = getdata['data'];
            List<SectionModel> saveLaterList = (data as List)
                .map((data) => SectionModel.fromCart(data))
                .toList();

            context.read<CartProvider>().setSaveForLaterlist(saveLaterList);
          } else {
            context.read<CartProvider>().setSaveForLaterlist([]);
            if (msg != 'Cart Is Empty !') setSnackbar(msg!, context);
          }
          if (mounted) {
            setState(() {
              _isSaveLoad = false;
            });
          }
        }, onError: (error) {
          setSnackbar(error.toString(), context);
        });
      } on TimeoutException catch (_) {
        setSnackbar(getTranslated(context, 'somethingMSg'), context);
      }
    } else {
      if (mounted) {
        setState(
          () {
            isNetworkAvail = false;
          },
        );
      }
    }

    return;
  }

  _showContent1(BuildContext context) {
    List<SectionModel> cartList = context.read<CartProvider>().cartList;

    return _isCartLoad || _isSaveLoad
        ? const ShimmerEffect()
        : cartList.isEmpty && context.read<CartProvider>().saveLaterList.isEmpty
            ? const EmptyCart()
            : Container(
                color: Theme.of(context).colorScheme.lightWhite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: RefreshIndicator(
                          color: colors.primary,
                          key: _refreshIndicatorKey,
                          onRefresh: _refresh,
                          child: SizedBox(
                            height: double.maxFinite,
                            child: SingleChildScrollView(
                              physics: const BouncingScrollPhysics(
                                  parent: AlwaysScrollableScrollPhysics()),
                              controller: _scrollControllerOnCartItems,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: cartList.length,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemBuilder: (context, index) {
                                        return CartListViewLayOut(
                                          index: index,
                                          setState: setStateNow,
                                          saveForLatter: saveForLaterFun,
                                        );
                                      },
                                    ),
                                  ),
                                  context
                                          .read<CartProvider>()
                                          .saveLaterList
                                          .isNotEmpty
                                      ? Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            getTranslated(
                                                context, 'SAVEFORLATER_BTN'),
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium!
                                                .copyWith(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .fontColor,
                                                  fontFamily: 'ubuntu',
                                                ),
                                          ),
                                        )
                                      : Container(
                                          height: 0,
                                        ),
                                  if (context
                                      .read<CartProvider>()
                                      .saveLaterList
                                      .isNotEmpty)
                                    ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: context
                                          .read<CartProvider>()
                                          .saveLaterList
                                          .length,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemBuilder: (context, index) {
                                        return SaveLatterIteam(
                                          index: index,
                                          setState: setStateNow,
                                          cartFunc: cartFun,
                                        );
                                      },
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        context.read<CartProvider>().cartList.isNotEmpty
                            ? Padding(
                                padding: const EdgeInsetsDirectional.only(
                                  top: 5.0,
                                  end: 10.0,
                                  start: 10.0,
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.white,
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(circularBorderRadius5),
                                    ),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                    horizontal: 5,
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            getTranslated(
                                                context, 'TOTAL_PRICE'),
                                          ),
                                          Text(
                                            '${DesignConfiguration.getPriceFormat(context, context.read<CartProvider>().oriPrice)!} ',
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium!
                                                .copyWith(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .fontColor,
                                                  fontFamily: 'ubuntu',
                                                ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              )
                            : Container(
                                height: 0,
                              ),
                      ],
                    ),
                    cartList.isNotEmpty
                        ? SimBtn(
                            size: 0.9,
                            height: 40,
                            borderRadius: circularBorderRadius5,
                            title: getTranslated(context, 'PROCEED_CHECKOUT'),
                            onBtnSelected: () {
                              Routes.navigateToLoginScreen(
                                context,
                                classType: Cart(fromBottom: widget.fromBottom),
                                isPop: true,
                                isRefresh: true,
                              ).then((value) {
                                callApi();
                              });
                            },
                          )
                        : Container(
                            height: 0,
                          ),
                  ],
                ),
              );
  }

  Future<void> promoEmpty() async {
    setState(() {
      context.read<CartProvider>().totalPrice =
          context.read<CartProvider>().totalPrice +
              context.read<CartProvider>().promoAmt;
    });
  }

  _showContent(BuildContext context) {
    return _isCartLoad || _isSaveLoad
        ? const ShimmerEffect()
        : context.read<CartProvider>().cartList.isEmpty &&
                context.read<CartProvider>().saveLaterList.isEmpty
            ? const EmptyCart()
            : Container(
                color: Theme.of(context).colorScheme.lightWhite,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        height: double.maxFinite,
                        padding: const EdgeInsets.only(
                          right: 10.0,
                          left: 10.0,
                          top: 10,
                        ),
                        child: RefreshIndicator(
                          color: colors.primary,
                          key: _refreshIndicatorKey,
                          onRefresh: _refresh,
                          child: SizedBox(
                            height: double.maxFinite,
                            child: SingleChildScrollView(
                              physics: const BouncingScrollPhysics(
                                  parent: AlwaysScrollableScrollPhysics()),
                              controller: _scrollControllerOnCartItems,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (context
                                      .read<CartProvider>()
                                      .cartList
                                      .isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 0.0),
                                      child: ListView.builder(
                                        shrinkWrap: true,
                                        itemCount: context
                                            .read<CartProvider>()
                                            .cartList
                                            .length,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemBuilder: (context, index) {
                                          return CartListViewLayOut(
                                            index: index,
                                            setState: setStateNow,
                                            saveForLatter: saveForLaterFun,
                                          );
                                        },
                                      ),
                                    ),
                                  if (context
                                      .read<CartProvider>()
                                      .saveLaterList
                                      .isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        getTranslated(
                                            context, 'SAVEFORLATER_BTN'),
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium!
                                            .copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .fontColor,
                                              fontFamily: 'ubuntu',
                                            ),
                                      ),
                                    ),
                                  if (context
                                      .read<CartProvider>()
                                      .saveLaterList
                                      .isNotEmpty)
                                    ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: context
                                          .read<CartProvider>()
                                          .saveLaterList
                                          .length,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemBuilder: (context, index) {
                                        return SaveLatterIteam(
                                          index: index,
                                          setState: setStateNow,
                                          cartFunc: cartFun,
                                        );
                                      },
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        if (context.read<CartProvider>().promoList.isNotEmpty &&
                            context.read<CartProvider>().oriPrice > 0)
                          Padding(
                            padding: const EdgeInsetsDirectional.only(
                                top: 5.0, end: 10.0, start: 10.0),
                            child: Stack(
                              alignment: Alignment.centerRight,
                              children: [
                                Container(
                                  margin: const EdgeInsetsDirectional.only(
                                    end: 20,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.white,
                                    borderRadius:
                                        BorderRadiusDirectional.circular(
                                      circularBorderRadius5,
                                    ),
                                  ),
                                  child: TextField(
                                    textDirection: Directionality.of(context),
                                    controller:
                                        context.read<CartProvider>().promoC,
                                    style:
                                        Theme.of(context).textTheme.titleSmall,
                                    decoration: InputDecoration(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 10),
                                      border: InputBorder.none,
                                      hintText: getTranslated(
                                          context, 'PROMOCODE_LBL'),
                                    ),
                                    onChanged: (val) {
                                      setState(
                                        () {
                                          if (val.isEmpty) {
                                            context
                                                .read<CartProvider>()
                                                .isPromoLen = false;
                                            context
                                                .read<CartProvider>()
                                                .isPromoValid = false;
                                            promoEmpty().then((value) {
                                              context
                                                  .read<CartProvider>()
                                                  .promoAmt = 0;
                                            });
                                          } else {
                                            /*context
                                                .read<CartProvider>()
                                                .promoAmt = 0;*/
                                            context
                                                .read<CartProvider>()
                                                .isPromoLen = true;
                                            context
                                                .read<CartProvider>()
                                                .isPromoValid = false;
                                          }
                                        },
                                      );
                                    },
                                  ),
                                ),
                                Positioned.directional(
                                  textDirection: Directionality.of(context),
                                  end: 0,
                                  child: InkWell(
                                    onTap: () {
                                      Routes.navigateToPromoCodeScreen(
                                        context,
                                        'cart',
                                        updatePromo,
                                      );
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(11),
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            colors.grad1Color,
                                            colors.grad2Color
                                          ],
                                          stops: [0, 1],
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.arrow_forward,
                                        color: colors.whiteTemp,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                       
                        Padding(
                          padding: const EdgeInsetsDirectional.only(
                            top: 5.0,
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.white,
                              borderRadius: const BorderRadius.all(
                                Radius.circular(circularBorderRadius5),
                              ),
                            ),
                           
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (context.read<CartProvider>().isPromoValid!)
                                  Padding(
                                    padding: const EdgeInsetsDirectional.symmetric(horizontal: 5),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          getTranslated(
                                              context, 'PROMO_CODE_DIS_LBL'),
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall!
                                              .copyWith(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .lightBlack2,
                                                fontFamily: 'ubuntu',
                                              ),
                                        ),
                                        Text(
                                          '${DesignConfiguration.getPriceFormat(
                                            context,
                                            context.read<CartProvider>().promoAmt,
                                          )!} ',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall!
                                              .copyWith(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .lightBlack2,
                                                fontFamily: 'ubuntu',
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                Container(
                                  padding:
                                      const EdgeInsetsDirectional.only(start: 20,),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.white,
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(circularBorderRadius5),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '${DesignConfiguration.getPriceFormat(context, context.read<CartProvider>().oriPrice)!} ',
                                                style: TextStyle(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .primary,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily: 'ubuntu',
                                                ),
                                              ),
                                              Text(
                                                '${context.read<CartProvider>().cartList.length} Items',
                                                style: const TextStyle(
                                                  fontFamily: 'ubuntu',
                                                ),
                                              ),
                                            ],
                                          ),
                                      
                                      SimBtn(
                                        paddingvalue: 10,
                                        size: 0.45,
                                        height: 40,
                                        borderRadius: circularBorderRadius5,
                                        title: context
                                                .read<CartProvider>()
                                                .isPromoLen
                                            ? getTranslated(
                                                context, 'VALI_PRO_CODE')
                                            : getTranslated(
                                                context, 'PROCEED_CHECKOUT'),
                                        onBtnSelected: () async {
                                          if (double.parse(
                                                  MIN_ALLOW_CART_AMT!) >
                                              context
                                                  .read<CartProvider>()
                                                  .oriPrice) {
                                            setSnackbar(
                                                "${getTranslated(context, 'MIN_CART_AMT')} ${DesignConfiguration.getPriceFormat(context, double.parse(MIN_ALLOW_CART_AMT!))!}",
                                                context);
                                            return;
                                          }
                                          if (context
                                                  .read<CartProvider>()
                                                  .isPromoLen ==
                                              false) {
                                            if (context
                                                    .read<CartProvider>()
                                                    .oriPrice >
                                                0) {
                                              FocusScope.of(context).unfocus();
                                              if (context
                                                  .read<CartProvider>()
                                                  .isAvailable) {
                                                if (context
                                                        .read<CartProvider>()
                                                        .totalPrice !=
                                                    0) {
                                                  checkout();
                                                }
                                              } else {
                                                setSnackbar(
                                                    getTranslated(context,
                                                        'CART_OUT_OF_STOCK_MSG'),
                                                    context);
                                              }
                                              if (mounted) setState(() {});
                                            } else {
                                              setSnackbar(
                                                  getTranslated(
                                                      context, 'ADD_ITEM'),
                                                  context);
                                            }
                                          } else {
                                            await context
                                                .read<PromoCodeProvider>()
                                                .validatePromocode(
                                                    check: false,
                                                    context: context,
                                                    promocode: context
                                                        .read<CartProvider>()
                                                        .promoC
                                                        .text,
                                                    update: setStateNow,
                                                    callShowOverlayMethod:
                                                        callShowOverlayMethod)
                                                .then(
                                              (value) {
                                                setState(
                                                  () {
                                                    FocusScope.of(context)
                                                        .unfocus();
                                                  },
                                                );
                                              },
                                            );
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
  }

  checkout() {
    deviceHeight = MediaQuery.of(context).size.height;
    deviceWidth = MediaQuery.of(context).size.width;
    List<SectionModel> tempCartListForTestCondtion =
        context.read<CartProvider>().cartList;

    if (context.read<CartProvider>().addressList.isNotEmpty &&
        !context.read<CartProvider>().deliverable &&
        context.read<CartProvider>().cartList[0].productList![0].productType !=
            'digital_product') {
      checkDeliverable(false);
    }

    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(circularBorderRadius10),
          topRight: Radius.circular(circularBorderRadius10),
        ),
      ),
      builder: (builder) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            context.read<CartProvider>().checkoutState = setState;
            return Container(
              constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.8),
              child: Scaffold(
                resizeToAvoidBottomInset: false,
                // key: context,
                body: isNetworkAvail
                    ? context.read<CartProvider>().cartList.isEmpty
                        ? const EmptyCart()
                        : _isLoading
                            ? const ShimmerEffect()
                            : Column(
                                children: [
                                  Expanded(
                                    child: Stack(
                                      children: <Widget>[
                                        SingleChildScrollView(
                                          child: Padding(
                                            padding: const EdgeInsetsDirectional.all(10.0),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                tempCartListForTestCondtion[0]
                                                            .productType ==
                                                        'digital_product'
                                                    ? const SizedBox()
                                                    : SetAddress(
                                                        update: setStateNow),
                                                AttachPrescriptionImages(
                                                    cartList: context
                                                        .read<CartProvider>()
                                                        .cartList),
                                                SelectPayment(
                                                  updateCheckout:
                                                      updateCheckout,
                                                ),
                                                cartItems(context
                                                    .read<CartProvider>()
                                                    .cartList),
                                                OrderSummery(
                                                  cartList: context
                                                      .read<CartProvider>()
                                                      .cartList,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Selector<CartProvider, bool>(
                                          builder: (context, data, child) {
                                            return DesignConfiguration
                                                .showCircularProgress(
                                                    data, colors.primary);
                                          },
                                          selector: (_, provider) =>
                                              provider.isProgress,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    color: Theme.of(context).colorScheme.white,
                                    child: Row(
                                      children: <Widget>[
                                        Padding(
                                          padding:
                                              const EdgeInsetsDirectional.only(
                                                  start: 15.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '${DesignConfiguration.getPriceFormat(context, context.read<CartProvider>().totalPrice)!} ',
                                                style: TextStyle(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .primary,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily: 'ubuntu',
                                                ),
                                              ),
                                              Text(
                                                '${context.read<CartProvider>().cartList.length} Items',
                                                style: const TextStyle(
                                                  fontFamily: 'ubuntu',
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Spacer(),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            right: 10.0,
                                          ),
                                          child: SimBtn(
                                            borderRadius: circularBorderRadius5,
                                            size: 0.4,
                                            title: getTranslated(
                                                context, 'PLACE_ORDER'),
                                            onBtnSelected: context
                                                    .read<CartProvider>()
                                                    .placeOrder
                                                ? () {
                                                    context
                                                        .read<CartProvider>()
                                                        .checkoutState!(
                                                      () {
                                                        context
                                                            .read<
                                                                CartProvider>()
                                                            .placeOrder = false;
                                                      },
                                                    );
                                                    if (tempCartListForTestCondtion[0].productType != 'digital_product' &&
                                                        (context.read<CartProvider>().selAddress == null ||
                                                            context.read<CartProvider>().selAddress ==
                                                                '' ||
                                                            context
                                                                .read<
                                                                    CartProvider>()
                                                                .selAddress!
                                                                .isEmpty)) {
                                                      msg = getTranslated(
                                                          context,
                                                          'addressWarning');

                                                      Navigator.push(
                                                        context,
                                                        CupertinoPageRoute(
                                                          builder: (context) =>
                                                              const ManageAddress(
                                                            home: false,
                                                          ),
                                                        ),
                                                      );
                                                      setState(() {});

                                                      context
                                                          .read<CartProvider>()
                                                          .checkoutState!(
                                                        () {
                                                          context
                                                              .read<
                                                                  CartProvider>()
                                                              .placeOrder = true;
                                                        },
                                                      );
                                                    } else if (tempCartListForTestCondtion[0].productList![0].productType != 'digital_product' &&
                                                        !context
                                                            .read<
                                                                CartProvider>()
                                                            .deliverable) {
                                                      checkDeliverable(true);

                                                      context
                                                          .read<CartProvider>()
                                                          .checkoutState!(
                                                        () {
                                                          context
                                                              .read<
                                                                  CartProvider>()
                                                              .placeOrder = true;
                                                        },
                                                      );
                                                    } else if (tempCartListForTestCondtion[0].productType != 'digital_product' &&
                                                        !context
                                                            .read<
                                                                CartProvider>()
                                                            .deliverable) {
                                                      msg = getTranslated(
                                                          context, 'NOT_DEL');
                                                      context
                                                          .read<CartProvider>()
                                                          .checkoutState!(
                                                        () {
                                                          context
                                                              .read<
                                                                  CartProvider>()
                                                              .placeOrder = true;
                                                        },
                                                      );
                                                    } else if (context.read<CartProvider>().payMethod ==
                                                        null) {
                                                      msg = getTranslated(
                                                          context,
                                                          'payWarning');
                                                      Navigator.push(
                                                        context,
                                                        CupertinoPageRoute(
                                                          builder: (BuildContext
                                                                  context) =>
                                                              Payment(
                                                            updateCheckout,
                                                            msg,
                                                          ),
                                                        ),
                                                      );
                                                      context
                                                          .read<CartProvider>()
                                                          .checkoutState!(
                                                        () {
                                                          context
                                                              .read<
                                                                  CartProvider>()
                                                              .placeOrder = true;
                                                        },
                                                      );
                                                    } else if (tempCartListForTestCondtion[0].productType !=
                                                            'digital_product' &&
                                                        (context.read<CartProvider>().isTimeSlot! &&
                                                            (context.read<CartProvider>().isLocalDelCharge == null ||
                                                                context
                                                                    .read<
                                                                        CartProvider>()
                                                                    .isLocalDelCharge!) &&
                                                            int.parse(context.read<PaymentProvider>().allowDay!) >
                                                                0 &&
                                                            (context.read<CartProvider>().selDate == null ||
                                                                context
                                                                    .read<
                                                                        CartProvider>()
                                                                    .selDate!
                                                                    .isEmpty) &&
                                                            IS_LOCAL_ON !=
                                                                '0')) {
                                                      msg = getTranslated(
                                                          context,
                                                          'dateWarning');
                                                      Navigator.push(
                                                        context,
                                                        CupertinoPageRoute(
                                                          builder: (BuildContext
                                                                  context) =>
                                                              Payment(
                                                            updateCheckout,
                                                            msg,
                                                          ),
                                                        ),
                                                      );

                                                      context
                                                          .read<CartProvider>()
                                                          .checkoutState!(
                                                        () {
                                                          context
                                                              .read<
                                                                  CartProvider>()
                                                              .placeOrder = true;
                                                        },
                                                      );
                                                    } else if (tempCartListForTestCondtion[0].productType !=
                                                            'digital_product' &&
                                                        (context.read<CartProvider>().isTimeSlot! &&
                                                            (context.read<CartProvider>().isLocalDelCharge == null || context.read<CartProvider>().isLocalDelCharge!) &&
                                                            context.read<PaymentProvider>().timeSlotList.isNotEmpty &&
                                                            (context.read<CartProvider>().selTime == null || context.read<CartProvider>().selTime!.isEmpty) &&
                                                            IS_LOCAL_ON != '0')) {
                                                      msg = getTranslated(
                                                          context,
                                                          'timeWarning');
                                                      Navigator.push(
                                                        context,
                                                        CupertinoPageRoute(
                                                          builder: (BuildContext
                                                                  context) =>
                                                              Payment(
                                                            updateCheckout,
                                                            msg,
                                                          ),
                                                        ),
                                                      );

                                                      context
                                                          .read<CartProvider>()
                                                          .checkoutState!(
                                                        () {
                                                          context
                                                              .read<
                                                                  CartProvider>()
                                                              .placeOrder = true;
                                                        },
                                                      );
                                                    } else if (double.parse(MIN_ALLOW_CART_AMT!) > context.read<CartProvider>().oriPrice) {
                                                      setSnackbar(
                                                          "${getTranslated(context, 'MIN_CART_AMT')} ${DesignConfiguration.getPriceFormat(context, double.parse(MIN_ALLOW_CART_AMT!))!}",
                                                          context);
                                                      context
                                                          .read<CartProvider>()
                                                          .checkoutState!(
                                                        () {
                                                          context
                                                              .read<
                                                                  CartProvider>()
                                                              .placeOrder = true;
                                                        },
                                                      );
                                                    } else {
                                                      if (!context
                                                          .read<CartProvider>()
                                                          .isProgress) {
                                                        confirmDialog();
                                                      }
                                                      context
                                                          .read<CartProvider>()
                                                          .checkoutState!(
                                                        () {
                                                          context
                                                              .read<
                                                                  CartProvider>()
                                                              .placeOrder = true;
                                                        },
                                                      );
                                                    }
                                                  }
                                                : null,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              )
                    : NoInterNet(
                        setStateNoInternate: setStateNoInternate,
                        buttonSqueezeanimation: buttonSqueezeanimation,
                        buttonController: buttonController,
                      ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> checkDeliverable(bool navigate) async {
    isNetworkAvail = await isNetworkAvailable();
    if (isNetworkAvail) {
      try {
        context.read<CartProvider>().setProgress(true);

        var parameter = {
          // USER_ID: context.read<UserProvider>().userId,
          ADD_ID: context.read<CartProvider>().selAddress,
        };
        apiBaseHelper.postAPICall(checkCartDelApi, parameter).then((getdata) {
          bool error = getdata['error'];
          String? msg = getdata['message'];
          List data = getdata['data'];
          context.read<CartProvider>().setProgress(false);

          if (error) {
            context.read<CartProvider>().deliverableList =
                (data).map((data) => Model.checkDeliverable(data)).toList();

            context.read<CartProvider>().checkoutState!(() {
              context.read<CartProvider>().deliverable = false;
              context.read<CartProvider>().placeOrder = true;
            });

            setSnackbar(msg!, context);
            context.read<CartProvider>().setProgress(false);
          } else {
            if (data.isEmpty) {
              context.read<CartProvider>().deliverable = true;

              setState(() {});

              if (context.read<CartProvider>().checkoutState != null) {
                context.read<CartProvider>().checkoutState!(() {});
              }
            } else {
              bool isDeliverible = false;
              bool? isShipRocket;
              context.read<CartProvider>().deliverableList =
                  (data).map((data) => Model.checkDeliverable(data)).toList();

              for (int i = 0;
                  i < context.read<CartProvider>().deliverableList.length;
                  i++) {
                if (context.read<CartProvider>().deliverableList[i].isDel ==
                    false) {
                  isDeliverible = false;
                  break;
                } else {
                  isDeliverible = true;
                  if (context.read<CartProvider>().deliverableList[i].delBy ==
                      'standard_shipping') {
                    isShipRocket = true;
                  }
                }
              }

              if (isDeliverible) {
                getShipRocketDeliveryCharge(
                    shipRocket:
                        isShipRocket != null && isShipRocket ? '1' : '0',
                    navigate: navigate);
              }
            }
            context.read<CartProvider>().setProgress(false);
          }
        }, onError: (error) {
          setSnackbar(error.toString(), context);
        });
      } on TimeoutException catch (_) {
        setSnackbar(getTranslated(context, 'somethingMSg'), context);
      }
    } else {
      isNetworkAvail = false;
      setState(() {});
    }
  }

  Future<void> getShipRocketDeliveryCharge(
      {required String shipRocket, required bool navigate}) async {
    isNetworkAvail = await isNetworkAvailable();
    if (context.read<UserProvider>().userId == null ||
        context.read<UserProvider>().userId!.trim().isEmpty) {
      return;
    }
    if (isNetworkAvail) {
      if (context.read<CartProvider>().addressList.isNotEmpty) {
        try {
          context.read<CartProvider>().setProgress(true);

          var parameter = {
            // USER_ID: context.read<UserProvider>().userId,
            ADD_ID: context
                .read<CartProvider>()
                .addressList[context.read<CartProvider>().selectedAddress!]
                .id,
            ONLY_DEL_CHARGE: shipRocket,
            DEL_PINCODE: context
                .read<CartProvider>()
                .addressList[context.read<CartProvider>().selectedAddress!]
                .pincode
            // SUB_TOTAL: oriPrice.toString()
          };

          print(parameter);

          CartRepository.fetchUserCart(parameter: parameter).then(
              (getData) async {
            bool error = getData['error'];
            String? msg = getData['message'];
            var data = getData['data'];

            if (error) {
              setSnackbar(msg.toString(), context);
              context.read<CartProvider>().checkoutState!(() {
                // _placeOrder = false;
                context.read<CartProvider>().deliverable = false;
              });
            } else {
              if (shipRocket == '1') {
                context.read<CartProvider>().codDeliverChargesOfShipRocket =
                    double.parse(data['delivery_charge_with_cod'].toString());

                context.read<CartProvider>().prePaidDeliverChargesOfShipRocket =
                    double.parse(
                        data['delivery_charge_without_cod'].toString());
                if (context.read<CartProvider>().codDeliverChargesOfShipRocket >
                        0 &&
                    context
                            .read<CartProvider>()
                            .prePaidDeliverChargesOfShipRocket >
                        0) {
                  context.read<CartProvider>().isLocalDelCharge = false;
                } else {
                  context.read<CartProvider>().isLocalDelCharge = true;
                }

                context.read<CartProvider>().shipRocketDeliverableDate =
                    data['estimate_date'] ?? '';
                if (context.read<CartProvider>().payMethod == '') {
                  context.read<CartProvider>().deliveryCharge = context
                      .read<CartProvider>()
                      .codDeliverChargesOfShipRocket;
                  if (context
                          .read<CartProvider>()
                          .isShippingDeliveryChargeApplied ==
                      false) {
                    context.read<CartProvider>().totalPrice =
                        context.read<CartProvider>().deliveryCharge +
                            context.read<CartProvider>().oriPrice;
                    context
                        .read<CartProvider>()
                        .isShippingDeliveryChargeApplied = true;
                  }
                } else {
                  if (context.read<CartProvider>().payMethod ==
                      getTranslated(context, 'COD_LBL')) {
                    context.read<CartProvider>().deliveryCharge = context
                        .read<CartProvider>()
                        .codDeliverChargesOfShipRocket;
                    if (context
                            .read<CartProvider>()
                            .isShippingDeliveryChargeApplied ==
                        false) {
                      context.read<CartProvider>().totalPrice =
                          context.read<CartProvider>().deliveryCharge +
                              context.read<CartProvider>().oriPrice;
                      context
                          .read<CartProvider>()
                          .isShippingDeliveryChargeApplied = true;
                    }
                  } else {
                    context.read<CartProvider>().deliveryCharge = context
                        .read<CartProvider>()
                        .prePaidDeliverChargesOfShipRocket;
                    if (context
                            .read<CartProvider>()
                            .isShippingDeliveryChargeApplied ==
                        false) {
                      context.read<CartProvider>().totalPrice =
                          context.read<CartProvider>().deliveryCharge +
                              context.read<CartProvider>().oriPrice;
                      context
                          .read<CartProvider>()
                          .isShippingDeliveryChargeApplied = true;
                    }
                  }
                }
              } else {
                context.read<CartProvider>().isLocalDelCharge = true;
                context.read<CartProvider>().deliveryCharge =
                    double.parse(getData[DEL_CHARGE]);
                context.read<CartProvider>().totalPrice =
                    context.read<CartProvider>().deliveryCharge +
                        context.read<CartProvider>().oriPrice;
              }

              Future.microtask(() {
                context.read<CartProvider>().checkoutState!.call(() {
                  context.read<CartProvider>().deliverable = true;
                });
              });

              if (context.read<CartProvider>().isPromoValid!) {
                await context
                    .read<PromoCodeProvider>()
                    .validatePromocode(
                      check: false,
                      context: context,
                      promocode: context.read<CartProvider>().promoC.text,
                      update: setStateNow,
                      // callShowOverlayMethod: callShowOverlayMethod
                    )
                    .then(
                  (value) {
                    FocusScope.of(context).unfocus();
                    setState(() {});
                  },
                );
              } else if (context.read<CartProvider>().isUseWallet!) {
                context.read<CartProvider>().setProgress(false);
                context.read<CartProvider>().remWalBal = 0;
                context.read<CartProvider>().payMethod = null;
                context.read<CartProvider>().usedBalance = 0;
                context.read<CartProvider>().isUseWallet = false;
                context.read<CartProvider>().isPayLayShow = true;
                setState(() {});
              } else {
                context.read<CartProvider>().setProgress(false);
                setState(() {});
              }
            }
            context.read<CartProvider>().setProgress(false);
            setState(() {});

            if (context.read<CartProvider>().checkoutState != null) {
              context.read<CartProvider>().checkoutState!(() {});
            }
          }, onError: (error) {
            setSnackbar(error.toString(), context);
          });
        } on TimeoutException catch (_) {
          setSnackbar(getTranslated(context, 'somethingMSg'), context);
        }
      }
    } else {
      isNetworkAvail = false;
      setState(() {});
    }
  }

  Future<void> _getAddress() async {
    isNetworkAvail = await isNetworkAvailable();
    if (isNetworkAvail) {
      try {
        Map<String, dynamic> parameter = {
          // USER_ID: context.read<UserProvider>().userId,
        };

        apiBaseHelper.postAPICall(getAddressApi, parameter).then((getdata) {
          bool error = getdata['error'];

          if (!error) {
            var data = getdata['data'];

            context.read<CartProvider>().addressList =
                (data as List).map((data) => User.fromAddress(data)).toList();

            if (context.read<CartProvider>().addressList.length == 1) {
              context.read<CartProvider>().selectedAddress = 0;
              context.read<CartProvider>().selAddress =
                  context.read<CartProvider>().addressList[0].id;
              if (!ISFLAT_DEL) {
                if (context.read<CartProvider>().totalPrice <
                    double.parse(
                        context.read<CartProvider>().addressList[0].freeAmt!)) {
                  context.read<CartProvider>().deliveryCharge = double.parse(
                      context
                          .read<CartProvider>()
                          .addressList[0]
                          .deliveryCharge!);
                } else {
                  context.read<CartProvider>().deliveryCharge = 0;
                }
              }
            } else {
              for (int i = 0;
                  i < context.read<CartProvider>().addressList.length;
                  i++) {
                if (context.read<CartProvider>().addressList[i].isDefault ==
                    '1') {
                  context.read<CartProvider>().selectedAddress = i;
                  context.read<CartProvider>().selAddress =
                      context.read<CartProvider>().addressList[i].id;
                  if (!ISFLAT_DEL) {
                    if (context.read<CartProvider>().totalPrice <
                        double.parse(context
                            .read<CartProvider>()
                            .addressList[i]
                            .freeAmt!)) {
                      context.read<CartProvider>().deliveryCharge =
                          double.parse(context
                              .read<CartProvider>()
                              .addressList[i]
                              .deliveryCharge!);
                    } else {
                      context.read<CartProvider>().deliveryCharge = 0;
                    }
                  }
                }
              }
            }

            if (ISFLAT_DEL) {
              if ((context.read<CartProvider>().oriPrice) <
                  double.parse(MIN_AMT!)) {
                context.read<CartProvider>().deliveryCharge =
                    double.parse(CUR_DEL_CHR!);
              } else {
                context.read<CartProvider>().deliveryCharge = 0;
              }
            }
            context.read<CartProvider>().totalPrice =
                context.read<CartProvider>().totalPrice +
                    context.read<CartProvider>().deliveryCharge;
          } else {
            if (ISFLAT_DEL) {
              if ((context.read<CartProvider>().oriPrice) <
                  double.parse(MIN_AMT!)) {
                context.read<CartProvider>().deliveryCharge =
                    double.parse(CUR_DEL_CHR!);
              } else {
                context.read<CartProvider>().deliveryCharge = 0;
              }
            }
            context.read<CartProvider>().totalPrice =
                context.read<CartProvider>().totalPrice +
                    context.read<CartProvider>().deliveryCharge;
          }
          if (mounted) {
            setState(
              () {
                _isLoading = false;
              },
            );
          }
          if (mounted) {
            if (context.read<CartProvider>().checkoutState != null) {
              context.read<CartProvider>().checkoutState!(() {});
            }
          }
        }, onError: (error) {
          setSnackbar(error.toString(), context);
        });
      } on TimeoutException catch (_) {}
    } else {
      if (mounted) {
        setState(
          () {
            isNetworkAvail = false;
          },
        );
      }
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    Map<String, dynamic> result =
        await updateOrderStatus(orderID: razorpayOrderId, status: PLACED);
    if (!result['error']) {
      await addTransaction(
          response.paymentId, razorpayOrderId, SUCCESS, rozorpayMsg, true);
    } else {
      setSnackbar('${result['message']}', context);
    }
    if (mounted) {
      context.read<CartProvider>().setProgress(false);
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    setSnackbar(getTranslated(context, 'somethingMSg'), context);
    deleteOrder(razorpayOrderId);
    if (mounted) {
      context.read<CartProvider>().checkoutState!(
        () {
          context.read<CartProvider>().placeOrder = true;
        },
      );
    }
    context.read<CartProvider>().setProgress(false);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {}

  Future<Map<String, dynamic>> updateOrderStatus(
      {required String status, required String orderID}) async {
    var parameter = {ORDER_ID: orderID, STATUS: status};
    var result = await ApiBaseHelper().postAPICall(updateOrderApi, parameter);

    return {'error': result['error'], 'message': result['message']};
  }

  updateCheckout() {
    if (mounted) context.read<CartProvider>().checkoutState!(() {});
  }

  razorpayPayment(
    String orderID,
    String? msg,
  ) async {
    SettingProvider settingsProvider =
        Provider.of<SettingProvider>(context, listen: false);

    String? contact = settingsProvider.mobile;
    String? email = settingsProvider.email;
    String amt =
        (context.read<CartProvider>().totalPrice * 100).toStringAsFixed(2);

    //  if (contact != '' && email != '') {
    context.read<CartProvider>().setProgress(true);

    context.read<CartProvider>().checkoutState!(() {});
    try {
      //create a razorpayOrder for capture payment automatically
      var response = await ApiBaseHelper()
          .postAPICall(createRazorpayOrder, {'order_id': orderID});
      print("response data*****${response['data']}");
      var razorpayOrderID = response['data']['id'];
      var options = {
        KEY: context.read<CartProvider>().razorpayId,
        AMOUNT: amt,
        NAME: settingsProvider.userName,
        'prefill': {
          CONTACT: contact,
          EMAIL: email /*, 'Order Id': orderID*/
        },
        'order_id': razorpayOrderID,
      };
      razorpayOrderId = orderID;
      rozorpayMsg = msg;
      _razorpay = Razorpay();
      _razorpay!.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
      _razorpay!.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
      _razorpay!.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

      _razorpay!.open(options);
    } catch (e) {}
    /*} else {
      if (email == '') {
        setSnackbar(getTranslated(context, 'emailWarning')!, context);
      } else if (contact == '') {
        setSnackbar(getTranslated(context, 'phoneWarning')!, context);
      }
    }*/
  }

  Future<void> deleteOrder(String orderId) async {
    try {
      var parameter = {
        ORDER_ID: orderId,
      };

      http.Response response =
          await post(deleteOrderApi, body: parameter, headers: headers)
              .timeout(const Duration(seconds: timeOut));
      var getdata = json.decode(response.body);

      bool error = getdata['error'];
      if (!error) {
        //context.read<CartProvider>().removeCart();
      }

      if (mounted) {
        setState(() {});
      }

      Navigator.of(context).pop();
    } on TimeoutException catch (_) {
      setSnackbar(getTranslated(context, 'somethingMSg'), context);

      setState(() {});
    }
  }

  void paytmPayment(String? tranId, String orderID, String? status, String? msg,
      bool redirect) async {
    String? paymentResponse;
    context.read<CartProvider>().setProgress(true);

/*    String orderId = DateTime
        .now()
        .millisecondsSinceEpoch
        .toString();*/

    String callBackUrl =
        '${context.read<CartProvider>().payTesting ? 'https://securegw-stage.paytm.in' : 'https://securegw.paytm.in'}/theia/paytmCallback?ORDER_ID=$orderID';

    var parameter = {
      AMOUNT: context.read<CartProvider>().totalPrice.toString(),
      // USER_ID: context.read<UserProvider>().userId,
      ORDER_ID: orderID
    };

    try {
      apiBaseHelper.postAPICall(getPytmChecsumkApi, parameter).then(
        (getdata) async {
          bool error = getdata['error'];

          if (!error) {
            String txnToken = getdata['txn_token'];
            setState(
              () {
                paymentResponse = txnToken;
              },
            );
            print(
                'context.read<CartProvider>().paytmMerId******${context.read<CartProvider>().paytmMerId!}****$orderID***${context.read<CartProvider>().totalPrice.toString()}****$txnToken****$callBackUrl****${context.read<CartProvider>().payTesting}');
            var response = await AllInOneSdk.startTransaction(
                context.read<CartProvider>().paytmMerId!,
                orderID,
                context.read<CartProvider>().totalPrice.toString(),
                txnToken,
                callBackUrl,
                context.read<CartProvider>().payTesting,
                false);
            print('response***$response');

            if (response!['errorCode'] == null) {
              if (response['STATUS'] == 'TXN_SUCCESS') {
                await updateOrderStatus(orderID: orderID, status: PLACED);
                addTransaction(response['TXNID'], orderID, SUCCESS, msg, true);
              } else {
                deleteOrder(orderID);
              }

              setSnackbar(response['STATUS'], context);
            } else {
              String paymentResponse = response['RESPMSG'];

              if (response['response'] != null) {
                addTransaction(response['TXNID'], orderID,
                    response['STATUS'] ?? '', paymentResponse, false);
              }

              setSnackbar(paymentResponse, context);
            }

            context.read<CartProvider>().setProgress(false);
            context.read<CartProvider>().placeOrder = true;
            setState(() {});
          } else {
            context.read<CartProvider>().checkoutState!(
              () {
                context.read<CartProvider>().placeOrder = true;
              },
            );
            context.read<CartProvider>().setProgress(false);
            setSnackbar(getdata['message'], context);
          }
        },
        onError: (error) {
          setSnackbar(error.toString(), context);
        },
      );
    } catch (e) {}
  }

  void initPhonePeSdk({required String orderId}) async {
    PhonePePaymentSdk.init(
            context.read<CartProvider>().phonePeMode!.toUpperCase(),
            context.read<CartProvider>().phonePeAppId ?? '',
            context.read<CartProvider>().phonePeMerId!,
            true)
        .then((isInitialized) {
      startPaymentPhonePe(orderId: orderId);
    }).catchError((error) {
      return <dynamic>{};
    });
  }

  void startPaymentPhonePe({required String orderId}) async {
    try {
      final phonePeDetails = await PaymentRepository.getPhonePeDetails(
        userId: context.read<UserProvider>().userId ?? '0',
        type: 'cart',
        mobile: context.read<UserProvider>().mob.trim().isEmpty
            ? context.read<UserProvider>().userId ?? '0'
            : context.read<UserProvider>().mob,
        orderId: orderId,
        transationId: orderId,
      );

      await PhonePePaymentSdk.startTransaction(
              jsonEncode(phonePeDetails['data']['payload'] ?? {}).toBase64,
              phonePeDetails['data']['payload']['redirectUrl'] ?? '',
              phonePeDetails['data']['checksum'] ?? '',
              Platform.isAndroid ? packageName : iosPackage)
          .then((response) async {
        if (response != null) {
          String status = response['status'].toString();
          if (status == 'SUCCESS') {
            // "Flow Completed - Status: Success!";

            // await updateOrderStatus(orderID: orderId, status: PLACED);
            // await addTransaction(orderId, orderId, SUCCESS, status, true);
            context.read<UserProvider>().setCartCount('0');
            clearAll();
            Routes.navigateToOrderSuccessScreen(context);

            if (mounted) {
              context.read<CartProvider>().setProgress(false);
            }
          } else {
            // "Flow Completed - Status: $status and Error: $error";
            // setSnackbar(response.message.toString(), context);
            deleteOrder(orderId);
            setSnackbar(
                getTranslated(context, 'PHONEPE_PAYMENT_FAILED'), context);
            if (mounted) {
              context.read<CartProvider>().checkoutState!(
                () {
                  context.read<CartProvider>().placeOrder = true;
                },
              );
            }
            context.read<CartProvider>().setProgress(false);
          }
        } else {
          // "Flow Incomplete";
          // setSnackbar(, context);
          deleteOrder(orderId);
          setSnackbar(
              getTranslated(context, 'PHONEPE_PAYMENT_FAILED'), context);
          if (mounted) {
            context.read<CartProvider>().checkoutState!(
              () {
                context.read<CartProvider>().placeOrder = true;
              },
            );
          }
          context.read<CartProvider>().setProgress(false);
        }
      }).catchError((error) {
        return <dynamic>{};
      });
    } catch (error) {
      setSnackbar(getTranslated(context, 'PHONEPE_PAYMENT_FAILED'), context);
      context.read<CartProvider>().setProgress(false);
    }
  }

  Future<void> placeOrder(String? tranId) async {
    isNetworkAvail = await isNetworkAvailable();
    if (isNetworkAvail) {
      context.read<CartProvider>().setProgress(true);
      List<SectionModel> tempCartListForTestCondtion =
          context.read<CartProvider>().cartList;
      SettingProvider settingsProvider =
          Provider.of<SettingProvider>(context, listen: false);

      String? mob = settingsProvider.mobile;

      String? varientId, quantity;

      List<SectionModel> cartList = context.read<CartProvider>().cartList;
      for (SectionModel sec in cartList) {
        varientId =
            varientId != null ? '$varientId,${sec.varientId!}' : sec.varientId;
        quantity = quantity != null ? '$quantity,${sec.qty!}' : sec.qty;
      }

      String? payVia;
      if (context.read<CartProvider>().payMethod ==
          getTranslated(context, 'COD_LBL')) {
        payVia = 'COD';
      } else if (context.read<CartProvider>().payMethod ==
          getTranslated(context, 'PAYPAL_LBL')) {
        payVia = 'PayPal';
      } else if (context.read<CartProvider>().payMethod ==
          getTranslated(context, 'PAYUMONEY_LBL')) {
        payVia = 'PayUMoney';
      } else if (context.read<CartProvider>().payMethod ==
          getTranslated(context, 'RAZORPAY_LBL')) {
        payVia = 'RazorPay';
      } else if (context.read<CartProvider>().payMethod ==
          getTranslated(context, 'PHONEPE_LBL')) {
        payVia = 'phonepe';
      } else if (context.read<CartProvider>().payMethod ==
          getTranslated(context, 'PAYSTACK_LBL')) {
        payVia = 'Paystack';
      } else if (context.read<CartProvider>().payMethod ==
          getTranslated(context, 'FLUTTERWAVE_LBL')) {
        payVia = 'Flutterwave';
      } else if (context.read<CartProvider>().payMethod ==
          getTranslated(context, 'STRIPE_LBL')) {
        payVia = 'Stripe';
      } else if (context.read<CartProvider>().payMethod ==
          getTranslated(context, 'PAYTM_LBL')) {
        payVia = 'Paytm';
      } else if (context.read<CartProvider>().payMethod == 'Wallet') {
        payVia = 'Wallet';
      } else if (context.read<CartProvider>().payMethod ==
          getTranslated(context, 'BANKTRAN')) {
        payVia = 'bank_transfer';
      } else if (context.read<CartProvider>().payMethod ==
          getTranslated(context, 'MidTrans')) {
        payVia = 'midtrans';
      } else if (context.read<CartProvider>().payMethod ==
          getTranslated(context, 'My Fatoorah')) {
        payVia = 'my fatoorah';
      } else if (context.read<CartProvider>().payMethod ==
          getTranslated(context, 'instamojo_lbl')) {
        payVia = 'instamojo';
      }
      var request = http.MultipartRequest('POST', placeOrderApi);
      request.headers.addAll(headers ?? {});

      try {
        // request.fields[USER_ID] = context.read<UserProvider>().userId!;
        request.fields[MOBILE] = mob;
        request.fields[PRODUCT_VARIENT_ID] = varientId!;
        request.fields[QUANTITY] = quantity!;
        request.fields[TOTAL] =
            context.read<CartProvider>().oriPrice.toString();
        request.fields[FINAL_TOTAL] =
            context.read<CartProvider>().totalPrice.toString();

        request.fields[DEL_CHARGE] =
            context.read<CartProvider>().deliveryCharge.toString();

        request.fields[TAX_PER] =
            context.read<CartProvider>().taxPer.toString();
        request.fields[PAYMENT_METHOD] = payVia!;
        if (tempCartListForTestCondtion[0].productType != 'digital_product') {
          request.fields[ADD_ID] = context.read<CartProvider>().selAddress!;

          if (context.read<CartProvider>().isTimeSlot!) {
            request.fields[DELIVERY_TIME] =
                context.read<CartProvider>().selTime ?? 'Anytime';
            request.fields[DELIVERY_DATE] =
                context.read<CartProvider>().selDate ?? '';
          }
        }

        if (tempCartListForTestCondtion[0].productType == 'digital_product') {
          request.fields['email'] =
              context.read<CartProvider>().emailController.text;
        }
        request.fields[ISWALLETBALUSED] =
            context.read<CartProvider>().isUseWallet! ? '1' : '0';
        request.fields[WALLET_BAL_USED] =
            context.read<CartProvider>().usedBalance.toString();
        request.fields[ORDER_NOTE] =
            context.read<CartProvider>().noteController.text;

        if (context.read<CartProvider>().isPromoValid!) {
          request.fields[PROMOCODE] = context.read<CartProvider>().promocode!;
          request.fields[PROMO_DIS] =
              context.read<CartProvider>().promoAmt.toString();
        }

        if (context.read<CartProvider>().payMethod ==
            getTranslated(context, 'COD_LBL')) {
          request.fields[ACTIVE_STATUS] = PLACED;
        } else if (tempCartListForTestCondtion[0].productType ==
            'digital_product') {
          // request.fields[ACTIVE_STATUS] = DELIVERD;
        } else {
          if (context.read<CartProvider>().payMethod ==
              getTranslated(context, 'PHONEPE_LBL')) {
            request.fields[ACTIVE_STATUS] = 'draft';
          } else {
            request.fields[ACTIVE_STATUS] = WAITING;
          }
        }

        if (context.read<CartProvider>().prescriptionImages.isNotEmpty) {
          for (var i = 0;
              i < context.read<CartProvider>().prescriptionImages.length;
              i++) {
            final mimeType = lookupMimeType(
                context.read<CartProvider>().prescriptionImages[i].path);

            var extension = mimeType!.split('/');

            var pic = await http.MultipartFile.fromPath(
              DOCUMENT,
              context.read<CartProvider>().prescriptionImages[i].path,
              contentType: MediaType('image', extension[1]),
            );

            request.files.add(pic);
          }
        }
         print('request fields****${request.fields}');
        var response = await request.send();
       
        print('response statuscode****${response.statusCode}');
        var responseData = await response.stream.toBytes();
        var responseString = String.fromCharCodes(responseData);
        context.read<CartProvider>().placeOrder = true;
        if (response.statusCode == 200) {
          var getdata = json.decode(responseString);
          print('getdata response place order****$getdata');
          bool error = getdata['error'];
          String? msg = getdata['message'];
          if (!error) {
            String orderId = getdata['order_id'].toString();
            if (context.read<CartProvider>().payMethod ==
                getTranslated(context, 'RAZORPAY_LBL')) {
              razorpayPayment(orderId, msg);
            } else if (context.read<CartProvider>().payMethod ==
                getTranslated(context, 'PHONEPE_LBL')) {
              initPhonePeSdk(orderId: orderId);
            } else if (context.read<CartProvider>().payMethod ==
                getTranslated(context, 'PAYPAL_LBL')) {
              paypalPayment(orderId);
            } else if (context.read<CartProvider>().payMethod ==
                getTranslated(context, 'STRIPE_LBL')) {
              stripePayment(context.read<CartProvider>().stripePayId, orderId,
                  tranId == 'succeeded' ? PLACED : WAITING, msg, true);
            } else if (context.read<CartProvider>().payMethod ==
                getTranslated(context, 'PAYSTACK_LBL')) {
              paystackPayment(context, tranId, orderId, SUCCESS, msg, true);
            } else if (context.read<CartProvider>().payMethod ==
                getTranslated(context, 'PAYTM_LBL')) {
              paytmPayment(tranId, orderId, SUCCESS, msg, true);
            } else if (context.read<CartProvider>().payMethod ==
                getTranslated(context, 'FLUTTERWAVE_LBL')) {
              flutterwavePayment(tranId, orderId, SUCCESS, msg, true);
            } else if (context.read<CartProvider>().payMethod ==
                getTranslated(context, 'MidTrans')) {
              midTrasPayment(
                  orderId, tranId == 'succeeded' ? PLACED : WAITING, msg, true);
            } else if (context.read<CartProvider>().payMethod ==
                getTranslated(context, 'My Fatoorah')) {
              fatoorahPayment(tranId, orderId,
                  tranId == 'succeeded' ? PLACED : WAITING, msg, true);
            } else if (context.read<CartProvider>().payMethod ==
                getTranslated(context, 'instamojo_lbl')) {
              instamojoPayment(orderId);
            } else {
              context.read<UserProvider>().setCartCount('0');
              clearAll();
              Routes.navigateToOrderSuccessScreen(context);
            }
          } else {
            setSnackbar(msg!, context);
            context.read<CartProvider>().setProgress(false);
          }
        }
      } on TimeoutException catch (_) {
        if (mounted) {
          context.read<CartProvider>().checkoutState!(
            () {
              context.read<CartProvider>().placeOrder = true;
            },
          );
        }
        context.read<CartProvider>().setProgress(false);
      }
    } else {
      if (mounted) {
        context.read<CartProvider>().checkoutState!(
          () {
            isNetworkAvail = false;
          },
        );
      }
    }
  }

  Future<void> instamojoPayment(String orderId) async {
    try {
      var parameter = {
        // USER_ID: context.read<UserProvider>().userId,
        ORDER_ID: orderId,
        // AMOUNT: context.read<CartProvider>().totalPrice.toString()
      };
      apiBaseHelper.postAPICall(getInstamojoWebviewApi, parameter).then(
        (getdata) {
          print('getdata instamojo****$getdata');
          bool error = getdata['error'];
          String? msg = getdata['message'];
          if (!error) {
            if (getdata['data']['longurl'] != null &&
                getdata['data']['longurl'] != '') {
              String? data = getdata['data']['longurl'];
              Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (BuildContext context) => InstamojoWebview(
                    url: data,
                    from: 'order',
                    orderId: orderId,
                  ),
                ),
              );
            } else {
              deleteOrder(orderId);
              setSnackbar(getTranslated(context, 'somethingMSg'), context);
            }
          } else {
            deleteOrder(orderId);
            setSnackbar(msg!, context);
          }
          context.read<CartProvider>().setProgress(false);
        },
        onError: (error) {
          setSnackbar(error.toString(), context);
        },
      );
    } on TimeoutException catch (_) {
      setSnackbar(getTranslated(context, 'somethingMSg'), context);
    }
  }

  Future<void> paypalPayment(String orderId) async {
    try {
      var parameter = {
        // USER_ID: context.read<UserProvider>().userId,
        ORDER_ID: orderId,
        AMOUNT: context.read<CartProvider>().totalPrice.toString()
      };
      apiBaseHelper.postAPICall(paypalTransactionApi, parameter).then(
        (getdata) {
          bool error = getdata['error'];
          String? msg = getdata['message'];
          if (!error) {
            String? data = getdata['data'];
            Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (BuildContext context) => WebViewClass(
                  url: data,
                  from: 'order',
                  orderId: orderId,
                ),
              ),
            );
          } else {
            setSnackbar(msg!, context);
          }
          context.read<CartProvider>().setProgress(false);
        },
        onError: (error) {
          setSnackbar(error.toString(), context);
        },
      );
    } on TimeoutException catch (_) {
      setSnackbar(getTranslated(context, 'somethingMSg'), context);
    }
  }

  Future<void> addTransaction(
    String? tranId,
    String orderID,
    String? status,
    String? msg,
    bool redirect,
  ) async {
    try {
      var parameter = {
        // USER_ID: context.read<UserProvider>().userId,
        ORDER_ID: orderID,
        TYPE: context.read<CartProvider>().payMethod,
        TXNID: tranId,
        AMOUNT: context.read<CartProvider>().totalPrice.toString(),
        STATUS: status,
        MSG: msg ?? '$status the payment'
      };
      apiBaseHelper.postAPICall(addTransactionApi, parameter).then(
        (getdata) {
          bool error = getdata['error'];
          String? msg1 = getdata['message'];

          if (!error) {
            if (redirect) {
              context.read<UserProvider>().setCartCount('0');
              clearAll();
              Routes.navigateToOrderSuccessScreen(context);
            }
          } else {
            setSnackbar(msg1!, context);
          }
        },
        onError: (error) {
          setSnackbar(error.toString(), context);
        },
      );
    } on TimeoutException catch (_) {
      setSnackbar(getTranslated(context, 'somethingMSg'), context);
    }
  }

  paystackPayment(
    BuildContext context,
    String? tranId,
    String orderID,
    String? status,
    String? msg,
    bool redirect,
  ) async {
    context.read<CartProvider>().setProgress(true);
    await paystackPlugin.initialize(
        publicKey: context.read<CartProvider>().paystackId!);
    String? email = context.read<SettingProvider>().email;

    Charge charge = Charge()
      ..amount = (context.read<CartProvider>().totalPrice * 100).toInt()
      ..reference = _getReference()
      ..putMetaData('order_id', orderID)
      ..email = email;
    try {
      CheckoutResponse response = await paystackPlugin.checkout(
        context,
        method: CheckoutMethod.card,
        charge: charge,
      );
      if (response.status) {
        addTransaction(response.reference, orderID, SUCCESS, msg, true);
      } else {
        deleteOrder(orderID);
        setSnackbar(response.message, context);
        if (mounted) {
          context.read<CartProvider>().checkoutState!(
            () {
              context.read<CartProvider>().placeOrder = true;
            },
          );
        }
        context.read<CartProvider>().setProgress(false);
      }
    } catch (e) {
      context.read<CartProvider>().setProgress(false);
      rethrow;
    }
  }

  String _getReference() {
    String platform;
    if (Platform.isIOS) {
      platform = 'iOS';
    } else {
      platform = 'Android';
    }
    return 'ChargedFrom${platform}_${DateTime.now().millisecondsSinceEpoch}';
  }

  fatoorahPayment(
    String? tranId,
    String orderID,
    String? status,
    String? msg,
    bool redirect,
  ) async {
    isNetworkAvail = await isNetworkAvailable();
    if (isNetworkAvail) {
      try {
        String amount = context.read<CartProvider>().totalPrice.toString();
        String successUrl =
            '${context.read<CartProvider>().myfatoorahSuccessUrl!}?order_id=$orderID&amount=${double.parse(amount)}';
        String errorUrl =
            '${context.read<CartProvider>().myfatoorahErrorUrl!}?order_id=$orderID&amount=${double.parse(amount)}';
        String token = context.read<CartProvider>().myfatoorahToken!;
        context.read<CartProvider>().setProgress(true);
        var response = await MyFatoorah.startPayment(
          context: context,
          successChild: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  getTranslated(context, 'Payment Done Successfully ...!'),
                  style: const TextStyle(
                    fontFamily: 'ubuntu',
                  ),
                ),
                const SizedBox(
                  width: 200,
                  height: 100,
                  child: Icon(
                    Icons.done,
                    size: 100,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
          request: context.read<CartProvider>().myfatoorahPaymentMode == 'test'
              ? MyfatoorahRequest.test(
                  currencyIso: () {
                    if (context.read<CartProvider>().myfatoorahCountry ==
                        'Kuwait') {
                      return Country.Kuwait;
                    } else if (context.read<CartProvider>().myfatoorahCountry ==
                        'UAE') {
                      return Country.UAE;
                    } else if (context.read<CartProvider>().myfatoorahCountry ==
                        'Egypt') {
                      return Country.Egypt;
                    } else if (context.read<CartProvider>().myfatoorahCountry ==
                        'Bahrain') {
                      return Country.Bahrain;
                    } else if (context.read<CartProvider>().myfatoorahCountry ==
                        'Jordan') {
                      return Country.Jordan;
                    } else if (context.read<CartProvider>().myfatoorahCountry ==
                        'Oman') {
                      return Country.Oman;
                    } else if (context.read<CartProvider>().myfatoorahCountry ==
                        'SaudiArabia') {
                      return Country.SaudiArabia;
                    } else if (context.read<CartProvider>().myfatoorahCountry ==
                        'SaudiArabia') {
                      return Country.Qatar;
                    }
                    return Country.SaudiArabia;
                  }(),
                  successUrl: successUrl,
                  errorUrl: errorUrl,
                  invoiceAmount: double.parse(amount),
                  userDefinedField: orderID,
                  language: () {
                    if (context.read<CartProvider>().myfatoorahLanguage ==
                        'english') {
                      return ApiLanguage.English;
                    }
                    return ApiLanguage.Arabic;
                  }(),
                  token: token,
                )
              : MyfatoorahRequest.live(
                  currencyIso: () {
                    if (context.read<CartProvider>().myfatoorahCountry ==
                        'Kuwait') {
                      return Country.Kuwait;
                    } else if (context.read<CartProvider>().myfatoorahCountry ==
                        'UAE') {
                      return Country.UAE;
                    } else if (context.read<CartProvider>().myfatoorahCountry ==
                        'Egypt') {
                      return Country.Egypt;
                    } else if (context.read<CartProvider>().myfatoorahCountry ==
                        'Bahrain') {
                      return Country.Bahrain;
                    } else if (context.read<CartProvider>().myfatoorahCountry ==
                        'Jordan') {
                      return Country.Jordan;
                    } else if (context.read<CartProvider>().myfatoorahCountry ==
                        'Oman') {
                      return Country.Oman;
                    } else if (context.read<CartProvider>().myfatoorahCountry ==
                        'SaudiArabia') {
                      return Country.SaudiArabia;
                    } else if (context.read<CartProvider>().myfatoorahCountry ==
                        'SaudiArabia') {
                      return Country.Qatar;
                    }
                    return Country.SaudiArabia;
                  }(),
                  successUrl: successUrl,
                  userDefinedField: orderID,
                  errorUrl: errorUrl,
                  invoiceAmount: double.parse(amount),
                  language: () {
                    if (context.read<CartProvider>().myfatoorahLanguage ==
                        'english') {
                      return ApiLanguage.English;
                    }
                    return ApiLanguage.Arabic;
                  }(),
                  token: token,
                ),
        );
        context.read<CartProvider>().setProgress(false);

        if (response.status.toString() == 'PaymentStatus.Success') {
          context.read<CartProvider>().setProgress(true);

          await updateOrderStatus(orderID: orderID, status: PLACED);
          addTransaction(
            response.paymentId,
            orderID,
            PLACED,
            msg,
            true,
          );
        }
        if (response.status.toString() == 'PaymentStatus.None') {
          setSnackbar(response.status.toString(), context);
          deleteOrder(orderID);
          //
        }
        if (response.status.toString() == 'PaymentStatus.Error') {
          setSnackbar(response.status.toString(), context);
          deleteOrder(orderID);
        }
      } on TimeoutException catch (_) {
        context.read<CartProvider>().setProgress(false);
        setSnackbar(getTranslated(context, 'somethingMSg'), context);
      }
    } else {
      if (mounted) {
        context.read<CartProvider>().checkoutState!(
          () {
            isNetworkAvail = false;
          },
        );
      }
    }
  }

  midTrasPayment(
    // String? tranId,
    String orderID,
    String? status,
    String? msg,
    bool redirect,
  ) async {
    isNetworkAvail = await isNetworkAvailable();
    if (isNetworkAvail) {
      try {
        context.read<CartProvider>().setProgress(true);
        var parameter = {
          AMOUNT: context.read<CartProvider>().totalPrice.toString(),
          // USER_ID: context.read<UserProvider>().userId,
          ORDER_ID: orderID
        };
        apiBaseHelper.postAPICall(createMidtransTransactionApi, parameter).then(
          (getdata) {
            bool error = getdata['error'];
            String? msg = getdata['message'];
            if (!error) {
              var data = getdata['data'];
              String redirectUrl = data['redirect_url'];
              Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (BuildContext context) => MidTrashWebview(
                    url: redirectUrl,
                    from: 'order',
                    orderId: orderID,
                  ),
                ),
              ).then(
                (value) async {
                  isNetworkAvail = await isNetworkAvailable();
                  if (isNetworkAvail) {
                    try {
                      context.read<CartProvider>().setProgress(true);
                      var parameter = {
                        ORDER_ID: orderID,
                      };
                      apiBaseHelper
                          .postAPICall(
                              getMidtransTransactionStatusApi, parameter)
                          .then(
                        (getdata) async {
                          bool error = getdata['error'];
                          String? msg = getdata['message'];
                          var data = getdata['data'];
                          if (!error) {
                            String statuscode = data['status_code'];

                            if (statuscode == '404') {
                              deleteOrder(orderID);
                              if (mounted) {
                                context.read<CartProvider>().checkoutState!(
                                  () {
                                    context.read<CartProvider>().placeOrder =
                                        true;
                                  },
                                );
                              }
                              context.read<CartProvider>().setProgress(false);
                            }

                            if (statuscode == '200') {
                              String transactionStatus =
                                  data['transaction_status'];
                              String transactionId = data['transaction_id'];
                              if (transactionStatus == 'capture') {
                                Map<String, dynamic> result =
                                    await updateOrderStatus(
                                        orderID: orderID, status: PLACED);
                                if (!result['error']) {
                                  await addTransaction(
                                    transactionId,
                                    orderID,
                                    SUCCESS,
                                    rozorpayMsg,
                                    true,
                                  );
                                } else {
                                  setSnackbar('${result['message']}', context);
                                }
                                if (mounted) {
                                  context
                                      .read<CartProvider>()
                                      .setProgress(false);
                                }
                              } else {
                                deleteOrder(orderID);
                                if (mounted) {
                                  context.read<CartProvider>().checkoutState!(
                                    () {
                                      context.read<CartProvider>().placeOrder =
                                          true;
                                    },
                                  );
                                }
                                context.read<CartProvider>().setProgress(false);
                              }
                            }
                          } else {
                            setSnackbar(msg!, context);
                          }

                          context.read<CartProvider>().setProgress(false);
                        },
                        onError: (error) {
                          setSnackbar(error.toString(), context);
                        },
                      );
                    } on TimeoutException catch (_) {
                      context.read<CartProvider>().setProgress(false);
                      setSnackbar(
                          getTranslated(context, 'somethingMSg'), context);
                    }
                  } else {
                    if (mounted) {
                      context.read<CartProvider>().checkoutState!(
                        () {
                          isNetworkAvail = false;
                        },
                      );
                    }
                  }
                  if (value == 'true') {
                    context.read<CartProvider>().checkoutState!(
                      () {
                        context.read<CartProvider>().placeOrder = true;
                      },
                    );
                  } else {}
                },
              );
            } else {
              setSnackbar(msg!, context);
            }
            context.read<CartProvider>().setProgress(false);
          },
          onError: (error) {
            setSnackbar(error.toString(), context);
          },
        );
      } on TimeoutException catch (_) {
        context.read<CartProvider>().setProgress(false);
        setSnackbar(getTranslated(context, 'somethingMSg'), context);
      }
    } else {
      if (mounted) {
        context.read<CartProvider>().checkoutState!(() {
          isNetworkAvail = false;
        });
      }
    }
  }

  stripePayment(String? tranId, String orderID, String? status, String? msg,
      bool redirect) async {
    context.read<CartProvider>().setProgress(true);
    var response = await StripeService.payWithPaymentSheet(
        amount:
            (context.read<CartProvider>().totalPrice * 100).toInt().toString(),
        currency: context.read<CartProvider>().stripeCurCode,
        from: 'order',
        context: context,
        awaitedOrderId: orderID);

    if (response.message == 'Transaction successful') {
      await updateOrderStatus(orderID: orderID, status: PLACED);
      addTransaction(context.read<CartProvider>().stripePayId, orderID,
          response.status == 'succeeded' ? PLACED : WAITING, msg, true);
    } else if (response.status == 'pending' || response.status == 'captured') {
      await updateOrderStatus(orderID: orderID, status: WAITING);
      addTransaction(
        context.read<CartProvider>().stripePayId,
        orderID,
        tranId == 'succeeded' ? PLACED : WAITING,
        msg,
        true,
      );
      if (mounted) {
        setState(
          () {
            context.read<CartProvider>().placeOrder = true;
          },
        );
      }
    } else {
      deleteOrder(orderID);
      if (mounted) {
        setState(
          () {
            context.read<CartProvider>().placeOrder = true;
          },
        );
      }

      context.read<CartProvider>().setProgress(false);
    }
    setSnackbar(response.message!, context);
  }

  cartItems(List<SectionModel> cartList) {
    return ListView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      itemCount: cartList.length,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return CartIteam(
          index: index,
          cartList: cartList,
          setState: setStateNow,
        );
      },
    );
  }

  Future<void> flutterwavePayment(
    String? tranId,
    String orderID,
    String? status,
    String? msg,
    bool redirect,
  ) async {
    isNetworkAvail = await isNetworkAvailable();
    if (isNetworkAvail) {
      try {
        context.read<CartProvider>().setProgress(true);
        var parameter = {
          AMOUNT: context.read<CartProvider>().totalPrice.toString(),
          // USER_ID: context.read<UserProvider>().userId,
          ORDER_ID: orderID
        };
        apiBaseHelper.postAPICall(flutterwaveApi, parameter).then(
          (getdata) {
            bool error = getdata['error'];
            String? msg = getdata['message'];
            if (!error) {
              var data = getdata['link'];
              Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (BuildContext context) => WebViewClass(
                    url: data,
                    from: 'order',
                    orderId: orderID,
                  ),
                ),
              ).then(
                (value) {
                  if (value == 'true') {
                    context.read<CartProvider>().checkoutState!(
                      () {
                        context.read<CartProvider>().placeOrder = true;
                      },
                    );
                  } else {
                    deleteOrder(orderID);
                  }
                },
              );
            } else {
              setSnackbar(msg!, context);
            }

            context.read<CartProvider>().setProgress(false);
          },
          onError: (error) {
            setSnackbar(error.toString(), context);
          },
        );
      } on TimeoutException catch (_) {
        context.read<CartProvider>().setProgress(false);
        setSnackbar(getTranslated(context, 'somethingMSg'), context);
      }
    } else {
      if (mounted) {
        context.read<CartProvider>().checkoutState!(() {
          isNetworkAvail = false;
        });
      }
    }
  }

  void confirmDialog() {
    showGeneralDialog(
      barrierColor: Theme.of(context).colorScheme.black.withOpacity(0.5),
      transitionBuilder: (context, a1, a2, widget) {
        return Transform.scale(
          scale: a1.value,
          child: Opacity(
            opacity: a1.value,
            child: AlertDialog(
              contentPadding: const EdgeInsets.all(0),
              elevation: 2.0,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(circularBorderRadius5),
                ),
              ),
              content: const GetContent(),
              actions: <Widget>[
                TextButton(
                  child: Text(
                    getTranslated(context, 'CANCEL'),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.lightBlack,
                      fontSize: textFontSize15,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'ubuntu',
                    ),
                  ),
                  onPressed: () {
                    context.read<CartProvider>().checkoutState!(
                      () {
                        context.read<CartProvider>().placeOrder = true;
                      },
                    );
                    Routes.pop(context);
                  },
                ),
                TextButton(
                  child: Text(
                    getTranslated(context, 'DONE'),
                    style: const TextStyle(
                      color: colors.primary,
                      fontSize: textFontSize15,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'ubuntu',
                    ),
                  ),
                  onPressed: () {
                    Routes.pop(context);
                    if (context.read<CartProvider>().payMethod ==
                        getTranslated(context, 'BANKTRAN')) {
                      bankTransfer();
                    } else {
                      placeOrder('');
                    }
                  },
                )
              ],
            ),
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 200),
      barrierDismissible: false,
      barrierLabel: '',
      context: context,
      pageBuilder: (context, animation1, animation2) {
        return const SizedBox();
      },
    );
  }

  void bankTransfer() {
    showGeneralDialog(
      barrierColor: Theme.of(context).colorScheme.black.withOpacity(0.5),
      transitionBuilder: (context, a1, a2, widget) {
        return Transform.scale(
          scale: a1.value,
          child: Opacity(
            opacity: a1.value,
            child: AlertDialog(
              contentPadding: const EdgeInsets.all(0),
              elevation: 2.0,
              shape: const RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.all(Radius.circular(circularBorderRadius5))),
              content: const GetBankTransferContent(),
              actions: <Widget>[
                TextButton(
                  child: Text(
                    getTranslated(context, 'CANCEL'),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.lightBlack,
                      fontSize: textFontSize15,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'ubuntu',
                    ),
                  ),
                  onPressed: () {
                    context.read<CartProvider>().checkoutState!(
                      () {
                        context.read<CartProvider>().placeOrder = true;
                      },
                    );
                    Routes.pop(context);
                  },
                ),
                TextButton(
                  child: Text(
                    getTranslated(context, 'DONE'),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.fontColor,
                      fontSize: textFontSize15,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'ubuntu',
                    ),
                  ),
                  onPressed: () {
                    Routes.pop(context);

                    context.read<CartProvider>().setProgress(true);

                    placeOrder('');
                  },
                )
              ],
            ),
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 200),
      barrierDismissible: false,
      barrierLabel: '',
      context: context,
      pageBuilder: (context, animation1, animation2) {
        return const SizedBox();
      },
    );
  }
}
