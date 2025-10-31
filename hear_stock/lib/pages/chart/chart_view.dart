import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../stores/intent_result_store.dart';

class ChartGraphView extends StatefulWidget {
  final List<dynamic> data;
  final String? code;
  final String? period;
  final String? market;

  const ChartGraphView({
    required this.data,
    this.code,
    this.period,
    this.market,
    Key? key,
  }) : super(key: key);

  @override
  State<ChartGraphView> createState() => _ChartGraphState();
}

class _ChartGraphState extends State<ChartGraphView> {
  late final WebViewController _controller;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();

    _controller =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setBackgroundColor(const Color(0xff131313))
          ..setNavigationDelegate(
            NavigationDelegate(
              onPageFinished: (url) async {
                setState(() => _isLoaded = true);
                await _sendStockData();
              },
            ),
          )
          // React 페이지 주소
          ..loadRequest(
            Uri.parse('https://hearstock-frontend-react.vercel.app/webView'),
          );
  }

  // Flutter → React 데이터 전달
  Future<void> _sendStockData() async {
    final code = widget.code ?? IntentResultStore.code ?? '005930';
    final period = widget.period ?? IntentResultStore.period ?? '3mo';
    final market = widget.market ?? IntentResultStore.market ?? 'KOSPI';

    final data = jsonEncode({'code': code, 'period': period, 'market': market});

    print('Flutter → React 전달 데이터: $data');

    try {
      await _controller.runJavaScript('window.updateStockChart($data)');
    } catch (e) {
      print('JavaScript 실행 실패: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 360,
      decoration: const BoxDecoration(
        color: Color(0xff131313),
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (!_isLoaded)
            const Center(child: CircularProgressIndicator(color: Colors.white)),
        ],
      ),
    );
  }
}
