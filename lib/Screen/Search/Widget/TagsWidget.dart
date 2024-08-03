import 'package:eshop_multivendor/Provider/Search/SearchProvider.dart';
import 'package:eshop_multivendor/Screen/Language/languageSettings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../Helper/Color.dart';
import '../../../Helper/Constant.dart';
import '../../ProductList&SectionView/ProductList.dart';

class TagsWidget extends StatelessWidget {
  ChoiceChip? tagChip;

  TagsWidget({Key? key, this.tagChip}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (context.read<SearchProvider>().tagList.isNotEmpty) {
      List<Widget> chips = [];
      for (int i = 0; i < context.read<SearchProvider>().tagList.length; i++) {
        tagChip = ChoiceChip(
          selected: false,
          label: Text(
            context.read<SearchProvider>().tagList[i],
            style: TextStyle(
              color: Theme.of(context).colorScheme.white,
              fontSize: textFontSize11,
              fontFamily: 'ubuntu',
            ),
          ),
          backgroundColor: colors.primary,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(
                circularBorderRadius25,
              ),
            ),
          ),
          onSelected: (bool selected) {
            Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (context) => ProductList(
                  name: context.read<SearchProvider>().tagList[i],
                  fromSeller: false,
                  tag: true,
                ),
              ),
            );
          },
        );

        chips.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: tagChip,
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(),
          context.read<SearchProvider>().tagList.isNotEmpty
              ? Padding(
                  padding: const EdgeInsetsDirectional.only(start: 8.0),
                  child: Text(
                    getTranslated(context, 'Discover more'),
                    style: const TextStyle(
                      fontFamily: 'ubuntu',
                    ),
                  ),
                )
              : const SizedBox(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Wrap(
              children: chips.map<Widget>(
                (Widget chip) {
                  return Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: chip,
                  );
                },
              ).toList(),
            ),
          ),
        ],
      );
    } else {
      return const SizedBox();
    }
  }
}
