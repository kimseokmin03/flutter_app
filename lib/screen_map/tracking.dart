import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:kakao_map_sdk/kakao_map_sdk.dart';
import 'package:project/service/location_permission.dart';

mixin MapLocationMixin<T extends StatefulWidget> on State<T> {
  late KakaoMapController mapController;
  Poi? currentLocationPoi;
  StreamSubscription<Position>? positionSubscription;
  LatLng? lastKnownPosition;

  @override
  void dispose() {
    stopLocationTracking();
    super.dispose();
  }

  void stopLocationTracking() {
    positionSubscription?.cancel();
    if (currentLocationPoi != null) {
      mapController.labelLayer.removePoi(currentLocationPoi!);
      currentLocationPoi = null;
    }
    print('현재위치 표시 중지');
  }

  Future<void> updateCurrentLocationPoi(LatLng newLatLng) async {
    lastKnownPosition = newLatLng;

    final poiStyle = PoiStyle(
      icon: KImage.fromAsset("assets/CurrentLocation.png", 30, 30),
    );

    if (currentLocationPoi == null) {
      currentLocationPoi = await mapController.labelLayer.addPoi(
        newLatLng,
        style: poiStyle,
        text: '내 위치',
      );
      moveCameraToCurrentLocation(animate: true);
    } else {
      await currentLocationPoi!.move(newLatLng);
    }
  }

  void moveCameraToCurrentLocation({bool animate = true}) {
    if (lastKnownPosition != null) {
      mapController.moveCamera(
        CameraUpdate.newCenterPosition(lastKnownPosition!),
        animation: animate ? const CameraAnimation(500) : null,
      );
    } else {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('위치 정보 수신 중')));
      }
    }
  }

  Widget buildCurrentLocationButton() {
    return Positioned(
      right: 16,
      bottom: 50,
      child: FloatingActionButton(
        onPressed: moveCameraToCurrentLocation,
        backgroundColor: Colors.white,
        shape: const CircleBorder(),
        child: const Icon(Icons.my_location, color: Colors.blue),
      ),
    );
  }

  Future<void> startLocationDisplayAutomatically() async {
    positionSubscription = LocationPermissionService.getPositionStream().listen(
      (Position position) {
        final newLatLng = LatLng(position.latitude, position.longitude);
        updateCurrentLocationPoi(newLatLng);
      },
      onError: (e) {
        print('위치 스트림 오류: $e');
        stopLocationTracking();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString().replaceFirst("Exception: ", "")),
            ),
          );
        }
      },
    );
  }
}
