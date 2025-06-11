import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
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
        list
            .map(
              (e) => ChartData(
                date: DateTime.parse(e['date']),
                price: e['price'].toDouble(),
              ),
            )
            .toList();

    // 서비스 초기화 & SoundFont 로드
    _sonifier = ChartSonificationService(data: data);
    await _sonifier.loadSoundFont('assets/sf2/Piano.sf2');

    setState(() {}); // 데이터 & 서비스 준비 완료
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
                      final label = _sonifier.playNoteAtPosition(
                        details.localPosition,
                        chartWidth, // ← 실제 박스 너비
                      );
                      setState(() => selectedPrice = label);
                    },
                    onTapUp: (details) {
                      final label = _sonifier.playNoteAtPosition(
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
}
