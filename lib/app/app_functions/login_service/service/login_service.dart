import 'package:carm2_base/app/app_functions/login_service/blocs/login_screen_bloc.dart';
import 'package:carm2_base/app/blocs/navigation_bloc.dart';
import 'package:carm2_base/app/resources/models/app_func.dart';
import 'package:carm2_base/app/services/abstract_app_func_service.dart';
import 'package:carm2_base/app/services/member/member_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_app/app/app_functions/login_service/ui/widgets/login_screen.dart';

class CustomLoginService
    implements
        AbstractAppFuncService,
        MemberLoginSinkAppFuncMixin,
        MemberStreamAppFuncMixin,
        EventSinkAppFuncMixin {
  static const int FUNC_ID = 8;
  @override
  int getFuncId() => FUNC_ID;

  Sink<NavigationRequest> _navigationSink;

  // used by LoginScreenBloc to open next AppFunc after successful login
  Sink<Event> _eventSink;
  Sink<MemberLogin> _memberLoginSink;
  Stream<MemberLogin> _memberLoginStream;

  AppFunc appFunc;

  int _targetAppFuncId;

  @override
  void setNavigationSink(Sink<NavigationRequest> navigationSink) {
    _navigationSink = navigationSink;
  }

  @override
  void setReloadStream(Stream<bool> reloadStream) {
    // TODO: implement setReloadStream
  }

  @override
  void setEventSink(Sink<Event> eventSink) {
    _eventSink = eventSink;
  }

  @override
  void setMemberLoginSink(Sink<MemberLogin> memberLoginSink) {
    _memberLoginSink = memberLoginSink;
  }

  @override
  void setMemberLoginStream(Stream<MemberLogin> memberLoginStream) {
    _memberLoginStream = memberLoginStream;
  }

  @override
  void open(AppFunc appFunc, Event event, {AppFuncParam param}) async {
    this.appFunc = appFunc;

    // screenLayoutの最初のボタンWidgetからログイン成功時に遷移するアプリ機能を取得する
    // TODO: これは専用のログインボタンWidgetになる？
    _targetAppFuncId =
        appFunc.screenLayout.mainWidgets.buttonWidgets.first.appFuncId;
    
    final Widget screen = _prepareScreen();

    final firstStream = await _memberLoginStream.first;
      switch (firstStream.loginStatus) {
        case LoginStatus.loggedOut:
          _navigationSink.add(NavigationRequest(
              appFuncId: appFunc.id,
              screen: screen,
              appFuncParam: param,
              event: event));
          break;
        case LoginStatus.loggedIn:
          _eventSink.add(WidgetEvent(
              fromWidgetId: -1,
              fromWidgetName: "Login",
              toAppFuncId: _targetAppFuncId));
          break;
        default:
      }

  }

  Widget _prepareScreen() {
    // test
    final loginScreenData = LoginScreenData.fromAppFunc(appFunc);

    final Widget screen = Builder(
      builder: (BuildContext context) => Provider(
        create: (BuildContext context) => LoginScreenBloc(
          eventSink: _eventSink,
          memberLoginSink: _memberLoginSink,
          targetAppFuncId: _targetAppFuncId,
          continueWithoutLoginAppFuncId:
              appFunc.screenLayout.mainWidgets.buttonWidgets.length > 1
                  ? appFunc.screenLayout.mainWidgets.buttonWidgets[1].appFuncId
                  : null,
        ),
        dispose: (_, _bloc) => _bloc.dispose(),
        child: LoginScreen(
          loginScreenData: loginScreenData,
        ),
      ),
    );

    return screen;
  }
}
