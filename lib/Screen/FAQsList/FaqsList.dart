import 'dart:async';
import 'package:eshop_multivendor/Provider/FaqsProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Helper/Color.dart';
import '../../Helper/Constant.dart';
import '../../Model/Faqs_Model.dart';
import '../../widgets/appBar.dart';
import '../../widgets/desing.dart';
import '../Language/languageSettings.dart';
import '../../widgets/simmerEffect.dart';

class FaqsList extends StatefulWidget {
  const FaqsList({Key? key}) : super(key: key);

  @override
  _FaqsListState createState() => _FaqsListState();
}

class _FaqsListState extends State<FaqsList> with TickerProviderStateMixin {
  bool isLoadingMore = false;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  ScrollController controller = ScrollController();

  int selectedIndex = -1;
  bool flag = true;

  @override
  void initState() {
    Future.delayed(Duration.zero).then(
        (value) => context.read<FaqsProvider>().getFaqs(isLoadingMore: false));

    controller.addListener(_scrollListener);

    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.white,
      key: _scaffoldKey,
      appBar: getSimpleAppBar(getTranslated(context, 'FAQS'), context),
      body: Consumer<FaqsProvider>(
        builder: (context, value, child) {
          if (value.getCurrentStatus == FaqsStatus.isSuccsess) {
            return showContent(value.faqsList);
          } else if (value.getCurrentStatus == FaqsStatus.isFailure) {
            return Center(
              child: Text(
                value.errorMessage,
                style: const TextStyle(
                  fontFamily: 'ubuntu',
                ),
              ),
            );
          }
          return const ShimmerEffect();
        },
      ),
    );
  }

  showContent(List<FaqsModel>? faqList) {
    return faqList!.isEmpty
        ? DesignConfiguration.getNoItem(context)
        : Stack(
            children: [
              ListView.builder(
                shrinkWrap: true,
                controller: controller,
                itemCount: faqList.length,
                physics: const AlwaysScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return (index == faqList.length && isLoadingMore)
                      ? const SingleItemSimmer()
                      : listItem(faqList, index);
                },
              ),
            ],
          );
  }

  listItem(List<FaqsModel> faqsList, int index) {
    return Card(
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(circularBorderRadius4),
        onTap: () {
          if (mounted) {
            setState(
              () {
                selectedIndex = index;
                flag = !flag;
              },
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    faqsList[index].question!,
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                          color: Theme.of(context).colorScheme.lightBlack,
                          fontFamily: 'ubuntu',
                        ),
                  )),
              selectedIndex != index || flag
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              faqsList[index].answer!,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall!
                                  .copyWith(
                                    fontFamily: 'ubuntu',
                                    color: Theme.of(context)
                                        .colorScheme
                                        .black
                                        .withOpacity(0.7),
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        const Icon(Icons.keyboard_arrow_down)
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              faqsList[index].answer!,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall!
                                  .copyWith(
                                    fontFamily: 'ubuntu',
                                    color: Theme.of(context)
                                        .colorScheme
                                        .black
                                        .withOpacity(0.7),
                                  ),
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.keyboard_arrow_up,
                        )
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }

  _scrollListener() async {
    if (controller.offset >= controller.position.maxScrollExtent &&
        !controller.position.outOfRange &&
        !isLoadingMore) {
      if (mounted) {
        if (context.read<FaqsProvider>().hasMoreData) {
          setState(
            () {
              isLoadingMore = true;
            },
          );
          await context.read<FaqsProvider>().getFaqs(isLoadingMore: false).then(
            (value) {
              setState(
                () {
                  isLoadingMore = false;
                },
              );
            },
          );
        }
      }
    }
  }
}
