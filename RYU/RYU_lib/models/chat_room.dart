class ChatRoom {
  final String id;
  final String roomName; // ⭐️ 1:1 채팅 시 상대방 이름, 그룹 시 그룹명
  final String lastMessage;
  final DateTime lastMessageTimestamp;
  final int myUnreadCount; // ⭐️ 1.1 내 안읽음 개수
  final DateTime? leftAt; // ⭐️ '영구' 삭제용 '떠난 시간'

  ChatRoom({
    required this.id,
    required this.roomName,
    required this.lastMessage,
    required this.lastMessageTimestamp,
    required this.myUnreadCount,
    this.leftAt,
  });

  factory ChatRoom.fromJson(Map<String, dynamic> json, String currentUserId) {
    return ChatRoom(
      id: json['id'].toString(), // ⭐️ .toString()
      roomName: json['room_name'] ?? '알 수 없는 대화',
      lastMessage: json['last_message'] ?? '',
      lastMessageTimestamp: DateTime.parse(json['last_message_timestamp']).toLocal(),
      myUnreadCount: (json['my_unread_count'] ?? 0).toInt(),
      leftAt: json['left_at'] != null ? DateTime.parse(json['left_at']).toLocal() : null,
    );
  }
}