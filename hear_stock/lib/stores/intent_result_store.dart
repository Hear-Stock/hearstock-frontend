class IntentResultStore {
  static String? name;
  static String? code;
  static String? market;
  static String? period;
  static List<dynamic> chartJsonList = [];

  static void set({
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
  }

  static void clear() {
    name = null;
    code = null;
    market = null;
    period = null;
    chartJsonList = [];
  }
}
