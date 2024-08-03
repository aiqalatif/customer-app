import 'dart:async';

import 'package:eshop_multivendor/Model/Section_Model.dart';
import 'package:eshop_multivendor/Provider/UserProvider.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import '../Helper/Constant.dart';
import '../Helper/String.dart';
import '../Screen/Language/languageSettings.dart';
import '../repository/FavoriteRepository.dart';
import '../repository/sellerDetailRepositry.dart';
import '../widgets/networkAvailablity.dart';
import '../widgets/security.dart';
import '../widgets/snackbar.dart';

enum SellerDetailProviderStatus {
  initial,
  inProgress,
  isSuccsess,
  isFailure,
  isMoreLoading,
}

class SellerDetailProvider extends ChangeNotifier {
  SellerDetailProviderStatus sellerStatus = SellerDetailProviderStatus.initial;
  List<Product> sellerList = [];
  String errorMessage = '';
  int? totalSellerCount;
  bool hasMoreData = false;
  int sellerListOffset = 0;

  String searchText = '';
  String view = 'GridView';
  String totalProducts = '0';
  List<Product> productList = [];

  get getCurrentStatus => sellerStatus;
  get geterrormessage => errorMessage;
  get sellerListOffsetValue => sellerListOffset;
  get totalSellerCountValue => totalSellerCount;

  get getCurrentView => view;

  changeViewTo(String view) {
    this.view = view;
    notifyListeners();
  }

  get getTotalProducts => totalProducts;

  setProductTotal(String total) {
    totalProducts = total;
    notifyListeners();
  }

  Future<void> setFavorateNow({
    required Function update,
    required BuildContext context,
    required int index,
    required Product model,
    required Function showSanckBarNow,
  }) async {
    isNetworkAvail = await isNetworkAvailable();
    if (isNetworkAvail) {
      try {
        index == -1
            ? model.isFavLoading = true
            : productList[index].isFavLoading = true;
        update();
        var parameter = {
          // USER_ID: context.read<UserProvider>().userId,
          PRODUCT_ID: model.id,
        };
        Map<String, dynamic> result = await FavRepository.setFavorate(
          parameter: parameter,
        );

        showSanckBarNow(
          result,
          model,
          index,
        );
      } on TimeoutException catch (_) {
        setSnackbar(getTranslated(context, 'somethingMSg'), context);
      }
    } else {
      isNetworkAvail = false;
      update();
    }
  }

  removeFav(
    int index,
    Product model,
    BuildContext context,
    Function updateNow,
    List<Product>? productList,
    Function showSanckBarNowForRemove,
  ) async {
    isNetworkAvail = await isNetworkAvailable();
    if (isNetworkAvail) {
      try {
        index == -1
            ? model.isFavLoading = true
            : productList![index].isFavLoading = true;
        updateNow();

        var parameter = {
          // USER_ID: context.read<UserProvider>().userId,
          PRODUCT_ID: model.id,
        };
        Response response =
            await post(removeFavApi, body: parameter, headers: headers).timeout(
          const Duration(seconds: timeOut),
        );
        showSanckBarNowForRemove(
          response,
          index,
          model,
        );
      } on TimeoutException catch (_) {
        setSnackbar(getTranslated(context, 'somethingMSg'), context);
      }
    } else {
      isNetworkAvail = false;
      updateNow();
    }
  }

  setFav(
    int index,
    Product model,
    Function updateNow,
    BuildContext context,
    Function showSanckBarNowForAdd,
  ) async {
    isNetworkAvail = await isNetworkAvailable();
    if (isNetworkAvail) {
      try {
        index == -1
            ? model.isFavLoading = true
            : productList[index].isFavLoading = true;

        updateNow();

        var parameter = {
          // USER_ID: context.read<UserProvider>().userId,
          PRODUCT_ID: model.id
        };
        Response response =
            await post(setFavoriteApi, body: parameter, headers: headers)
                .timeout(const Duration(seconds: timeOut));

        showSanckBarNowForAdd(
          response,
          model,
          index,
        );
      } on TimeoutException catch (_) {
        setSnackbar(getTranslated(context, 'somethingMSg'), context);
      }
    } else {
      isNetworkAvail = false;

      updateNow();
    }
  }

  changeStatus(SellerDetailProviderStatus status) {
    sellerStatus = status;
    notifyListeners();
  }

  setSearchText(value) {
    searchText = value;
    notifyListeners();
  }

  doSellerListEmpty() {
    sellerList = [];
  }

  setOffsetvalue(value) {
    sellerListOffset = value;
    notifyListeners();
  }

  Future<void> getSeller(String sellerId, String search) async {
    try {
      if (!hasMoreData) {
        changeStatus(SellerDetailProviderStatus.inProgress);
      }

      var parameter = {
        LIMIT: perPage.toString(),
        OFFSET: sellerListOffset.toString(),
      };
      if (sellerId != '') {
        parameter[SELLER_ID] = sellerId;
      }
      if (search != '') {
        parameter[SEARCH] = search;
      }

      Map<String, dynamic> result =
          await SellerDetailRepository.fetchSeller(parameter: parameter);
      var data = result['data'];
      bool error = result['error'];
      List<Product> tempSellerList = [];
      tempSellerList.clear();
      if (!error) {
        totalSellerCount = int.parse(result['total']);

        sellerListOffset += perPage;
        tempSellerList =
            (data as List).map((data) => Product.fromSeller(data)).toList();
        sellerList.addAll(tempSellerList);
      }

      changeStatus(SellerDetailProviderStatus.isSuccsess);
    } catch (e) {
      errorMessage = e.toString();
      changeStatus(SellerDetailProviderStatus.isFailure);
    }
  }
}
