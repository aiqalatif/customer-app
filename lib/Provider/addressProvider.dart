import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Helper/Constant.dart';
import '../Helper/String.dart';
import '../Model/User.dart';
import '../repository/addressRepositry.dart';
import '../Screen/Language/languageSettings.dart';
import '../widgets/snackbar.dart';
import 'CartProvider.dart';

class AddressProvider extends ChangeNotifier {
  StateSetter? updateCityDialogState;
  StateSetter? updateZipcodeDialogState;

  String? latitude,
      longitude,
      state,
      name,
      type = 'Home',
      mobile,
      city,
      address,
      zipcode,
      landmark,
      altMob,
      area,
      country,
      selectedCity = '',
      selectedZipcode = '',
      cityName,
      areaName,
      zipcodeName;
  int zipcodeOffset = 0;
  int? selCityPos = -1;
  bool cityLoading = true;
  bool checkedDefault = false;
  bool? isLoadingMoreCity;
  bool isProgress = false;
  List<User> zipcodeSearchList = [];
  List<User> zipcodeList = [];
  AnimationController? buttonController;
  List<User> citySearchLIst = [];
  List<User> cityList = [];
  User? selZipcode;
  int _index = 0;
  //int? selAreaPos = -1;
  bool? isLoadingMoreZipcode;

  //StateSetter? areaState;
  //StateSetter? cityState;
  bool zipcodeLoading = true;
  final TextEditingController cityController = TextEditingController();
  final TextEditingController zipcodeController = TextEditingController();
  TextEditingController? zipcodeC;
  bool isZipcode = false;
  int cityOffset = 0;
  bool cityEnable = false, zipcodeEnable = false;

  setZipcodeSetter(StateSetter stateSetter) {
    updateZipcodeDialogState = stateSetter;
  }

  int get getaddresscheck => _index;

  void setAddresscheck(int index){
    _index = index;
  }

  setCitySetter(StateSetter stateSetter) {
    updateCityDialogState = stateSetter;
  }

  setLatitude(String? value) {
    latitude = value;
    notifyListeners();
  }

  setLongitude(String? value) {
    longitude = value;
    notifyListeners();
  }

  setStateValue(String? value) {
    state = value;
    notifyListeners();
  }

  setCountry(String? value) {
    country = value;
    notifyListeners();
  }

  Future<void> getZipcode(
      String? city,
      bool clear,
      bool isSearchZipcode,
      BuildContext context,
      StateSetter setState,
      bool? update,
      int? index) async {
    try {
      var parameter = {
        ID: city,
        OFFSET: zipcodeOffset.toString(),
        LIMIT: perPage.toString()
      };

      if (isSearchZipcode) {
        parameter[SEARCH] = zipcodeController.text;
        parameter[OFFSET] = '0';
        zipcodeOffset = 0;
        zipcodeList.clear();
        zipcodeLoading = true;
        zipcodeSearchList.clear();
      }
      dynamic result = await AddressRepository.getZipcode(parameter: parameter);

      bool error = result['error'];
      String? msg = result['message'];
      // areaTotal = int.parse(result["total"]);
      if (!error) {
        var data = result['data'];
        zipcodeList.clear();
        if (clear) {
          zipcode = null;
          selZipcode = null;
          zipcodeSearchList.clear();
        }
        zipcodeList =
            (data as List).map((data) => User.fromJson(data)).toList();


        zipcodeSearchList.addAll(zipcodeList);

        if (update!) {
          for (User item in context.read<CartProvider>().addressList) {
            for (int i = 0; i < zipcodeSearchList.length; i++) {
              if (context.read<CartProvider>().selAddress == item.id) {
                if (zipcodeSearchList[i].zipcode == item.pincode) {
                  selZipcode = zipcodeSearchList[i];
                  // selAreaPos = i;
                  if (context
                          .read<CartProvider>()
                          .addressList[index!]
                          .systemZipcode !=
                      '0') {
                    selectedZipcode = zipcodeSearchList[i].zipcode!;
                  }
                  // selectedZipcode = zipcodeSearchList[i].name!;
                } else {
                  selZipcode = null;
                  //selAreaPos = -1;
                  selectedZipcode = null;
                }
              }
            }
          }
        }

        print(
            'zipcodeSearchList****${zipcodeSearchList.length}*******${zipcodeSearchList[0].id}****${zipcodeSearchList[0].zipcode}');
        zipcodeOffset += perPage;
      } else {
        if (msg != null) {
          setSnackbar(msg, context);
        }
      }
      zipcodeLoading = false;
      isLoadingMoreZipcode = false;

      /* if (areaState != null) {
        areaState!(
          () {},
        );
      }*/
      isZipcode = true;
      Future.microtask(() {
        updateZipcodeDialogState?.call(() {});
      });
      setState(() {});
    } on TimeoutException catch (_) {
      setSnackbar(getTranslated(context, 'somethingMSg'), context);
    }
  }
  

