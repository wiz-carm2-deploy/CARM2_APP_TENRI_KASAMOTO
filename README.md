# CARM2 アプリテンプレート

flutter version `v1.12.13+hotfix.9` で作成されたプロジェクトです。
(kotlin/swiftベース)

## ここで対応できるアプリ設定

- アプリ名
- アプリバーション
- バックエンドベースurl
- 色 ThemeData
- ダミーデータ利用/パス

Firebase 設定ファイル(Firebase Consoleから)
/android/app/google-services.json
/ios/GoogleService-Info.plist

## テンプレートからプロジェクトリポ複製

1. プロジェクトのリモートリポジトリ作成

2. ローカルにクローン
```
git clone https://github.com/wiz-develop/CARM2_APP_TEMPLATE.git １.で作成したリモートリポ名 (例)CARM2_APP_Tabetomo_20200917
```
3. プロジェクトのリモートリポにテンプレートを反映
```
cd 2.のプロジェクト名

git remote rename origin upstream

git remote add origin 1.で作成したリモートリポURL 

プロジェクトの権限(setting→manage access)を付与する

git push -u origin master
```



