import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/io.dart';
import 'api_service.dart';
import '../models/chat_room.dart';
import '../models/message.dart';
import '../models/user.dart';

class ChatService with ChangeNotifier {
  final ApiService _apiService;
  
  // ⭐️ WebSocket 채널
  IOWebSocketChannel? _channel;
  
  // ⭐️ 상태: UI가 구독할 데이터
  List<ChatRoom> _chatRooms = [];
  List<User> _users = [];
  User? _myProfile;
  // ⭐️ key: chatRoomId, value: 메시지 목록
  final Map<String, List<Message>> _messages = {};
  
  bool _isLoadingRooms = false;
  bool _isLoadingUsers = false;
  bool _isLoadingProfile = false;
  
  // ⭐️ UI가 접근할 Getter
  List<ChatRoom> get chatRooms => _chatRooms;
  List<User> get users => _users;
  User? get myProfile => _myProfile;
  Map<String, List<Message>> get messages => _messages;
  bool get isLoadingRooms => _isLoadingRooms;
  bool get isLoadingUsers => _isLoadingUsers;

  // ⭐️ 현재 사용자 ID (SharedPreferences에서 가져옴)
  String? _currentUserId;

  ChatService(this._apiService) {
    _loadCurrentUserId();
  }
  
  Future<void> _loadCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    _currentUserId = prefs.getString('userId');
  }

  // ⭐️ 1. WebSocket 연결 (로그인 성공 시 호출)
  Future<void> connect() async {
    if (_channel != null) return; // 이미 연결됨
    if (_currentUserId == null) await _loadCurrentUserId();

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    
    if (token == null) return; // 토큰 없음

    // ⭐️ ws://YOUR_NODE_SERVER_URL/chat?token=...
    final wsUrl = _apiService.getWsUrl() + '/?token=$token'; // ⭐️ Node.js 'ws' 라이브러리 호환
    
    try {
      _channel = IOWebSocketChannel.connect(Uri.parse(wsUrl));
      _listen();
    } catch (e) {
      debugPrint("WebSocket 연결 실패: $e");
    }
  }

  // ⭐️ 2. WebSocket 이벤트 수신
  void _listen() {
    _channel?.stream.listen((event) {
      final data = jsonDecode(event);
      
      // ⭐️ Node.js 서버가 보낸 이벤트 타입에 따라 분기
      switch (data['type']) {
        case 'newMessage':
          _handleNewMessage(Message.fromJson(data['payload']));
          break;
        case 'roomUpdate': // 안읽음 개수, 마지막 메시지 등
          _handleRoomUpdate(ChatRoom.fromJson(data['payload'], _currentUserId!));
          break;
        // (기타 필요한 이벤트, 예: 'profileUpdated', 'userHidden' 등)
      }

    }, onError: (error) {
      debugPrint("WebSocket 오류: $error");
      _channel = null;
      // (재연결 로직)
    }, onDone: () {
      debugPrint("WebSocket 연결 종료");
      _channel = null;
      // (재연결 로직)
    });
  }
  
  // ⭐️ 3. WebSocket 이벤트 핸들러
  void _handleNewMessage(Message message) {
    // 현재 채팅방 목록에 메시지 추가
    if (_messages.containsKey(message.chatRoomId)) {
      _messages[message.chatRoomId]?.insert(0, message); // 0번에 추가 (최신순)
      notifyListeners();
    }
    // (채팅방 목록도 갱신해야 함 - roomUpdate 이벤트가 같이 오거나, 여기서 갱신)
  }
  
  void _handleRoomUpdate(ChatRoom updatedRoom) {
    final index = _chatRooms.indexWhere((r) => r.id == updatedRoom.id);
    if (index != -1) {
      _chatRooms[index] = updatedRoom; // 기존 방 정보 갱신
    } else {
      _chatRooms.insert(0, updatedRoom); // 새 채팅방 추가
    }
    // ⭐️ 최신 메시지 순으로 정렬
    _chatRooms.sort((a, b) => b.lastMessageTimestamp.compareTo(a.lastMessageTimestamp));
    notifyListeners();
  }
  
  // ⭐️ 4. API를 통해 데이터 로드 (Future)
  
  Future<void> loadChatRooms() async {
    if (_isLoadingRooms) return;
    _isLoadingRooms = true;
    notifyListeners();
    try {
      final jsonList = await _apiService.getChatRooms();
      _chatRooms = jsonList.map((json) => ChatRoom.fromJson(json, _currentUserId!)).toList();
    } catch (e) {
      debugPrint("채팅방 로드 실패: $e");
    }
    _isLoadingRooms = false;
    notifyListeners();
  }
  
  Future<void> loadUsers() async {
    if (_isLoadingUsers) return;
    _isLoadingUsers = true;
    notifyListeners();
    try {
      final jsonList = await _apiService.getUsers();
      _users = jsonList.map((json) => User.fromJson(json)).toList();
    } catch (e) {
      debugPrint("사용자 로드 실패: $e");
    }
    _isLoadingUsers = false;
    notifyListeners();
  }

  Future<void> loadMyProfile() async {
    if (_isLoadingProfile) return;
    _isLoadingProfile = true;
    notifyListeners();
     try {
      final json = await _apiService.getMyProfile();
      _myProfile = User.fromJson(json);
    } catch (e) {
      debugPrint("프로필 로드 실패: $e");
    }
    _isLoadingProfile = false;
    notifyListeners();
  }
  
  Future<void> loadMessages(String chatRoomId, DateTime? leftAt) async {
    try {
      final jsonList = await _apiService.getMessages(chatRoomId, leftAt);
      _messages[chatRoomId] = jsonList.map((json) => Message.fromJson(json)).toList();
    } catch (e) {
      debugPrint("메시지 로드 실패: $e");
    }
    notifyListeners();
  }
  
  // ⭐️ 5. API 호출 (POST/PUT - 상태 변경)

  Future<String> createOrGetChatRoom(List<String> userIds, String? roomName) async {
    try {
      final json = await _apiService.createChatRoom(userIds, roomName);
      return json['id'].toString(); // ⭐️ 생성된 채팅방 ID 반환
    } catch (e) {
      rethrow;
    }
  }

  Future<void> hideChatRoom(String chatRoomId) async {
    await _apiService.hideChatRoom(chatRoomId);
    // ⭐️ 로컬 목록에서 즉시 제거 (UI 반응성)
    _chatRooms.removeWhere((r) => r.id == chatRoomId);
    notifyListeners();
  }

  Future<void> hideUser(String userIdToHide) async {
    await _apiService.hideUser(userIdToHide);
    // ⭐️ 로컬 목록에서 즉시 제거 (UI 반응성)
    _users.removeWhere((u) => u.id == userIdToHide);
    _myProfile?.hiddenUsers.add(userIdToHide); // ⭐️ 내 프로필에도 반영
    notifyListeners();
  }
  
  Future<void> markChatRoomAsRead(String chatRoomId) async {
    // ⭐️ 낙관적 업데이트: UI 먼저 0으로
    final index = _chatRooms.indexWhere((r) => r.id == chatRoomId);
    if (index != -1 && _chatRooms[index].myUnreadCount > 0) {
       // ⭐️ 모델이 불변(immutable)하다고 가정하고 새 객체로 교체
       final oldRoom = _chatRooms[index];
       _chatRooms[index] = ChatRoom(
         id: oldRoom.id,
         roomName: oldRoom.roomName,
         lastMessage: oldRoom.lastMessage,
         lastMessageTimestamp: oldRoom.lastMessageTimestamp,
         myUnreadCount: 0, // ⭐️ 0으로 변경
         leftAt: oldRoom.leftAt,
       );
       notifyListeners();
    }
    // ⭐️ API 호출 (백그라운드)
    await _apiService.markRoomAsRead(chatRoomId);
    // ⭐️ 서버가 'roomUpdate' 이벤트를 보내주면 더 정확하게 갱신됨
  }

  Future<void> sendMessage(String chatRoomId, String text) async {
    if (text.trim().isEmpty) return;
    // ⭐️ API 호출
    await _apiService.sendMessage(chatRoomId, text);
    // ⭐️ Node.js가 'newMessage'와 'roomUpdate' 이벤트를
    // ⭐️ 모든 참가자(나 포함)에게 WebSocket으로 보내줌
  }
  
  // ⭐️ 프로필 수정 후 데이터 갱신
  Future<void> refreshProfileAndUsers() async {
    await loadMyProfile();
    await loadUsers(); // ⭐️ 다른 사람의 이름 변경도 반영될 수 있음
    await loadChatRooms(); // ⭐️ 채팅방 이름 갱신
  }
  
  // ⭐️ 로그아웃 시 상태 초기화
  void disposeConnection() {
    _channel?.sink.close();
    _channel = null;
    _chatRooms = [];
    _users = [];
    _myProfile = null;
    _messages.clear();
    debugPrint("ChatService 연결 해제 및 상태 초기화");
    notifyListeners(); // ⭐️ UI도 초기화 상태로 돌림
  }
}