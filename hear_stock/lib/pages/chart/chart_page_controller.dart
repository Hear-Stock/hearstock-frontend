import '../../services/stock_chart_service.dart';
import '../../services/stock_chart_service.dart'; // ChartData 모델

class ChartPageController {
  // period 변환: 사용자 선택값 → API용 포맷
  String convertTimelineToPeriod(String timeline) {
    switch (timeline) {
      case "1달":
        return "1mo";
      case "3달":
        return "3mo";
      case "1년":
        return "1y";
      default:
        return "3mo";
    }
  }

  // 실제 API 호출
  Future<List<ChartData>> fetchChartData({
    required String timeline,
    required String code,
    required String market,
  }) async {
    final period = convertTimelineToPeriod(timeline);
    final data = await StockChartService.fetchChartData(
      code: '$code.KS', // API 요구 포맷
      market: market,
      period: period,
    );
    return data;
  }
}
