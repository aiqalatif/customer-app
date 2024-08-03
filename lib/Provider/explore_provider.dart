import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import '../Helper/Constant.dart';
import '../Helper/String.dart';
import '../Model/Section_Model.dart';
import '../repository/FavoriteRepository.dart';
import '../Screen/Language/languageSettings.dart';
import '../widgets/networkAvailablity.dart';
import '../widgets/security.dart';
import '../widgets/snackbar.dart';
import 'UserProvider.dart';

class ExploreProvider extends ChangeNotifier {
  String view = 'GridView';
  String totalProducts = '0';
  List<Product> productList = [];

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
}
