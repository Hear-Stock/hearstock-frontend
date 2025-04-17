import 'dart:convert'; // JSON 파싱을 위해 추가
import 'package:flutter/services.dart'; // rootBundle을 사용하기 위해 추가
import 'package:flutter/material.dart';

class ChartGraph extends StatefulWidget {
  final String timeline;

  ChartGraph({required this.timeline});

  @override
  _ChartGraphState createState() => _ChartGraphState();
}

class _ChartGraphState extends State<ChartGraph> {
  String selectedPrice = ""; // 선택된 주식 가격을 표시
  List<ChartData> data = []; // JSON에서 불러온 데이터

  @override
  void initState() {
    super.initState();
    // 앱 시작 시 데이터 읽기
    loadData();
  }

  // JSON 데이터를 읽어오는 함수
  Future<void> loadData() async {
    final String response = await rootBundle.loadString(
      'assets/data/chart_data.json', // JSON 파일 경로
    );
    final List<dynamic> dataList = json.decode(response);

    // 데이터 모델로 변환
    setState(() {
      data =
          dataList
              .map(
                (item) => ChartData(
                  DateTime.parse(item['date']),
                  item['price'].toDouble(),
                ),
              )
              .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      padding: const EdgeInsets.all(10),
      color: Color(0xff131313),
      height: 250,
      width: double.infinity,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            selectedPrice = getPriceFromPosition(
              details.localPosition,
            ); // 드래그 시 가격 갱신
          });
        },
        onTapUp: (details) {
          setState(() {
            selectedPrice = getPriceFromPosition(
              details.localPosition,
            ); // 클릭 시 가격 갱신
          });
        },
        child: CustomPaint(painter: ChartPainter(data: data)),
      ),
    );
  }

  // 클릭된 위치에 해당하는 주식 가격을 구하는 메소드
  String getPriceFromPosition(Offset position) {
    if (data.isEmpty) return "";

    // X, Y 축의 범위 계산
    final double chartWidth = MediaQuery.of(context).size.width;
    final double chartHeight = 250;

    double scaleX = chartWidth / (data.length - 1);
    double scaleY =
        chartHeight /
        (data.map((e) => e.price).reduce((a, b) => a > b ? a : b) -
            data.map((e) => e.price).reduce((a, b) => a < b ? a : b));

    // X축 위치에 맞는 가격을 찾기
    int closestIndex = ((position.dx / scaleX).round()).clamp(
      0,
      data.length - 1,
    );
    double closestPrice = data[closestIndex].price;

    // 콘솔에 출력
    print("Date: ${data[closestIndex].date}, Price: \$${closestPrice}");

    return "${data[closestIndex].date.toLocal().toString().split(' ')[0]}: \$${closestPrice.toString()}"; // 날짜와 가격을 반환
  }
}

class ChartPainter extends CustomPainter {
  final List<ChartData> data;

  ChartPainter({required this.data});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint linePaint =
        Paint()
          ..color = Colors.orange
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;

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
