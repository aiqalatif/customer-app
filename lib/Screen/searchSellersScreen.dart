import 'dart:async';

import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:eshop_multivendor/Helper/String.dart';
import 'package:eshop_multivendor/Helper/routes.dart';
import 'package:eshop_multivendor/Model/personalChatHistory.dart';
import 'package:eshop_multivendor/Screen/Language/languageSettings.dart';
import 'package:eshop_multivendor/Screen/NoInterNetWidget/NoInterNet.dart';
import 'package:eshop_multivendor/cubits/searchSellerCubit.dart';
import 'package:eshop_multivendor/widgets/errorContainer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SearchSellersScreen extends StatefulWidget {
  const SearchSellersScreen({Key? key}) : super(key: key);

  @override
  State<SearchSellersScreen> createState() => _SearchSellersScreenState();
}

class _SearchSellersScreenState extends State<SearchSellersScreen>
    with TickerProviderStateMixin {
  late AnimationController buttonController;
  late Animation buttonSqueezeanimation;

  late final TextEditingController searchQueryTextEditingController =
      TextEditingController()..addListener(searchQueryTextControllerListener);

  Timer? waitForNextSearchRequestTimer;

  int waitForNextRequestSearchQueryTimeInMilliSeconds = 500;

  @override
  void initState() {
    super.initState();
    buttonController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    buttonSqueezeanimation = Tween(
      begin: deviceWidth! * 0.7,
      end: 50.0,
    ).animate(
      CurvedAnimation(
        parent: buttonController,
        curve: const Interval(
          0.0,
          0.150,
        ),
      ),
    );
  }

  void searchQueryTextControllerListener() {
    waitForNextSearchRequestTimer?.cancel();
    setWaitForNextSearchRequestTimer();
  }

  void setWaitForNextSearchRequestTimer() {
    if (waitForNextRequestSearchQueryTimeInMilliSeconds != 400) {
      waitForNextRequestSearchQueryTimeInMilliSeconds = 400;
    }
    waitForNextSearchRequestTimer =
        Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (waitForNextRequestSearchQueryTimeInMilliSeconds == 0) {
        timer.cancel();
        if (searchQueryTextEditingController.text.trim().isNotEmpty) {
          context.read<SearchSellerCubit>().searchSeller(
                search: searchQueryTextEditingController.text.trim(),
              );
        }
      } else {
        waitForNextRequestSearchQueryTimeInMilliSeconds =
            waitForNextRequestSearchQueryTimeInMilliSeconds - 100;
      }
    });
  }

  @override
  void dispose() {
    buttonController.dispose();
    waitForNextSearchRequestTimer?.cancel();
    searchQueryTextEditingController
        .removeListener(searchQueryTextControllerListener);
    searchQueryTextEditingController.dispose();

    super.dispose();
  }

  Widget _buildSearchTextField() {
    return TextField(
      controller: searchQueryTextEditingController,
      autofocus: true,
      cursorColor: Theme.of(context).colorScheme.primary,
      style: TextStyle(color: Theme.of(context).colorScheme.secondary),
      decoration: InputDecoration(
        hintStyle: TextStyle(color: Theme.of(context).colorScheme.background),
        border: InputBorder.none,
        hintText: 'Search sellers',
      ),
    );
  }

  Widget _buildSearchTextContainer() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Text(
          getTranslated(context, 'SEARCH_SELLER'),
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 16.0,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
                iconSize: 26,
                color: Theme.of(context).colorScheme.secondary,
                onPressed: () {
                  searchQueryTextEditingController.clear();
                  setState(() {});
                },
                icon: const Icon(Icons.clear))
          ],
          title: _buildSearchTextField(),
          elevation: 0.5,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.arrow_back_ios),
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
        body: BlocBuilder<SearchSellerCubit, SearchSellerState>(
          builder: (context, state) {
            if (state is SearchSellerSuccess) {
              if (searchQueryTextEditingController.text.trim().isEmpty) {
                return _buildSearchTextContainer();
              }
              return ListView.builder(
                  itemCount: state.sellers.length,
                  itemBuilder: (context, index) {
                    final seller = state.sellers[index];
                    return ListTile(
                      leading: (seller.image ?? '').isEmpty
                          ? const Icon(Icons.person)
                          : SizedBox(
                              height: 25,
                              width: 25,
                              child: Image.network(seller.image!)),
                      onTap: () {
                        Navigator.of(context).pop();
                        Routes.navigateToConverstationScreen(
                            context: context,
                            personalChatHistory: PersonalChatHistory(
                                id: seller.id,
                                opponentUserId: seller.id,
                                unreadMsg: '0',
                                opponentUsername: seller.username,
                                image: seller.image),
                            isGroup: false);
                      },
                      title: Text(seller.username ?? '',
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.lightBlack)),
                    );
                  });
            }

            if (state is SearchSellerFailure) {
              if (state.errorMessage == 'No Internet connection') {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 50),
                    child: NoInterNet(
                        buttonController: buttonController,
                        buttonSqueezeanimation: buttonSqueezeanimation,
                        setStateNoInternate: () {
                          buttonController.forward().then((value) {
                            buttonController.value = 0;

                            context.read<SearchSellerCubit>().searchSeller(
                                search: searchQueryTextEditingController.text
                                    .trim());
                          });
                        }),
                  ),
                );
              }
              return Center(
                child: ErrorContainer(
                  errorMessage: state.errorMessage == 'Data not available !'
                      ? 'No seller found'
                      : state.errorMessage,
                  showBackButton: state.errorMessage != 'Data not available !',
                  onTapRetry: () {
                    context.read<SearchSellerCubit>().searchSeller(
                        search: searchQueryTextEditingController.text.trim());
                  },
                ),
              );
            }

            if (state is SearchSellerInitial) {
              return _buildSearchTextContainer();
            }

            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        ));
  }
}
