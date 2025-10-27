import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'components/graph/chart_graph.dart';
import 'components/chart_timeline.dart';
import 'components/chart_header.dart';

import '../../services/voice_scroll_handler.dart';
import '../../widgets/mic_overlay.dart';
import '../../services/stock_chart_service.dart'; // ChartData
import '../../stores/intent_result_store.dart';

class ChartPage extends StatefulWidget {
  @override
  _ChartPageState createState() => _ChartPageState();
}

class _ChartPageState extends State<ChartPage> {
  late final WebViewController _controller;

  /* ────────────────────────────── UI State ────────────────────────────── */
  String selectedTimeline = '3달';
  bool _isMicrophoneActive = false;
  String _recognizedText = '';
  bool _isLoading = true;

  /* ───────────────────────────── Data State ───────────────────────────── */
  List<ChartData> _chartData = [];

  /* ───────────────────────────── Controllers ──────────────────────────── */
  final VoiceScrollHandler _voiceScrollHandler = VoiceScrollHandler();
  final ScrollController _scrollController = ScrollController();

  /* ─────────────────────────────── Constants ──────────────────────────── */
  static const _pagePadding = EdgeInsets.fromLTRB(24, 28, 24, 16);
  static const _graphHeight = 260.0;

  /* intent 초기화 중복 방지 */
  bool _didInitFromIntent = false;

