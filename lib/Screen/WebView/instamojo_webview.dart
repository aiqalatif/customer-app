import 'dart:async';
import 'dart:convert';

import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:eshop_multivendor/Helper/Constant.dart';
import 'package:eshop_multivendor/Helper/String.dart';
import 'package:eshop_multivendor/Helper/routes.dart';
import 'package:eshop_multivendor/Provider/CartProvider.dart';

import 'package:eshop_multivendor/Provider/UserProvider.dart';
import 'package:eshop_multivendor/Screen/Language/languageSettings.dart';
import 'package:eshop_multivendor/Screen/OrderSuccess/Order_Success.dart';
import 'package:eshop_multivendor/widgets/snackbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart';

import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'package:webview_flutter_android/webview_flutter_android.dart';

// Import for iOS features.
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

import '../../widgets/security.dart';

class InstamojoWebview extends StatefulWidget {
  final String? url, from, msg, amt, orderId;

  const InstamojoWebview({
    Key? key,
    this.url,
    this.from,
    this.msg,
    this.amt,
    this.orderId,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return StatePayPalWebview();
  }
}

class StatePayPalWebview extends State<InstamojoWebview> {
  bool isloading = true;
  late final WebViewController _controller;
  String currentStatus = '';
  String transactionId = '';
  List<String> visitedUrls = [];

  DateTime? currentBackPressTime;
  late UserProvider userProvider;

  @override
  void initState() {
    webViewInitiliased();
    super.initState();
  }

