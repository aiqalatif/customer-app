import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../Helper/Constant.dart';
import '../../../Helper/String.dart';
import '../../../Model/Section_Model.dart';
import '../../../Provider/SettingProvider.dart';
import '../../../widgets/desing.dart';
import '../../Product Detail/productDetail.dart';
import '../Search.dart';

class SuggestionList extends StatelessWidget {
  const SuggestionList({
    Key? key,
    this.suggestions,
    this.textController,
    this.searchDelegate,
    this.notificationcontroller,
    this.getProduct,
    this.clearAll,
  }) : super(key: key);

  final List<Product>? suggestions;
  final TextEditingController? textController;

  final notificationcontroller;
  final SearchDelegate<Product>? searchDelegate;
  final Function? getProduct, clearAll;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: suggestions!.length,
      shrinkWrap: true,
      controller: notificationcontroller,
      separatorBuilder: (BuildContext context, int index) => const Divider(),
      itemBuilder: (BuildContext context, int i) {
        final Product suggestion = suggestions![i];

        return ListTile(
          title: Text(
            suggestion.name!,
            style: Theme.of(context).textTheme.titleSmall!.copyWith(
                  color: Theme.of(context).colorScheme.lightBlack,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'ubuntu',
                ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: textController!.text.toString().trim().isEmpty ||
                  suggestion.history!
              ? null
              : Text(
                  'In ${suggestion.catName!}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.fontColor,
                    fontFamily: 'ubuntu',
                  ),
                ),
          leading: textController!.text.toString().trim().isEmpty ||
                  suggestion.history!
              ? const Icon(Icons.history)
              : ClipRRect(
                  borderRadius: BorderRadius.circular(circularBorderRadius7),
                  child: suggestion.image == ''
                      ? Image.asset(
                          DesignConfiguration.setPngPath('placeholder'),
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        )
                      : DesignConfiguration.getCacheNotworkImage(
                          boxFit: extendImg ? BoxFit.cover : BoxFit.contain,
                          context: context,
                          heightvalue: 50,
                          widthvalue: 50,
                          placeHolderSize: 50,
                          imageurlString: suggestion.image!,
                        ),
                ),
          trailing: const Icon(
            Icons.reply,
          ),
          onTap: () async {
            // if (suggestion.name!.startsWith('Search Result for ')) {
            //   SettingProvider settingsProvider =
            //       Provider.of<SettingProvider>(context, listen: false);

            //   settingsProvider.setPrefrenceList(
            //       HISTORYLIST, textController!.text.toString().trim());

            //   buildResult = true;
            //   clearAll!();
            //   getProduct!();
            // } else
            if (suggestion.history!) {
              clearAll!();

              buildResult = true;
              textController!.text = suggestion.name!;
              textController!.selection = TextSelection.fromPosition(
                  TextPosition(offset: textController!.text.length));
            } else {
              SettingProvider settingsProvider =
                  Provider.of<SettingProvider>(context, listen: false);

              settingsProvider.setPrefrenceList(
                  HISTORYLIST, textController!.text.toString().trim());
              buildResult = false;
              Product model = suggestion;
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => ProductDetail(
                    model: model,
                    secPos: 0,
                    index: i,
                    list: true,
                  ),
                ),
              );
            }
          },
        );
      },
    );
  }
}
