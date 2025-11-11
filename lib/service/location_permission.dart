import 'dart:async';
import 'package:geolocator/geolocator.dart';

class LocationPermissionService {
  static Future<LocationPermission?> requestAndCheckPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      return permission;
    }
    return permission;
  }

  static bool isPermissionGranted(LocationPermission? permission) {
    return (permission != null &&
        permission != LocationPermission.denied &&
        permission != LocationPermission.deniedForever);
  }

  static Stream<Position> getPositionStream() async* {
    LocationPermission? permission = await requestAndCheckPermission();
    if (!isPermissionGranted(permission)) {
      yield* Stream.error(Exception('위치 권한이 거부되었습니다.'));
      return;
    }

    yield* Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 1,
      ),
    );
  }
}
