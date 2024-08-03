import 'dart:async';
import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:eshop_multivendor/Provider/UserProvider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../Helper/Constant.dart';
import '../../../Helper/String.dart';
import '../../../Helper/routes.dart';
import '../../../Model/Section_Model.dart';
import '../../../Provider/CartProvider.dart';
import '../../../Provider/faqProvider.dart';
import '../../../Provider/productDetailProvider.dart';
import '../../../widgets/ButtonDesing.dart';
import '../../Language/languageSettings.dart';
import '../../../widgets/networkAvailablity.dart';
import '../../../widgets/snackbar.dart';

class PostQuesWidget extends StatelessWidget {
  Product? model;
  Function update;
  PostQuesWidget({Key? key, this.model, required this.update})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            getTranslated(context, 'Have any Query regarding this product?'),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.fontColor,
            ),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.only(
              top: 10,
              bottom: 5,
            ),
            child: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                context.read<UserProvider>().userId != ''
                    ? openPostQueBottomSheet(context, model!.id, update)
                    : Routes.navigateToLoginScreen(
                        context,
                        isPop: true,
                      );
              },
              child: Container(
                width: double.maxFinite,
                height: 38.5,
                alignment: FractionalOffset.center,
                decoration: BoxDecoration(
                  border: Border.all(
                      color: Theme.of(context)
                          .colorScheme
                          .lightBlack
                          .withOpacity(0.4)),
                  borderRadius: const BorderRadius.all(
                      Radius.circular(circularBorderRadius5)),
                ),
                child: Text(
                  getTranslated(context, 'POST YOUR QUESTION'),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleSmall!.copyWith(
                        color: Theme.of(context).colorScheme.fontColor,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

void openPostQueBottomSheet(
    BuildContext context, String? id, Function? update) {
  showModalBottomSheet(
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(circularBorderRadius40),
        topRight: Radius.circular(circularBorderRadius40),
      ),
    ),
    isScrollControlled: true,
    context: context,
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setStater) {
          return Form(
            key: context.read<ProductDetailProvider>().faqsKey,
            child: Wrap(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(circularBorderRadius40),
                      topRight: Radius.circular(circularBorderRadius40),
                    ),
                    color: Theme.of(context).colorScheme.white,
                  ),
                  padding: EdgeInsetsDirectional.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 30.0, bottom: 20),
                        child: Text(
                          getTranslated(context, 'Write Question'),
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium!
                              .copyWith(
                                  fontWeight: FontWeight.bold,
                                  color:
                                      Theme.of(context).colorScheme.fontColor),
                        ),
                      ),
                      Flexible(
                        child: Padding(
                          padding: const EdgeInsetsDirectional.only(top: 10.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsetsDirectional.only(
                                    start: 20, end: 20),
                                child: Container(
                                  height:
                                      MediaQuery.of(context).size.height * 0.25,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(
                                          circularBorderRadius10),
                                      color: Theme.of(context)
                                          .colorScheme
                                          .lightWhite),
                                  child: TextFormField(
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .fontColor,
                                      fontWeight: FontWeight.w400,
                                      fontStyle: FontStyle.normal,
                                      fontSize: textFontSize14,
                                    ),
                                    onChanged: (value) {},
                                    onSaved: ((String? val) {}),
                                    maxLines: null,
                                    validator: (val) {
                                      if (val!.isEmpty) {
                                        return getTranslated(context,
                                            'Please provide more details on your question');
                                      }
                                      return null;
                                    },
                                    decoration: InputDecoration(
                                      hintText: getTranslated(
                                          context, 'Type your question'),
                                      hintStyle: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .black),
                                      contentPadding:
                                          const EdgeInsetsDirectional.all(25.0),
                                      filled: true,
                                      fillColor: Theme.of(context)
                                          .colorScheme
                                          .lightWhite,
                                      border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                              circularBorderRadius10),
                                          borderSide: const BorderSide(
                                              width: 0.0,
                                              style: BorderStyle.none)),
                                    ),
                                    keyboardType: TextInputType.multiline,
                                    controller: context
                                        .read<ProductDetailProvider>()
                                        .edtFaqs,
                                  ),
                                ),
                              ),
                              Consumer<FaQProvider>(
                                builder: (context, value, child) {
                                  return Padding(
                                    padding:
                                        const EdgeInsetsDirectional.all(20),
                                    child: SimBtn(
                                      size: 0.5,
                                      borderRadius: 10,
                                      title:
                                          getTranslated(context, 'SUBMIT_LBL'),
                                      height: 45,
                                      onBtnSelected: () async {
                                        final form = context
                                            .read<ProductDetailProvider>()
                                            .faqsKey
                                            .currentState!;
                                        form.save();
                                        if (form.validate()) {
                                          context
                                              .read<FaQProvider>()
                                              .setProdId(id);
                                          context
                                              .read<FaQProvider>()
                                              .setquestion(context
                                                  .read<ProductDetailProvider>()
                                                  .edtFaqs
                                                  .text
                                                  .trim());
                                          context
                                              .read<CartProvider>()
                                              .setProgress(true);
                                          isNetworkAvail =
                                              await isNetworkAvailable();
                                          if (isNetworkAvail) {
                                            Future.delayed(Duration.zero).then(
                                              (value) => context
                                                  .read<FaQProvider>()
                                                  .setFaqsQue(context)
                                                  .then(
                                                (
                                                  value,
                                                ) async {
                                                  bool error = value['error'];
                                                  String? msg =
                                                      value['message'];
                                                  if (!error) {
                                                    setSnackbar(msg!, context);
                                                    context
                                                        .read<
                                                            ProductDetailProvider>()
                                                        .edtFaqs
                                                        .clear();
                                                    Routes.pop(context);
                                                  } else {
                                                    setSnackbar(msg!, context);
                                                  }
                                                  context
                                                      .read<CartProvider>()
                                                      .setProgress(false);
                                                },
                                              ),
                                            );
                                          } else {
                                            isNetworkAvail = false;
                                            update!();
                                          }
                                        }
                                      },
                                    ),
                                  );
                                },
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

Widget bottomSheetHandle(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.only(top: 10.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(circularBorderRadius20),
            color: Theme.of(context).colorScheme.lightBlack,
          ),
          height: 5,
          width: MediaQuery.of(context).size.width * 0.3,
        ),
      ],
    ),
  );
}

