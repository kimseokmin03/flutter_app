import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// --- 사용자 정의 스크린 및 서비스 Import ---
// 맵 (KakaoMapView)
import 'screen_map/map_main.dart';
// 홈 (Homescreen)
import 'screen_home/home_main.dart';
// 채팅 목록 및 프로필
import 'ryu/screens/chat_list_page.dart';
import 'ryu/screens/profile_screen.dart';
// 새로운 채팅방 생성 화면 (FAB 연결)
import 'ryu/screens/select_users_page.dart'; // ⭐️ 추가된 import
// 채팅 서비스
import 'ryu/services/chat_service.dart';
import 'ryu/screens/auth_gate.dart';



class MyBottomNavBar extends StatefulWidget {
  const MyBottomNavBar({super.key});

  @override
  State<MyBottomNavBar> createState() => _MyBottomNavBarState();
}

class _MyBottomNavBarState extends State<MyBottomNavBar> {
  int _selectedIndex = 0; // 현재 선택된 탭의 인덱스
  late final List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    
    // 1. 화면 목록 초기화
    _widgetOptions = <Widget>[
      // 순서: 0: Home, 1: Map, 2: Chat, 3: Profile
      const Homescreen(), // Index 0
      const KakaoMapView(), // Index 1
      const ChatListPage(), // Index 2 (채팅 목록)
      const ProfileScreen(), // Index 3
    ];
    
    // 2. 초기 데이터 로딩 함수 호출 (비동기로 실행)
    _loadData();
  }

  // 탭 선택 시 호출되는 함수
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // 상태 업데이트
    });
  }
  
  // 필요한 초기 데이터를 로드하는 함수
  Future<void> _loadData() async {
    final chatService = Provider.of<ChatService>(context, listen: false);
    
    // 1. WebSocket 연결 (안정성을 위해 확인 및 연결 시도)
    try {
      await chatService.connect();
    } catch (e) {
      print('WebSocket 연결 실패: $e');
    }

    // 2. 초기 데이터 로드 (API 요청)
    chatService.loadChatRooms();
    chatService.loadUsers();
    chatService.loadMyProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack을 사용하여 탭 전환 시 위젯 상태를 유지합니다.
      body: IndexedStack(
        index: _selectedIndex, 
        children: _widgetOptions
      ),

      // ⭐️ 플로팅 액션 버튼 로직 추가
      // 채팅 목록 탭(Index 2)일 때만 버튼을 표시합니다.
      floatingActionButton: _selectedIndex == 2 ? FloatingActionButton(
        onPressed: () {
          // 버튼 클릭 시 사용자 선택 화면으로 이동
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SelectUsersPage()),
          );
        },
        child: const Icon(Icons.add),
      ) : null, // 다른 탭에서는 버튼을 숨깁니다.

      // **BottomNavigationBar 정의**
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.map_outlined), label: '지도'),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: '채팅',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: '프로필'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey, // unselectedItemColor 추가
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}