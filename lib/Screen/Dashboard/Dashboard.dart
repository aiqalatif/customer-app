import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:eshop_multivendor/Model/message.dart';
import 'package:eshop_multivendor/Provider/SettingProvider.dart';
import 'package:eshop_multivendor/Provider/homePageProvider.dart';
import 'package:eshop_multivendor/Screen/Product%20Detail/productDetail.dart';
import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:eshop_multivendor/Helper/Constant.dart';
import 'package:eshop_multivendor/Model/Section_Model.dart';
import 'package:eshop_multivendor/Provider/Theme.dart';
import 'package:eshop_multivendor/Screen/Profile/MyProfile.dart';
import 'package:eshop_multivendor/Screen/ExploreSection/explore.dart';
import 'package:eshop_multivendor/Screen/PushNotification/PushNotificationService.dart';
import 'package:eshop_multivendor/cubits/personalConverstationsCubit.dart';
import 'package:eshop_multivendor/repository/NotificationRepository.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import '../../Helper/String.dart';
import '../../Provider/UserProvider.dart';
import '../../widgets/security.dart';
import '../../widgets/systemChromeSettings.dart';
import '../SQLiteData/SqliteData.dart';
import '../../Helper/routes.dart';
import '../../widgets/desing.dart';
import '../Language/languageSettings.dart';
import '../../widgets/networkAvailablity.dart';
import '../../widgets/snackbar.dart';
import '../AllCategory/All_Category.dart';
import '../Cart/Cart.dart';
import '../Cart/Widget/clearTotalCart.dart';
import '../Notification/NotificationLIst.dart';
import '../homePage/homepageNew.dart';

class Dashboard extends StatefulWidget {
  static GlobalKey<DashboardPageState> dashboardScreenKey =
      GlobalKey<DashboardPageState>();
  const Dashboard({Key? key}) : super(key: key);

  @override
  DashboardPageState createState() => DashboardPageState();
}

var db = DatabaseHelper();

