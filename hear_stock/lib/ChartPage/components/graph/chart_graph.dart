import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_soloud/flutter_soloud.dart';

import 'chart_sonification.dart';
import 'chart_painter.dart';

class ChartGraph extends StatefulWidget {
  final String timeline;

  ChartGraph({required this.timeline});

  @override
  _ChartGraphState createState() => _ChartGraphState();
}

class _ChartGraphState extends State<ChartGraph> {
  String selectedPrice = "";
  List<ChartData> data = [];

  late ChartSonificationService _sonifier;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final raw = await rootBundle.loadString('assets/data/chart_data.json');
    final List<dynamic> list = json.decode(raw);

    data =
        list.map((e) {
          return ChartData(
            date: DateTime.parse(e['date']),
            price: e['price'].toDouble(),
          );
        }).toList();

    _sonifier = ChartSonificationService(data: data);
    await _sonifier.init();

    setState(() {}); // 데이터 로딩 및 초기화 완료
  }

  @override
  void dispose() {
    _sonifier.dispose();
    super.dispose();
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
                  final chartHeight = constraints.maxHeight;

                  return GestureDetector(
                    onPanUpdate: (details) async {
                      final label = await _sonifier.play3DSoundAt(
                        details.localPosition,
                        Size(chartWidth, chartHeight),
                      );
                      setState(() => selectedPrice = label);
                    },
                    onTapUp: (details) async {
                      final label = await _sonifier.play3DSoundAt(
                        details.localPosition,
                        Size(chartWidth, chartHeight),
                      );
                      setState(() => selectedPrice = label);
                    },
                    child: CustomPaint(
                      painter: ChartPainter(data: data),
                      size: Size(chartWidth, chartHeight),
                    ),
                  );
                },
              ),
    );
  }
}
