import 'package:carm2_base/app/app_functions/login_service/blocs/login_screen_bloc.dart';
import 'package:carm2_base/app/app_functions/login_service/blocs/member_registration_screen_bloc.dart';
import 'package:carm2_base/app/app_functions/login_service/blocs/password_reset_screen_bloc.dart';
import 'package:carm2_base/app/app_functions/login_service/models/credentials.dart';
import 'package:carm2_base/app/app_settings.dart';
import 'package:carm2_base/app/blocs/navigation_bloc.dart';
import 'package:carm2_base/app/resources/models/app_func.dart';
import 'package:carm2_base/app/resources/models/attributes/attributes.dart';
import 'package:carm2_base/app/resources/models/main_widgets.dart';
import 'package:carm2_base/app/resources/models/screen_layout.dart';
import 'package:carm2_base/app/ui/widgets/custom_input_label.dart';
import 'package:carm2_base/app/ui/widgets/custom_status_bar.dart';
import 'package:carm2_base/app/ui/widgets/loading_screen.dart';
import 'package:carm2_base/app/ui/widgets/stream_snack_bar.dart';
import 'package:carm2_base/app/util/navigator_state_carm2.dart';
import 'package:carm2_base/app/util/widget_util.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// プロジェクト側で上書きされた画面
import 'package:test_app/app/app_functions/login_service/ui/widgets/member_registration_screen.dart';
import 'package:test_app/app/app_functions/login_service/ui/widgets/password_reset_screen.dart';

class LoginScreenData {
  /// ID, パスワード入力
  final List<LoginInput> inputs;

  /// ログインボタン
  final LoginInput submitButton;

  /// 新規登録可能フラグ
  final bool canSignUp;

  /// 新規会員の登録画面に表示する会員属性入力
  final Attributes attributes;

  /// ログインせずに進むボタン
  final LoginInput continueWithoutLoginButton;

  final bool displayBackButton;

  final ScreenLayout screenLayout;

  final bool displayPasswordResetButton;

  /// 新規会員登録画面に表示するパスワード説明
  final String passwordDescription;

  final String passwordResetDescription;

  LoginScreenData({
    @required this.inputs,
    @required this.submitButton,
    @required this.canSignUp,
    this.screenLayout,
    this.attributes,
    this.continueWithoutLoginButton,
    this.displayBackButton,
    @required this.displayPasswordResetButton,
    this.passwordDescription,
    this.passwordResetDescription,
  });

  factory LoginScreenData.fromAppFunc(AppFunc appFunc) {
    /// test, get [LoginInput] fields from all [TextWidget] in [mainWidget]
    final MainWidgets mainWidgets = appFunc.screenLayout.mainWidgets;
    final List<LoginInput> _inputs = mainWidgets.textWidgets
        .map((textWidget) => LoginInput(
            label: textWidget.content,
            inputType: appFunc.useLoginIdColumn == 'account_id'
                ? LoginInputType.accountId
                : LoginInputType.email))
        .toList();

    /// ログインアプリ機能にテキストWidgetが設定されていなかったら
    /// 下記のでデフォルトラベルを使う
    if (_inputs.isEmpty) {
      _inputs.addAll([
        LoginInput(
            label: appFunc.useLoginIdColumn == 'account_id' ? 'ID' : 'EMAIL',
            inputType: appFunc.useLoginIdColumn == 'account_id'
                ? LoginInputType.accountId
                : LoginInputType.email),
        LoginInput(
          label: 'PASSWORD',
          inputType: LoginInputType.password,
        )
      ]);
    }

    /// test, get login button label from first button in [mainWidgets]
    final _submitButton = LoginInput(
      inputType: LoginInputType.submit,
      label: mainWidgets.buttonWidgets.first.content,
      backgroundColor: WidgetUtil.hexToColor(
          mainWidgets.buttonWidgets.first.backgroundColor),
    );

    LoginInput _continueButton;
    if (mainWidgets.buttonWidgets.length > 1) {
      _continueButton = LoginInput(
        inputType: LoginInputType.submit,
        label: mainWidgets.buttonWidgets.last.content,
        backgroundColor: WidgetUtil.hexToColor(
            mainWidgets.buttonWidgets.last.backgroundColor),
      );
    }

    return LoginScreenData(
      inputs: _inputs,
      submitButton: _submitButton,
      canSignUp: appFunc.canSignUp,
      attributes: appFunc.memberRegistrationAttributes,
      continueWithoutLoginButton: _continueButton,

      /// 一旦はヘッダーが設定されていれば、戻るボタンのAppBarを表示する
      displayBackButton: appFunc.screenLayout.hasHeader,
      screenLayout: appFunc.screenLayout,
      // パスワードリセットボタンの表示、設定されていなければ表示しない
      displayPasswordResetButton:
          appFunc?.loginOptions?.isDisplayPasswordReset ?? false,
      passwordDescription: appFunc?.loginOptions?.passwordDescription,
      passwordResetDescription: appFunc?.loginOptions?.passwordResetDescription,
    );
  }
}

