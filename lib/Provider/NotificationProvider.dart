import 'package:eshop_multivendor/Model/Notification_Model.dart';
import 'package:flutter/material.dart';
import '../Helper/Constant.dart';
import '../Helper/String.dart';
import '../repository/NotificationRepository.dart';

enum NotificationStatus {
  initial,
  inProgress,
  isSuccsess,
  isFailure,
  isMoreLoading,
}

class NotificationProvider extends ChangeNotifier {
  NotificationStatus _NotificationStatus = NotificationStatus.initial;
  List<NotificationModel> notificationList = [];
  String errorMessage = '';
  int _notificationListOffset = 0;
  final int _notificationPerPage = perPage;

  bool hasMoreData = false;

  get getCurrentStatus => _NotificationStatus;

  changeStatus(NotificationStatus status) {
    _NotificationStatus = status;
    notifyListeners();
  }

  Future<void> getNotification({required bool isLoadingMore}) async {
    try {
      if (isLoadingMore) {
        changeStatus(NotificationStatus.inProgress);
      }

      var parameter = {
        LIMIT: _notificationPerPage.toString(),
        OFFSET: _notificationListOffset.toString(),
      };

      Map<String, dynamic> result =
          await NotificationRepository.fetchNotification(parameter: parameter);
      List<NotificationModel> tempList = [];

      for (var element in (result['notiList'] as List)) {
        tempList.add(element);
      }

      notificationList.addAll(tempList);

      if (int.parse(result['totalNoti']) > _notificationListOffset) {
        _notificationListOffset += _notificationPerPage;
        hasMoreData = true;
      } else {
        hasMoreData = false;
      }
      changeStatus(NotificationStatus.isSuccsess);
    } catch (e) {
      errorMessage = e.toString();

      changeStatus(NotificationStatus.isFailure);
    }
  }
}
