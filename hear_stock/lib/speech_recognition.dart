import 'package:speech_to_text/speech_to_text.dart' as stt;

class SpeechRecognition {
  final stt.SpeechToText _speech = stt.SpeechToText(); // 음성 인식 객체

  // 음성 인식 시작 함수
  Future<void> startListening(Function(String) onResult) async {
    await _speech.stop();

    bool available = await _speech.initialize(
      onStatus: (status) => print('🎙️ STT 상태: $status'),
      onError: (error) => print('❌ STT 오류: $error'),
    ); // 음성 인식 초기화

    if (!available) {
      print("⚠️ 음성 인식이 지원되지 않습니다.");
      return;
    }

    _speech.listen(
      onResult: (result) {
        print('✅ 인식된 단어: ${result.recognizedWords}');
        onResult(result.recognizedWords);
      },
      listenMode: stt.ListenMode.dictation,
    );
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
