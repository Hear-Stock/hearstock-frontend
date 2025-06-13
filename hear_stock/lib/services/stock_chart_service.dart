import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ChartData {
  final DateTime date;
  final double price;

  ChartData({required this.date, required this.price});
}

class StockChartService {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  static Future<List<ChartData>> fetchChartData({
    required String code,
    required String market,
    required String period,
  }) async {
    final url = Uri.parse(
      '$baseUrl/api/stock/chart?code=$code&period=$period&market=$market',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((e) {
        return ChartData(
          date: DateTime.parse(e['date']),
          price: (e['close'] ?? 0).toDouble(), // 종가 사용
        );
      }).toList();
    } else {
      throw Exception('API 요청 실패: ${response.statusCode}');
    }
  }
}
