import 'package:flutter/material.dart';
import 'screen_map/map_main.dart'; // KakaoMapView를 가져옵니다.
import 'screen_home/home_main.dart';
//종훈게이 만든거 임포트

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
    _widgetOptions = <Widget>[
      const Homescreen(),
      const KakaoMapView(),
      //종훈게이 만든 스크린 여기다가 비슷한 형식으로 선언하고
      //밑에거 중 해당하는거 지우면 됨
      const Center(child: Text('Chat Screen', style: TextStyle(fontSize: 30))),
      const Center(
        child: Text('👤 Profile Screen', style: TextStyle(fontSize: 30)),
      ), // '홈' 탭에 키와 함께 PostingScreen 위젯을 연결
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // 상태 업데이트
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 현재 선택된 인덱스에 해당하는 화면을 body에 표시
      body: IndexedStack(index: _selectedIndex, children: _widgetOptions),

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
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
