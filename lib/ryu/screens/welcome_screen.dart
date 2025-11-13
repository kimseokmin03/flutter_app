import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../services/chat_service.dart'; // ⭐️ WebSocket 연결용
import 'auth_gate.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final TextEditingController _nameController = TextEditingController();
  final ValueNotifier<bool> _isLoading = ValueNotifier(false);
  late AuthService _authService;

  @override
  void initState() {
    super.initState();
    _authService = Provider.of<AuthService>(context, listen: false);
    _checkLogin(); 
  }

  // 1. ⭐️ 토큰 확인으로 변경
  void _checkLogin() async {
    _isLoading.value = true;
    final prefs = await SharedPreferences.getInstance();
    final displayName = prefs.getString('displayName');
    
    // ⭐️ Firebase 세션 대신 토큰 유무 확인
    if (await _authService.isLoggedIn()) { 
      if (mounted) {
        // ⭐️ AuthGate가 MainScreen으로 보내줄 것임
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AuthGate()),
        );
      }
    } else {
      // ⭐️ 저장된 이름이 있으면 텍스트 필드에 미리 채우기
      _nameController.text = displayName ?? '';
      _isLoading.value = false;
    }
  }

  // 2. ⭐️ API 로그인 호출
  void _submit() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이름을 입력해 주세요.')),
      );
      return;
    }

    _isLoading.value = true;
    final displayName = _nameController.text.trim();

    try {
      // ⭐️ 1. API로 로그인
      await _authService.signInAnonymously(displayName);

      // ⭐️ 2. (저장 로직은 AuthService가 담당)

      // ⭐️ 3. WebSocket 연결 시작!
      if (mounted) {
        await Provider.of<ChatService>(context, listen: false).connect();
      }

      // ⭐️ 4. AuthGate로 이동
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AuthGate()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('로그인 실패: ${e.toString()}')),
      );
      _isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('채팅 입장하기'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: '사용할 이름',
                  border: OutlineInputBorder(),
                ),
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: 20),
              ValueListenableBuilder<bool>(
                valueListenable: _isLoading,
                builder: (context, isLoading, child) {
                  if (isLoading) {
                    return const CircularProgressIndicator();
                  }
                  return ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    ),
                    child: const Text('입장하기'),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}