class DashboardPageState extends State<Dashboard>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  int selBottom = 0;
  late TabController _tabController;

  late StreamSubscription streamSubscription;

  late AnimationController navigationContainerAnimationController =
      AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 200),
  );

  changeTabPosition(int index) {
    Future.delayed(Duration.zero, () {
      _tabController.animateTo(index);
    });
  }

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      SystemChromeSettings.setSystemChromes(
          isDarkTheme: Provider.of<ThemeNotifier>(context, listen: false)
                  .getThemeMode() ==
              ThemeMode.dark);
    });
    WidgetsBinding.instance.addObserver(this);
    NotificationRepository.clearChatNotifications();
    initDynamicLinks();
    _tabController = TabController(
      length: 5,
      vsync: this,
    );

    _tabController.addListener(
      () {
        Future.delayed(const Duration(microseconds: 10)).then(
          (value) {
            setState(
              () {
                selBottom = _tabController.index;
              },
            );
          },
        );
        //show bottombar on tab change by user interaction
        if (_tabController.index != 0 || _tabController.index != 2 || _tabController.index != 3 &&
            !context.read<HomePageProvider>().getBars) {
          context.read<HomePageProvider>().animationController.reverse();
          context.read<HomePageProvider>().showAppAndBottomBars(true);
        }
        if (_tabController.index == 3) {
          cartTotalClear(context);
        }
      },
    );

    Future.delayed(
      Duration.zero,
      () async {
        if ((context.read<SettingProvider>().userId ?? '').isNotEmpty) {
          if (kDebugMode) {
            print('Init the push notificaiton service');
          }
          PushNotificationService(context: context).initialise();
        }
        SettingProvider settingsProvider =
            Provider.of<SettingProvider>(context, listen: false);
        context
            .read<UserProvider>()
            .setUserId(await settingsProvider.getPrefrence(ID) ?? '');

        context.read<HomePageProvider>()
          ..setAnimationController(navigationContainerAnimationController)
          ..setBottomBarOffsetToAnimateController(
              navigationContainerAnimationController)
          ..setAppBarOffsetToAnimateController(
              navigationContainerAnimationController);
      },
    );
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      NotificationRepository.getChatNotifications().then((messages) {
        for (var encodedMessage in messages) {
          final message =
              Message.fromJson(Map.from(jsonDecode(encodedMessage) ?? {}));

          if (converstationScreenStateKey.currentState?.mounted ?? false) {
            final state = converstationScreenStateKey.currentState!;
            if (state.widget.isGroup) {
              //To manage the group
            } else {
              //
              if (state.widget.personalChatHistory?.getOtherUserId() !=
                  message.fromId) {
                context
                    .read<PersonalConverstationsCubit>()
                    .updateUnreadMessageCounter(userId: message.fromId!);
              } else {
                state.addMessage(message: message);
              }
            }
          } else {
            if (message.type == 'person') {
              context
                  .read<PersonalConverstationsCubit>()
                  .updateUnreadMessageCounter(
                    userId: message.fromId!,
                  );
            } else {
              // Update group message
            }
          }
        }
        //Clear the message notifications
        NotificationRepository.clearChatNotifications();
      });
    }
  }

  setSnackBarFunctionForCartMessage() {
    Future.delayed(const Duration(seconds: 5)).then(
      (value) {
        if (homePageSingleSellerMessage) {
          homePageSingleSellerMessage = false;
          showOverlay(
              getTranslated(context,
                  'One of the product is out of stock, We are not able To Add In Cart'),
              context);
        }
      },
    );
  }

  Future<void> initDynamicLinks() async {
    FirebaseDynamicLinks.instance.onLink.listen((event) async {
      final Uri deepLink = event.link;
      if (deepLink.queryParameters.isNotEmpty) {
        deeplinkGetData(deepLink.queryParameters);
      }
    }, onError: (e) {});
    final PendingDynamicLinkData? initialLink =
        await FirebaseDynamicLinks.instance.getInitialLink();
    try {
      if (initialLink != null) {
        if (initialLink.link.queryParameters.isNotEmpty) {
          deeplinkGetData(initialLink.link.queryParameters);
        }
      }
    } catch (e) {
      debugPrint('deeplink=other>No deepLink found');
    }
  }

  deeplinkGetData(Map<String, String> queryParameters) {
    int index = int.parse(queryParameters['index']!);

    int secPos = int.parse(queryParameters['secPos']!);

    String? id = queryParameters['id'];

    String? list = queryParameters['list'];

    getProduct(id!, index, secPos, list == 'true' ? true : false);
  }

  Future<void> getProduct(String id, int index, int secPos, bool list) async {
    isNetworkAvail = await isNetworkAvailable();
    if (isNetworkAvail) {
      try {
        var parameter = {
          ID: id,
        };

        Response response =
            await post(getProductApi, headers: headers, body: parameter)
                .timeout(const Duration(seconds: timeOut));

        var getdata = json.decode(response.body);
        bool error = getdata['error'];
        String msg = getdata['message'];
        if (!error) {
          var data = getdata['data'];
          print('dynamic link data****$data');

          List<Product> items = [];

          items = (data as List).map((data) => Product.fromJson(data)).toList();
          bool useSection = false;
          if (!list) {
            if (context.read<HomePageProvider>().sectionList.length > secPos) {
              if ((context
                          .read<HomePageProvider>()
                          .sectionList[secPos]
                          .productList
                          ?.length ??
                      0) >
                  index) {
                useSection = true;
              }
            }
          }
          Navigator.of(context).push(
            CupertinoPageRoute(
              builder: (context) => ProductDetail(
                index: list ? int.parse(id) : index,
                model: !useSection
                    ? items[0]
                    : context
                        .read<HomePageProvider>()
                        .sectionList[secPos]
                        .productList![index],
                secPos: secPos,
                list: list,
              ),
            ),
          );
        } else {
          if (msg != 'Products Not Found !') setSnackbar(msg, context);
        }
      } on TimeoutException catch (_) {
        setSnackbar(getTranslated(context, 'somethingMSg'), context);
      }
    } else {
      {
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

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: selBottom == 0,
      onPopInvoked: (didPop) {
        if (_tabController.index != 0) {
          _tabController.animateTo(0);
        }
      },
      child: Scaffold(
        extendBodyBehindAppBar: false,
        extendBody: true,
        backgroundColor: Theme.of(context).colorScheme.lightWhite,
        appBar: selBottom == 0
            ? _getAppBar()
            : AppBar(
                systemOverlayStyle: SystemUiOverlayStyle(
                    statusBarColor: Theme.of(context).colorScheme.white),
                toolbarHeight: 0,
                elevation: 0,
                backgroundColor: Theme.of(context).colorScheme.white,
              ) 
              //  : const PreferredSize(
              //   preferredSize: Size.zero,
              //   child: SizedBox(),
              // ) 
        ,
        body: SafeArea(
            child: Consumer<UserProvider>(builder: (context, data, child) {
          return TabBarView(
            controller: _tabController,
            children: const [
              HomePage(),
              AllCategory(),
              Explore(),
              Cart(
                fromBottom: true,
              ),
              MyProfile(),
            ],
          );
        })),
        // floatingActionButton: FloatingActionButton(
        //   backgroundColor: Colors.pink,
        //   child: const Icon(Icons.add),
        //   onPressed: () {
        //     Navigator.push(
        //       context,
        //       CupertinoPageRoute(
        //         builder: (context) => const AnimationScreen(),
        //       ),
        //     );
        //   },
        // ),
        bottomNavigationBar: _getBottomBar(),
      ),
    );
  }

  _getAppBar() {
    /* String? title;
    if (_selBottom == 1) {
      title = getTranslated(context, 'CATEGORY');
    } else if (_selBottom == 2) {
      title = getTranslated(context, 'EXPLORE');
    } else if (_selBottom == 3) {
      title = getTranslated(context, 'MYBAG');
    } else if (_selBottom == 4) {
      title = getTranslated(context, 'PROFILE');
    } */
    final appBar = AppBar(
      systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Theme.of(context).colorScheme.white),
      elevation: 0,
      toolbarHeight: 60,
      shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(20), // Radius for bottom left and right corners
            ),
          ),
      centerTitle: false,
      automaticallyImplyLeading: false,
      backgroundColor: Theme.of(context).colorScheme.white,
      // ignore: prefer_single_quotes
      title: const Padding(padding: EdgeInsetsDirectional.only(start: 10, end: 10),
        child:   Text("DsiStars",style: TextStyle(color:colors.primary,fontSize: 25),)),
      /* _selBottom == 0
          ? */
      //     SvgPicture.asset(
      //   DesignConfiguration.setSvgPath('titleicon'),
      //   height: 40,
      // ),
      /* : Text(
              title!,
              style: const TextStyle(
                color: colors.primary,
                fontFamily: 'ubuntu',
                fontWeight: FontWeight.normal,
              ),
            ), */
      actions: <Widget>[
        appbarActionIcon(() {
          Routes.navigateToFavoriteScreen(context);
        }, 'fav_black'),
        appbarActionIcon(() {
          context.read<UserProvider>().userId != ''
              ? Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (context) => const NotificationList(),
                  ),
                ).then(
                  (value) {
                    if (value != null && value) {
                      _tabController.animateTo(1);
                    }
                  },
                )
              : Routes.navigateToLoginScreen(
                  context,
                  classType: const Dashboard(),
                  isPop: true,
                );
        }, 'notification_black'),
      ],
    );

    return PreferredSize(
      preferredSize: appBar.preferredSize,
      child: SlideTransition(
        position: context.watch<HomePageProvider>().animationAppBarBarOffset,
        child: SizedBox(
          height: context.watch<HomePageProvider>().getBars ? 100 : 0,
          child: appBar,
        ),
      ),
    );
  }

  appbarActionIcon(Function callback, String iconname) {
    return Align(
      child: GestureDetector(
        onTap: () {
          callback();
        },
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).colorScheme.gray),
            borderRadius: BorderRadius.circular(circularBorderRadius10),
            color: Theme.of(context).colorScheme.white,
          ),
          margin: const EdgeInsetsDirectional.only(end: 10),
          width: Platform.isAndroid ? 37 : 30,
          height: Platform.isAndroid ? 37 : 30,
          padding: const EdgeInsets.all(7),
          child: SvgPicture.asset(
            DesignConfiguration.setSvgPath(iconname),
            colorFilter: ColorFilter.mode(
                Theme.of(context).colorScheme.black, BlendMode.srcIn),
          ),
        ),
      ),
    );
  }

  getTabItem(String enabledImage, String disabledImage, int selectedIndex,
      String name) {
    return Wrap(
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: SizedBox(
                height: 25,
                child: selBottom == selectedIndex
                    ? Lottie.asset(
                        DesignConfiguration.setLottiePath(enabledImage),
                        repeat: false,
                        height: 25,
                      )
                    : SvgPicture.asset(
                        DesignConfiguration.setSvgPath(disabledImage),
                        colorFilter: const ColorFilter.mode(
                            Colors.grey, BlendMode.srcIn),
                        height: 20,
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Text(
                getTranslated(context, name),
                style: TextStyle(
                  color: selBottom == selectedIndex
                      ? Theme.of(context).colorScheme.fontColor
                      : Theme.of(context).colorScheme.lightBlack,
                  fontWeight: FontWeight.w400,
                  fontStyle: FontStyle.normal,
                  fontSize: textFontSize11,
                  fontFamily: 'ubuntu',
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            )
          ],
        ),
      ],
    );
  }

  Widget _getBottomBar() {
    Brightness currentBrightness = MediaQuery.of(context).platformBrightness;

    return AnimatedContainer(
      duration: Duration(
        milliseconds: context.watch<HomePageProvider>().getBars ? 500 : 500,
      ),
      padding: EdgeInsets.only(
          bottom:
              Platform.isIOS ? MediaQuery.of(context).viewPadding.bottom : 0),
      height: context.watch<HomePageProvider>().getBars
          ? kBottomNavigationBarHeight +
              (Platform.isIOS
                  ? MediaQuery.of(context).viewPadding.bottom > 8
                      ? 8
                      : MediaQuery.of(context).viewPadding.bottom
                  : 0)
          : 0,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.white,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.black26,
            blurRadius: selBottom == 2 ? 0 : 5 ,
          )
        ],
      ),
      child: Selector<ThemeNotifier, ThemeMode>(
        selector: (_, themeProvider) => themeProvider.getThemeMode(),
        builder: (context, data, child) {
          return TabBar(
            isScrollable: false,
            controller: _tabController,indicatorPadding: EdgeInsets.zero,labelPadding: EdgeInsets.zero,
            tabs: [
              Tab(
                child: getTabItem(
                  (data == ThemeMode.system &&
                              currentBrightness == Brightness.dark) ||
                          data == ThemeMode.dark
                      ? 'dark_active_home'
                      : 'light_active_home',
                  'home',
                  0,
                  'HOME_LBL',
                ),
              ),
              Tab(
                child: getTabItem(
                    (data == ThemeMode.system &&
                                currentBrightness == Brightness.dark) ||
                            data == ThemeMode.dark
                        ? 'dark_active_category'
                        : 'light_active_category',
                    'category',
                    1,
                    'CATEGORY'),
              ),
              Tab(
                child: getTabItem(
                  (data == ThemeMode.system &&
                              currentBrightness == Brightness.dark) ||
                          data == ThemeMode.dark
                      ? 'dark_active_explorer'
                      : 'light_active_explorer',
                  'brands',
                  2,
                  'EXPLORE',
                ),
              ),
              Tab(
                child: Selector<UserProvider, String>(
                  builder: (context, data, child) {
                    return Stack(
                      children: [
                        getTabItem(
                          (data == ThemeMode.system &&
                                      currentBrightness == Brightness.dark) ||
                                  data == ThemeMode.dark
                              ? 'dark_active_cart'
                              : 'light_active_cart',
                          'cart',
                          3,
                          'CART',
                        ),
                        (data.isNotEmpty && data != '0')
                            ? Positioned.directional(
                                end: 0,
                                textDirection: Directionality.of(context),
                                top: 0,
                                child: Container(
                                    decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: colors.primary),
                                    child: Center(
                                      child: Padding(
                                        padding: const EdgeInsets.all(3),
                                        child: Text(
                                          data,
                                          style: TextStyle(
                                              fontSize: 7,
                                              fontWeight: FontWeight.bold,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .white),
                                        ),
                                      ),
                                    )),
                              )
                            : const SizedBox.shrink()
                      ],
                    );
                  },
                  selector: (_, homeProvider) => homeProvider.curCartCount,
                ),
              ),
              Tab(
                child: getTabItem(
                  (data == ThemeMode.system &&
                              currentBrightness == Brightness.dark) ||
                          data == ThemeMode.dark
                      ? 'dark_active_profile'
                      : 'light_active_profile',
                  'profile',
                  4,
                  'PROFILE',
                ),
              ),
            ],
            indicatorColor: Colors.transparent,
            labelColor: colors.primary,
            // isScrollable: false,
            labelStyle: const TextStyle(fontSize: textFontSize12),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tabController.dispose();
    super.dispose();
  }
}