  webViewInitiliased() {
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final WebViewController controller =
        WebViewController.fromPlatformCreationParams(params);
    // #enddocregion platform_features

    controller
      ..loadRequest(Uri.parse(widget.url!))
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel('Toaster', onMessageReceived: (message) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message.message)),
        );
      })
      ..setNavigationDelegate(NavigationDelegate(
        onPageFinished: (String url) {
          print('finished******URL*****$url');
          visitedUrls.add(url); // Capture visited URL

          if (url.contains('https://test.instamojo.com/order/status/') ||
              url.contains('https://instamojo.com/order/status/')) {
            print('finish inner url');
            print('currentstatus: $currentStatus****$transactionId');

            if (currentStatus != '' && transactionId != '') {
              print('inner status if');
              if (currentStatus == 'AUTHENTICATION_FAILED' ||
                  currentStatus == 'AUTHORIZATION_FAILED') {
                deleteOrder();
                Timer(const Duration(seconds: 5), () {
                  Navigator.pop(context);
                });
              } else if (currentStatus == 'CHARGED' &&
                  visitedUrls.contains(url)) {
                if (widget.from == 'order') {
                  print('inner');
                  AddTransaction(transactionId, widget.orderId!, SUCCESS,
                      'Order placed successfully', true);
                  userProvider.setCartCount('0');
                  Timer(const Duration(seconds: 5), () {
                    Navigator.pushAndRemoveUntil(
                        context,
                        CupertinoPageRoute(
                            builder: (BuildContext context) =>
                                const OrderSuccess()),
                        ModalRoute.withName('/home'));
                  });
                } else if (widget.from == 'wallet') {
                  Timer(const Duration(seconds: 5), () {
                    Navigator.pop(context);
                  });
                }
              } else if (currentStatus == 'PENDING_VBV') {
                Timer(const Duration(seconds: 5), () {
                  Navigator.pop(context);
                });
              }
            }
            // Redirect to a new screen
          }
          setState(() {
            isloading = false;
          });
        },
        onNavigationRequest: (request) async {
          String responseurl = request.url;

          List<String> testdata = responseurl.split('?');

          for (String data in testdata) {
            if (data.split('=')[0].toLowerCase() == 'order_id') {
              setState(() {
                transactionId = data.split('=')[1];
              });

              break;
            }
          }

          if (responseurl.contains('AUTHENTICATION_FAILED') ||
              responseurl.contains('AUTHORIZATION_FAILED')) {
            if (responseurl.contains('AUTHENTICATION_FAILED')) {
              setState(() {
                currentStatus = 'AUTHENTICATION_FAILED';
              });
            } else {
              setState(() {
                currentStatus = 'AUTHORIZATION_FAILED';
                isloading = false;
              });
            }
          } else if (responseurl.contains('CHARGED')) {
            setState(() {
              currentStatus = 'CHARGED';
            });
          }
          if (responseurl.contains('PENDING_VBV')) {
            setState(() {
              currentStatus = 'PENDING_VBV';
            });
          }

          if (currentStatus != '' && transactionId != '') {}
          return NavigationDecision.navigate;
        },
      ));

    // #docregion platform_features
    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }
    // #enddocregion platform_features

    _controller = controller;
  }

  @override
  Widget build(BuildContext context) {
    userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      //  key: scaffoldKey,
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        titleSpacing: 0,
        leading: Builder(builder: (BuildContext context) {
          return Container(
            margin: const EdgeInsets.all(10),
            child: Card(
              elevation: 0,
              child: InkWell(
                borderRadius: BorderRadius.circular(4),
                onTap: () {
                  DateTime now = DateTime.now();
                  if (currentBackPressTime == null ||
                      now.difference(currentBackPressTime!) >
                          const Duration(seconds: 2)) {
                    currentBackPressTime = now;
                    setSnackbar(
                        "Don't press back while doing payment!\n ${getTranslated(context, 'EXIT_WR')}",
                        context);
                  }
                  if (widget.from == 'order' && widget.orderId != null) {
                    deleteOrder();
                  }
                  Navigator.pop(context);
                },
                child: const Center(
                  child: Icon(
                    Icons.keyboard_arrow_left,
                    color: colors.primary,
                  ),
                ),
              ),
            ),
          );
        }),
        title: Text(
          appName,
          style: TextStyle(
            color: Theme.of(context).colorScheme.fontColor,
          ),
        ),
      ),
      body: PopScope(
        canPop: false,
        onPopInvoked: (didPop) {
          DateTime now = DateTime.now();
          if (currentBackPressTime == null ||
              now.difference(currentBackPressTime!) >
                  const Duration(seconds: 2)) {
            currentBackPressTime = now;
            setSnackbar(
                "${getTranslated(
                  context,
                  "Don't press back while doing payment!",
                )}\n ${getTranslated(
                  context,
                  'EXIT_WR',
                )}",
                context);
          } else {
            if (widget.from == 'order' && widget.orderId != null) {
              deleteOrder();
            }
            if (didPop) {
              return;
            }
            Navigator.pop(context, 'true');
          }
        },
        child: Stack(
          children: <Widget>[
            WebViewWidget(controller: _controller),
            isloading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: colors.primary,
                    ),
                  )
                : const SizedBox(),
          ],
        ),
      ),
    );
  }

  Future<void> deleteOrder() async {
    try {
      var parameter = {
        ORDER_ID: widget.orderId,
      };

      Response response =
          await post(deleteOrderApi, body: parameter, headers: headers).timeout(
        const Duration(
          seconds: timeOut,
        ),
      );
      if (mounted) {
        setState(
          () {
            isloading = false;
          },
        );
      }

      Navigator.of(context).pop();
    } on TimeoutException catch (_) {
      setSnackbar(getTranslated(context, 'somethingMSg'), context);

      setState(
        () {
          isloading = false;
        },
      );
    }
  }

  /* JavascriptChannel _toasterJavascriptChannel(BuildContext context) {
    return JavascriptChannel(
        name: 'Toaster',
        onMessageReceived: (JavascriptMessage message) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message.message)),
          );
        });
  }*/

  Future<void> AddTransaction(String tranId, String orderID, String status,
      String? msg, bool redirect) async {
    try {
      var parameter = {
        // USER_ID: context.read<UserProvider>().userId,
        ORDER_ID: orderID,
        TYPE: context.read<CartProvider>().payMethod,
        TXNID: tranId,
        AMOUNT: context.read<CartProvider>().totalPrice.toString(),
        STATUS: status,
        MSG: msg
      };

      Response response =
          await post(addTransactionApi, body: parameter, headers: headers)
              .timeout(const Duration(seconds: timeOut));

      DateTime now = DateTime.now();
      currentBackPressTime = now;
      var getdata = json.decode(response.body);

      bool error = getdata['error'];
      String? msg1 = getdata['message'];
      if (!error) {
        if (redirect) {
          if (mounted) {
            userProvider.setCartCount('0');

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
            context.read<CartProvider>().prePaidDeliverChargesOfShipRocket =
                0.0;
            context.read<CartProvider>().isLocalDelCharge = null;
            context.read<CartProvider>().isShippingDeliveryChargeApplied =
                false;
            context.read<CartProvider>().shipRocketDeliverableDate = '';
            context.read<CartProvider>().isAddressChange = null;
            context.read<CartProvider>().noteController.clear();
            context.read<CartProvider>().promoC.clear();
            context.read<CartProvider>().promocode = null;
          }
          Routes.navigateToOrderSuccessScreen(context);
        }
      } else {
        setSnackbar(msg1!, context);
      }
    } on TimeoutException catch (_) {
      setSnackbar(getTranslated(context, 'somethingMSg'), context);
    }
  }
}
