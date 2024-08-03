import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Helper/Color.dart';
import '../../Helper/Constant.dart';
import '../../Helper/routes.dart';
import '../../Provider/writeReviewProvider.dart';
import '../Language/languageSettings.dart';
import '../../widgets/snackbar.dart';
import 'Widget/ImageField.dart';
import 'Widget/rattingwidget.dart';

class Write_Review extends StatefulWidget {
  BuildContext screenContext;
  String productId;
  String userReview;
  double userStarRating;

  Write_Review(
      this.screenContext, this.productId, this.userReview, this.userStarRating,
      {Key? key})
      : super(key: key);

  @override
  State<Write_Review> createState() => _Write_ReviewState();
}

class _Write_ReviewState extends State<Write_Review> {
  @override
  void initState() {
    context.read<WriteReviewProvider>().commentTextController.text =
        widget.userReview;
    super.initState();
  }

  setStateNow() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              bottomSheetHandle(),
              rateTextLabel(),
              RattingWidget(
                userStarRating: widget.userStarRating,
              ),
              writeReviewLabel(),
              writeReviewField(),
              getImageField(),
              sendReviewButton(widget.productId),
            ],
          ),
        ),
      ],
    );
  }

  Widget bottomSheetHandle() {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(circularBorderRadius50),
            color: Theme.of(context).colorScheme.lightBlack),
        height: 5,
        width: MediaQuery.of(context).size.width * 0.3,
      ),
    );
  }

  Widget rateTextLabel() {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: getHeading('PRODUCT_REVIEW'),
    );
  }

  Widget writeReviewLabel() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Text(
        getTranslated(context, 'REVIEW_OPINION'),
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Theme.of(context).colorScheme.fontColor,
          fontFamily: 'ubuntu',
        ),
      ),
    );
  }

  Widget writeReviewField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
      child: TextField(
        controller: context.read<WriteReviewProvider>().commentTextController,
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
                    Theme.of(context).colorScheme.lightBlack2.withOpacity(0.7),
              ),
        ),
      ),
    );
  }

  Widget sendReviewButton(var productID) {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
            child: MaterialButton(
              height: 45.0,
              textColor: Theme.of(context).colorScheme.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(circularBorderRadius10)),
              onPressed: () {
                if (context.read<WriteReviewProvider>().curRating != 0 ||
                    context
                            .read<WriteReviewProvider>()
                            .commentTextController
                            .text !=
                        '' ||
                    (context
                        .read<WriteReviewProvider>()
                        .reviewPhotos
                        .isNotEmpty)) {
                  context.read<WriteReviewProvider>().setRating(
                        productID,
                        context,
                        widget.screenContext,
                        setStateNow,
                      );
                } else {
                  Routes.pop(context);
                  setSnackbar(getTranslated(context, 'REVIEW_W'),
                      widget.screenContext);
                }
              },
              color: colors.primary,
              child: Text(
                widget.userStarRating == 0.0
                    ? getTranslated(context, 'SEND_REVIEW'): getTranslated(context, 'UPDATE_REVIEW_LBL'),
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

  Text getHeading(
    String title,
  ) {
    return Text(
      getTranslated(context, title),
      style: Theme.of(context).textTheme.titleLarge!.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.fontColor,
            fontFamily: 'ubuntu',
          ),
    );
  }
}
