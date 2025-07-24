import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

/// 차트에 사용할 데이터 모델
class ChartData {
  final DateTime date;
  final double price;

  ChartData({required this.date, required this.price});
}

class StockChartService {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  /// 주식 차트 데이터를 가져오는 메소드
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

      return jsonList.map((item) {
        return ChartData(
          date: DateTime.parse(item['date']),
          price: (item['close'] ?? 0).toDouble(), // 종가 사용
        );
      }).toList();
    } else {
      throw Exception('API 요청 실패: ${response.statusCode}');
    }
  }
}
