// import 'dart:convert';
// import 'package:eshop_multivendor/Provider/UserProvider.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart';
// import 'package:provider/provider.dart';
// import '../../../Helper/Color.dart';
// import '../../../Helper/Constant.dart';
// import '../../../Helper/String.dart';
// import '../../../Model/Section_Model.dart';
// import '../../../Provider/Favourite/FavoriteProvider.dart';
// import '../../../Provider/sellerDetailProvider.dart';
// import '../../../widgets/desing.dart';
// import '../../Language/languageSettings.dart';
// import '../../../widgets/snackbar.dart';
// import '../../../widgets/star_rating.dart';
// import '../../Dashboard/Dashboard.dart';
// import '../../Product Detail/productDetail.dart';

// // ignore: must_be_immutable
// class GridViewLayOut extends StatefulWidget {
//   int index;
//   Function update;

//   GridViewLayOut({
//     Key? key,
//     required this.index,
//     required this.update,
//   }) : super(key: key);

//   @override
//   State<GridViewLayOut> createState() => _GridViewLayOutState();
// }

// class _GridViewLayOutState extends State<GridViewLayOut> {
//   showSanckBarNowForAdd(
//     Map<String, dynamic> response,
//     Product model,
//     int index,
//   ) {
//     //
//     var getdata = response;

//     bool error = getdata['error'];
//     String? msg = getdata['message'];
//     if (!error) {
//       index == -1
//           ? model.isFav = '1'
//           : context.read<SellerDetailProvider>().productList[index].isFav = '1';
//       context.read<FavoriteProvider>().addFavItem(model);
//       setSnackbar(msg!, context);
//     } else {
//       setSnackbar(msg!, context);
//     }
//     index == -1
//         ? model.isFavLoading = false
//         : context.read<SellerDetailProvider>().productList[index].isFavLoading =
//             false;
//     widget.update();
//     setState(() {});
//   }

//   showSanckBarNowForRemove(
//     Response response,
//     int index,
//     Product model,
//   ) {
//     //
//     var getdata = json.decode(response.body);
//     bool error = getdata['error'];
//     String? msg = getdata['message'];
//     if (!error) {
//       index == -1
//           ? model.isFav = '0'
//           : context.read<SellerDetailProvider>().productList[index].isFav = '0';
//       context
//           .read<FavoriteProvider>()
//           .removeFavItem(model.prVarientList![0].id!);
//       setSnackbar(msg!, context);
//     } else {
//       setSnackbar(msg!, context);
//     }
//     index == -1
//         ? model.isFavLoading = false
//         : context.read<SellerDetailProvider>().productList[index].isFavLoading =
//             false;
//     widget.update();
//   }

//   @override
//   Widget build(BuildContext context) {
//     int index = widget.index;
//     if (context.read<SellerDetailProvider>().productList.length > index) {
//       String? offPer;
//       double price = double.parse(context
//           .read<SellerDetailProvider>()
//           .productList[index]
//           .prVarientList![0]
//           .disPrice!);
//       if (price == 0) {
//         price = double.parse(context
//             .read<SellerDetailProvider>()
//             .productList[index]
//             .prVarientList![0]
//             .price!);
//       } else {
//         double off = double.parse(context
//                 .read<SellerDetailProvider>()
//                 .productList[index]
//                 .prVarientList![0]
//                 .price!) -
//             price;
//         offPer = ((off * 100) /
//                 double.parse(context
//                     .read<SellerDetailProvider>()
//                     .productList[index]
//                     .prVarientList![0]
//                     .price!))
//             .toStringAsFixed(2);
//       }

