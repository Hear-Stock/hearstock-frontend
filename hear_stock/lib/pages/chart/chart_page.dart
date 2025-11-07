import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert'; // jsonDecode

import 'components/graph/chart_graph.dart';
import 'components/chart_timeline.dart';
import 'components/chart_header.dart';

import '../../services/voice_scroll_handler.dart';
import '../../widgets/mic_overlay.dart';
import '../../services/stock_chart_service.dart'; // ChartData
import '../../stores/intent_result_store.dart';
import '../../services/webSocket.dart';

class ChartPage extends StatefulWidget {
  @override
  _ChartPageState createState() => _ChartPageState();
}

class _ChartPageState extends State<ChartPage> {
  String selectedTimeline = '3달';
  bool _isMicrophoneActive = false;
  String _recognizedText = '';
  bool _isLoading = true;
  List<ChartData> _chartData = [];

  final VoiceScrollHandler _voiceScrollHandler = VoiceScrollHandler();
  final ScrollController _scrollController = ScrollController();

  // ✅ GlobalKey 타입을 public ChartGraphState로 수정
  final GlobalKey<ChartGraphState> _chartGraphKey =
      GlobalKey<ChartGraphState>();

  bool _didInitFromIntent = false;
  static const _pagePadding = EdgeInsets.fromLTRB(24, 28, 24, 16);

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
    if (_didInitFromIntent) return;
    _didInitFromIntent = true;
    _initFromIntentIfAny();
  }

  void _initFromIntentIfAny() {
    if (IntentResultStore.chartJsonList.isNotEmpty) {
      final period = IntentResultStore.period ?? '3mo';
      final timeline = _periodToTimeline(period);

      if (IntentResultStore.intent == "current_price") {
        selectedTimeline = "실시간";
        connectLive();
        _isLoading = false;
        return;
      }

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

  void _stopListeningManually() {
    _voiceScrollHandler.stopImmediately(
      context,
      (isActive) => setState(() => _isMicrophoneActive = isActive),
    );
  }

  Future<void> _onRefresh() async {
    setState(() {
      _recognizedText = "";
    });

    _voiceScrollHandler.startListening(
      context,
      onStart: (isActive) => setState(() => _isMicrophoneActive = isActive),
      onResult: (text) => setState(() => _recognizedText = text),
      onEnd: (isActive) => setState(() => _isMicrophoneActive = isActive),
    );
  }

  void updateTimeline(String newTimeline) {
    setState(() {
      selectedTimeline = newTimeline;

      if (newTimeline == "실시간") {
        disconnectLive();
        connectLive();
      } else {
        disconnectLive();
      }
    });
  }

  LivePriceSocket liveSocket = LivePriceSocket();
  StreamSubscription? liveSub;

  void connectLive() {
    final code = IntentResultStore.code!;
    liveSocket.connect(code);

    liveSub = liveSocket.stream?.listen((event) async {
      final msg = jsonDecode(event);
      print("WS msg : $msg");

      try {
        await _chartGraphKey.currentState?.runJavaScript(
          'window.updateRealTime(${jsonEncode(msg)})',
        );
        print("✅ React로 실시간 데이터 전달 완료");
      } catch (e) {
        print("❌ JS 호출 실패: $e");
      }

      if (msg["current_price"] != null && _chartData.isNotEmpty) {
        setState(() {
          final last = _chartData.last;
          final int newPrice = (msg["current_price"] as num).toInt();
          final int safeVolume =
              ((msg["volume"] as num?)?.toInt() ?? last.volume) < 0
                  ? last.volume
                  : (msg["volume"] as num?)?.toInt() ?? last.volume;

          final updated = ChartData(
            timestamp: last.timestamp,
            open: last.open,
            high: newPrice > last.high ? newPrice : last.high,
            low: newPrice < last.low ? newPrice : last.low,
            close: newPrice,
            volume: safeVolume,
            fluctuationRate:
                (msg["fluctuation_rate"] as num?)?.toDouble() ??
                last.fluctuationRate,
          );

          final newList = List<ChartData>.from(_chartData);
          newList[newList.length - 1] = updated;
          _chartData = List<ChartData>.from(newList);
        });
      }
    });
  }

  void disconnectLive() {
    liveSocket.disconnect();
    liveSub?.cancel();
    liveSub = null;
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
      case '10년':
        return '10y';
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
      case '10y':
        return '10년';
      default:
        return '3달';
    }
  }

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
                const SizedBox(height: 100),
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
          onPressed: () {
            final cleanCode = IntentResultStore.code!
                .replaceAll('.KS', '')
                .replaceAll('.KQ', '');
            Navigator.pushNamed(
              context,
              '/rsi',
              arguments: {
                'code': cleanCode,
                'name': IntentResultStore.name,
                'market': IntentResultStore.market,
              },
            );
          },
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
    );
  }

  Widget _buildHeader() {
    return ChartHeader(
      headerTitle: IntentResultStore.name ?? '주식',
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

  Widget _buildGraphCard(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final graphHeight = 800.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.onSurface.withOpacity(0.12)),
      ),
      child: Column(
        children: [
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 48),
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: cs.onSurface,
              ),
            )
          else
            SizedBox(
              height: graphHeight,
              child: ChartGraph(
                key: _chartGraphKey,
                code: IntentResultStore.code!,
                period:
                    selectedTimeline == "실시간"
                        ? "live"
                        : _timelineToPeriod(selectedTimeline),
                market: IntentResultStore.market!,
              ),
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
