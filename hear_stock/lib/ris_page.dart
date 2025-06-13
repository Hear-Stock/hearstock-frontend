import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'services/voice_scroll_handler.dart';
import 'widgets/mic_overlay.dart';

class RsiPage extends StatefulWidget {
  @override
  _RsiPageState createState() => _RsiPageState();
}

class _RsiPageState extends State<RsiPage> {
  final FlutterTts flutterTts = FlutterTts();

  String selectedTitle = '시가총액';
  String selectedValue = '';

  // 음성 인식 관련 변수 추가
  final VoiceScrollHandler _voiceScrollHandler = VoiceScrollHandler();
  bool _isMicrophoneActive = false;
  String _recognizedText = "";

  Future<void> _onRefresh() async {
    _voiceScrollHandler.startListening(
      context,
      onStart: (isActive) => setState(() => _isMicrophoneActive = isActive),
      onResult: (text) => setState(() => _recognizedText = text),
      onEnd: (isActive) => setState(() => _isMicrophoneActive = isActive),
    );
  }

  Map<String, String> indicatorValues = {
    '시가총액': '',
    '배당수익률': '',
    'PBR': '',
    'PER': '',
    'ROE': '',
    'PSR': '',
    '외국인 소진율': '',
  };

  final List<_IndicatorItem> items = [
    _IndicatorItem(title: '시가총액', backgroundColor: Color(0xFF4A90E2)),
    _IndicatorItem(title: '배당수익률', backgroundColor: Color(0xFFFF6B6B)),
    _IndicatorItem(title: 'PBR', backgroundColor: Color(0xFF2ECC71)),
    _IndicatorItem(title: 'PER', backgroundColor: Color(0xFFFFC107)),
    _IndicatorItem(title: 'ROE', backgroundColor: Color(0xFFAF7AC5)),
    _IndicatorItem(title: 'PSR', backgroundColor: Color(0xFFF3B6B6)),
    _IndicatorItem(title: '외국인 소진율', backgroundColor: Color(0xFF80DEEA)),
  ];

  @override
  void initState() {
    super.initState();
    fetchIndicatorValues(code: '005930', market: 'KR'); // 예: 삼성전자
  }

  Future<void> fetchIndicatorValues({
    required String code,
    required String market,
  }) async {
    final baseUrl = dotenv.env['API_BASE_URL'];
    final uri = Uri.parse('$baseUrl/api/indicator/?code=$code&market=$market');

    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          indicatorValues = {
            '시가총액': _formatValue(data['market_cap'], unit: '원'),
            '배당수익률': '${data['dividend_yield']}%',
            'PBR': '${data['pbr']}배',
            'PER': '${data['per']}배',
            'ROE': '${data['roe']}%',
            'PSR': '${data['psr']}배',
            if (data.containsKey('foreign_ownership'))
              '외국인 소진율': '${data['foreign_ownership']}%',
          };
          selectedValue = indicatorValues[selectedTitle] ?? '';
        });
      } else {
        setState(() {
          indicatorValues.updateAll((key, value) => '불러오기 실패');
        });
      }
    } catch (e) {
      setState(() {
        indicatorValues.updateAll((key, value) => '에러 발생');
      });
    }
  }

  String _formatValue(dynamic value, {String unit = ''}) {
    if (value == null) return 'N/A';
    double numValue = double.tryParse(value.toString()) ?? 0;
    if (numValue >= 1e12) {
      return '${(numValue / 1e12).toStringAsFixed(1)}조$unit';
    } else if (numValue >= 1e8) {
      return '${(numValue / 1e8).toStringAsFixed(1)}억$unit';
    } else if (numValue >= 1e4) {
      return '${(numValue / 1e4).toStringAsFixed(1)}만$unit';
    } else {
      return '${numValue.toStringAsFixed(0)}$unit';
    }
  }

  Future<String> fetchSummaryFromApi(String title) async {
    final baseUrl = dotenv.env['API_BASE_URL']!;
    final uri = Uri.parse('${baseUrl}api/summary/?title=$title');

    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['summary'] ?? '$title에 대한 요약 정보가 없습니다.';
      } else {
        return '$title 정보를 불러오는 데 실패했습니다.';
      }
    } catch (e) {
      return '요약 정보를 가져오는 중 오류가 발생했습니다.';
    }
  }

  Future<void> _onIndicatorPressed(String title) async {
    setState(() {
      selectedTitle = title;
      selectedValue = indicatorValues[title] ?? '';
    });
    await flutterTts.speak('$title, ${indicatorValues[title]}');
  }

  Future<void> _onIndicatorLongPressed(String title) async {
    String summary = await fetchSummaryFromApi(title);
    await flutterTts.speak(summary);
  }

  // 음성 인식 중단
  void _stopListeningManually() {
    setState(() {
      _isMicrophoneActive = false;
    });
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textScale = MediaQuery.of(context).textScaleFactor;

    return Scaffold(
      backgroundColor: Color(0xff262626),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(30, 60, 30, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Semantics(
                    header: true,
                    child: Text(
                      selectedTitle,
                      style: TextStyle(
                        fontSize: 22 * textScale,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Text(
                    selectedValue,
                    style: TextStyle(
                      fontSize: 34 * textScale,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 30),
                  Expanded(
                    child: FocusTraversalGroup(
                      policy: ReadingOrderTraversalPolicy(),
                      child: GridView(
                        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 200,
                          crossAxisSpacing: 20,
                          mainAxisSpacing: 20,
                          childAspectRatio: 1.2,
                        ),
                        children:
                            items
                                .where(
                                  (item) =>
                                      indicatorValues.containsKey(item.title),
                                )
                                .map((item) {
                                  final isSelected =
                                      item.title == selectedTitle;

                                  return Semantics(
                                    label:
                                        '${item.title} 버튼${isSelected ? ', 선택됨' : ''}',
                                    button: true,
                                    selected: isSelected,
                                    child: Tooltip(
                                      message: '${item.title} 선택',
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: item.backgroundColor,
                                          foregroundColor: Color(0xff262626),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                            side: BorderSide(
                                              color:
                                                  isSelected
                                                      ? Colors.white
                                                      : Colors.transparent,
                                              width: 3,
                                            ),
                                          ),
                                        ),
                                        onPressed:
                                            () =>
                                                _onIndicatorPressed(item.title),
                                        onLongPress:
                                            () => _onIndicatorLongPressed(
                                              item.title,
                                            ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              item.title,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 22 * textScale,
                                                fontWeight: FontWeight.w900,
                                              ),
                                            ),
                                            if (isSelected)
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  top: 8.0,
                                                ),
                                                child: Icon(
                                                  Icons.check_circle,
                                                  size: 20 * textScale,
                                                  color: Colors.white,
                                                  semanticLabel: '선택됨',
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                })
                                .toList(),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Center(
                    child: Text(
                      '아래로 스크롤해서 마이크를 작동시키세요.',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 15 * textScale,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
            // 마이크 활성 시 UI 오버레이
            if (_isMicrophoneActive)
              MicOverlay(
                recognizedText: _recognizedText,
                onStop: _stopListeningManually,
              ),
          ],
        ),
      ),
    );
  }
}

class _IndicatorItem {
  final String title;
  final Color backgroundColor;

  _IndicatorItem({required this.title, required this.backgroundColor});
}
