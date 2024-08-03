import 'package:flutter/material.dart';
import '../Model/Section_Model.dart';

class ReviewPreviewProvider extends ChangeNotifier {
  //data for review gallery image

  Product? productModel;
  List<dynamic>? imageList;
  int? index;

  get productModelData => productModel;

  get imageListData => imageList;

  get indexData => index;
  setProductModel(Product? value) {
    productModel = value;
    notifyListeners();
  }

  setImageList(List<dynamic>? value) {
    imageList = value;
    notifyListeners();
  }

  setIndex(int? value) {
    index = value;
    notifyListeners();
  }
}
