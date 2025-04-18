import 'package:flutter/material.dart';

class LandingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Landing Page")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/home');
              },
              child: Text('Go to Home Page'),
            ),
            SizedBox(height: 20), // 두 버튼 사이에 여백 추가
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/chart');
              },
              child: Text('Go to Chart Page'),
            ),
          ],
        ),
      ),
    );
  }
}
