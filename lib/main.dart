import 'package:carm2_base/app/ui/widgets/app_version_widget.dart';
import 'package:carm2_base/carm2_base.dart';
import 'package:flutter/material.dart';
import 'package:test_app/app/app_functions/login_service/service/login_service.dart';

void main() => runApp(Carm2Base(
      configuration: Carm2Configuration(
        appSettings: AppSettings(
          appId: 1,
          appName: '都アプリ',
          // backendBaseUrl:
          //     'https://dev014.carm2-app.wiz-services.com/CARM2CMS/client/',
          backendBaseUrl:
              'https://carm2-app.mykpht.com/CARM2CMS/client/',
          apiTimeoutDuration: const Duration(seconds: 120),
          useDummyData: false,
          dummyAppDataPath: 'test_resources/kyoroman_app_data.json',
        ),
        themeData: ThemeData(
          primarySwatch: Carm2Colors.grey,
        ),
        splashScreen: SplashScreen(),
        appFuncServicesOverrides: [
          CustomLoginService()
        ],
      ),
    ).start());

/// カスタム[MaterialColor]の例
/// 下記のサイトから自動作成できる
/// http://mcg.mbitson.com/#!?mcgpalette0=%233f51b5
class Carm2Colors {
  static const MaterialColor grey =
      MaterialColor(_carm2colorsPrimaryValue, <int, Color>{
    50: Color(0xFFF7F7F7),
    100: Color(0xFFEAEAEA),
    200: Color(0xFFDDDDDD),
    300: Color(0xFFCFCFCF),
    400: Color(0xFFC4C4C4),
    500: Color(_carm2colorsPrimaryValue),
    600: Color(0xFFB3B3B3),
    700: Color(0xFFABABAB),
    800: Color(0xFFA3A3A3),
    900: Color(0xFF949494),
  });
  static const int _carm2colorsPrimaryValue = 0xFFBABABA;

  static const MaterialColor carm2colorsAccent =
      MaterialColor(_carm2colorsAccentValue, <int, Color>{
    100: Color(0xFFFFFFFF),
    200: Color(_carm2colorsAccentValue),
    400: Color(0xFFFFCCCC),
    700: Color(0xFFFFB3B3),
  });
  static const int _carm2colorsAccentValue = 0xFFFFFFFF;
}

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: <Widget>[
            Container(
              constraints: BoxConstraints.expand(),
              // decoration: BoxDecoration(
              //   image: DecorationImage(
              //     image: AssetImage('assets/splash/karto_splash.png'),
              //     fit: BoxFit.cover,
              //   ),
              // ),
              child: Center(
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 30, horizontal: 30.0),
                  child: Image.asset(
                    'assets/splash/splash.png',
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: LinearProgressIndicator(),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 4.0, right: 4.0),
                child: AppVersionWidget(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
