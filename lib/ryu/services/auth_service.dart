import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';
import '../models/user.dart'; // ⭐️ User 모델

class AuthService {
  final ApiService _apiService;
  User? _currentUser; // ⭐️ 메모리 캐시

  AuthService(this._apiService);

  // ⭐️ 현재 로그인한 사용자 정보 (캐시 또는 API)
  Future<User?> getCurrentUser() async {
    if (_currentUser != null) return _currentUser;
    
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString('token') == null) {
      return null;
    }
    
    try {
      final json = await _apiService.getMyProfile();
      _currentUser = User.fromJson(json);
      return _currentUser;
    } catch (e) {
      return null;
    }
  }
  
  // ⭐️ 로그인 상태 확인 (토큰 유무)
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') != null;
  }

  // ⭐️ 로그인 (API 호출)
  Future<User> signInAnonymously(String displayName) async {
    try {
      final json = await _apiService.login(displayName);
      final User user = User.fromJson(json['user']);
      final String token = json['token'];

      // ⭐️ 토큰과 사용자 정보 저장
      await _apiService.setToken(token);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userId', user.id); // ⭐️ id가 integer여도 .toString()됨
      await prefs.setString('displayName', user.displayName);
      
      _currentUser = user; // ⭐️ 캐시 저장
      return user;

    } catch (e) {
      rethrow;
    }
  }

  // ⭐️ 프로필 업데이트 (API 호출)
  Future<void> updateProfile(String displayName, String preferredSport) async {
    try {
      final json = await _apiService.updateProfile(displayName, preferredSport);
      _currentUser = User.fromJson(json); // ⭐️ 캐시 업데이트
      // SharedPreferences의 displayName도 업데이트
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('displayName', _currentUser!.displayName);
    } catch (e) {
      rethrow;
    }
  }

  // ⭐️ 로그아웃
  Future<void> signOut() async {
    _currentUser = null;
    await _apiService.clearToken();
  }
}