//       double width = deviceWidth! * 0.5;
//       Product model = context.read<SellerDetailProvider>().productList[index];
//       return Card(
//         elevation: 0.2,
//         margin: const EdgeInsetsDirectional.only(bottom: 2, end: 2),
//         child: InkWell(
//           borderRadius: BorderRadius.circular(circularBorderRadius10),
//           child: Stack(
//             children: [
//               Column(
//                 mainAxisSize: MainAxisSize.min,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: <Widget>[
//                   Expanded(
//                     child: ClipRRect(
//                       borderRadius: const BorderRadius.only(
//                         topLeft: Radius.circular(circularBorderRadius5),
//                         topRight: Radius.circular(circularBorderRadius5),
//                       ),
//                       child: Hero(
//                         transitionOnUserGestures: true,
//                         tag:
//                             '$heroTagUniqueString${context.read<SellerDetailProvider>().productList[index].id}$index',
//                         child: DesignConfiguration.getCacheNotworkImage(
//                           boxFit: BoxFit.cover,
//                           context: context,
//                           heightvalue: double.maxFinite,
//                           imageurlString: context
//                               .read<SellerDetailProvider>()
//                               .productList[index]
//                               .image!,
//                           placeHolderSize: width,
//                           widthvalue: double.maxFinite,
//                         ),
//                       ),
//                     ),
//                   ),
//                   Padding(
//                     padding: const EdgeInsetsDirectional.only(
//                       start: 10.0,
//                       top: 15,
//                     ),
//                     child: Text(
//                       context
//                           .read<SellerDetailProvider>()
//                           .productList[index]
//                           .name!,
//                       style: Theme.of(context).textTheme.titleSmall!.copyWith(
//                             color: Theme.of(context).colorScheme.fontColor,
//                             fontWeight: FontWeight.w400,
//                             fontFamily: 'ubuntu',
//                             fontStyle: FontStyle.normal,
//                           ),
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ),
//                   Padding(
//                     padding: const EdgeInsetsDirectional.only(
//                       start: 10.0,
//                       top: 5,
//                     ),
//                     child: Row(
//                       children: [
//                         Text(
//                           ' ${DesignConfiguration.getPriceFormat(context, price)!}',
//                           style: TextStyle(
//                             color: Theme.of(context).colorScheme.blue,
//                             fontSize: textFontSize14,
//                             fontWeight: FontWeight.w700,
//                             fontStyle: FontStyle.normal,
//                             fontFamily: 'ubuntu',
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   double.parse(context
//                               .read<SellerDetailProvider>()
//                               .productList[index]
//                               .prVarientList![0]
//                               .disPrice!) !=
//                           0
//                       ? Padding(
//                           padding: const EdgeInsetsDirectional.only(
//                             start: 10.0,
//                             top: 5,
//                           ),
//                           child: Row(
//                             children: <Widget>[
//                               Text(
//                                 double.parse(context
//                                             .read<SellerDetailProvider>()
//                                             .productList[index]
//                                             .prVarientList![0]
//                                             .disPrice!) !=
//                                         0
//                                     ? '${DesignConfiguration.getPriceFormat(context, double.parse(context.read<SellerDetailProvider>().productList[index].prVarientList![0].price!))}'
//                                     : '',
//                                 style: Theme.of(context)
//                                     .textTheme
//                                     .labelSmall!
//                                     .copyWith(
//                                         fontFamily: 'ubuntu',
//                                         decoration: TextDecoration.lineThrough,
//                                         decorationColor: colors.darkColor3,
//                                         decorationStyle:
//                                             TextDecorationStyle.solid,
//                                         decorationThickness: 2,
//                                         letterSpacing: 0,
//                                         fontSize: textFontSize10,
//                                         fontWeight: FontWeight.w400,
//                                         fontStyle: FontStyle.normal,
//                                         color: Theme.of(context)
//                                             .colorScheme
//                                             .lightBlack),
//                               ),
//                               Flexible(
//                                 child: Text(
//                                   '   ${double.parse(offPer!).round().toStringAsFixed(2)}%',
//                                   maxLines: 1,
//                                   overflow: TextOverflow.ellipsis,
//                                   style: Theme.of(context)
//                                       .textTheme
//                                       .labelSmall!
//                                       .copyWith(
//                                         fontFamily: 'ubuntu',
//                                         color: colors.primary,
//                                         letterSpacing: 0,
//                                         fontSize: textFontSize10,
//                                         fontWeight: FontWeight.w400,
//                                         fontStyle: FontStyle.normal,
//                                       ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         )
//                       : const SizedBox(),
//                   Padding(
//                     padding: const EdgeInsetsDirectional.only(
//                       start: 10.0,
//                       top: 10,
//                       bottom: 5.0,
//                     ),
//                     child: StarRating(
//                       totalRating: context
//                           .read<SellerDetailProvider>()
//                           .productList[index]
//                           .rating!,
//                       noOfRatings: context
//                           .read<SellerDetailProvider>()
//                           .productList[index]
//                           .noOfRating!,
//                       needToShowNoOfRatings: true,
//                     ),
//                   ),
//                 ],
//               ),
//               Positioned.directional(
//                 textDirection: Directionality.of(context),
//                 top: 0,
//                 end: 0,
//                 child: Container(
//                   decoration: BoxDecoration(
//                       color: Theme.of(context).colorScheme.white,
//                       borderRadius: const BorderRadiusDirectional.only(
//                           bottomStart: Radius.circular(circularBorderRadius10),
//                           topEnd: Radius.circular(circularBorderRadius5))),
//                   child: model.isFavLoading!
//                       ? const Padding(
//                           padding: EdgeInsets.all(8.0),
//                           child: SizedBox(
//                             height: 20,
//                             width: 20,
//                             child: CircularProgressIndicator(
//                               strokeWidth: 0.7,
//                             ),
//                           ),
//                         )
//                       : Selector<FavoriteProvider, List<String?>>(
//                           builder: (context, data, child) {
//                             return InkWell(
//                               child: Padding(
//                                 padding: const EdgeInsets.all(8.0),
//                                 child: Icon(
//                                   !data.contains(model.id)
//                                       ? Icons.favorite_border
//                                       : Icons.favorite,
//                                   size: 20,
//                                 ),
//                               ),
//                               onTap: () {
//                                 if (context.read<UserProvider>().userId != '') {
//                                   !data.contains(model.id)
//                                       ? context
//                                           .read<SellerDetailProvider>()
//                                           .setFavorateNow(
//                                             index: index,
//                                             model: model,
//                                             context: context,
//                                             update: widget.update,
//                                             showSanckBarNow:
//                                                 showSanckBarNowForAdd,
//                                           )
//                                       : context
//                                           .read<SellerDetailProvider>()
//                                           .removeFav(
//                                               index,
//                                               model,
//                                               context,
//                                               widget.update,
//                                               context
//                                                   .read<SellerDetailProvider>()
//                                                   .productList,
//                                               showSanckBarNowForRemove);
//                                 } else {
//                                   if (!data.contains(model.id)) {
//                                     model.isFavLoading = true;
//                                     model.isFav = '1';
//                                     context
//                                         .read<FavoriteProvider>()
//                                         .addFavItem(model);
//                                     db.addAndRemoveFav(model.id!, true);
//                                     model.isFavLoading = false;
//                                     setSnackbar(
//                                         getTranslated(
//                                             context, 'Added to favorite'),
//                                         context);
//                                   } else {
//                                     model.isFavLoading = true;
//                                     model.isFav = '0';
//                                     context
//                                         .read<FavoriteProvider>()
//                                         .removeFavItem(
//                                             model.prVarientList![0].id!);
//                                     db.addAndRemoveFav(model.id!, false);
//                                     model.isFavLoading = false;
//                                     setSnackbar(
//                                         getTranslated(
//                                             context, 'Removed from favorite'),
//                                         context);
//                                   }
//                                   setState(
//                                     () {},
//                                   );
//                                 }
//                               },
//                             );
//                           },
//                           selector: (_, provider) => provider.favIdList,
//                         ),
//                 ),
//               )
//             ],
//           ),
//           onTap: () {
//             Product model =
//                 context.read<SellerDetailProvider>().productList[index];
//             Navigator.push(
//               context,
//               PageRouteBuilder(
//                 pageBuilder: (_, __, ___) => ProductDetail(
//                   model: model,
//                   secPos: 0,
//                   index: index,
//                   list: false,
//                 ),
//               ),
//             );
//           },
//         ),
//       );
//     } else {
//       return const SizedBox();
//     }
//   }
// }
