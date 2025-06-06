import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

import 'chart_data.dart';
import 'chart_sonification.dart';
import 'chart_painter.dart';
import '../../../ffi/soloud_ffi.dart';

class ChartGraph extends StatefulWidget {
  final String timeline;

  ChartGraph({required this.timeline});

  @override
  _ChartGraphState createState() => _ChartGraphState();
}

class _ChartGraphState extends State<ChartGraph> {
  String selectedPrice = "";
  List<ChartData> data = [];

  @override
  void initState() {
    super.initState();
    loadData();
    initSoloud(); // C++ SoLoud 초기화
  }

  Future<void> loadData() async {
    final raw = await rootBundle.loadString('assets/data/chart_data.json');
    final List<dynamic> list = json.decode(raw);
    data =
        list
            .map(
              (e) => ChartData(
                date: DateTime.parse(e['date']),
                price: e['price'].toDouble(),
              ),
            )
            .toList();

    setState(() {});
  }

  String playSoundFromPosition(Offset position, double chartWidth) {
    final index =
        (position.dx / chartWidth * data.length)
            .clamp(0, data.length - 1)
            .toInt();
    final point = data[index];
    final price = point.price;

    final x = (position.dx / chartWidth - 0.5) * 2;
    final y = (1 - (position.dy / 250.0)) * 2 - 1;
    final z = (price % 10) / 5.0 - 1.0;

    play3d(x, y, z); // FFI 호출

    return '${point.date.month}/${point.date.day}: ₩${price.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      padding: const EdgeInsets.all(10),
      color: const Color(0xff131313),
      height: 250,
      width: double.infinity,
      child:
          data.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : LayoutBuilder(
                builder: (context, constraints) {
                  final chartWidth = constraints.maxWidth;
                  return GestureDetector(
                    onPanUpdate: (details) {
                      final label = playSoundFromPosition(
                        details.localPosition,
                        chartWidth,
                      );
                      setState(() => selectedPrice = label);
                    },
                    onTapUp: (details) {
                      final label = playSoundFromPosition(
                        details.localPosition,
                        chartWidth,
                      );
                      setState(() => selectedPrice = label);
                    },
                    child: CustomPaint(
                      painter: ChartPainter(data: data),
                      size: Size(chartWidth, constraints.maxHeight),
                    ),
                  );
                },
              ),
    );
  }

  @override
  void dispose() {
    stopSoloud();
    super.dispose();
  }
}
