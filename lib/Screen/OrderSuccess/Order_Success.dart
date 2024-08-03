import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../Helper/Constant.dart';
import '../../Helper/String.dart';
import '../../widgets/appBar.dart';
import '../../widgets/desing.dart';
import '../Dashboard/Dashboard.dart';
import '../Language/languageSettings.dart';

class OrderSuccess extends StatefulWidget {
  const OrderSuccess({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return StateSuccess();
  }
}

class StateSuccess extends State<OrderSuccess> {
  setStateNow() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    deviceHeight = MediaQuery.of(context).size.height;
    deviceWidth = MediaQuery.of(context).size.width;
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) {
          return;
        }
        Dashboard.dashboardScreenKey = GlobalKey();
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) => Dashboard(
                      key: Dashboard.dashboardScreenKey,
                    )),
            (route) => false);
      },
      child: Scaffold(
        appBar: getAppBar(
            getTranslated(context, 'ORDER_PLACED'), context, setStateNow,
            onTap: () {
          Dashboard.dashboardScreenKey = GlobalKey();
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => Dashboard(
                        key: Dashboard.dashboardScreenKey,
                      )),
              (route) => false);
        }),
        body: Center(
          child: SingleChildScrollView(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(25),
                margin: const EdgeInsets.symmetric(vertical: 40),
                child: SvgPicture.asset(
                  DesignConfiguration.setSvgPath('bags'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  getTranslated(context, 'ORD_PLC'),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              Text(
                getTranslated(context, 'ORD_PLC_SUCC'),
                style:
                    TextStyle(color: Theme.of(context).colorScheme.fontColor),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.only(top: 28.0),
                child: CupertinoButton(
                  child: Container(
                    width: deviceWidth! * 0.7,
                    height: 45,
                    alignment: FractionalOffset.center,
                    decoration: const BoxDecoration(
                      color: colors.primary,
                      borderRadius: BorderRadius.all(
                        Radius.circular(circularBorderRadius10),
                      ),
                    ),
                    child: Text(
                      getTranslated(context, 'CONTINUE_SHOPPING'),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                            color: colors.whiteTemp,
                            fontWeight: FontWeight.normal,
                          ),
                    ),
                  ),
                  onPressed: () {
                    Dashboard.dashboardScreenKey = GlobalKey();
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) => Dashboard(
                                  key: Dashboard.dashboardScreenKey,
                                )),
                        (route) => false);
                  },
                ),
              )
            ],
          )),
        ),
      ),
    );
  }
}
