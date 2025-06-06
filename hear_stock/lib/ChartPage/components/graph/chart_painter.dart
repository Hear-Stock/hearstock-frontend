// lib/chart_painter.dart
import 'package:flutter/material.dart';
import 'chart_sonification.dart'; // ChartData를 쓰기 위해

class ChartPainter extends CustomPainter {
  final List<ChartData> data;
  ChartPainter({required this.data});

  @override
  void paint(Canvas canvas, Size size) {
    // 1) 선 그릴 Paint 설정
    final Paint linePaint =
        Paint()
          ..color = Colors.orange
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;

    // 2) 데이터에서 최소·최대 가격 계산
    double minPrice = data[0].price;
    double maxPrice = data[0].price;
    for (var item in data) {
      if (item.price < minPrice) minPrice = item.price;
      if (item.price > maxPrice) maxPrice = item.price;
    }

    // 3) 차트 크기
    final double chartWidth = size.width;
    final double chartHeight = size.height;

    // 4) 스케일 계산
    double scaleY = chartHeight / (maxPrice - minPrice);
    double scaleX = chartWidth / (data.length - 1);

    // 5) 점들을 이어 선으로 그림
    for (int i = 0; i < data.length - 1; i++) {
      final double x1 = i * scaleX;
      final double y1 = chartHeight - (data[i].price - minPrice) * scaleY;
      final double x2 = (i + 1) * scaleX;
      final double y2 = chartHeight - (data[i + 1].price - minPrice) * scaleY;

      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
