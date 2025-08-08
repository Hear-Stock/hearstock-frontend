import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

// 차트에 사용할 데이터 모델
class ChartData {
  final String timestamp;
  final int open, high, low, close, volume;
  final double fluctuationRate;

  ChartData({
    required this.timestamp,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
    required this.fluctuationRate,
  });

  factory ChartData.fromJson(Map<String, dynamic> json) {
    return ChartData(
      timestamp: json['timestamp'],
      open: json['open'],
      high: json['high'],
      low: json['low'],
      close: json['close'],
      volume: json['volume'],
      fluctuationRate: (json['fluctuation_rate'] as num).toDouble(),
    );
  }
}

class StockChartService {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  // 주식 차트 데이터를 가져오는 메소드
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
          timestamp: item['timestamp'],
          open: item['open'],
          high: item['high'],
          low: item['low'],
          close: item['close'],
          volume: item['volume'],
          fluctuationRate: (item['fluctuation_rate'] as num).toDouble(),
        );
      }).toList();
    } else {
      throw Exception('API 요청 실패: ${response.statusCode}');
    }
  }
}
