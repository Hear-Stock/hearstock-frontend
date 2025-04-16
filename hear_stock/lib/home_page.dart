import 'package:flutter/material.dart';
import 'speech_recognition.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isMicrophoneActive = false;
  String _recognizedText = ""; // 인식된 텍스트 저장

  final SpeechRecognition _speechRecognition =
      SpeechRecognition(); // SpeechRecognition 객체 생성

  // 음성 인식 시작 함수
  void _startListening() {
    setState(() {
      _isMicrophoneActive = true; // 마이크 활성화
    });

    _speechRecognition.startListening((result) {
      setState(() {
        _recognizedText = result; // 인식된 텍스트 업데이트
      });
    });
  }

  // 음성 인식 중지 함수
  void _stopListening() {
    _speechRecognition.stopListening();
    setState(() {
      _isMicrophoneActive = false; // 마이크 비활성화
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF262626),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(30, 50, 30, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '어떤 주식을 찾으세요?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFFFFFF),
              ),
            ),
            Text(
              '위로 스크롤해서 마이크를 작동시켜 물어보세요!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFFFFFF),
              ),
            ),
            SizedBox(height: 40),
            Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/home-image.png',
                    width: 200.0,
                    height: 200.0,
                  ),
                  SizedBox(height: 10),
                  Text(
                    '삼성전자 주가 알고싶어',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF989898),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    '현대차 주식 보여줘',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFFFFFF),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'SK 하이닉스 차트가 궁금해',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF989898),
                    ),
                  ),
                  // 마이크 버튼
                  ElevatedButton(
                    onPressed:
                        _isMicrophoneActive
                            ? _stopListening
                            : _startListening, // 마이크 시작/중지
                    child: Text(_isMicrophoneActive ? "마이크 중지" : "마이크 시작"),
                  ),
                  SizedBox(height: 20),
                  // 인식된 텍스트 출력
                  Text(
                    '인식된 텍스트: $_recognizedText',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFFFFFF),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
