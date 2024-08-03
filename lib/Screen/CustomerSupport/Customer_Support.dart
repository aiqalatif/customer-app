import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import '../../Helper/String.dart';
import '../../Provider/customerSupportProvider.dart';
import '../../widgets/ButtonDesing.dart';
import '../../widgets/appBar.dart';
import '../../widgets/desing.dart';
import '../Language/languageSettings.dart';
import '../../widgets/networkAvailablity.dart';
import '../../widgets/simmerEffect.dart';
import '../../widgets/snackbar.dart';
import '../../widgets/validation.dart';
import '../../Helper/Color.dart';
import 'package:flutter/material.dart';
import '../../Helper/Constant.dart';
import '../../Model/Model.dart';
import '../NoInterNetWidget/NoInterNet.dart';
import 'Widget/setEmailWidget.dart';
import 'Widget/setTitleWidget.dart';
import 'Widget/ticketWidget.dart';

class CustomerSupport extends StatefulWidget {
  const CustomerSupport({Key? key}) : super(key: key);

  @override
  _CustomerSupportState createState() => _CustomerSupportState();
}

class _CustomerSupportState extends State<CustomerSupport>
    with TickerProviderStateMixin {
  Animation? buttonSqueezeanimation;
  late AnimationController buttonController;
  List<Model> statusList = [];

  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  bool fabIsVisible = true;
  ScrollController controller = ScrollController();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  setStateNow() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    context.read<CustomerSupportProvider>().offset = 0;
    context.read<CustomerSupportProvider>().ticketList = [];
    context.read<CustomerSupportProvider>().nameController.text = '';
    context.read<CustomerSupportProvider>().emailController.text = '';
    context.read<CustomerSupportProvider>().descController.text = '';
    statusList = [
      Model(id: '3', title: 'Resolved'),
      Model(id: '5', title: 'Reopen')
    ];
    buttonController = AnimationController(
        duration: const Duration(milliseconds: 2000), vsync: this);

    buttonSqueezeanimation = Tween(
      begin: deviceWidth! * 0.7,
      end: 50.0,
    ).animate(
      CurvedAnimation(
        parent: buttonController,
        curve: const Interval(
          0.0,
          0.150,
        ),
      ),
    );
    context.read<CustomerSupportProvider>().show = false;
    controller = ScrollController();
    controller.addListener(
      () {
        setState(
          () {
            fabIsVisible = controller.position.userScrollDirection ==
                ScrollDirection.forward;

            if (controller.offset >= controller.position.maxScrollExtent &&
                !controller.position.outOfRange) {
              context.read<CustomerSupportProvider>().isLoadingmore = true;

              if (context.read<CustomerSupportProvider>().offset <
                  context.read<CustomerSupportProvider>().total) {
                context.read<CustomerSupportProvider>().getTicket(
                      context,
                      setStateNow,
                    );
              }
            }
          },
        );
      },
    );
    context.read<CustomerSupportProvider>().getType(
          context,
          setStateNow,
        );
    context.read<CustomerSupportProvider>().getTicket(
          context,
          setStateNow,
        );
  }

  //TODO: customer support issue is here 
  // @override
  // void dispose() {
  //   super.dispose();
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     if (mounted) {
  //       context.read<CustomerSupportProvider>().nameController.dispose();
  //       context.read<CustomerSupportProvider>().emailController.dispose();
  //       context.read<CustomerSupportProvider>().descController.dispose();
  //     }
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          getSimpleAppBar(getTranslated(context, 'CUSTOMER_SUPPORT'), context),
      floatingActionButton: AnimatedOpacity(
        duration: const Duration(milliseconds: 100),
        opacity: fabIsVisible ? 1 : 0,
        child: FloatingActionButton(
          onPressed: () async {
            setState(
              () {
                context.read<CustomerSupportProvider>().edit = false;
                context.read<CustomerSupportProvider>().show =
                    !context.read<CustomerSupportProvider>().show;
                clearAll();
              },
            );
          },
          heroTag: null,
          child: Container(
            width: 60,
            height: 60,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: colors.primary,
            ),
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [colors.grad1Color, colors.grad2Color],
                  stops: [0, 1],
                ),
              ),
              child: Icon(
                Icons.add,
                color: Theme.of(context).colorScheme.white,
              ),
            ),
          ),
        ),
      ),
      body: isNetworkAvail
          ? context.read<CustomerSupportProvider>().isLoading
              ? const ShimmerEffect()
              : Stack(
                  children: [
                    RefreshIndicator(
                      color: colors.primary,
                      key: _refreshIndicatorKey,
                      onRefresh: _refresh,
                      child: SingleChildScrollView(
                        controller: controller,
                        child: Form(
                          key: _formkey,
                          child: Column(
                            children: [
                              context.read<CustomerSupportProvider>().show
                                  ? Card(
                                      elevation: 0,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 15.0),
                                              child: DropdownButtonFormField(
                                                isExpanded: true,
                                                iconEnabledColor:
                                                    Theme.of(context)
                                                        .colorScheme
                                                        .fontColor,
                                                isDense: true,
                                                hint: SizedBox(
                                                  width: deviceWidth! * 0.6,
                                                  child: Text(
                                                    getTranslated(context,
                                                        'SELECT_TYPE'),
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .titleSmall!
                                                        .copyWith(
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .fontColor,
                                                          fontFamily: 'ubuntu',
                                                          fontWeight:
                                                              FontWeight.normal,
                                                        ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                    softWrap: true,
                                                  ),
                                                ),
                                                decoration: InputDecoration(
                                                  filled: true,
                                                  isDense: true,
                                                  fillColor: Theme.of(context)
                                                      .colorScheme
                                                      .lightWhite,
                                                  contentPadding:
                                                      const EdgeInsets
                                                              .symmetric(
                                                          vertical: 10,
                                                          horizontal: 10),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .fontColor),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            circularBorderRadius10),
                                                  ),
                                                  enabledBorder:
                                                      UnderlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .lightWhite),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            circularBorderRadius10),
                                                  ),
                                                ),
                                                value: context
                                                    .read<
                                                        CustomerSupportProvider>()
                                                    .type,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleSmall!
                                                    .copyWith(
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .fontColor),
                                                onChanged: (String? newValue) {
                                                  if (mounted) {
                                                    setState(
                                                      () {
                                                        context
                                                            .read<
                                                                CustomerSupportProvider>()
                                                            .type = newValue;
                                                      },
                                                    );
                                                  }
                                                },
                                                items: context
                                                    .read<
                                                        CustomerSupportProvider>()
                                                    .typeList
                                                    .map(
                                                  (Model user) {
                                                    return DropdownMenuItem<
                                                        String>(
                                                      value: user.id,
                                                      child: Text(
                                                        user.title!,
                                                        style: const TextStyle(
                                                          fontFamily: 'ubuntu',
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ).toList(),
                                              ),
                                            ),
                                            const Padding(
                                              padding:
                                                  EdgeInsets.only(top: 15.0),
                                              child: SetEmailWidget(),
                                            ),
                                            const Padding(
                                              padding:
                                                  EdgeInsets.only(top: 15.0),
                                              child: SetTitleWidget(),
                                            ),
                                            Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 15.0),
                                                child: setDesc()),
                                            Row(
                                              children: [
                                                context
                                                        .read<
                                                            CustomerSupportProvider>()
                                                        .edit
                                                    ? statusDropDown()
                                                    : const SizedBox(),
                                                const Spacer(),
                                                sendButton(),
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                    )
                                  : const SizedBox(),
                              context
                                      .read<CustomerSupportProvider>()
                                      .ticketList
                                      .isNotEmpty
                                  ? ListView.separated(
                                      separatorBuilder:
                                          (BuildContext context, int index) =>
                                              const Divider(),
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      itemCount: (context
                                                  .read<
                                                      CustomerSupportProvider>()
                                                  .offset <
                                              context
                                                  .read<
                                                      CustomerSupportProvider>()
                                                  .total)
                                          ? context
                                                  .read<
                                                      CustomerSupportProvider>()
                                                  .ticketList
                                                  .length +
                                              1
                                          : context
                                              .read<CustomerSupportProvider>()
                                              .ticketList
                                              .length,
                                      itemBuilder: (context, index) {
                                        return (index ==
                                                    context
                                                        .read<
                                                            CustomerSupportProvider>()
                                                        .ticketList
                                                        .length &&
                                                context
                                                    .read<
                                                        CustomerSupportProvider>()
                                                    .isLoadingmore)
                                            ? const Center(
                                                child:
                                                    CircularProgressIndicator(),
                                              )
                                            : TicketIteamWidget(
                                                index: index,
                                                updateNow: setStateNow,
                                              );
                                      },
                                    )
                                  : SizedBox(
                                      height: deviceHeight! -
                                          kToolbarHeight -
                                          MediaQuery.of(context).padding.top,
                                      child: DesignConfiguration.getNoItem(
                                        context,
                                      ),
                                    )
                            ],
                          ),
                        ),
                      ),
                    ),
                    DesignConfiguration.showCircularProgress(
                      context.read<CustomerSupportProvider>().isProgress,
                      colors.primary,
                    ),
                  ],
                )
          : NoInterNet(
              setStateNoInternate: setStateNoInternate,
              buttonSqueezeanimation: buttonSqueezeanimation,
              buttonController: buttonController,
            ),
    );
  }

  void validateAndSubmit() async {
    if (context.read<CustomerSupportProvider>().edit) {
      if ((context.read<CustomerSupportProvider>().type == null ||
              context.read<CustomerSupportProvider>().status == null) ||
          (context.read<CustomerSupportProvider>().status == null &&
              context.read<CustomerSupportProvider>().type == null)) {
        setSnackbar(getTranslated(context, 'Please Select Type'), context);
      } else if (validateAndSave()) {
        checkNetwork();
      }
    } else {
      if (context.read<CustomerSupportProvider>().type == null) {
        setSnackbar(getTranslated(context, 'Please Select Type'), context);
      } else if (validateAndSave()) {
        checkNetwork();
      }
    }
  }

  Future<void> checkNetwork() async {
    isNetworkAvail = await isNetworkAvailable();
    if (isNetworkAvail) {
      context.read<CustomerSupportProvider>().sendRequest(
            setStateNow,
            context,
          );
    } else {
      Future.delayed(const Duration(seconds: 2)).then(
        (_) async {
          if (mounted) {
            setState(
              () {
                isNetworkAvail = false;
              },
            );
          }
          await buttonController.reverse();
        },
      );
    }
  }

  Future<void> _playAnimation() async {
    try {
      await buttonController.forward();
    } on TickerCanceled {}
  }

  bool validateAndSave() {
    final form = _formkey.currentState!;
    form.save();
    if (form.validate()) {
      return true;
    }
    return false;
  }

  setDesc() {
    return Padding(
      padding: const EdgeInsetsDirectional.only(
        top: 10.0,
      ),
      child: TextFormField(
        focusNode: context.read<CustomerSupportProvider>().descFocus,
        controller: context.read<CustomerSupportProvider>().descController,
        maxLines: null,
        style: TextStyle(
          color: Theme.of(context).colorScheme.fontColor,
          fontWeight: FontWeight.normal,
        ),
        validator: (val) => StringValidation.validateField(
          val!,
          getTranslated(context, 'FIELD_REQUIRED'),
        ),
        onSaved: (String? value) {
          context.read<CustomerSupportProvider>().desc = value;
        },
        onFieldSubmitted: (v) {
          fieldFocusChange(
              context,
              context.read<CustomerSupportProvider>().emailFocus!,
              context.read<CustomerSupportProvider>().nameFocus);
        },
        decoration: InputDecoration(
          hintText: getTranslated(context, 'DESCRIPTION'),
          hintStyle: Theme.of(context).textTheme.titleSmall!.copyWith(
              color: Theme.of(context).colorScheme.fontColor,
              fontWeight: FontWeight.normal),
          filled: true,
          fillColor: Theme.of(context).colorScheme.lightWhite,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          focusedBorder: OutlineInputBorder(
            borderSide:
                BorderSide(color: Theme.of(context).colorScheme.fontColor),
            borderRadius: BorderRadius.circular(circularBorderRadius10),
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide:
                BorderSide(color: Theme.of(context).colorScheme.lightWhite),
            borderRadius: BorderRadius.circular(circularBorderRadius10),
          ),
        ),
      ),
    );
  }

  Future<void> _refresh() async {
    context.read<CustomerSupportProvider>().offset = 0;
    context.read<CustomerSupportProvider>().ticketList = [];
    context.read<CustomerSupportProvider>().getTicket(
          context,
          setStateNow,
        );
    setState(() {});
  }

  Widget sendButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: SimBtn(
        borderRadius: circularBorderRadius5,
        size: 0.4,
        title: getTranslated(context, 'SEND'),
        onBtnSelected: () {
          validateAndSubmit();
        },
      ),
    );
  }

  clearAll() {
    context.read<CustomerSupportProvider>().type = null;
    context.read<CustomerSupportProvider>().email = null;
    context.read<CustomerSupportProvider>().title = null;
    context.read<CustomerSupportProvider>().desc = null;
    FocusScope.of(context).unfocus();
  }

  statusDropDown() {
    return SizedBox(
      width: MediaQuery.of(context).size.width * .4,
      child: DropdownButtonFormField(
        iconEnabledColor: Theme.of(context).colorScheme.fontColor,
        isDense: true,
        hint: Text(
          getTranslated(context, 'SELECT_TYPE'),
          style: Theme.of(context).textTheme.titleSmall!.copyWith(
                color: Theme.of(context).colorScheme.fontColor,
                fontWeight: FontWeight.normal,
                fontFamily: 'ubuntu',
              ),
        ),
        decoration: InputDecoration(
          filled: true,
          isDense: true,
          fillColor: Theme.of(context).colorScheme.lightWhite,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          focusedBorder: OutlineInputBorder(
            borderSide:
                BorderSide(color: Theme.of(context).colorScheme.fontColor),
            borderRadius: BorderRadius.circular(circularBorderRadius10),
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide:
                BorderSide(color: Theme.of(context).colorScheme.lightWhite),
            borderRadius: BorderRadius.circular(circularBorderRadius10),
          ),
        ),
        value: context.read<CustomerSupportProvider>().status,
        style: Theme.of(context)
            .textTheme
            .titleSmall!
            .copyWith(color: Theme.of(context).colorScheme.fontColor),
        onChanged: (String? newValue) {
          if (mounted) {
            setState(
              () {
                context.read<CustomerSupportProvider>().status = newValue;
              },
            );
          }
        },
        items: statusList.map(
          (Model user) {
            return DropdownMenuItem<String>(
              value: user.id,
              child: Text(
                user.title!,
                style: const TextStyle(
                  fontFamily: 'ubuntu',
                ),
              ),
            );
          },
        ).toList(),
      ),
    );
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
          await buttonController.reverse();
          if (mounted) {
            setState(
              () {},
            );
          }
        }
      },
    );
  }
}
