import 'package:flutter/material.dart';
import '../Model/Section_Model.dart';

class ReviewGallaryProvider extends ChangeNotifier {
  //data for review gallery image

  Product? productModel;
  List<dynamic>? imageList;

  get productModelData => productModel;

  get imageListData => imageList;

  setProductModel(Product? value) {
    productModel = value;
    notifyListeners();
  }

  setImageList(List<dynamic>? value) {
    imageList = value;
    notifyListeners();
  }
}
