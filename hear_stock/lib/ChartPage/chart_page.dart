import 'package:flutter/material.dart';
import 'components/chart_graph.dart';
import 'components/chart_timeline.dart';

class ChartPage extends StatefulWidget {
  @override
  _ChartPageState createState() => _ChartPageState();
}

class _ChartPageState extends State<ChartPage> {
  // 선택된 시간 옵션
  String selectedTimeline = "1주"; // 기본 값은 "1주"

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
      appBar: AppBar(
        title: Text("Chart Page", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent, // 투명한 배경
        elevation: 0, // 그림자 제거
      ),
      body: Column(
        children: <Widget>[
          // 상단 버튼들 (시간 선택)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ChartTimeline(
              selectedTimeline: selectedTimeline,
              onTimelineChanged: updateTimeline,
            ),
          ),
          SizedBox(height: 20), // 버튼과 차트 사이 간격
          // 차트 그래프 (중앙에 위치)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              height: 300, // 차트의 높이
              color: Colors.grey[300], // 차트 배경 색상
              child: Center(
                child: Text(
                  '그래프 (${selectedTimeline})',
                  style: TextStyle(fontSize: 20, color: Colors.black),
                ),
              ),
            ),
          ),
          SizedBox(height: 30), // 차트 아래 여백
          // 하단 마이크 아이콘과 안내 문구
          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 20),
          //   child: Column(
          //     children: [
          //       Icon(Icons.mic, size: 50, color: Colors.white),
          //       SizedBox(height: 10),
          //       Text(
          //         '위로 스크롤해서 마이크를 작동시켜 주세요.',
          //         style: TextStyle(color: Colors.white, fontSize: 16),
          //       ),
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }
}
