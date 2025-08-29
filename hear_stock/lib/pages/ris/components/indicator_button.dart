// pages/ris/components/indicator_button.dart
import 'package:flutter/material.dart';

class IndicatorButton extends StatelessWidget {
  final String title;
  final bool selected;
  final VoidCallback onPressed;
  final VoidCallback onLongPressed;

  const IndicatorButton({
    super.key,
    required this.title,
    required this.selected,
    required this.onPressed,
    required this.onLongPressed,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    );
    const minSize = Size(double.infinity, 64);
    const pad = EdgeInsets.symmetric(horizontal: 16, vertical: 14);

    // ✅ 양쪽 상태에서 동일한 레이아웃 사용 (텍스트는 좌측, 아이콘은 우측)
    //    선택 해제 시에도 아이콘 공간을 유지해 텍스트 흔들림 방지
    final rowChild = Row(
      children: [
        Expanded(
          child: Text(
            title,
            // 색은 버튼의 foregroundColor에 맡긴다 (직접 color 지정 X)
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Visibility(
          visible: selected,
          maintainSize: true,
          maintainAnimation: true,
          maintainState: true,
          child: const Icon(Icons.check_circle, size: 20),
        ),
      ],
    );

    if (selected) {
      return SizedBox(
        width: double.infinity,
        child: FilledButton(
          onPressed: onPressed,
          onLongPress: onLongPressed,
          style: FilledButton.styleFrom(
            minimumSize: minSize,
            padding: pad,
            shape: shape,
            // 색 지정하지 않음 → 전역 FilledButtonTheme 사용
          ),
          child: rowChild,
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        onLongPress: onLongPressed,
        style: OutlinedButton.styleFrom(
          minimumSize: minSize,
          padding: pad,
          shape: shape,
          side: BorderSide(color: cs.onSurface.withOpacity(0.35), width: 1.4),
        ),
        child: rowChild, // ← 비선택도 동일한 Row 사용
      ),
    );
  }
}