class FaqsQueWidget extends StatelessWidget {
  const FaqsQueWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return context.read<ProductDetailProvider>().isFaqsLoading
        ? const Center(
            // child: CircularProgressIndicator(),
            )
        : context.read<ProductDetailProvider>().faqsProductList.isNotEmpty
            ? Padding(
                padding: const EdgeInsetsDirectional.only(
                  start: 0,
                  end: 10,
                  top: 15,
                  bottom: 0,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListView.separated(
                      shrinkWrap: true,
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      itemCount: context
                                  .read<ProductDetailProvider>()
                                  .faqsProductList
                                  .length >=
                              5
                          ? 5
                          : context
                              .read<ProductDetailProvider>()
                              .faqsProductList
                              .length,
                      physics: const NeverScrollableScrollPhysics(),
                      separatorBuilder: (BuildContext context, int index) =>
                          const Divider(),
                      itemBuilder: (context, index) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${getTranslated(context, "Que :")} ${context.read<ProductDetailProvider>().faqsProductList[index].question!}',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.fontColor,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Ubuntu',
                                fontStyle: FontStyle.normal,
                                fontSize: textFontSize14,
                              ),
                              maxLines: 10,
                              softWrap: false,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: SizedBox(
                                width: deviceWidth! * 0.9,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${getTranslated(context, 'Ans')} : ',
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .fontColor,
                                        fontWeight: FontWeight.w500,
                                        fontFamily: 'Ubuntu',
                                        fontStyle: FontStyle.normal,
                                        fontSize: textFontSize14,
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        context
                                                .read<ProductDetailProvider>()
                                                .faqsProductList[index]
                                                .answer ??
                                            '',
                                        style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .lightBlack,
                                          fontSize: textFontSize14,
                                        ),
                                        maxLines: 10,
                                        softWrap: false,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 3.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    context
                                            .read<ProductDetailProvider>()
                                            .faqsProductList[index]
                                            .ansBy ??
                                        '',
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .lightBlack
                                          .withOpacity(0.5),
                                      fontWeight: FontWeight.w500,
                                      fontFamily: 'Ubuntu',
                                      fontStyle: FontStyle.normal,
                                      fontSize: textFontSize12,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 10.0, right: 10),
                                    child: Text(
                                      '|',
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .lightBlack
                                            .withOpacity(0.5),
                                        fontWeight: FontWeight.w500,
                                        fontFamily: 'Ubuntu',
                                        fontStyle: FontStyle.normal,
                                        fontSize: textFontSize12,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    context
                                        .read<ProductDetailProvider>()
                                        .faqsProductList[index]
                                        .dateAdded!,
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .lightBlack
                                          .withOpacity(0.5),
                                      fontWeight: FontWeight.w500,
                                      fontFamily: 'Ubuntu',
                                      fontStyle: FontStyle.normal,
                                      fontSize: textFontSize12,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        );
                      },
                    )
                  ],
                ),
              )
            : const SizedBox();
  }
}
