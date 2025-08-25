import 'package:flutter/material.dart';

import 'services/voice_scroll_handler.dart';
import 'widgets/mic_overlay.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isMicrophoneActive = false;
  String _recognizedText = "";

  final VoiceScrollHandler _voiceScrollHandler = VoiceScrollHandler();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_isMicrophoneActive) {
        _stopListeningManually();
      }
    });
  }

  void _stopListeningManually() {
    _voiceScrollHandler.stopImmediately(
      context,
      (isActive) => setState(() => _isMicrophoneActive = isActive),
    );
  }

  Future<void> _onRefresh() async {
    _voiceScrollHandler.startListening(
      context,
      onStart: (isActive) => setState(() => _isMicrophoneActive = isActive),
      onResult: (text) => setState(() => _recognizedText = text),
      onEnd: (isActive) => setState(() => _isMicrophoneActive = isActive),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: _onRefresh,
            child: ListView(
              controller: _scrollController,
              physics: AlwaysScrollableScrollPhysics(),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(30, 50, 30, 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '어떤 주식을 찾으세요?',
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '아래로 스크롤해서\n마이크를 작동시켜 물어보세요!',
                        style: Theme.of(
                          context,
                        ).textTheme.headlineSmall?.copyWith(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 40),
                      Center(
                        child: Column(
                          children: [
                            Text(
                              '아래로 스크롤해서 마이크를 작동시켜 물어보세요',
                              style: Theme.of(
                                context,
                              ).textTheme.headlineSmall?.copyWith(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Image.asset(
                              'assets/images/home-image.png',
                              width: 200,
                              height: 200,
                            ),
                            SizedBox(height: 10),
                            Text(
                              '삼성전자 주가 알고싶어',
                              style: Theme.of(
                                context,
                              ).textTheme.headlineSmall?.copyWith(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onBackground.withOpacity(0.65),
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              '현대차 주식 보여줘',
                              style: Theme.of(
                                context,
                              ).textTheme.headlineSmall?.copyWith(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'SK 하이닉스 차트가 궁금해',
                              style: Theme.of(
                                context,
                              ).textTheme.headlineSmall?.copyWith(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onBackground.withOpacity(0.65),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          if (_isMicrophoneActive)
            MicOverlay(
              recognizedText: _recognizedText,
              onStop: _stopListeningManually,
            ),
        ],
      ),
    );
  }
}
