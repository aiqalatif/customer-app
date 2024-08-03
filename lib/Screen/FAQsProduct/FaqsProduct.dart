import 'dart:async';
import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Helper/Constant.dart';
import '../../Helper/String.dart';
import '../../Model/Faqs_Model.dart';
import '../../Model/User.dart';
import '../../Provider/CartProvider.dart';
import '../../Provider/productDetailProvider.dart';
import '../../widgets/appBar.dart';
import '../../widgets/desing.dart';
import '../Language/languageSettings.dart';
import '../../widgets/networkAvailablity.dart';
import '../../widgets/snackbar.dart';
import '../NoInterNetWidget/NoInterNet.dart';
import 'Widget/commandWidgetFaQ.dart';

class FaqsProduct extends StatefulWidget {
  final String? id;

  const FaqsProduct(this.id, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return StateFaqsProduct();
  }
}

class StateFaqsProduct extends State<FaqsProduct>
    with TickerProviderStateMixin {
  bool _isLoading = true;
  bool isLoadingmore = true;
  ScrollController controller = ScrollController();
  List<User> tempList = [];
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final edtFaqs = TextEditingController();
  final GlobalKey<FormState> faqsKey = GlobalKey<FormState>();
  Animation? buttonSqueezeanimation;
  AnimationController? buttonController;
  final TextEditingController _controller1 = TextEditingController();
  FocusNode searchFocusNode = FocusNode();
  bool notificationisnodata = false;
  Timer? _debounce;
  String query = '';

  @override
  void initState() {
    context.read<ProductDetailProvider>().faqsOffset = 0;
    controller = ScrollController(keepScrollOffset: true);
    controller.addListener(_scrollListener);
    _controller1.addListener(
      () {
        if (_controller1.text.isEmpty) {
          setState(
            () {
              query = '';
              context.read<ProductDetailProvider>().faqsOffset = 0;
              isLoadingmore = true;
              getFaqs();
            },
          );
        } else {
          query = _controller1.text;
          context.read<ProductDetailProvider>().faqsOffset = 0;
          notificationisnodata = false;

          if (query.trim().isNotEmpty) {
            if (_debounce?.isActive ?? false) _debounce!.cancel();
            _debounce = Timer(
              const Duration(milliseconds: 500),
              () {
                if (query.trim().isNotEmpty) {
                  isLoadingmore = true;
                  context.read<ProductDetailProvider>().faqsOffset = 0;
                  getFaqs();
                }
              },
            );
          }
        }
        ScaffoldMessenger.of(context).clearSnackBars();
      },
    );
    getFaqs();
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
    edtFaqs.dispose();
    _controller1.dispose();
    controller.removeListener(
      () {},
    );
    super.dispose();
  }

  _scrollListener() {
    if (controller.offset >= controller.position.maxScrollExtent &&
        !controller.position.outOfRange) {
      if (mounted) {
        if (mounted) {
          setState(
            () {
              isLoadingmore = true;
              if (context.read<ProductDetailProvider>().faqsOffset <
                  context.read<ProductDetailProvider>().faqsTotal) {
                getFaqs();
              }
            },
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: getAppBar(
        getTranslated(context, 'Questions and Answers'),
        context,
        update,
      ),
      bottomNavigationBar: BorromBtnWidget(id: widget.id, update: update),
      body: isNetworkAvail
          ? Stack(
              children: <Widget>[
                _showForm(),
                Selector<CartProvider, bool>(
                  builder: (context, data, child) {
                    return DesignConfiguration.showCircularProgress(
                        data, colors.primary);
                  },
                  selector: (_, provider) => provider.isProgress,
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
          Navigator.pushReplacement(
              context,
              CupertinoPageRoute(
                  builder: (BuildContext context) => super.widget));
        } else {
          await buttonController!.reverse();
          if (mounted) {
            setState(
              () {},
            );
          }
        }
      },
    );
  }

  _showForm() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 5, 10, 10),
          child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(circularBorderRadius25)),
            height: 44,
            child: TextField(
              controller: _controller1,
              autofocus: false,
              focusNode: searchFocusNode,
              enabled: true,
              textAlign: TextAlign.left,
              decoration: InputDecoration(
                focusedBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: Theme.of(context).colorScheme.gray),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(circularBorderRadius10),
                  ),
                ),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.transparent),
                  borderRadius: BorderRadius.all(
                    Radius.circular(circularBorderRadius10),
                  ),
                ),
                contentPadding: const EdgeInsets.fromLTRB(15.0, 5.0, 0, 5.0),
                border: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.transparent),
                  borderRadius: BorderRadius.all(
                    Radius.circular(circularBorderRadius10),
                  ),
                ),
                fillColor: Theme.of(context).colorScheme.white,
                filled: true,
                isDense: true,
                hintText: getTranslated(
                    context, 'Have a question? Search for answers'),
                hintStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .fontColor
                          .withOpacity(0.7),
                      fontSize: textFontSize14,
                      fontWeight: FontWeight.w400,
                      fontStyle: FontStyle.normal,
                    ),
                prefixIcon: const Padding(
                    padding: EdgeInsets.all(15.0),
                    child: Icon(
                      Icons.search,
                      color: colors.primary,
                    )),
                suffixIcon: _controller1.text != ''
                    ? IconButton(
                        onPressed: () {
                          FocusScope.of(context).unfocus();

                          _controller1.text = '';
                          context.read<ProductDetailProvider>().faqsOffset = 0;
                          getFaqs();
                        },
                        icon: const Icon(
                          Icons.close,
                          color: colors.primary,
                        ),
                      )
                    : const SizedBox(),
              ),
            ),
          ),
        ),
        _faqs(),
      ],
    );
  }

  update() {
    setState(
      () {},
    );
  }

  Widget _faqs() {
    return _isLoading
        ? Padding(
            padding: EdgeInsetsDirectional.only(top: deviceHeight! / 3),
            child: const CircularProgressIndicator(
              color: colors.primary,
            ),
          )
        : notificationisnodata
            ? Padding(
                padding: EdgeInsetsDirectional.only(top: deviceHeight! / 3),
                child: DesignConfiguration.getNoItem(context),
              )
            : Expanded(
                child: ListView.separated(
                  shrinkWrap: true,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  controller: controller,
                  separatorBuilder: (BuildContext context, int index) =>
                      const Divider(),
                  itemCount: (context.read<ProductDetailProvider>().faqsOffset <
                          context.read<ProductDetailProvider>().faqsTotal)
                      ? context
                              .read<ProductDetailProvider>()
                              .faqsProductList
                              .length +
                          1
                      : context
                          .read<ProductDetailProvider>()
                          .faqsProductList
                          .length,
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    if (index ==
                            context
                                .read<ProductDetailProvider>()
                                .faqsProductList
                                .length &&
                        isLoadingmore) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: colors.primary,
                        ),
                      );
                    } else {
                      if (index <
                          context
                              .read<ProductDetailProvider>()
                              .faqsProductList
                              .length) {
                        return Padding(
                          padding: const EdgeInsets.all(7),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Q: ${context.read<ProductDetailProvider>().faqsProductList[index].question!}',
                                style: TextStyle(
                                  fontFamily: 'ubuntu',
                                  fontWeight: FontWeight.bold,
                                  color:
                                      Theme.of(context).colorScheme.fontColor,
                                  fontSize: textFontSize12,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text(
                                  'A: ${context.read<ProductDetailProvider>().faqsProductList[index].answer!}',
                                  style: TextStyle(
                                    fontFamily: 'ubuntu',
                                    color: Theme.of(context)
                                        .colorScheme
                                        .lightBlack,
                                    fontSize: textFontSize11,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  context
                                      .read<ProductDetailProvider>()
                                      .faqsProductList[index]
                                      .uname!,
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .lightBlack2,
                                    fontSize: textFontSize11,
                                    fontFamily: 'ubuntu',
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 3.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.check_circle,
                                      size: 13,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .lightBlack
                                          .withOpacity(0.8),
                                    ),
                                    Padding(
                                      padding: const EdgeInsetsDirectional.only(
                                          start: 3.0),
                                      child: Text(
                                        context
                                            .read<ProductDetailProvider>()
                                            .faqsProductList[index]
                                            .ansBy!,
                                        style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .lightBlack
                                              .withOpacity(0.5),
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'ubuntu',
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        );
                      } else {
                        return const SizedBox();
                      }
                    }
                  },
                ),
              );
  }

  Future<void> getFaqs() async {
    isNetworkAvail = await isNetworkAvailable();
    if (isNetworkAvail) {
      try {
        if (isLoadingmore) {
          if (mounted) {
            setState(
              () {
                isLoadingmore = false;
                // ignore: invalid_use_of_protected_member
                if (_controller1.hasListeners && _controller1.text.isNotEmpty) {
                  _isLoading = true;
                }
              },
            );
          }
          var parameter = {
            PRODUCT_ID: widget.id,
            LIMIT: perPage.toString(),
            OFFSET: context.read<ProductDetailProvider>().faqsOffset.toString(),
            SEARCH: query,
          };
          apiBaseHelper.postAPICall(getProductFaqsApi, parameter).then(
            (getdata) {
              bool error = getdata['error'];
              String? msg = getdata['message'];

              _isLoading = false;
              if (context.read<ProductDetailProvider>().faqsOffset == 0) {
                notificationisnodata = error;
              }
              if (!error) {
                context.read<ProductDetailProvider>().faqsTotal =
                    int.parse(getdata['total'].toString());

                if (context.read<ProductDetailProvider>().faqsOffset <
                    context.read<ProductDetailProvider>().faqsTotal) {
                  var data = getdata['data'];

                  if (context.read<ProductDetailProvider>().faqsOffset == 0) {
                    context.read<ProductDetailProvider>().faqsProductList = [];
                  }
                  List<FaqsModel> tempList = (data as List)
                      .map((data) => FaqsModel.fromJson(data))
                      .toList();
                  context
                      .read<ProductDetailProvider>()
                      .faqsProductList
                      .addAll(tempList);
                  isLoadingmore = true;
                  context.read<ProductDetailProvider>().faqsOffset =
                      context.read<ProductDetailProvider>().faqsOffset +
                          perPage;
                } else {
                  if (msg != 'FAQs does not exist') {
                    notificationisnodata = true;
                  }
                  isLoadingmore = false;
                }
              } else {
                if (msg != 'FAQs does not exist') {
                  notificationisnodata = true;
                }
                isLoadingmore = false;
                if (mounted) setState(() {});
              }

              setState(
                () {
                  _isLoading = false;
                },
              );
            },
            onError: (error) {
              setSnackbar(error.toString(), context);
            },
          );
        }
      } on TimeoutException catch (_) {
        setSnackbar(getTranslated(context, 'somethingMSg'), context);
        if (mounted) {
          setState(
            () {
              isLoadingmore = false;
            },
          );
        }
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
}