  /* ───────────────────────────── Lifecycle ────────────────────────────── */
  @override
  void initState() {
    super.initState();

    _controller =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setNavigationDelegate(
            NavigationDelegate(
              onPageFinished: (url) {
                debugPrint('✅ WebView 로드 완료: $url');

                // 페이지 로드 완료 후 JS 호출 (Intent 값 전달)
                final code = IntentResultStore.code ?? '';
                final period = IntentResultStore.period ?? '3mo';
                final market = IntentResultStore.market ?? 'KR';

                if (code.isNotEmpty) {
                  final jsCode = """
              updateStockChart({
                code: '$code',
                period: '$period',
                market: '$market'
              });
            """;
                  _controller.runJavaScript(jsCode);
                  debugPrint('✅ 초기 JS 실행 완료: $jsCode');
                }
              },
            ),
          )
          ..loadRequest(
            Uri.parse('https://hearstock-frontend-react-j4lm.vercel.app/'),
          );

    _scrollController.addListener(() {
      if (_isMicrophoneActive) _stopListeningManually();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didInitFromIntent) return; // 가드
    _didInitFromIntent = true;
    _initFromIntentIfAny();
  }

  /* ─────────────────────────── Intent 초기화 ──────────────────────────── */
  void _initFromIntentIfAny() {
    if (IntentResultStore.chartJsonList.isNotEmpty) {
      final period = IntentResultStore.period ?? '3mo';
      final timeline = _periodToTimeline(period);

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
      setState(() => _isLoading = false);
    }
  }

  /* ───────────────────────────── Voice Hooks ──────────────────────────── */
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

  /* ───────────────────────────── Timeline API ─────────────────────────── */
  void updateTimeline(String newTimeline) async {
    setState(() {
      selectedTimeline = newTimeline;
      _isLoading = true;
    });

    final period = _timelineToPeriod(newTimeline);

    // code는 기존 IntentResultStore의 것을 그대로 유지
    final code = IntentResultStore.code ?? '';
    final market = IntentResultStore.market ?? 'KR'; // 선택사항
    if (code.isEmpty) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('종목 코드가 없습니다. 음성으로 먼저 검색하세요.')),
      );
      return;
    }

    try {
      // code는 유지, period만 변경해서 fetch
      final newData = await StockChartService.fetchChartData(
        code: code,
        period: period,
        market: market,
      );

      setState(() {
        _chartData = newData;
        _isLoading = false;
      });

      // period 갱신도 IntentResultStore에 반영 (다음 화면 전환 대비)
      IntentResultStore.period = period;

      final jsCode = """
        updateStockChart({
          code: '$code',
          period: '$period',
          market: '$market'
        });
      """;
      _controller.runJavaScript(jsCode);

      debugPrint('updateTimeline → WebView updateStockChart 호출 완료');
      debugPrint('updateTimeline: code=$code, period=$period');
    } catch (e, st) {
      debugPrint('updateTimeline 실패: $e\n$st');
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('데이터를 불러오지 못했습니다.')));
    }
  }

  static String _timelineToPeriod(String timeline) {
    switch (timeline) {
      case '1달':
        return '1mo';
      case '3달':
        return '3mo';
      case '1년':
        return '1y';
      case '5년':
        return '5y';
      case '전체':
        return 'all';
      default:
        return '3mo';
    }
  }

  static String _periodToTimeline(String period) {
    switch (period) {
      case '1mo':
        return '1달';
      case '3mo':
        return '3달';
      case '1y':
        return '1년';
      case '5y':
        return '5년';
      case 'all':
        return '전체';
      default:
        return '3달';
    }
  }

  /* ─────────────────────────────── Build ──────────────────────────────── */
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.background,
      bottomNavigationBar: _buildBottomBar(context),
      body: Stack(
        children: [
          _buildScrollableBody(context),
          if (_isMicrophoneActive)
            MicOverlay(
              recognizedText: _recognizedText,
              onStop: _stopListeningManually,
            ),
        ],
      ),
    );
  }

  /* ───────────────────────────── Sections ─────────────────────────────── */

  Widget _buildScrollableBody(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: ListView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          Padding(
            padding: _pagePadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 16),
                _buildTimelineSelector(),
                const SizedBox(height: 16),
                _buildGraphCard(context),
                const SizedBox(height: 18),
                _buildFooterHint(context),
                const SizedBox(height: 100), // 하단 버튼과 여유 간격
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: () => Navigator.pushNamed(context, '/rsi'),
          icon: const Icon(Icons.analytics_outlined),
          label: const Text('투자지표 보기'), // 색은 버튼 테마에서 처리
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
    );
  }

  Widget _buildHeader() {
    return const ChartHeader(
      headerTitle: '삼성전자',
      subtitle: '주식을 불러왔어요. 추가 정보를 요청하세요.',
    );
  }

  Widget _buildTimelineSelector() {
    return Center(
      child: ChartTimeline(
        selectedTimeline: selectedTimeline,
        onTimelineChanged: updateTimeline,
      ),
    );
  }

  // Widget _buildGraphCard(BuildContext context) {
  //   final cs = Theme.of(context).colorScheme;
  //   final tt = Theme.of(context).textTheme;

  //   return Container(
  //     width: double.infinity,
  //     padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
  //     decoration: BoxDecoration(
  //       color: cs.surface,
  //       borderRadius: BorderRadius.circular(12),
  //       border: Border.all(color: cs.onSurface.withOpacity(0.12)),
  //     ),
  //     child: Column(
  //       children: [
  //         if (_isLoading)
  //           Padding(
  //             padding: const EdgeInsets.symmetric(vertical: 48),
  //             child: CircularProgressIndicator(
  //               strokeWidth: 2,
  //               color: cs.onSurface,
  //             ),
  //           )
  //         else
  //           SizedBox(height: _graphHeight, child: ChartGraph(data: _chartData)),
  //         const SizedBox(height: 8),
  //         Align(
  //           alignment: Alignment.centerRight,
  //           child: Text(
  //             selectedTimeline,
  //             style: tt.labelLarge?.copyWith(
  //               fontSize: 14,
  //               color: cs.onSurface.withOpacity(0.7),
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }
  Widget _buildGraphCard(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      height: 400,
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.onSurface.withOpacity(0.12)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: WebViewWidget(controller: _controller),
      ),
    );
  }

  Widget _buildFooterHint(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Center(
      child: Text(
        '아래로 스크롤하면 음성이 시작됩니다.',
        textAlign: TextAlign.center,
        style: tt.bodyMedium?.copyWith(
          fontSize: 18,
          color: cs.onBackground.withOpacity(0.75),
        ),
      ),
    );
  }
}
