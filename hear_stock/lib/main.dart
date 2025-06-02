import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'landing_page.dart';
import 'home_page.dart';
import 'chartPage/chart_page.dart';
import 'ris_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  print(dotenv.env['API_BASE_URL']);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // 기본 폰트 Pretendard로 설정
      theme: ThemeData(fontFamily: "Pretendard"),
      // 초기 화면: LandingPage
      initialRoute: '/',
      routes: {
        '/': (context) => LandingPage(),
        '/home': (context) => HomePage(),
        '/chart': (context) => ChartPage(),
        '/ris': (context) => RsiPage(),
      },
    );
  }
}
