import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/chat_service.dart';
import 'chat_screen.dart';
import '../models/user.dart'; // ⭐️

class SelectUsersPage extends StatefulWidget {
  const SelectUsersPage({Key? key}) : super(key: key);

  @override
  State<SelectUsersPage> createState() => _SelectUsersPageState();
}

class _SelectUsersPageState extends State<SelectUsersPage> {
  final Map<String, String> _selectedUsers = {}; // Key: uid, Value: displayName

  void _toggleUserSelection(String uid, String displayName) {
    setState(() {
      if (_selectedUsers.containsKey(uid)) {
        _selectedUsers.remove(uid);
      } else {
        _selectedUsers[uid] = displayName;
      }
    });
  }

  void _showHideUserDialog(BuildContext context, ChatService chatService, String uid, String displayName) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('$displayName 님을 숨기시겠습니까?'),
          content: const Text('이 사용자가 대화 상대 목록에 더 이상 표시되지 않습니다.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () {
                // ⭐️ API 호출
                chatService.hideUser(uid);
                Navigator.pop(context);
              },
              child: const Text('숨기기', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _createChat() async {
    if (_selectedUsers.isEmpty) return;

    final chatService = Provider.of<ChatService>(context, listen: false);
    
    final List<String> userIds = _selectedUsers.keys.toList();
    final List<String> userNames = _selectedUsers.values.toList();
    
    String? roomName;
    String receiverName; 

    if (userIds.length > 1) {
      roomName = "그룹 채팅 (${userIds.length + 1}명)";
      receiverName = roomName;
    } else {
      roomName = null;
      receiverName = userNames.first;
    }

    // ⭐️ API 호출
    final String chatRoomId = await chatService.createOrGetChatRoom(userIds, roomName);

    if (mounted) {
      Navigator.pop(context); // 현재 선택 화면 닫기
      Navigator.push( // 채팅방 열기
        context,
        MaterialPageRoute(
          builder: (context) => ChatScreen(
            chatRoomId: chatRoomId,
            receiverName: receiverName,
            // ⭐️ 새 방이므로 leftAt은 null
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // ⭐️ Consumer로 변경
    return Scaffold(
      appBar: AppBar(
        title: const Text('대화 상대 선택'),
        actions: [
          TextButton(
            onPressed: _selectedUsers.isEmpty ? null : _createChat,
            child: Text(
              '확인',
              style: TextStyle(
                color: _selectedUsers.isEmpty ? Colors.grey : Colors.black,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: Consumer<ChatService>(
        builder: (context, chatService, child) {
          
          if (chatService.isLoadingUsers || chatService.myProfile == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final allUsers = chatService.users;
          
          // ⭐️ 내 정보에서 'hiddenUsers' 목록 가져오기
          final hiddenUsers = chatService.myProfile?.hiddenUsers ?? [];
          
          // ⭐️ 전체 사용자 중 '숨긴 사용자' 필터링 (로컬)
          final visibleUsers = allUsers.where((user) {
            return !hiddenUsers.contains(user.id);
          }).toList();

          if (visibleUsers.isEmpty) {
            return const Center(child: Text('대화 가능한 상대가 없습니다.'));
          }

          return ListView.builder(
            itemCount: visibleUsers.length,
            itemBuilder: (context, index) {
              final User user = visibleUsers[index]; // ⭐️ 모델 사용
              final uid = user.id;
              final displayName = user.displayName;
              
              final isSelected = _selectedUsers.containsKey(uid);

              return ListTile(
                leading: CircleAvatar(
                  child: isSelected ? const Icon(Icons.check, color: Colors.white) : const Icon(Icons.person),
                  backgroundColor: isSelected ? Colors.blue : Colors.grey[300],
                ),
                title: Text(displayName),
                onTap: () => _toggleUserSelection(uid, displayName),
                onLongPress: () {
                  _showHideUserDialog(context, chatService, uid, displayName);
                },
              );
            }
          );
        },
      ),
    );
  }
}