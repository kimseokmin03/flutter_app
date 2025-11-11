class User {
  final String id;
  final String displayName;
  final String? preferredSport;
  final List<String> hiddenUsers; // ⭐️ 숨긴 사용자 ID 목록

  User({
    required this.id,
    required this.displayName,
    this.preferredSport,
    this.hiddenUsers = const [],
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      // ⭐️ DB의 id가 integer여도 .toString()으로 안전하게 변환
      id: json['id'].toString(), 
      displayName: json['display_name'],
      preferredSport: json['preferred_sport'],
      hiddenUsers: (json['hidden_users'] as List<dynamic>?)
          ?.map((e) => e.toString()) // ⭐️ 숨긴 ID 목록도 .toString()
          .toList() ?? [],
    );
  }
}