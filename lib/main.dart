// main.dart
import 'package:flutter/material.dart';
import 'package:project/screen_map/map_loader.dart';
// MyBottomNavBar 위젯을 사용하기 위해 import 합니다. (파일명이 bottombar.dart인 경우)
import '../bottombar.dart';

Future<void> main() async {
  // Flutter 엔진과 위젯 바인딩을 초기화합니다.
  WidgetsFlutterBinding.ensureInitialized();

  await initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Bottom Bar App',
      // main.dart에서 bottombar.dart의 위젯을 불러와 사용
      home: MyBottomNavBar(),
    );
  }
}
