import 'package:flutter/material.dart';
import 'package:project/bottombar.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'welcome_screen.dart';
import 'package:project/bottombar.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ⭐️ Firebase AuthStateChanges() 대신 AuthService.isLoggedIn() 사용
    return FutureBuilder<bool>(
      future: Provider.of<AuthService>(context, listen: false).isLoggedIn(),
      builder: (context, snapshot) {
        
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData && snapshot.data == true) {
          // ⭐️ 로그인이 되어 있으면 MainScreen
          return const MyBottomNavBar();
        }

        // ⭐️ 비로그인 상태이면 WelcomeScreen
        return const WelcomeScreen();
      },
    );
  }
}