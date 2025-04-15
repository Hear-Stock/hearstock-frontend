import 'package:flutter/material.dart';

class ChartTimeline extends StatelessWidget {
  final String selectedTimeline; // 현재 선택된 시간
  final Function(String) onTimelineChanged; // 버튼 클릭 시 상태 변경 함수

  ChartTimeline({
    required this.selectedTimeline,
    required this.onTimelineChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('실시간', style: TextStyle(fontSize: 18)),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _buildTimelineButton("1주"),
            _buildTimelineButton("3달"),
            _buildTimelineButton("6달"),
            _buildTimelineButton("1년"),
            _buildTimelineButton("5년"),
            _buildTimelineButton("10년"),
          ],
        ),
      ],
    );
  }

  // 버튼을 생성하는 헬퍼 함수
  Widget _buildTimelineButton(String timeline) {
    return ElevatedButton(
      onPressed: () {
        onTimelineChanged(timeline); // 버튼 클릭 시 콜백 실행
      },
      child: Text(timeline),
      style: ElevatedButton.styleFrom(
        backgroundColor:
            selectedTimeline == timeline ? Colors.white : Colors.grey,
      ),
    );
  }
}
