import 'package:eshop_multivendor/Helper/Constant.dart';
import 'package:eshop_multivendor/Screen/Language/languageSettings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../Helper/Color.dart';
import '../../../Helper/String.dart';
import '../../../Helper/routes.dart';
import '../../../Model/Notification_Model.dart';
import '../../../Provider/SingleProductProvider.dart';
import '../../../widgets/desing.dart';
import '../../../widgets/snackbar.dart';

class NotiListData extends StatelessWidget {
  int index;
  List<NotificationModel> notiList;

  NotiListData({Key? key, required this.index, required this.notiList})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    NotificationModel model = notiList[index];
    return InkWell(
      onTap: () {
        if (model.type == 'products') {
          Future.delayed(Duration.zero).then((value) => context
              .read<SingleProProvider>()
              .getProduct(model.typeId!, 0, 0, true, context));
        } else if (model.type == 'categories') {
          Navigator.of(context).pop(true);
        } else if (model.type == 'wallet') {
          Routes.navigateToMyWalletScreen(context);
        } else if (model.type == 'order') {
          Routes.navigateToMyOrderScreen(context);
        } else if (model.type == 'ticket_message') {
          Routes.navigateToChatScreen(context, model.id, '');
        } else if (model.type == 'ticket_status') {
          Routes.navigateToCustomerSupportScreen(context);
        } else {
          setSnackbar(
              getTranslated(context, 'It is a normal Notification'), context);
        }
      },
      child: Container(
        color: Theme.of(context).colorScheme.white,
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.all(10),
        child: Row(
          children: <Widget>[
            model.img != null && model.img != ''
                ? GestureDetector(
                    child: SizedBox(
                      width: 50,
                      height: 50,
                      child: Hero(
                        tag: '$heroTagUniqueString ${model.id!}',
                        child: CircleAvatar(
                          backgroundImage: NetworkImage(
                            model.img!,
                          ),
                          radius: 25,
                        ),
                      ),
                    ),
                    onTap: () {
                      Navigator.of(context).push(
                        PageRouteBuilder(
                          opaque: false,
                          barrierDismissible: true,
                          pageBuilder: (BuildContext context, _, __) {
                            return AlertDialog(
                              elevation: 0,
                              contentPadding: const EdgeInsets.all(0),
                              backgroundColor: Colors.transparent,
                              content: Hero(
                                tag: '$heroTagUniqueString ${model.id!}',
                                child: DesignConfiguration.getCacheNotworkImage(
                                  boxFit: null,
                                  context: context,
                                  heightvalue: null,
                                  widthvalue: null,
                                  imageurlString: model.img!,
                                  placeHolderSize: 150,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  )
                : Container(
                    height: 0,
                  ),
            const SizedBox(
              width: 10,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Text(
                      model.title!,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: 'ubuntu',
                        fontSize: textFontSize16,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 2,
                  ),
                  Text(
                    model.desc!,
                    style: const TextStyle(
                      fontFamily: 'ubuntu',
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    model.date!,
                    style: TextStyle(
                        fontFamily: 'ubuntu',
                        fontSize: textFontSize10,
                        color: Theme.of(context)
                            .colorScheme
                            .fontColor
                            .withOpacity(0.4)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
