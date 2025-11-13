import 'package:flutter/material.dart';
import 'package:kakao_map_sdk/kakao_map_sdk.dart'; // 카카오맵 SDK
import 'package:intl/date_symbol_data_local.dart'; // 날짜 포맷팅
import 'package:provider/provider.dart'; // 상태 관리 및 의존성 주입
import 'ryu/services/auth_service.dart'; // 인증 서비스
import 'ryu/services/chat_service.dart'; // 채팅 서비스
import 'ryu/services/api_service.dart'; // API 서비스



// 앱의 시작 화면
import 'ryu/screens/welcome_screen.dart'; 


Future<void> main() async {
  // Flutter 엔진과 위젯 바인딩을 초기화합니다.
  WidgetsFlutterBinding.ensureInitialized();

  // 1. 카카오맵 SDK 초기화
  // ⭐️ [YOUR_KAKAO_JAVASCRIPT_KEY]를 실제 카카오 JavaScript 키로 변경하세요!
  KakaoMapSdk.instance.initialize("f886a42dac1df90a5697008af44a87fb");

  // 2. 한국어 날짜 포맷팅 초기화
  await initializeDateFormatting('ko_KR', null);

  // 3. API 서비스 인스턴스 생성 (백엔드 서버 주소 설정)
  // ⭐️ 아래 URL을 실제 실행 중인 Node.js 서버 주소로 변경하세요!
  final ApiService apiService = ApiService('https://flutter-api-server.onrender.com');

  // 4. MultiProvider를 사용하여 앱 실행 및 서비스 주입
  runApp(
    MultiProvider(
      providers: [
        // ApiService 자체를 주입하여 다른 컴포넌트가 직접 접근 가능하도록 함
        Provider.value(value: apiService),
        // AuthService와 ChatService에 ApiService를 주입 (Dependency Injection)
        Provider(create: (context) => AuthService(apiService)),
        ChangeNotifierProvider(create: (context) => ChatService(apiService)),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: const WelcomeScreen(),
    );
  }
}