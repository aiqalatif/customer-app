import 'package:eshop_multivendor/Helper/ApiBaseHelper.dart';
import 'package:eshop_multivendor/Helper/Constant.dart';
import 'package:eshop_multivendor/Helper/String.dart';
import 'package:eshop_multivendor/Model/brandModel.dart';

class BrandsRepository {
  Future<List<BrandData>> getAllBrands() async {
    try {
      var responseData = await ApiBaseHelper().postAPICall(getBrandsApi, {});
      return responseData['data']
          .map<BrandData>((e) => BrandData.fromJson(e))
          .toList();
    } on Exception catch (e) {
      throw ApiException('$errorMesaage${e.toString()}');
    }
  }
}
