import 'package:flutter/material.dart';

class ChartGraph extends StatelessWidget {
  final String timeline;

  ChartGraph({required this.timeline});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xff131313),
      height: 300,
      width: double.infinity,
      child: CustomPaint(painter: ChartPainter()),
    );
  }
}

class ChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // 차트 그리기
    final Paint linePaint =
        Paint()
          ..color = Colors.orange
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;

    // 데이터: 가격 날짜 하드코딩
    final List<ChartData> data = [
      ChartData(DateTime(2025, 1, 17), 53700),
      ChartData(DateTime(2025, 1, 18), 54000),
      ChartData(DateTime(2025, 1, 19), 53000),
      ChartData(DateTime(2025, 1, 20), 56000),
      ChartData(DateTime(2025, 1, 21), 55000),
      ChartData(DateTime(2025, 1, 22), 56000),
      ChartData(DateTime(2025, 1, 23), 57000),
    ];

    // 최대값과 최소값 계산
    double minPrice = data[0].price;
    double maxPrice = data[0].price;
    for (var item in data) {
      if (item.price < minPrice) minPrice = item.price;
      if (item.price > maxPrice) maxPrice = item.price;
    }

    // X, Y 축의 범위 계산
    final double chartWidth = size.width;
    final double chartHeight = size.height;

    // Y축 스케일: 가격 범위를 차트 높이에 맞게 매핑
    double scaleY = chartHeight / (maxPrice - minPrice);

    // X축 스케일: 날짜 범위를 차트 너비에 맞게 매핑
    double scaleX = chartWidth / (data.length - 1);

    // 차트의 선을 그리기
    for (int i = 0; i < data.length - 1; i++) {
      final x1 = i * scaleX;
      final y1 = chartHeight - (data[i].price - minPrice) * scaleY;

      final x2 = (i + 1) * scaleX;
      final y2 = chartHeight - (data[i + 1].price - minPrice) * scaleY;

      // 선을 그림
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

// 차트 데이터 모델
class ChartData {
  final DateTime date;
  final double price;

  ChartData(this.date, this.price);
}
