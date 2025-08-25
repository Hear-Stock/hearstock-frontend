import 'package:flutter/material.dart';

class MicOverlay extends StatelessWidget {
  final String recognizedText;
  final VoidCallback onStop;

  const MicOverlay({
    super.key,
    required this.recognizedText,
    required this.onStop,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.9),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '음성 대화 중',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontSize: 18),
            ),
            SizedBox(height: 20),
            Icon(Icons.mic, size: 100, color: Colors.white),
            SizedBox(height: 20),
            Text(
              '듣고 있어요',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              '인식된 텍스트: $recognizedText',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: onStop,
              icon: Icon(Icons.stop, size: 32),
              label: Text(
                "그만두기",
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontSize: 18),
              ),
              style: ElevatedButton.styleFrom(
                shape: CircleBorder(),
                padding: EdgeInsets.all(50),
                backgroundColor: Colors.redAccent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
