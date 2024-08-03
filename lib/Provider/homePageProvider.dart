import 'package:eshop_multivendor/Provider/UserProvider.dart';
import 'package:eshop_multivendor/Screen/SQLiteData/SqliteData.dart';
import 'package:eshop_multivendor/repository/homeRepository.dart';
import 'package:eshop_multivendor/widgets/desing.dart';
import 'package:eshop_multivendor/Screen/Language/languageSettings.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../Helper/Constant.dart';
import '../Helper/String.dart';
import '../Model/Model.dart';
import '../Model/Section_Model.dart';
import '../widgets/networkAvailablity.dart';
import '../widgets/snackbar.dart';
import 'CategoryProvider.dart';
import 'Favourite/FavoriteProvider.dart';

class HomePageProvider extends ChangeNotifier {
  int _curSlider = 0;
  bool catLoading = true;
  bool secLoading = true;
  bool offerLoading = true;
  bool mostLikeLoading = true;
  bool _sellerLoading = true;
  bool sliderLoading = true;
  bool _showBars = true;
  bool isMicClick = false;
  int _selectedBottomNavigationBarIndex = 0;
  late AnimationController _animationController;
  late Animation<Offset> _animationBottomBarOffset;
  late Animation<Offset> _animationAppBarOffset;

  List<Product> productList = [];
  List<SectionModel> sectionList = [];
  List<Product> catList = [], popularList = [];
  List<Model> sliderList = [];
  DateTime? _currentBackPressTime;
  List<Model> homeSliderList = [];
  List<Widget> pages = [];
  List<Model> offerImagesList = [];
  List<Product> mostFavouriteProductList = [];
  List<String> proIds = [];
  List<Product> mostLikeProductList = [];
  List<String> proIds1 = [];

  get getCurrentBackPressTime => _currentBackPressTime;

  set setCurrentBackPressTime(DateTime value) {
    _currentBackPressTime = value;
  }

  get sellerLoading => _sellerLoading;

  get curSlider => _curSlider;

  get getBars => _showBars;

  AnimationController get animationController => _animationController;

  get animationNavigationBarOffset => _animationBottomBarOffset;

  get animationAppBarBarOffset => _animationAppBarOffset;

  get micClick => isMicClick;

  int get selectedBottomNavigationBarIndex => _selectedBottomNavigationBarIndex;

  set setSelectedBottomNavigationBarIndex(int value) {
    _selectedBottomNavigationBarIndex = value;
    notifyListeners();
  }

  setMicClickBtn(bool value) {
    isMicClick = value;

    notifyListeners();
  }

  showAppAndBottomBars(bool value) {
    _showBars = value;
    notifyListeners();
  }

  void setAnimationController(AnimationController animationController) {
    _animationController = animationController;
    notifyListeners();
  }

  setBottomBarOffsetToAnimateController(
      AnimationController animationController) {
    _animationBottomBarOffset =
        Tween<Offset>(begin: Offset.zero, end: const Offset(0.0, 1.0)).animate(
      CurvedAnimation(
        parent: animationController,
        curve: Curves.easeIn,
      ),
    );
    notifyListeners();
  }

  setAppBarOffsetToAnimateController(AnimationController animationController) {
    _animationAppBarOffset =
        Tween<Offset>(end: const Offset(0.0, -1.25), begin: Offset.zero)
            .animate(
      CurvedAnimation(
        parent: animationController,
        curve: Curves.easeIn,
      ),
    );
    notifyListeners();
  }

  setCurSlider(int pos) {
    _curSlider = pos;
    notifyListeners();
  }

  setSellerLoading(bool loading) {
    _sellerLoading = loading;
    notifyListeners();
  }

  //
  //This method is used to get Slider images from server
  Future<void> getSliderImages() async {
    sliderLoading = true;
    notifyListeners();
    homeSliderList.clear();

    await HomeRepository.fetchSliderImages().then(
      (result) {
        if (!result['error']) {
          List<Model> tempList = [];

          for (var element in (result['sliderList'] as List)) {
            tempList.add(element);
          }

          homeSliderList.addAll(tempList);
          sliderLoading = false;
          notifyListeners();
        }
      },
    );
  }

  //This method is used to get Categories from server
  Future<void> getCategories(
    BuildContext context,
  ) async {
    catLoading = true;
    catList.clear();
    notifyListeners();

    var parameter = {
      CAT_FILTER: 'false',
    };

    await HomeRepository.fetchCategories(
      parameter: parameter,
    ).then(
      (result) {
        bool error = result['error'];
        String? msg = result['message'];

        if (!error) {
          var data = result['data'];
          print("#######################################333");
          print(data);
          print("#######################################333");
          catList =
              (data as List).map((data) => Product.fromCat(data)).toList();

          if (result.containsKey('popular_categories')) {
            var data = result['popular_categories'];
            popularList =
                (data as List).map((data) => Product.fromCat(data)).toList();

            if (popularList.isNotEmpty) {
              Product pop = Product.popular(
                  'Popular', DesignConfiguration.setSvgPath('popular'));
              catList.insert(0, pop);
              context.read<CategoryProvider>().setSubList(popularList);
            }
          }

          notifyListeners();
        } else {
          setSnackbar(msg!, context);
        }
        catLoading = false;
        notifyListeners();
      },
    );
  }

