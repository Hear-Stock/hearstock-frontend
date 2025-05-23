import 'package:flutter/material.dart';
import 'dart:async';

import '../services/api_service.dart';
import '../speech_recognition.dart';

typedef OnSTTResult = void Function(String result);
typedef OnSTTStatusChange = void Function(bool isActive);

class VoiceScrollHandler {
  final SpeechRecognition _speechRecognition = SpeechRecognition();
  Timer? _silenceTimer;

  void startListening({
    required OnSTTStatusChange onStart,
    required OnSTTResult onResult,
    required OnSTTStatusChange onEnd,
  }) async {
    onStart(true);
    await _speechRecognition.startListening((result) {
      onResult(result);

      // 음성 인식 결과를 API로 전송
      ApiService.sendRecognizedText(result);
      // 음성이 들어왔으니 타이머 초기화 후 새로 시작
      _silenceTimer?.cancel();
      _silenceTimer = Timer(Duration(seconds: 3), () {
        _speechRecognition.stopListening();
        onEnd(false);
      });
    });
  }

  void stopImmediately(OnSTTStatusChange onEnd) {
    _silenceTimer?.cancel();
    _speechRecognition.stopListening();
    onEnd(false);
  }
}
