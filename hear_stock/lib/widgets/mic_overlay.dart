import 'dart:ui';
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
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Positioned.fill(
      child: Stack(
        children: [
          // 반투명 배경
          Container(color: cs.scrim.withOpacity(0.65)),
          // 글래스 효과를 위한 블러
          Positioned.fill(
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                child: const SizedBox.expand(),
              ),
            ),
          ),

          // 내용 카드
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
                  decoration: BoxDecoration(
                    color: cs.surface.withOpacity(0.92),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: cs.onSurface.withOpacity(0.10)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 제목 24
                      Text(
                        '음성 대화 중',
                        style: tt.headlineSmall?.copyWith(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: cs.onSurface,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 마이크 아이콘 + 링
                      _MicBadge(),

                      const SizedBox(height: 16),

                      // 부제 18
                      Text(
                        '듣고 있어요',
                        style: tt.titleMedium?.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: cs.onSurface,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // 인식된 텍스트 영역
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: cs.surfaceVariant.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: cs.onSurface.withOpacity(0.08),
                          ),
                        ),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: Text(
                            // AnimatedSwitcher가 child 변경을 감지하도록 key 부여
                            '인식된 텍스트: $recognizedText',
                            key: ValueKey(recognizedText),
                            style: tt.bodyLarge?.copyWith(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: cs.onSurface,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // 그만두기 (위험 동작 → error 팔레트 사용)
                      FilledButton.icon(
                        onPressed: onStop,
                        icon: const Icon(Icons.stop_rounded, size: 28),
                        label: const Text('그만두기'),
                        style: FilledButton.styleFrom(
                          backgroundColor: cs.error,
                          foregroundColor: cs.onError,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 22,
                            vertical: 14,
                          ),
                          textStyle: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 마이크 원형 배지: 테마 포그라운드 색으로 링을 만들고 중앙에 아이콘 배치
class _MicBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Stack(
      alignment: Alignment.center,
      children: [
        // 바깥 링 (그라디언트)
        Container(
          width: 128,
          height: 128,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: SweepGradient(
              colors: [
                cs.primary.withOpacity(0.85),
                cs.secondary.withOpacity(0.85),
                cs.primary.withOpacity(0.85),
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        ),
        // 안쪽 써클 (배경)
        Container(
          width: 112,
          height: 112,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: cs.surface,
            border: Border.all(color: cs.onSurface.withOpacity(0.08)),
            boxShadow: [
              BoxShadow(
                color: cs.primary.withOpacity(0.25),
                blurRadius: 18,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Icon(Icons.mic_rounded, size: 56, color: cs.onSurface),
        ),
      ],
    );
  }
}
