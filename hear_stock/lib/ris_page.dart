import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class RsiPage extends StatefulWidget {
  @override
  _RsiPageState createState() => _RsiPageState();
}

class _RsiPageState extends State<RsiPage> {
  final FlutterTts flutterTts = FlutterTts();

  String selectedTitle = '';
  String selectedValue = '';

  final Map<String, String> indicatorValues = {
    '시가총액': '',
    '배당수익률': '',
    'PBR': '',
    'PER': '',
    'ROE': '',
    'PSR': '',
  };

  final List<_IndicatorItem> items = [
    _IndicatorItem(title: '시가총액', backgroundColor: Color(0xFF4A90E2)),
    _IndicatorItem(title: '배당수익률', backgroundColor: Color(0xFFFF6B6B)),
    _IndicatorItem(title: 'PBR', backgroundColor: Color(0xFF2ECC71)),
    _IndicatorItem(title: 'PER', backgroundColor: Color(0xFFFFC107)),
    _IndicatorItem(title: 'ROE', backgroundColor: Color(0xFFAF7AC5)),
    _IndicatorItem(title: 'PSR', backgroundColor: Color(0xFFF3B6B6)),
  ];

  final String apiUrl = 'http://localhost:8000/api/indicator/';

  Future<String> fetchSummaryFromApi(String title) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'indicator_name': title}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['summary'] ?? '$title에 대한 요약 정보가 없습니다.';
      } else {
        return '$title 정보를 불러오는 데 실패했습니다. (${response.statusCode})';
      }
    } catch (e) {
      return '요약 정보를 가져오는 중 오류가 발생했습니다.';
    }
  }

  Future<void> _onIndicatorPressed(String title) async {
    setState(() {
      selectedTitle = title;
      selectedValue = indicatorValues[title] ?? '';
    });
    await flutterTts.speak('$title, ${indicatorValues[title] ?? ""}');
  }

  Future<void> _onIndicatorLongPressed(String title) async {
    String summary = await fetchSummaryFromApi(title);
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
                selectedTitle.isNotEmpty ? selectedTitle : '지표를 선택하세요',
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
