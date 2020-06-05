import 'package:carm2_base/app/blocs/navigation_bloc.dart';
import 'package:carm2_base/app/resources/models/app_func.dart';
import 'package:carm2_base/app/services/abstract_app_func_service.dart';
import 'package:carm2_base/carm2_base.dart';
import 'package:flutter/material.dart';

void main() => runApp(Carm2Base(
      configuration: Carm2Configuration(
        appSettings: AppSettings(
          appId: 3,
          appName: '京ろまん',
          backendBaseUrl: 'https://api.carm2test.wiz-services.com/CARM2CMS/api/',
          apiTimeoutDuration: const Duration(seconds: 30),
          useDummyData: false,
          dummyAppDataPath: 'test_resources/kyoroman_app_data.json',
        ),
        themeData: ThemeData(
          primarySwatch: Colors.red,
        ),
        splashScreen: Carm2SplashScreen(),
        appFuncServicesOverrides: [],
      ),
    ).start());

class KyoromanColors {
  static const MaterialColor purple = MaterialColor(
    _purplePrimaryValue,
    <int, Color>{
      50: Color(0xFFFAEBF2),
      100: Color(0xFFEFC3D9),
      200: Color(0xFFE49BBF),
      300: Color(0xFFD973A5),
      400: Color(0xFFCE4B8C),
      500: Color(_purplePrimaryValue),
      600: Color(0xFF8C2659),
      700: Color(0xFF641B3F),
      800: Color(0xFF3C1026),
      900: Color(0xFF14050D),
    },
  );
  static const int _purplePrimaryValue = 0xFFA92E6B;

  static const lightPurple = const Color(0xFFD497B5);
  static const grey = const Color(0xFFE6E6E6);

  /// 反転色と補色のカラーコードを計算します。
  /// https://www.wave440.com/php/iro.php
  static const purpleContrastColor = const Color(0xFF56D194);
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

class ExampleCustomWebViewService implements AbstractAppFuncService {
  static const int FUNC_ID = 2;

  AppFunc appFunc;

  Sink<NavigationRequest> _navigationSink;

  @override
  int getFuncId() => FUNC_ID;

  @override
  void setNavigationSink(Sink<NavigationRequest> navigationSink) {
    _navigationSink = navigationSink;
  }

  void open(AppFunc appFunc) async {
    _navigationSink.add(
      NavigationRequest(
        appFuncId: appFunc.id,
        screen: Scaffold(
          body: Container(
            color: Colors.orange,
            child: Center(
              child: Text('${this.runtimeType}'),
            ),
          ),
        ),
      ),
    );
  }
}
