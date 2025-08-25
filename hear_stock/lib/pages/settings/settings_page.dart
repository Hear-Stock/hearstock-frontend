import 'package:flutter/material.dart';
import '../../app_settings.dart';

class SettingsPage extends StatelessWidget {
  final AppSettings settings;
  const SettingsPage({super.key, required this.settings});

  @override
  Widget build(BuildContext context) {
    final presets = {
      CvdPreset.defaultDark: '기본(다크)',
      CvdPreset.highContrastDark: '고대비(다크)',
      CvdPreset.protanopiaFriendly: 'Protanopia 친화',
      CvdPreset.deuteranopiaFriendly: 'Deuteranopia 친화',
      CvdPreset.tritanopiaFriendly: 'Tritanopia 친화',
      CvdPreset.monochrome: '모노크롬',
      CvdPreset.custom: '사용자 정의',
    };

    return Scaffold(
      appBar: AppBar(title: const Text('접근성 & 테마 설정')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 프리셋
          Text('색상 프리셋', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          DropdownButton<CvdPreset>(
            value: settings.preset,
            isExpanded: true,
            onChanged: (v) {
              if (v != null) settings.setPreset(v);
            },
            items:
                presets.entries.map((e) {
                  return DropdownMenuItem(value: e.key, child: Text(e.value));
                }).toList(),
          ),
          const SizedBox(height: 24),

          // 글자 배율
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
          const SizedBox(height: 24),

          // 커스텀 색 빠르게 선택 (프리셋=custom으로 전환)
          Text('빠른 색상 선택', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _colorChip(context, '라이트', Colors.white, Colors.black),
              _colorChip(context, '다크', const Color(0xFF262626), Colors.white),
              _colorChip(context, '초고대비', Colors.black, Colors.white),
              _colorChip(
                context,
                '따뜻한 톤',
                const Color(0xFF1C1C1C),
                const Color(0xFFFFF3E0),
              ),
              _colorChip(
                context,
                '차가운 톤',
                const Color(0xFF1E1E24),
                const Color(0xFFE6F1FF),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // 미리보기
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
                Text('이 텍스트는 현재 설정된 글자 배율과 색상으로 표시됩니다.'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _colorChip(BuildContext context, String label, Color bg, Color font) {
    return ActionChip(
      label: Text(label),
      onPressed: () => settings.setCustomColors(bg, font),
      backgroundColor: bg,
      labelStyle: TextStyle(color: font, fontWeight: FontWeight.w700),
      shape: StadiumBorder(side: BorderSide(color: font.withOpacity(0.4))),
    );
  }
}
