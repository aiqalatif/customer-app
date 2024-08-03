import 'package:cached_network_image/cached_network_image.dart';
import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:eshop_multivendor/Helper/String.dart';
import 'package:eshop_multivendor/Helper/routes.dart';
import 'package:eshop_multivendor/Provider/UserProvider.dart';
import 'package:eshop_multivendor/Screen/Language/languageSettings.dart';
import 'package:eshop_multivendor/Screen/NoInterNetWidget/NoInterNet.dart';
import 'package:eshop_multivendor/cubits/personalConverstationsCubit.dart';
import 'package:eshop_multivendor/widgets/appBar.dart';
import 'package:eshop_multivendor/widgets/errorContainer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ConverstationListScreen extends StatefulWidget {
  const ConverstationListScreen({Key? key}) : super(key: key);

  @override
  State<ConverstationListScreen> createState() =>
      ConverstationListScreenState();
}

class ConverstationListScreenState extends State<ConverstationListScreen>
    with TickerProviderStateMixin {
  final TextEditingController _textEditingController = TextEditingController();

  late AnimationController buttonController;
  late Animation buttonSqueezeanimation;

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
    Future.delayed(Duration.zero, () {
      context.read<PersonalConverstationsCubit>().fetchConverstations(
          currentUserId: context.read<UserProvider>().userId!);
    });
  }

  @override
  void dispose() {
    buttonController.dispose();
    _textEditingController.dispose();
    super.dispose();
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: GestureDetector(
        onTap: () async {
          Routes.navigateToSearchSellerScreen(context);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          decoration: BoxDecoration(color: Theme.of(context).colorScheme.white),
          child: Row(
            children: [
              Text(
                getTranslated(context, 'SEARCH_SELLER'),
                style: const TextStyle(fontSize: 15.0),
              ),
              const Spacer(),
              const Icon(Icons.search),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPersonalConverstationsContainer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BlocBuilder<PersonalConverstationsCubit, PersonalConverstationsState>(
          builder: (context, state) {
            if (state is PersonalConverstationsFetchSuccess) {
              return Column(
                children: state.personalConverstations.map(
                  (personalChatHistory) {
                    final unreadMessages = personalChatHistory.getUnreadMessage(
                        userId: context.read<UserProvider>().userId!);
                    return ListTile(
                      onTap: () async {
                        Routes.navigateToConverstationScreen(
                            isGroup: false,
                            context: context,
                            personalChatHistory: personalChatHistory);
                      },
                      tileColor: Theme.of(context).colorScheme.white,
                      title: Text(
                        personalChatHistory.opponentUsername ?? '',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.lightBlack),
                      ),
                      leading: (personalChatHistory.image ?? '').isEmpty
                          ? const Icon(Icons.person)
                          : SizedBox(
                              height: 25,
                              width: 25,
                              child: CachedNetworkImage(
                                imageUrl: personalChatHistory.image!,
                                errorWidget: (context, url, error) {
                                  return const Icon(Icons.person);
                                },
                              )),
                      trailing:
                          (unreadMessages.isNotEmpty && unreadMessages != '0')
                              ? CircleAvatar(
                                  radius: 14,
                                  child: Text(
                                    personalChatHistory.unreadMsg!,
                                    style: const TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                )
                              : const SizedBox(),
                    );
                  },
                ).toList(),
              );
            }
            if (state is PersonalConverstationsFetchFailure) {
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
                            context
                                .read<PersonalConverstationsCubit>()
                                .fetchConverstations(
                                    currentUserId:
                                        context.read<UserProvider>().userId!);
                          });
                        }),
                  ),
                );
              }
              return Center(
                child: ErrorContainer(
                    onTapRetry: () {
                      context
                          .read<PersonalConverstationsCubit>()
                          .fetchConverstations(
                              currentUserId:
                                  context.read<UserProvider>().userId!);
                    },
                    errorMessage: state.errorMessage),
              );
            }
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.0,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getSimpleAppBar(getTranslated(context, 'CHAT'), context),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          _buildSearchBar(),
          _buildPersonalConverstationsContainer(),
        ],
      ),
    );
  }
}
