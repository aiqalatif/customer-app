import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:eshop_multivendor/Provider/Theme.dart';
import 'package:eshop_multivendor/widgets/bottomSheet.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Language/languageSettings.dart';

class ThemeBottomSheet extends StatelessWidget {
  late ThemeNotifier themeNotifier;

  ThemeBottomSheet({Key? key}) : super(key: key);

  List<String?> themeList = [];

  List<Widget> themeListView(BuildContext context) {
    context.read<ThemeProvider>().getCurrentTheme(context, themeList);
    return themeList
        .asMap()
        .map(
          (index, element) => MapEntry(
            index,
            InkWell(
              onTap: () {
                context
                    .read<ThemeProvider>()
                    .changeTheme(index, themeList[index]!, context);
              },
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20.0, 5.0, 20.0, 10),
                child: Column(
                  children: [
                    Selector<ThemeProvider, int>(
                      selector: (_, provider) => provider.activeThemeIndex,
                      builder: (context, activeThemeIndex, child) {
                        return Row(
                          children: [
                            Container(
                              height: 25.0,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: activeThemeIndex == index
                                    ? colors.grad2Color
                                    : Theme.of(context).colorScheme.white,
                                border: Border.all(color: colors.grad2Color),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: activeThemeIndex == index
                                    ? Icon(
                                        Icons.check,
                                        size: 17.0,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .fontColor,
                                      )
                                    : Icon(
                                        Icons.check_box_outline_blank,
                                        size: 17.0,
                                        color:
                                            Theme.of(context).colorScheme.white,
                                      ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsetsDirectional.only(
                                start: 15.0,
                              ),
                              child: Text(
                                themeList[index]!,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium!
                                    .copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .lightBlack),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        )
        .values
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    themeList = [
      getTranslated(context, 'SYSTEM_DEFAULT'),
      getTranslated(context, 'LIGHT_THEME'),
      getTranslated(context, 'DARK_THEME')
    ];
    themeNotifier = Provider.of<ThemeNotifier>(context);

    return Wrap(
      children: [
        Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Form(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                CustomBottomSheet.bottomSheetHandle(context),
                CustomBottomSheet.bottomSheetLabel(context, 'CHOOSE_THEME_LBL'),
                SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: themeListView(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
