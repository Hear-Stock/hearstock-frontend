import 'package:flutter/material.dart';
import '../../services/voice_scroll_handler.dart';
import '../../widgets/mic_overlay.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  bool _isMicrophoneActive = false;
  String _recognizedText = "";

  final VoiceScrollHandler _voiceScrollHandler = VoiceScrollHandler();
  final ScrollController _scrollController = ScrollController();

  late final AnimationController _arrowCtrl;
  late final Animation<double> _arrowDy; // 아래로 살짝 이동
  late final Animation<double> _arrowOpacity; // 은은한 깜빡임

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      if (_isMicrophoneActive) {
        _stopListeningManually();
      }
    });

    // 스크롤 힌트 애니메이션
    _arrowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _arrowDy = Tween<double>(
      begin: 0,
      end: 8,
    ).animate(CurvedAnimation(parent: _arrowCtrl, curve: Curves.easeInOut));

    _arrowOpacity = Tween<double>(
      begin: 0.55,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _arrowCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _arrowCtrl.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _stopListeningManually() {
    _voiceScrollHandler.stopImmediately(
      context,
      (isActive) => setState(() => _isMicrophoneActive = isActive),
    );
  }

  Future<void> _onRefresh() async {
    _voiceScrollHandler.startListening(
      context,
      onStart: (isActive) => setState(() => _isMicrophoneActive = isActive),
      onResult: (text) => setState(() => _recognizedText = text),
      onEnd: (isActive) => setState(() => _isMicrophoneActive = isActive),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: cs.background,
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: _onRefresh,
            child: ListView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                // 상단 히어로 영역
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 36, 24, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 24 크기 타이틀
                      Text(
                        '어떤 주식을 찾으세요?',
                        style: tt.headlineSmall?.copyWith(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // 18 크기 서브 타이틀
                      // Text(
                      //   '아래로 스크롤해서 마이크를 작동시켜 물어보세요!',
                      //   style: tt.titleMedium?.copyWith(
                      //     fontSize: 18,
                      //     fontWeight: FontWeight.w600,
                      //     color: cs.onBackground.withOpacity(0.9),
                      //   ),
                      // ),
                    ],
                  ),
                ),

                // 안내 카드 (풀다운 설명 + 아이콘)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _HintCard(),
                ),

                const SizedBox(height: 24),

                // 스크롤 힌트 애니메이션
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Center(
                    child: AnimatedBuilder(
                      animation: _arrowCtrl,
                      builder: (context, _) {
                        return Opacity(
                          opacity: _arrowOpacity.value,
                          child: Transform.translate(
                            offset: Offset(0, _arrowDy.value),
                            child: Column(
                              children: [
                                Container(
                                  width: 56,
                                  height: 56,
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
                                    size: 32,
                                    color: cs.onBackground,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  '아래로 스크롤하면 음성이 시작됩니다',
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
                  ),
                ),

                const SizedBox(height: 24),

                // 추천 문장 (칩 스타일)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: [
                      _QueryChip(text: '삼성전자 주가 알고싶어'),
                      _QueryChip(text: '현대차 주식 보여줘'),
                      _QueryChip(text: 'SK 하이닉스 차트가 궁금해'),
                    ],
                  ),
                ),

                const SizedBox(height: 48),
              ],
            ),
          ),

          if (_isMicrophoneActive)
            MicOverlay(
              recognizedText: _recognizedText,
              onStop: _stopListeningManually,
            ),
        ],
      ),
    );
  }
}

/* ------------------------------- UI 파츠 ------------------------------- */

class _HintCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.onSurface.withOpacity(0.12)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: cs.onSurface.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.mic_none_rounded, size: 24),
            alignment: Alignment.center,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '두 손가락으로 아래로 스와이프하면 마이크가 켜집니다.',
              style: tt.bodyMedium?.copyWith(fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }
}

class _QueryChip extends StatelessWidget {
  final String text;
  final bool emphasized; // 하나 정도는 Filled 느낌

  const _QueryChip({required this.text, this.emphasized = false});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(24),
    );
    final pad = const EdgeInsets.symmetric(horizontal: 14, vertical: 10);

    if (emphasized) {
      // 전역 FilledButton 테마 사용
      return FilledButton(
        onPressed: () {},
        style: FilledButton.styleFrom(shape: shape, padding: pad),
        child: Text(text, style: tt.labelLarge?.copyWith(fontSize: 18)),
      );
    }

    // 나머지는 Outlined로 가볍게
    return OutlinedButton(
      onPressed: () {},
      style: OutlinedButton.styleFrom(
        shape: shape,
        padding: pad,
        side: BorderSide(color: cs.onBackground.withOpacity(0.25)),
      ),
      child: Text(
        text,
        style: tt.labelLarge?.copyWith(
          fontSize: 18,
          color: cs.onBackground.withOpacity(0.9),
        ),
      ),
    );
  }
}
