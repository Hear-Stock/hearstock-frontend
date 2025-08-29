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
    final tt = Theme.of(context).textTheme;

    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    );
    const minSize = Size(double.infinity, 64); // 가로 꽉 + 충분한 터치 타깃
    const pad = EdgeInsets.symmetric(horizontal: 16, vertical: 14);

    final label = Text(
      title,
      style: tt.titleMedium?.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w800,
      ),
    );

    final trailing = Icon(
      Icons.check_circle,
      size: 22,
      color: selected ? cs.onPrimary : cs.onSurface.withOpacity(0.4),
      semanticLabel: selected ? '선택됨' : null,
    );

    final child = Row(
      children: [
        Expanded(child: label),
        if (selected) trailing, // 선택시에만 강조 아이콘
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
          ),
          child: child,
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
        child: child,
      ),
    );
  }
}
