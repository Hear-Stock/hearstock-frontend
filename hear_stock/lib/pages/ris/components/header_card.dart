// pages/ris/components/header_card.dart
import 'package:flutter/material.dart';

class HeaderCard extends StatelessWidget {
  final String title;
  final String value;
  final String semanticsLabelValue;

  /// 탭 시 동작 (없으면 비활성)
  final VoidCallback? onTap;

  /// 하단 '자세히 보기' 힌트를 노출할지 여부 (기본 true)
  final bool showSeeMore;

  const HeaderCard({
    super.key,
    required this.title,
    required this.value,
    required this.semanticsLabelValue,
    this.onTap,
    this.showSeeMore = true,
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
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),
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

                  // 하단 ‘자세히 보기’ 힌트 (onTap 있을 때만 노출)
                  if (onTap != null && showSeeMore) ...[
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: _SeeMore(onTap: onTap!),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 오른쪽 아래 ‘자세히 보기’ 텍스트+아이콘(테마 프라이머리 색)
class _SeeMore extends StatelessWidget {
  final VoidCallback onTap;
  const _SeeMore({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Tooltip(
      message: '자세히 보기',
      child: TextButton.icon(
        onPressed: onTap,
        icon: Icon(Icons.chevron_right_rounded, color: cs.primary),
        label: Text(
          '자세히 보기',
          style: tt.labelLarge?.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: cs.primary,
          ),
        ),
        style: TextButton.styleFrom(
          // 버튼 자체 여백을 조금 줄여 카드 내에서 과하지 않게
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          minimumSize: const Size(0, 0),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
        ),
      ),
    );
  }
}
