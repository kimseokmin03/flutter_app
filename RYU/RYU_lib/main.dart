// 기존 main.dart의 필수 import
import 'package:flutter/material.dart';

// main2.dart에서 추가된 API, Provider, 화면 관련 import
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import '../../lib/ryu/services/auth_service.dart';
import '../../lib/ryu/services/chat_service.dart';
import '../../lib/ryu/services/api_service.dart';
import '../../lib/ryu/screens/welcome_screen.dart';

Future<void> main() async {
  // Flutter 엔진과 위젯 바인딩을 초기화합니다.
  WidgetsFlutterBinding.ensureInitialized();

  // 날짜 형식화를 위해 'ko_KR' 지역 데이터를 초기화합니다.
  await initializeDateFormatting('ko_KR', null);

  // ⭐️ API 서비스 인스턴스 생성 (main2.dart 내용)
  // ⭐️⭐️⭐️⭐️⭐️ 아래 URL을 실제 서버 주소로 변경하세요! ⭐️⭐️⭐️⭐️⭐️
  final ApiService apiService = ApiService('https://flutter-api-server.onrender.com');

  runApp(
    // Provider를 사용하여 AuthService와 ChatService에 ApiService를 주입합니다. (main2.dart 내용)
    MultiProvider(
      providers: [
        Provider(create: (context) => AuthService(apiService)),
        ChangeNotifierProvider(create: (context) => ChatService(apiService)),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const WelcomeScreen(),
    );
  }
}