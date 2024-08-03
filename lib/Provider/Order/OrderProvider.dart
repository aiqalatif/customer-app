import 'package:eshop_multivendor/Provider/UserProvider.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../Helper/Constant.dart';
import '../../Helper/String.dart';
import '../../Model/Order_Model.dart';
import '../../repository/Order/OrderRepository.dart';

enum OrderStatus {
  initial,
  inProgress,
  isSuccsess,
  isFailure,
  isMoreLoading,
}

class OrderProvider extends ChangeNotifier {
  OrderStatus _OrderStatus = OrderStatus.initial;
  List<OrderModel> OrderList = [];
  String errorMessage = '';
  int OrderOffset = 0;
  final int _OrderPerPage = perPage;
  String activeStatus = '';
  bool isNodata = false;

  bool hasMoreData = true;
  bool isGettingdata = false;

  get getCurrentStatus => _OrderStatus;

  changeStatus(OrderStatus status) {
    _OrderStatus = status;
    notifyListeners();
  }

  Future<void> getOrder(
    BuildContext context,
    String searchText,
  ) async {
    try {
      if (hasMoreData) {
        hasMoreData = false;
        isGettingdata = true;
        if (OrderOffset == 0) {
          OrderList = [];
        }
        changeStatus(OrderStatus.inProgress);
        if (context.read<UserProvider>().userId != '') {
          var parameter = {
            LIMIT: _OrderPerPage.toString(),
            OFFSET: OrderOffset.toString(),
            SEARCH: searchText.trim(),
          };
          if (activeStatus != null) {
          if (activeStatus == awaitingPayment) activeStatus = 'awaiting';
          parameter[ACTIVE_STATUS] = activeStatus;
          }

          Map<String, dynamic> result =
              await OrderRepository.fetchOrder(parameter: parameter);
          bool error = result['error'];
          isGettingdata = false;
          if (OrderOffset == 0) isNodata = error;
          if (!error) {
            if (result.isNotEmpty) {
              List<OrderModel> allitems = [];
              List<OrderModel> tempList = [];

              for (var element in (result['orderList'] as List)) {
                tempList.add(element);
              }
              allitems.addAll(tempList);
              for (OrderModel item in tempList) {
                OrderList.where((i) => i.id == item.id).map(
                  (obj) {
                    allitems.remove(item);
                    return obj;
                  },
                ).toList();
              }
              OrderList.addAll(allitems);
              OrderOffset += _OrderPerPage;
              hasMoreData = true;
            } else {
              hasMoreData = false;
            }
            hasMoreData = false;
            changeStatus(OrderStatus.isSuccsess);
          } else {
            changeStatus(OrderStatus.isSuccsess);
          }
        } else {
          hasMoreData = false;
        }
      }
    } catch (e) {
      errorMessage = e.toString();

      changeStatus(OrderStatus.isFailure);
    }
  }
}
