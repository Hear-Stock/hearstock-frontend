import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class RsiPage extends StatefulWidget {
  @override
  _RsiPageState createState() => _RsiPageState();
}

class _RsiPageState extends State<RsiPage> {
  final FlutterTts flutterTts = FlutterTts();

  String selectedTitle = '시가총액';
  String selectedValue = '3,444.5조원';

  final Map<String, String> indicatorValues = {
    '시가총액': '3,444.5조원',
    '배당수익률': '2.1%',
    'PBR': '1.15배',
    'PER': '12.7배',
    'ROE': '8.5%',
    'PSR': '1.3배',
  };

  final Map<String, String> indicatorSummaries = {
    '시가총액': '시가총액은 기업의 전체 시장 가치를 나타냅니다.',
    '배당수익률': '배당수익률은 주가 대비 배당금 비율을 의미합니다.',
    'PBR': 'PBR은 주가순자산비율로, 주가가 순자산에 비해 얼마나 높은지를 나타냅니다.',
    'PER': 'PER은 주가수익비율로, 기업의 수익성과 투자 매력을 나타냅니다.',
    'ROE': 'ROE는 자기자본이익률로, 기업의 수익성을 평가하는 지표입니다.',
    'PSR': 'PSR은 주가매출비율로, 매출 대비 주가의 수준을 보여줍니다.',
  };

  final List<_IndicatorItem> items = [
    _IndicatorItem(title: '시가총액', backgroundColor: Color(0xFF4A90E2)),
    _IndicatorItem(title: '배당수익률', backgroundColor: Color(0xFFFF6B6B)),
    _IndicatorItem(title: 'PBR', backgroundColor: Color(0xFF2ECC71)),
    _IndicatorItem(title: 'PER', backgroundColor: Color(0xFFFFC107)),
    _IndicatorItem(title: 'ROE', backgroundColor: Color(0xFFAF7AC5)),
    _IndicatorItem(
      title: 'PSR',
      backgroundColor: Color.fromARGB(255, 243, 182, 182),
    ),
  ];

  Future<void> _onIndicatorPressed(String title) async {
    setState(() {
      selectedTitle = title;
      selectedValue = indicatorValues[title] ?? '';
    });
    await flutterTts.speak('$title, ${indicatorValues[title]}');
  }

  Future<void> _onIndicatorLongPressed(String title) async {
    String summary = indicatorSummaries[title] ?? '$title에 대한 요약 정보입니다.';
    await flutterTts.speak(summary);
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textScale = MediaQuery.of(context).textScaleFactor;

    return Scaffold(
      backgroundColor: Color(0xff262626),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(30, 60, 30, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Semantics(
              header: true,
              child: Text(
                selectedTitle,
                style: TextStyle(
                  fontSize: 22 * textScale,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            Text(
              selectedValue,
              style: TextStyle(
                fontSize: 34 * textScale,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 30),
            Expanded(
              child: FocusTraversalGroup(
                policy: ReadingOrderTraversalPolicy(),
                child: GridView(
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 200,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                    childAspectRatio: 1.2,
                  ),
                  children:
                      items.map((item) {
                        final isSelected = item.title == selectedTitle;

                        return Semantics(
                          label:
                              '${item.title} 버튼' + (isSelected ? ', 선택됨' : ''),
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
                              onPressed: () => _onIndicatorPressed(item.title),
                              onLongPress:
                                  () => _onIndicatorLongPressed(item.title),
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
                                      padding: const EdgeInsets.only(top: 8.0),
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
                      }).toList(),
                ),
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
