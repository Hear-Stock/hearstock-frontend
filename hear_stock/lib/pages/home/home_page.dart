import 'package:flutter/material.dart';
import '../../services/voice_scroll_handler.dart';
import '../../widgets/mic_overlay.dart';
import '../../widgets/mic_hint.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isMicrophoneActive = false;
  String _recognizedText = "";

  final VoiceScrollHandler _voiceScrollHandler = VoiceScrollHandler();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      if (_isMicrophoneActive) {
        _stopListeningManually();
      }
    });
  }

  @override
  void dispose() {
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
                  child: const MicHint(), // 기본 문구/사이즈 사용
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

          // 테마 설정 버튼 (톱니바퀴 아이콘)
          if (!_isMicrophoneActive)
            Positioned(
              right: 16,
              bottom: 24,
              child: SafeArea(
                child: SettingsBar(
                  onOpenSettings:
                      () => Navigator.of(context).pushNamed('/settings'),
                  themeMode:
                      Theme.of(context).brightness == Brightness.dark
                          ? ThemeMode.dark
                          : ThemeMode.light, // 예: 현재 모드 추정 (앱 전역 상태에 맞게 바꿔주세요)
                  onThemeChanged: (mode) {
                    // TODO: 앱 전역 상태(Provider/Bloc/GetX 등)로 연결해 실제 테마 변경
                    // ex) context.read<AppTheme>().setThemeMode(mode);
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/* ------------------------------- UI 파츠 ------------------------------- */

class SettingsBar extends StatelessWidget {
  final VoidCallback onOpenSettings;
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeChanged;

  const SettingsBar({
    super.key,
    required this.onOpenSettings,
    required this.themeMode,
    required this.onThemeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    IconData themeIcon;
    String themeLabel;
    switch (themeMode) {
      case ThemeMode.system:
        themeIcon = Icons.brightness_auto_rounded;
        themeLabel = '시스템';
        break;
      case ThemeMode.light:
        themeIcon = Icons.wb_sunny_rounded;
        themeLabel = '라이트';
        break;
      case ThemeMode.dark:
        themeIcon = Icons.nightlight_round_rounded;
        themeLabel = '다크';
        break;
    }

    return Material(
      color: cs.surface.withOpacity(0.72),
      elevation: 2,
      shape: const StadiumBorder(),
      clipBehavior: Clip.antiAlias,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 왼쪽: 설정
          _PillButton(
            tooltip: '테마 변경',
            icon: Icons.settings_outlined,
            label: '테마',
            onTap: onOpenSettings,
          ),

          // 구분선
          Container(
            width: 1,
            height: 24,
            color: cs.onSurface.withOpacity(0.12),
          ),

          // 오른쪽: 테마 토글 (system → light → dark 순환)
          _PillButton(
            tooltip: '모드 변경',
            icon: themeIcon,
            label: themeLabel,
            onTap:
                () => Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil('/', (route) => false),
          ),
        ],
      ),
    );
  }

  ThemeMode _nextTheme(ThemeMode m) {
    switch (m) {
      case ThemeMode.system:
        return ThemeMode.light;
      case ThemeMode.light:
        return ThemeMode.dark;
      case ThemeMode.dark:
        return ThemeMode.system;
    }
  }
}

class _PillButton extends StatelessWidget {
  final String tooltip;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _PillButton({
    required this.tooltip,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      child: Tooltip(
        message: tooltip,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Icon(icon, size: 20, color: cs.onSurface.withOpacity(0.92)),
              const SizedBox(width: 6),
              Text(
                label,
                style: tt.labelLarge?.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface.withOpacity(0.9),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
