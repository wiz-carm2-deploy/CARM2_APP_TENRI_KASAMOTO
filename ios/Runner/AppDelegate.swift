import UIKit
import Flutter
import GoogleMaps
import flutter_unity_widget

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // google map プラグインに必要
    GMSServices.provideAPIKey("AIzaSyCqnSHSA8FmovXP3KDtJ8YqgJ6O7vSRpx4")
    InitUnityIntegrationWithOptions(argc: CommandLine.argc, argv: CommandLine.unsafeArgv, launchOptions)

    // アプリ起動してもバッジが消えない問題への対応
    // いつのバージョンからか、Firebaseプラグイン側で、アプリ起動時にバッジを削除する処理が消えているっぽい
    // ネットで調べてもこの方法以外なかったのでひとまず取り入れる
    application.applicationIconBadgeNumber = 1;
    application.applicationIconBadgeNumber = 0;

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
