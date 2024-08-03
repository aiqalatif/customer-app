import 'dart:async';
import 'package:eshop_multivendor/Provider/systemProvider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../Helper/String.dart';
import '../../widgets/appBar.dart';
import '../Language/languageSettings.dart';
import '../../widgets/networkAvailablity.dart';

class PrivacyPolicy extends StatefulWidget {
  final String? title;

  const PrivacyPolicy({Key? key, this.title}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return StatePrivacy();
  }
}

class StatePrivacy extends State<PrivacyPolicy> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Animation? buttonSqueezeanimation;
  AnimationController? buttonController;

  @override
  void initState() {
    getSystemPolicy();

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
    super.initState();
  }

  @override
  void dispose() {
    buttonController!.dispose();
    super.dispose();
  }

  Future<void> _playAnimation() async {
    try {
      await buttonController!.forward();
    } on TickerCanceled {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: getSimpleAppBar(widget.title!, context),
      body: Consumer<SystemProvider>(builder: (context, value, child) {
        if (value.getCurrentStatus == SystemProviderPolicyStatus.isSuccsess) {
          if (value.policy.isNotEmpty) {
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: HtmlWidget(
                  
                  value.policy,
                  onErrorBuilder: (context, element, error) =>
                      Text('$element error: $error'),
                  onLoadingBuilder: (context, element, loadingProgress) =>
                      const Center(child: CircularProgressIndicator()),
                  onTapUrl: (url) {
                    launchUrl(Uri.parse(url));
                    return true;
                  },
                ),
              ),
            );
          } else {
            Center(
              child: Text(
                getTranslated(context, 'No Data Found'),
              ),
            );
          }
        } else if (value.getCurrentStatus ==
            SystemProviderPolicyStatus.isFailure) {
          return Center(
            child: Text('Something went wrong:- ${value.errorMessage}'),
          );
        }
        return const Center(
          child: CircularProgressIndicator(),
        );
      }),
    );
  }

  Future<void> getSystemPolicy() async {
    isNetworkAvail = await isNetworkAvailable();
    if (isNetworkAvail) {
      String type = '';
      if (widget.title == getTranslated(context, 'PRIVACY')) {
        type = PRIVACY_POLLICY;
      } else if (widget.title == getTranslated(context, 'TERM')) {
        type = TERM_COND;
      } else if (widget.title == getTranslated(context, 'ABOUT_LBL')) {
        type = ABOUT_US;
      } else if (widget.title == getTranslated(context, 'CONTACT_LBL')) {
        type = CONTACT_US;
      } else if (widget.title ==
          getTranslated(context, 'SHIPPING_POLICY_LBL')) {
        type = shippingPolicy;
      } else if (widget.title == getTranslated(context, 'RETURN_POLICY_LBL')) {
        type = returnPolicy;
      }

      await Future.delayed(Duration.zero);
      await context.read<SystemProvider>().getSystemPolicies(type);
    }
  }
}
