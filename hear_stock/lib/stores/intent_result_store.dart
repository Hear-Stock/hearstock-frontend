class IntentResultStore {
  static String? name;
  static String? code;
  static String? market;
  static String? period;
  static List<dynamic> chartJsonList = [];
  static Map<String, dynamic> indicatorData = {};

  static void setChart({
    required String name_,
    required String code_,
    required String market_,
    required String period_,
    required List<dynamic> chartData,
  }) {
    name = name_;
    code = code_;
    market = market_;
    period = period_;
    chartJsonList = chartData;
    indicatorData = {}; // chart intent면 indicator는 비움
  }

  static void setIndicator({
    required String name_,
    required String code_,
    required String market_,
    required Map<String, dynamic> indicator,
  }) {
    name = name_;
    code = code_;
    market = market_;
    indicatorData = indicator;
    chartJsonList = []; // indicator intent면 chart는 비움
  }

  static void clear() {
    name = null;
    code = null;
    market = null;
    period = null;
    chartJsonList = [];
    indicatorData = {};
  }
}
