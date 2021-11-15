
# オフラインの同期(OfflineSync)

オフライン時には ローカルデータベースorローカルキャッシュ
に書き込みを行い、

オンライン復帰時に リモートデータベースと同期を行う仕組み。

これといった定番の方法がない。。

使用したい個所: 多数

リモートに書き込みを行うソフトならすべて。
松本のように、普段オフラインのユーザーは、
通常はオフラインで書き込みを行い、
部屋に戻ってきて リモートと同期をとる。

 Google Keep
 Google Calendar など



## まさにこの質問, socket_io_client

次のstackoverflowは、質問者の図がわかりやすい。
https://stackoverflow.com/questions/64283811/

  僕のやりたいことは、まさに この質問者と同じもの。
  一人回答者がいて、下記のパッケージを使うとのこと
  
    socket_io_client: ^0.9.4
    connectivity: ^3.0.6
    shared_preferences: ^0.5.8


 socket_io_client (Like: 400)
 https://pub.dev/packages/socket_io_client




## FireStoreのキャッシュ機能を使え

次のstackoverflowでは、素直に FireStoreのキャッシュ機能を使え、と言っている。
https://stackoverflow.com/questions/57882097/

 しかし、それだと、FireStore 以外のデータベースが使えないし、
 このキャッシュ機能はブラックボックスで、何が起こっているのか、
 見えない。
 その部分についてのデバッグもしづらい。



## flutter_offline

松本実装場所
C:\Users\takeshi\AndroidStudioProjects\flutter2\lib\dbsync


ローカルのSQliteに 
同期用のカラム(status)を一つ設け、
サーバーにアップできていれば trueを設定する仕組み
https://walkingtree.tech/make-your-apps-available-offline-using-flutter-and-sqlite/

  ネットワーク接続しているときは、status: 1 で保存する
  未接続のときは、status: 0 で保存
  
  status: 0 のデータは、ネットワーク接続復帰時に サーバーにアップする

  flutter_offline というパッケージを使用している。
  https://pub.dev/packages/flutter_offline
  
  GitHubソースコードあり
  https://github.com/abhilashahyd/dbsync_app


使用しているパッケージ

  sqflite: ^1.2.0
  provider: ^4.1.3
  path_provider: ^1.5.1
  http: ^0.12.2
  flutter_offline: ^0.3.0
  dio: ^3.0.10


GitHubからダウンロードしたコードを見てみると、
なんか、しょぼいコードかと一見思ったが、
同期について、flutter_offlineを使ってしっかりしている感じもする。。



### flutter_offlineについて

内部で connectivityパッケージと、StreamBuilderを使用している。

下記のような方法で connectivityをStream化し、
そのストリームをStreamBuilderで監視ししている。

  _connectivityStream = Stream.fromFuture(
    widget.connectivityService.checkConnectivity()
  )

ネットワークが復帰したら自動的にリビルドが走る、というわけ。



## Inkdrop
(Google Keepより転記)

Inkdropの仕様が理想的である。

Inkdropは内部DBとして、PouchDBを使用している。
これは、NoSQL(FlutterでのHiveのようなもの)
そして、サーバー側ではこのPouchDBと動機相性の良いCouchDBが使用されている。

Synchronizing in the Cloud
自分のサーバーを立てる方法
https://docs.inkdrop.app/manual/synchronizing-in-the-cloud
CouchDBが使えるサーバーであれば、独自のサーバーにアップすることができる。
Apache CouchDB
http://couchdb.apache.org/



## sync sqflite to mysql

役立つかもと思って見てみたが、
自動的に同期されるわけではなくて、
同期ボタンを押すと、ローカルの全データがリモートにアップロードされる仕組み。

松本実装
C:\Users\takeshi\AndroidStudioProjects\hoge\lib\sync_sqflite_to_mysql

抜粋元URL
https://github.com/shawondeveloper/sync-sqflite-tomysql

おそらく、下記のYoutubeが対応するものだと思われる。

flutter sync sqflite to mysql. sync offline to online data
https://www.youtube.com/watch?v=QjT5_U3YxW0



## Mobync
https://github.com/mobync/flutter-client

mobync 0.0.8 (Like: 2) Nov 12, 2020
https://pub.dev/packages/mobync

Open source offline-online data syncing protocol
しっかりしてそうに見えるが、Like: 2しかない。
ソースコードを参考にできるのかもしれない。。。


## brick_offline_first 0.1.3
https://pub.dev/packages/brick_offline_first

  まだ、内容は読んでいない。



## offline-first apps

https://www.techaheadcorp.com/blog/offline-app-architecture/

  Flutterの話ではない。
  一般的な話
  High-level tools とローレベルツール
  Couchbase Mobile
  localForage
  PouchDB
  


## Keeping it local: Managing a Flutter app's data
https://www.youtube.com/watch?v=uCbHxLA9t9E
Flutter公式動画
一度見たが、大した内容ではなかったような。
単に、
  SharedPrefereces
  ImageCache
  SQflite
の紹介だったと思う。

動画もダウンロードして保存している。
C:\Users\takeshi\Downloads\RecoCoder動画\keep_it_local\Keeping it local - Managing a Flutter app's data-uCbHxLA9t9E.mp4




# オフラインファースト

オフラインファースト という言葉があることを知った。

Chrome SyncFileSystem APIはとても便利なAPIである。
アプリをオフラインで使っているときはアプリが扱うデータはローカルに保存され、
オンラインになると自動的にリモート（Google Drive）と同期させることができるようになる。


SyncFileSystem APIというものが存在する
https://www.eisbahn.jp/yoichiro/2013/02/syncfilesystem-api-japanese.html

ただし、上記情報はすべて 非常に古い。2013年とか。
Flutterで検索しても、情報が出てこない。



# WorkManager

Drive Android APIは廃止されます、という記事。
https://developers.google.com/drive/android/deprecation
  ここに、Offline Sync という言葉があった。
  

AndroidのAPIについて調べていたところ、
https://developer.android.com/training/sync-adapters/creating-sync-adapter
下記のような文言を見つけた。

バックグラウンド処理ユースケースのほとんどで、『WorkManager』を推奨ソリューションとしておすすめしています。最適なソリューションについては、バックグラウンド処理ガイドをご覧ください。

  ↓↓
WorkManager について検索してみたところ、Flutterのパッケージが見つかった。

workmanager 0.4.1
https://pub.dev/packages/workmanager

Flutter WorkManager is a wrapper around Android's WorkManager and iOS' performFetchWithCompletionHandler, effectively enabling headless execution of Dart code in the background.

Flutter WorkManagerは、AndroidのWorkManagerとiOSのperformFetchWithCompletionHandlerのラッパーであり、バックグラウンドでのDartコードのヘッドレス実行を効果的に可能にします。

This is especially useful to run periodic tasks, such as fetching remote data on a regular basis.

これは、リモートデータを定期的にフェッチするなどの定期的なタスクを実行する場合に特に便利です。



https://developers.google.com/drive/android/deprecation

