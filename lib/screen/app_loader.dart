import 'package:kakao_map_sdk/kakao_map_sdk.dart';
import 'package:flutter/material.dart';
import 'map_main.dart';

class AppLoader extends StatefulWidget {
  const AppLoader({super.key});

  @override
  State<AppLoader> createState() => _AppLoaderState();
}

class _AppLoaderState extends State<AppLoader>{
  bool _isInitialized = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeKakaoSdk();
  }

  Future<void> _initializeKakaoSdk() async {
    try {
      await KakaoMapSdk.instance.initialize("f886a42dac1df90a5697008af44a87fb");
      setState(() {
        _isInitialized = true;
      });
    }
    catch (e){
    setState(() {
    _errorMessage = 'SDK 초기화 실페: ${e.toString()}';
    });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage!=null) {
      return Scaffold(body: Center(child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text(_errorMessage!, textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red)),
      )));
    }
    else if (_isInitialized){
      return const KakaoMapView();
    }
    else {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text("지도를 불러오는 중...")
            ],
          ),
        ),
      );
    }
  }
}