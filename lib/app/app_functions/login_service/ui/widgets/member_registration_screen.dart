import 'dart:async';

import 'package:built_collection/built_collection.dart';
import 'package:carm2_base/app/app_functions/attributes_editor/ui/screen/attribute_editor_screen.dart';
import 'package:carm2_base/app/app_functions/attributes_editor/blocs/attribute_editor_screen_bloc.dart';
import 'package:carm2_base/app/app_functions/attributes_editor/ui/view_models/attribute_input_data.dart';
import 'package:carm2_base/app/app_functions/attributes_editor/ui/widgets/attribute_inputs.dart';
import 'package:carm2_base/app/app_functions/login_service/blocs/member_registration_screen_bloc.dart';
import 'package:carm2_base/app/app_settings.dart';
import 'package:carm2_base/app/resources/models/attributes/attribute.dart';
import 'package:carm2_base/app/resources/models/attributes/attribute_value.dart';
import 'package:carm2_base/app/resources/models/member/member_registration_payload.dart';
import 'package:carm2_base/app/resources/models/screen_layout.dart';
import 'package:carm2_base/app/ui/widgets/cached_image.dart';
import 'package:carm2_base/app/ui/widgets/custom_input_label.dart';
import 'package:carm2_base/app/ui/widgets/custom_status_bar.dart';
import 'package:carm2_base/app/ui/widgets/loading_screen.dart';
import 'package:carm2_base/app/ui/widgets/stream_snack_bar.dart';
import 'package:carm2_base/app/util/navigator_state_carm2.dart';
import 'package:carm2_base/app/util/kyoroman_colors.dart';
import 'package:carm2_base/app/util/widget_util.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_app/app/app_functions/login_service/ui/widgets/login_screen.dart';

class MemberRegistrationScreen extends StatelessWidget {
  final ScreenLayout screenLayout;
  final LoginScreenData loginScreenData;

