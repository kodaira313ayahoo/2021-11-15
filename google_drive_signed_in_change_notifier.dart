import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:googleapis/drive/v3.dart' as ga;
import 'google_sign_in_stream.dart';
import 'is_google_signed_in_state.dart';
import 'google_http_client.dart';

final googleDriveSignedInProviderChange =
    ChangeNotifierProvider.autoDispose<GoogleDriveSignedInController>(
        (AutoDisposeChangeNotifierProviderRef ref) {
  ref.maintainState = true;
  final googleSignIn = ref.read(googleSignInProvider);
  final AsyncValue<GoogleSignInAccount?> asyncValue =
      ref.watch(googleSignInStreamProvider);
  final AutoDisposeChangeNotifierProviderRef _ref = ref;

  // こんなところに書いても意味ないのかもしれない。
  asyncValue.when(
    data: (GoogleSignInAccount? data) {
      if (data == null) print('asyncValueチェック1: null');
      if (data != null) print('asyncValueチェック1: $data');
    },
    loading: () => print('asyncValueチェック1: loading'),
    error: (_, __) {},
  );

  final aaa = GoogleDriveSignedInController(
    //signedIn_: false,
    googleSignIn_: googleSignIn,
    googleSignInAccountAsyncValue_: asyncValue,
    ref_: _ref,
  );
  //aaa.loginSilentlyWithGoogle();
  return aaa;
});

//! setState をriverodで書き換えてみよう。
/// やったこと(1) setStateの更新対象となる signedIn をメンバ変数にする。
/// (2) setStateを削除する（念のため setStateがあった場所の痕跡を残しておく）
class GoogleDriveSignedInController with ChangeNotifier {
  GoogleDriveSignedInController({
    //required this.signedIn_,
    //this._googleSignInAccount_,
    required this.googleSignIn_,
    required this.googleSignInAccountAsyncValue_,
    required this.ref_,
  }) {}

  final storage = FlutterSecureStorage();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  GoogleSignIn googleSignIn_;
  AsyncValue<GoogleSignInAccount?> googleSignInAccountAsyncValue_;
  final AutoDisposeChangeNotifierProviderRef ref_;

  // _googleSignInAccount_についての getter, setter
  GoogleSignInAccount? _googleSignInAccount_;

  GoogleSignInAccount? get googleSignInAccount_ => _googleSignInAccount_;

  set googleSignInAccount_(GoogleSignInAccount? googleSignInAccount) {
    if (_googleSignInAccount_ != googleSignInAccount) {
      _googleSignInAccount_ = googleSignInAccount;
      notifyListeners();
    }
  }

  // _isSignInについての getter, setter
  bool _signedIn_ = false;

  bool get signedIn_ => _signedIn_;

  set signedIn_(bool isSignIn) {
    if (_signedIn_ != isSignIn) {
      _signedIn_ = isSignIn;
      notifyListeners();
    }
  }

  // final GoogleSignIn googleSignIn = GoogleSignIn(scopes: [
  //   'https://www.googleapis.com/auth/drive.appdata',
  //   ga.DriveApi.driveScope,
  // ]);

  // _state_についての getter, setter
  ChangeNotifierState _state_ = ChangeNotifierState.initial;

  ChangeNotifierState get state_ => _state_;

  set state_(ChangeNotifierState state) {
    if (_state_ != state) {
      _state_ = state;
      notifyListeners();
    }
  }

  bool _doneLoginSilently = false;

  ///! UIで状態チェックに用いられる
  Future<void> updateState() async {
    //final eee = ref_.watch();
    if (_doneLoginSilently == false) {
      _doneLoginSilently == true;
      await loginSilentlyWithGoogle();
    }

    //return _state_;
  }

