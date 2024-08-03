import 'dart:async';
import 'package:eshop_multivendor/Provider/ManageAddressProvider.dart';
import 'package:eshop_multivendor/Provider/addressProvider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Helper/Color.dart';
import '../../Helper/String.dart';
import '../../Provider/CartProvider.dart';
import '../../widgets/appBar.dart';
import '../../widgets/desing.dart';
import '../Language/languageSettings.dart';
import '../../widgets/networkAvailablity.dart';
import '../../widgets/simmerEffect.dart';
import '../AddAddress/Add_Address.dart';
import '../NoInterNetWidget/NoInterNet.dart';
import 'Widget/RadioItem.dart';

class ManageAddress extends StatefulWidget {
  final bool? home;

  const ManageAddress({Key? key, this.home}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return StateAddress();
  }
}

class StateAddress extends State<ManageAddress> with TickerProviderStateMixin {
  Animation? buttonSqueezeanimation;
  AnimationController? buttonController;
  List<RadioModel> addModel = [];
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  setStateNow() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero).then(
        (value) => context.read<ManageAddrProvider>().getAddress(context).then(
          (value) {
             addAddressModel();
          },
        ),
      );
    // if (widget.home!) {
    //   Future.delayed(Duration.zero).then(
    //     (value) => context.read<ManageAddrProvider>().getAddress(context).then(
    //       (value) {
    //         addAddressModel();
    //       },
    //     ),
    //   );
    // } else {
    //   Future.delayed(Duration.zero).then(
    //     (value) => context.read<ManageAddrProvider>().getAddress(context).then(
    //       (value) {
    //         addAddressModel();
    //       },
    //     ),
    //   );
    // }
    

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

  setStateNoInternate() async {
    _playAnimation();

    Future.delayed(const Duration(seconds: 2)).then(
      (_) async {
        isNetworkAvail = await isNetworkAvailable();
        if (isNetworkAvail) {
          context.read<CartProvider>().addressList.clear();
          addModel.clear();
          if (IS_SHIPROCKET_ON == '0') {
            if (!ISFLAT_DEL) context.read<CartProvider>().deliveryCharge = 0;
          }
          Future.delayed(Duration.zero).then(
            (value) =>
                context.read<ManageAddrProvider>().getAddress(context).then(
              (value) {
                addAddressModel();
              },
            ),
          );
        } else {
          await buttonController!.reverse();
          if (mounted) setState(() {});
        }
      },
    );
  }

  Future<void> _refresh() {
    context.read<CartProvider>().addressList.clear();
    addModel.clear();
    if (IS_SHIPROCKET_ON == '0') {
      if (!ISFLAT_DEL) context.read<CartProvider>().deliveryCharge = 0;
    }
    return Future.delayed(Duration.zero).then(
      (value) => context.read<ManageAddrProvider>().getAddress(context).then(
        (value) {
          addAddressModel();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: getSimpleAppBar(getTranslated(context, 'SHIPP_ADDRESS'), context),
      floatingActionButton: FloatingActionButton(
        backgroundColor: colors.primary,
        onPressed: () async {
          await Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => AddAddress(
                update: false,
                index: context.read<CartProvider>().addressList.length,
                fromProfile: widget.home!,
              ),
            ),
          ).then(
            (value) {
              context.read<CartProvider>().addressList.clear();
              addModel.clear();
              if (!ISFLAT_DEL) context.read<CartProvider>().deliveryCharge = 0;
              return Future.delayed(Duration.zero).then(
                (value) =>
                    context.read<ManageAddrProvider>().getAddress(context).then(
                  (value) {
                    addAddressModel();
                    if (mounted) {
                      if (context.read<CartProvider>().checkoutState != null) {
                        context.read<CartProvider>().checkoutState!(() {});
                      }
                    }
                  },
                ),
              );
            },
          );
          if (mounted) {
            setState(
              () {
                addModel.clear();
                addAddressModel();
              },
            );
          }
        },
        child: Container(
          width: 60,
          height: 60,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [colors.grad1Color, colors.grad2Color],
              stops: [0, 1],
            ),
          ),
          child: const Icon(
            Icons.add,
          ),
        ),
      ),
      backgroundColor: Theme.of(context).colorScheme.lightWhite,
      body: isNetworkAvail
          ? Column(
              children: [
                Expanded(
                  child: Consumer<ManageAddrProvider>(
                    builder: (context, value, child) {
                      if (value.getCurrentStatus ==
                          ManageAddrProviderStatus.isSuccess) {
                        return context.read<CartProvider>().addressList.isEmpty
                            ? Center(
                                child: Text(
                                  getTranslated(context, 'NOADDRESS'),
                                  style: const TextStyle(
                                    fontFamily: 'ubuntu',
                                  ),
                                ),
                              )
                            : Stack(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: RefreshIndicator(
                                      color: colors.primary,
                                      key: _refreshIndicatorKey,
                                      onRefresh: _refresh,
                                      child: ListView.builder(
                                        physics:
                                            const AlwaysScrollableScrollPhysics(),
                                        itemCount: context
                                            .read<CartProvider>()
                                            .addressList
                                            .length,
                                        itemBuilder: (context, index) {
                                          return GestureDetector(
                                            onTap: () {
                                              if (widget.home == true) {
                                                return;
                                              }
                                              if (mounted) {
                                                setState(() {
                                                  if (IS_SHIPROCKET_ON == '0') {
                                                    if (!ISFLAT_DEL) {
                                                      if (context
                                                              .read<
                                                                  CartProvider>()
                                                              .oriPrice <
                                                          double.parse(context
                                                              .read<
                                                                  CartProvider>()
                                                              .addressList[context
                                                                  .read<
                                                                      CartProvider>()
                                                                  .selectedAddress!]
                                                              .freeAmt!)) {
                                                        context
                                                                .read<
                                                                    CartProvider>()
                                                                .deliveryCharge =
                                                            double.parse(context
                                                                .read<
                                                                    CartProvider>()
                                                                .addressList[context
                                                                    .read<
                                                                        CartProvider>()
                                                                    .selectedAddress!]
                                                                .deliveryCharge!);
                                                      } else {
                                                        context
                                                            .read<
                                                                CartProvider>()
                                                            .deliveryCharge = 0;
                                                      }
                                                      context
                                                          .read<CartProvider>()
                                                          .totalPrice = context
                                                              .read<
                                                                  CartProvider>()
                                                              .totalPrice -
                                                          context
                                                              .read<
                                                                  CartProvider>()
                                                              .deliveryCharge;
                                                    }
                                                  } else {
                                                    context
                                                            .read<CartProvider>()
                                                            .totalPrice =
                                                        context
                                                            .read<
                                                                CartProvider>()
                                                            .oriPrice;
                                                  }

                                                  context
                                                      .read<CartProvider>()
                                                      .selectedAddress = index;
                                                  context
                                                          .read<CartProvider>()
                                                          .selAddress =
                                                      context
                                                          .read<CartProvider>()
                                                          .addressList[index]
                                                          .id;
                                                  if (IS_SHIPROCKET_ON == '0') {
                                                    if (!ISFLAT_DEL) {
                                                      if (context
                                                              .read<
                                                                  CartProvider>()
                                                              .totalPrice <
                                                          double.parse(context
                                                              .read<
                                                                  CartProvider>()
                                                              .addressList[context
                                                                  .read<
                                                                      CartProvider>()
                                                                  .selectedAddress!]
                                                              .freeAmt!)) {
                                                        context
                                                                .read<
                                                                    CartProvider>()
                                                                .deliveryCharge =
                                                            double.parse(context
                                                                .read<
                                                                    CartProvider>()
                                                                .addressList[context
                                                                    .read<
                                                                        CartProvider>()
                                                                    .selectedAddress!]
                                                                .deliveryCharge!);
                                                      } else {
                                                        context
                                                            .read<
                                                                CartProvider>()
                                                            .deliveryCharge = 0;
                                                      }

                                                      context
                                                          .read<CartProvider>()
                                                          .totalPrice = context
                                                              .read<
                                                                  CartProvider>()
                                                              .totalPrice +
                                                          context
                                                              .read<
                                                                  CartProvider>()
                                                              .deliveryCharge;
                                                    }
                                                  } else {
                                                    context
                                                            .read<CartProvider>()
                                                            .totalPrice =
                                                        context
                                                            .read<
                                                                CartProvider>()
                                                            .oriPrice;
                                                  }

                                                  for (var element
                                                      in addModel) {
                                                    element.isSelected = false;
                                                  }
                                                  addModel[index].isSelected =
                                                      true;
                                                      Provider.of<AddressProvider>(context, listen:false).setAddresscheck(index);
                                                });
                                                context
                                                    .read<CartProvider>()
                                                    .checkoutState!(() {});
                                              }
                                            },
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 5.0),
                                              child: RadioItem(addModel[index], index: index,),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  DesignConfiguration.showCircularProgress(
                                    context
                                            .read<ManageAddrProvider>()
                                            .getCurrentStatus ==
                                        ManageAddrProviderStatus.inProgress,
                                    colors.primary,
                                  ),
                                ],
                              );
                      }
                      return const ShimmerEffect();
                    },
                  ),
                )
              ],
            )
          : NoInterNet(
              buttonController: buttonController,
              buttonSqueezeanimation: buttonSqueezeanimation,
              setStateNoInternate: setStateNoInternate,
            ),
    );
  }

  void addAddressModel() {
    for (int i = 0; i < context.read<CartProvider>().addressList.length; i++) {
      addModel.add(
        RadioModel(
          isSelected:
              i == context.read<CartProvider>().selectedAddress ? true : false,
          name: context.read<CartProvider>().addressList[i].name!,
          mobile: context.read<CartProvider>().addressList[i].mobile!,
          add:
              '${context.read<CartProvider>().addressList[i].address!}, ${context.read<CartProvider>().addressList[i].area!}, ${context.read<CartProvider>().addressList[i].city!}, ${context.read<CartProvider>().addressList[i].state!}, ${context.read<CartProvider>().addressList[i].country!}, ${context.read<CartProvider>().addressList[i].pincode!}',
          addItem: context.read<CartProvider>().addressList[i],
          show: !widget.home!,
          onSetDefault: () {
            if (mounted) {
              setState(
                () {
                  context
                      .read<ManageAddrProvider>()
                      .changeStatus(ManageAddrProviderStatus.inProgress);
                },
              );
            }
            Future.delayed(Duration.zero).then(
              (value) =>
                  context.read<ManageAddrProvider>().setAsDefault(i, context),
            );
          },
          onDeleteSelected: () {
            if (mounted) {
              setState(
                () {
                  context
                      .read<ManageAddrProvider>()
                      .changeStatus(ManageAddrProviderStatus.inProgress);
                },
              );
            }
            Future.delayed(Duration.zero)
                .then((value) => context
                    .read<ManageAddrProvider>()
                    .deleteAddress(i, context))
                .then(
              (value) {
                addModel.clear();
                addAddressModel();
                if (context.read<CartProvider>().addressList.isEmpty) {
                  if (context.read<CartProvider>().deliveryCharge > 0) {
                    context.read<CartProvider>().totalPrice =
                        context.read<CartProvider>().totalPrice -
                            context.read<CartProvider>().deliveryCharge;
                    context.read<CartProvider>().deliveryCharge = 0;
                    if (mounted) {
                      if (context.read<CartProvider>().checkoutState != null) {
                        context.read<CartProvider>().checkoutState!(() {});
                      }
                    }
                  }
                }
              },
            );
          },
          onEditSelected: () async {
            await Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (context) => AddAddress(
                  update: true,
                  index: i,
                  fromProfile: widget.home!,
                ),
              ),
            ).then(
              (value) {
                context.read<CartProvider>().addressList.clear();
                addModel.clear();
                if (IS_SHIPROCKET_ON == '0') {
                  if (!ISFLAT_DEL) {
                    context.read<CartProvider>().deliveryCharge = 0;
                  }
                }
                return Future.delayed(Duration.zero).then(
                  (value) => context
                      .read<ManageAddrProvider>()
                      .getAddress(context)
                      .then(
                    (value) {
                      addAddressModel();
                    },
                  ),
                );
              },
            );
            if (mounted) {
              setState(
                () {
                  addModel.clear();
                  addAddressModel();
                },
              );
            }
            if (mounted) {
              if (context.read<CartProvider>().checkoutState != null) {
                context.read<CartProvider>().checkoutState!(() {});
              }
            }
          },
        ),
      );
    }
  }
}
