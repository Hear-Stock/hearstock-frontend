import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

// 차트 데이터 모델
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

  // POST 방식으로 변경된 메서드
  static Future<List<ChartData>> fetchChartData({
    required String code,
    required String market,
    required String period,
  }) async {
    final fullCode = code.contains('.') ? code : '$code.KS';
    final url = Uri.parse('$baseUrl/api/stock/chart/direct');

    print('[POST] 요청 URL: $url');
    print('body: { stock_code: $fullCode, period: $period, market: $market }');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'stock_code': fullCode,
        'period': period,
        'market': market,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      // 응답이 List 형식인지 확인
      if (data is List) {
        return data.map((item) => ChartData.fromJson(item)).toList();
      }
      // 응답이 {"data": [...]} 구조인 경우도 대비
      else if (data is Map && data['data'] is List) {
        return (data['data'] as List)
            .map((item) => ChartData.fromJson(item))
            .toList();
      } else {
        throw Exception('응답 형식이 예상과 다릅니다.');
      }
    } else {
      print('서버 응답 오류: ${response.statusCode}, ${response.body}');
      throw Exception('API 요청 실패 (${response.statusCode})');
    }
  }
}
