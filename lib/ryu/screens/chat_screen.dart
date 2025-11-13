import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../services/chat_service.dart';
import '../models/message.dart'; // ⭐️

class ChatScreen extends StatefulWidget {
  final String chatRoomId;
  final String receiverName; 
  final DateTime? leftAt; // ⭐️ '떠난 시간' (필터링용)

  const ChatScreen({
    Key? key,
    required this.chatRoomId,
    required this.receiverName,
    this.leftAt, // ⭐️
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  late ChatService _chatService;
  bool _isLoading = true; // ⭐️

  @override
  void initState() {
    super.initState();
    _chatService = Provider.of<ChatService>(context, listen: false);
    
    // ⭐️ 1. 안읽음 '0' 처리 (API 호출)
    _chatService.markChatRoomAsRead(widget.chatRoomId);
    
    // ⭐️ 2. 메시지 목록 로드 (API 호출)
    _loadMessages();
  }
  
  Future<void> _loadMessages() async {
    setState(() => _isLoading = true);
    await _chatService.loadMessages(widget.chatRoomId, widget.leftAt);
    setState(() => _isLoading = false);
  }

  void _sendMessage() {
    if (_messageController.text.trim().isNotEmpty) {
      _chatService.sendMessage(
        widget.chatRoomId, 
        _messageController.text.trim(), 
      );
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.receiverName),
      ),
      body: Column(
        children: [
          // ⭐️ 2. 메시지 목록 (Consumer)
          Expanded(
            // ⭐️ Consumer로 ChatService의 _messages 맵을 구독
            child: Consumer<ChatService>(
              builder: (context, chatService, child) {
                if (_isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                // ⭐️ ChatService에서 현재 방의 메시지 목록 가져오기
                final messages = chatService.messages[widget.chatRoomId] ?? [];

                if (messages.isEmpty) {
                  if (widget.leftAt != null) {
                    return const Center(child: Text('대화방에 다시 참여했습니다.\n메시지를 보내보세요.'));
                  }
                  return const Center(child: Text('메시지를 보내보세요.'));
                }

                return ListView.builder(
                  reverse: true, // 최신 메시지가 하단에 오도록
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final Message message = messages[index]; // ⭐️ 모델 사용
                    
                    // --- ⭐️ 1.2 & 1.3 로직 ---
                    // ⭐️ .toString()으로 변환된 String ID 끼리 비교
                    final bool isMe = message.senderId == chatService.myProfile?.id;
                    final DateTime messageTime = message.createdAt;
                    
                    bool showTimestamp = false; 
                    bool showDateSeparator = false; 
                    
                    if (index == messages.length - 1) {
                      showDateSeparator = true; 
                    } else {
                      final Message prevMessage = messages[index + 1];
                      final DateTime prevTimestamp = prevMessage.createdAt;
                      if (messageTime.day != prevTimestamp.day ||
                          messageTime.month != prevTimestamp.month ||
                          messageTime.year != prevTimestamp.year) {
                        showDateSeparator = true;
                      }
                    }

                    if (index == 0) {
                      showTimestamp = true; 
                    } else {
                      final Message nextMessage = messages[index - 1];
                      final DateTime nextTimestamp = nextMessage.createdAt;
                      final String nextSenderId = nextMessage.senderId;
                      if (message.senderId != nextSenderId ||
                          messageTime.minute != nextTimestamp.minute ||
                          messageTime.hour != nextTimestamp.hour || 
                          showDateSeparator) {
                        showTimestamp = true;
                      }
                    }
                    // --- ⭐️ 로직 종료 ---
                    
                    // ⭐️ 안 읽은 사람 수 (API가 계산)
                    final int unreadCount = message.unreadCount;

                    return Column(
                      children: [
                        if (showDateSeparator) 
                          _buildDateSeparator(messageTime),
                        _buildMessageItem(
                          message.text, 
                          isMe, 
                          unreadCount, 
                          messageTime, 
                          showTimestamp,
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),

          // 3. 메시지 입력창
          _buildMessageInputField(),
        ],
      ),
    );
  }

  // ⭐️ 날짜 구분선 위젯
  Widget _buildDateSeparator(DateTime messageTime) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
      margin: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFE0E0E0),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        DateFormat('yyyy년 MM월 dd일 EEEE', 'ko_KR').format(messageTime),
        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  // ⭐️ 메시지 아이템 위젯
  Widget _buildMessageItem(String text, bool isMe, int unreadCount, DateTime messageTime, bool showTimestamp) {
        return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (isMe) ...[
            if (showTimestamp)
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (unreadCount > 0)
                    Text(
                      '$unreadCount',
                      style: const TextStyle(color: Colors.orange, fontSize: 12),
                    ),
                  Text(
                    DateFormat('HH:mm').format(messageTime),
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            const SizedBox(width: 8), 
          ],
          Container(
            margin: const EdgeInsets.symmetric(vertical: 4), 
            padding: const EdgeInsets.all(12),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.7, 
            ),
            decoration: BoxDecoration(
              color: isMe ? Colors.yellow : Colors.grey[200],
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(12),
                topRight: const Radius.circular(12),
                bottomLeft: isMe ? const Radius.circular(12) : const Radius.circular(0),
                bottomRight: isMe ? const Radius.circular(0) : const Radius.circular(12),
              ),
            ),
            child: Text(text, style: const TextStyle(color: Colors.black)),
          ),
          if (!isMe) ...[
            const SizedBox(width: 8), 
            if (showTimestamp)
              Text(
                DateFormat('HH:mm').format(messageTime),
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
          ]
        ],
      ),
    );
  }

  // ⭐️ 메시지 입력 필드 위젯
  Widget _buildMessageInputField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
      ),
      child: SafeArea( 
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: '메시지 입력...',
                  border: InputBorder.none,
                  filled: true,
                  fillColor: Colors.grey[100],
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(color: Colors.blue),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: _sendMessage,
              color: Colors.blue,
            ),
          ],
        ),
      ),
    );
  }
}