import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';

import '../stores/intent_result_store.dart';

class ApiService {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  // 텍스트를 보내 intent 파악
  static Future<Map<String, dynamic>?> sendRecognizedText(
    String text,
    BuildContext context,
  ) async {
    final url = Uri.parse('$baseUrl/api/intent/');
    print('API 호출 시도 함 url은?: $url');
    print('보낼 텍스트: $text');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'text': text}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('의도 분석 성공: $data');
      await _fetchDataFromIntent(data, context);
    } else {
      print('의도 분석 실패: ${response.statusCode}, ${response.body}');
    }
  }

  // intent 결과에 따라 실제 API 호출
  static Future<dynamic> _fetchDataFromIntent(
    Map<String, dynamic> data,
    BuildContext context,
  ) async {
    final String? path = data['path'];
    final String? intent = data['intent'];

    if (intent == 'current_price') {
      IntentResultStore.intent = "current_price";
      IntentResultStore.name = data['name'];
      IntentResultStore.code = data['code'];
      IntentResultStore.market = data['market'];
      IntentResultStore.market = data['market'];
      IntentResultStore.period = null;

      Navigator.pushNamed(context, '/chart');
      return;
    }

    if (path == null || path.isEmpty) {
      print('path 없음: $data');
      return;
    }

    try {
      print('intent에 따른 API 요청 시도');
      // API 요청
      final url = Uri.parse('$baseUrl$path');
      print('intent에 따른 API 호출 시도 함 url은?: $url');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final fetchedData = json.decode(response.body);

        final name = data['name'];
        final code = data['code'];
        final market = data['market'];
        final period = data['period'];

        if (code == null || market == null) {
          print("❌ 종목 식별 실패");
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("해당 종목을 찾지 못했어요. 정확한 종목명을 다시 말씀해주세요."),
            ),
          );
          return; // 여기서 종료
        }

        // intent에 따라 저장
        if (intent == 'chart') {
          IntentResultStore.setChart(
            name_: name,
            code_: code,
            market_: market,
            period_: period,
            chartData: fetchedData,
          );
        } else if (intent == 'indicator') {
          print('indicator 데이터 요청 성공: ${fetchedData}');
          IntentResultStore.setIndicator(
            name_: name,
            code_: code,
            market_: market,
            indicator: fetchedData,
          );
        }

        // intent에 따라 페이지 이동
        if (intent == 'chart') {
          Navigator.pushNamed(context, '/chart');
        } else if (intent == 'indicator') {
          Navigator.pushNamed(context, '/rsi');
        } else {
          print('알 수 없는 intent: $intent');
        }

        return fetchedData;
      } else {
        print('데이터 요청 실패: ${response.statusCode}, ${response.body}');
      }
    } catch (e, stack) {
      print('❌ 예외 발생: $e');
      print('🔍 Stacktrace:\n$stack');
    }
  }
}
