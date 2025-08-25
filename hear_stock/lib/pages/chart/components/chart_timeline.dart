import 'package:flutter/material.dart';

class ChartTimeline extends StatelessWidget {
  final String selectedTimeline; // 현재 선택된 시간
  final ValueChanged<String> onTimelineChanged; // 버튼 클릭 시 상태 변경 함수

  const ChartTimeline({
    super.key,
    required this.selectedTimeline,
    required this.onTimelineChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 상단 메인 버튼: 전역 FilledButton 테마 그대로 사용
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          child: FilledButton(
            onPressed: () {},
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: const Text('실시간', style: TextStyle(fontSize: 18)),
          ),
        ),
        const SizedBox(height: 20),

        // 타임라인 선택 버튼 그룹
        Wrap(
          spacing: 4,
          runSpacing: 4,
          alignment: WrapAlignment.center,
          children:
              <String>[
                '3달',
                '1년',
                '5년',
                '10년',
              ].map((t) => _buildTimelineButton(context, t)).toList(),
        ),
      ],
    );
  }

  // 선택 상태에 따라 Filled / Outlined로 분기
  Widget _buildTimelineButton(BuildContext context, String timeline) {
    final selected = selectedTimeline == timeline;
    final pad = const EdgeInsets.symmetric(horizontal: 10, vertical: 6);
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(6),
    );

    if (selected) {
      return FilledButton(
        onPressed: () => onTimelineChanged(timeline),
        style: FilledButton.styleFrom(padding: pad, shape: shape),
        child: Text(
          timeline,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      );
    } else {
      return OutlinedButton(
        onPressed: () => onTimelineChanged(timeline),
        style: OutlinedButton.styleFrom(padding: pad, shape: shape),
        child: Text(timeline, style: const TextStyle(fontSize: 16)),
      );
    }
  }
}
