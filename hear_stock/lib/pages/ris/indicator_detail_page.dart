// pages/ris/indicator_detail_page.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../stores/intent_result_store.dart';

class IndicatorDetailArgs {
  final String metricTitle;
  final String currentValue;
  const IndicatorDetailArgs({
    required this.metricTitle,
    required this.currentValue,
  });
}

class IndicatorDetailPage extends StatefulWidget {
  static const route = '/rsi/detail';

  final IndicatorDetailArgs args;
  const IndicatorDetailPage({super.key, required this.args});

  @override
  State<IndicatorDetailPage> createState() => _IndicatorDetailPageState();
}

class _IndicatorDetailPageState extends State<IndicatorDetailPage> {
  double? _yoyChangePct; // 예: +12.3 (단위 %)
  String? _prevYearValue; // 예: "1.2조원"
  bool _loading = true;

  // 간단 부제목 설명
  static const Map<String, String> _descriptions = {
    '시가총액': '회사의 전체 가치를 나타내는 지표입니다.',
    '배당수익률': '주가 대비 연간 배당의 비율을 뜻합니다.',
    'PBR': '주가가 순자산(자본) 대비 얼마나 높은지 보여줍니다.',
    'PER': '주가가 이익 대비 얼마나 높은지 보여줍니다.',
    'ROE': '자기자본 대비 이익률을 말합니다.',
    'PSR': '주가가 매출 대비 얼마나 높은지 보여줍니다.',
    '외국인 소진율': '외국인 보유 한도 대비 보유 비중입니다.',
  };

  static const Map<String, String> _metricKey = {
    '시가총액': 'market_cap',
    '배당수익률': 'dividend_yield',
    'PBR': 'pbr',
    'PER': 'per',
    'ROE': 'roe',
    'PSR': 'psr',
    '외국인 소진율': 'foreign_ownership',
  };

  @override
  void initState() {
    super.initState();
    _fetchYoY();
  }

  Future<void> _fetchYoY() async {
    try {
      final baseUrl = dotenv.env['API_BASE_URL'];
      final code = IntentResultStore.code;
      final market = IntentResultStore.market;
      if (baseUrl == null || code == null || market == null)
        throw Exception('missing params');

      final metric =
          _metricKey[widget.args.metricTitle] ?? widget.args.metricTitle;
      // 예시 API: { current: number, prev_year: number, change_pct: number }
      final uri = Uri.parse(
        '$baseUrl/api/indicator/yoy?code=$code&market=$market&metric=$metric',
      );

      final res = await http.get(uri);
      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        setState(() {
          _yoyChangePct = (json['change_pct'] as num?)?.toDouble();
          _prevYearValue =
              json['prev_year_str'] as String? ??
              _formatValue(json['prev_year']);
          _loading = false;
        });
      } else {
        setState(() => _loading = false);
      }
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  String _formatValue(dynamic v) {
    if (v == null) return 'N/A';
    final d = double.tryParse(v.toString()) ?? 0;
    if (d >= 1e12) return '${(d / 1e12).toStringAsFixed(1)}조';
    if (d >= 1e8) return '${(d / 1e8).toStringAsFixed(1)}억';
    if (d >= 1e4) return '${(d / 1e4).toStringAsFixed(1)}만';
    return d.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final title = widget.args.metricTitle;
    final value = widget.args.currentValue;

    final change = _yoyChangePct;
    final isUp = (change ?? 0) >= 0;

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      backgroundColor: cs.background,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
        children: [
          // 헤더 카드
          Container(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: cs.onSurface.withOpacity(0.12)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: tt.headlineSmall?.copyWith(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value.isEmpty ? '—' : value,
                  style: tt.displaySmall?.copyWith(
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _descriptions[title] ?? '해당 지표에 대한 설명입니다.',
                  style: tt.bodyLarge?.copyWith(
                    fontSize: 18,
                    color: cs.onBackground.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 작년 대비 변화 카드
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: cs.onSurface.withOpacity(0.12)),
            ),
            child:
                _loading
                    ? Center(
                      child: CircularProgressIndicator(
                        color: cs.onSurface,
                        strokeWidth: 2,
                      ),
                    )
                    : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '작년 대비',
                          style: tt.titleMedium?.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // 변화 요약 배지 (색맹 친화: 아이콘+텍스트)
                        Semantics(
                          label: '작년 대비 변화',
                          value:
                              (change == null)
                                  ? '데이터 없음'
                                  : (isUp ? '상승' : '하락') +
                                      ' ' +
                                      '${change!.abs().toStringAsFixed(1)}%',
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: cs.primaryContainer.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: cs.onSurface.withOpacity(0.15),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isUp
                                      ? Icons.arrow_upward_rounded
                                      : Icons.arrow_downward_rounded,
                                  size: 20,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  change == null
                                      ? 'N/A'
                                      : '${change!.abs().toStringAsFixed(1)}% ' +
                                          (isUp ? '상승' : '하락'),
                                  style: tt.labelLarge?.copyWith(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 14),
                        // 이전 값 텍스트
                        Text(
                          '작년: ${_prevYearValue ?? 'N/A'}',
                          style: tt.bodyLarge?.copyWith(
                            fontSize: 18,
                            color: cs.onBackground.withOpacity(0.85),
                          ),
                        ),

                        const SizedBox(height: 16),
                        // 간단 바 게이지(시각 보조)
                        _YoYBar(change: change),
                      ],
                    ),
          ),
        ],
      ),
    );
  }
}

class _YoYBar extends StatelessWidget {
  final double? change; // % (음수 가능)
  const _YoYBar({required this.change});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    if (change == null) {
      return Text(
        '변화 데이터를 표시할 수 없습니다.',
        style: tt.bodyMedium?.copyWith(color: cs.onBackground.withOpacity(0.7)),
      );
    }

    // -100% ~ +100% 범위로 클램프
    final v = change!.clamp(-100.0, 100.0);
    final frac = (v + 100) / 200; // 0.0..1.0, 0.5가 기준선

    return Semantics(
      label: '변화 막대',
      value: '${v.toStringAsFixed(1)}%',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          height: 14,
          child: Stack(
            children: [
              Container(color: cs.onSurface.withOpacity(0.12)),
              FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: frac, // 0~1
                child: Container(color: cs.primary.withOpacity(0.8)),
              ),
              // 중앙 기준선
              Align(
                alignment: Alignment.center,
                child: Container(width: 2, color: cs.background),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