  Future<void> getCities(
    bool isSearchCity,
    BuildContext context,
    StateSetter setState,
    bool? update,
    int? index,
  ) async {
    try {
      var parameter = {
        LIMIT: perPage.toString(),
        OFFSET: cityOffset.toString(),
      };

      if (isSearchCity) {
        parameter[SEARCH] = cityController.text;
        parameter[OFFSET] = '0';
        cityOffset = 0;
        cityList.clear();
        cityLoading = true;
        citySearchLIst.clear();
      }
      dynamic result = await AddressRepository.getCitys(
        parameter: parameter,
      );

      bool error = result['error'];
      String? msg = result['message'];

      if (!error) {
        var data = result['data'];
        cityList = (data as List).map((data) => User.fromJson(data)).toList();
        citySearchLIst.addAll(cityList);
        cityOffset += perPage;
      } else {
        if (msg != null) {
          setSnackbar(msg, context);
        }
      }
      cityLoading = false;
      isLoadingMoreCity = false;
      isProgress = false;

      // if (cityState != null) cityState!(() {});

      if (update!) {
        selCityPos = citySearchLIst.indexWhere((f) =>
            f.id == context.read<CartProvider>().addressList[index!].cityId);

        if (selCityPos == -1) {
          selCityPos = null;
        } else {
          selectedCity = citySearchLIst[selCityPos!].name!;
        }
      }

      Future.microtask(() {
        updateCityDialogState?.call(() {});
      });
      setState(() {});
    } on TimeoutException catch (_) {
      setSnackbar(getTranslated(context, 'somethingMSg'), context);
    }
  }

