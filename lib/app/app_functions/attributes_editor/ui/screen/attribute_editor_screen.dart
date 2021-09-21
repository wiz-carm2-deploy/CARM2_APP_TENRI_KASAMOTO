import 'dart:async';

import 'package:built_collection/built_collection.dart';
import 'package:carm2_base/app/app_functions/attributes_editor/blocs/attribute_editor_screen_bloc.dart';
import 'package:carm2_base/app/app_functions/attributes_editor/service/initial_app_func_checker.dart';
import 'package:carm2_base/app/app_functions/attributes_editor/ui/view_models/attribute_input_data.dart';
import 'package:carm2_base/app/app_functions/attributes_editor/ui/widgets/attribute_inputs.dart';
import 'package:carm2_base/app/blocs/navigation_bloc.dart';
import 'package:carm2_base/app/resources/models/attributes/attribute.dart';
import 'package:carm2_base/app/resources/models/attributes/attribute_value.dart';
import 'package:carm2_base/app/resources/models/attributes/attributes.dart';
import 'package:carm2_base/app/resources/models/attributes/attributes_update_payload.dart';
import 'package:carm2_base/app/resources/models/text_widget.dart';
import 'package:carm2_base/app/ui/widgets/custom_status_bar.dart';
import 'package:carm2_base/app/ui/widgets/loading_screen.dart';
import 'package:carm2_base/app/ui/widgets/stream_snack_bar.dart';
import 'package:carm2_base/app/util/widget_util.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// global variable [inputDataList] to get all input when updating
final List<AbstractAttributeInputData> _inputDataList = [];

/// TODO: CARM2_APP の基本属性入力画面は`しもまちアプリ`のデザインになっている
/// プロジェクト側に移してもっとデフォルト的なデザインに変更する(asset画像を削除する)
class AttributeEditorScreen extends StatefulWidget {
  final InitialAppFuncButton initialAppFuncButton;
  final TextWidget initalTextWidget;

  AttributeEditorScreen(
      {Key key, this.initialAppFuncButton, this.initalTextWidget})
      : super(key: key);

  @override
  _AttributeEditorScreenState createState() => _AttributeEditorScreenState();
}

class _AttributeEditorScreenState extends State<AttributeEditorScreen> {
  final _formKey = GlobalKey<FormState>();

  void _saveAttributes(BuildContext context) {
    // フォームのバリデーション処理
    final _formsState = _formKey.currentState;
    if (!_formsState.validate()) {
      print('failed to validate attributes form');
      return;
    }

    // キーボードを閉じる
    FocusScope.of(context).unfocus();

    final List<AttributeValue> _attributeValues = [];
    _inputDataList.forEach((inputData) {
      _attributeValues.addAll(inputData.getAttributeValues());
    });

    final attributesUpdatePayload = AttributesUpdatePayload((b) {
      b.attributeValues = ListBuilder(_attributeValues);
      return b;
    });

    Provider.of<AttributeEditorScreenBloc>(context)
        .saveAttributeValuesSink
        .add(attributesUpdatePayload);
  }

  Stream _previousIsSavedSuccessStream;
  StreamSubscription _isSavedSuccessStreamSubscription;

  void _listenIsSavedSucccess(Stream<bool> isSavedSuccess) {
    isSavedSuccess.forEach(
      (bool isSavedSuccess) {
        if (mounted && isSavedSuccess) {
          /// これは最後の`initialAppFuncButton`なら、初期のみの履歴登録APIを[updateAppFuncId]で呼ぶ
          if (widget.initialAppFuncButton.updateAppFuncId != null) {
            Provider.of<NavigationBloc>(context)
                .updateInitialAppFuncIdAsCompleted(
              widget.initialAppFuncButton.updateAppFuncId,
            );
          }

          /// 次のアプリ機能に遷移する
          Provider.of<NavigationBloc>(context).eventSink.add(WidgetEvent(
              fromWidgetId: -1,
              fromWidgetName: "NextButton",
              toAppFuncId: widget.initialAppFuncButton.nextAppFuncId));
        }
      },
    );
  }

  String _convertText(String text) {
    return text.replaceAll('\\n', '\n');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (widget.initialAppFuncButton == null) {
      return;
    }

    /// 初期のみの画面として開けたら、ここで属性更新の成功ストリームを聞くようにする
    final _bloc = Provider.of<AttributeEditorScreenBloc>(context);
    if (_bloc.isSavedSuccess != _previousIsSavedSuccessStream) {
      _isSavedSuccessStreamSubscription?.cancel();
      _previousIsSavedSuccessStream = _bloc.isSavedSuccess;
      _listenIsSavedSucccess(_bloc.isSavedSuccess);
    }
  }

