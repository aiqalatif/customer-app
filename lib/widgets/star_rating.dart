// import 'package:eshop_multivendor/Helper/Color.dart';
// import 'package:eshop_multivendor/Helper/Constant.dart';
// import 'package:flutter/material.dart';

// class StarRating extends StatelessWidget {
//   String totalRating, noOfRatings;
//   bool needToShowNoOfRatings;

//   StarRating({
//     Key? key,
//     required this.totalRating,
//     required this.noOfRatings,
//     required this.needToShowNoOfRatings,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     if (double.parse(totalRating) > 0) {
//       return Row(
//         children: [
//           Container(
//             width: 15,
//             height: 15,
//             decoration: BoxDecoration(
//               gradient: const LinearGradient(
//                 begin: Alignment(0, 0),
//                 end: Alignment(1, 1),
//                 colors: [
//                   colors.grad1Color,
//                   colors.grad2Color,
//                 ],
//               ),
//               borderRadius: BorderRadius.circular(circularBorderRadius3),
//             ),
//             child: const FittedBox(
//               child: Icon(
//                 Icons.star,
//                 color: Colors.white,
//               ),
//             ),
//           ),
//           const SizedBox(
//             width: 5.0,
//           ),
//           Flexible(
//             child: Text(
//               double.parse(totalRating)
//                   .toStringAsFixed(1)
//                   .trim()
//                   .replaceAll('.0', ''),
//               style: const TextStyle(
//                 fontFamily: 'ubuntu',
//               ),
//             ),
//           ),
//           /*needToShowNoOfRatings
//             ? const SizedBox(
//                 width: 5.0,
//               )
//             : SizedBox(),*/
//           needToShowNoOfRatings
//               ? Flexible(
//                   child: Text(
//                     '($noOfRatings)',
//                     style: const TextStyle(
//                       fontSize: textFontSize10,
//                       fontWeight: FontWeight.w300,
//                       fontStyle: FontStyle.normal,
//                       fontFamily: 'ubuntu',
//                     ),
//                   ),
//                 )
//               : const SizedBox(),
//         ],
//       );
//     } else {
//       return const SizedBox.shrink();
//     }
//   }
// }
