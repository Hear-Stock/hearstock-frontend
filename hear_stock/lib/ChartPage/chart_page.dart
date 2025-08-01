import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'components/graph/chart_graph.dart';
import 'components/chart_timeline.dart';
import 'components/chart_header.dart';

import '../services/voice_scroll_handler.dart';
import '../widgets/mic_overlay.dart';
import '../services/stock_chart_service.dart';
import 'chart_page_controller.dart';
import '../providers/intent_result_provider.dart';

class ChartPage extends StatefulWidget {
  @override
  _ChartPageState createState() => _ChartPageState();
}

class _ChartPageState extends State<ChartPage> {
  // 선택된 시간 옵션
  String selectedTimeline = "";

  // 음성 인식 관련 변수 추가
  final VoiceScrollHandler _voiceScrollHandler = VoiceScrollHandler();
  bool _isMicrophoneActive = false;
  String _recognizedText = "";

  List<ChartData> _chartData = []; // 받아온 차트 데이터 저장
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final intentProvider = Provider.of<IntentResultProvider>(
        context,
        listen: false,
      );

      if (intentProvider != null) {
        final code = intentProvider.code ?? '';
        final market = intentProvider.market ?? '';
        final period = intentProvider.period ?? '3mo';

        _fetchDataFromIntent(code, market, period);
      }
    });
  }

  // 기간에 맞는 period 포맷 변환
  String convertTimelineToPeriod(String timeline) {
    switch (timeline) {
      case "1달":
        return "1mo";
      case "3달":
        return "3mo";
      case "1년":
        return "1y";
      default:
        return "3mo";
    }
  }

  // API 호출 함수
  final ChartPageController _controller = ChartPageController();

  Future<void> _fetchDataFromIntent(
    String code,
    String market,
    String period,
  ) async {
    setState(() => _isLoading = true);

    try {
      final period = convertTimelineToPeriod(selectedTimeline);
      final data = await _controller.fetchChartData(
        timeline: selectedTimeline,
        code: code,
        market: market,
      );

      setState(() {
        _chartData = data;
        _isLoading = false;
      });
    } catch (e) {
      print("차트 불러오기 실패: $e");
      setState(() => _isLoading = false);
    }
  }

  // 시간 옵션 버튼 클릭 시 업데이트하는 메소드
  void updateTimeline(String newTimeline) {
    setState(() {
      selectedTimeline = newTimeline;
    });
  }

  Future<void> _onRefresh() async {
    _voiceScrollHandler.startListening(
      context,
      onStart: (isActive) => setState(() => _isMicrophoneActive = isActive),
      onResult: (text) => setState(() => _recognizedText = text),
      onEnd: (isActive) => setState(() => _isMicrophoneActive = isActive),
    );
  }

  // 음성 인식 중단
  void _stopListeningManually() {
    setState(() {
      _isMicrophoneActive = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff262626),
      appBar: AppBar(
        title: Text("Chart Page", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: Stack(
          children: [
            SingleChildScrollView(
              // 스크롤이 가능하게
              physics: const AlwaysScrollableScrollPhysics(), // 새로고침을 항상 가능하게
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SizedBox(height: 20),
                  // 헤더 글자
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: ChartHeader(
                        headerTitle: "삼성전자",
                        subtitle: "주식을 불러왔어요.\n추가 정보를 요청하세요.",
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  // 기간 선택 버튼
                  ChartTimeline(
                    selectedTimeline: selectedTimeline,
                    onTimelineChanged: updateTimeline,
                  ),
                  SizedBox(height: 10),
                  // 차트 그래프
                  ChartGraph(data: _chartData),
                  SizedBox(height: 10),
                  Center(
                    child: Text(
                      '아래로 스크롤해서 마이크를 작동시키세요.',
                      style: TextStyle(color: Colors.white70, fontSize: 15),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: 80),
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
