import 'package:eshop_multivendor/Model/Section_Model.dart';
import 'package:eshop_multivendor/Screen/Product%20Detail/productDetail.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Helper/String.dart';
import '../../Provider/productDetailProvider.dart';
import '../../widgets/appBar.dart';
import '../../widgets/desing.dart';
import '../Language/languageSettings.dart';
import 'Widget/compareProductWidget.dart';

class CompareList extends StatefulWidget {
  const CompareList({Key? key}) : super(key: key);

  @override
  _CompareListState createState() => _CompareListState();
}

class _CompareListState extends State<CompareList> {
  int maxLength = 0;
  setStateNow() {
    setState(() {});
  }

  @override
  void initState() {
    List val = [];

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      List compareList = context.read<ProductDetailProvider>().compareList;
      for (int i = 0;
          i < context.read<ProductDetailProvider>().compareList.length;
          i++) {
        if (compareList[i]!.prVarientList![0].attr_name != '') {
          val.add(
              compareList[i]!.prVarientList![0].attr_name!.split(',').length);
        }
      }
      if (val.isNotEmpty) {
        maxLength = val.reduce((curr, next) => curr > next ? curr : next);
        setState(() {});
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getAppBar(
          getTranslated(context, 'COMPARE_PRO'), context, setStateNow),
      body: Selector<ProductDetailProvider, List<Product>>(
        builder: (context, data, child) {
          return data.isEmpty
              ? DesignConfiguration.getNoItem(context)
              : ScrollConfiguration(
                  behavior: MyBehavior(),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: data.length,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      return listItem(index, data);
                    },
                  ),
                );
        },
        selector: (_, categoryProvider) => categoryProvider.compareList,
      ),
    );
  }

  Widget listItem(int index, List<Product> compareList) {
    Product model = compareList[index];
    String? gaurantee = compareList[index].gurantee;
    String? returnable = compareList[index].isReturnable;
    String? cancleable = compareList[index].isCancelable;
    if (cancleable == '1') {
      cancleable = 'Till ${compareList[index].cancleTill!}';
    } else {
      cancleable = 'No';
    }
    String? warranty = compareList[index].warranty;

    String? madeIn = compareList[index].madein;

    double price =
        double.parse(model.prVarientList![model.selVarient!].disPrice!);
    if (price == 0) {
      price = double.parse(model.prVarientList![model.selVarient!].price!);
    }
    List att = [], val = [];
    if (model.prVarientList![model.selVarient!].attr_name != '') {
      att = model.prVarientList![model.selVarient!].attr_name!.split(',');
      val = model.prVarientList![model.selVarient!].varient_value!.split(',');
    }
    return SingleChildScrollView(
      child: Card(
        elevation: 0,
        child: SizedBox(
          width: deviceWidth! * 0.45,
          child: InkWell(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextButton.icon(
                  onPressed: () {
                    setState(
                      () {
                        compareList.removeWhere(
                            (item) => item.id == compareList[index].id);
                        List val = [];
                        for (int i = 0; i < compareList.length; i++) {
                          if (compareList[i].prVarientList![0].attr_name !=
                              '') {
                            val.add(compareList[i]
                                .prVarientList![0]
                                .attr_name!
                                .split(',')
                                .length);
                          }
                        }
                        if (val.isNotEmpty) {
                          maxLength = val.reduce(
                              (curr, next) => curr > next ? curr : next);
                        }
                      },
                    );
                  },
                  icon: const Icon(Icons.close),
                  label: Text(
                    getTranslated(context, 'REMOVE'),
                    style: const TextStyle(
                      fontFamily: 'ubuntu',
                    ),
                  ),
                ),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    getImagePart(model.image!, index, model.id, context),
                    OutOffStockLableWidget(availability: model.availability!),
                  ],
                ),
                getRattingIcons(context, model.rating),
                getProductName(model.name!),
                getPriceFields(model, context, price),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.only(bottom: 5.0),
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: maxLength,
                          itemBuilder: (context, index) {
                            if (model.prVarientList![model.selVarient!]
                                        .attr_name !=
                                    '' &&
                                model.prVarientList![model.selVarient!]
                                    .attr_name!.isNotEmpty &&
                                index < att.length) {
                              return getListViewIteam(
                                  att[index].trim(), val[index]);
                            } else {
                              return const Text(' ');
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                commanField(
                    madeIn, getTranslated(context, 'MADE_IN'), context),
                commanField(
                    warranty, getTranslated(context, 'WARRENTY'), context),
                commanField(
                    gaurantee, getTranslated(context, 'GAURANTEE'), context),
                isReturnable(returnable, context),
                isCancelable(cancleable, context),
              ],
            ),
            onTap: () {
              Product? model = compareList[index];
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => ProductDetail(
                    model: model,
                    secPos: index,
                    index: index,
                    list: true,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
