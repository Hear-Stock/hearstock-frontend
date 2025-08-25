import 'package:flutter/material.dart';
import 'components/graph/chart_graph.dart';
import 'components/chart_timeline.dart';
import 'components/chart_header.dart';

import '../../services/voice_scroll_handler.dart';
import '../../widgets/mic_overlay.dart';
import '../../services/stock_chart_service.dart';
import '../../stores/intent_result_store.dart';

class ChartPage extends StatefulWidget {
  @override
  _ChartPageState createState() => _ChartPageState();
}

class _ChartPageState extends State<ChartPage> {
  String selectedTimeline = "3달";

  // 음성 인식 관련
  final VoiceScrollHandler _voiceScrollHandler = VoiceScrollHandler();
  final ScrollController _scrollController = ScrollController();
  bool _isMicrophoneActive = false;
  String _recognizedText = "";

  List<ChartData> _chartData = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_isMicrophoneActive) _stopListeningManually();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // intent 기반 진입 시 초기 데이터 주입
    if (IntentResultStore.chartJsonList.isNotEmpty) {
      final period = IntentResultStore.period ?? '3mo';
      final timeline = convertPeriodToTimeline(period);
      setState(() {
        selectedTimeline = timeline;
        _chartData =
            IntentResultStore.chartJsonList
                .cast<Map<String, dynamic>>()
                .map((e) => ChartData.fromJson(e))
                .toList();
        _isLoading = false;
      });
    } else {
      // 외부 진입이면 로딩 UI → 실제 fetch는 별도 컨트롤러에서 연결 예정
      setState(() {
        _isLoading = false;
      });
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
      onEnd: (isActive) => setState(() => _isMicrophoneActive = isActive),
    );
  }

  // period ↔ timeline 유틸 (옵션 확장)
  String convertTimelineToPeriod(String timeline) {
    switch (timeline) {
      case "1달":
        return "1mo";
      case "3달":
        return "3mo";
      case "1년":
        return "1y";
      case "5년":
        return "5y";
      case "10년":
        return "10y";
      default:
        return "3mo";
    }
  }

  String convertPeriodToTimeline(String period) {
    switch (period) {
      case "1mo":
        return "1달";
      case "3mo":
        return "3달";
      case "1y":
        return "1년";
      case "5y":
        return "5년";
      case "10y":
        return "10년";
      default:
        return "3달";
    }
  }

  void updateTimeline(String newTimeline) {
    setState(() {
      selectedTimeline = newTimeline;
      // 그래프 데이터 갱신이 필요하면 여기서 fetch 연동
      // final period = convertTimelineToPeriod(newTimeline);
      // ChartPageController().fetchChartData(...);
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: cs.background,

      // ✅ 하단 고정 버튼: RSI 페이지로 이동
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/rsi'),
            icon: const Icon(Icons.analytics_outlined),
            label: const Text('투자지표 보기'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),

      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: _onRefresh,
            child: ListView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 헤더
                      ChartHeader(
                        headerTitle: "삼성전자",
                        subtitle: "주식을 불러왔어요. 추가 정보를 요청하세요.",
                      ),
                      const SizedBox(height: 16),

                      // 기간 선택
                      Center(
                        child: ChartTimeline(
                          selectedTimeline: selectedTimeline,
                          onTimelineChanged: updateTimeline,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 그래프 카드
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                        decoration: BoxDecoration(
                          color: cs.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: cs.onSurface.withOpacity(0.12),
                          ),
                        ),
                        child: Column(
                          children: [
                            // 로딩/빈 상태 처리 간단화
                            if (_isLoading)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 48,
                                ),
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: cs.onSurface,
                                ),
                              )
                            else
                              SizedBox(
                                height: 260, // 필요시 조정
                                child: ChartGraph(data: _chartData),
                              ),

                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                selectedTimeline,
                                style: tt.labelLarge?.copyWith(
                                  fontSize: 14,
                                  color: cs.onSurface.withOpacity(0.7),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 18),

                      // 하단 설명
                      Center(
                        child: Text(
                          '아래로 스크롤하면 음성이 시작됩니다.',
                          style: tt.bodyMedium?.copyWith(
                            fontSize: 18,
                            color: cs.onBackground.withOpacity(0.75),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      const SizedBox(height: 100), // 하단 버튼과 간격 확보
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
