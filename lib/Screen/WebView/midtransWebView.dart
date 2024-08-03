import 'dart:async';
import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:eshop_multivendor/Provider/UserProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../Helper/Constant.dart';
import '../../Helper/routes.dart';
import '../../widgets/desing.dart';
import '../Language/languageSettings.dart';
import '../../widgets/snackbar.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

// Import for iOS features.
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

class MidTrashWebview extends StatefulWidget {
  final String? url, from, msg, amt, orderId;

  const MidTrashWebview(
      {Key? key, this.url, this.from, this.msg, this.amt, this.orderId})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return StateMidTrashWebview();
  }
}

class StateMidTrashWebview extends State<MidTrashWebview> {
  String message = '';
  bool isloading = true;
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  DateTime? currentBackPressTime;
  late UserProvider userProvider;
  late final WebViewController _controller;

  @override
  void initState() {
    // TODO: implement initState
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
      ..setNavigationDelegate(NavigationDelegate(
        onPageFinished: (String url) {
          setState(
            () {
              isloading = false;
            },
          );
        },
        onNavigationRequest: (request) async {
          if (request.url.contains('app/v1/api/midtrans_payment_process')) {
            if (mounted) {
              setState(
                () {
                  isloading = true;
                },
              );
            }
            String responseurl = request.url;

            if (responseurl.contains('Failed') ||
                responseurl.contains('failed')) {
              if (mounted) {
                setState(
                  () {
                    isloading = false;
                  },
                );
              } else if (responseurl.contains('capture') ||
                  responseurl.contains('completed') ||
                  responseurl.toLowerCase().contains('success')) {}
            }
            Navigator.of(context).pop();

            return NavigationDecision.prevent;
          }
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
      key: scaffoldKey,
      appBar: AppBar(
        titleSpacing: 0,
        leading: Builder(
          builder: (BuildContext context) {
            return Container(
              margin: const EdgeInsets.all(10),
              decoration: DesignConfiguration.shadow(),
              child: Card(
                elevation: 0,
                child: InkWell(
                  borderRadius: BorderRadius.circular(circularBorderRadius4),
                  onTap: () {
                    DateTime now = DateTime.now();
                    if (currentBackPressTime == null ||
                        now.difference(currentBackPressTime!) >
                            const Duration(seconds: 2)) {
                      currentBackPressTime = now;
                      setSnackbar(
                        "${getTranslated(context, "Don't press back while doing payment!")}\n ${getTranslated(context, 'EXIT_WR')}",
                        context,
                      );
                    }
                    Routes.pop(context);
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
          },
        ),
        title: Text(
          appName,
          style: TextStyle(
            fontFamily: 'ubuntu',
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
              "${getTranslated(context, "Don't press back while doing payment!")}\n ${getTranslated(context, 'EXIT_WR')}",
              context,
            );
          } else {
            if (didPop) {
              return;
            }
            Navigator.pop(context, 'true');
          }
        },
        child: Stack(
          children: <Widget>[
            WebViewWidget(controller: _controller),
            message.trim().isEmpty
                ? const SizedBox()
                : Center(
                    child: Container(
                      color: colors.primary,
                      padding: const EdgeInsets.all(5),
                      margin: const EdgeInsets.all(5),
                      child: Text(
                        message,
                        style: TextStyle(
                          fontFamily: 'ubuntu',
                          color: Theme.of(context).colorScheme.white,
                        ),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
