import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_soloud/flutter_soloud.dart';

//import 'chart_sonification.dart';
import 'chart_painter.dart';
import '../../../services/stock_chart_service.dart';

class ChartGraph extends StatefulWidget {
  final List<ChartData> data;

  ChartGraph({required this.data});

  @override
  _ChartGraphState createState() => _ChartGraphState();
}

class _ChartGraphState extends State<ChartGraph> {
  String selectedPrice = "";
  //late ChartSonificationService _sonifier;

  @override
  void initState() {
    super.initState();
    //_initializeSonifier();
  }

  // Future<void> _initializeSonifier() async {
  //   _sonifier = ChartSonificationService(data: widget.data);
  //   await _sonifier.init();
  //   setState(() {}); // 초기화 완료 후 리렌더링
  // }

  // @override
  // void didUpdateWidget(covariant ChartGraph oldWidget) {
  //   super.didUpdateWidget(oldWidget);
  //   // 데이터가 바뀌면 소리 서비스도 다시 초기화
  //   if (oldWidget.data != widget.data) {
  //     _sonifier.dispose();
  //     _initializeSonifier();
  //   }
  // }

  // @override
  // void dispose() {
  //   _sonifier.dispose();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    final data = widget.data;

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
                      // final label = await _sonifier.play3DSoundAt(
                      //   details.localPosition,
                      //   Size(chartWidth, chartHeight),
                      // );
                      // setState(() => selectedPrice = label);
                    },
                    onTapUp: (details) async {
                      // final label = await _sonifier.play3DSoundAt(
                      //   details.localPosition,
                      //   Size(chartWidth, chartHeight),
                      // );
                      // setState(() => selectedPrice = label);
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
