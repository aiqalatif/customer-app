import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Helper/routes.dart';
import '../../Model/Section_Model.dart';
import '../../Provider/ReviewGallleryProvider.dart';
import '../../Provider/ReviewPreviewProvider.dart';
import '../../Provider/productDetailProvider.dart';
import '../../widgets/appBar.dart';
import '../../widgets/desing.dart';
import '../Language/languageSettings.dart';

class ReviewGallary extends StatefulWidget {
  final List<dynamic>? imageList;

  const ReviewGallary({Key? key, this.imageList}) : super(key: key);
  @override
  _ReviewImageState createState() => _ReviewImageState();
}

class _ReviewImageState extends State<ReviewGallary> {
  setStateNow() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getSimpleAppBar(
          getTranslated(context, 'REVIEW_BY_CUST'), context),
      body: Selector<ReviewGallaryProvider, Product?>(
        builder: (context, model, child) {
          return GridView.count(
            shrinkWrap: true,
            crossAxisCount: 3,
            childAspectRatio: 1,
            crossAxisSpacing: 5,
            mainAxisSpacing: 5,
            padding: const EdgeInsets.all(20),
            children: List.generate(
              model != null
                  ? context.read<ProductDetailProvider>().reviewImgList.length
                  : widget.imageList!.length,
              (index) {
                return InkWell(
                  child: DesignConfiguration.getCacheNotworkImage(
                    boxFit: BoxFit.cover,
                    context: context,
                    heightvalue: null,
                    widthvalue: null,
                    imageurlString: model != null
                        ? context
                            .read<ProductDetailProvider>()
                            .reviewImgList[index]
                            .img!
                        : widget.imageList![index],
                    placeHolderSize: double.maxFinite,
                  ),
                  onTap: () {
                    if (model != null) {
                      context
                          .read<ReviewPreviewProvider>()
                          .setProductModel(model);
                      context.read<ReviewPreviewProvider>().setIndex(index);
                      Routes.navigateToReviewPreviewScreen(context);
                    } else {
                      context.read<ReviewPreviewProvider>().setIndex(index);
                      context
                          .read<ReviewPreviewProvider>()
                          .setImageList(widget.imageList);
                      Routes.navigateToReviewPreviewScreen(context);
                    }
                  },
                );
              },
            ),
          );
        },
        selector: (_, galleryProvider) => galleryProvider.productModel,
      ),
    );
  }
}
