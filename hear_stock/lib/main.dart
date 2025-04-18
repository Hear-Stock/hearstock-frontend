import 'package:flutter/material.dart';
import 'landing_page.dart';
import 'home_page.dart';

void main() {
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
      },
    );
  }
}
