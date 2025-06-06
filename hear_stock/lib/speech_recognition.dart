import 'package:speech_to_text/speech_to_text.dart' as stt;

class SpeechRecognition {
  final stt.SpeechToText _speech = stt.SpeechToText(); // 음성 인식 객체

  // 음성 인식 시작 함수
  Future<void> startListening(Function(String) onResult) async {
    bool available = await _speech.initialize(); // 음성 인식 초기화

    if (available) {
      _speech.listen(
        onResult: (result) {
          onResult(result.recognizedWords); // 인식된 텍스트를 콜백으로 전달
        },
      );
    } else {
      print("음성 인식이 지원되지 않습니다.");
    }
  }

  // 음성 인식 중지 함수
  void stopListening() {
    if (_speech.isListening) {
      _speech.stop();
    } else {
      print('⚠️ 이미 음성 인식이 중지된 상태입니다.');
    }
  }
}
