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
  // 선택된 시간 옵션
  String selectedTimeline = "3달";

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // intent 기반 진입인 경우
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
    }
  }

  // 음성 인식 관련 변수 추가
  final VoiceScrollHandler _voiceScrollHandler = VoiceScrollHandler();
  final ScrollController _scrollController = ScrollController();

  bool _isMicrophoneActive = false;
  String _recognizedText = "";

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_isMicrophoneActive) {
        _stopListeningManually();
      }
    });
  }

  // 음성 인식 중단
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

  List<ChartData> _chartData = []; // 받아온 차트 데이터 저장
  bool _isLoading = true;

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

  // 받아온 period를 기간으로
  String convertPeriodToTimeline(String period) {
    switch (period) {
      case "1mo":
        return "1달";
      case "3mo":
        return "3달";
      case "1y":
        return "1년";
      default:
        return "3달";
    }
  }

  // 시간 옵션 버튼 클릭 시 업데이트하는 메소드
  void updateTimeline(String newTimeline) {
    setState(() {
      selectedTimeline = newTimeline;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff262626),

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
    );
  }
}
