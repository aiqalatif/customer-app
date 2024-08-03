import 'dart:io';
import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import '../../../Helper/Constant.dart';
import '../../../Helper/routes.dart';
import '../../../Model/Order_Model.dart';
import '../../../Provider/Order/UpdateOrderProvider.dart';
import '../../Language/languageSettings.dart';
import '../../../widgets/snackbar.dart';

class GetImageField extends StatefulWidget {
  const GetImageField({
    Key? key,
  }) : super(key: key);

  @override
  State<GetImageField> createState() => _GetImageFieldState();
}

class _GetImageFieldState extends State<GetImageField> {
  setSanckBarNow(String msg) {
    setSnackbar(msg, context);
    context.read<UpdateOrdProvider>().reviewPhotos.clear();
    context.read<UpdateOrdProvider>().changeStatus(UpdateOrdStatus.initial);
  }

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setModalState) {
        return Container(
          padding:
              const EdgeInsetsDirectional.only(start: 20.0, end: 20.0, top: 5),
          height: 100,
          child: Row(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0),
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: colors.primary,
                        borderRadius:
                            BorderRadius.circular(circularBorderRadius50),
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.camera_alt,
                          color: Theme.of(context).colorScheme.white,
                          size: 25.0,
                        ),
                        onPressed: () {
                          _reviewImgFromGallery(setModalState, context);
                        },
                      ),
                    ),
                    Text(
                      getTranslated(context, 'ADD_YOUR_PHOTOS'),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.lightBlack,
                        fontSize: textFontSize11,
                        fontFamily: 'ubuntu',
                      ),
                    )
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount:
                      context.read<UpdateOrdProvider>().reviewPhotos.length,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, i) {
                    return InkWell(
                      child: Stack(
                        alignment: AlignmentDirectional.topEnd,
                        children: [
                          Image.file(
                            context.read<UpdateOrdProvider>().reviewPhotos[i],
                            width: 100,
                            height: 100,
                          ),
                          Container(
                            color: Theme.of(context).colorScheme.black26,
                            child: const Icon(
                              Icons.clear,
                              size: 15,
                            ),
                          ),
                        ],
                      ),
                      onTap: () {
                        setModalState(
                          () {
                            context
                                .read<UpdateOrdProvider>()
                                .reviewPhotos
                                .removeAt(i);
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

void openBottomSheet(
  BuildContext parentContext,
  OrderItem orderItem,
  Function setSanckBarNow,
) {
  parentContext.read<UpdateOrdProvider>().curRating =
      double.parse(orderItem.userReviewRating!);
  showModalBottomSheet(
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(circularBorderRadius40),
        topRight: Radius.circular(
          circularBorderRadius40,
        ),
      ),
    ),
    isScrollControlled: true,
    context: parentContext,
    builder: (context) {
      return Wrap(
        children: [
          Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                bottomSheetHandle(context),
                rateTextLabel(context),
                ratingWidget(
                    double.parse(orderItem.userReviewRating!), context),
                writeReviewLabel(context),
                writeReviewField(orderItem.userReviewComment!, context),
                const GetImageField(),
                sendReviewButton(
                    orderItem, context, setSanckBarNow, parentContext),
              ],
            ),
          ),
        ],
      );
    },
  );
}

Widget bottomSheetHandle(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.only(top: 10.0),
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(circularBorderRadius20),
        color: Theme.of(context).colorScheme.lightBlack,
      ),
      height: 5,
      width: MediaQuery.of(context).size.width * 0.3,
    ),
  );
}

Widget rateTextLabel(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.only(top: 10.0),
    child: getHeading('PRODUCT_REVIEW', context),
  );
}

Widget ratingWidget(
  double rating,
  BuildContext context,
) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: RatingBar.builder(
      initialRating: rating,
      minRating: 1,
      direction: Axis.horizontal,
      allowHalfRating: false,
      itemCount: 5,
      itemSize: 32,
      itemPadding: const EdgeInsets.symmetric(
        horizontal: 8.0,
        vertical: 5,
      ),
      itemBuilder: (context, _) => const Icon(
        Icons.star,
        color: Colors.amber,
      ),
      onRatingUpdate: (rating) {
        context.read<UpdateOrdProvider>().curRating = rating;
      },
      glow: true,
    ),
  );
}

Widget writeReviewLabel(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
    child: Text(
      getTranslated(context, 'REVIEW_OPINION'),
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.titleMedium!.copyWith(
            fontFamily: 'ubuntu',
          ),
    ),
  );
}

Widget writeReviewField(String comment, BuildContext context) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
    child: Form(
      key: context.read<UpdateOrdProvider>().commentTextFieldKey,
      child: TextFormField(
        initialValue: comment,
        style: Theme.of(context).textTheme.titleSmall,
        keyboardType: TextInputType.multiline,
        maxLines: 5,
        decoration: InputDecoration(
          border: OutlineInputBorder(
              borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.lightBlack, width: 1.0)),
          hintText: getTranslated(context, 'REVIEW_HINT_LBL'),
          hintStyle: Theme.of(context).textTheme.titleSmall!.copyWith(
              color:
                  Theme.of(context).colorScheme.lightBlack2.withOpacity(0.7)),
        ),
        onChanged: (value) {
          context.read<UpdateOrdProvider>().updatedComment = value;
        },
      ),
    ),
  );
}

void _reviewImgFromGallery(
  StateSetter setModalState,
  BuildContext context,
) async {
  var result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['jpg', 'jpeg', 'png'],
    allowMultiple: true,
  );
  if (result != null) {
    context.read<UpdateOrdProvider>().reviewPhotos =
        result.paths.map((path) => File(path!)).toList();
    setModalState(() {});
  } else {
    // User canceled the picker
  }
}

Widget sendReviewButton(OrderItem orderItem, BuildContext context,
    Function setSanckBarNow, BuildContext parentContext) {
  return Row(
    children: [
      Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
          child: MaterialButton(
            height: 45.0,
            textColor: Theme.of(context).colorScheme.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                circularBorderRadius10,
              ),
            ),
            onPressed: () {
              Future.delayed(Duration.zero).then((value) => context
                  .read<UpdateOrdProvider>()
                  .commentTextFieldKey
                  .currentState!
                  .save());
              if (context.read<UpdateOrdProvider>().curRating != 0.0) {
                Routes.pop(context);
                Future.delayed(Duration.zero)
                    .then(
                  (value) => parentContext.read<UpdateOrdProvider>().setRating(
                        parentContext.read<UpdateOrdProvider>().curRating,
                        orderItem.productId,
                        parentContext,
                      ),
                )
                    .then(
                  (value) {
                    parentContext
                        .read<UpdateOrdProvider>()
                        .commentTextController
                        .text = '';
                    parentContext
                        .read<UpdateOrdProvider>()
                        .reviewPhotos
                        .clear();
                  },
                );
              } else {
                Routes.pop(context);
                setSnackbar(
                    getTranslated(parentContext, 'REVIEW_W'), parentContext);
              }
            },
            color: colors.primary,
            child: Text(
              orderItem.userReviewRating != '0'
                  ? getTranslated(context, 'UPDATE_REVIEW_LBL'): getTranslated(context, 'SEND_REVIEW'),
              style: const TextStyle(
                fontFamily: 'ubuntu',
              ),
            ),
          ),
        ),
      ),
    ],
  );
}

Text getHeading(String title, BuildContext context) {
  return Text(
    getTranslated(context, title),
    style: Theme.of(context).textTheme.titleLarge!.copyWith(
          fontWeight: FontWeight.bold,
          fontFamily: 'ubuntu',
        ),
  );
}
