import 'package:flutter/material.dart';
import 'package:kakao_map_sdk/kakao_map_sdk.dart';
import 'package:project/screen/tracking.dart';

class RealtimeMapView extends StatefulWidget {
  const RealtimeMapView({super.key});

  @override
  State<RealtimeMapView> createState() => _RealtimeMapViewState();
}

class _RealtimeMapViewState extends State<RealtimeMapView>
    with MapLocationMixin {
  @override
  void initState() {
    super.initState();
    startLocationDisplayAutomatically();
  }

  //오버레이 초기화
  void onMapReady(KakaoMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: KakaoMap(
            onMapReady: onMapReady,
            option: const KakaoMapOption(
              position: LatLng(36.5, 127.5),
              zoomLevel: 8,
            ),
          ),
        ),
        buildCurrentLocationButton(),
        Positioned(
          left: 0,
          right: 0,
          bottom: 50,
          child: Align(
            alignment: Alignment.center,
            child: FloatingActionButton.extended(
              onPressed: () {},
              label: const Text('실시간 참여', style: TextStyle(color: Colors.blue)),
              icon: const Icon(Icons.circle, color: Colors.blue),
            ),
          ),
        ),
      ],
    );
  }
}
