import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'services/voice_scroll_handler.dart';
import 'widgets/mic_overlay.dart';
import './stores/intent_result_store.dart';

class RsiPage extends StatefulWidget {
  @override
  _RsiPageState createState() => _RsiPageState();
}

class _RsiPageState extends State<RsiPage> {
  final FlutterTts flutterTts = FlutterTts();
  bool _isMicrophoneActive = false;
  String _recognizedText = "";

  final VoiceScrollHandler _voiceScrollHandler = VoiceScrollHandler();
  final ScrollController _scrollController = ScrollController();

  String selectedTitle = '시가총액';
  String selectedValue = '';

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
    _IndicatorItem(title: '시가총액', backgroundColor: Color(0xff262626)),
    _IndicatorItem(title: '배당수익률', backgroundColor: Color(0xff262626)),
    _IndicatorItem(title: 'PBR', backgroundColor: Color(0xff262626)),
    _IndicatorItem(title: 'PER', backgroundColor: Color(0xff262626)),
    _IndicatorItem(title: 'ROE', backgroundColor: Color(0xff262626)),
    _IndicatorItem(title: 'PSR', backgroundColor: Color(0xff262626)),
    _IndicatorItem(title: '외국인 소진율', backgroundColor: Color(0xff262626)),
  ];

  final Map<String, String> metricMap = {
    '시가총액': 'market_cap',
    '배당수익률': 'dividend_yield',
    'PBR': 'pbr',
    'PER': 'per',
    'ROE': 'roe',
    'PSR': 'psr',
    '외국인 소진율': 'foreign_ownership',
  };

  @override
  void initState() {
    super.initState();
    _fetchIndicatorData();

    _scrollController.addListener(() {
      if (_isMicrophoneActive) _stopListeningManually();
    });
  }

  /// API 호출
  Future<void> _fetchIndicatorData() async {
    final baseUrl = dotenv.env['API_BASE_URL'];
    final code = IntentResultStore.code;
    final market = IntentResultStore.market;
    if (code == null || market == null) return;

    final uri = Uri.parse('$baseUrl/api/indicator?code=$code&market=$market');

    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          indicatorValues = {
            '시가총액': _formatValue(data['market_cap'], unit: '원'),
            '배당수익률':
                data['dividend_yield'] != null
                    ? '${data['dividend_yield']}%'
                    : 'N/A',
            'PBR': data['pbr'] != null ? '${data['pbr']}배' : 'N/A',
            'PER': data['per'] != null ? '${data['per']}배' : 'N/A',
            'ROE': data['roe'] != null ? '${data['roe']}%' : 'N/A',
            'PSR': data['psr'] != null ? '${data['psr']}배' : 'N/A',
            if (data.containsKey('foreign_ownership') &&
                data['foreign_ownership'] != null)
              '외국인 소진율': '${data['foreign_ownership']}%',
          };
          selectedValue = indicatorValues[selectedTitle] ?? '';
        });
      }
    } catch (e) {
      print("지표 데이터 로드 실패: $e");
    }
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
      onEnd: (isActive) async {
        setState(() => _isMicrophoneActive = isActive);
        if (_recognizedText.isNotEmpty)
          await _onVoiceCommandRecognized(_recognizedText);
      },
    );
  }

  /// 🔹 음성 명령 처리 + UI 갱신 (종목명 포함 가능)
  Future<void> _onVoiceCommandRecognized(String text) async {
    final lowerText = text.toLowerCase();

    // 1️⃣ 종목명 변경 처리
    final newStockCode =
        IntentResultStore.code; // 이미 IntentResultStore에 새 코드가 들어온 경우 그대로 사용
    if (newStockCode != null) {
      await _fetchIndicatorData(); // 새 종목 데이터 로드 후 indicatorValues 갱신
    }

    // 2️⃣ 지표 처리
    for (var indicator in metricMap.keys) {
      if (lowerText.contains(indicator.toLowerCase())) {
        setState(() {
          selectedTitle = indicator;
          selectedValue = indicatorValues[indicator] ?? '정보가 없습니다.';
        });
        await flutterTts.speak(
          "${IntentResultStore.name}의 $indicator 값은 $selectedValue 입니다.",
        );
        return;
      }
    }

    // 3️⃣ "투자지표 보여줘" 처리
    if (lowerText.contains('투자지표 보여줘') || lowerText.contains('투자지표 보여 줘')) {
      setState(() {
        selectedTitle = '시가총액';
        selectedValue = indicatorValues[selectedTitle] ?? '';
      });
      await flutterTts.speak("");
      return;
    }

    await flutterTts.speak("해당 지표를 찾을 수 없습니다.");
  }

  String _formatValue(dynamic value, {String unit = ''}) {
    if (value == null) return 'N/A';
    double numValue = double.tryParse(value.toString()) ?? 0;
    if (numValue >= 1e12)
      return '${(numValue / 1e12).toStringAsFixed(1)}조$unit';
    if (numValue >= 1e8) return '${(numValue / 1e8).toStringAsFixed(1)}억$unit';
    if (numValue >= 1e4) return '${(numValue / 1e4).toStringAsFixed(1)}만$unit';
    return '${numValue.toStringAsFixed(0)}$unit';
  }

  Future<String> fetchSummaryFromApi(String title) async {
    final baseUrl = dotenv.env['API_BASE_URL'];
    final code = IntentResultStore.code;
    final market = IntentResultStore.market;
    final metricKey = metricMap[title] ?? title.toLowerCase();
    final uri = Uri.parse(
      '$baseUrl/api/indicator/explain?code=$code&market=$market&metric=$metricKey',
    );

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
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: _onRefresh,
            child: ListView(
              controller: _scrollController,
              physics: AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(30, 60, 30, 30),
              children: [
                Column(
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
                    GridView(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
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
                                final isSelected = item.title == selectedTitle;
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
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          side: BorderSide(
                                            color: Colors.white,
                                            width: 3.5,
                                          ),
                                        ),
                                      ),
                                      onPressed:
                                          () => _onIndicatorPressed(item.title),
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

class _IndicatorItem {
  final String title;
  final Color backgroundColor;

  _IndicatorItem({required this.title, required this.backgroundColor});
}
