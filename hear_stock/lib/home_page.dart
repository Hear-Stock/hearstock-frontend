import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Home Page")),
      backgroundColor: Color(0xFF262626),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '어떤 주식을 찾으세요?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFFFFFF),
              ),
            ),
            Text(
              '위로 스크롤해서 마이크를 작동시켜 물어보세요!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFFFFFF),
              ),
            ),
            Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/home-image.png',
                    width: 200.0,
                    height: 200.0,
                  ),
                  SizedBox(height: 10),
                  Text(
                    '삼성전자 주가 알고싶어',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF989898),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    '현대차 주식 보여줘',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFFFFFF),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'SK 하이닉스 차트가 궁금해',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF989898),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
