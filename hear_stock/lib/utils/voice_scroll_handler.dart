import 'package:flutter/material.dart';
import '../speech_recognition.dart';

typedef OnSTTResult = void Function(String result);
typedef OnSTTStatusChange = void Function(bool isActive);

class VoiceScrollHandler {
  final SpeechRecognition _speechRecognition = SpeechRecognition();

  void startListening({
    required OnSTTStatusChange onStart,
    required OnSTTResult onResult,
    required OnSTTStatusChange onEnd,
  }) {
    onStart(true);
    _speechRecognition.startListening((result) {
      onResult(result);
    });

    Future.delayed(Duration(seconds: 3), () {
      _speechRecognition.stopListening();
      onEnd(false);
    });
  }
}
