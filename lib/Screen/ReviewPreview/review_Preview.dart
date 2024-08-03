import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:provider/provider.dart';
import '../../Helper/Constant.dart';
import '../../Helper/String.dart';
import '../../Model/User.dart';
import '../../Provider/ReviewPreviewProvider.dart';
import '../../Provider/productDetailProvider.dart';
import 'Widget/reviewPreviewWidget.dart';

class ReviewPreview extends StatefulWidget {
  const ReviewPreview({
    Key? key,
  }) : super(key: key);
  @override
  State<StatefulWidget> createState() => StatePreview();
}

class StatePreview extends State<ReviewPreview> {
  int? curPos;
  bool flag = true;
  User? model;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ReviewPreviewProvider>(
      builder: (context, reviewPreviewProvider, _) {
        curPos = reviewPreviewProvider.index;
        if (reviewPreviewProvider.productModel != null) {
          model =
              reviewPreviewProvider.productModel!.reviewList![0].productRating![
                  context
                      .read<ProductDetailProvider>()
                      .reviewImgList[curPos!]
                      .index!];
        }
        return Scaffold(
          body: Hero(
            tag: '${reviewPreviewProvider.index} $heroTagUniqueString',
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: <Widget>[
                PhotoViewGallery.builder(
                  scrollPhysics: const BouncingScrollPhysics(),
                  builder: (BuildContext context, int index) {
                    return PhotoViewGalleryPageOptions(
                      initialScale: PhotoViewComputedScale.covered,
                      minScale: PhotoViewComputedScale.contained * 0.9,
                      imageProvider: NetworkImage(
                        reviewPreviewProvider.productModel != null
                            ? context
                                .read<ProductDetailProvider>()
                                .reviewImgList[index]
                                .img!
                            : reviewPreviewProvider.imageList![index],
                      ),
                    );
                  },
                  itemCount: reviewPreviewProvider.productModel != null
                      ? context
                          .read<ProductDetailProvider>()
                          .reviewImgList
                          .length
                      : reviewPreviewProvider.imageList!.length,
                  loadingBuilder: (context, event) => Center(
                    child: SizedBox(
                      width: 20.0,
                      height: 20.0,
                      child: CircularProgressIndicator(
                        color: colors.primary,
                        value: event == null
                            ? 0
                            : event.cumulativeBytesLoaded /
                                event.expectedTotalBytes!,
                      ),
                    ),
                  ),
                  backgroundDecoration:
                      BoxDecoration(color: Theme.of(context).colorScheme.white),
                  pageController:
                      PageController(initialPage: reviewPreviewProvider.index!),
                  onPageChanged: (index) {
                    if (mounted) {
                      setState(
                        () {
                          curPos = index;
                        },
                      );
                    }
                  },
                ),
                const NavigationBtnWidget(),
                reviewPreviewProvider.productModel != null
                    ? Container(
                        color: Colors.black87,
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GetRattingBarIndicatorWidget(
                                rating: model!.rating!),
                            model!.comment != null && model!.comment!.isNotEmpty
                                ? SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width - 20,
                                    child: InkWell(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 5.0,
                                        ),
                                        child: Text(
                                          model!.comment ?? '',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontFamily: 'ubuntu',
                                          ),
                                          maxLines: flag ? 2 : null,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      onTap: () {
                                        setState(
                                          () {
                                            flag = !flag;
                                          },
                                        );
                                      },
                                    ),
                                  )
                                : const SizedBox(),
                            SizedBox(
                              width: MediaQuery.of(context).size.width - 20,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    model!.username ?? '',
                                    style: const TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    model!.date ?? '',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'ubuntu',
                                      fontSize: textFontSize11,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                    : const SizedBox()
              ],
            ),
          ),
        );
      },
    );
  }
}
