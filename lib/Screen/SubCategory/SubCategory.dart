import 'package:eshop_multivendor/Model/Section_Model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:eshop_multivendor/Helper/Color.dart';
import '../../Helper/Constant.dart';
import '../../widgets/appBar.dart';
import '../../widgets/desing.dart';
import '../ProductList&SectionView/ProductList.dart';

class SubCategory extends StatelessWidget {
  final List<Product>? subList;
  final String title;
  const SubCategory({Key? key, this.subList, required this.title})
      : super(key: key);
  setStateNow() {}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getAppBar(title, context, setStateNow),
      body: GridView.count(
        padding: const EdgeInsets.all(20),
        crossAxisCount: 3,
        shrinkWrap: true,
        childAspectRatio: .75,
        children: List.generate(
          subList!.length,
          (index) {
            return subCatItem(index, context);
          },
        ),
      ),
    );
  }

  subCatItem(int index, BuildContext context) {
    return GestureDetector(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(circularBorderRadius10),
                child: DesignConfiguration.getCacheNotworkImage(
                  boxFit: BoxFit.cover,
                  context: context,
                  heightvalue: null,
                  widthvalue: null,
                  placeHolderSize: 50,
                  imageurlString: subList![index].image!,
                ),
              ),
            ),
          ),
          Text(
            '${subList![index].name!}\n',
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  color: Theme.of(context).colorScheme.fontColor,
                  fontFamily: 'ubuntu',
                  fontSize: textFontSize14,
                ),
          )
        ],
      ),
      onTap: () {
        if (subList![index].subList == null ||
            subList![index].subList!.isEmpty) {
          Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => ProductList(
                name: subList![index].name,
                id: subList![index].id,
                tag: false,
                fromSeller: false,
              ),
            ),
          );
        } else {
          Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => SubCategory(
                subList: subList![index].subList,
                title: subList![index].name ?? '',
              ),
            ),
          );
        }
      },
    );
  }
}