  // ga.FileList gaFileList;
  //ga.FileList? gaFileList;
  //ga.FileList? gaFileList = null; // 初期値を設定した。
  Future<void> loginSilentlyWithGoogle() async {
    //loginSilentlyWithGoogle()が実行されるのは一度だけ
    if (_doneLoginSilently == true) {
      return;
    }
    _doneLoginSilently == true;

    signedIn_ = await storage.read(key: "signedIn") == "true" ? true : false;
    if (signedIn_ == false) return;

    final bool isGoogleSingedIn = await googleSignIn_.isSignedIn();
    if (isGoogleSingedIn == false) return;

    // メソッド内でwhenを実施しても意味ない？ メソッドが叩かれたとき一回きり のように思える。
    googleSignInAccountAsyncValue_.when(
      data: (GoogleSignInAccount? data) {
        if (data == null) print('asyncValueチェック2: null');
        if (data != null) print('asyncValueチェック2: $data');
      },
      loading: () => print('asyncValueチェック2: loading'),
      error: (_, __) {},
    );

    try {
      print('silentlyが実行された');
      //final GoogleSignInAccount? aaa = await googleSignIn_.signInSilently();
      googleSignInAccount_ = await googleSignIn_.signInSilently();

      if (googleSignInAccount_ is GoogleSignInAccount) {
        print('silentlyで値が取得できた');
        await storage.write(key: "signedIn", value: "true");

        ///!_afterGoogleLogin(aaa);
        signedIn_ = true;
      }
    } catch (e) {
      await storage.write(key: "signedIn", value: "false");
      //! setStateを削除
      signedIn_ = false;
    }
  }

  Future<void> loginWithGoogle() async {
    print('isDisposed_ at loginWithGoogle: $isDisposed_');

    signedIn_ = await storage.read(key: "signedIn") == "true" ? true : false;
    print('loginWithGoogle()メソッドAAが叩かれた');
    print('singedIn: $signedIn_');

    // googleSignIn_.onCurrentUserChanged
    //     .listen((GoogleSignInAccount? googleSignInAccount) async {
    //   if (googleSignInAccount != null) {
    //     print('listen内を通るか1？ - ChangeNotifier');
    //     _afterGoogleLogin(googleSignInAccount);
    //   }
    // });
    //
    // asyncValue_.when(
    //   data: (GoogleSignInAccount? googleSignInAccount) async {
    //     if (googleSignInAccount != null) {
    //       print('listen内を通るか2？ - ChangeNotifier');
    //       _afterGoogleLogin(googleSignInAccount);
    //     }
    //   },
    //   loading: () {},
    //   error: (_, __) {},
    // );

    final bool isGoogleSingedIn = await googleSignIn_.isSignedIn();

    if (signedIn_ && isGoogleSingedIn) {
      print('signedIn_ && isGoogleSingedInを通った');
      try {
        final GoogleSignInAccount? aaa = await googleSignIn_.signInSilently();
        print('GoogleSignInAccount?: ${aaa.runtimeType}');

        if (aaa is GoogleSignInAccount) {
          //await _afterGoogleLogin(aaa);
          ///!_afterGoogleLogin(aaa);
          storage.write(key: "signedIn", value: "true").then((value) {
            //! setStateを削除
            signedIn_ = true;
          });
          //signedIn_ = true;
        }
      } catch (e) {
        storage.write(key: "signedIn", value: "false").then((value) {
          //! setStateを削除
          signedIn_ = false;
        });
      }
    } else {
      // Google SignIn処理を実行
      print('isDisposed_: before signedIn_◎ : $isDisposed_');
      final GoogleSignInAccount? googleSignInAccount =
          await googleSignIn_.signIn();
      print('isDisposed_: after signedIn_◎ : $isDisposed_');
      print(googleSignInAccount.runtimeType);
      // ログイン成功した場合だけ、ログイン後の処理を実行
      if (googleSignInAccount != null) {
        // ここに awaitをつけていないことが問題なのか？
        //await _afterGoogleLogin(googleSignInAccount);
        print('isDisposed_: before signedIn_★ : $isDisposed_');
        signedIn_ = true;
        print('isDisposed_: after signedIn_★ : $isDisposed_');
        storage.write(key: "signedIn", value: "true").then((value) {
          //! setStateを削除
          signedIn_ = true;
        });
      }
    }

    // この時点で Disposeされているかチェックする
    //print('isDisposed_ at the end of loginWithGoogle: $isDisposed_');
    // 結局、最後に一発叩けばいいだけなのか？
    //notifyListeners();
  }

