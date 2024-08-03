import 'package:eshop_multivendor/main.dart';
import 'package:flutter/material.dart';
import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:eshop_multivendor/Provider/systemProvider.dart';
import 'package:provider/provider.dart';
import '../../../widgets/bottomSheet.dart';

class LanguageBottomSheet extends StatelessWidget {
  LanguageBottomSheet({Key? key}) : super(key: key);
  List<String?> languageList = [];
  List<String?> subLanguageList = [];

  List<Widget> getLngList(
    BuildContext context,
    StateSetter setModalState,
  ) {
    context.read<SystemProvider>().getCurrentLanguage(context: context);
    return languageList
        .asMap()
        .map(
          (index, element) => MapEntry(
            index,
            InkWell(
                onTap: () {
                  context
                      .read<SystemProvider>()
                      .changeCurrentLanguage(selectedLanguageIndex: index)
                      .then(
                    (value) {
                      MyApp.setLocale(context, value);
                      context
                          .read<SystemProvider>()
                          .getCurrentLanguage(context: context);
                    },
                  );
                  setModalState(() {});
                },
                child: Selector<SystemProvider, int>(
                    selector: (_, provider) => provider.currentLanguage,
                    builder: (context, selectedLanguage, child) {
                      return ListTile(
                        dense: true,
                        leading: Container(
                          height: 25.0,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: selectedLanguage == index
                                ? colors.primary
                                : Theme.of(context).colorScheme.white,
                            border: Border.all(
                              color: colors.grad2Color,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: selectedLanguage == index
                                ? Icon(
                                    Icons.check,
                                    size: 17.0,
                                    color:
                                        Theme.of(context).colorScheme.fontColor,
                                  )
                                : Icon(
                                    Icons.check_box_outline_blank,
                                    size: 17.0,
                                    color: Theme.of(context).colorScheme.white,
                                  ),
                          ),
                        ),
                        title: Text(subLanguageList[index]!,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium!
                                .copyWith(
                                  color:
                                      Theme.of(context).colorScheme.lightBlack,
                                )),
                        subtitle: Text(languageList[index]!,
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall!
                                .copyWith(
                                  color:
                                      Theme.of(context).colorScheme.lightBlack,
                                )),
                      );
                    }) /* Padding(
                padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10),
                child: Row(
                  children: [
                   
                        return Container(
                          height: 25.0,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: selectedLanguage == index
                                ? colors.primary
                                : Theme.of(context).colorScheme.white,
                            border: Border.all(
                              color: colors.grad2Color,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: selectedLanguage == index
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
                        );
                      },
                    ),
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsetsDirectional.only(
                            start: 15.0,
                          ),
                          child: Text(
                            languageList[index]!,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium!
                                .copyWith(
                                  color:
                                      Theme.of(context).colorScheme.lightBlack,
                                ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
             */
                ),
          ),
        )
        .values
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    languageList = [
      'English',
      'Chinese',
      'Spanish',
      'French',
      'Hindi',
      'Arabic',
      'Russian',
      'Japanese',
      'German'
    ];
    subLanguageList = [
      'English',
      '中国人',
      'Española',
      'Français',
      'हिंदी',
      'عربي',
      'Русский',
      '日本',
      'Deutsch'
    ];
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomBottomSheet.bottomSheetHandle(context),
          CustomBottomSheet.bottomSheetLabel(context, 'CHOOSE_LANGUAGE_LBL'),
          Flexible(
            child: SingleChildScrollView(
              child: StatefulBuilder(
                builder: (BuildContext context, StateSetter setModalState) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: getLngList(
                      context,
                      setModalState,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