enum LoginInputType {
  accountId,
  email,
  password,
  submit,
}

class LoginInput {
  final String label;
  final Color backgroundColor;
  final LoginInputType inputType;

  LoginInput({
    @required this.label,
    this.backgroundColor,
    @required this.inputType,
  });
}

class LoginScreen extends StatelessWidget {
  final LoginScreenData loginScreenData;

  const LoginScreen({
    Key key,
    this.loginScreenData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Provider.of<NavigationBloc>(context).pop();
        return false;
      },
      child: CustomStatusBar(
        child: Scaffold(
          backgroundColor: Colors.white,
          body: StreamSnackBar(
            stream: Provider.of<LoginScreenBloc>(context).messageStream,
            child: LoginForm(
              loginScreenData: loginScreenData,
            ),
          ),
        ),
      ),
    );
  }
}

class LoginForm extends StatefulWidget {
  final LoginScreenData loginScreenData;

  const LoginForm({
    Key key,
    this.loginScreenData,
  }) : super(key: key);

  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();

  final String _keepLoggedInLabel = '次回から自動ログインする';
  final String _newMemberSubmitButtonLabel = '新規会員登録';

  final _idInputController = TextEditingController();
  final _passwordInputController = TextEditingController();

  bool _obscurePassword = true;

  _submitForm() {
    final form = _formKey.currentState;
    if (form.validate() == false) {
      return;
    }

    //TODO: AppUser.idはわざわざNavigationBlocから取得するじゃなくて login_screen_bloc で準備した方がいい？
    final int _appUserId = Provider.of<NavigationBloc>(context).appUser.id;

    final LoginInputType loginInputType =
        widget.loginScreenData.inputs.first.inputType;

    String _accountId;
    String _email;
    if (loginInputType == LoginInputType.accountId) {
      _accountId = _idInputController.text;
      _email = '';
    } else {
      _accountId = '';
      _email = _idInputController.text;
    }

    final credentials = MemberApiCredentials(
      accountId: _accountId,
      email: _email,
      password: _passwordInputController.text,
      appUserId: _appUserId,
      appId: appSettings.appId,
      apiToken: null,
    );

    print('credentials: ${credentials.toMap().toString()}');
    Provider.of<LoginScreenBloc>(context).submit(credentials);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: Provider.of<LoginScreenBloc>(context).isLoggingIn,
      initialData: false,
      builder: (context, snapshot) {
        if (snapshot.data) {
          return LoadingScreen();
        } else {
          return Builder(
            builder: (BuildContext context) => Container(
              height: MediaQuery.of(context).size.height,
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Container(
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 40.0, right: 40.0, bottom: 65.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                            padding:
                                const EdgeInsets.only(top: 10.0, bottom: 20.0),
                            child: Container(
                              child: Image.asset(
                                  'assets/icon/auth_icon.png'),
                            ),
                          ),

                          // account id field
                          CustomInputLabel.black(
                            label: widget.loginScreenData.inputs.first.label,
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 20.0),
                              child: TextFormField(
                                controller: _idInputController,
                                validator: (input) {
                                  final loginInputType = widget
                                      .loginScreenData.inputs.first.inputType;

                                  if (loginInputType ==
                                      LoginInputType.accountId) {
                                    // prevent japanese input
                                    final RegExp validCharacters =
                                        RegExp(r'^[a-zA-Z0-9-_@.]+$');
                                    if (validCharacters.hasMatch(input) ==
                                        false) {
                                      return '英数文字を入力してください';
                                    }
                                  }

                                  return (input == null || input == '')
                                      ? '不正な入力'
                                      : null;
                                },
                                keyboardType: TextInputType.text,
                                decoration: InputDecoration(
                                    contentPadding: EdgeInsets.only(left: 5.0),
                                    border: OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.black),
                                        borderRadius:
                                            BorderRadius.circular(6.0)),
                                    hintText: widget
                                        .loginScreenData.inputs.first.label,
                                    filled: true,
                                    fillColor: Colors.white54),
                              ),
                            ),
                          ),

                          // password field
                          CustomInputLabel.black(
                            label: widget.loginScreenData.inputs.last.label,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextFormField(
                                  controller: _passwordInputController,
                                  obscureText: _obscurePassword,
                                  validator: (input) {
                                    return (input == null || input == '')
                                        ? '不正な入力'
                                        : null;
                                  },
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.only(left: 5.0),
                                    border: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.black),
                                      borderRadius: BorderRadius.circular(6.0),
                                    ),
                                    hintText: widget
                                        .loginScreenData.inputs.last.label,
                                    filled: true,
                                    fillColor: Colors.white54,
                                    suffixIcon: GestureDetector(
                                      child: Icon(
                                        Icons.lock,
                                        color: _obscurePassword
                                            ? Colors.black
                                            : Colors.black45,
                                      ),
                                      onTap: () {
                                        setState(() {
                                          _obscurePassword = !_obscurePassword;
                                        });
                                      },
                                    ),
                                  ),
                                ),

                                /// パスワード忘れた場合のリセットボタン
                                if (widget
                                    .loginScreenData.displayPasswordResetButton)
                                  Container(
                                    alignment: Alignment.centerRight,
                                    width: double.infinity,
                                    child: FlatButton(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 8.0,
                                      ),
                                      child: Text(
                                        'パスワードをお忘れの方はこちら',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 12.0,
                                          decoration: TextDecoration.underline,
                                          decorationThickness: 2,
                                        ),
                                      ),
                                      onPressed: () {
                                        WidgetEvent event = WidgetEvent(
                                          fromWidgetId: -1,
                                          fromWidgetName: "PasswordResetButton",
                                          toScreenName: "PasswordResetScreen",
                                        );

                                        NavigatorStateCarm2.push(
                                          MaterialPageRoute(
                                            builder: (BuildContext context) {
                                              return Provider(
                                                create: (BuildContext
                                                        context) =>
                                                    PasswordResetScreenBloc(),
                                                dispose: (_, _bloc) =>
                                                    _bloc.dispose(),
                                                child: PasswordResetScreen(
                                                  screenLayout: widget
                                                      .loginScreenData
                                                      .screenLayout,
                                                  email:
                                                      _idInputController.text,
                                                  loginScreenData:
                                                      widget.loginScreenData,
                                                ),
                                              );
                                            },
                                          ),
                                          event,
                                        );
                                      },
                                    ),
                                  ),
                              ],
                            ),
                          ),

                          // stay logged in checkbox
                          StreamBuilder(
                            stream: Provider.of<LoginScreenBloc>(context)
                                .keepLoggedIn,
                            initialData: false,
                            builder: (context, snapshot) {
                              return Row(
                                children: <Widget>[
                                  Theme(
                                    data: Theme.of(context).copyWith(
                                      unselectedWidgetColor: Colors.black,
                                    ),
                                    child: Checkbox(
                                      value: snapshot.data,
                                      onChanged: (value) {
                                        Provider.of<LoginScreenBloc>(context)
                                            .changeKeepLoggedIn(value);
                                      },
                                      focusColor: Colors.white,
                                      activeColor:
                                          Theme.of(context).primaryColor,
                                      materialTapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                  ),
                                  FlatButton(
                                    child: Text(
                                      _keepLoggedInLabel,
                                      style: TextStyle(color: Colors.black),
                                    ),
                                    onPressed: () {
                                      Provider.of<LoginScreenBloc>(context)
                                          .changeKeepLoggedIn(!snapshot.data);
                                    },
                                  ),
                                ],
                              );
                            },
                          ),

                          // submit button
                          Container(
                            width: double.infinity,
                            child: RaisedButton(
                              padding: EdgeInsets.symmetric(vertical: 10.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              color: widget
                                  .loginScreenData.submitButton.backgroundColor,
                              child: Text(
                                "ログイン",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 20),
                              ),
                              onPressed: () {
                                _submitForm();
                              },
                            ),
                          ),

                          // 会員登録ボタンはログインアプリ機能のcanSignUpフラグによって表示される
                          if (widget.loginScreenData.canSignUp)
                            Padding(
                              padding: const EdgeInsets.only(top: 30.0),
                              child: Container(
                                color: WidgetUtil.hexToColor('#F7F4E9'),
                                width: double.infinity,
                                height: MediaQuery.of(context).size.width * 0.3,
                                padding: EdgeInsets.all(10.0),
                                child: Column(
                                  children: [
                                    Text(
                                      '会員登録がお済みでない方はこちらから\n新規会員登録してください',
                                      style: TextStyle(fontSize: 14.0),
                                    ),
                                    Spacer(),
                                    RaisedButton(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 10.0,horizontal: 20.0),
                                      shape: OutlineInputBorder(
                                        borderSide: BorderSide(color: WidgetUtil.hexToColor('#887C7C')),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(50)),
                                      ),
                                      color: Colors.white,
                                      child: Text(
                                        _newMemberSubmitButtonLabel,
                                        style: TextStyle(
                                            color: Colors.black, fontSize: 16),
                                      ),
                                      onPressed: () {
                                        WidgetEvent event = WidgetEvent(
                                          fromWidgetId: -1,
                                          fromWidgetName:
                                              "MemberRegistrationButton",
                                          toScreenName:
                                              "MemberRegistrationScreen",
                                        );

                                        NavigatorStateCarm2.push(
                                          MaterialPageRoute(
                                            builder: (BuildContext context) {
                                              return Provider(
                                                create: (BuildContext
                                                        context) =>
                                                    MemberRegistrationScreenBloc(
                                                        initialAttributes:
                                                            widget
                                                                .loginScreenData
                                                                .attributes),
                                                dispose: (_, _bloc) =>
                                                    _bloc.dispose(),
                                                child: MemberRegistrationScreen(
                                                  screenLayout: widget
                                                      .loginScreenData
                                                      .screenLayout,
                                                  loginScreenData:
                                                      widget.loginScreenData,
                                                ),
                                              );
                                            },
                                          ),
                                          event,
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),

                          /// ログインせずに利用するボタン
                          // if (widget
                          //         .loginScreenData.continueWithoutLoginButton !=
                          //     null)
                          //   Padding(
                          //     padding: const EdgeInsets.only(top: 30.0),
                          //     child: Container(
                          //       width: double.infinity,
                          //       child: RaisedButton(
                          //         padding: EdgeInsets.symmetric(vertical: 10.0),
                          //         shape: RoundedRectangleBorder(
                          //           borderRadius: BorderRadius.circular(12.0),
                          //         ),
                          //         color: widget
                          //             .loginScreenData
                          //             .continueWithoutLoginButton
                          //             .backgroundColor,
                          //         child: Text(
                          //           widget.loginScreenData
                          //               .continueWithoutLoginButton.label,
                          //           style: TextStyle(
                          //               color: Colors.white, fontSize: 20),
                          //         ),
                          //         onPressed: () {
                          //           Provider.of<LoginScreenBloc>(context)
                          //               .continueWithoutLogin();
                          //         },
                          //       ),
                          //     ),
                          //   ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }
      },
    );
  }

  @override
  void dispose() {
    _idInputController.dispose();
    _passwordInputController.dispose();
    super.dispose();
  }
}
