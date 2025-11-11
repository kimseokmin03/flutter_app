import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'map_non_realtime.dart';
import 'map_realtime.dart';

enum MapMode { nonRealtime, realtime }

class KakaoMapView extends StatefulWidget {
  const KakaoMapView({super.key});

  @override
  State<KakaoMapView> createState() => _KakaoMapViewState();
}

class _KakaoMapViewState extends State<KakaoMapView> {
  MapMode _mapMode = MapMode.nonRealtime;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('카카오맵')), //AppBar
      body: Stack(
        children: [
          Positioned.fill(
            child: IndexedStack(
              index: _mapMode == MapMode.nonRealtime ? 0 : 1,
              children: [
                NonRealtimeMapView(key: const ValueKey('NonRealtimeMap')),
                RealtimeMapView(key: const ValueKey('RealtimeMap')),
              ],
            ),
          ),
          SafeArea(
            child: Align(
              alignment: AlignmentGeometry.topCenter,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: CupertinoSlidingSegmentedControl<MapMode>(
                  backgroundColor: Colors.grey.shade200,
                  thumbColor: Colors.white,
                  groupValue: _mapMode,
                  padding: const EdgeInsets.all(4),
                  children: const {
                    MapMode.nonRealtime: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      child: Text('비실시간'),
                    ),
                    MapMode.realtime: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      child: Text('실시간'),
                    ),
                  },
                  onValueChanged: (v) {
                    if (v == null) return;
                    setState(() => _mapMode = v);
                  },
                ),
              ),
            ),
          ),
        ],
      ),
      //bottom
    );
  }
}
