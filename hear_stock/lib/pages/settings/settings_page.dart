import 'package:flutter/material.dart';
import '../../app_settings.dart';

class SettingsPage extends StatelessWidget {
  final AppSettings settings;
  const SettingsPage({super.key, required this.settings});

  @override
  Widget build(BuildContext context) {
    final labels = <CvdPreset, String>{
      CvdPreset.defaultDark: '기본(다크)',
      CvdPreset.highContrastDark: '고대비(다크)',
      CvdPreset.protanopiaFriendly: '적색맹 친화',
      CvdPreset.deuteranopiaFriendly: '녹색맹 친화',
      CvdPreset.tritanopiaFriendly: '청색맹 친화',
      CvdPreset.monochrome: '모노크롬',
      CvdPreset.custom: '사용자 정의',
    };

    return Scaffold(
      appBar: AppBar(title: const Text('접근성 & 테마 설정')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ===== 색상 프리셋 (칩 버튼) =====
          Text('색상 프리셋', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                CvdPreset.values.map((preset) {
                  // custom은 사용자 직접 색을 고를 때 쓰이므로, 목록에는 유지(원하면 빼도 됨)
                  final selected = settings.preset == preset;
                  final swatch = _presetSwatch(preset);
                  return ChoiceChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _SwatchBox(bg: swatch.bg, fg: swatch.fg),
                        const SizedBox(width: 8),
                        Text(labels[preset] ?? preset.name),
                      ],
                    ),
                    selected: selected,
                    onSelected: (_) => settings.setPreset(preset),
                    // 접근성: 선택 상태를 명확히
                    avatar: selected ? const Icon(Icons.check, size: 18) : null,
                  );
                }).toList(),
          ),

          const SizedBox(height: 24),

          // ===== 글자 배율 =====
          Text(
            '글자 크기 배율 (${settings.fontScale.toStringAsFixed(2)}x)',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          Slider(
            value: settings.fontScale,
            min: 0.8,
            max: 1.8,
            divisions: 10,
            label: '${settings.fontScale.toStringAsFixed(2)}x',
            onChanged: settings.setFontScale,
          ),

          const SizedBox(height: 32),

          // ===== 미리보기 =====
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  '미리보기 제목',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  '이 텍스트는 현재 설정된 글자 배율과 색상으로 표시됩니다.',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 프리셋 미리보기용 색상(설정과 동일하게 맞춤)
  _PresetColors _presetSwatch(CvdPreset p) {
    switch (p) {
      case CvdPreset.defaultDark:
        return const _PresetColors(Color(0xFF262626), Color(0xFFFFFFFF));
      case CvdPreset.highContrastDark:
        return const _PresetColors(Color(0xFF000000), Color(0xFFFFFFFF));
      case CvdPreset.protanopiaFriendly:
        return const _PresetColors(Color(0xFF000000), Color(0xFF00FFFF));
      case CvdPreset.deuteranopiaFriendly:
        return const _PresetColors(Color(0xFF000000), Color(0xFFFFD700));
      case CvdPreset.tritanopiaFriendly:
        return const _PresetColors(Color(0xFF000000), Color(0xFFFF00FF));
      case CvdPreset.monochrome:
        return const _PresetColors(Color(0xFF111111), Color(0xFFEDEDED));
      case CvdPreset.custom:
        // 현재 사용자 정의값 그대로 보여주고 싶으면 settings에서 가져와도 됨
        return _PresetColors(settings.backgroundColor, settings.fontColor);
    }
  }
}

class _SwatchBox extends StatelessWidget {
  final Color bg;
  final Color fg;
  const _SwatchBox({super.key, required this.bg, required this.fg});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 26,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: fg.withOpacity(0.6), width: 1),
      ),
      alignment: Alignment.center,
      child: Text(
        'Aa',
        style: TextStyle(color: fg, fontWeight: FontWeight.w700, fontSize: 14),
      ),
    );
  }
}

class _PresetColors {
  final Color bg;
  final Color fg;
  const _PresetColors(this.bg, this.fg);
}
