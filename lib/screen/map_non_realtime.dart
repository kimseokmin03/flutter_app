import 'dart:async';
import 'package:flutter/material.dart';
import 'package:kakao_map_sdk/kakao_map_sdk.dart';
import 'package:project/facility/facility_init.dart';
import 'package:project/facility/facility_data.dart';
import 'package:project/widgets/facility_info.dart';
import 'package:project/screen/tracking.dart';

class NonRealtimeMapView extends StatefulWidget {
  const NonRealtimeMapView({super.key});

  @override
  State<NonRealtimeMapView> createState() => _NonRealtimeMapViewState();
}

class _NonRealtimeMapViewState extends State<NonRealtimeMapView>
    with MapLocationMixin {
  Facility? _selectedFacility;
  final FacilityService facilityService = FacilityService();
  List<Facility> allFacilities = [];
  List<Poi> visiblePoi = [];
  final GlobalKey _mapKey = GlobalKey();
  bool isupdatingmarkers = false;
  Timer? debounce;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    debounce?.cancel();
    super.dispose();
  }

  //오버레이 초기화
  void onMapReady(KakaoMapController controller) async {
    mapController = controller;
    await loadFacilitiesIntoMemory();

    startLocationDisplayAutomatically();
  }

  Future<void> loadFacilitiesIntoMemory() async {
    allFacilities = await facilityService.loadFacilitiesFromCsv();
    print('--- 데이터 로드 완료: ${allFacilities.length}개 ---');
  }

  Future<void> updateVisibleMarkers() async {
    print('--- updateVisibleMarkers 호출됨 ---');
    if (isupdatingmarkers) {
      print('이미 작업 중이라 무시');
      return;
    }

    await Future.delayed(const Duration(milliseconds: 50));

    isupdatingmarkers = true;
    try {
      final RenderBox? renderBox =
          _mapKey.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox == null) {
        print('--- RenderBox가 null이라 종료됨 ---');
        isupdatingmarkers = false;
        return;
      }

      final logicalSize = renderBox.size;

      if (!mounted) {
        isupdatingmarkers = false;
        return;
      }

      final dpr = View.of(context).devicePixelRatio;

      print('[dpr] $dpr, [논리 크기] ${logicalSize.width}, ${logicalSize.height}');
      final int physicalWidth = (logicalSize.width * dpr).toInt();
      final int physicalHeight = (logicalSize.height * dpr).toInt();

      if (physicalWidth == 0 || physicalHeight == 0) {
        print('화면 크기 계산 실패');
        isupdatingmarkers = false;
        return;
      }

      final LatLng? topleft = await mapController.fromScreenPoint(0, 0);
      final LatLng? topright = await mapController.fromScreenPoint(
        physicalWidth,
        0,
      );
      final LatLng? bottomleft = await mapController.fromScreenPoint(
        0,
        physicalHeight,
      );
      final LatLng? bottomright = await mapController.fromScreenPoint(
        physicalWidth,
        physicalHeight,
      );

      if (topleft == null ||
          topright == null ||
          bottomright == null ||
          bottomleft == null) {
        print('지도 좌표 변환에 실패했습니다.');
        isupdatingmarkers = false;
        return;
      }

      final List<double> latitudes = [
        topleft.latitude,
        topright.latitude,
        bottomleft.latitude,
        bottomright.latitude,
      ];
      final List<double> longitudes = [
        topleft.longitude,
        topright.longitude,
        bottomleft.longitude,
        bottomright.longitude,
      ];

      final double minLat = latitudes.reduce((a, b) => a < b ? a : b);
      final double maxLat = latitudes.reduce((a, b) => a > b ? a : b);
      final double minLng = longitudes.reduce((a, b) => a < b ? a : b);
      final double maxLng = longitudes.reduce((a, b) => a > b ? a : b);

      print('--- [지도 경계] Lat: $minLat ~ $maxLat');
      print('--- [지도 경계] Lng: $minLng ~ $maxLng');

      if (allFacilities.isNotEmpty) {
        print(
          '--- [데이터 위치(첫번째)] Lat: ${allFacilities[0].location.latitude}, Lng: ${allFacilities[0].location.longitude} ---',
        );
      } else {
        print('--- [오류] allFacilities 리스트가 비어있습니다. ---');
      }

      if (visiblePoi.isNotEmpty) {
        for (final poi in visiblePoi) {
          await mapController.labelLayer.removePoi(poi);
        }
        visiblePoi.clear();
      }

      List<Facility> facilitiesToAdd = [];

      for (final facility in allFacilities) {
        if (facility.location.latitude >= minLat &&
            facility.location.latitude <= maxLat &&
            facility.location.longitude >= minLng &&
            facility.location.longitude <= maxLng) {
          facilitiesToAdd.add(facility);
        }
      }
      print('총 ${facilitiesToAdd.length}개의 마커 추가');

      for (final facility in facilitiesToAdd) {
        try {
          String icon = facility.iconpath;

          if (icon.isEmpty) {
            print('이미지 없어서 기본 마커로 대체');
            icon = "assets/marker.png";
          }

          final poiStyle = PoiStyle(icon: KImage.fromAsset(icon, 30, 30));

          final poi = await mapController.labelLayer.addPoi(
            facility.location,
            style: poiStyle,
          );

          poi.onClick = () {
            _showFacilityDetailsSheet(facility);
          };
          visiblePoi.add(poi);
        } catch (e) {
          print('마커 추가 실패');
          print('실패한 경로 : ${facility.iconpath}');
          print('오류 발생: $e');
        }
      }
    } catch (e) {
      print('updateVisibleMarkers에서 오류 발생: $e');
    } finally {
      isupdatingmarkers = false;
    }
  }

  Future<void> loadAndDisplayMarkers() async {
    final List<Facility> facilities = await facilityService
        .loadFacilitiesFromCsv();

    for (final facility in facilities) {
      final poistyle = PoiStyle(
        icon: KImage.fromAsset(facility.iconpath, 30, 30),
      );

      final poi = await mapController.labelLayer.addPoi(
        facility.location,
        style: poistyle,
      );

      poi.onClick = () {
        setState(() {
          _showFacilityDetailsSheet(facility);
        });
      };
    }
  }

  void _showFacilityDetailsSheet(Facility facility) {
    setState(() {
      _selectedFacility = facility;
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      barrierColor: Colors.transparent,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return FacilityInfoWindow(facility: facility);
      },
    ).whenComplete(() {
      setState(() {
        _selectedFacility = null;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: KakaoMap(
            key: _mapKey,
            onMapReady: onMapReady,
            onMapClick: (point, latlng) {
              if (_selectedFacility != null) {
                Navigator.of(context).pop();

                setState(() {
                  _selectedFacility = null;
                });
              }
            },
            onCameraMoveEnd: (message, _) {
              if (debounce?.isActive ?? false) {
                debounce!.cancel();
              }
              debounce = Timer(const Duration(milliseconds: 300), () {
                print('--- onCameraMoveEnd 발생 ---');
                updateVisibleMarkers();
              });
            },

            option: const KakaoMapOption(
              position: LatLng(36.5, 127.5),
              zoomLevel: 20,
            ),
          ),
        ),
        buildCurrentLocationButton(),
      ],
    );
  }
}
