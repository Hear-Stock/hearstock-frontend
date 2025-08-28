import 'package:flutter/material.dart';

class DeveloperPage extends StatelessWidget {
  const DeveloperPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Developer Page")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildNavButton(context, "Landing Page", '/'),
            _buildNavButton(context, "[홈] Home Page", '/home'),
            _buildNavButton(context, "[차트] Chart Page", '/chart'),
            _buildNavButton(context, "[투자지표] RSI Page", '/rsi'),
          ],
        ),
      ),
    );
  }

  Widget _buildNavButton(BuildContext context, String title, String route) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 50), // 가로 꽉 차는 버튼
          textStyle: const TextStyle(fontSize: 16),
        ),
        onPressed: () => Navigator.pushNamed(context, route),
        child: Text(title),
      ),
    );
  }
}
