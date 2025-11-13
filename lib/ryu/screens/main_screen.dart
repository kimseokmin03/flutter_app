import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'chat_list_page.dart';
import 'select_users_page.dart';
import 'profile_screen.dart';
import '../services/chat_service.dart'; // ⭐️

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final List<Widget> _pages = [
    const ChatListPage(),
    const ProfileScreen(), 
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  // ⭐️ MainScreen 진입 시 WebSocket 연결 및 데이터 로드
  @override
  void initState() {
    super.initState();
    // ⭐️ 비동기로 호출 (await 안함)
    _loadData();
  }

  Future<void> _loadData() async {
    final chatService = Provider.of<ChatService>(context, listen: false);
    // 1. WebSocket 연결 (이미 되어있을 수 있지만, 확인차)
    await chatService.connect();
    // 2. 초기 데이터 로드
    chatService.loadChatRooms();
    chatService.loadUsers();
    chatService.loadMyProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex], 
      floatingActionButton: _currentIndex == 0 ? FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SelectUsersPage()),
          );
        },
        child: const Icon(Icons.add),
      ) : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble),
            label: '채팅',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '프로필',
          ),
        ],
      ),
    );
  }
}