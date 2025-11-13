import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  final String _baseUrl;
  final http.Client _client = http.Client();
  String? _token; // ⭐️ 인증용 JWT 토큰

  ApiService(this._baseUrl);
  
  // ⭐️ Node.js 서버의 WebSocket 주소를 반환 (ws://)
  String getWsUrl() {
    return _baseUrl.replaceFirst('http', 'ws');
  }

  // ⭐️ 토큰을 헤더에 추가하는 헬퍼
  Future<Map<String, String>> _getHeaders() async {
    if (_token == null) {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString('token');
    }
    return {
      'Content-Type': 'application/json',
      if (_token != null) 'Authorization': 'Bearer $_token',
    };
  }

  // ⭐️ 토큰 설정 (로그인 시)
  Future<void> setToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  // ⭐️ 토큰 제거 (로그아웃 시)
  Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('userId');
    await prefs.remove('displayName');
  }

  // --- API 호출 메서드들 ---

  // ⭐️ POST /auth/login
  Future<Map<String, dynamic>> login(String displayName) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'}, // ⭐️ 로그인 시에는 토큰 없음
      body: jsonEncode({'displayName': displayName}),
    );
    return _handleResponse(response);
  }

  // ⭐️ GET /users/me (프로필)
  Future<Map<String, dynamic>> getMyProfile() async {
    final response = await _client.get(
      Uri.parse('$_baseUrl/users/me'),
      headers: await _getHeaders(),
    );
    return _handleResponse(response);
  }

  // ⭐️ PUT /users/me (프로필 수정)
  Future<Map<String, dynamic>> updateProfile(String displayName, String preferredSport) async {
    final response = await _client.put(
      Uri.parse('$_baseUrl/users/me'),
      headers: await _getHeaders(),
      body: jsonEncode({'displayName': displayName, 'preferredSport': preferredSport}),
    );
    return _handleResponse(response);
  }
  
  // ⭐️ GET /users (사용자 목록)
  Future<List<dynamic>> getUsers() async {
    final response = await _client.get(
      Uri.parse('$_baseUrl/users'),
      headers: await _getHeaders(),
    );
    return _handleResponse(response);
  }
  
  // ⭐️ GET /rooms (채팅방 목록)
  Future<List<dynamic>> getChatRooms() async {
    final response = await _client.get(
      Uri.parse('$_baseUrl/rooms'),
      headers: await _getHeaders(),
    );
    return _handleResponse(response);
  }

  // ⭐️ POST /rooms (채팅방 생성)
  Future<Map<String, dynamic>> createChatRoom(List<String> userIds, String? roomName) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/rooms'),
      headers: await _getHeaders(),
      body: jsonEncode({'userIds': userIds, 'roomName': roomName}),
    );
    return _handleResponse(response);
  }
  
  // ⭐️ GET /rooms/:roomId/messages (메시지 목록)
  Future<List<dynamic>> getMessages(String chatRoomId, DateTime? leftAt) async {
    String url = '$_baseUrl/rooms/$chatRoomId/messages';
    if (leftAt != null) {
      url += '?leftAt=${leftAt.toIso8601String()}';
    }
    final response = await _client.get(
      Uri.parse(url),
      headers: await _getHeaders(),
    );
    return _handleResponse(response);
  }
  
  // ⭐️ POST /rooms/:roomId/messages (메시지 전송)
  Future<Map<String, dynamic>> sendMessage(String chatRoomId, String text) async {
     final response = await _client.post(
      Uri.parse('$_baseUrl/rooms/$chatRoomId/messages'),
      headers: await _getHeaders(),
      body: jsonEncode({'text': text}),
    );
    return _handleResponse(response);
  }
  
  // ⭐️ POST /rooms/:roomId/read (안읽음 0 처리)
  Future<void> markRoomAsRead(String chatRoomId) async {
    await _client.post(
      Uri.parse('$_baseUrl/rooms/$chatRoomId/read'),
      headers: await _getHeaders(),
    );
    // ⭐️ 이 API는 응답 본문이 없으므로 _handleResponse를 쓰지 않음
  }
  
  // ⭐️ POST /rooms/:roomId/hide ('영구' 삭제)
  Future<void> hideChatRoom(String chatRoomId) async {
    await _client.post(
      Uri.parse('$_baseUrl/rooms/$chatRoomId/hide'),
      headers: await _getHeaders(),
    );
  }

  // ⭐️ POST /users/hide (사용자 숨기기)
  Future<void> hideUser(String userId) async {
     await _client.post(
      Uri.parse('$_baseUrl/users/hide'),
      headers: await _getHeaders(),
      body: jsonEncode({'userId': userId}),
    );
  }

  // --- 응답 처리 헬퍼 ---
  dynamic _handleResponse(http.Response response) {
    final data = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    } else {
      throw Exception(data['message'] ?? 'API 오류 발생');
    }
  }
}