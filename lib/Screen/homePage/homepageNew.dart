import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:eshop_multivendor/Helper/ApiBaseHelper.dart';
import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:eshop_multivendor/Helper/Constant.dart';
import 'package:eshop_multivendor/Provider/CategoryProvider.dart';
import 'package:eshop_multivendor/Screen/Dashboard/Dashboard.dart';
import 'package:eshop_multivendor/Screen/SQLiteData/SqliteData.dart';
import 'package:eshop_multivendor/Model/Section_Model.dart';
import 'package:eshop_multivendor/Provider/CartProvider.dart';
import 'package:eshop_multivendor/Provider/Search/SearchProvider.dart';
import 'package:eshop_multivendor/Provider/SettingProvider.dart';
import 'package:eshop_multivendor/Provider/UserProvider.dart';
import 'package:eshop_multivendor/Provider/systemProvider.dart';
import 'package:eshop_multivendor/Screen/homePage/widgets/MostLikeSection.dart';
import 'package:eshop_multivendor/Screen/homePage/widgets/brandsListWidget.dart';
import 'package:eshop_multivendor/Screen/homePage/widgets/hideAppBarBottom.dart';
import 'package:eshop_multivendor/Screen/homePage/widgets/homePageDialog.dart';
import 'package:eshop_multivendor/Screen/homePage/widgets/horizontalCategoryList.dart';
import 'package:eshop_multivendor/Screen/homePage/widgets/section.dart';
import 'package:eshop_multivendor/Screen/homePage/widgets/slider.dart';
import 'package:eshop_multivendor/cubits/brandsListCubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:version/version.dart';
import '../../Helper/String.dart';
import '../../Helper/routes.dart';
import '../../Provider/Favourite/FavoriteProvider.dart';
import '../../Provider/homePageProvider.dart';
import '../../widgets/desing.dart';
import '../Language/languageSettings.dart';
import '../../widgets/networkAvailablity.dart';
import '../../widgets/security.dart';
import '../../widgets/snackbar.dart';
import '../NoInterNetWidget/NoInterNet.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin<HomePage>, TickerProviderStateMixin {
  late Animation buttonSqueezeanimation;
  late AnimationController buttonController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  var db = DatabaseHelper();
  final ScrollController _scrollBottomBarController = ScrollController();
  DateTime? currentBackPressTime;
  ApiBaseHelper apiBaseHelper = ApiBaseHelper();

  int count = 1;

  @override
  bool get wantKeepAlive => true;

  setStateNow() {
    setState(() {});
  }

  setSnackBarFunctionForCartMessage() {
    Future.delayed(const Duration(seconds: 6)).then(
      (value) {
        if (homePageSingleSellerMessage) {
          homePageSingleSellerMessage = false;
          showOverlay(
            getTranslated(context,
                'One of the product is out of stock, We are not able To Add In Cart'),
            context,
          );
        }
      },
    );
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      UserProvider user = Provider.of<UserProvider>(context, listen: false);

      SettingProvider setting =
          Provider.of<SettingProvider>(context, listen: false);
      user.setMobile(setting.mobile);
      user.setName(setting.userName);
      user.setEmail(setting.email);
      user.setProfilePic(setting.profileUrl);
      user.setLoginType(setting.loginType);
      //setUserData();
      Future.delayed(Duration.zero).then(
        (value) {
          callApi();
        },
      );

      buttonController = AnimationController(
        duration: const Duration(milliseconds: 2000),
        vsync: this,
      );

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
      setSnackBarFunctionForCartMessage();
      Future.delayed(Duration.zero).then(
        (value) {
          hideAppbarAndBottomBarOnScroll(
            _scrollBottomBarController,
            context,
          );
        },
      );
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      key: _scaffoldKey,
      body: PopScope(
        canPop: !(currentBackPressTime == null ||
            DateTime.now().difference(currentBackPressTime!) >
                const Duration(seconds: 2)),
        onPopInvoked: (didPop) {
          if (Dashboard.dashboardScreenKey.currentState?.selBottom == 0) {
            DateTime now = DateTime.now();
            if (currentBackPressTime == null ||
                now.difference(currentBackPressTime!) >
                    const Duration(seconds: 2)) {
              currentBackPressTime = now;
              setSnackbar(
                  getTranslated(context, 'Press back again to Exit'), context);
              setState(() {});
            }
          }
        },
        // child: SafeArea(
        //   child: isNetworkAvail
        //       ? RefreshIndicator(
        //           color: colors.primary,
        //           key: _refreshIndicatorKey,
        //           onRefresh: _refresh,
        //           child: CustomScrollView(
        //             physics: const BouncingScrollPhysics(),
        //             controller: _scrollBottomBarController,
        //             slivers: [
        //               SliverPersistentHeader(
        //                 floating: false,
        //                 pinned: true,
        //                 delegate: SearchBarHeaderDelegate(),
        //               ),
        //               const SliverToBoxAdapter(
        //                 child: Column(
        //                   children: [
        //                     HorizontalCategoryList(),
        //                     CustomSlider(),
        //                     BrandsListWidget(),
        //                     Section(),
        //                     MostLikeSection(),
        //                   ],
        //                 ),
        //               )
        //             ],
        //           ),
        //         )
        //       : NoInterNet(
        //           buttonController: buttonController,
        //           buttonSqueezeanimation: buttonSqueezeanimation,
        //           setStateNoInternate: setStateNoInternate,
        //         ),
        // ),
        child: SafeArea(
          child: isNetworkAvail
              ? Padding(
                padding: EdgeInsets.only(
                  top: context.watch<HomePageProvider>().getBars ? 10 : 40,
                ),
                child: NestedScrollView(
                  controller: _scrollBottomBarController,
                  headerSliverBuilder:
                      (BuildContext context, bool innerBoxIsScrolled) {
                    return [
                      SliverPersistentHeader(
                        delegate: SearchBarHeaderDelegate(),
                        floating: false,
                        pinned: true,
                      ),
                    ];
                  },
                  body: RefreshIndicator(
                  color: colors.primary, // Replace with your color
                  key: _refreshIndicatorKey,
                  onRefresh: _refresh,
                    child: ListView(
                      padding: EdgeInsets.zero, 
                      children: const [
                        HorizontalCategoryList(),
                        CustomSlider(),
                        BrandsListWidget(),
                        Section(),
                        MostLikeSection(),
                      ],
                    ),
                  ),
                ),
              )
              : NoInterNet(
                  buttonController: buttonController,
                  buttonSqueezeanimation: buttonSqueezeanimation,
                  setStateNoInternate: setStateNoInternate,
                ),
        ),
     
     ),
    );
  }

  Future<void> _refresh() {
    context.read<HomePageProvider>().catLoading = true;
    context.read<HomePageProvider>().secLoading = true;
    context.read<HomePageProvider>().sliderLoading = true;
    context.read<HomePageProvider>().mostLikeLoading = true;
    context.read<HomePageProvider>().offerLoading = true;
    context.read<HomePageProvider>().proIds.clear();
    context.read<HomePageProvider>().sliderList.clear();
    context.read<HomePageProvider>().offerImagesList.clear();
    context.read<CategoryProvider>().setCurSelected(0);
    context.read<HomePageProvider>().sectionList.clear();
    return callApi();
  }

  Future<void> callApi({bool isrefresh = true}) async {
    isNetworkAvail = await isNetworkAvailable();
    if (isNetworkAvail) {
      getSetting();
      context.read<BrandsListCubit>().getBrandsList();
      context.read<HomePageProvider>().getSliderImages();
      context.read<HomePageProvider>().getCategories(context);
      context.read<HomePageProvider>().getOfferImages();

      if (isrefresh) {
        context.read<HomePageProvider>().getSections(
              context: context,
            );
      }

      context.read<HomePageProvider>().getMostLikeProducts();
      context.read<HomePageProvider>().getMostFavouriteProducts();
    } else {
      if (mounted) {
        setState(
          () {
            isNetworkAvail = false;
          },
        );
      }
    }
    return;
  }

  void getSetting() {
    context
        .read<SystemProvider>()
        .getSystemSettings(userID: context.read<UserProvider>().userId)
        .then(
      (systemConfigData) async {
        if (!systemConfigData['error']) {
          //
          //Tag list from system API
          if (systemConfigData['tagList'] != null) {
            context.read<SearchProvider>().tagList =
                systemConfigData['tagList'];
          }
          //check whether app is under maintenance
          if (systemConfigData['isAppUnderMaintenance'] == '1') {
            HomePageDialog.showUnderMaintenanceDialog(context);
          }

          if (context.read<UserProvider>().userId != '') {
            context
                .read<UserProvider>()
                .setCartCount(systemConfigData['cartCount']);
            context
                .read<UserProvider>()
                .setBalance(systemConfigData['userBalance']);
            context
                .read<UserProvider>()
                .setPincode(systemConfigData['pinCode']);

            if (systemConfigData['referCode'] == null ||
                systemConfigData['referCode'] == '' ||
                systemConfigData['referCode']!.isEmpty) {
              generateReferral();
            } else {
              context
                  .read<UserProvider>()
                  .setReferCode(systemConfigData['referCode']);
              context
                  .read<SettingProvider>()
                  .setPrefrence(REFERCODE, systemConfigData['referCode']);
            }

            context.read<HomePageProvider>().getFav(context);
            context
                .read<CartProvider>()
                .getUserCart(save: '0', context: context);
          } else {
            context.read<CartProvider>().getUserOfflineCart(context);
            _getOffFav();
          }
          if (systemConfigData['isVersionSystemOn'] == '1') {
            String? androidVersion = systemConfigData['androidVersion'];
            String? iOSVersion = systemConfigData['iOSVersion'];

            PackageInfo packageInfo = await PackageInfo.fromPlatform();

            String version = packageInfo.version;

            final Version currentVersion = Version.parse(version);
            final Version latestVersionAnd = Version.parse(androidVersion!);
            final Version latestVersionIos = Version.parse(iOSVersion!);

            if ((Platform.isAndroid && latestVersionAnd > currentVersion) ||
                (Platform.isIOS && latestVersionIos > currentVersion)) {
              HomePageDialog.showAppUpdateDialog(context);
            }
          }
          setState(() {});
        } else {
          setSnackbar(systemConfigData['message']!, context);
        }
      },
    ).onError(
      (error, stackTrace) {
        setSnackbar(error.toString(), context);
      },
    );
  }

