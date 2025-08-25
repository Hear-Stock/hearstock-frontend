import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// 페이지 임포트 (랜딩, 홈)
import 'landing_page.dart';
import 'home_page.dart';

// 페이지 임포트
import 'pages/chart/chart_page.dart';
import 'pages/ris/ris_page.dart';
import 'pages/developer/developer_page.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // 기본 폰트 Pretendard로 설정
      theme: ThemeData(fontFamily: "Pretendard"),
      // 초기 화면: LandingPage
      initialRoute: '/home',
      routes: {
        '/': (context) => LandingPage(),
        '/home': (context) => HomePage(),
        '/chart': (context) => ChartPage(),
        '/rsi': (context) => RsiPage(),
        '/dev': (context) => DeveloperPage(),
      },
    );
  }
}
