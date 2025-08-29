// pages/ris/ris_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../services/voice_scroll_handler.dart';
import '../../widgets/mic_overlay.dart';
import '../../stores/intent_result_store.dart';

// ▶ 새로 만든 컴포넌트 임포트
import 'components/header_card.dart';
import 'components/indicator_list.dart';
import 'indicator_detail_page.dart';

class RsiPage extends StatefulWidget {
  @override
  _RsiPageState createState() => _RsiPageState();
}

class _RsiPageState extends State<RsiPage> {
  // ----- 음성/TTS/스크롤 -----
  final FlutterTts flutterTts = FlutterTts();
  final VoiceScrollHandler _voiceScrollHandler = VoiceScrollHandler();
  final ScrollController _scrollController = ScrollController();

  bool _isMicrophoneActive = false;
  String _recognizedText = "";

  // ----- 선택/지표 상태 -----
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

  // (제목만 활용, 색상은 테마 사용)
  final List<_IndicatorItem> items = const [
    _IndicatorItem(title: '시가총액', backgroundColor: Color(0xff262626)),
    _IndicatorItem(title: '배당수익률', backgroundColor: Color(0xff262626)),
    _IndicatorItem(title: 'PBR', backgroundColor: Color(0xff262626)),
    _IndicatorItem(title: 'PER', backgroundColor: Color(0xff262626)),
    _IndicatorItem(title: 'ROE', backgroundColor: Color(0xff262626)),
    _IndicatorItem(title: 'PSR', backgroundColor: Color(0xff262626)),
    _IndicatorItem(title: '외국인 소진율', backgroundColor: Color(0xff262626)),
  ];

  final Map<String, String> metricMap = const {
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

  @override
  void dispose() {
    flutterTts.stop();
    _scrollController.dispose();
    super.dispose();
  }

  // ----- 데이터 로드 -----
  Future<void> _fetchIndicatorData() async {
    final baseUrl = dotenv.env['API_BASE_URL'];
    final code = IntentResultStore.code;
    final market = IntentResultStore.market;
    if (baseUrl == null || code == null || market == null) return;

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
      debugPrint("지표 데이터 로드 실패: $e");
    }
  }

  // ----- 음성 제어 -----
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

  Future<void> _onVoiceCommandRecognized(String text) async {
    final lowerText = text.toLowerCase();

    final newStockCode = IntentResultStore.code;
    if (newStockCode != null) {
      await _fetchIndicatorData();
    }

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

  // ----- 헬퍼 -----
  String _formatValue(dynamic value, {String unit = ''}) {
    if (value == null) return 'N/A';
    final numValue = double.tryParse(value.toString()) ?? 0;
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
    if (baseUrl == null || code == null || market == null) {
      return '$title 정보를 불러오는 데 실패했습니다.';
    }

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
    final summary = await fetchSummaryFromApi(title);
    await flutterTts.speak(summary);
  }

  // ----- UI -----
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final textScale = MediaQuery.of(context).textScaleFactor;

    // 버튼에 쓸 제목 목록 (데이터가 있는 항목만)
    final titles =
        items
            .where((item) => indicatorValues.containsKey(item.title))
            .map((e) => e.title)
            .toList();

    return Scaffold(
      backgroundColor: cs.background,
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: _onRefresh,
            child: ListView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
              children: [
                // 상단 선택 지표 카드
                HeaderCard(
                  title: selectedTitle,
                  value: selectedValue,
                  semanticsLabelValue: '$selectedTitle, $selectedValue',
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      IndicatorDetailPage.route, // '/rsi/detail'
                      arguments: IndicatorDetailArgs(
                        metricTitle: selectedTitle,
                        currentValue: selectedValue,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),

                // ✅ 지표 선택: “가로로 긴 버튼”을 세로로 나열
                IndicatorList(
                  titles: titles,
                  selectedTitle: selectedTitle,
                  onPressed: _onIndicatorPressed,
                  onLongPressed: _onIndicatorLongPressed,
                ),

                const SizedBox(height: 16),

                // 하단 안내
                Center(
                  child: Text(
                    '아래로 스크롤하면 음성이 시작됩니다.',
                    textAlign: TextAlign.center,
                    style: tt.bodyMedium?.copyWith(
                      fontSize: 18 * textScale,
                      color: cs.onBackground.withOpacity(0.75),
                    ),
                  ),
                ),
                const SizedBox(height: 48),
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

/* ───────────────────────── 내부 모델 ───────────────────────── */
class _IndicatorItem {
  final String title;
  final Color backgroundColor; // (디자인은 테마 사용. 호환 위해 남김)
  const _IndicatorItem({required this.title, required this.backgroundColor});
}