  const MemberRegistrationScreen({
    Key key,
    this.screenLayout,
    @required this.loginScreenData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        NavigatorStateCarm2.pop();
        return false;
      },
      child: CustomStatusBar(
        child: Container(
          color: Colors.white,
          height: MediaQuery.of(context).size.height,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: screenLayout.headerBackgroundColor == null
                  ? Colors.white
                  : WidgetUtil.hexToColor(screenLayout.headerBackgroundColor),
              leading: IconButton(
                  icon: Icon(
                    screenLayout.headerSideMenuIcon == null
                        ? Icons.arrow_back_ios
                        : IconData(
                            int.parse(screenLayout.headerSideMenuIcon),
                            fontFamily: 'MaterialIcons',
                          ),
                    color: screenLayout.headerSideMenuIcon == null
                        ? Colors.black
                        : WidgetUtil.hexToColor(
                            screenLayout.headerMenuIconColor),
                  ),
                  onPressed: () {
                    NavigatorStateCarm2.pop();
                  }),
              centerTitle: true,
              // flexibleSpace: Padding(
              //   padding: const EdgeInsets.all(4.0),
              //   child: screenLayout.headerSideMenuIcon == null
              //       ? Image.asset('assets/login_screen/login_icon.png')
              //       : Padding(
              //           padding: const EdgeInsets.all(4.0),
              //           child:
              //               CachedImage(imageUrl: screenLayout.headerImageUrl),
              //         ),
              // ),
            ),
            body: StreamSnackBar(
              title: '会員登録に失敗しました',
              backgroundColor: Theme.of(context).primaryColor,
              stream: Provider.of<MemberRegistrationScreenBloc>(context)
                  .messageStream,
              child: StreamBuilder<ProcessingStatus>(
                stream: Provider.of<MemberRegistrationScreenBloc>(context)
                    .processingStatus,
                initialData: ProcessingStatus.pending,
                builder: (context, snapshot) {
                  final _status = snapshot.data;

                  if (_status == ProcessingStatus.registrationDone) {
                    return RegistrationSuccess(
                      loginScreenData: loginScreenData,
                    );
                  }

                  return RegistrationForm(loginScreenData: loginScreenData);
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class RegistrationSuccess extends StatelessWidget {
  final LoginScreenData loginScreenData;

  const RegistrationSuccess({Key key, this.loginScreenData}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 30.0, right: 30.0, bottom: 65.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 64.0, vertical: 30.0),
                child: Container(
                  child:
                      Image.asset('assets/icon/auth_icon.png'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Container(
                  color: WidgetUtil.hexToColor('#F7F4E9'),
                  width: double.infinity,
                  padding: EdgeInsets.all(10.0),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Icon(
                                Icons.warning_amber_outlined,
                              ),
                              Text(
                                'まだ登録は完了していません。',
                                style: TextStyle(
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          'ご入力頂いたメールアドレスに本人確認のためのメールを送りました。お手続きをお願い致します。\n'
                          '※メールが届かない場合、スマートフォン・タブレットの迷惑メール設定を解除してから再度ご登録をお願い致します。',
                          style: TextStyle(
                            fontSize: 12.0,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 40.0),
            child: Container(
              width: double.infinity,
              child: RaisedButton(
                padding: EdgeInsets.symmetric(vertical: 10.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                color: loginScreenData.submitButton.backgroundColor,
                child: Text(
                  'ログイン画面へ',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
                onPressed: () {
                  NavigatorStateCarm2.pop();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// global variable [inputDataList] to get all input when updating
final List<AbstractAttributeInputData> _inputDataList = [];

class RegistrationForm extends StatefulWidget {
  final LoginScreenData loginScreenData;

  const RegistrationForm({Key key, this.loginScreenData}) : super(key: key);

  @override
  _RegistrationFormState createState() => _RegistrationFormState();
}

class _RegistrationFormState extends State<RegistrationForm> {
  final _formKey = GlobalKey<FormState>();

  final _emailInputController = TextEditingController();
  // final _accountIdInputController = TextEditingController();
  final _passwordInputController = TextEditingController();
  final _passwordConfirmInputController = TextEditingController();

  final String _emailInputLabel = 'メールアドレス';
  // final String _accountIdInputLabel = 'アカウントID';
  final String _passwordInputLabel = 'パスワード';
  final String _passwordConfirmInputLabel = 'パスワード (確認)';

  final ScrollController scrollController = ScrollController();

  InputDecoration _getInputDecoration(String hintText) {
    return InputDecoration(
      contentPadding: const EdgeInsets.only(left: 5.0),
      border: const OutlineInputBorder(
        borderSide: BorderSide(),
        borderRadius: const BorderRadius.all(Radius.circular(6.0)),
      ),
      hintText: hintText,
      filled: true,
      fillColor: Colors.white,
      errorMaxLines: 2,
    );
  }

  Future<void> _submitForm() async {
    final form = _formKey.currentState;
    if (form.validate() == false) {
      return;
    }

    final List<AttributeValue> _attributeValues = [];
    _inputDataList.forEach((inputData) {
      _attributeValues.addAll(inputData.getAttributeValues());
    });

    final attributesUpdatePayload = MemberRegistrationPayload((b) {
      b.appId = appSettings.appId;
      b.name = '<dummy name>';
      b.email = _emailInputController.text;
      // b.accountId = _accountIdInputController.text;
      b.password = _passwordInputController.text;
      b.passwordConfirmation = _passwordConfirmInputController.text;
      b.attributeValues = ListBuilder<AttributeValue>(_attributeValues);
      return b.build();
    });

    print('attributesUpdatePayload: ${attributesUpdatePayload.toJson()}');

    Provider.of<MemberRegistrationScreenBloc>(context)
        .submit(attributesUpdatePayload);
  }

  bool _hasPasswordDescription() {
    return widget.loginScreenData?.passwordDescription != null &&
        widget.loginScreenData?.passwordDescription != '';
  }

  /// TODO: これもAppFuncのloginScreenDataから設定できるようにする
  bool _hasEmailDescription() {
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        SingleChildScrollView(
          controller: scrollController,
          child: Theme(
            data: Theme.of(context).copyWith(errorColor: Colors.red),
            child: Builder(
              builder: (BuildContext context) => Form(
                key: _formKey,
                child: Container(
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 40.0, right: 40.0, bottom: 65.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 64.0, vertical: 30.0),
                          child: Container(
                            child: Image.asset(
                                'assets/icon/auth_icon.png'),
                          ),
                        ),

                        // CustomInputLabel.white(
                        //   label: _accountIdInputLabel,
                        //   child: Padding(
                        //     padding: const EdgeInsets.only(bottom: 20.0),
                        //     child: TextFormField(
                        //       controller: _accountIdInputController,
                        //       keyboardType: TextInputType.text,
                        //       decoration:
                        //           _getInputDecoration(_accountIdInputLabel),
                        //     ),
                        //   ),
                        // ),

                        // email field
                        CustomInputLabel.black(
                          label: _emailInputLabel,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 20.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextFormField(
                                  controller: _emailInputController,
                                  validator: (input) {
                                    return (input == null || input == '')
                                        ? '不正な入力'
                                        : null;
                                  },
                                  keyboardType: TextInputType.text,
                                  decoration:
                                      _getInputDecoration(_emailInputLabel),
                                ),
                                if (_hasEmailDescription())
                                  Text(
                                      'キャリアのメールアドレス(docomo.ne.jp, ezweb.ne.jp等)はお控えください')
                              ],
                            ),
                          ),
                        ),

                        // password field
                        CustomInputLabel.black(
                          label: _passwordInputLabel,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 20.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextFormField(
                                  controller: _passwordInputController,
                                  validator: (input) {
                                    // .* は任意の文字0文字以上 *?は最短のマッチをとる(最長だと貪欲にとるため)
                                    final RegExp validatePassword = RegExp(
                                        r'^(?=.*?[a-z])(?=.*?[A-Z])(?=.*?\d)[a-zA-Z0-9]{8,}$');
                                    return (validatePassword.hasMatch(input) ==
                                            false)
                                        ? '英大文字小文字、数字をそれぞれ1文字以上含む8桁以上で入力してください'
                                        : null;
                                  },
                                  decoration:
                                      _getInputDecoration(_passwordInputLabel),
                                ),
                                if (_hasPasswordDescription())
                                  Text(widget
                                      .loginScreenData?.passwordDescription)
                              ],
                            ),
                          ),
                        ),

                        CustomInputLabel.black(
                          label: _passwordConfirmInputLabel,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 20.0),
                            child: TextFormField(
                              controller: _passwordConfirmInputController,
                              validator: (input) {
                                if (input != _passwordInputController.text) {
                                  return _passwordInputLabel + 'と一致しません';
                                }

                                return (input == null || input == '')
                                    ? '不正な入力'
                                    : null;
                              },
                              decoration: _getInputDecoration(
                                  _passwordConfirmInputLabel),
                            ),
                          ),
                        ),

                        AttributeDisplayArea(
                          scrollController: scrollController,
                          attributeDecoration: AttributeDecoration(
                            fillColor: Colors.white,
                            borderSide: BorderSide(),
                            borderRadius: BorderRadius.circular(6.0),
                            labelTextStyle: TextStyle(
                              color: Colors.black,
                              fontSize: 18.0,
                            ),
                          ),
                        ),

                        // submit button
                        // TODO: using hardcoded color values for submit button on member registration form
                        Padding(
                          padding: const EdgeInsets.only(top: 40.0),
                          child: Container(
                            width: double.infinity,
                            child: RaisedButton(
                              padding: EdgeInsets.symmetric(vertical: 10.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              color: widget
                                  .loginScreenData.submitButton.backgroundColor,
                              child: Text(
                                '登録する',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                              ),
                              onPressed: () {
                                _submitForm();
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),

        /// 保存中にアニメーションを表示する
        StreamBuilder<ProcessingStatus>(
          stream: Provider.of<MemberRegistrationScreenBloc>(context)
              .processingStatus,
          initialData: ProcessingStatus.pending,
          builder: (context, snapshot) {
            if (snapshot.data != ProcessingStatus.processing) {
              return SizedBox();
            }

            return AbsorbPointer(
              child: Container(
                color: Colors.white.withOpacity(0.4),
                child: LoadingScreen(),
              ),
            );
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    _emailInputController.dispose();
    // _accountIdInputController.dispose();
    _passwordInputController.dispose();
    _passwordConfirmInputController.dispose();
    // _messageStreamSubscription?.cancel();

    scrollController.dispose();
    super.dispose();
  }
}

class AttributeDisplayArea extends StatefulWidget {
  final GlobalKey<FormState> formKey;

  /// 入力フィールドのデザイン設定
  final AttributeDecoration attributeDecoration;

  final ScrollController scrollController;

  const AttributeDisplayArea({
    Key key,
    this.formKey,
    this.attributeDecoration,
    @required this.scrollController,
  }) : super(key: key);

  @override
  _AttributeDisplayAreaState createState() => _AttributeDisplayAreaState();
}

class _AttributeDisplayAreaState extends State<AttributeDisplayArea> {
  void _scrollDownABit() {
    // using timer to scroll down after build has completed
    Timer(Duration(milliseconds: 100), () {
      double scrollOffset = widget.scrollController.offset + 50.0;

      if (scrollOffset > widget.scrollController.position.maxScrollExtent) {
        scrollOffset = widget.scrollController.position.maxScrollExtent;
      }

      widget.scrollController.animateTo(scrollOffset,
          duration: Duration(milliseconds: 300), curve: Curves.decelerate);
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AttributesDisplayData>(
      stream:
          Provider.of<MemberRegistrationScreenBloc>(context).attributeStream,
      builder: (BuildContext context,
          AsyncSnapshot<AttributesDisplayData> snapshot) {
        if (!snapshot.hasData || snapshot.data == null) {
          return Container(
            child: Center(
              child: LoadingScreen(),
            ),
          );
        }

        if (snapshot.data.hasGrown) {
          _scrollDownABit();
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              child: AttributeList(
                attributes: snapshot.data.attributes,
                inputDataList: _inputDataList,
                attributeDecoration: widget.attributeDecoration,
                updateCallback: (Attribute attribute) {
                  Provider.of<MemberRegistrationScreenBloc>(context)
                      .updatedAttributeSink
                      .add(attribute);
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
