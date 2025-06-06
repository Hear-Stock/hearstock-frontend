// lib/chart_sonification_soloud.dart

import 'dart:ui';
import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:logging/logging.dart';

/// 차트 데이터 모델 (기존과 동일)
class ChartData {
  final DateTime date;
  final double price;

  ChartData({required this.date, required this.price});
}

/// ChartSonificationService (SoLoud 사용 버전)
class ChartSonificationService {
  final List<ChartData> data;
  final SoLoud _soloud = SoLoud.instance; // SoLoud 싱글톤 인스턴스
  final Map<int, SoundHandle> _playingHandles = {}; // 현재 재생 중인 핸들 저장

  late double _minPrice, _maxPrice;

  ChartSonificationService({required this.data}) {
    _initPriceBounds();
  }

  /// 가격의 최솟값/최댓값 계산
  void _initPriceBounds() {
    if (data.isEmpty) {
      _minPrice = 0;
      _maxPrice = 1;
    } else {
      _minPrice = data.map((e) => e.price).reduce((a, b) => a < b ? a : b);
      _maxPrice = data.map((e) => e.price).reduce((a, b) => a > b ? a : b);
    }
  }

  /// SoLoud 엔진 초기화
  Future<void> initialize() async {
    // 이미 초기화되었다면 중복 호출 방지
    if (_soloud.isInitialized) return;

    // 로깅 레벨 설정 (필요에 따라 조정)
    Logger.root.level = Level.INFO;
    Logger.root.onRecord.listen((record) {
      // Flutter 로깅 시스템에 기록
      // (코드 내에선 생략)
    });

    await _soloud.init(); // SoLoud 엔진 시작 :contentReference[oaicite:1]{index=1}
  }

  /// SoLoud 엔진 종료 및 리소스 해제
  void dispose() {
    // 재생 중인 모든 소리 중단
    for (var handle in _playingHandles.values) {
      _soloud.stop(handle);
    }
    _playingHandles.clear();

    // 엔진 해제
    _soloud.deinit();
  }

  /// 주어진 화면 X 위치에 해당하는 데이터를 이용해 3D 위치에서 Beep 재생
  ///
  /// [position]: 터치하거나 커서 위치 등 차트상의 좌표 (Offset(dx, dy))
  /// [chartWidth]: 차트의 가로 길이 (px)
  /// [chartHeight]: 차트의 세로 길이 (px)
  /// [durationMillis]: 소리 길이 (기본 150ms)
  Future<String> playBeepAtPosition(
    Offset position,
    double chartWidth,
    double chartHeight, {
    int durationMillis = 150,
  }) async {
    if (data.isEmpty || !_soloud.isInitialized) return '';

    // 1) 화면 X 위치 → 데이터 인덱스 매핑
    final int index = ((position.dx / (chartWidth / (data.length - 1))).round())
        .clamp(0, data.length - 1);
    final ChartData point = data[index];

    // 2) 가격 → 주파수 매핑 (예: 220Hz ~ 880Hz 구간)
    final double frequency = _mapPriceToFrequency(point.price);

    // 3) Waveform(사인파) 소스 생성
    final AudioSource source = await SoLoudTools.createWaveform(
      wave: WaveForm.sin,
      frequency: frequency,
      volume: 1.0,
    ); // :contentReference[oaicite:2]{index=2}

    // 4) 3D 좌표 계산
    //    - X축: 전체 차트 넓이를 -1.0 ~ 1.0 범위로 정규화
    //    - Y축: 0으로 고정하거나 필요 시 사용
    //    - Z축: 화면 Y 위치를 -1.0 ~ 1.0 범위로 정규화 (아래로 갈수록 + 쪽)
    final double normX = (position.dx / chartWidth) * 2 - 1; // [-1.0, 1.0]
    final double normY = 0.0; // 고정
    final double normZ = (position.dy / chartHeight) * 2 - 1; // [-1.0, 1.0]

    // 5) 소리 재생 (3D)
    final SoundHandle handle = await _soloud.play3d(
      source,
      normX,
      normY,
      normZ,
      // 1.0, // 초기 볼륨 (0.0 ~ 1.0)
    ); // :contentReference[oaicite:3]{index=3}
    // 재생 핸들 보관
    _playingHandles[index] = handle;

    // 6) durationMillis 후에 소리 중단 및 소스 해제
    Future.delayed(Duration(milliseconds: durationMillis), () async {
      _soloud.stop(handle);
      _soloud.disposeSource(source); // 자원 해제
      _playingHandles.remove(index);
    });

    // 7) 재생된 데이터 정보 반환 (예: 날짜, 가격)
    final String dateStr =
        point.date.toLocal().toIso8601String().split('T').first;
    return '$dateStr: \$${point.price.toString()}';
  }

  /// 가격 → 주파수 매핑 유틸리티
  ///
  /// 예를 들어, _minPrice → 220Hz, _maxPrice → 880Hz 로 변환
  double _mapPriceToFrequency(double price) {
    final double normalized = ((price - _minPrice) / (_maxPrice - _minPrice))
        .clamp(0.0, 1.0);
    const double minFreq = 220.0;
    const double maxFreq = 880.0;
    return minFreq + (normalized * (maxFreq - minFreq));
  }
}
