import 'dart:math';

import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:eshop_multivendor/Provider/homePageProvider.dart';
import 'package:eshop_multivendor/Screen/Product%20Detail/Widget/sellerDetail.dart';
import 'package:eshop_multivendor/widgets/ratingCardForProduct.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../Helper/Constant.dart';
import '../../../Helper/routes.dart';
import '../../../Model/Section_Model.dart';
import '../../../widgets/desing.dart';
import '../../Language/languageSettings.dart';
import '../../../widgets/star_rating.dart';
import '../explore.dart';

// ignore: must_be_immutable
class ShowContentOfSellers extends StatelessWidget {
  List<Product> sellerList;
  ShowContentOfSellers({Key? key, required this.sellerList}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return sellerList.isNotEmpty
        ? ListView.builder(
            shrinkWrap: true,
            controller: sellerListController,
            itemCount: sellerList.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6.0),
                child: Card(
                  elevation: 0,
                  color: Theme.of(context).colorScheme.white,
                  child: ListTile(
                    title: Padding(
                      padding: const EdgeInsets.only(bottom:  8.0),
                      child: Text(
                        sellerList[index].store_name!,
                        style: Theme.of(context).textTheme.titleSmall!.copyWith(
                              color: Theme.of(context).colorScheme.lightBlack,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'ubuntu',
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    subtitle: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Padding(
                        //   padding: const EdgeInsets.only(top: 3.0),
                        //   child: RatingCartForProduct(noOfRating: sellerList[index].noOfRatingsOnSeller!, totalRating: sellerList[index].seller_rating!),
                        // ),
                        const Icon(
                          Icons.star_rate,
                          size: 15,
                          color: colors.primary,
                        ),
                        Text(
                          ' ${sellerList[index].seller_rating!}',
                           style: const TextStyle(
                              fontWeight: FontWeight.w400,
                              fontStyle: FontStyle.normal,
                              fontSize: textFontSize13,
                              fontFamily: 'ubuntu',
                            ),
                        ),
                        Text(
                          ' | ${sellerList[index].noOfRatingsOnSeller!}',
                           style: const TextStyle(
                              fontWeight: FontWeight.w400,
                              fontStyle: FontStyle.normal,
                              fontSize: textFontSize13,
                              fontFamily: 'ubuntu',
                            ),
                        ),
                    
                        // Expanded(
                        //   child: StarRating(
                        //       noOfRatings:
                        //           sellerList[index].noOfRatingsOnSeller!,
                        //       totalRating: sellerList[index].seller_rating!,
                        //       needToShowNoOfRatings: false),
                        // ),
                        Expanded(
                          child: Text(
                            ' | ${sellerList[index].totalProductsOfSeller} ${getTranslated(context, 'PRODUCTS')} ',
                            style: const TextStyle(
                              fontWeight: FontWeight.w400,
                              fontStyle: FontStyle.normal,
                              fontSize: textFontSize14,
                              fontFamily: 'ubuntu',
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(circularBorderRadius7),
                      child: sellerList[index].seller_profile == ''
                          ? Image.asset(
                              DesignConfiguration.setPngPath('placeholder'),
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            )
                          : DesignConfiguration.getCacheNotworkImage(
                              context: context,
                              boxFit: BoxFit.cover,
                              heightvalue: 50,
                              widthvalue: 50,
                              placeHolderSize: 50,
                              imageurlString: sellerList[index].seller_profile!,
                            ),
                    ),
                    trailing: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: colors.black12),
                          borderRadius:
                              BorderRadius.circular(circularBorderRadius10),
                        ),
                        child: Icon(
                          Icons.chevron_right,
                          color: Theme.of(context).colorScheme.fontColor,
                        )),
                    // Container(
                    //   width: 80,
                    //   height: 35,
                    //   padding:
                    //       const EdgeInsetsDirectional.fromSTEB(3.0, 0, 3.0, 0),
                    //   decoration: BoxDecoration(
                    //     border: Border.all( color: colors.black12),
                    //     borderRadius:
                    //         BorderRadius.circular(circularBorderRadius10),
                    //   ),
                    //   child: Center(
                    //     child: Text(
                    //       getTranslated(context, 'VIEW_STORE'),
                    //       style: TextStyle(
                    //         color: Theme.of(context).colorScheme.fontColor,
                    //         fontFamily: 'ubuntu',
                    //       ),
                    //       overflow: TextOverflow.ellipsis,
                    //       maxLines: 1,
                    //       softWrap: true,
                    //     ),
                    //   ),
                    // ),
                    onTap: () async {
                      Routes.navigateToSellerProfileScreen(
                        context,
                        sellerList[index].seller_id!,
                        sellerList[index].seller_profile!,
                        sellerList[index].seller_name!,
                        sellerList[index].seller_rating!,
                        sellerList[index].store_name!,
                        sellerList[index].store_description!,
                        sellerList[index].totalProductsOfSeller,
                        sellerList[index].noOfRatingsOnSeller!,
                      );
                    },
                  ),
                ),
              );
            },
          )
        : Selector<HomePageProvider, bool>(
            builder: (context, data, child) {
              return !data
                  ? Center(
                      child: Text(
                        getTranslated(context, 'No Seller/Store Found'),
                        style: const TextStyle(
                          fontFamily: 'ubuntu',
                        ),
                      ),
                    )
                  : const SizedBox();
            },
            selector: (_, provider) => provider.sellerLoading,
          );
  }
}
