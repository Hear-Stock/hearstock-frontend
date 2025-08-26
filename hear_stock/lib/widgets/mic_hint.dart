import 'package:flutter/material.dart';

/// 아래로 스크롤 힌트 위젯
/// - 자체적으로 AnimationController를 관리하므로
///   부모는 TickerProvider 믹스인이 필요없습니다.
class MicHint extends StatefulWidget {
  /// 힌트 문구
  final String message;

  /// 원형 링 지름
  final double diameter;

  /// 아이콘 크기
  final double iconSize;

  /// 아이콘이 위아래로 이동하는 거리(px)
  final double travel;

  /// 애니메이션 길이
  final Duration duration;

  /// 바깥쪽 패딩
  final EdgeInsetsGeometry? padding;

  const MicHint({
    super.key,
    this.message = '아래로 스크롤하면 음성이 시작됩니다',
    this.diameter = 56,
    this.iconSize = 32,
    this.travel = 8,
    this.duration = const Duration(milliseconds: 1200),
    this.padding,
  });

  @override
  State<MicHint> createState() => _MicHintState();
}

class _MicHintState extends State<MicHint> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _dy;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration)
      ..repeat(reverse: true);

    _dy = Tween<double>(
      begin: 0,
      end: widget.travel,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));

    _opacity = Tween<double>(
      begin: 0.55,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final diameter = widget.diameter;

    return Padding(
      padding: widget.padding ?? EdgeInsets.zero,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) {
          return Opacity(
            opacity: _opacity.value,
            child: Transform.translate(
              offset: Offset(0, _dy.value),
              child: Column(
                children: [
                  Container(
                    width: diameter,
                    height: diameter,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: cs.onBackground.withOpacity(0.6),
                        width: 1.5,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: widget.iconSize,
                      color: cs.onBackground,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.message,
                    textAlign: TextAlign.center,
                    style: tt.bodyMedium?.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
