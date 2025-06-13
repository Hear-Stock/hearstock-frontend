import 'package:flutter/material.dart';
import 'dart:async';

import '../services/api_service.dart';
import '../speech_recognition.dart';

typedef OnSTTResult = void Function(String result);
typedef OnSTTStatusChange = void Function(bool isActive);

class VoiceScrollHandler {
  final SpeechRecognition _speechRecognition = SpeechRecognition();
  Timer? _silenceTimer;
  String _finalText = '';

  void startListening(
    BuildContext context, {
    required OnSTTStatusChange onStart,
    required OnSTTResult onResult,
    required OnSTTStatusChange onEnd,
  }) async {
    onStart(true);
    _finalText = ''; // 초기화

    await _speechRecognition.startListening((result) {
      print('onResult 콜백 실행됨: $result');

      _finalText = result; // 최종 텍스트 저장
      onResult(result); // 화면 표시용 setState
      _silenceTimer?.cancel();
      _silenceTimer = Timer(Duration(seconds: 3), () {
        _speechRecognition.stopListening();
        onEnd(false);
        print('최종 텍스트 (API 전송 직전): $_finalText');
        print('마이크 비활성화됨, API 전송 시작');

        // API 호출
        if (_finalText.isNotEmpty) {
          ApiService.sendRecognizedText(_finalText, context);
        }
      });
    });
  }

  void stopImmediately(BuildContext context, OnSTTStatusChange onEnd) {
    _silenceTimer?.cancel();
    _speechRecognition.stopListening();
    onEnd(false);

    if (_finalText.isNotEmpty) {
      print('버튼으로 중단 - 텍스트: $_finalText');
      ApiService.sendRecognizedText(_finalText, context);
    }
  }
}
