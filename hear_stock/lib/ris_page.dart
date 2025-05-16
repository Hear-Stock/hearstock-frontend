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

  final List<_IndicatorItem> items = [
    _IndicatorItem(title: '시가총액', color: Colors.red),
    _IndicatorItem(title: '배당수익률', color: Colors.yellow),
    _IndicatorItem(title: 'PBR', color: Colors.green),
    _IndicatorItem(title: 'PER', color: Colors.blue),
    _IndicatorItem(title: 'ROE', color: Colors.white),
    _IndicatorItem(title: 'PSR', color: Colors.pink),
  ];

  Future<void> _onIndicatorPressed(String title) async {
    setState(() {
      selectedTitle = title;
      selectedValue = indicatorValues[title] ?? '';
    });

    await flutterTts.speak('$title, ${indicatorValues[title]}');
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF262626),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(30, 60, 30, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              selectedTitle,
              style: TextStyle(
                fontSize: 22,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              selectedValue,
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 30),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                childAspectRatio: 1.2,
                children:
                    items.map((item) {
                      return Semantics(
                        label: '${item.title} 버튼',
                        button: true,
                        child: GestureDetector(
                          onTap: () => _onIndicatorPressed(item.title),
                          child: Container(
                            decoration: BoxDecoration(
                              color: item.color,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: EdgeInsets.all(16),
                            child: Center(
                              child: Text(
                                item.title,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color:
                                      (item.color == Colors.yellow ||
                                              item.color == Colors.white)
                                          ? Colors.black
                                          : Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
              ),
            ),
            SizedBox(height: 10),
            Center(
              child: Text(
                '위로 스크롤해서 마이크를 작동시키세요.',
                style: TextStyle(color: Colors.white, fontSize: 15),
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
  final Color color;

  _IndicatorItem({required this.title, required this.color});
}
