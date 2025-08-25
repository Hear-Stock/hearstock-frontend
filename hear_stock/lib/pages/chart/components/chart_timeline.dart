import 'package:flutter/material.dart';

class ChartTimeline extends StatelessWidget {
  final String selectedTimeline;
  final ValueChanged<String> onTimelineChanged;

  const ChartTimeline({
    super.key,
    required this.selectedTimeline,
    required this.onTimelineChanged,
  });

  @override
  Widget build(BuildContext context) {
    final items = <String>['1달', '3달', '1년', '5년', '10년'];

    return Column(
      children: [
        // 실시간 버튼(디자인 통일, 필요 시 onPressed 구현)
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          child: FilledButton(
            onPressed: () {},
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('실시간', style: TextStyle(fontSize: 18)),
          ),
        ),
        const SizedBox(height: 16),

        Wrap(
          spacing: 6,
          runSpacing: 6,
          alignment: WrapAlignment.center,
          children: items.map((t) => _buildItem(context, t)).toList(),
        ),
      ],
    );
  }

  Widget _buildItem(BuildContext context, String timeline) {
    final selected = selectedTimeline == timeline;
    final pad = const EdgeInsets.symmetric(horizontal: 12, vertical: 8);
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
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
    }
    return OutlinedButton(
      onPressed: () => onTimelineChanged(timeline),
      style: OutlinedButton.styleFrom(padding: pad, shape: shape),
      child: Text(timeline, style: const TextStyle(fontSize: 16)),
    );
  }
}
