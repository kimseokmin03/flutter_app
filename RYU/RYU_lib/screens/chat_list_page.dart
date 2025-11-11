import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/chat_service.dart';
import 'chat_screen.dart';
import 'package:intl/intl.dart';
import '../models/chat_room.dart'; // ⭐️ 모델 임포트

class ChatListPage extends StatelessWidget {
  const ChatListPage({Key? key}) : super(key: key);

  // ⭐️ Timestamp 대신 DateTime 사용
  String _formatTimestamp(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final date = DateTime(dt.year, dt.month, dt.day);

    if (date == today) {
      return DateFormat('HH:mm').format(dt); 
    } else {
      return DateFormat('MM/dd').format(dt);
    }
  }

  void _showDeleteDialog(BuildContext context, ChatService chatService, String chatRoomId, String roomName) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('$roomName\n채팅방을 나가시겠습니까?'),
          content: const Text('채팅방 목록에서 삭제되며, 다시 대화 시 이전 내역이 보이지 않습니다.'), // ⭐️ 문구 수정
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () {
                // ⭐️ ChatService 호출 (API)
                chatService.hideChatRoom(chatRoomId);
                Navigator.pop(context);
              },
              child: const Text('나가기', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // ⭐️ ChatService를 'Provider.of' 대신 'Consumer'로 구독
    return Scaffold(
      appBar: AppBar(
        title: const Text('채팅'),
      ),
      // ⭐️ StreamBuilder 대신 Consumer 사용
      body: Consumer<ChatService>(
        builder: (context, chatService, child) {
          
          // --- 로딩 및 오류 처리 ---
          if (chatService.isLoadingRooms) {
            return const Center(child: CircularProgressIndicator());
          }
          if (chatService.chatRooms.isEmpty) {
            return const Center(child: Text('채팅 내역이 없습니다.\n하단의 + 버튼으로 새 채팅을 시작해 보세요.'));
          }

          // ⭐️ Firestore 'hiddenFor' 필터링은 API가 이미 처리 (is_hidden)
          final chatRooms = chatService.chatRooms;

          // --- 채팅 목록 ---
          return ListView.builder(
            itemCount: chatRooms.length,
            itemBuilder: (context, index) {
              final ChatRoom chatRoom = chatRooms[index]; // ⭐️ 모델 사용

              return ListTile(
                leading: const CircleAvatar(radius: 25, child: Icon(Icons.person)),
                title: Text(
                  chatRoom.roomName, // ⭐️
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  chatRoom.lastMessage, // ⭐️
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: _buildTrailing(chatRoom), // ⭐️
                onTap: () {
                  // ⭐️ 1.1 채팅방 입장 시 '안읽음 0' 처리 (API 호출)
                  chatService.markChatRoomAsRead(chatRoom.id);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(
                        chatRoomId: chatRoom.id,
                        receiverName: chatRoom.roomName,
                        leftAt: chatRoom.leftAt, // ⭐️ '떠난 시간' 전달
                      ),
                    ),
                  );
                },
                onLongPress: () {
                  _showDeleteDialog(context, chatService, chatRoom.id, chatRoom.roomName);
                },
              );
            },
          );
        },
      ),
    );
  }
  
  // ⭐️ Trailing 위젯 (안읽음 + 시간) 수정
  Widget _buildTrailing(ChatRoom chatRoom) {
    final int myUnreadCount = chatRoom.myUnreadCount;
    final DateTime lastMessageTimestamp = chatRoom.lastMessageTimestamp;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _formatTimestamp(lastMessageTimestamp), // ⭐️ DateTime
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
        const SizedBox(height: 5),
        
        if (myUnreadCount > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$myUnreadCount',
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          )
        else
          const SizedBox(height: 20), // ⭐️ 높이 고정용 빈 위젯
      ],
    );
  }
}