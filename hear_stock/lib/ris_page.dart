import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RsiPage extends StatefulWidget {
  const RsiPage({Key? key}) : super(key: key);

  @override
  _RsiPageState createState() => _RsiPageState();
}

class _RsiPageState extends State<RsiPage> {
  Map<String, String> indicatorValues = {
    '시가총액': '',
    '배당수익률': '',
    'PBR': '',
    'PER': '',
    'ROE': '',
    'PSR': '',
    '외국인 소진율': '',
  };

  String selectedTitle = '시가총액';

  final List<_IndicatorItem> items = [
    _IndicatorItem(title: '시가총액', backgroundColor: Color(0xFF4A90E2)),
    _IndicatorItem(title: '배당수익률', backgroundColor: Color(0xFFFF6B6B)),
    _IndicatorItem(title: 'PBR', backgroundColor: Color(0xFF2ECC71)),
    _IndicatorItem(title: 'PER', backgroundColor: Color(0xFFFFC107)),
    _IndicatorItem(title: 'ROE', backgroundColor: Color(0xFFAF7AC5)),
    _IndicatorItem(title: 'PSR', backgroundColor: Color(0xFFF3B6B6)),
    _IndicatorItem(title: '외국인 소진율', backgroundColor: Color(0xFF80DEEA)),
  ];

  @override
  void initState() {
    super.initState();
    fetchIndicatorValues(code: '005930', market: 'KR');
  }

  Future<void> fetchIndicatorValues({
    required String code,
    required String market,
  }) async {
    final queryParameters = {'code': code, 'market': market};
    final uri = Uri.http(
      '39.126.141.8:8000',
      '/api/indicator/',
      queryParameters,
    );

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          indicatorValues['시가총액'] = _formatValue(data['market_cap'], unit: '원');
          indicatorValues['배당수익률'] = '${data['dividend_yield']}%';
          indicatorValues['PBR'] = '${data['pbr']}배';
          indicatorValues['PER'] = '${data['per']}배';
          indicatorValues['ROE'] = '${data['roe']}%';
          indicatorValues['PSR'] = '${data['psr']}배';

          if (data.containsKey('foreign_ownership')) {
            indicatorValues['외국인 소진율'] = '${data['foreign_ownership']}%';
          } else {
            indicatorValues['외국인 소진율'] = 'N/A';
          }

          // 초기 선택값 지정
          selectedTitle = '시가총액';
        });
      } else {
        setState(() {
          indicatorValues.updateAll((key, value) => '불러오기 실패');
        });
      }
    } catch (e) {
      setState(() {
        indicatorValues.updateAll((key, value) => '에러 발생');
      });
    }
  }

  String _formatValue(dynamic raw, {String unit = ''}) {
    if (raw == null) return '-';
    try {
      final numValue = double.parse(raw.toString());
      if (numValue >= 1e12)
        return '${(numValue / 1e12).toStringAsFixed(1)}조$unit';
      if (numValue >= 1e8)
        return '${(numValue / 1e8).toStringAsFixed(1)}억$unit';
      return '$numValue$unit';
    } catch (_) {
      return '$raw$unit';
    }
  }

  void _onIndicatorPressed(String title) {
    setState(() {
      selectedTitle = title;
    });
  }

  @override
  Widget build(BuildContext context) {
    final textScale = MediaQuery.of(context).textScaleFactor;

    return Scaffold(
      backgroundColor: Color(0xff262626),
      appBar: AppBar(title: const Text('투자지표')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              selectedTitle,
              style: TextStyle(
                fontSize: 22 * textScale,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 8),
            Text(
              indicatorValues[selectedTitle] ?? '-',
              style: TextStyle(
                fontSize: 34 * textScale,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 24),
            Expanded(
              child: GridView(
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 200,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  childAspectRatio: 1.2,
                ),
                children:
                    items
                        .where(
                          (item) => indicatorValues.containsKey(item.title),
                        )
                        .map((item) {
                          final isSelected = item.title == selectedTitle;
                          return Semantics(
                            label:
                                '${item.title} 버튼${isSelected ? ', 선택됨' : ''}',
                            button: true,
                            selected: isSelected,
                            child: Tooltip(
                              message: '${item.title} 선택',
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: item.backgroundColor,
                                  foregroundColor: Color(0xff262626),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    side: BorderSide(
                                      color:
                                          isSelected
                                              ? Colors.white
                                              : Colors.transparent,
                                      width: 3,
                                    ),
                                  ),
                                ),
                                onPressed:
                                    () => _onIndicatorPressed(item.title),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      item.title,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 22 * textScale,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    if (isSelected)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          top: 8.0,
                                        ),
                                        child: Icon(
                                          Icons.check_circle,
                                          size: 20 * textScale,
                                          color: Colors.white,
                                          semanticLabel: '선택됨',
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        })
                        .toList(),
              ),
            ),
            SizedBox(height: 10),
            Center(
              child: Text(
                '아래로 스크롤해서 마이크를 작동시키세요.',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 15 * textScale,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IndicatorItem {
  final String title;
  final Color backgroundColor;

  _IndicatorItem({required this.title, required this.backgroundColor});
}
