import 'package:flutter/material.dart';

class ChartGraph extends StatelessWidget {
  final String timeline; // 선택된 시간 옵션 (1주, 3달 등)

  ChartGraph({required this.timeline});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[300], // 차트 배경 색상
      height: 300, // 차트의 높이
      width: double.infinity, // 차트의 너비
      child: Center(
        child: Text(
          '그래프 (${timeline})', // 선택된 시간 옵션에 따라 차트 변화
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
