import 'dart:math';
import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:eshop_multivendor/Provider/SettingProvider.dart';
import 'package:eshop_multivendor/Provider/Theme.dart';
import 'package:eshop_multivendor/Provider/UserProvider.dart';
import 'package:eshop_multivendor/widgets/desing.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import '../../Helper/Constant.dart';
import '../../Helper/String.dart';
import '../../widgets/security.dart';
import '../../widgets/snackbar.dart';
import '../SQLiteData/SqliteData.dart';
import '../../Model/Section_Model.dart';
import '../../Provider/ProductProvider.dart';
import '../../Provider/Search/SearchProvider.dart';
import '../../Provider/homePageProvider.dart';
import '../Language/languageSettings.dart';
import '../../widgets/networkAvailablity.dart';
import '../NoInterNetWidget/NoInterNet.dart';
import '../Product Detail/productDetail.dart';
import '../ProductList&SectionView/ProductList.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class Search extends StatefulWidget {
  const Search({Key? key}) : super(key: key);

  @override
  _SearchState createState() => _SearchState();
}

bool buildResult = false;

class _SearchState extends State<Search> with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int pos = 0;
  bool _isProgress = false;

   List<TextEditingController> _controllerList = [];
  Animation? buttonSqueezeanimation;
  AnimationController? buttonController;

  int sellerListOffset = 0;
  ScrollController? notificationcontroller;
  // ScrollController? sellerListController;

  late AnimationController _animationController;
  Timer? _debounce;

  bool _hasSpeech = false;
  double level = 0.0;
  double minSoundLevel = 50000;
  double maxSoundLevel = -50000;

  String lastStatus = '';
  String _currentLocaleId = '';
  String lastWords = '';
  final SpeechToText speech = SpeechToText();
  late StateSetter setStater;
  ChoiceChip? tagChip;
  late UserProvider userProvider;
  var db = DatabaseHelper();
  List<Product> sellerList = [];
  List<String> oldEntriedForFutureBuilderOfHistory = [];
  int totalSelletCount = 0;

  @override
  void initState() {
    super.initState();
    context.read<SearchProvider>().notificationisloadmore = true;
    context.read<SearchProvider>().notificationisgettingdata = false;
    context.read<SearchProvider>().notificationisnodata = false;
    context.read<SearchProvider>().notificationoffset = 0;
    context.read<SearchProvider>().productList.clear();
    _controllerList = [];
    notificationcontroller = ScrollController(keepScrollOffset: true);
    notificationcontroller!.addListener(_transactionscrollListener);
    // sellerListController = ScrollController(keepScrollOffset: true);
    // sellerListController!.addListener(_sellerListController);

    _controller.addListener(
      () {
        if (_controller.text.isEmpty) {
          if (mounted) {
            if (context
                .read<SearchProvider>()
                .query
                .toString()
                .trim()
                .isNotEmpty) {
              setState(() {
                context.read<SearchProvider>().query = '';
              });
            }
          }
        } else {
          setState(() {
            context.read<SearchProvider>().query = _controller.text;
          });
          context.read<SearchProvider>().notificationoffset = 0;
          context.read<SearchProvider>().notificationisnodata = false;
          buildResult = false;
          if (context.read<SearchProvider>().query.trim().isNotEmpty) {
            if (_debounce?.isActive ?? false) _debounce!.cancel();
            _debounce = Timer(
              const Duration(milliseconds: 500),
              () {
                if (context.read<SearchProvider>().query.trim().isNotEmpty) {
                  context.read<SearchProvider>().notificationisloadmore = true;
                  context.read<SearchProvider>().notificationoffset = 0;
                  getProduct();
                }
              },
            );
          }
        }
        ScaffoldMessenger.of(context).clearSnackBars();
      },
    );

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

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

    // getSeller();
  }

  _transactionscrollListener() {
    if (notificationcontroller!.offset >=
            notificationcontroller!.position.maxScrollExtent &&
        !notificationcontroller!.position.outOfRange) {
      if (mounted) {
        setState(() {
          getProduct();
        });
      }
    }
  }

  // _sellerListController() {
  //   if (sellerListController!.offset >=
  //           sellerListController!.position.maxScrollExtent &&
  //       !sellerListController!.position.outOfRange) {
  //     if (mounted) {
  //       if (sellerListOffset < totalSelletCount) {
  //         setState(
  //           () {
  //             getSeller();
  //           },
  //         );
  //       }
  //     }
  //   }
  // }

  @override
  void dispose() {
    buttonController!.dispose();
    notificationcontroller!.dispose();
    // sellerListController!.dispose();

    _controller.dispose();
    for (int i = 0; i < _controllerList.length; i++) {
      _controllerList[i].dispose();
    }
    _animationController.dispose();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
      }
    });
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
          Navigator.pushReplacement(
              context,
              CupertinoPageRoute(
                  builder: (BuildContext context) => super.widget));
        } else {
          await buttonController!.reverse();
          if (mounted) setState(() {});
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.read<HomePageProvider>().micClick) {
        lastWords = '';
        if (!_hasSpeech) {
          initSpeechState(1);
        } else {
          showSpeechDialog(1);
        }
      }
    });

    userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsetsDirectional.only(end: 4.0),
          child: IconButton(
            icon:
                 Icon(Icons.arrow_back_ios_rounded, color: Theme.of(context).colorScheme.fontColor,),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.white,
        title: TextField(
          controller: _controller,
          //autofocus: true,
          style: TextStyle(
            color: Theme.of(context).colorScheme.fontColor,
            fontWeight: FontWeight.normal,
          ),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.fromLTRB(0, 15.0, 0, 15.0),
            hintText: getTranslated(context, 'SEARCH_LBL'),
            hintStyle: TextStyle(color: colors.primary.withOpacity(0.5)),
            enabledBorder: UnderlineInputBorder(
              borderSide:
                  BorderSide(color: Theme.of(context).colorScheme.white),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide:
                  BorderSide(color: Theme.of(context).colorScheme.white),
            ),
          ),
        ),
        titleSpacing: 0,
        actions: [
          _controller.text != ''
              ? IconButton(
                  onPressed: () {
                    _controller.text = '';
                  },
                  icon: const Icon(
                    Icons.close,
                    color: colors.primary,
                  ),
                )
              : GestureDetector(
                  onTap: () async {
                    lastWords = '';
                    if (!_hasSpeech) {
                      initSpeechState(0);
                    } else {
                      showSpeechDialog(0);
                    }
                  },
                  child: Selector<ThemeNotifier, ThemeMode>(
                    selector: (_, themeProvider) =>
                        themeProvider.getThemeMode(),
                    builder: (context, data, child) {
                      return Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: (data == ThemeMode.system &&
                                    MediaQuery.of(context).platformBrightness ==
                                        Brightness.light) ||
                                data == ThemeMode.light
                            ? SvgPicture.asset(
                                DesignConfiguration.setSvgPath('voice_search'),
                                height: 25,
                                width: 25,
                              )
                            : SvgPicture.asset(
                                DesignConfiguration.setSvgPath(
                                    'voice_search_white'),
                                height: 25,
                                width: 25,
                              ),
                      );
                    },
                  ),
                ),
        ],
      ),
      body: isNetworkAvail
          ? Stack(
              children: <Widget>[
                _showContentOfProducts(),
                Center(
                  child: DesignConfiguration.showCircularProgress(
                    _isProgress,
                    colors.primary,
                  ),
                ),
              ],
            )
          : NoInterNet(
              buttonController: buttonController,
              buttonSqueezeanimation: buttonSqueezeanimation,
              setStateNoInternate: setStateNoInternate,
            ),
    );
  }

  Widget listItem(int index) {
    Product model = context.read<SearchProvider>().productList[index];

    if (_controllerList.length < index + 1) {
      _controllerList.add(TextEditingController());
    }

    _controllerList[index].text =
        model.prVarientList![model.selVarient!].cartCount!;

    double price =
        double.parse(model.prVarientList![model.selVarient!].disPrice!);
    if (price == 0) {
      price = double.parse(model.prVarientList![model.selVarient!].price!);
    }

    List att = [], val = [];
    if (model.prVarientList![model.selVarient!].attr_name != null) {
      att = model.prVarientList![model.selVarient!].attr_name!.split(',');
      val = model.prVarientList![model.selVarient!].varient_value!.split(',');
    }

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: InkWell(
          splashColor: colors.primary.withOpacity(0.2),
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
            Product model = context.read<SearchProvider>().productList[index];
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (_, __, ___) => ProductDetail(
                  model: model,
                  secPos: 0,
                  index: index,
                  list: true,
                ),
              ),
            );
          },
          child: Stack(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Hero(
                    tag: '$heroTagUniqueString$index${model.id}',
                    child: ClipRRect(
                      borderRadius:
                          BorderRadius.circular(circularBorderRadius7),
                      child: DesignConfiguration.getCacheNotworkImage(
                        imageurlString: context
                            .read<SearchProvider>()
                            .productList[index]
                            .image!,
                        boxFit: extendImg ? BoxFit.cover : BoxFit.contain,
                        context: context,
                        heightvalue: 80,
                        widthvalue: 80,
                        placeHolderSize: 80,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              model.name!,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall!
                                  .copyWith(
                                    color:
                                        Theme.of(context).colorScheme.fontColor,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Row(
                              children: <Widget>[
                                Text(
                                    ' ${DesignConfiguration.getPriceFormat(context, price)!}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium),
                                Text(
                                  double.parse(model
                                              .prVarientList![model.selVarient!]
                                              .disPrice!) !=
                                          0
                                      ? ' ${DesignConfiguration.getPriceFormat(context, double.parse(model.prVarientList![model.selVarient!].price!))!}'
                                      : '',
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelSmall!
                                      .copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .lightBlack,
                                        decoration: TextDecoration.lineThrough,
                                        decorationColor: colors.darkColor3,
                                        decorationStyle:
                                            TextDecorationStyle.solid,
                                        decorationThickness: 2,
                                        letterSpacing: 0,
                                      ),
                                ),
                              ],
                            ),
                            model.prVarientList![model.selVarient!].attr_name !=
                                        null &&
                                    model.prVarientList![model.selVarient!]
                                        .attr_name!.isNotEmpty
                                ? ListView.builder(
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    itemCount: att.length,
                                    itemBuilder: (context, index) {
                                      return Row(
                                        children: [
                                          Flexible(
                                            child: Text(
                                              att[index].trim() + ':',
                                              overflow: TextOverflow.ellipsis,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleSmall!
                                                  .copyWith(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .lightBlack),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsetsDirectional
                                                .only(start: 5.0),
                                            child: Text(
                                              val[index],
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleSmall!
                                                  .copyWith(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .lightBlack,
                                                      fontWeight:
                                                          FontWeight.bold),
                                            ),
                                          )
                                        ],
                                      );
                                    },
                                  )
                                : const SizedBox(),
                            Row(
                              children: [
                                model.availability == '0'
                                    ? const SizedBox()
                                    : cartBtnList
                                        ? Row(
                                            children: <Widget>[
                                              Row(
                                                children: <Widget>[
                                                  GestureDetector(
                                                    child: Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              2),
                                                      margin:
                                                          const EdgeInsetsDirectional
                                                              .only(end: 8),
                                                      decoration: BoxDecoration(
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .lightWhite,
                                                        borderRadius:
                                                            const BorderRadius
                                                                .all(
                                                          Radius.circular(
                                                              circularBorderRadius3),
                                                        ),
                                                      ),
                                                      child: Icon(
                                                        Icons.remove,
                                                        size: 14,
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .fontColor,
                                                      ),
                                                    ),
                                                    onTap: () {
                                                      if (_isProgress ==
                                                              false &&
                                                          (int.parse(context
                                                                  .read<
                                                                      SearchProvider>()
                                                                  .productList[
                                                                      index]
                                                                  .prVarientList![
                                                                      model
                                                                          .selVarient!]
                                                                  .cartCount!)) >
                                                              0) {
                                                        removeFromCart(index);
                                                      }
                                                    },
                                                  ),
                                                  SizedBox(
                                                    width: 40,
                                                    height: 20,
                                                    child: Stack(
                                                      children: [
                                                        TextField(
                                                          textAlign:
                                                              TextAlign.center,
                                                          readOnly: true,
                                                          style:
                                                              const TextStyle(
                                                            fontSize:
                                                                textFontSize10,
                                                          ),
                                                          controller:
                                                              _controllerList[
                                                                  index],
                                                          decoration:
                                                              InputDecoration(
                                                            contentPadding:
                                                                const EdgeInsets
                                                                    .all(5.0),
                                                            focusedBorder:
                                                                OutlineInputBorder(
                                                              borderSide: BorderSide(
                                                                  color: Theme.of(
                                                                          context)
                                                                      .colorScheme
                                                                      .fontColor,
                                                                  width: 0.5),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          circularBorderRadius5),
                                                            ),
                                                            enabledBorder:
                                                                OutlineInputBorder(
                                                              borderSide: BorderSide(
                                                                  color: Theme.of(
                                                                          context)
                                                                      .colorScheme
                                                                      .fontColor,
                                                                  width: 0.5),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          circularBorderRadius5),
                                                            ),
                                                          ),
                                                        ),
                                                        PopupMenuButton<String>(
                                                          tooltip: '',
                                                          icon: const Icon(
                                                            Icons
                                                                .arrow_drop_down,
                                                            size: 1,
                                                          ),
                                                          onSelected:
                                                              (String value) {
                                                            if (_isProgress ==
                                                                false) {
                                                              addToCart(
                                                                  index, value);
                                                            }
                                                          },
                                                          itemBuilder:
                                                              (BuildContext
                                                                  context) {
                                                            return model
                                                                .itemsCounter!
                                                                .map<
                                                                    PopupMenuItem<
                                                                        String>>(
                                                              (String value) {
                                                                return PopupMenuItem(
                                                                  value: value,
                                                                  child: Text(
                                                                    value,
                                                                  ),
                                                                );
                                                              },
                                                            ).toList();
                                                          },
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  GestureDetector(
                                                    child: Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              2),
                                                      margin:
                                                          const EdgeInsets.only(
                                                              left: 8),
                                                      decoration: BoxDecoration(
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .lightWhite,
                                                        borderRadius:
                                                            const BorderRadius
                                                                .all(
                                                          Radius.circular(
                                                            circularBorderRadius3,
                                                          ),
                                                        ),
                                                      ),
                                                      child: Icon(
                                                        Icons.add,
                                                        size: 14,
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .fontColor,
                                                      ),
                                                    ),
                                                    onTap: () {
                                                      if (_isProgress ==
                                                          false) {
                                                        addToCart(
                                                          index,
                                                          ((int.parse(model
                                                                      .prVarientList![
                                                                          model
                                                                              .selVarient!]
                                                                      .cartCount!)) +
                                                                  int.parse(model
                                                                      .qtyStepSize!))
                                                              .toString(),
                                                        );
                                                      }
                                                    },
                                                  )
                                                ],
                                              ),
                                            ],
                                          )
                                        : const SizedBox(),
                              ],
                            ),
                          ],
                        )),
                  )
                ],
              ),
              context.read<SearchProvider>().productList[index].availability ==
                      '0'
                  ? Text(getTranslated(context, 'OUT_OF_STOCK_LBL'),
                      style: Theme.of(context).textTheme.titleSmall!.copyWith(
                          color: Colors.red, fontWeight: FontWeight.bold))
                  : const SizedBox(),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> addToCart(int index, String qty) async {
    isNetworkAvail = await isNetworkAvailable();
    if (isNetworkAvail) {
      if (context.read<UserProvider>().userId != '') {
        try {
          if (mounted) {
            setState(() {
              _isProgress = true;
            });
          }

          if (int.parse(qty) <
              context
                  .read<SearchProvider>()
                  .productList[index]
                  .minOrderQuntity!) {
            qty = context
                .read<SearchProvider>()
                .productList[index]
                .minOrderQuntity
                .toString();

            setSnackbar("${getTranslated(context, 'MIN_MSG')}$qty", context);
          }

          var parameter = {
            // USER_ID: context.read<UserProvider>().userId,
            PRODUCT_VARIENT_ID: context
                .read<SearchProvider>()
                .productList[index]
                .prVarientList![context
                    .read<SearchProvider>()
                    .productList[index]
                    .selVarient!]
                .id,
            QTY: qty
          };
          Response response =
              await post(manageCartApi, body: parameter, headers: headers)
                  .timeout(const Duration(seconds: timeOut));

          var getdata = json.decode(response.body);

          bool error = getdata['error'];
          String? msg = getdata['message'];
          if (!error) {
            var data = getdata['data'];

            String? qty = data['total_quantity'];
            userProvider.setCartCount(data['cart_count']);

            context
                .read<SearchProvider>()
                .productList[index]
                .prVarientList![context
                    .read<SearchProvider>()
                    .productList[index]
                    .selVarient!]
                .cartCount = qty.toString();
          } else {
            setSnackbar(msg!, context);
          }
          if (mounted) {
            setState(
              () {
                _isProgress = false;
              },
            );
          }
        } on TimeoutException catch (_) {
          setSnackbar(getTranslated(context, 'somethingMSg'), context);
          if (mounted) {
            setState(
              () {
                _isProgress = false;
              },
            );
          }
        }
      }
    } else {
      if (mounted) {
        setState(() {
          isNetworkAvail = false;
        });
      }
    }
  }

  Future<void> removeFromCart(int index) async {
    Product model = context.read<SearchProvider>().productList[index];
    isNetworkAvail = await isNetworkAvailable();
    if (isNetworkAvail) {
      if (context.read<UserProvider>().userId != '') {
        try {
          if (mounted) {
            setState(() {
              _isProgress = true;
            });
          }

          int qty;

          qty = (int.parse(context
                  .read<SearchProvider>()
                  .productList[index]
                  .prVarientList![model.selVarient!]
                  .cartCount!) -
              int.parse(context
                  .read<SearchProvider>()
                  .productList[index]
                  .qtyStepSize!));

          if (qty <
              context
                  .read<SearchProvider>()
                  .productList[index]
                  .minOrderQuntity!) {
            qty = 0;
          }

          var parameter = {
            PRODUCT_VARIENT_ID: model.prVarientList![model.selVarient!].id,
            // USER_ID: context.read<UserProvider>().userId,
            QTY: qty.toString()
          };

          Response response =
              await post(manageCartApi, body: parameter, headers: headers)
                  .timeout(const Duration(seconds: timeOut));

          var getdata = json.decode(response.body);

          bool error = getdata['error'];
          String? msg = getdata['message'];

          if (!error) {
            var data = getdata['data'];
            String? qty = data['total_quantity'];
            userProvider.setCartCount(data['cart_count']);
            model.prVarientList![model.selVarient!].cartCount = qty.toString();
          } else {
            setSnackbar(msg!, context);
          }
          if (mounted) {
            setState(
              () {
                _isProgress = false;
              },
            );
          }
        } on TimeoutException catch (_) {
          setSnackbar(getTranslated(context, 'somethingMSg'), context);
          if (mounted) {
            setState(
              () {
                _isProgress = false;
              },
            );
          }
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

  Future<void> getMostLikePro() async {
    List<String> proIds = [];
    proIds = (await db.getMostLike())!;
    if (proIds.isNotEmpty) {
      isNetworkAvail = await isNetworkAvailable();

      if (isNetworkAvail) {
        try {
          var parameter = {'product_ids': proIds.join(',')};
          apiBaseHelper.postAPICall(getProductApi, parameter).then(
            (getdata) async {
              bool error = getdata['error'];
              if (!error) {
                var data = getdata['data'];

                List<Product> tempList = (data as List)
                    .map((data) => Product.fromJson(data))
                    .toList();
                context.read<ProductProvider>().setProductList(tempList);
              }
              if (mounted) {
                setState(
                  () {
                    context.read<HomePageProvider>().mostLikeLoading = false;
                  },
                );
              }
            },
            onError: (error) {
              setSnackbar(error.toString(), context);
            },
          );
        } on TimeoutException catch (_) {
          setSnackbar(getTranslated(context, 'somethingMSg'), context);
          context.read<HomePageProvider>().mostLikeLoading = false;
        }
      } else {
        if (mounted) {
          setState(
            () {
              isNetworkAvail = false;
              context.read<HomePageProvider>().mostLikeLoading = false;
            },
          );
        }
      }
    } else {
      context.read<ProductProvider>().setProductList([]);
      setState(
        () {
          context.read<HomePageProvider>().mostLikeLoading = false;
        },
      );
    }
  }

  Future getProduct() async {
    isNetworkAvail = await isNetworkAvailable();
    if (isNetworkAvail) {
      try {
        if (context.read<SearchProvider>().notificationisloadmore) {
          if (mounted) {
            setState(
              () {
                context.read<SearchProvider>().notificationisloadmore = false;
                context.read<SearchProvider>().notificationisgettingdata = true;
              },
            );
          }
          var parameter = {
            SEARCH: context.read<SearchProvider>().query.trim(),
            LIMIT: perPage.toString(),
            OFFSET:
                context.read<SearchProvider>().notificationoffset.toString(),
          };

          // if (context.read<UserProvider>().userId != '') {
          // parameter[USER_ID] = context.read<UserProvider>().userId!;
          // }

          Response response =
              await post(getProductApi, headers: headers, body: parameter)
                  .timeout(const Duration(seconds: timeOut));

          var getdata = json.decode(response.body);

          bool error = getdata['error'];

          Map<String, dynamic> tempData = getdata;
          if (tempData.containsKey(TAG)) {
            List<String> tempList = List<String>.from(getdata[TAG]);
            if (tempList.isNotEmpty) {
              context.read<SearchProvider>().tagList = tempList;
            }
          }

          String? search = getdata['search'];

          context.read<SearchProvider>().notificationisgettingdata = false;
          if (context.read<SearchProvider>().notificationoffset == 0) {
            context.read<SearchProvider>().notificationisnodata = error;
          }

          if (!error &&
              search!.trim() == context.read<SearchProvider>().query.trim()) {
            if (mounted) {
              Future.delayed(
                Duration.zero,
                () => setState(
                  () {
                    List mainlist = getdata['data'];

                    if (mainlist.isNotEmpty) {
                      List<Product> items = [];
                      List<Product> allitems = [];

                      items.addAll(mainlist
                          .map((data) => Product.fromJson(data))
                          .toList());
                      allitems.addAll(items);
                      context
                          .read<SearchProvider>()
                          .getAvailVarient(allitems, context, setStateNow);
                    } else {
                      context.read<SearchProvider>().notificationisloadmore =
                          false;
                    }
                  },
                ),
              );
            }
          } else {
            context.read<SearchProvider>().notificationisloadmore = false;
            if (mounted) setState(() {});
          }
        }
      } on TimeoutException catch (_) {
        setSnackbar(getTranslated(context, 'somethingMSg'), context);
        if (mounted) {
          setState(
            () {
              context.read<SearchProvider>().notificationisloadmore = false;
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

  // void getSeller() {
  //   Map parameter = {
  //     LIMIT: perPage.toString(),
  //     OFFSET: sellerListOffset.toString(),
  //   };

  //   if (_controller.text != '') {
  //     parameter = {
  //       SEARCH: _controller.text.trim(),
  //     };
  //   }

  //   apiBaseHelper.postAPICall(getSellerApi, parameter).then(
  //     (getdata) {
  //       bool error = getdata['error'];
  //       String? msg = getdata['message'];
  //       List<Product> tempSellerList = [];
  //       tempSellerList.clear();
  //       if (!error) {
  //         totalSelletCount = int.parse(getdata['total']);
  //         var data = getdata['data'];

  //         tempSellerList =
  //             (data as List).map((data) => Product.fromSeller(data)).toList();
  //         sellerListOffset += perPage;
  //         sellerList.addAll(tempSellerList);

  //         setState(() {});
  //       } else {
  //         setSnackbar(msg!, context);
  //       }

  //       context.read<HomePageProvider>().setSellerLoading(false);
  //     },
  //     onError: (error) {
  //       setSnackbar(error.toString(), context);
  //       context.read<HomePageProvider>().setSellerLoading(false);
  //     },
  //   );
  //   setState(() {});
  // }

  clearAll() {
    setState(
      () {
        context.read<SearchProvider>().query = _controller.text;
        context.read<SearchProvider>().notificationoffset = 0;
        context.read<SearchProvider>().notificationisloadmore = true;
        context.read<SearchProvider>().productList.clear();
      },
    );
  }

  updateState() {
    setState(() {});
  }

  _tags() {
    if (context.read<SearchProvider>().tagList.isNotEmpty) {
      List<Widget> chips = [];
      for (int i = 0; i < context.read<SearchProvider>().tagList.length; i++) {
        tagChip = ChoiceChip(
          selected: false,
          label: Text(context.read<SearchProvider>().tagList[i],
              style: TextStyle(
                  color: Theme.of(context).colorScheme.white,
                  fontSize: textFontSize11)),
          backgroundColor: colors.primary,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: const RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.all(Radius.circular(circularBorderRadius25))),
          onSelected: (bool selected) {
            if (mounted) {
              Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (context) => ProductList(
                    name: context.read<SearchProvider>().tagList[i],
                    fromSeller: false,
                    tag: true,
                  ),
                ),
              );
            }
          },
        );

        chips.add(Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: tagChip));
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(),
          context.read<SearchProvider>().tagList.isNotEmpty
              ? Padding(
                  padding: const EdgeInsetsDirectional.only(start: 8.0),
                  child: Text(
                    getTranslated(context, 'Discover more'),
                  ),
                )
              : const SizedBox(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Wrap(
              children: chips.map<Widget>(
                (Widget chip) {
                  return Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: chip,
                  );
                },
              ).toList(),
            ),
          ),
        ],
      );
    } else {
      return const SizedBox();
    }
  }

  // _showContentOfSellers() {
  //   return sellerList.isNotEmpty
  //       ? ListView.separated(
  //           shrinkWrap: true,
  //           controller: sellerListController,
  //           separatorBuilder: (BuildContext context, int index) =>
  //               const Divider(),
  //           itemCount: sellerList.length,
  //           itemBuilder: (context, index) {
  //             return ListTile(
  //               title: Text(
  //                 sellerList[index].store_name!,
  //                 style: Theme.of(context).textTheme.titleSmall!.copyWith(
  //                     color: Theme.of(context).colorScheme.lightBlack,
  //                     fontWeight: FontWeight.bold),
  //                 maxLines: 2,
  //                 overflow: TextOverflow.ellipsis,
  //               ),
  //               subtitle: Text(
  //                 sellerList[index].seller_name!,
  //                 style: TextStyle(
  //                     fontFamily: 'ubuntu',
  //                     color: Theme.of(context).colorScheme.fontColor),
  //               ),
  //               leading: ClipRRect(
  //                 borderRadius: BorderRadius.circular(circularBorderRadius7),
  //                 child: sellerList[index].seller_profile == ''
  //                     ? Image.asset(
  //                         DesignConfiguration.setPngPath('placeholder'),
  //                         width: 50,
  //                         height: 50,
  //                         fit: BoxFit.cover,
  //                       )
  //                     : DesignConfiguration.getCacheNotworkImage(
  //                         imageurlString: sellerList[index].seller_profile!,
  //                         boxFit: extendImg ? BoxFit.cover : BoxFit.contain,
  //                         context: context,
  //                         heightvalue: 50,
  //                         widthvalue: 50,
  //                         placeHolderSize: 50,
  //                       ),
  //               ),
  //               onTap: () async {
  //                 Navigator.push(
  //                   context,
  //                   CupertinoPageRoute(
  //                     builder: (BuildContext context) => SellerProfile(
  //                       sellerID: sellerList[index].seller_id!,
  //                       totalProductsOfSeller:
  //                           sellerList[index].totalProductsOfSeller,
  //                       sellerImage: sellerList[index].seller_profile!,
  //                       sellerName: sellerList[index].seller_name!,
  //                       sellerRating: sellerList[index].seller_rating!,
  //                       sellerStoreName: sellerList[index].store_name!,
  //                       storeDesc: sellerList[index].store_description!,
  //                     ),
  //                   ),
  //                 );
  //               },
  //             );
  //           },
  //         )
  //       : Selector<HomePageProvider, bool>(
  //           builder: (context, data, child) {
  //             return !data
  //                 ? Center(
  //                     child: Text(
  //                       getTranslated(context, 'No Seller/Store Found')!,
  //                       style: const TextStyle(
  //                         fontFamily: 'ubuntu',
  //                       ),
  //                     ),
  //                   )
  //                 : const SizedBox();
  //           },
  //           selector: (_, provider) => provider.sellerLoading,
  //         );
  // }

  _showContentOfProducts() {
    if (_controller.text == '') {
      SettingProvider settingsProvider =
          Provider.of<SettingProvider>(context, listen: false);

      return FutureBuilder<List<String>>(
        future: settingsProvider.getPrefrenceList(HISTORYLIST),
        builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData) {
            final entities = snapshot.data!;
            oldEntriedForFutureBuilderOfHistory = entities;
            List<Product> itemList = [];
            for (int i = 0; i < entities.length; i++) {
              Product item = Product.history(entities[i]);
              itemList.add(item);
            }
            context.read<SearchProvider>().history.clear();
            context.read<SearchProvider>().history.addAll(itemList);

            return SingleChildScrollView(
              child: Column(
                children: [
                  _SuggestionList(
                    textController: _controller,
                    suggestions: itemList,
                    notificationcontroller: notificationcontroller,
                    getProduct: getProduct,
                    clearAll: clearAll,
                    update: updateState,
                  ),
                  _tags()
                ],
              ),
            );
          } else {
            List<Product> itemList = [];
            for (int i = 0;
                i < oldEntriedForFutureBuilderOfHistory.length;
                i++) {
              Product item =
                  Product.history(oldEntriedForFutureBuilderOfHistory[i]);
              itemList.add(item);
            }
            context.read<SearchProvider>().history.clear();
            context.read<SearchProvider>().history.addAll(itemList);

            return SingleChildScrollView(
              child: Column(
                children: [
                  _SuggestionList(
                    textController: _controller,
                    suggestions: itemList,
                    notificationcontroller: notificationcontroller,
                    getProduct: getProduct,
                    clearAll: clearAll,
                    update: updateState,
                  ),
                  _tags()
                ],
              ),
            );
          }
        },
      );
    } else if (buildResult) {
      return context.read<SearchProvider>().notificationisnodata
          ? DesignConfiguration.getNoItem(context)
          : Column(
              children: <Widget>[
                Flexible(
                  child: ListView.builder(
                    padding: const EdgeInsetsDirectional.only(
                        bottom: 5, start: 10, end: 10, top: 12),
                    controller: notificationcontroller,
                    physics: const BouncingScrollPhysics(),
                    itemCount:
                        context.read<SearchProvider>().productList.length,
                    itemBuilder: (context, index) {
                      Product? item;
                      try {
                        item = context
                                .read<SearchProvider>()
                                .productList
                                .isEmpty
                            ? null
                            : context.read<SearchProvider>().productList[index];
                        if (context
                                .read<SearchProvider>()
                                .notificationisloadmore &&
                            index ==
                                (context
                                        .read<SearchProvider>()
                                        .productList
                                        .length -
                                    1) &&
                            notificationcontroller!.position.pixels <= 0) {
                          getProduct();
                        }
                      } on Exception catch (_) {}

                      return item == null ? const SizedBox() : listItem(index);
                    },
                  ),
                ),
                context.read<SearchProvider>().notificationisgettingdata
                    ? const Center(
                        child: Padding(
                          padding:
                              EdgeInsetsDirectional.only(top: 5, bottom: 5),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : const SizedBox(),
              ],
            );
    }
    return context.read<SearchProvider>().notificationisnodata
        ? DesignConfiguration.getNoItem(context)
        : Column(
            children: <Widget>[
              Flexible(
                child: _SuggestionList(
                  textController: _controller,
                  suggestions: context.read<SearchProvider>().productList,
                  notificationcontroller: notificationcontroller,
                  getProduct: getProduct,
                  clearAll: clearAll,
                  update: updateState,
                ),
              ),
              context.read<SearchProvider>().notificationisgettingdata
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsetsDirectional.only(top: 5, bottom: 5),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : const SizedBox(),
            ],
          );
  }

  Future<void> initSpeechState(int from) async {
    var hasSpeech = await speech.initialize(
        onError: errorListener,
        onStatus: statusListener,
        debugLogging: false,
        finalTimeout: const Duration(milliseconds: 0));
    if (hasSpeech) {
      var systemLocale = await speech.systemLocale();
      _currentLocaleId = systemLocale?.localeId ?? '';
    }

    if (!mounted) return;
    _hasSpeech = hasSpeech;
    // setState(() {
    //   _hasSpeech = hasSpeech;
    // });
    if (hasSpeech) {
      showSpeechDialog(from);
    } else {
      setSnackbar(
          getTranslated(context, 'MICROPHONE_PERMISSION_REQUIRED'), context);
    }
  }

  void errorListener(SpeechRecognitionError error) {}

  void statusListener(String status) {
    setStater(
      () {
        lastStatus = status;
      },
    );
  }

  void startListening() {
    lastWords = '';
    speech.listen(
        onResult: resultListener,
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 5),
        partialResults: true,
        localeId: _currentLocaleId,
        onSoundLevelChange: soundLevelListener,
        cancelOnError: true,
        listenMode: ListenMode.confirmation);
    setStater(() {});
  }

  void soundLevelListener(double level) {
    minSoundLevel = min(minSoundLevel, level);
    maxSoundLevel = max(maxSoundLevel, level);

    setStater(() {
      this.level = level;
    });
  }

  void stopListening() {
    speech.stop();
    setStater(() {
      level = 0.0;
    });
  }

  void cancelListening() {
    speech.cancel();
    setStater(() {
      level = 0.0;
    });
  }

  void resultListener(SpeechRecognitionResult result) {
    setStater(
      () {
        lastWords = result.recognizedWords;
        context.read<SearchProvider>().query = lastWords;
      },
    );

    if (result.finalResult) {
      Future.delayed(const Duration(seconds: 1)).then((_) async {
        clearAll();

        _controller.text = lastWords;
        _controller.selection = TextSelection.fromPosition(
            TextPosition(offset: _controller.text.length));

        setState(() {});
        Navigator.of(context).pop();
      });
    }
  }

  showSpeechDialog(int from) {
    if (from == 1) {
      context.read<HomePageProvider>().setMicClickBtn(false);
    }
    return DesignConfiguration.dialogAnimate(
      context,
      StatefulBuilder(
        builder: (BuildContext context, StateSetter setStater1) {
          setStater = setStater1;
          return AlertDialog(
            backgroundColor: Theme.of(context).colorScheme.lightWhite,
            title: Text(
              getTranslated(context, 'SEarchHint'),
              style: TextStyle(
                color: Theme.of(context).colorScheme.fontColor,
                fontWeight: FontWeight.bold,
                fontSize: textFontSize16,
                fontFamily: 'ubuntu',
              ),
              textAlign: TextAlign.center,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                          blurRadius: .26,
                          spreadRadius: level * 1.5,
                          color: Theme.of(context)
                              .colorScheme
                              .black
                              .withOpacity(.05))
                    ],
                    color: Theme.of(context).colorScheme.white,
                    borderRadius: const BorderRadius.all(
                        Radius.circular(circularBorderRadius50)),
                  ),
                  child: IconButton(
                      icon: const Icon(
                        Icons.mic,
                        color: colors.primary,
                      ),
                      onPressed: () {
                        if (!_hasSpeech) {
                          initSpeechState(0);
                        } else {
                          !_hasSpeech || speech.isListening
                              ? null
                              : startListening();
                        }
                      }),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(lastWords),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  color:
                      Theme.of(context).colorScheme.fontColor.withOpacity(0.1),
                  child: Center(
                    child: speech.isListening
                        ? Text(
                            getTranslated(context, "I'm listening..."),
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall!
                                .copyWith(
                                    color:
                                        Theme.of(context).colorScheme.fontColor,
                                    fontFamily: 'ubuntu',
                                    fontWeight: FontWeight.bold),
                          )
                        : Text(
                            getTranslated(context, 'Not listening'),
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall!
                                .copyWith(
                                  color:
                                      Theme.of(context).colorScheme.fontColor,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'ubuntu',
                                ),
                          ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SuggestionList extends StatelessWidget {
  const _SuggestionList(
      {this.suggestions,
      this.textController,
      this.notificationcontroller,
      this.getProduct,
      this.clearAll,
      required this.update});

  final List<Product>? suggestions;
  final TextEditingController? textController;

  final notificationcontroller;
  final Function? getProduct, clearAll;
  final Function update;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: suggestions!.length,
      shrinkWrap: true,
      controller: notificationcontroller,
      separatorBuilder: (BuildContext context, int index) => const Divider(),
      itemBuilder: (BuildContext context, int i) {
        final Product suggestion = suggestions![i];
        return ListTile(
          title: Text(
            suggestion.name!,
            style: Theme.of(context).textTheme.titleSmall!.copyWith(
                  color: Theme.of(context).colorScheme.fontColor,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'ubuntu',
                ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: textController!.text.toString().trim().isEmpty ||
                  suggestion.history!
              ? null
              : Text(
                  '${getTranslated(context, 'IN')} ${suggestion.catName!}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.fontColor,
                    fontFamily: 'ubuntu',
                  ),
                ),
          leading: textController!.text.toString().trim().isEmpty ||
                  suggestion.history!
              ? IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () async {
                    SettingProvider settingsProvider =
                        Provider.of<SettingProvider>(context, listen: false);

                    suggestions!.removeWhere((item) => item == suggestion);

                    settingsProvider.removeValuePrefrenceList(
                        HISTORYLIST, suggestion.name!);
                    update();
                  },
                )
              : ClipRRect(
                  borderRadius: BorderRadius.circular(circularBorderRadius7),
                  child: suggestion.image == ''
                      ? Image.asset(
                          DesignConfiguration.setPngPath('placeholder'),
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        )
                      : DesignConfiguration.getCacheNotworkImage(
                          imageurlString: suggestion.image!,
                          boxFit: extendImg ? BoxFit.cover : BoxFit.contain,
                          context: context,
                          heightvalue: 50,
                          widthvalue: 50,
                          placeHolderSize: 50,
                        ),
                ),
          trailing: // suggestion.name!.startsWith('Search Result for ')
              //     ? const SizedBox() :
              const Icon(
            Icons.reply,
          ),
          onTap: () async {
            // if (suggestion.name!.startsWith('Search Result for ')) {

            //   SettingProvider settingsProvider =
            //       Provider.of<SettingProvider>(context, listen: false);

            //   settingsProvider.setPrefrenceList(
            //       HISTORYLIST, textController!.text.toString().trim());

            //   buildResult = true;
            //   clearAll!();
            //   getProduct!();
            //} else
            if (suggestion.history!) {
              clearAll!();

              buildResult = true;
              textController!.text = suggestion.name!;
              textController!.selection = TextSelection.fromPosition(
                  TextPosition(offset: textController!.text.length));
            } else {
              SettingProvider settingsProvider =
                  Provider.of<SettingProvider>(context, listen: false);

              settingsProvider.setPrefrenceList(
                  HISTORYLIST, textController!.text.toString().trim());
              buildResult = false;
              Product model = suggestion;
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => ProductDetail(
                    model: model,
                    secPos: 0,
                    index: i,
                    list: true,
                  ),
                ),
              );
            }
          },
        );
      },
    );
  }
}
