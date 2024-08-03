import 'package:eshop_multivendor/Model/Section_Model.dart';
import 'package:eshop_multivendor/repository/SingleProductRepository.dart';
import 'package:flutter/cupertino.dart';
import '../Helper/String.dart';
import '../Screen/Product Detail/productDetail.dart';

enum SingleProStatus {
  initial,
  inProgress,
  isSuccsess,
  isFailure,
}

class SingleProProvider extends ChangeNotifier {
  SingleProStatus _SingleProStatus = SingleProStatus.isSuccsess;
  String errorMessage = '';

  get getCurrentStatus => _SingleProStatus;

  changeStatus(SingleProStatus status) {
    _SingleProStatus = status;
    notifyListeners();
  }

  Future<void> getProduct(String proId, int index, int secPos, bool list,
      BuildContext context) async {
    try {
      changeStatus(SingleProStatus.inProgress);
      var parameter = {
        ID: proId,
      };

      var result =
          await SingleProductRepository.getProduct(parameter: parameter);

      bool error = result['error'];

      if (!error) {
        var data = result['data'];

        List<Product> items = [];

        items = (data as List).map((data) => Product.fromJson(data)).toList();
        Navigator.of(context).push(
          CupertinoPageRoute(
            builder: (context) => ProductDetail(
              index: int.parse(proId),
              model: items[0],
              secPos: secPos,
              list: list,
            ),
          ),
        );
      } else {
        //
      }

      changeStatus(SingleProStatus.isSuccsess);
    } catch (e) {
      errorMessage = e.toString();

      changeStatus(SingleProStatus.isFailure);
    }
  }
}
