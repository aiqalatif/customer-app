import 'package:eshop_multivendor/Helper/ApiBaseHelper.dart';
import '../Helper/Constant.dart';
import '../Helper/String.dart';
import '../Model/Model.dart';
import '../Model/Section_Model.dart';

class HomeRepository {
  //This method is used to fetch slider images
  static Future<Map<String, dynamic>> fetchSliderImages() async {
    try {
      var sliderData = await ApiBaseHelper().postAPICall(getSliderApi, {});

      return {
        'error': sliderData['error'],
        'message': sliderData['message'],
        'sliderList': (sliderData['data'] as List)
            .map((data) => Model.fromSlider(data))
            .toList()
      };
    } catch (e) {
      throw ApiException('$errorMesaage${e.toString()}');
    }
  }

  //
  //This method is used to fetch categories
  static Future<Map<String, dynamic>> fetchCategories(
      {required Map<String, dynamic> parameter}) async {
    try {
      var categoryData =
          await ApiBaseHelper().postAPICall(getCatApi, parameter);

      return categoryData;
    } catch (e) {
      throw ApiException('$errorMesaage${e.toString()}');
    }
  }

  //
  //This method is used to fetch sections
  static Future<Map<String, dynamic>> fetchSections(
      {required Map<String, dynamic> parameter}) async {
    try {
      var sectionData =
          await ApiBaseHelper().postAPICall(getSectionApi, parameter);
      print(sectionData['message']);
      return {
        'error': sectionData['error'],
        'message': sectionData['message'],
        'sectionList': (sectionData['data'] as List)
            .map((data) => SectionModel.fromJson(data))
            .toList()
      };
    } catch (e) {
      throw ApiException('$errorMesaage${e.toString()}');
    }
  }

  //
  //This method is used to fetch offer images
  static Future<Map<String, dynamic>> fetchOfferImages() async {
    try {
      var offerImageData =
          await ApiBaseHelper().postAPICall(getOfferImageApi, {});

      return {
        'error': offerImageData['error'],
        'message': offerImageData['message'],
        'offerImageList': (offerImageData['data'] as List)
            .map((data) => Model.fromSlider(data))
            .toList()
      };
    } catch (e) {
      throw ApiException('$errorMesaage${e.toString()}');
    }
  }

  //
//This method is used to get most like products
  static Future<Map<String, dynamic>> fetchMostLikeOrFavouriteProducts(
      Map<String, dynamic> parameter) async {
    try {
      var mostLikeProductData =
          await ApiBaseHelper().postAPICall(getProductApi, parameter);

      return {
        'error': mostLikeProductData['error'],
        'message': mostLikeProductData['message'],
        'productList': (mostLikeProductData['data'] as List)
            .map((data) => Product.fromJson(data))
            .toList()
      };
    } catch (e) {
      throw ApiException('$errorMesaage${e.toString()}');
    }
  }
}
