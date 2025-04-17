import 'package:flutter/material.dart';
import 'components/chart_graph.dart';
import 'components/chart_timeline.dart';
import 'components/chart_header.dart';

class ChartPage extends StatefulWidget {
  @override
  _ChartPageState createState() => _ChartPageState();
}

class _ChartPageState extends State<ChartPage> {
  // 선택된 시간 옵션
  String selectedTimeline = "3달";

  // 시간 옵션 버튼 클릭 시 업데이트 메소드
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
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(height: 20),
          // 헤더 글자
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 20.0),
              child: ChartHeader(
                headerTitle: "엔비디아",
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
          Container(
            margin: EdgeInsets.symmetric(horizontal: 20),
            height: 300,
            color: Colors.grey[300],
            child: Center(
              child: Text(
                '그래프 (${selectedTimeline})',
                style: TextStyle(fontSize: 20, color: Colors.black),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
