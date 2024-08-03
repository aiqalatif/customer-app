import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:eshop_multivendor/Helper/Constant.dart';
import 'package:eshop_multivendor/Model/Section_Model.dart';
import 'package:eshop_multivendor/Provider/Favourite/FavoriteProvider.dart';
import 'package:eshop_multivendor/Provider/Favourite/UpdateFavProvider.dart';
import 'package:eshop_multivendor/Provider/UserProvider.dart';
import 'package:eshop_multivendor/Screen/Dashboard/Dashboard.dart';
import 'package:eshop_multivendor/Screen/Language/languageSettings.dart';
import 'package:eshop_multivendor/Screen/Product%20Detail/productDetail.dart';
import 'package:eshop_multivendor/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CustomFevoriteButtonForCart extends StatelessWidget {
  Product model;
   CustomFevoriteButtonForCart({Key? key, required this.model}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
                            margin: EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: Theme.of(context).colorScheme.gray,
                                  width: 1),
                              color: Theme.of(context).colorScheme.white,
                              borderRadius: const BorderRadius.all(
                                Radius.circular(circularBorderRadius50),
                              ),
                            ),
                            child: model.isFavLoading!
                                ? const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 0.7,
                                      ),
                                    ),
                                  )
                                : Selector<FavoriteProvider, List<String?>>(
                                    builder: (context, data, child) {
                                      return InkWell(
                                        child: Padding(
                                          padding: const EdgeInsets.all(2.0),
                                          child: Icon(
                                            !data.contains(model.id)
                                                ? Icons.favorite_border
                                                : Icons.favorite,
                                            size: 18,
                                          ),
                                        ),
                                        onTap: () {
                                          if (context
                                                  .read<UserProvider>()
                                                  .userId !=
                                              '') {
                                            if (!data
                                                .contains(model.id)) {
                                              model.isFavLoading = true;
                                              model.isFav = '1';

                                              Future.delayed(Duration.zero)
                                                  .then((value) => context
                                                      .read<UpdateFavProvider>()
                                                      .addFav(context,
                                                          model.id!, 1,
                                                          model: model))
                                                  .then(
                                                (value) {
                                                  model.isFavLoading =
                                                      false;
                                                },
                                              );
                                            } else {
                                              model.isFavLoading = true;
                                              model.isFav = '0';
                                              Future.delayed(Duration.zero)
                                                  .then(
                                                (value) => context
                                                    .read<UpdateFavProvider>()
                                                    .removeFav(
                                                      model.id!,
                                                      model
                                                          .prVarientList![0]
                                                          .id!,
                                                      context,
                                                    ),
                                              )
                                                  .then(
                                                (value) {
                                                  model.isFavLoading =
                                                      false;
                                                },
                                              );
                                            }
                                          } else {
                                            if (!data
                                                .contains(model.id)) {
                                              model.isFavLoading = true;
                                              model.isFav = '1';
                                              context
                                                  .read<FavoriteProvider>()
                                                  .addFavItem(model);
                                              db.addAndRemoveFav(
                                                  model.id!, true);
                                              model.isFavLoading = false;
                                              setSnackbar(
                                                  getTranslated(context,
                                                      'Added to favorite'),
                                                  context);
                                            } else {
                                              model.isFavLoading = true;
                                              model.isFav = '0';
                                              context
                                                  .read<FavoriteProvider>()
                                                  .removeFavItem(model
                                                      .prVarientList![0].id!);
                                              db.addAndRemoveFav(
                                                  model.id!, false);
                                              model.isFavLoading = false;
                                              setSnackbar(
                                                getTranslated(context,
                                                    'Removed from favorite'),
                                                context,
                                              );
                                            }
                                          }
                                        },
                                      );
                                    },
                                    selector: (_, provider) =>
                                        provider.favIdList,
                                  ),
                          )
                       ;
  }
}