  Future<void> addNewAddress(BuildContext context, Function updateNow,
      bool? update, int index, bool fromProfile) async {
    isProgress = true;
    updateNow();
    try {
      var parameter = {
        // USER_ID: context.read<SettingProvider>().userId,
        NAME: name,
        MOBILE: mobile,
        //PINCODE: pincodeC!.text,
        //CITY_ID: city,
        //AREA_ID: area,
        ADDRESS: address,
        STATE: state,
        COUNTRY: country,
        TYPE: type,
        ISDEFAULT: checkedDefault.toString() == 'true' ? '1' : '0',
        LATITUDE: latitude,
        LONGITUDE: longitude,
        GEN_AREA_NAME: areaName
      };
      if (update!) {
        parameter[ID] = context.read<CartProvider>().addressList[index].id;
      }
      if (cityName != null) {
        parameter['city_name'] = cityName;
        parameter[CITY_ID] = '0';
      } else {
        parameter[CITY_ID] = city;
        parameter['city_name'] = selectedCity;
      }

      if (zipcodeName != null) {
        parameter['pincode_name'] = zipcodeC!.text;
        // parameter[SYSTEM_PINCODE] = '0';
      } else {
        if(zipcode == null){
          parameter['pincode'] = '';
        }else{parameter['pincode'] = zipcode;}
        
        
        //parameter[SYSTEM_PINCODE] = '1';
      }

      dynamic result = await AddressRepository.addAndUpdateAddress(
        parameter: parameter,
        update: update,
      );
      bool error = result['error'];
      String? msg = result['message'];

      await buttonController!.reverse();

      if (!error) {
        context.read<CartProvider>().isAddressChange = true;
        var data = result['data'];

        if (update) {
          if (checkedDefault.toString() == 'true' ||
              context.read<CartProvider>().addressList.length == 1) {
            for (User i in context.read<CartProvider>().addressList) {
              i.isDefault = '0';
            }

            context.read<CartProvider>().addressList[index].isDefault = '1';
            if (IS_SHIPROCKET_ON == '0') {
              if (!ISFLAT_DEL) {
                if (context.read<CartProvider>().oriPrice <
                    double.parse(context
                        .read<CartProvider>()
                        .addressList[
                            context.read<CartProvider>().selectedAddress!]
                        .freeAmt!)) {
                  context.read<CartProvider>().deliveryCharge = double.parse(
                      context
                          .read<CartProvider>()
                          .addressList[
                              context.read<CartProvider>().selectedAddress!]
                          .deliveryCharge!);
                } else {
                  context.read<CartProvider>().deliveryCharge = 0;
                }

                context.read<CartProvider>().totalPrice =
                    context.read<CartProvider>().totalPrice -
                        context.read<CartProvider>().deliveryCharge;
              }
            }

            User value = User.fromAddress(data[0]);

            context.read<CartProvider>().addressList[index] = value;

            context.read<CartProvider>().selectedAddress = index;
            context.read<CartProvider>().selAddress =
                context.read<CartProvider>().addressList[index].id;
            if (IS_SHIPROCKET_ON == '0') {
              if (!ISFLAT_DEL) {
                if (context.read<CartProvider>().oriPrice <
                    double.parse(context
                        .read<CartProvider>()
                        .addressList[
                            context.read<CartProvider>().selectedAddress!]
                        .freeAmt!)) {
                  context.read<CartProvider>().deliveryCharge = double.parse(
                      context
                          .read<CartProvider>()
                          .addressList[
                              context.read<CartProvider>().selectedAddress!]
                          .deliveryCharge!);
                } else {
                  context.read<CartProvider>().deliveryCharge = 0;
                }
                context.read<CartProvider>().totalPrice =
                    context.read<CartProvider>().totalPrice +
                        context.read<CartProvider>().deliveryCharge;
              }
            }
          }
        } else {
          User value = User.fromAddress(data[0]);
          context.read<CartProvider>().addressList.add(value);

          if (checkedDefault.toString() == 'true' ||
              context.read<CartProvider>().addressList.length == 1) {
            for (User i in context.read<CartProvider>().addressList) {
              i.isDefault = '0';
            }

            context.read<CartProvider>().addressList[index].isDefault = '1';

            if (IS_SHIPROCKET_ON == '0') {
              if (!ISFLAT_DEL &&
                  context.read<CartProvider>().addressList.length != 1) {
                if (context.read<CartProvider>().oriPrice <
                    double.parse(context
                        .read<CartProvider>()
                        .addressList[
                            context.read<CartProvider>().selectedAddress!]
                        .freeAmt!)) {
                  context.read<CartProvider>().deliveryCharge = double.parse(
                      context
                          .read<CartProvider>()
                          .addressList[
                              context.read<CartProvider>().selectedAddress!]
                          .deliveryCharge!);
                } else {
                  context.read<CartProvider>().deliveryCharge = 0;
                }

                context.read<CartProvider>().totalPrice =
                    context.read<CartProvider>().totalPrice -
                        context.read<CartProvider>().deliveryCharge;
              }
            }

            context.read<CartProvider>().selectedAddress = index;
            context.read<CartProvider>().selAddress =
                context.read<CartProvider>().addressList[index].id;
            if (IS_SHIPROCKET_ON == '0') {
              if (!ISFLAT_DEL) {
                if (context.read<CartProvider>().totalPrice <
                    double.parse(context
                        .read<CartProvider>()
                        .addressList[
                            context.read<CartProvider>().selectedAddress!]
                        .freeAmt!)) {
                  context.read<CartProvider>().deliveryCharge = double.parse(
                      context
                          .read<CartProvider>()
                          .addressList[
                              context.read<CartProvider>().selectedAddress!]
                          .deliveryCharge!);
                } else {
                  context.read<CartProvider>().deliveryCharge = 0;
                }
                context.read<CartProvider>().totalPrice =
                    context.read<CartProvider>().totalPrice +
                        context.read<CartProvider>().deliveryCharge;
              }
            }
          }
        }
        isProgress = false;

        updateNow();
        /* if (!fromProfile) {
          context
              .read<CartProvider>()
              .checkDeliverable(updateNow, context, true);
        } else {*/
        Navigator.of(context).pop();
        /*}*/
      } else {
        setSnackbar(msg!, context);
      }
    } on TimeoutException catch (_) {
      setSnackbar(
        getTranslated(context, 'somethingMSg'),
        context,
      );
    }
  }
}
