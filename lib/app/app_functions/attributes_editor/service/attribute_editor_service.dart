import 'package:carm2_base/app/app_functions/attributes_editor/blocs/attribute_editor_screen_bloc.dart';
import 'package:carm2_base/app/app_functions/attributes_editor/service/initial_app_func_checker.dart';
import 'package:carm2_base/app/blocs/layout_bloc.dart';
import 'package:carm2_base/app/blocs/navigation_bloc.dart';
import 'package:carm2_base/app/resources/models/app_func.dart';
import 'package:carm2_base/app/services/abstract_app_func_service.dart';
import 'package:carm2_base/app/services/layout_screen_data_builder.dart';
import 'package:carm2_base/app/services/member/member_service.dart';
import 'package:carm2_base/app/ui/screens/layout_screen/layout_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_app/app/app_functions/attributes_editor/ui/screen/attribute_editor_screen.dart';

class CustomAttributeEditorService
    implements AbstractAppFuncService, MemberStreamAppFuncMixin {
  static const int FUNC_ID = 28;

  Sink<NavigationRequest> _navigationSink;

  Stream<MemberLogin> _memberLoginStream;

  AppFunc appFunc;

  @override
  int getFuncId() => FUNC_ID;

  @override
  void setNavigationSink(Sink<NavigationRequest> navigationSink) {
    _navigationSink = navigationSink;
  }

  @override
  void setReloadStream(Stream<bool> reloadStream) {
    // TODO: implement setReloadStream
  }

  @override
  void setMemberLoginStream(Stream<MemberLogin> memberLoginStream) {
    _memberLoginStream = memberLoginStream;
  }

  @override
  void open(AppFunc appFunc, Event event, {AppFuncParam param}) async {
    this.appFunc = appFunc;

    _navigationSink.add(NavigationRequest(
      appFuncId: appFunc.id,
      screen: _prepareScreen(),
      appFuncParam: param,
      event: event
    ));
  }

  Widget _prepareScreen() {
    LayoutCheckResult layoutCheckResult =
        InitialAppFuncChecker.checkAll(appFunc.screenLayout);

    final AttributeType _attributeType = appFunc.isMemberAttribute
        ? AttributeType.member
        : AttributeType.appUser;

    final layoutBuilder =
        LayoutScreenDataBuilder(layoutCheckResult.screenLayout);

    layoutBuilder.widgets = [
      AttributeEditorScreen(
        initialAppFuncButton: layoutCheckResult.initialAppFuncButton,
        initalTextWidget: layoutCheckResult.initialTextWidget,
      )
    ];

    final Widget screen = Builder(
      builder: (BuildContext context) => MultiProvider(
        providers: [
          Provider(
            create: (BuildContext context) => AttributeEditorScreenBloc(
              appFuncId: appFunc.id,
              attributeType: _attributeType,
              memberLoginStream: _memberLoginStream,
            ),
            dispose: (_, _bloc) => _bloc.dispose(),
          ),
          Provider(
            create: (BuildContext context) =>
                LayoutBloc(layoutScreenData: layoutBuilder.build()),
            dispose: (_, _bloc) => _bloc.dispose(),
          ),
        ],
        child: LayoutScreen(),
      ),
    );

    return screen;
  }
}
