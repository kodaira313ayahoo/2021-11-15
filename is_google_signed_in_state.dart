import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'google_sign_in_stream.dart';

// 外部から書き換えられるグローバル変数的な役割（アンチパターンではないか？）
// どこから書き換えられているのか探し出せない。
final StateProvider<bool> isGoogleSignedInStateProvider =
    StateProvider<bool>((ref) => false);

//! 松本作！ ちょっとトリッキーだが、ナイスかも。
final Provider<bool> isGoogleSignedInProvider = Provider<bool>((ref) {
  final stream1 = ref.watch(googleSignInStreamProvider.stream);
  bool isGoogleSignedInState = ref.watch(isGoogleSignedInStateProvider);
  final googleSignIn = ref.watch(googleSignInProvider);

  // ここでリスナーを設定するところがミソ。
  stream1.listen((event) async {
    // そして、外部のStateProviderの値を更新する
    bool boolTemp = await googleSignIn.isSignedIn();
    if (isGoogleSignedInState != boolTemp) {
      isGoogleSignedInState = boolTemp;
    }
    //return await googleSignIn.isSignedIn();
  });

  // その外部の値を読み込み、返す。
  final bool isGoogleSignedIn = ref.watch(isGoogleSignedInStateProvider);
  return isGoogleSignedIn;
});
