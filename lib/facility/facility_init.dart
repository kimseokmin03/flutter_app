import 'package:kakao_map_sdk/kakao_map_sdk.dart';

class Facility {
  final String name;
  final String type;
  final LatLng location;
  final String iconpath;

  Facility({
    required this.name,
    required this.type,
    required this.location,
    required this.iconpath,
  });

  factory Facility.fromCsvDate({
    required String name,
    required String type,
    required double lat,
    required double lng,
  }) {
    final String iconpath = getIconForFaciliryType(type);

    return Facility(
      name: name,
      type: type,
      location: LatLng(lat, lng),
      iconpath: iconpath,
    );
  }

  static String getIconForFaciliryType(String facilitytype) {
    switch (facilitytype) {
      // 1. 헬스
      case '체력단련장':
      case '생활체육관':
      case '기타체육시설':
      case '줄넘기':
      case '가상체험 체육시설':
        return 'assets/icons/fitness-Photoroom.png';

      // 2. 무술
      case '태권도':
      case '유도':
      case '우슈':
      case '합기도':
      case '투기체육관':
        return 'assets/icons/takwondo-Photoroom.png';

      // 3. 권투
      case '권투':
      case '레슬링':
        return 'assets/icons/boxing-Photoroom.png';

      // 4. 검도
      case '검도':
        return 'assets/icons/knife-Photoroom.png';

      // 5. 씨름
      case '씨름장':
        return 'assets/icons/CCirum-Photoroom.png';

      // 6. 축구
      case '축구':
      case '풋살장':
        return 'assets/icons/soccer-Photoroom.png';

      // 7. 농구
      case '농구':
        return 'assets/icons/basketball-Photoroom.png';

      // 8. 야구
      case '야구':
        return 'assets/icons/baseball-Photoroom.png';

      // 9. 하키
      case '하키장':
        return 'assets/icons/hockey-Photoroom.png';

      // 10. 육상
      case '육상경기장':
      case '간이운동장':
        return 'assets/icons/running-Photoroom.png';

      // 11. 배드민턴
      case '배드민턴':
        return 'assets/icons/badminton-Photoroom.png';

      // 12. 테니스
      case '테니스장':
        return 'assets/icons/tennis-Photoroom.png';

      // 13. 수영
      case '수영':
      case '수영장':
        return 'assets/icons/swimming-Photoroom.png';

      // 14. 요트
      case '요트장':
        return 'assets/icons/yort-Photoroom.png';

      // 15. 카누
      case '카누장':
      case '조정카누장':
        return 'assets/icons/kanu-Photoroom.png';

      // 16. 골프
      case '골프':
      case '스크린':
      case '골프연습장':
      case '골프장':
      case '파크 골프장':
        return 'assets/icons/golf-Photoroom.png';

      // 17. 썰매
      case '썰매장':
        return 'assets/icons/snowman-Photoroom.png';

      // 18. 빙상
      case '빙상장':
      case '빙상':
        return 'assets/icons/skate-Photoroom.png';

      // 19. 스키
      case '스키장':
      case '스키점프':
      case '크로스컨트리':
      case '바이애슬론':
        return 'assets/icons/ski-Photoroom.png';

      // 20. 당구
      case '당구장':
        return 'assets/icons/poketball-Photoroom.png';

      // 21. 활
      case '국궁장':
      case '양궁장':
        return 'assets/icons/bowandarrow-Photoroom.png';

      // 22. 사격
      case '사격장':
        return 'assets/icons/gun-Photoroom.png';

      // 23. 승마
      case '승마장':
        return 'assets/icons/horse-Photoroom.png';

      // 24. 롤러스케이트
      case '롤러스케이트':
      case '롤러스케이트장':
        return 'assets/icons/roller-Photoroom.png';

      // 25. 게이트볼
      case '전천후게이트볼장':
        return 'assets/icons/gateball-Photoroom.png';

      // 26. 사이클
      case '사이클경기장':
        return 'assets/icons/bycycle-Photoroom.png';

      // 27. 자동차
      case '자동차경주장':
        return 'assets/icons/handle-Photoroom.png';

      // 28. 암벽 등반
      case '인공암벽장':
        return 'assets/icons/rockclimbing-Photoroom.png';

      // 29. 댄스
      case '무도장':
      case '무도학원':
        return 'assets/icons/dance-Photoroom.png';

      // 28. 기타 (기본 아이콘)
      case '기타':
      case '구기체육관':
      case '기타시설':
      case '실내':
      case '복합':
      case '실외':
      case '종합체육시설':
      default:
        return 'assets/icons/gym-Photoroom.png';
    }
  }
}