  @override
  Widget build(BuildContext context) {
    final initText = widget.initalTextWidget;
    final _screenWidth = MediaQuery.of(context).size.width;
    return WillPopScope(
      onWillPop: () async {
        Provider.of<NavigationBloc>(context).pop();
        return false;
      },
      child: CustomStatusBar(
        child: Scaffold(
          backgroundColor: Theme.of(context).backgroundColor,
          body: StreamSnackBar(
            stream:
                Provider.of<AttributeEditorScreenBloc>(context).messageStream,
            child: Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  initText != null
                      ? Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 20.0),
                          alignment: Alignment.topLeft,
                          child: Text(
                            _convertText(initText.content),
                            style: TextStyle(
                              height: 1.5,
                              color: WidgetUtil.hexToColor(initText.fontColor),
                              fontSize: initText.fontSize.toDouble(),
                            ),
                          ),
                        )
                      : SizedBox(),

                  /// 属性変更画面はログイン会員のみの設定になっている場合
                  /// ログインしていなかったら[hasRequiredAccess]は`false`になって
                  /// [AttributeDisplayArea]のローディングアニメーションが表示されなくなる
                  StreamBuilder<bool>(
                    stream: Provider.of<AttributeEditorScreenBloc>(context)
                        .hasRequiredAccess,
                    initialData: true,
                    builder: (context, snapshot) {
                      if (snapshot.data) {
                        // 属性の表示/入力フィールド
                        return Form(
                          key: _formKey,
                          child: AttributeDisplayArea(
                            attributeDecoration: AttributeDecoration(
                              fillColor: Colors.white,
                              labelTextStyle: TextStyle(
                                fontSize: 16.0,
                              ),
                            ),
                          ),
                        );
                      } else {
                        return Expanded(child: SizedBox());
                      }
                    },
                  ),

                  // ナビゲーションボタン
                  StreamBuilder(
                    stream: Provider.of<AttributeEditorScreenBloc>(context)
                        .isLoading,
                    initialData: true,
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      final bool _isLoading = snapshot.data;

                      return InkWell(
                        child: Container(
                          width: _screenWidth * 0.7,
                          color: widget.initialAppFuncButton?.backgroundColor ??
                              Theme.of(context).primaryColor,
                          margin:
                              const EdgeInsets.only(top: 10.0, bottom: 10.0),
                          padding: EdgeInsets.all(18.0),
                          child: Center(
                            child: Text(
                              widget.initialAppFuncButton?.label ?? '保存',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        onTap: _isLoading
                            ? null
                            : () {
                                _saveAttributes(context);
                              },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _isSavedSuccessStreamSubscription?.cancel();
    super.dispose();
  }
}

// これでAttributesデーターを表示する
class AttributeDisplayArea extends StatefulWidget {
  /// 入力フィールドのデザイン設定
  final AttributeDecoration attributeDecoration;

  const AttributeDisplayArea({
    Key key,
    this.attributeDecoration,
  }) : super(key: key);

  @override
  _AttributeDisplayAreaState createState() => _AttributeDisplayAreaState();
}

class _AttributeDisplayAreaState extends State<AttributeDisplayArea> {
  ScrollController _scrollController = ScrollController();

  void _scrollDownABit() {
    // using timer to scroll down after build has completed
    Timer(Duration(milliseconds: 100), () {
      double scrollOffset = _scrollController.offset + 50.0;

      if (scrollOffset > _scrollController.position.maxScrollExtent) {
        scrollOffset = _scrollController.position.maxScrollExtent;
      }

      _scrollController.animateTo(scrollOffset,
          duration: Duration(milliseconds: 300), curve: Curves.decelerate);
    });
  }

  bool checkRequiredInput(Attributes attributes) {
    for (var attribute in attributes.attributes) {
      if (attribute.isRequired == null || attribute.isRequired) return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: StreamBuilder<AttributesDisplayData>(
        stream: Provider.of<AttributeEditorScreenBloc>(context).attributeStream,
        builder: (BuildContext context,
            AsyncSnapshot<AttributesDisplayData> snapshot) {
          // had to add check for attributes getting null while saving, check saving logic in bloc!
          if (!snapshot.hasData ||
              snapshot.data == null ||
              snapshot.data?.attributes == null) {
            return Container(
              child: Center(
                child: LoadingScreen(),
              ),
            );
          }

          if (snapshot.data.hasGrown) {
            _scrollDownABit();
          }

          return SingleChildScrollView(
            controller: _scrollController,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: <Widget>[
                  checkRequiredInput(snapshot.data.attributes)
                      ? Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 20.0),
                          alignment: Alignment.topRight,
                          child: Text(
                            '*は必須項目です',
                            style: widget.attributeDecoration?.labelTextStyle ??
                                TextStyle(
                                  fontSize: 16.0,
                                  color: Theme.of(context).primaryColor,
                                ),
                          ),
                        )
                      : SizedBox(),
                    Container(
                      child: AttributeList(
                        attributes: snapshot.data.attributes,
                        inputDataList: _inputDataList,
                        attributeDecoration: widget.attributeDecoration,
                        updateCallback: (Attribute attribute) {
                          Provider.of<AttributeEditorScreenBloc>(context)
                              .updatedAttributeSink
                              .add(attribute);
                        },
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}

class AttributeList extends StatefulWidget {
  final Attributes attributes;
  final List<AbstractAttributeInputData> inputDataList;
  final AttributeDecoration attributeDecoration;
  final AttributeUpdateCallback updateCallback;

  const AttributeList({
    Key key,
    @required this.attributes,
    @required this.inputDataList,
    this.attributeDecoration,
    @required this.updateCallback,
  }) : super(key: key);

  @override
  _AttributeListState createState() => _AttributeListState();
}

class _AttributeListState extends State<AttributeList> {
  @override
  void dispose() {
    widget.inputDataList.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: widget.attributeDecoration?.padding,
      child: Column(
        children:
            // mapping every attribute to a AttributeInput
            widget.attributes.attributes
                .map((attribute) => AttributeInput(
                      key: Key(attribute.hashCode.toString()),
                      attribute: attribute,
                      inputDataList: widget.inputDataList,
                      attributeDecoration: widget.attributeDecoration,
                      updateCallback: widget.updateCallback,
                    ))
                .toList(),
      ),
    );
  }
}
