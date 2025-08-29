// pages/ris/components/header_card.dart
import 'package:flutter/material.dart';

class HeaderCard extends StatelessWidget {
  final String title;
  final String value;
  final String semanticsLabelValue;

  /// 탭 시 동작 (없으면 비활성)
  final VoidCallback? onTap;

  const HeaderCard({
    super.key,
    required this.title,
    required this.value,
    required this.semanticsLabelValue,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final radius = BorderRadius.circular(12);

    return Semantics(
      container: true,
      header: true,
      liveRegion: true, // 값 변화를 보이스오버가 쉽게 인지
      label: semanticsLabelValue,
      button: onTap != null, // 스크린리더에 "버튼"으로 노출
      onTapHint: onTap != null ? '자세히 보기' : null,
      child: Container(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: radius,
          border: Border.all(color: cs.onSurface.withOpacity(0.12)),
        ),
        child: Material(
          color: Colors.transparent, // InkWell 리플 보이도록
          child: InkWell(
            borderRadius: radius,
            onTap: onTap, // ← 탭 시 콜백
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 제목 24
                  Text(
                    title,
                    style: tt.headlineSmall?.copyWith(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // 값 34
                  Text(
                    value.isEmpty ? '—' : value,
                    style: tt.displaySmall?.copyWith(
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                      color: cs.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
