import 'package:flutter/material.dart';

class ChartHeader extends StatelessWidget {
  final String headerTitle;
  final String subtitle;

  ChartHeader({required this.headerTitle, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          headerTitle, // 동적으로 받은 headerTitle을 표시
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white, // 색상은 필요에 맞게 조정
          ),
        ),
        SizedBox(height: 8), // '엔비디아'와 '주식' 사이에 간격
        Text(
          subtitle, // 동적으로 받은 subtitle을 표시
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
