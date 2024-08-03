import 'package:eshop_multivendor/Helper/Constant.dart';
import 'package:eshop_multivendor/Model/groupDetails.dart';
import 'package:eshop_multivendor/Model/personalChatHistory.dart';
import 'package:eshop_multivendor/Screen/converstationListScreen.dart';
import 'package:eshop_multivendor/Screen/converstationScreen.dart';
import 'package:eshop_multivendor/Screen/groupInfoScreen.dart';
import 'package:eshop_multivendor/Screen/searchSellersScreen.dart';
import 'package:eshop_multivendor/cubits/converstationCubit.dart';
import 'package:eshop_multivendor/cubits/searchSellerCubit.dart';
import 'package:eshop_multivendor/cubits/sendMessageCubit.dart';
import 'package:eshop_multivendor/repository/chatRepository.dart';
import 'package:eshop_multivendor/repository/sellerDetailRepositry.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../Screen/Auth/Login.dart';
import '../Screen/Cart/Cart.dart';
import '../Screen/Chat/Chat.dart';
import '../Screen/CompareList/CompareList.dart';
import '../Screen/CustomerSupport/Customer_Support.dart';
import '../Screen/FAQsList/FaqsList.dart';
import '../Screen/Favourite/Favorite.dart';
import '../Screen/Manage Address/Manage_Address.dart';
import '../Screen/My Wallet/My_Wallet.dart';
import '../Screen/MyOrder/MyOrder.dart';
import '../Screen/OrderSuccess/Order_Success.dart';
import '../Screen/PrivacyPolicy/Privacy_Policy.dart';
import '../Screen/ProductPreview/productPreview.dart';
import '../Screen/PromoCode/PromoCode.dart';
import '../Screen/ReferAndEarn/ReferEarn.dart';
import '../Screen/ReviewGallary/reviewGallary.dart';
import '../Screen/ReviewPreview/review_Preview.dart';
import '../Screen/Search/Search.dart';
import '../Screen/SellerDetail/Seller_Details.dart';
import '../Screen/SplashScreen/Splash.dart';
import '../Screen/Transaction/userTransactionsScreen.dart';
import '../Screen/Language/languageSettings.dart';

class Routes {
  static navigateToSearchScreen(BuildContext context) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => const Search(),
      ),
    );
  }

  static navigateToReviewGallaryScreen(BuildContext context) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => const ReviewGallary(),
      ),
    );
  }

  static navigateToProductPreviewScreen(BuildContext context) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => const ProductPreview(),
      ),
    );
  }

  static navigateToCompareListScreen(BuildContext context) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => const CompareList(),
      ),
    );
  }

  static navigateToReferEarnScreen(BuildContext context) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => const ReferEarn(),
      ),
    );
  }

  static navigateToFaqsListScreen(BuildContext context) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => const FaqsList(),
      ),
    );
  }

  static navigateToReviewPreviewScreen(BuildContext context) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => const ReviewPreview(),
      ),
    );
  }

  static navigateToFavoriteScreen(BuildContext context) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => const Favorite(),
      ),
    );
  }

  static navigateToSplashScreen(BuildContext context) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => const Splash(),
      ),
    );
  }

  static navigateToCustomerSupportScreen(BuildContext context) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => const CustomerSupport(),
      ),
    );
  }

  static Future<dynamic> navigateToLoginScreen(BuildContext context,
      {Widget? classType, required bool isPop, bool? isRefresh}) {
    return Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) =>
            Login(isPop: isPop, isRefresh: isRefresh, classType: classType),
      ),
    );
  }

  static navigateToUserTransactionsScreen(BuildContext context) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => const UserTransactions(),
      ),
    );
  }

  static navigateToMyOrderScreen(BuildContext context) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => const MyOrder(),
      ),
    );
  }

  static navigateToMyWalletScreen(BuildContext context) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => const MyWallet(),
      ),
    );
  }

  static navigateToPrivacyPolicyScreen(
      {required BuildContext context, required String title}) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => PrivacyPolicy(
          title: getTranslated(context, title),
        ),
      ),
    );
  }

  // Push Replacement Routes

  static navigateToOrderSuccessScreen(BuildContext context) {
    Navigator.pushAndRemoveUntil(
        context,
        CupertinoPageRoute(
            builder: (BuildContext context) => const OrderSuccess()),
        ModalRoute.withName('/home'));
  }

  // pop the current page
  static pop(BuildContext context) {
    Navigator.pop(context);
  }

  // Routes With Parameters
  static navigateToChatScreen(
      BuildContext context, String? id, String? status) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => Chat(
          id: id,
          status: status,
        ),
      ),
    );
  }

  static navigateToManageAddressScreen(BuildContext context, bool? home) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => ManageAddress(
          home: home,
        ),
      ),
    );
  }

  static navigateToCartScreen(BuildContext context, bool from,
      {bool isFromCart = false}) {
    if (isFromCart) {
      Navigator.of(context).pop();
    } else {
      Navigator.push(
        context,
        CupertinoPageRoute(
          builder: (context) => Cart(
            fromBottom: from,
          ),
        ),
      );
    }
  }

  static navigateToPromoCodeScreen(
      BuildContext context, String from, Function updateParentNow) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => PromoCode(
          from: from,
          updateParent: updateParentNow,
        ),
      ),
    );
  }

  static navigateToSellerProfileScreen(
    BuildContext context,
    String? sellerId,
    String? sellerImage,
    String? sellerName,
    String? sellerRatting,
    String? sellerStorename,
    String? storeDescription,
    String? totalProductsOfSeller,
    String? noOfRatingsOnSeller,
  ) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => SellerProfile(
          sellerID: sellerId,
          sellerImage: sellerImage,
          sellerName: sellerName,
          sellerRating: sellerRatting,
          sellerStoreName: sellerStorename,
          totalProductsOfSeller: totalProductsOfSeller,
          storeDesc: storeDescription,
          noOfRatings: noOfRatingsOnSeller
        ),
      ),
    );
  }

  ///
  ///Chat related navitation function
  ///

  static navigateToConverstationListScreen(BuildContext context) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => ConverstationListScreen(
          key: converstationListScreenStateKey,
        ),
      ),
    );
  }

  static navigateToConverstationScreen(
      {required BuildContext context,
      PersonalChatHistory? personalChatHistory,
      GroupDetails? groupDetails,
      required bool isGroup}) {
    converstationScreenStateKey = GlobalKey<ConverstationScreenState>();
    Navigator.of(context).push(CupertinoPageRoute(
        builder: (_) => MultiBlocProvider(
                providers: [
                  BlocProvider(
                    create: (_) => ConverstationCubit(ChatRepository()),
                  ),
                  BlocProvider(
                      create: (_) => SendMessageCubit(ChatRepository()))
                ],
                child: ConverstationScreen(
                    groupDetails: groupDetails,
                    key: converstationScreenStateKey,
                    isGroup: isGroup,
                    personalChatHistory: personalChatHistory))));
  }

  static navigateToSearchSellerScreen(BuildContext context) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => BlocProvider(
          create: (context) => SearchSellerCubit(SellerDetailRepository()),
          child: const SearchSellersScreen(),
        ),
      ),
    );
  }

  static navigateToGroupInfoScreen(
      BuildContext context, GroupDetails groupDetails) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => GroupInfoScreen(groupDetails: groupDetails),
      ),
    );
  }
}
