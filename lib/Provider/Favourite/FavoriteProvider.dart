import 'dart:async';
import 'package:eshop_multivendor/repository/FavoriteRepository.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Helper/String.dart';
import '../../Model/Section_Model.dart';
import '../../Screen/Dashboard/Dashboard.dart';
import '../../Screen/Language/languageSettings.dart';
import '../../widgets/networkAvailablity.dart';
import '../../widgets/snackbar.dart';
import '../UserProvider.dart';

enum FavStatus {
  initial,
  inProgress,
  isSuccsess,
  isFailure,
  isMoreLoading,
}

class FavoriteProvider extends ChangeNotifier {
  FavStatus _favStatus = FavStatus.initial;
  List<Product> favoriteList = [];
  String errorMessage = '';
  final List<TextEditingController> controllerText = [];

  bool hasMoreData = false;

  get getCurrentStatus => _favStatus;

  changeStatus(FavStatus status) {
    _favStatus = status;
    notifyListeners();
  }

  Future<void> getFav(
      {required bool isLoadingMore, required BuildContext context}) async {
    try {
      if (isLoadingMore) {
        favoriteList.clear();
        changeStatus(FavStatus.inProgress);
      }
      Map<String, dynamic>  parameter = {
      };

      Map<String, dynamic> result =
          await FavRepository.fetchFavorite(parameter: parameter);
      List<Product> tempList = [];

      for (var element in (result['favList'] as List)) {
        tempList.add(element);
      }
      favoriteList.addAll(tempList);
      changeStatus(FavStatus.isSuccsess);
    } catch (e) {
      errorMessage = e.toString();

      changeStatus(FavStatus.isFailure);
    }
  }

  bool _isLoading = true;

  get isLoading => _isLoading;

  get favIdList => favoriteList.map((fav) => fav.id).toList();

  setFavID() {
    return favoriteList.map((fav) => fav.id).toList();
  }

  setLoading(bool isloading) {
    _isLoading = isloading;
    notifyListeners();
  }

  removeFavItem(String id) {
    favoriteList.removeWhere((item) => item.prVarientList![0].id == id);

    notifyListeners();
  }

  addFavItem(Product? item) {
    if (item != null) {
      favoriteList.add(item);
      notifyListeners();
    }
  }

  setFavlist(List<Product> favList) {
    favoriteList.clear();
    favoriteList.addAll(favList);
    notifyListeners();
  }

  Future<void> getOfflineFavorateProducts(
    BuildContext context,
    Function update,
  ) async {
    if (context.read<UserProvider>().userId == '') {
      List<String>? proIds = (await db.getFav())!;
      if (proIds.isNotEmpty) {
        isNetworkAvail = await isNetworkAvailable();

        if (isNetworkAvail) {
          try {
            var parameter = {'product_ids': proIds.join(',')};
            Map<String, dynamic> result =
                await FavRepository.setOfflineFavorateProducts(
                    parameter: parameter);
            bool error = result['error'];

            if (!error) {
              var data = result['data'];

              List<Product> tempList =
                  (data as List).map((data) => Product.fromJson(data)).toList();

              setFavlist(tempList);
            }
            setLoading(false);

            update();
          } on TimeoutException catch (_) {
            setSnackbar(getTranslated(context, 'somethingMSg'), context);
            setLoading(false);
          }
        } else {
          isNetworkAvail = false;
          setLoading(false);
          update();
        }
      } else {
        setFavlist([]);
        setLoading(false);
        update();
      }
    }
  }
}
