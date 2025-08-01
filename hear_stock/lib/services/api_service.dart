import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/intent_result_provider.dart';

class ApiService {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  // 텍스트를 보내 intent 파악
  static Future<void> sendRecognizedText(
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
  static Future<void> _fetchDataFromIntent(
    Map<String, dynamic> data,
    BuildContext context,
  ) async {
    final intentProvider = Provider.of<IntentResultProvider>(
      context,
      listen: false,
    );
    intentProvider.setIntentResult(data);

    final String? path = data['path'];
    final String? intent = data['intent'];

    if (path == null || path.isEmpty) {
      print('path 없음: $data');
      return;
    }

    // API 요청
    final url = Uri.parse('$baseUrl$path');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      print('데이터 요청 성공: ${response.body}');

      // intent에 따라 페이지 이동
      if (intent == 'chart') {
        Navigator.pushNamed(context, '/chart');
      } else if (intent == 'indicator') {
        Navigator.pushNamed(context, '/rsi');
      } else {
        print('알 수 없는 intent: $intent');
      }
    } else {
      print('데이터 요청 실패: ${response.statusCode}, ${response.body}');
    }
  }
}
