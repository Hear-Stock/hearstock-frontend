import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  // 텍스트를 보내 intent 파악
  static Future<void> sendRecognizedText(String text) async {
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
      await _fetchDataFromIntent(data);
    } else {
      print('의도 분석 실패: ${response.statusCode}, ${response.body}');
    }
  }

  // intent 결과에 따라 실제 API 호출
  static Future<void> _fetchDataFromIntent(Map<String, dynamic> data) async {
    final String? path = data['path'];
    if (path == null || path.isEmpty) {
      print('path 없음: $data');
      return;
    }

    // 쿼리 파라미터 붙은 path일 수 있으므로 전체 URL로 처리
    final url = Uri.parse('$baseUrl$path');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      print('데이터 요청 성공: ${response.body}');
    } else {
      print('데이터 요청 실패: ${response.statusCode}, ${response.body}');
    }
  }
}
