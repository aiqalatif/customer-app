import 'dart:async';
import 'package:eshop_multivendor/Provider/UserProvider.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../Helper/Constant.dart';
import '../Helper/String.dart';
import '../Model/Model.dart';
import '../repository/customerSupportRepositry.dart';
import '../Screen/Language/languageSettings.dart';
import '../widgets/networkAvailablity.dart';
import '../widgets/snackbar.dart';

class CustomerSupportProvider extends ChangeNotifier {
  bool isProgress = false;
  bool isLoading = true;
  String? type, email, title, desc, status, id;
  bool edit = false;
  bool show = false;
  TextEditingController emailController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController descController = TextEditingController();
  List<Model> ticketList = [];
  FocusNode? nameFocus, emailFocus, descFocus;
  List<Model> typeList = [];
  List<Model> tempList = [];
  bool isLoadingmore = true;
  int curEdit = -1;
  int offset = 0;
  int total = 0;
  Future<void> sendRequest(
    Function updateNow,
    BuildContext context,
  ) async {
    isProgress = true;
    updateNow();

    try {
      var parameter = {
        // USER_ID: context.read<UserProvider>().userId,
        SUB: title,
        DESC: desc,
        TICKET_TYPE: type,
        EMAIL: email,
      };
      if (edit) {
        parameter[TICKET_ID] = id;
        parameter[STATUS] = status;
      }
      dynamic result = await CustomerSupportRepository.editOrAddAPI(
        parameter: parameter,
        edit: edit,
      );

      bool error = result['error'];
      String msg = result['message'];
      if (!error) {
        var data = result['data'];
        if (edit) {
          ticketList[curEdit] = Model.fromTicket(data[0]);
        } else {
          ticketList.add(Model.fromTicket(data[0]));
        }
        updateNow();
      }
      setSnackbar(msg, context);
      edit = false;
      isProgress = false;
      clearAll(context);
      updateNow();
    } on TimeoutException catch (_) {
      setSnackbar(getTranslated(context, 'somethingMSg'), context);
    }
  }

  clearAll(context) {
    type = null;
    email = null;
    title = null;
    desc = null;
    emailController.clear();
    descController.clear();
    nameController.clear();
    FocusScope.of(context).unfocus();
  }

  Future<void> getType(
    BuildContext context,
    Function updateNow,
  ) async {
    isNetworkAvail = await isNetworkAvailable();
    if (isNetworkAvail) {
      try {
        dynamic result = await CustomerSupportRepository.getType();

        bool error = result['error'];
        String? msg = result['message'];
        if (!error) {
          var data = result['data'];
          typeList =
              (data as List).map((data) => Model.fromSupport(data)).toList();
        } else {
          setSnackbar(
            msg!,
            context,
          );
        }
        isLoading = false;
        updateNow();
      } on TimeoutException catch (_) {
        setSnackbar(
          getTranslated(context, 'somethingMSg'),
          context,
        );
      }
    } else {
      isNetworkAvail = false;
      updateNow();
    }
  }

  Future<void> getTicket(
    BuildContext context,
    Function updateNow,
  ) async {
    isNetworkAvail = await isNetworkAvailable();
    if (isNetworkAvail) {
      try {
        var parameter = {
          // USER_ID: context.read<UserProvider>().userId,
          LIMIT: perPage.toString(),
          OFFSET: offset.toString(),
        };
        dynamic result =
            await CustomerSupportRepository.getTicket(parameter: parameter);

        bool error = result['error'];
        String? msg = result['message'];
        if (!error) {
          total = int.parse(result['total']);

          if ((offset) < total) {
            tempList.clear();
            var data = result['data'];
            tempList =
                (data as List).map((data) => Model.fromTicket(data)).toList();

            ticketList.addAll(tempList);

            offset = offset + perPage;
          }
        } else {
          if (msg != 'Ticket(s) does not exist') {
            setSnackbar(
              msg!,
              context,
            );
          }
          isLoadingmore = false;
        }
        isLoading = false;
        updateNow();
      } on TimeoutException catch (_) {
        setSnackbar(
          getTranslated(context, 'somethingMSg'),
          context,
        );
      }
    } else {
      isNetworkAvail = false;
      updateNow();
    }
  }
}
