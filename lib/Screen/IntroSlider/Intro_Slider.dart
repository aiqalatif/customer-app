import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:eshop_multivendor/Helper/Constant.dart';
import 'package:eshop_multivendor/Helper/routes.dart';
import 'package:eshop_multivendor/Provider/Theme.dart';
import 'package:eshop_multivendor/Screen/IntroSlider/Widgets/SliderClass.dart';
import 'package:eshop_multivendor/Screen/Profile/widgets/languageBottomSheet.dart';
import 'package:eshop_multivendor/widgets/bottomSheet.dart';
import 'package:eshop_multivendor/widgets/desing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../Helper/String.dart';
import '../../widgets/systemChromeSettings.dart';
import '../Language/languageSettings.dart';
import 'Widgets/AllBtn.dart';
import 'Widgets/SetSlider.dart';



class IntroSlider extends StatefulWidget {
  const IntroSlider({Key? key}) : super(key: key);

  @override
  _GettingStartedScreenState createState() => _GettingStartedScreenState();
}

class _GettingStartedScreenState extends State<IntroSlider>
    with TickerProviderStateMixin {
  int _currentPage = 0;
  final PageController _pageController = PageController(initialPage: 0);
  Animation? buttonSqueezeanimation;
  AnimationController? buttonController;
  late List slideList = [];

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      SystemChromeSettings.setSystemChromes(
          isDarkTheme: Provider.of<ThemeNotifier>(context, listen: false)
                  .getThemeMode() ==
              ThemeMode.dark);
    });

    Future.delayed(
      Duration.zero,
      () {
        setState(
          () {
            slideList = [
              Slide(
                imageUrl: 'introimage_a',
                title: getTranslated(context, 'TITLE1_LBL'),
                description: getTranslated(context, 'DISCRIPTION1'),
              ),
              Slide(
                imageUrl: 'introimage_b',
                title: getTranslated(context, 'TITLE2_LBL'),
                description: getTranslated(context, 'DISCRIPTION2'),
              ),
              Slide(
                imageUrl: 'introimage_c',
                title: getTranslated(context, 'TITLE3_LBL'),
                description: getTranslated(context, 'DISCRIPTION3'),
              ),
            ];
          },
        );
      },
    );

    buttonController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    buttonSqueezeanimation = Tween(
      begin: deviceWidth! * 0.9,
      end: 50.0,
    ).animate(
      CurvedAnimation(
        parent: buttonController!,
        curve: const Interval(
          0.0,
          0.150,
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
    buttonController!.dispose();
  }

  _onPageChanged(int index) {
    if (mounted) {
      setState(() {
        _currentPage = index;
      });
    }
  }

 

  @override
  Widget build(BuildContext context) {
    deviceHeight = MediaQuery.of(context).size.height;
    deviceWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Padding(
            //   padding: const EdgeInsets.all(8.0),
            //   child: Column(
            //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //     children: [
            //       Text(
            //         'Select Language:',
            //         style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            //       ),
            //      _getDrawerItem(
            // getTranslated(context, 'CHANGE_LANGUAGE_LBL'), 'pro_language'),
               
            //     ],
            //   ),
            // ),
            skipBtn(
              context,
              _currentPage,
            ),
            slider(
              slideList,
              _pageController,
              context,
              _onPageChanged,
            ),
            SliderBtn(
              currentPage: _currentPage,
              pageController: _pageController,
              sliderList: slideList,
            ),
          ],
        ),
      ),
    );
  }
  //  _getDrawerItem(String title, String img) {
  //   return Card(
  //     elevation: 0.1,
  //     child: ListTile(
  //       trailing: const Icon(
  //         Icons.navigate_next,
  //         color: colors.primary,
  //       ),
  //       leading: SvgPicture.asset(
  //         DesignConfiguration.setSvgPath(img),
  //         height: 25,
  //         width: 25,
  //         colorFilter: const ColorFilter.mode(colors.primary, BlendMode.srcIn),
  //       ),
  //       dense: true,
  //       title: Text(
  //         title,
  //         style: TextStyle(
  //           color: Theme.of(context).colorScheme.lightBlack,
  //           fontSize: textFontSize15,
  //         ),
  //       ),
  //       onTap: () {
  //         if (title == getTranslated(context, 'MY_ORDERS_LBL')) {
  //           Routes.navigateToMyOrderScreen(context);
  //         } else if (title == getTranslated(context, 'CHANGE_LANGUAGE_LBL')) {
  //           CustomBottomSheet.showBottomSheet(
  //               child: LanguageBottomSheet(),
  //               context: context,
  //               enableDrag: true);
  //         } 
  //       },
  //     ),
  //   );
  // }

}
