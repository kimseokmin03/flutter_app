class Message {
  final String id;
  final String chatRoomId;
  final String senderId;
  final String text;
  final DateTime createdAt;
  final int unreadCount; // ⭐️ 채팅방 안의 '1' 표시용

  Message({
    required this.id,
    required this.chatRoomId,
    required this.senderId,
    required this.text,
    required this.createdAt,
    required this.unreadCount,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'].toString(), // ⭐️ .toString()
      chatRoomId: json['chat_room_id'].toString(), // ⭐️ .toString()
      senderId: json['sender_id'].toString(), // ⭐️ .toString() (integer -> String)
      text: json['text'],
      createdAt: DateTime.parse(json['created_at']).toLocal(),
      unreadCount: (json['unread_count'] ?? 0).toInt(),
    );
  }
}