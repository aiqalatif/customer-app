import 'dart:async';
import 'package:eshop_multivendor/Provider/UserProvider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Helper/Constant.dart';
import '../../Helper/String.dart';
import '../../Screen/SQLiteData/SqliteData.dart';
import '../../Model/Section_Model.dart';
import '../../repository/SearchRepository.dart';
import '../../Screen/Language/languageSettings.dart';
import '../../widgets/networkAvailablity.dart';
import '../../widgets/snackbar.dart';
import '../ProductProvider.dart';
import '../homePageProvider.dart';

enum SearchStatus {
  initial,
  inProgress,
  isSuccsess,
  isFailure,
  isMoreLoading,
}

class SearchProvider extends ChangeNotifier {
  SearchStatus _SearchStatus = SearchStatus.initial;
  bool notificationisloadmore = true,
      notificationisgettingdata = false,
      notificationisnodata = false;
  int notificationoffset = 0;
  String query = '';
  List<Product> productList = [];
  List<Product> history = [];
  String errorMessage = '';
  int SellerOffset = 0;
  final int _SellerPerPage = perPage;
  List<Product> sellerList = [];
  List<String> tagList = [];

  int totalSellerCount = 0;

  bool hasMoreData = true;
  var db = DatabaseHelper();

  get getCurrentStatus => _SearchStatus;

  changeStatus(SearchStatus status) {
    _SearchStatus = status;
    notifyListeners();
  }

  Future getSearch(Function updateNow, BuildContext context) async {
    isNetworkAvail = await isNetworkAvailable();
    if (isNetworkAvail) {
      try {
        if (notificationisloadmore) {
          notificationisloadmore = false;
          notificationisgettingdata = true;
          updateNow();
          var parameter = {
            SEARCH: query.trim(),
            LIMIT: perPage.toString(),
            OFFSET: notificationoffset.toString(),
          };

          // if (context.read<UserProvider>().userId != '') {
          // parameter[USER_ID] = context.read<UserProvider>().userId!;
          // }

          Map<String, dynamic> getdata =
              await SearchRepository.fetchSearch(parameter: parameter);

          bool error = getdata['error'];

          Map<String, dynamic> tempData = getdata;
          if (tempData.containsKey(TAG)) {
            List<String> tempList = List<String>.from(getdata[TAG]);

            if (tempList.isNotEmpty) tagList = tempList;
          }

          String? search = getdata['search'];

          notificationisgettingdata = false;
          if (notificationoffset == 0) notificationisnodata = error;

          if (!error && search!.trim() == query.trim()) {
            Future.delayed(
              Duration.zero,
              () {
                List mainlist = getdata['data'];
                if (mainlist.isNotEmpty) {
                  List<Product> items = [];
                  List<Product> allitems = [];
                  items.addAll(
                      mainlist.map((data) => Product.fromJson(data)).toList());
                  allitems.addAll(items);
                  getAvailVarient(
                    allitems,
                    context,
                    updateNow,
                  );
                } else {
                  notificationisloadmore = false;
                }
                updateNow();
              },
            );
          } else {
            notificationisloadmore = false;
            updateNow();
          }
        }
      } on TimeoutException catch (_) {
        setSnackbar(
          getTranslated(context, 'somethingMSg'),
          context,
        );
        notificationisloadmore = false;
        updateNow();
      }
    } else {
      isNetworkAvail = false;
      updateNow();
    }
  }

  void getAvailVarient(
    List<Product> tempList,
    BuildContext context,
    Function updateNow,
  ) async {
    for (int j = 0; j < tempList.length; j++) {
      if (tempList[j].stockType == '2') {
        for (int i = 0; i < tempList[j].prVarientList!.length; i++) {
          if (tempList[j].prVarientList![i].availability == '1') {
            tempList[j].selVarient = i;
            break;
          }
        }
      }
    }
    if (notificationoffset == 0) {
      productList = [];
    }

    // if (notificationoffset == 0 && !buildResult) {
    //   Product element = Product(
    //       name: 'Search Result for "$query"',
    //       image: '',
    //       catName: 'All Categories',
    //       history: false);
    //   productList.insert(0, element);
    //   for (int i = 0; i < history.length; i++) {
    //     if (history[i].name == query) productList.insert(0, history[i]);
    //   }
    // }

    productList.addAll(tempList);
    int p = 0;

    for (int j = 0; j < productList.length; j++) {
      bool? check = await db.checkMostLikeExists(productList[j].id ?? '');

      if (p < 5) {
        if (!(check ?? false)) {
          p = p + 1;
          await db.addMostLike(productList[j].id ?? '');
        }
      }
    }

    await getMostLikePro(context, updateNow);

    notificationisloadmore = true;
    notificationoffset = notificationoffset + perPage;
  }

  Future<void> getMostLikePro(BuildContext context, Function updateNow) async {
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
              context.read<HomePageProvider>().mostLikeLoading = false;

              updateNow();
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
        isNetworkAvail = false;
        context.read<HomePageProvider>().mostLikeLoading = false;
        updateNow();
      }
    } else {
      context.read<ProductProvider>().setProductList([]);

      context.read<HomePageProvider>().mostLikeLoading = false;
      updateNow();
    }
  }

  Future<void> getSeller(String search) async {
    try {
      var parameter = {
        LIMIT: _SellerPerPage.toString(),
        OFFSET: SellerOffset.toString(),
      };
      if (search.isNotEmpty) {
        parameter = {
          SEARCH: search,
        };
      }

      Map<String, dynamic> result =
          await SearchRepository.fetchSeller(parameter: parameter);

      if (result['error'] as bool == false) {
        totalSellerCount = int.parse(result['totalSeller']);

        List<Product> tempList = [];

        for (var element in (result['sellerList'] as List)) {
          tempList.add(element);
        }

        sellerList.addAll(tempList);

        if (int.parse(result['totalSeller']) > SellerOffset) {
          SellerOffset += _SellerPerPage;
          hasMoreData = true;
        } else {
          hasMoreData = false;
        }
        changeStatus(SearchStatus.isSuccsess);
      } else {
        changeStatus(SearchStatus.isSuccsess);
      }
    } catch (e) {
      errorMessage = e.toString();

      changeStatus(SearchStatus.isFailure);
    }
  }
}
