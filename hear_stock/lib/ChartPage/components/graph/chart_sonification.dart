// lib/chart_sonification.dart

import 'dart:ui';
import 'package:flutter_midi_pro/flutter_midi_pro.dart';

/// 차트 데이터 모델
class ChartData {
  final DateTime date;
  final double price;

  ChartData({required this.date, required this.price});
}

/// 차트 음향화 서비스
/// - 차트 데이터를 받아 MIDI 사운드로 재생하는 로직을 라이브러리 형태로 분리
class ChartSonificationService {
  final List<ChartData> data;
  final MidiPro _midiPro;
  final int minKey;
  final int maxKey;
  int? _soundfontId;

  late double _minPrice, _maxPrice;

  ChartSonificationService({
    required this.data,
    MidiPro? midiPro,
    this.minKey = 40,
    this.maxKey = 80,
  }) : _midiPro = midiPro ?? MidiPro() {
    _initPriceBounds();
  }

  void _initPriceBounds() {
    if (data.isEmpty) {
      _minPrice = 0;
      _maxPrice = 1;
    } else {
      _minPrice = data.map((e) => e.price).reduce((a, b) => a < b ? a : b);
      _maxPrice = data.map((e) => e.price).reduce((a, b) => a > b ? a : b);
    }
  }

  /// SoundFont 파일 로딩
  Future<void> loadSoundFont(
    String path, {
    int bank = 0,
    int program = 0,
  }) async {
    _soundfontId = await _midiPro.loadSoundfont(
      path: path,
      bank: bank,
      program: program,
    );
    if (_soundfontId != null) {
      // 채널 0,1에 동일 악기 설정
      await _midiPro.selectInstrument(
        sfId: _soundfontId!,
        channel: 0,
        bank: bank,
        program: program,
      );
      await _midiPro.selectInstrument(
        sfId: _soundfontId!,
        channel: 1,
        bank: bank,
        program: program,
      );
    }
  }

  /// 주어진 화면 X 위치에 해당하는 데이터를 MIDI로 재생하고, 날짜와 가격 문자열 반환
  String playNoteAtPosition(
    Offset position,
    double chartWidth, {
    int channelLeft = 0,
    int channelRight = 1,
    int durationMillis = 150,
  }) {
    if (data.isEmpty || _soundfontId == null) return '';

    final int index = ((position.dx / (chartWidth / (data.length - 1))).round())
        .clamp(0, data.length - 1);
    final ChartData point = data[index];

    final int key = _mapPriceToKey(point.price);
    final double ratio = (position.dx / chartWidth).clamp(0.0, 1.0);

    final int velL = (ratio * 127).round();
    final int velR = ((1 - ratio) * 127).round();

    _midiPro.playNote(
      sfId: _soundfontId!,
      channel: channelLeft,
      key: key,
      velocity: velL,
    );
    _midiPro.playNote(
      sfId: _soundfontId!,
      channel: channelRight,
      key: key,
      velocity: velR,
    );

    Future.delayed(Duration(milliseconds: durationMillis), () {
      _midiPro.stopNote(sfId: _soundfontId!, channel: channelLeft, key: key);
      _midiPro.stopNote(sfId: _soundfontId!, channel: channelRight, key: key);
    });

    final String dateStr =
        point.date.toLocal().toIso8601String().split('T').first;
    return '$dateStr: \$${point.price.toString()}';
  }

  int _mapPriceToKey(double price) {
    final double normalized = ((price - _minPrice) / (_maxPrice - _minPrice))
        .clamp(0.0, 1.0);
    return (minKey + (normalized * (maxKey - minKey))).round();
  }
}
