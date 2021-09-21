import 'package:carm2_base/carm2_base.dart';
import 'package:flutter/material.dart';

void main() => runApp(Carm2Base(
      configuration: Carm2Configuration(
        appSettings: AppSettings(
          appId: 3,
          appName: '京ろまん',
          backendBaseUrl:
              'https://api.carm2test.wiz-services.com/CARM2CMS/api/',
          apiTimeoutDuration: const Duration(seconds: 30),
          useDummyData: false,
          dummyAppDataPath: 'test_resources/kyoroman_app_data.json',
        ),
        themeData: ThemeData(
          primarySwatch: Carm2Colors.grey,
        ),
        splashScreen: Carm2SplashScreen(),
        appFuncServicesOverrides: [],
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

class Carm2SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: <Widget>[
            Container(
              constraints: BoxConstraints.expand(),
              child: Center(
                child: Text(
                  'CARM2',
                  style: TextStyle(
                    fontSize: 18.0,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: LinearProgressIndicator(),
            ),
          ],
        ),
      ),
    );
  }
}
