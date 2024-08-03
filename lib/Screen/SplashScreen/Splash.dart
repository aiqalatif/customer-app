import 'dart:async';
import 'package:eshop_multivendor/Provider/SettingProvider.dart';
import 'package:eshop_multivendor/Provider/Theme.dart';
import 'package:eshop_multivendor/Provider/homePageProvider.dart';
import 'package:eshop_multivendor/Screen/IntroSlider/Intro_Slider.dart';
import 'package:eshop_multivendor/Screen/NoInterNetWidget/NoInterNet.dart';
import 'package:eshop_multivendor/cubits/appSettingsCubit.dart';
import 'package:eshop_multivendor/widgets/applogo.dart';
import 'package:eshop_multivendor/widgets/errorContainer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import '../../Helper/String.dart';
import '../../widgets/desing.dart';
import '../../widgets/systemChromeSettings.dart';

//splash screen of app
class Splash extends StatefulWidget {
  const Splash({Key? key}) : super(key: key);

  @override
  _SplashScreen createState() => _SplashScreen();
}

class _SplashScreen extends State<Splash> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late AnimationController buttonController;
  late Animation buttonSqueezeanimation;
  bool from = false;
  late AnimationController navigationContainerAnimationController =
      AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 200),
  );

  @override
  void initState() {
    buttonController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    Future.delayed(Duration.zero, () {
      SystemChromeSettings.setSystemChromes(
          isDarkTheme: Provider.of<ThemeNotifier>(context, listen: false)
                  .getThemeMode() ==
              ThemeMode.dark);
    });
    initializeAnimationController();
    Future.delayed(Duration.zero, () {
      context.read<AppSettingsCubit>().fetchAndStoreAppSettings();
      context
          .read<HomePageProvider>()
          .getSections(isnotify: false, context: context);
    });
    super.initState();
  }

  void initializeAnimationController() {
    Future.delayed(
      Duration.zero,
      () {
        context.read<HomePageProvider>()
          ..setAnimationController(navigationContainerAnimationController)
          ..setBottomBarOffsetToAnimateController(
              navigationContainerAnimationController)
          ..setAppBarOffsetToAnimateController(
              navigationContainerAnimationController);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    deviceHeight = MediaQuery.of(context).size.height;
    deviceWidth = MediaQuery.of(context).size.width;
    buttonSqueezeanimation = Tween(
      begin: MediaQuery.of(context).size.width * 0.7,
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
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
      child: Scaffold(
        key: _scaffoldKey,
        body: BlocConsumer<AppSettingsCubit, AppSettingsState>(
          listener: (context, state) {
            if (state is AppSettingsSuccess) {
              navigationPage();
            }
          },
          builder: (context, state) {
            if (state is AppSettingsFailure) {
              if (state.message.contains('No Internet connection')) {
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
                                .read<AppSettingsCubit>()
                                .fetchAndStoreAppSettings();
                          });
                        }),
                  ),
                );
              }
              return Center(
                child: ErrorContainer(
                    onTapRetry: () {
                      context
                          .read<AppSettingsCubit>()
                          .fetchAndStoreAppSettings();
                    },
                    errorMessage: state.message),
              );
            }
            return Stack(
              children: <Widget>[
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: DesignConfiguration.back(),
                  child:  Center(
                    child: SvgPicture.asset(
                  DesignConfiguration.setSvgPath('splashlogo'),
                  // fit: BoxFit.fill,
                  width: 150,
                   height: 150,
                ),
                    // AppLogo(
                    //   width: 150,
                    //   height: 150,
                    //   colorFilter:
                    //       ColorFilter.mode(Colors.white, BlendMode.srcIn),
                    // ),
                  ),
                ),
                Image.asset(
                  DesignConfiguration.setPngPath('doodle'),
                  fit: BoxFit.fill,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> navigationPage() async {
    SettingProvider settingsProvider =
        Provider.of<SettingProvider>(context, listen: false);

    bool isFirstTime = await settingsProvider.getPrefrenceBool(ISFIRSTTIME);
    if (isFirstTime) {
      setState(
        () {
          from = true;
        },
      );
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      setState(
        () {
          from = false;
        },
      );
      Navigator.pushReplacement(
        context,
        CupertinoPageRoute(
          builder: (context) => const IntroSlider(),
        ),
      );
    }
  }
}
