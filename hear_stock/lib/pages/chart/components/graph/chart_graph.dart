// chart_graph.dart
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/gestures.dart';
import '../../../../stores/intent_result_store.dart';
import 'package:flutter/foundation.dart';

class ChartGraph extends StatefulWidget {
  final List<dynamic>? data;
  final String? code;
  final String? period;
  final String? market;

  const ChartGraph({this.data, this.code, this.period, this.market, Key? key})
    : super(key: key);

  // ✅ 외부에서 State 접근 가능하도록 public
  @override
  ChartGraphState createState() => ChartGraphState();
}

// ✅ State 클래스 public으로 선언
class ChartGraphState extends State<ChartGraph> {
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
                print("WebView 로드 완료 => JS 호출 시작");
                setState(() => _isLoaded = true);
                await _sendStockData();
              },
            ),
          )
          ..loadRequest(
            Uri.parse('https://hearstock-frontend-react-1.vercel.app/webView'),
          );
  }

  Future<void> _sendStockData() async {
    final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';
    final code = widget.code ?? IntentResultStore.code;
    String? period;

    if (IntentResultStore.intent != "current_price") {
      period = widget.period ?? IntentResultStore.period;
    }
    final market = widget.market ?? IntentResultStore.market;

    final data = jsonEncode({
      'baseUrl': baseUrl,
      'code': code,
      if (period != null) 'period': period,
      'market': market,
    });

    print('Flutter → React 전달 데이터: $data');

    try {
      await runJavaScript('window.updateStockChart($data)');
      print("JS 호출 완료됨");
    } catch (e) {
      print('JavaScript 실행 실패: $e');
    }
  }

  // ✅ 외부에서 JS 실행 가능
  Future<void> runJavaScript(String jsCode) async {
    try {
      await _controller.runJavaScript(jsCode);
    } catch (e) {
      print('JS 실행 실패: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.55,
      decoration: const BoxDecoration(
        color: Color(0xff131313),
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: Stack(
        children: [
          WebViewWidget(
            controller: _controller,
            gestureRecognizers:
                const <Factory<OneSequenceGestureRecognizer>>{}.toSet(),
          ),
          if (!_isLoaded)
            const Center(child: CircularProgressIndicator(color: Colors.white)),
        ],
      ),
    );
  }

  @override
  void didUpdateWidget(covariant ChartGraph oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.code != widget.code ||
        oldWidget.period != widget.period ||
        oldWidget.market != widget.market) {
      _sendStockData();
    }
  }
}
