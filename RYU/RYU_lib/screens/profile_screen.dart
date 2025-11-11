import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/chat_service.dart';
import 'welcome_screen.dart';
import '../models/user.dart'; // ⭐️

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _sportController = TextEditingController();
  late AuthService _authService;
  late ChatService _chatService;

  bool _isLoading = false;
  String _currentName = '';
  
  // ⭐️ Consumer로 UI가 빌드된 후 텍스트 필드 채우기
  void _updateControllers(User user) {
    if (_nameController.text != user.displayName) {
      _nameController.text = user.displayName;
    }
     _currentName = user.displayName;
    if (_sportController.text != (user.preferredSport ?? '')) {
     _sportController.text = user.preferredSport ?? '';
    }
  }


  @override
  void dispose() {
    _nameController.dispose();
    _sportController.dispose();
    super.dispose();
  }

  // ⭐️ 2.2 프로필 저장 기능 (API 호출)
  Future<void> _saveProfile() async {
    _authService = Provider.of<AuthService>(context, listen: false);
    _chatService = Provider.of<ChatService>(context, listen: false);

    final newName = _nameController.text.trim();
    final newSport = _sportController.text.trim();

    if (newName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이름은 비워둘 수 없습니다.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. ⭐️ AuthService를 통해 프로필 업데이트 (API 호출)
      await _authService.updateProfile(newName, newSport);

      // 2. ⭐️ 이름이 변경되었다면, ChatService에 데이터 갱신 요청
      if (newName != _currentName) {
        await _chatService.refreshProfileAndUsers();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('프로필이 저장되었습니다.')),
      );
      setState(() {
        _currentName = newName; 
      });

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('저장 실패: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ⭐️ 2.3 로그아웃 기능 (WebSocket 연결 해제 추가)
  Future<void> _logout() async {
    _authService = Provider.of<AuthService>(context, listen: false);
    _chatService = Provider.of<ChatService>(context, listen: false);

    await _authService.signOut(); // ⭐️ 토큰 삭제
    _chatService.disposeConnection(); // ⭐️ WebSocket 연결 해제 및 상태 초기화

    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const WelcomeScreen()),
        (route) => false,
      );
    }
  }

  void _showComingSoonDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('알림'),
        content: const Text('준비 중인 기능입니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('프로필'),
      ),
      // ⭐️ StreamBuilder 대신 Consumer
      body: Consumer<ChatService>(
        builder: (context, chatService, child) {
          if (chatService.myProfile == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final User userData = chatService.myProfile!;
          
          // ⭐️ 빌드 후 컨트롤러 업데이트
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _updateControllers(userData);
          });
          
          final String userId = userData.id;

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              ListTile(
                leading: const Icon(Icons.badge),
                title: const Text('이름 (필수)', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(hintText: '이름을 입력하세요'),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.fitness_center),
                title: const Text('선호하는 운동', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: TextField(
                  controller: _sportController,
                  decoration: const InputDecoration(hintText: '예: 축구, 농구'),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveProfile,
                child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('저장하기'),
              ),
              const Divider(height: 40),

              // --- 2.3 껍데기 항목들 ---
              ListTile(
                leading: const Icon(Icons.account_circle),
                title: const Text('아이디'),
                subtitle: Text(userId), // ⭐️ integer여도 String으로 표시됨
              ),
               ListTile(
                leading: const Icon(Icons.lock),
                title: const Text('비밀번호 변경'),
                trailing: const Icon(Icons.chevron_right),
                onTap: _showComingSoonDialog,
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('환경설정'),
                trailing: const Icon(Icons.chevron_right),
                onTap: _showComingSoonDialog,
              ),
               ListTile(
                leading: const Icon(Icons.notifications),
                title: const Text('알림 설정'),
                trailing: const Icon(Icons.chevron_right),
                onTap: _showComingSoonDialog,
              ),
              ListTile(
                leading: const Icon(Icons.description),
                title: const Text('이용약관'),
                trailing: const Icon(Icons.chevron_right),
                onTap: _showComingSoonDialog,
              ),
              ListTile(
                leading: const Icon(Icons.campaign),
                title: const Text('공지사항'),
                trailing: const Icon(Icons.chevron_right),
                onTap: _showComingSoonDialog,
              ),
               ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('앱 버전'),
                subtitle: const Text('1.0.0'),
                onTap: _showComingSoonDialog,
              ),
              const Divider(height: 40),
              TextButton(
                onPressed: _logout,
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('로그아웃'),
              ),
            ],
          );
        },
      ),
    );
  }
}