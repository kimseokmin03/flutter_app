import 'package:kakao_map_sdk/kakao_map_sdk.dart';

// ★ 위젯이 아닌, 단순 초기화 함수
Future<void> initializeApp() async {
  await KakaoMapSdk.instance.initialize("f886a42dac1df90a5697008af44a87fb");
}
