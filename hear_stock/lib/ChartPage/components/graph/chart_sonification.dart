// // lib/chart_sonification.dart

// import 'dart:ui';
// import 'package:flutter_soloud/flutter_soloud.dart';
// import '../../../services/stock_chart_service.dart';

// /// 차트 음향화 서비스
// /// - 차트 데이터를 받아 MIDI 사운드로 재생하는 로직을 라이브러리 형태로 분리
// class ChartSonificationService {
//   final List<ChartData> data;
//   final SoLoud soloud = SoLoud.instance;
//   late AudioSource _ping;

//   ChartSonificationService({required this.data});

//   Future<void> init() async {
//     await soloud.init();
//     _ping = await soloud.loadAsset('assets/audio/sample3.wav');

//     // 3D 리스너 위치 초기화
//     soloud.set3dListenerPosition(0, 0, 0);
//     soloud.set3dListenerAt(0, 0, -1);
//   }

//   void dispose() {
//     soloud.deinit();
//   }

//   // 실제 소리 재생
//   Future<String> play3DSoundAt(Offset localPos, Size chartSize) async {
//     final idx = ((localPos.dx / chartSize.width) * (data.length - 1))
//         .round()
//         .clamp(0, data.length - 1);
//     final point = data[idx];

//     // 2D 위치를 3D 공간 좌표로 변환
//     double x = (localPos.dx / chartSize.width) * 20 - 10;
//     double y = (1 - localPos.dy / chartSize.height) * 10 - 5;
//     double z = 0;

//     // 3D 위치에서 소리 재생
//     final handle = await soloud.play3d(_ping, x, y, z);

//     return '${point.date.toIso8601String().split("T")[0]}: ${point.price}';
//   }
// }
