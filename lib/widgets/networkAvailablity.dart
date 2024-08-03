
// global netWork Variable

import 'package:connectivity_plus/connectivity_plus.dart';

bool isNetworkAvail = true;

//checking the network
Future<bool> isNetworkAvailable() async {
  var connectivityResult = await (Connectivity().checkConnectivity());
  if (connectivityResult == ConnectivityResult.mobile) {
    return true;
  } else if (connectivityResult == ConnectivityResult.wifi) {
    return true;
  }
  return false;
}
