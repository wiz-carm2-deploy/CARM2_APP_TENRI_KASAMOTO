import 'package:carm2_base/app/ui/widgets/app_version_widget.dart';
import 'package:carm2_base/carm2_base.dart';
import 'package:flutter/material.dart';
import 'package:test_app/app/app_functions/attributes_editor/service/attribute_editor_service.dart';
import 'package:test_app/app/app_functions/login_service/service/login_service.dart';

void main() => runApp(Carm2Base(
      configuration: Carm2Configuration(
        appSettings: AppSettings(
          appId: 1,
          appName: '都アプリ',
          backendBaseUrl: 'https://carm2-app.mykpht.com/CARM2CMS/client/',
          apiTimeoutDuration: const Duration(seconds: 120),
          useDummyData: false,
          dummyAppDataPath: 'test_resources/kyoroman_app_data.json',
        ),
        themeData: ThemeData(
          primarySwatch: Carm2Colors.frogColor,
        ),
        splashScreen: SplashScreen(),
        appFuncServicesOverrides: [
          CustomLoginService(),
          CustomAttributeEditorService(),
        ],
      ),
    ).start());

/// カスタム[MaterialColor]の例
/// 下記のサイトから自動作成できる
/// http://mcg.mbitson.com/#!?mcgpalette0=%233f51b5
class Carm2Colors {
  static const MaterialColor frogColor =
      MaterialColor(_mcgpalette0PrimaryValue, <int, Color>{
    50: Color(0xFFE5F6F3),
    100: Color(0xFFBFE9E0),
    200: Color(0xFF94DACC),
    300: Color(0xFF69CBB8),
    400: Color(0xFF48BFA8),
    500: Color(_mcgpalette0PrimaryValue),
    600: Color(0xFF24AD91),
    700: Color(0xFF1EA486),
    800: Color(0xFF189C7C),
    900: Color(0xFF0F8C6B),
  });
  static const int _mcgpalette0PrimaryValue = 0xFF28B499;

  static const MaterialColor mcgpalette0Accent =
      MaterialColor(_mcgpalette0AccentValue, <int, Color>{
    100: Color(0xFFBEFFEC),
    200: Color(_mcgpalette0AccentValue),
    400: Color(0xFF58FFCD),
    700: Color(0xFF3EFFC6),
  });
  static const int _mcgpalette0AccentValue = 0xFF8BFFDC;
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