/*  Future<void>? getDialogForClearCart() {
    HomePageDialog.clearYouCartDialog(context);
    return null;
  }*/

  Future<void> _getOffFav() async {
    if (context.read<UserProvider>().userId == '') {
      List<String>? proIds = (await db.getFav())!;
      if (proIds.isNotEmpty) {
        isNetworkAvail = await isNetworkAvailable();

        if (isNetworkAvail) {
          try {
            var parameter = {'product_ids': proIds.join(',')};

            Response response =
                await post(getProductApi, body: parameter, headers: headers)
                    .timeout(const Duration(seconds: timeOut));

            var getdata = json.decode(response.body);
            bool error = getdata['error'];
            if (!error) {
              var data = getdata['data'];

              List<Product> tempList =
                  (data as List).map((data) => Product.fromJson(data)).toList();

              context.read<FavoriteProvider>().setFavlist(tempList);
            }
            if (mounted) {
              setState(() {
                context.read<FavoriteProvider>().setLoading(false);
              });
            }
          } on TimeoutException catch (_) {
            setSnackbar(getTranslated(context, 'somethingMSg'), context);
            context.read<FavoriteProvider>().setLoading(false);
          }
        } else {
          if (mounted) {
            setState(() {
              isNetworkAvail = false;
              context.read<FavoriteProvider>().setLoading(false);
            });
          }
        }
      } else {
        context.read<FavoriteProvider>().setFavlist([]);
        setState(() {
          context.read<FavoriteProvider>().setLoading(false);
        });
      }
    }
  }

  final _chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  final Random _rnd = Random();

  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
      length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

  Future<void> generateReferral() async {
    String refer = getRandomString(8);

    Map parameter = {
      REFERCODE: refer,
    };

    apiBaseHelper.postAPICall(validateReferalApi, parameter).then(
      (getdata) {
        bool error = getdata['error'];
        if (!error) {
          context.read<UserProvider>().setReferCode(refer);
          context.read<SettingProvider>().setPrefrence(REFERCODE, refer);

          Map parameter = {
            // USER_ID: context.read<UserProvider>().userId,
            REFERCODE: refer,
          };

          apiBaseHelper.postAPICall(getUpdateUserApi, parameter);
        } else {
          if (count < 5) generateReferral();
          count++;
        }

        context.read<HomePageProvider>().secLoading = false;
      },
      onError: (error) {
        setSnackbar(error.toString(), context);
        context.read<HomePageProvider>().secLoading = false;
      },
    );
  }

  Widget homeShimmer() {
    return SizedBox(
      width: double.infinity,
      child: Shimmer.fromColors(
        baseColor: Theme.of(context).colorScheme.simmerBase,
        highlightColor: Theme.of(context).colorScheme.simmerHigh,
        child: SingleChildScrollView(
            child: Column(
          children: [
            HorizontalCategoryList.catLoading(context),
            sliderLoading(),
            Section.sectionLoadingShimmer(context),
          ],
        )),
      ),
    );
  }

  Widget sliderLoading() {
    double width = deviceWidth!;
    double height = width / 2;
    return Shimmer.fromColors(
      baseColor: Theme.of(context).colorScheme.simmerBase,
      highlightColor: Theme.of(context).colorScheme.simmerHigh,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        width: double.infinity,
        height: height,
        color: Theme.of(context).colorScheme.white,
      ),
    );
  }

  setStateNoInternate() async {
    context.read<HomePageProvider>().catLoading = true;
    context.read<HomePageProvider>().secLoading = true;
    context.read<HomePageProvider>().offerLoading = true;
    context.read<HomePageProvider>().mostLikeLoading = true;
    context.read<HomePageProvider>().sliderLoading = true;
    _playAnimation();

    Future.delayed(const Duration(seconds: 2)).then(
      (_) async {
        isNetworkAvail = await isNetworkAvailable();
        if (isNetworkAvail) {
          if (mounted) {
            setState(
              () {
                isNetworkAvail = true;
              },
            );
          }
          callApi();
        } else {
          await buttonController.reverse();
          if (mounted) setState(() {});
        }
      },
    );
  }

  Future<void> _playAnimation() async {
    try {
      await buttonController.forward();
    } on TickerCanceled {}
  }

  @override
  void dispose() {
    _scrollBottomBarController.removeListener(() {});
    super.dispose();
  }
}

