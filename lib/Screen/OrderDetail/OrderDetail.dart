import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'package:eshop_multivendor/Model/Order_Model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import '../../Helper/Color.dart';
import '../../Helper/String.dart';
import '../../Provider/Order/UpdateOrderProvider.dart';
import '../../widgets/appBar.dart';
import '../../widgets/desing.dart';
import '../Language/languageSettings.dart';
import '../../widgets/networkAvailablity.dart';
import '../NoInterNetWidget/NoInterNet.dart';
import 'Widget/OrderSubDetails.dart';
import 'Widget/SingleProduct.dart';
import 'Widget/SubHeadingTabBar.dart';

class OrderDetail extends StatefulWidget {
  final OrderModel? model;

  const OrderDetail({Key? key, this.model}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return StateOrder();
  }
}

class StateOrder extends State<OrderDetail>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  Future<List<Directory>?>? _externalStorageDirectories;

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      context.read<UpdateOrdProvider>().externalStorageDirectories =
          getExternalStorageDirectories(type: StorageDirectory.downloads);
      _externalStorageDirectories =
          getExternalStorageDirectories(type: StorageDirectory.documents);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UpdateOrdProvider>().files.clear();
      context.read<UpdateOrdProvider>().reviewPhotos.clear();
      context.read<UpdateOrdProvider>().buttonController = AnimationController(
          duration: const Duration(milliseconds: 2000), vsync: this);
      context.read<UpdateOrdProvider>().buttonSqueezeanimation = Tween(
        begin: deviceWidth! * 0.7,
        end: 50.0,
      ).animate(
        CurvedAnimation(
          parent: context.read<UpdateOrdProvider>().buttonController!,
          curve: const Interval(
            0.0,
            0.150,
          ),
        ),
      );

      context.read<UpdateOrdProvider>().changeStatus(UpdateOrdStatus.initial);
    });
    context.read<UpdateOrdProvider>().tabController =
        TabController(length: 6, vsync: this, initialIndex: 0);

    context.read<UpdateOrdProvider>().tabController.addListener(
      () {
        setState(() {});
      },
    );
    FlutterDownloader.registerCallback(downloadCallback);
  }

  static void downloadCallback(
    String id,
    int status,
    int progress,
  ) {
    final SendPort send =
        IsolateNameServer.lookupPortByName('downloader_send_port')!;
    send.send([id, status, progress]);
  }

  setStateNow() {
    setState(() {});
  }

  @override
  void dispose() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<UpdateOrdProvider>().buttonController!.dispose();
        context.read<UpdateOrdProvider>().commentTextController.dispose();
        context.read<UpdateOrdProvider>().tabController.dispose();
        context.read<UpdateOrdProvider>().controller.dispose();
        context.read<UpdateOrdProvider>().buttonController!.dispose();
      }
    });
    super.dispose();
  }

  Future<void> _playAnimation() async {
    try {
      await context.read<UpdateOrdProvider>().buttonController!.forward();
    } on TickerCanceled {}
  }

  setStateNoInternate() async {
    _playAnimation();

    Future.delayed(const Duration(seconds: 2)).then(
      (_) async {
        isNetworkAvail = await isNetworkAvailable();
        if (isNetworkAvail) {
          Navigator.pushReplacement(
              context,
              CupertinoPageRoute(
                  builder: (BuildContext context) => super.widget));
        } else {
          await context.read<UpdateOrdProvider>().buttonController!.reverse();
          if (mounted) setState(() {});
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    deviceHeight = MediaQuery.of(context).size.height;
    deviceWidth = MediaQuery.of(context).size.width;

    var model = widget.model!;
    String? pDate, prDate, sDate, dDate, cDate, rDate;

    if (model.listStatus.contains(PLACED)) {
      pDate = model.listDate![model.listStatus.indexOf(PLACED)];

      if (pDate != null) {
        List d = pDate.split(' ');
        pDate = d[0] + '\n' + d[1];
      }
    }
    if (model.listStatus.contains(PROCESSED)) {
      prDate = model.listDate![model.listStatus.indexOf(PROCESSED)];
      if (prDate != null) {
        List d = prDate.split(' ');
        prDate = d[0] + '\n' + d[1];
      }
    }
    if (model.listStatus.contains(SHIPED)) {
      sDate = model.listDate![model.listStatus.indexOf(SHIPED)];
      if (sDate != null) {
        List d = sDate.split(' ');
        sDate = d[0] + '\n' + d[1];
      }
    }
    if (model.listStatus.contains(DELIVERD)) {
      dDate = model.listDate![model.listStatus.indexOf(DELIVERD)];
      if (dDate != null) {
        List d = dDate.split(' ');
        dDate = d[0] + '\n' + d[1];
      }
    }
    if (model.listStatus.contains(CANCLED)) {
      cDate = model.listDate![model.listStatus.indexOf(CANCLED)];
      if (cDate != null) {
        List d = cDate.split(' ');
        cDate = d[0] + '\n' + d[1];
      }
    }
    if (model.listStatus.contains(RETURNED)) {
      rDate = model.listDate![model.listStatus.indexOf(RETURNED)];
      if (rDate != null) {
        List d = rDate.split(' ');
        rDate = d[0] + '\n' + d[1];
      }
    }

    return PopScope(
      canPop: context.read<UpdateOrdProvider>().tabController.index == 0,
      onPopInvoked: (didPop) {
        if (context.read<UpdateOrdProvider>().tabController.index != 0) {
          context.read<UpdateOrdProvider>().tabController.animateTo(0);
        }
      },
      child: Scaffold(
          appBar:
              getSimpleAppBar(getTranslated(context, 'ORDER_DETAIL'), context),
          body: Consumer<UpdateOrdProvider>(
              builder: (context, updateOrdProvider, _) {
            return isNetworkAvail
                ? Stack(
                    children: [
                      Column(
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: GetSubHeadingsTabBar(),
                          ),
                          Expanded(
                            child: TabBarView(
                              controller: updateOrdProvider.tabController,
                              children: [
                                GetOrderDetails(
                                  model: model,
                                  controller: updateOrdProvider.controller,
                                  externalStorageDirectories:
                                      _externalStorageDirectories,
                                  updateNow: setStateNow,
                                ),
                                SingleChildScrollView(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                    child: GetSingleProduct(
                                      model: model,
                                      activeStatus: PROCESSED,
                                      id: widget.model!.id!,
                                      updateNow: setStateNow,
                                    ),
                                  ),
                                ),
                                SingleChildScrollView(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                    child: GetSingleProduct(
                                      model: model,
                                      activeStatus: SHIPED,
                                      id: widget.model!.id!,
                                      updateNow: setStateNow,
                                    ),
                                  ),
                                ),
                                SingleChildScrollView(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                    child: GetSingleProduct(
                                      model: model,
                                      activeStatus: DELIVERD,
                                      id: widget.model!.id!,
                                      updateNow: setStateNow,
                                    ),
                                  ),
                                ),
                                SingleChildScrollView(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                    child: GetSingleProduct(
                                      model: model,
                                      activeStatus: CANCLED,
                                      id: widget.model!.id!,
                                      updateNow: setStateNow,
                                    ),
                                  ),
                                ),
                                SingleChildScrollView(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                    child: GetSingleProduct(
                                      model: model,
                                      activeStatus: RETURNED,
                                      id: widget.model!.id!,
                                      updateNow: setStateNow,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (updateOrdProvider.getCurrentStatus ==
                          UpdateOrdStatus.inProgress)
                        DesignConfiguration.showCircularProgress(
                            true, colors.primary),
                    ],
                  )
                : NoInterNet(
                    buttonController: updateOrdProvider.buttonController,
                    buttonSqueezeanimation:
                        updateOrdProvider.buttonSqueezeanimation,
                    setStateNoInternate: setStateNoInternate,
                  );
          })),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
