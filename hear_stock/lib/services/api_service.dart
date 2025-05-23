import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  static Future<void> sendRecognizedText(String text) async {
    final url = Uri.parse('$baseUrl/api/stock/chart');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'text': text}),
    );

    if (response.statusCode == 200) {
      print('서버 전송 성공: ${response.body}');
    } else {
      print('서버 전송 실패: ${response.statusCode}, ${response.body}');
    }
  }
}
