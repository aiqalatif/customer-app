// import 'package:eshop_multivendor/Helper/Color.dart';
// import 'package:eshop_multivendor/Screen/Language/languageSettings.dart';
// import 'package:flutter/material.dart';
// import '../../../Helper/Constant.dart';
// import '../../../Helper/String.dart';
// import '../../../widgets/desing.dart';
// import '../Seller_Details.dart';

// ChoiceChip? choiceChip;

// class ListViewLayOutWidget extends StatelessWidget {
//   dynamic filterList;
//   String minPrice;
//   String maxPrice;
//   Function setStateNow;
//   Function setListViewOnTap;
//   ListViewLayOutWidget(
//       {Key? key,
//       required this.filterList,
//       required this.maxPrice,
//       required this.minPrice,
//       required this.setListViewOnTap,
//       required this.setStateNow})
//       : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Expanded(
//       child: Container(
//         color: Theme.of(context).colorScheme.lightWhite,
//         padding:
//             const EdgeInsetsDirectional.only(start: 7.0, end: 7.0, top: 7.0),
//         child: filterList != null
//             ? ListView.builder(
//                 shrinkWrap: true,
//                 scrollDirection: Axis.vertical,
//                 padding: const EdgeInsetsDirectional.only(top: 10.0),
//                 itemCount: filterList.length + 1,
//                 itemBuilder: (context, index) {
//                   if (index == 0) {
//                     return Column(
//                       children: [
//                         if (currentRangeValues != null)
//                           SizedBox(
//                             width: deviceWidth,
//                             child: Card(
//                               elevation: 0,
//                               child: Padding(
//                                 padding: const EdgeInsets.all(8.0),
//                                 child: Text(
//                                   "${getTranslated(context, 'Price Range')} ($CUR_CURRENCY${currentRangeValues!.start.round().toString()} - $CUR_CURRENCY${currentRangeValues!.end.round().toString()})",
//                                   style: Theme.of(context)
//                                       .textTheme
//                                       .titleMedium!
//                                       .copyWith(
//                                         color: Theme.of(context)
//                                             .colorScheme
//                                             .lightBlack,
//                                         fontWeight: FontWeight.normal,
//                                         fontFamily: 'ubuntu',
//                                       ),
//                                   overflow: TextOverflow.ellipsis,
//                                   maxLines: 2,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         if (currentRangeValues != null)
//                           RangeSlider(
//                             values: currentRangeValues!,
//                             min: double.parse(minPrice),
//                             max: double.parse(maxPrice),
//                             onChanged: (RangeValues values) {
//                               currentRangeValues = values;
//                               setStateNow();
//                             },
//                           ),
//                       ],
//                     );
//                   } else {
//                     index = index - 1;
//                     attributeSubList =
//                         filterList[index]['attribute_values'].split(',');

//                     attributeIDList =
//                         filterList[index]['attribute_values_id'].split(',');

//                     List<Widget?> chips = [];
//                     List<String> att =
//                         filterList[index]['attribute_values']!.split(',');

//                     List<String> attSType =
//                         filterList[index]['swatche_type'].split(',');

//                     List<String> attSValue =
//                         filterList[index]['swatche_value'].split(',');

//                     for (int i = 0; i < att.length; i++) {
//                       Widget itemLabel;
//                       if (attSType[i] == '1') {
//                         String clr = (attSValue[i].substring(1));

//                         String color = '0xff$clr';

//                         itemLabel = Container(
//                           width: 25,
//                           decoration: BoxDecoration(
//                               shape: BoxShape.circle,
//                               color: Color(int.parse(color))),
//                         );
//                       } else if (attSType[i] == '2') {
//                         itemLabel = ClipRRect(
//                             borderRadius:
//                                 BorderRadius.circular(circularBorderRadius10),
//                             child: Image.network(attSValue[i],
//                                 width: 80,
//                                 height: 80,
//                                 errorBuilder: (context, error, stackTrace) =>
//                                     DesignConfiguration.erroWidget(80)));
//                       } else {
//                         itemLabel = Padding(
//                           padding: const EdgeInsets.symmetric(horizontal: 8.0),
//                           child: Text(
//                             att[i],
//                             style: TextStyle(
//                               color: selectedId!.contains(attributeIDList![i])
//                                   ? Theme.of(context).colorScheme.white
//                                   : Theme.of(context).colorScheme.fontColor,
//                               fontFamily: 'ubuntu',
//                             ),
//                           ),
//                         );
//                       }

//                       choiceChip = ChoiceChip(
//                         selected: selectedId!.contains(attributeIDList![i]),
//                         label: itemLabel,
//                         labelPadding: const EdgeInsets.all(0),
//                         selectedColor: colors.primary,
//                         backgroundColor: Theme.of(context).colorScheme.white,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(attSType[i] == '1'
//                               ? circularBorderRadius100
//                               : circularBorderRadius10),
//                           side: BorderSide(
//                               color: selectedId!.contains(attributeIDList![i])
//                                   ? colors.primary
//                                   : colors.secondary,
//                               width: 1.5),
//                         ),
//                         onSelected: (bool selected) {
//                           setListViewOnTap(index, selected, i);
//                         },
//                       );

//                       chips.add(choiceChip);
//                     }

//                     return Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         SizedBox(
//                           width: deviceWidth,
//                           child: Card(
//                             elevation: 0,
//                             child: Padding(
//                               padding: const EdgeInsets.all(8.0),
//                               child: Text(
//                                 filterList[index]['name'],
//                                 style: Theme.of(context)
//                                     .textTheme
//                                     .titleMedium!
//                                     .copyWith(
//                                       color: Theme.of(context)
//                                           .colorScheme
//                                           .fontColor,
//                                       fontWeight: FontWeight.normal,
//                                       fontFamily: 'ubuntu',
//                                     ),
//                                 overflow: TextOverflow.ellipsis,
//                                 maxLines: 2,
//                               ),
//                             ),
//                           ),
//                         ),
//                         chips.isNotEmpty
//                             ? Padding(
//                                 padding: const EdgeInsets.all(8.0),
//                                 child: Wrap(
//                                   children: chips.map<Widget>(
//                                     (Widget? chip) {
//                                       return Padding(
//                                         padding: const EdgeInsets.all(2.0),
//                                         child: chip,
//                                       );
//                                     },
//                                   ).toList(),
//                                 ),
//                               )
//                             : const SizedBox()
//                       ],
//                     );
//                   }
//                 },
//               )
//             : const SizedBox(),
//       ),
//     );
//   }
// }