class SearchBarHeaderDelegate extends SliverPersistentHeaderDelegate {
  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        10,
        0,
        10,
        0,
      ),
      child: Align(
        alignment: Alignment.topCenter,
        child: Container(
          height: 50,
          decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.white,
              borderRadius: BorderRadius.circular(circularBorderRadius10),
              border: Border.all(
                color: Theme.of(context).colorScheme.fontColor.withOpacity(0.2),
              )),
          padding: const EdgeInsetsDirectional.only(start: 10, end: 10),
          child: Row(
            children: [
              Expanded(
                child: InkWell(
                  child: Row(children: [
                    SvgPicture.asset(
                      DesignConfiguration.setSvgPath('homepage_search'),
                      height: 15,
                      width: 15,
                    ),
                    Padding(
                      padding: const EdgeInsetsDirectional.only(start: 15),
                      child: Text(getTranslated(context, 'searchHint'),
                          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                color: Theme.of(context).colorScheme.lightBlack,
                                fontSize: textFontSize12,
                                fontWeight: FontWeight.w400,
                                fontStyle: FontStyle.normal,
                              )),
                    )
                  ]),
                  onTap: () {
                    Routes.navigateToSearchScreen(context);
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: InkWell(
                  onTap: () {
                    context.read<HomePageProvider>().setMicClickBtn(true);
                    Routes.navigateToSearchScreen(context);
                  },
                  child: SvgPicture.asset(
                    DesignConfiguration.setSvgPath('voice_search'),
                    height: 25,
                    width: 25,
                    colorFilter: ColorFilter.mode(
                        Theme.of(context).colorScheme.lightBlack,
                        BlendMode.srcIn),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  double get maxExtent => 65;

  @override
  double get minExtent => 65;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
