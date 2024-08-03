import 'dart:async';
import 'dart:io';

import 'package:eshop_multivendor/Provider/UserProvider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../Helper/Color.dart';
import '../../Helper/Constant.dart';
import '../../Helper/String.dart';
import '../../Helper/routes.dart';
import '../../Model/Section_Model.dart';
import '../../Provider/CartProvider.dart';
import '../../Provider/paymentProvider.dart';
import '../../widgets/ButtonDesing.dart';
import '../../widgets/appBar.dart';
import '../../widgets/desing.dart';
import '../../widgets/networkAvailablity.dart';
import '../../widgets/snackbar.dart';
import '../Language/languageSettings.dart';
import '../NoInterNetWidget/NoInterNet.dart';
import 'Widget/PaymentRadio.dart';

class Payment extends StatefulWidget {
  final Function update;
  final String? msg;

  const Payment(this.update, this.msg, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return StatePayment();
  }
}

class StatePayment extends State<Payment> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Animation? buttonSqueezeanimation;
  AnimationController? buttonController;

  setStateNow() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    context.read<PaymentProvider>().payModel.clear();
    context.read<PaymentProvider>().getdateTime(context, setStateNow);
    context.read<PaymentProvider>().timeSlotList.length = 0;
    context.read<PaymentProvider>().timeModel.clear();

    Future.delayed(
      Duration.zero,
      () {
        context.read<PaymentProvider>().paymentMethodList = [
          Platform.isIOS
              ? getTranslated(context, 'APPLEPAY')
              : getTranslated(context, 'GPAY'),
          getTranslated(context, 'COD_LBL'),
          getTranslated(context, 'PAYPAL_LBL'),
          getTranslated(context, 'PAYUMONEY_LBL'),
          getTranslated(context, 'RAZORPAY_LBL'),
          getTranslated(context, 'PAYSTACK_LBL'),
          getTranslated(context, 'FLUTTERWAVE_LBL'),
          getTranslated(context, 'STRIPE_LBL'),
          getTranslated(context, 'PAYTM_LBL'),
          getTranslated(context, 'BANKTRAN'),
          getTranslated(context, 'MidTrans'),
          getTranslated(context, 'My Fatoorah'),
          getTranslated(context, 'instamojo_lbl'),
          getTranslated(context, 'PHONEPE_LBL'),
        ];
      },
    );
    if (widget.msg != '') {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => setSnackbar(
          widget.msg!,
          context,
        ),
      );
    }
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
          context.read<PaymentProvider>().getdateTime(
                context,
                setStateNow,
              );
        } else {
          await buttonController!.reverse();
          if (mounted) setState(() {});
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    List<SectionModel> tempCartListForTestCondtion =
        context.read<CartProvider>().cartList;
    return Scaffold(
      key: _scaffoldKey,
      appBar: getSimpleAppBar(
          getTranslated(context, 'PAYMENT_METHOD_LBL'), context),
      body: isNetworkAvail
          ? context.read<PaymentProvider>().isLoading
              ? DesignConfiguration.getProgress()
              : Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
                  child: Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Consumer<UserProvider>(
                                builder: (context, userProvider, _) {
                                  return Card(
                                    elevation: 0,
                                    child: userProvider.curBalance != '0' &&
                                            userProvider
                                                .curBalance.isNotEmpty &&
                                            userProvider.curBalance != ''
                                        ? Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8.0),
                                            child: CheckboxListTile(
                                              dense: true,
                                              contentPadding:
                                                  const EdgeInsets.all(0),
                                              value: context
                                                  .read<CartProvider>()
                                                  .isUseWallet,
                                              onChanged: (bool? value) {
                                                if (mounted) {
                                                  setState(
                                                    () {
                                                      context
                                                          .read<CartProvider>()
                                                          .isUseWallet = value;
                                                      print(
                                                          "value wallet****$value******${context.read<CartProvider>().totalPrice}******${userProvider.curBalance}");
                                                      if (value!) {
                                                        if ((context
                                                                .read<
                                                                    CartProvider>()
                                                                .totalPrice) <=
                                                            double.parse(
                                                                userProvider
                                                                    .curBalance)) {
                                                          context
                                                              .read<
                                                                  CartProvider>()
                                                              .remWalBal = (double
                                                                  .parse(userProvider
                                                                      .curBalance) -
                                                              (context
                                                                  .read<
                                                                      CartProvider>()
                                                                  .totalPrice));
                                                          context
                                                                  .read<
                                                                      CartProvider>()
                                                                  .usedBalance =
                                                              (context
                                                                  .read<
                                                                      CartProvider>()
                                                                  .totalPrice);
                                                          context
                                                              .read<
                                                                  CartProvider>()
                                                              .payMethod = 'Wallet';

                                                          context
                                                              .read<
                                                                  CartProvider>()
                                                              .isPayLayShow = false;
                                                        } else {
                                                          context
                                                              .read<
                                                                  CartProvider>()
                                                              .remWalBal = 0;
                                                          context
                                                                  .read<
                                                                      CartProvider>()
                                                                  .usedBalance =
                                                              double.parse(
                                                                  userProvider
                                                                      .curBalance);
                                                          context
                                                              .read<
                                                                  CartProvider>()
                                                              .isPayLayShow = true;
                                                        }

                                                        context
                                                            .read<
                                                                CartProvider>()
                                                            .totalPrice = (context
                                                                .read<
                                                                    CartProvider>()
                                                                .totalPrice) -
                                                            context
                                                                .read<
                                                                    CartProvider>()
                                                                .usedBalance;
                                                      } else {
                                                        context
                                                            .read<
                                                                CartProvider>()
                                                            .totalPrice = (context
                                                                .read<
                                                                    CartProvider>()
                                                                .totalPrice) +
                                                            context
                                                                .read<
                                                                    CartProvider>()
                                                                .usedBalance;
                                                        context
                                                                .read<
                                                                    CartProvider>()
                                                                .remWalBal =
                                                            double.parse(
                                                                userProvider
                                                                    .curBalance);
                                                        context
                                                            .read<
                                                                CartProvider>()
                                                            .payMethod = null;
                                                        context
                                                            .read<
                                                                CartProvider>()
                                                            .selectedMethod = null;
                                                        context
                                                            .read<
                                                                CartProvider>()
                                                            .usedBalance = 0;
                                                        context
                                                            .read<
                                                                CartProvider>()
                                                            .isPayLayShow = true;
                                                      }

                                                      widget.update();
                                                    },
                                                  );
                                                }
                                              },
                                              title: Text(
                                                  getTranslated(
                                                      context, 'USE_WALLET'),
                                                  style: TextStyle(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .fontColor,
                                                      fontSize: 17)
                                                  // Theme.of(context)
                                                  //     .textTheme
                                                  //     .titleMedium,
                                                  ),
                                              subtitle: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 8.0),
                                                child: Text(
                                                  context
                                                          .read<CartProvider>()
                                                          .isUseWallet!
                                                      ? '${getTranslated(context, 'REMAIN_BAL')} : ${DesignConfiguration.getPriceFormat(context, context.read<CartProvider>().remWalBal)}'
                                                      : '${getTranslated(context, 'TOTAL_BAL')} : ${DesignConfiguration.getPriceFormat(context, double.parse(userProvider.curBalance))!}',
                                                  style: TextStyle(
                                                    fontSize: textFontSize15,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .black,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          )
                                        : const SizedBox(),
                                  );
                                },
                              ),
                              if (context
                                      .read<CartProvider>()
                                      .cartList[0]
                                      .productList![0]
                                      .productType !=
                                  'digital_product')
                                context.read<CartProvider>().isTimeSlot! &&
                                        ((context
                                                        .read<CartProvider>()
                                                        .isLocalDelCharge ==
                                                    null ||
                                                context
                                                    .read<CartProvider>()
                                                    .isLocalDelCharge!) &&
                                            IS_LOCAL_ON != '0')
                                    ? Card(
                                        elevation: 0,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Text(
                                                getTranslated(
                                                    context, 'PREFERED_TIME'),
                                                style: TextStyle(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .fontColor,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: textFontSize16,
                                                ),
                                              ),
                                            ),
                                            const Divider(),
                                            Container(
                                              height: 90,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10),
                                              child: ListView.builder(
                                                shrinkWrap: true,
                                                scrollDirection:
                                                    Axis.horizontal,
                                                itemCount: int.parse(context
                                                    .read<PaymentProvider>()
                                                    .allowDay!),
                                                itemBuilder: (context, index) {
                                                  return dateCell(index);
                                                },
                                              ),
                                            ),
                                            const Divider(),
                                            ListView.builder(
                                              shrinkWrap: true,
                                              physics:
                                                  const NeverScrollableScrollPhysics(),
                                              itemCount: context
                                                  .read<PaymentProvider>()
                                                  .timeModel
                                                  .length,
                                              itemBuilder: (context, index) {
                                                return timeSlotItem(index);
                                              },
                                            )
                                          ],
                                        ),
                                      )
                                    : const SizedBox(),
                              context.read<CartProvider>().isPayLayShow! &&
                                      context
                                          .read<PaymentProvider>()
                                          .payModel
                                          .isNotEmpty
                                  ? Card(
                                      elevation: 0,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              getTranslated(
                                                  context, 'SELECT_PAYMENT'),
                                              style: TextStyle(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .fontColor,
                                                fontWeight: FontWeight.bold,
                                                fontSize: textFontSize16,
                                              ),
                                            ),
                                          ),
                                          const Divider(),
                                          ListView.builder(
                                            shrinkWrap: true,
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            itemCount: context
                                                .read<PaymentProvider>()
                                                .paymentMethodList
                                                .length,
                                            itemBuilder: (context, index) {
                                              if (index == 1 &&
                                                  context
                                                      .read<PaymentProvider>()
                                                      .cod &&
                                                  tempCartListForTestCondtion[0]
                                                          .productType !=
                                                      'digital_product') {
                                                return paymentItem(index);
                                              } else if (index == 2 &&
                                                  context
                                                      .read<PaymentProvider>()
                                                      .paypal) {
                                                return paymentItem(index);
                                              } else if (index == 3 &&
                                                  context
                                                      .read<PaymentProvider>()
                                                      .paumoney) {
                                                return paymentItem(index);
                                              } else if (index == 4 &&
                                                  context
                                                      .read<PaymentProvider>()
                                                      .razorpay) {
                                                return paymentItem(index);
                                              } else if (index == 5 &&
                                                  context
                                                      .read<PaymentProvider>()
                                                      .paystack) {
                                                return paymentItem(index);
                                              } else if (index == 6 &&
                                                  context
                                                      .read<PaymentProvider>()
                                                      .flutterwave) {
                                                return paymentItem(index);
                                              } else if (index == 7 &&
                                                  context
                                                      .read<PaymentProvider>()
                                                      .stripe) {
                                                return paymentItem(index);
                                              } else if (index == 8 &&
                                                  context
                                                      .read<PaymentProvider>()
                                                      .paytm) {
                                                return paymentItem(index);
                                              } else if (index == 0 &&
                                                  context
                                                      .read<PaymentProvider>()
                                                      .gpay) {
                                                return paymentItem(index);
                                              } else if (index == 9 &&
                                                  context
                                                      .read<PaymentProvider>()
                                                      .bankTransfer) {
                                                return paymentItem(index);
                                              } else if (index == 10 &&
                                                  context
                                                      .read<PaymentProvider>()
                                                      .midtrans) {
                                                return paymentItem(index);
                                              } else if (index == 11 &&
                                                  context
                                                      .read<PaymentProvider>()
                                                      .myfatoorah) {
                                                return paymentItem(index);
                                              } else if (index == 12 &&
                                                  context
                                                      .read<PaymentProvider>()
                                                      .instamojo) {
                                                return paymentItem(index);
                                              } else if (index == 13 &&
                                                  context
                                                      .read<PaymentProvider>()
                                                      .phonepe) {
                                                return paymentItem(index);
                                              } else {
                                                return const SizedBox();
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                    )
                                  : const SizedBox()
                            ],
                          ),
                        ),
                      ),
                      SimBtn(
                        borderRadius: circularBorderRadius5,
                        size: 0.8,
                        title: getTranslated(context, 'DONE'),
                        onBtnSelected: () {
                          if (context
                                  .read<CartProvider>()
                                  .cartList[0]
                                  .productList![0]
                                  .productType !=
                              'digital_product') {
                            if (context.read<CartProvider>().isTimeSlot ==
                                true) {
                              if ((context
                                              .read<CartProvider>()
                                              .selectedMethod !=
                                          null ||
                                      context
                                          .read<CartProvider>()
                                          .isUseWallet!) &&
                                  (context.read<CartProvider>().selectedTime !=
                                      null ||
                                  context.read<CartProvider>().selectedDate !=
                                      null)) {
                                Routes.pop(context);
                              } else {
                                setSnackbar(
                                    getTranslated(context, 'ENTER_ALL_DETAILS'),
                                    context);
                              }
                            } else {
                              if (context
                                              .read<CartProvider>()
                                              .selectedMethod !=
                                          null ||
                                      context
                                          .read<CartProvider>()
                                          .isUseWallet!) {
                                Routes.pop(context);
                              } else {
                                setSnackbar(
                                    getTranslated(context, 'ENTER_ALL_DETAILS'),
                                    context);
                              }
                            }
                          } else {
                            Routes.pop(context);
                          }
                        },
                      ),
                    ],
                  ),
                )
          : NoInterNet(
              setStateNoInternate: setStateNoInternate,
              buttonSqueezeanimation: buttonSqueezeanimation,
              buttonController: buttonController,
            ),
    );
  }

  dateCell(int index) {
    DateTime today =
        DateTime.parse(context.read<PaymentProvider>().startingDate!);
    return InkWell(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(circularBorderRadius10),
          gradient: context.read<CartProvider>().selectedDate == index
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [colors.grad1Color, colors.grad2Color],
                  stops: [0, 1],
                )
              : null,
        ),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              DateFormat('EEE').format(
                today.add(
                  Duration(
                    days: index,
                  ),
                ),
              ),
              style: TextStyle(
                color: context.read<CartProvider>().selectedDate == index
                    ? Theme.of(context).colorScheme.white
                    : Theme.of(context).colorScheme.lightBlack2,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: Text(
                DateFormat('dd').format(
                  today.add(
                    Duration(days: index),
                  ),
                ),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: context.read<CartProvider>().selectedDate == index
                      ? Theme.of(context).colorScheme.white
                      : Theme.of(context).colorScheme.lightBlack2,
                ),
              ),
            ),
            Text(
              DateFormat('MMM').format(
                today.add(
                  Duration(
                    days: index,
                  ),
                ),
              ),
              style: TextStyle(
                color: context.read<CartProvider>().selectedDate == index
                    ? Theme.of(context).colorScheme.white
                    : Theme.of(context).colorScheme.lightBlack2,
              ),
            ),
          ],
        ),
      ),
      onTap: () {
        DateTime date = today.add(Duration(days: index));

        if (mounted) context.read<CartProvider>().selectedDate = index;
        context.read<CartProvider>().selectedTime = null;
        context.read<CartProvider>().selTime = null;
        context.read<CartProvider>().selDate =
            DateFormat('yyyy-MM-dd').format(date);
        context.read<PaymentProvider>().timeModel.clear();
        DateTime cur = DateTime.now();
        DateTime tdDate = DateTime(cur.year, cur.month, cur.day);
        if (date == tdDate) {
          if (context.read<PaymentProvider>().timeSlotList.isNotEmpty) {
            for (int i = 0;
                i < context.read<PaymentProvider>().timeSlotList.length;
                i++) {
              DateTime cur = DateTime.now();
              String time =
                  context.read<PaymentProvider>().timeSlotList[i].lastTime!;
              DateTime last = DateTime(
                cur.year,
                cur.month,
                cur.day,
                int.parse(time.split(':')[0]),
                int.parse(time.split(':')[1]),
                int.parse(time.split(':')[2]),
              );

              if (cur.isBefore(last)) {
                context.read<PaymentProvider>().timeModel.add(
                      RadioModel(
                        isSelected:
                            i == context.read<CartProvider>().selectedTime
                                ? true
                                : false,
                        name: context
                            .read<PaymentProvider>()
                            .timeSlotList[i]
                            .name,
                        img: '',
                      ),
                    );
              }
            }
          }
        } else {
          if (context.read<PaymentProvider>().timeSlotList.isNotEmpty) {
            for (int i = 0;
                i < context.read<PaymentProvider>().timeSlotList.length;
                i++) {
              context.read<PaymentProvider>().timeModel.add(
                    RadioModel(
                      isSelected: i == context.read<CartProvider>().selectedTime
                          ? true
                          : false,
                      name:
                          context.read<PaymentProvider>().timeSlotList[i].name,
                      img: '',
                    ),
                  );
            }
          }
        }
        setState(() {});
        if (mounted) {
          if (context.read<CartProvider>().checkoutState != null) {
            context.read<CartProvider>().checkoutState!(() {});
          }
        }
      },
    );
  }

  Widget timeSlotItem(int index) {
    return InkWell(
      onTap: () {
        if (mounted) {
          setState(
            () {
              context.read<CartProvider>().selectedTime = index;
              context.read<CartProvider>().selTime = context
                  .read<PaymentProvider>()
                  .timeModel[context.read<CartProvider>().selectedTime!]
                  .name;
              for (var element in context.read<PaymentProvider>().timeModel) {
                element.isSelected = false;
              }
              context.read<PaymentProvider>().timeModel[index].isSelected =
                  true;
            },
          );
          if (mounted) {
            if (context.read<CartProvider>().checkoutState != null) {
              context.read<CartProvider>().checkoutState!(() {});
            }
          }
        }
      },
      child: RadioItem(context.read<PaymentProvider>().timeModel[index]),
    );
  }

  Widget paymentItem(int index) {
    return InkWell(
      onTap: () {
        if (mounted) {
          setState(
            () {
              print(
                  "IS_SHIPROCKET_ON****$IS_SHIPROCKET_ON*****${context.read<CartProvider>().prePaidDeliverChargesOfShipRocket}");
              if (IS_SHIPROCKET_ON == '1') {
                context.read<CartProvider>().isShippingDeliveryChargeApplied =
                    false;
                if (context.read<CartProvider>().isUseWallet == true) {
                  context.read<CartProvider>().totalPrice =
                      context.read<CartProvider>().totalPrice +
                          (context.read<CartProvider>().usedBalance -
                              context.read<CartProvider>().deliveryCharge);
                  context.read<CartProvider>().isUseWallet = false;
                  context.read<CartProvider>().usedBalance = 0;
                }

                if (index == 1 &&
                    context.read<PaymentProvider>().cod &&
                    context.read<CartProvider>().codDeliverChargesOfShipRocket >
                        0) {
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
                } else if (context
                        .read<CartProvider>()
                        .prePaidDeliverChargesOfShipRocket >
                    0) {
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
                } else {
                  if (context.read<CartProvider>().isPromoValid!) {
                    context.read<CartProvider>().totalPrice =
                        (context.read<CartProvider>().deliveryCharge +
                                context.read<CartProvider>().oriPrice) -
                            context.read<CartProvider>().promoAmt;
                  } else {
                    context.read<CartProvider>().totalPrice =
                        context.read<CartProvider>().deliveryCharge +
                            context.read<CartProvider>().oriPrice;
                  }
                }
              }
              context.read<CartProvider>().selectedMethod = index;
              context.read<CartProvider>().payMethod =
                  context.read<PaymentProvider>().paymentMethodList[
                      context.read<CartProvider>().selectedMethod!];

              for (var element in context.read<PaymentProvider>().payModel) {
                element.isSelected = false;
              }
              context.read<PaymentProvider>().payModel[index].isSelected = true;
              if (mounted) {
                if (context.read<CartProvider>().checkoutState != null) {
                  context.read<CartProvider>().checkoutState!(() {});
                }
              }
            },
          );
        }
      },
      child: RadioItem(
        context.read<PaymentProvider>().payModel[index],
      ),
    );
  }
}