  // ログイン後の処理
  Future<void> _afterGoogleLogin(GoogleSignInAccount gSA) async {
    print('_afterGoogleLoginが呼ばれたか？');

    print('isDisposed_ at _afterGoogleLogin: $isDisposed_');

    // メンバ変数 googleSignInAccount に 引数で渡されてきたgSAを代入する
    // gSAの型は はてな無しのGoogleSignInAccountだから、
    // メンバ変数 googleSignInAccount もNull不可型になるはず。
    // 自動的に Null不可型にならないものかなぁ～
    googleSignInAccount_ = gSA;

    // (A)before authentication
    print('isDisposed_ at before authentication: $isDisposed_'); // ここではまだfalse

    //====▼▼ Firebase Auth（ここから）▼▼====//

    // /// Retrieve [GoogleSignInAuthentication] for this account.
    // /// GoogleSignInAuthenticationは、サインイン後のトークン情報を保持する
    // ///   accessToken と idToken を取得できる。
    // /// メンバ変数は、_data 一つだけ
    // ///   final GoogleSignInTokenData _data;
    // /// この GoogleSignInTokenDataに 次の3つのメンバ変数がある
    // // class GoogleSignInTokenData {
    // //   /// Build `GoogleSignInTokenData`.
    // //   GoogleSignInTokenData({
    // //     this.idToken,
    // //     this.accessToken,
    // //     this.serverAuthCode,
    // //   });
    // final GoogleSignInAuthentication googleSignInAuthentication =
    //     await googleSignInAccount_!.authentication;
    //
    // // 上記の(A)と下記の(B)の間で、一度、buildが呼ばれており、下記のログが残る。
    // // I/flutter (13210): build内 singedIn: false
    // // I/flutter (13210): build内 googleSignInAccount: null
    //
    // // つまり、この googleSignInAccount_!.authenticationが怪しい、ということだ。
    //
    // // (B)before credential
    // print('isDisposed_ at before credential: $isDisposed_'); // ここでは既にtrue
    //
    //
    // // たぶん、仕様が変わったのだと思う。
    // //final AuthCredential credential = GoogleAuthProvider.getCredential(
    // final AuthCredential credential = GoogleAuthProvider.credential(
    //   accessToken: googleSignInAuthentication.accessToken,
    //   idToken: googleSignInAuthentication.idToken,
    // );
    //
    // //print('isDisposed_ at after credential: $isDisposed_'); // ここでは既にtrue
    //
    // // ここでFirebase Authに連携している。
    // //final AuthResult authResult = await _auth.signInWithCredential(credential);
    // final UserCredential authResult =
    //     await _auth.signInWithCredential(credential);
    // final User? user = authResult.user;
    //
    // assert(!user!.isAnonymous);
    // //assert(await user!.getIdToken() != null);
    // assert(await user!.getIdToken() is String);
    //
    // final User currentUser = _auth.currentUser!;
    // assert(user!.uid == currentUser.uid);

    //print('signInWithGoogle succeeded: $user');
    //print('isDisposed_ at after succeeded: $isDisposed_');// ここでは既にtrue

    //====▲▲ Firebase Auth（ここまで）▲▲====//

    storage.write(key: "signedIn", value: "true").then((value) {
      //! setStateを削除
      signedIn_ = true;
    });

    // 外に出した
    //notifyListeners();
  }

  bool isDisposed_ = false;

//  get bool isDisposed => _disposed;

  @override
  void dispose() {
    isDisposed_ = true;
    notifyListeners();
    super.dispose();
  }

  //
  // @override
  // void notifyListeners() {
  //   if (!_disposed) {
  //     super.notifyListeners();
  //   }
  // }

  void logoutFromGoogle() async {
    googleSignIn_.signOut().then((value) {
      print("User Sign Out");
      storage.write(key: "signedIn", value: "false").then((value) {
        //! setStateを削除
        signedIn_ = false;
        //notifyListeners();
      });
    });
  }
}

enum ChangeNotifierState {
  initial,
  homePage,
  loginPage,
}
