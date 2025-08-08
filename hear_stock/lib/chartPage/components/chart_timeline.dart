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
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          child: TextButton(
            onPressed: () {},
            child: Text(
              '실시간',
              style: TextStyle(fontSize: 18, color: Colors.black),
            ),
            style: TextButton.styleFrom(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            ),
          ),
        ),
        SizedBox(height: 20),
        Wrap(
          spacing: 4, // 버튼 간 간격
          runSpacing: 4, // 줄 간 간격
          alignment: WrapAlignment.center, // 버튼들을 가운데 정렬
          children: <Widget>[
            _buildTimelineButton("실시간"),
            _buildTimelineButton("3달"),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 1),
      child: TextButton(
        onPressed: () {
          onTimelineChanged(timeline); // 버튼 클릭 시 콜백 실행
        },
        child: Text(
          timeline,
          style: TextStyle(
            fontSize: 16,
            fontWeight:
                selectedTimeline == timeline
                    ? FontWeight.bold
                    : FontWeight.normal,
            color: selectedTimeline == timeline ? Colors.white : Colors.black,
          ),
        ),
        style: TextButton.styleFrom(
          backgroundColor:
              selectedTimeline == timeline ? Colors.orange : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6), // 둥근 버튼
          ),
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5), // 버튼 크기
        ),
      ),
    );
  }
}