  Future<void> getSections(
      {bool isnotify = true, required BuildContext context}) async {
    secLoading = true;
    if (isnotify) notifyListeners();

    var parameter = {PRODUCT_LIMIT: '6', PRODUCT_OFFSET: '0'};
    if (context.read<UserProvider>().userId != '') {
    // parameter[USER_ID] = context.read<UserProvider>().userId!;
    }

    await HomeRepository.fetchSections(parameter: parameter).then(
      (result) {
        if (!result['error']) {
          List<SectionModel> tempList = [];

          for (var element in (result['sectionList'] as List)) {
            tempList.add(element);
          }
          sectionList.clear();
          sectionList.addAll(tempList);
          //secLoading = false;
          notifyListeners();
        }
        secLoading = false;
        notifyListeners();
      },
    );
  }

  /* //This method is used to get Categories from server
  Future<void> getSections(BuildContext context) async {
    secLoading = true;
    notifyListeners();
    var parameter = {PRODUCT_LIMIT: '6', PRODUCT_OFFSET: '0'};
    if (context.read<UserProvider>().userId != '') {
      parameter[USER_ID] = context.read<UserProvider>().userId!;
    }
    sectionList.clear();
    await HomeRepository.fetchSections(parameter: parameter).then(
      (result) {
        if (!result['error']) {
          List<SectionModel> tempList = [];

          for (var element in (result['sectionList'] as List)) {
            tempList.add(element);
          }

          sectionList.addAll(tempList);
          //secLoading = false;
          notifyListeners();
        }
        secLoading = false;
        notifyListeners();
      },
    );
  }*/

  //
  //This method is used to get offer Images from server
  Future<void> getOfferImages() async {
    offerLoading = true;
    notifyListeners();

    await HomeRepository.fetchOfferImages().then(
      (result) {
        if (!result['error']) {
          List<Model> tempList = [];

          for (var element in (result['offerImageList'] as List)) {
            tempList.add(element);
          }

          offerImagesList.addAll(tempList);
          offerLoading = false;
          notifyListeners();
        }
      },
    );
  }

  //
  //This method is used to get offer Images from server
  Future<void> getYouMightLikeSectionProducts() async {
    offerLoading = true;
    notifyListeners();

    await HomeRepository.fetchOfferImages().then(
      (result) {
        if (!result['error']) {
          List<Model> tempList = [];

          for (var element in (result['offerImageList'] as List)) {
            tempList.add(element);
          }

          offerImagesList.addAll(tempList);
          offerLoading = false;
          notifyListeners();
        }
      },
    );
  }

  //
  //This method is used to get Most like product
  Future<void> getMostLikeProducts() async {
    mostLikeLoading = true;
    notifyListeners();
    proIds = (await DatabaseHelper().getMostLike())!;

    if (proIds.isNotEmpty) {
      try {
        var parameter = {'product_ids': proIds.join(',')};

        HomeRepository.fetchMostLikeOrFavouriteProducts(parameter).then(
            (value) async {
          if (!value['error']) {
            List<Product> tempList = value['productList'];
            mostLikeProductList.clear();
            mostLikeProductList.addAll(tempList);
          }

          mostLikeLoading = false;
          notifyListeners();
        }, onError: (error) {});
      } catch (e) {}
    } else {
      mostLikeLoading = false;
      mostLikeProductList = [];
      notifyListeners();
    }
  }

  //This method is used to get Most like product
  Future<void> getMostFavouriteProducts() async {
    mostLikeLoading = true;
    notifyListeners();
    proIds1 = (await DatabaseHelper().getMostFav())!;

    if (proIds1.isNotEmpty) {
      try {
        var parameter = {'product_ids': proIds1.join(',')};

        HomeRepository.fetchMostLikeOrFavouriteProducts(parameter).then(
          (value) async {
            if (!value['error']) {
              List<Product> tempList = value['productList'];
              mostFavouriteProductList.clear();
              mostFavouriteProductList.addAll(tempList);
            }

            mostLikeLoading = false;
            notifyListeners();
          },
          onError: (error) {},
        );
      } catch (e) {}
    } else {
      mostLikeLoading = false;
      mostFavouriteProductList = [];
      notifyListeners();
    }
  }

  Future getFav(
    BuildContext context,
  ) async {
    isNetworkAvail = await isNetworkAvailable();
    if (isNetworkAvail) {
      if (context.read<UserProvider>().userId != '') {
        Map<String, dynamic>  parameter = {
          // USER_ID: context.read<UserProvider>().userId,
        };
        apiBaseHelper.postAPICall(getFavApi, parameter).then(
          (getdata) {
            bool error = getdata['error'];
            String? msg = getdata['message'];
            if (!error) {
              var data = getdata['data'];

              List<Product> tempList =
                  (data as List).map((data) => Product.fromJson(data)).toList();

              context.read<FavoriteProvider>().setFavlist(tempList);
            } else {
              if (msg != 'No Favourite(s) Product Are Added') {
                setSnackbar(
                  getTranslated(context, 'No Favourite(s) Product Are Added'),
                  context,
                );
              }
            }
            context.read<FavoriteProvider>().setLoading(false);
          },
          onError: (error) {
            setSnackbar(error.toString(), context);
            context.read<FavoriteProvider>().setLoading(false);
          },
        );
      } else {
        context.read<FavoriteProvider>().setLoading(false);
      }
    } else {
      isNetworkAvail = false;
    }
  }
}
