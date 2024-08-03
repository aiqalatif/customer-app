import 'dart:async';
import 'package:eshop_multivendor/Model/Section_Model.dart';
import 'package:eshop_multivendor/Provider/UserProvider.dart';
import 'package:eshop_multivendor/repository/Favourite/UpdateFavRepository.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../Helper/Constant.dart';
import '../../Helper/String.dart';
import '../../Screen/Dashboard/Dashboard.dart';
import '../../Screen/Language/languageSettings.dart';
import '../../widgets/networkAvailablity.dart';
import '../../widgets/snackbar.dart';
import '../CartProvider.dart';
import 'FavoriteProvider.dart';

enum UpdateFavStatus {
  initial,
  inProgress,
  isSuccsess,
  isFailure,
}

class UpdateFavProvider extends ChangeNotifier {
  final List<Product> _favList = [];

  UpdateFavStatus _UpFavStatus = UpdateFavStatus.initial;
  String errorMessage = '';

  get getCurrentStatus => _UpFavStatus;

  // new vars for add to cart
  String? cartCount;
  var cart;
  changeStatus(UpdateFavStatus status) {
    _UpFavStatus = status;
    notifyListeners();
  }

  Future<void> addFav(BuildContext context, String id, int from,
      {Product? model}) async {
    try {
      var parameter = {
        PRODUCT_ID: id,
      };

      Map<String, dynamic> result =
          await UpdateFavRepository.addFavorite(parameter: parameter);
      bool error = result['error'];
      String? msg = result['message'];
      if (!error) {
        context.read<FavoriteProvider>().addFavItem(model);
        setSnackbar(msg!, context);
      } else {
        if (from == 1) {
          setSnackbar(msg!, context);
        }
      }

      changeStatus(UpdateFavStatus.isSuccsess);
    } catch (e) {
      errorMessage = e.toString();

      changeStatus(UpdateFavStatus.isFailure);
    }
  }

  Future<void> addToCart(
    int index,
    List<Product> favList,
    BuildContext context,
    String qty,
    int from,
    Function updateNow,
  ) async {
    isNetworkAvail = await isNetworkAvailable();
    if (isNetworkAvail) {
      if (context.read<UserProvider>().userId != '') {
        try {
          updateNow();

          String qty = (int.parse(favList[index].prVarientList![0].cartCount!) +
                  int.parse(favList[index].qtyStepSize!))
              .toString();

          if (int.parse(qty) < favList[index].minOrderQuntity!) {
            qty = favList[index].minOrderQuntity.toString();
            setSnackbar("${getTranslated(context, 'MIN_MSG')}$qty", context);
          }

          var parameter = {
            PRODUCT_VARIENT_ID:
                favList[index].prVarientList![favList[index].selVarient!].id,
            QTY: qty,
          };
          apiBaseHelper.postAPICall(manageCartApi, parameter).then(
            (getdata) {
              bool error = getdata['error'];
              String? msg = getdata['message'];
              if (!error) {
                var data = getdata['data'];

                String? qty = data['total_quantity'];
                cartCount = data['cart_count'];
                favList[index].prVarientList![0].cartCount = qty.toString();
                cart = getdata['cart'];
                List<SectionModel> cartList = (cart as List)
                    .map((cart) => SectionModel.fromCart(cart))
                    .toList();
                context.read<CartProvider>().setCartlist(cartList);
              } else {
                setSnackbar(msg!, context);
              }
              context
                  .read<FavoriteProvider>()
                  .changeStatus(FavStatus.isSuccsess);

              updateNow();
            },
            onError: (error) {
              setSnackbar(error.toString(), context);
            },
          );
        } on TimeoutException catch (_) {
          setSnackbar(getTranslated(context, 'somethingMSg'), context);
          context.read<FavoriteProvider>().changeStatus(FavStatus.isSuccsess);

          updateNow();
        }
      } else {
        context.read<FavoriteProvider>().changeStatus(FavStatus.inProgress);

        updateNow();

        if (from == 1) {
          db.insertCart(
            favList[index].id!,
            favList[index].prVarientList![favList[index].selVarient!].id!,
            qty,
            context,
          );
          setSnackbar(
              getTranslated(context, 'PRODUCT_ADDED_TO_CART_LBL'), context);
        } else {
          if (int.parse(qty) > favList[index].itemsCounter!.length) {
            setSnackbar(
              '${getTranslated(
                context,
                'Max Quantity is',
              )}-${int.parse(qty) - 1}',
              context,
            );
          } else {
            db.updateCart(
              favList[index].id!,
              favList[index].prVarientList![favList[index].selVarient!].id!,
              qty,
            );
            setSnackbar(
                getTranslated(context, 'Cart Update Successfully'), context);
          }
        }
        context.read<FavoriteProvider>().changeStatus(FavStatus.isSuccsess);

        updateNow();
      }
    } else {
      isNetworkAvail = false;

      updateNow();
    }
  }

  Future<void> removeFav(String id, String vId, BuildContext context) async {
    try {
      changeStatus(UpdateFavStatus.inProgress);
      var parameter = {
        PRODUCT_ID: id,
      };

      Map<String, dynamic> result =
          await UpdateFavRepository.removeFavorite(parameter: parameter);
      bool error = result['error'];
      String? msg = result['message'];
      if (!error) {
        context.read<FavoriteProvider>().removeFavItem(vId);
        setSnackbar(msg!, context);
        // showOverlay(msg, context);
      } else {
        setSnackbar(msg!, context);
      }

      changeStatus(UpdateFavStatus.isSuccsess);
    } catch (e) {
      errorMessage = e.toString();

      changeStatus(UpdateFavStatus.isFailure);
    }
  }

  bool _isLoading = true;

  get isLoading => _isLoading;

  get favList => _favList;

  get favIdList => _favList.map((fav) => fav.id).toList();

  setFavID() {
    return _favList.map((fav) => fav.id).toList();
  }

  setLoading(bool isloading) {
    _isLoading = isloading;
    notifyListeners();
  }

  removeFavItem(String id) {
    _favList.removeWhere((item) => item.prVarientList![0].id == id);
    notifyListeners();
  }

  addFavItem(Product? item) {
    if (item != null) {
      _favList.add(item);
      notifyListeners();
    }
  }

  setFavlist(List<Product> favList) {
    _favList.clear();
    _favList.addAll(favList);
    notifyListeners();
  }
}
