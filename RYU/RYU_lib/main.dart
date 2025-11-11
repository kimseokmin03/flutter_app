import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'services/auth_service.dart';
import 'services/chat_service.dart';
import 'services/api_service.dart'; // ⭐️ API 서비스 추가
import 'screens/welcome_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // ⭐️ Firebase 초기화 제거
  
  await initializeDateFormatting('ko_KR', null); 

  // ⭐️ API 서비스 인스턴스 생성
  // ⭐️⭐️⭐️⭐️⭐️⭐️⭐️⭐️⭐️⭐️⭐️⭐️⭐️⭐️⭐️⭐️⭐️⭐️
  // ⭐️ 아래 URL을 실제 실행 중인 Node.js 서버 주소로 변경하세요!
  // ⭐️ 예: 'http://192.168.0.5:3000' 또는 'http://내도메인.com'
  // ⭐️⭐️⭐️⭐️⭐️⭐️⭐️⭐️⭐️⭐️⭐️⭐️⭐️⭐️⭐️⭐️⭐️⭐️
  final ApiService apiService = ApiService('https://flutter-api-server.onrender.com'); 

  runApp(
    MultiProvider(
      providers: [
        // ⭐️ AuthService와 ChatService에 ApiService 주입
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
      debugShowCheckedModeBanner: false,
      title: 'Flutter Chat Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          titleTextStyle: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
          iconTheme: IconThemeData(color: Colors.black),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.grey,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
        ),
      ),
      home: const WelcomeScreen(),
    );
  }
}