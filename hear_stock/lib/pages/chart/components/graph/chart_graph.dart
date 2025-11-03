import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ChartGraph extends StatefulWidget {
  final String code;
  final String period;
  final String market;

  const ChartGraph({
    required this.code,
    required this.period,
    required this.market,
  });

  @override
  State<ChartGraph> createState() => _ChartGraphState();
}

class _ChartGraphState extends State<ChartGraph> {
  late final WebViewController _controller;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _controller =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setNavigationDelegate(
            NavigationDelegate(onPageFinished: (url) => _sendStockData()),
          )
          ..loadRequest(
            Uri.parse('https://hearstock-frontend-react.vercel.app/webView'),
          );
  }

  Future<void> _sendStockData() async {
    final payload = jsonEncode({
      'code': widget.code,
      'period': widget.period,
      'market': widget.market,
    });
    await _controller.runJavaScript('window.updateStockChart($payload)');
    setState(() => _isLoaded = true);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        WebViewWidget(controller: _controller),
        if (!_isLoaded)
          const Center(child: CircularProgressIndicator(color: Colors.white)),
      ],
    );
  }
}
