import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum CvdPreset {
  defaultDark,
  highContrastDark,
  protanopiaFriendly,
  deuteranopiaFriendly,
  tritanopiaFriendly,
  monochrome,
  custom,
}

class AppSettings extends ChangeNotifier {
  // 전역으로 쓸 값
  Color backgroundColor;
  Color fontColor;
  double fontScale;
  CvdPreset preset;

  AppSettings({
    this.backgroundColor = const Color(0xFF262626),
    this.fontColor = Colors.white,
    this.fontScale = 1.0,
    this.preset = CvdPreset.defaultDark,
  });

  // ---- Persistence ----
  static const _kBg = 'bgColor';
  static const _kFont = 'fontColor';
  static const _kScale = 'fontScale';
  static const _kPreset = 'presetIndex';

  Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    backgroundColor = Color(p.getInt(_kBg) ?? const Color(0xFF262626).value);
    fontColor = Color(p.getInt(_kFont) ?? Colors.white.value);
    fontScale = p.getDouble(_kScale) ?? 1.0;
    final pi = p.getInt(_kPreset) ?? CvdPreset.defaultDark.index;
    preset = CvdPreset.values[pi];
    notifyListeners();
  }

  Future<void> _save() async {
    final p = await SharedPreferences.getInstance();
    await p.setInt(_kBg, backgroundColor.value);
    await p.setInt(_kFont, fontColor.value);
    await p.setDouble(_kScale, fontScale);
    await p.setInt(_kPreset, preset.index);
  }

  // ---- Update APIs ----
  void setFontScale(double scale) {
    fontScale = scale.clamp(0.8, 1.8);
    _save();
    notifyListeners();
  }

  void setCustomColors(Color bg, Color font) {
    backgroundColor = bg;
    fontColor = font;
    preset = CvdPreset.custom;
    _save();
    notifyListeners();
  }

  void setPreset(CvdPreset p) {
    preset = p;
    switch (p) {
      case CvdPreset.defaultDark:
        backgroundColor = const Color(0xFF262626);
        fontColor = const Color(0xFFFFFFFF);
        break;
      case CvdPreset.highContrastDark:
        backgroundColor = const Color(0xFF000000);
        fontColor = const Color(0xFFFFFFFF);
        break;
      case CvdPreset.protanopiaFriendly:
        backgroundColor = const Color(0xFF000000);
        fontColor = const Color(0xFF00ffff);
        break;
      case CvdPreset.deuteranopiaFriendly:
        backgroundColor = const Color(0xFF000000);
        fontColor = const Color(0xFFffd700);
        break;
      case CvdPreset.tritanopiaFriendly:
        backgroundColor = const Color(0xFF000000);
        fontColor = const Color(0xFFff00ff);
        break;
      case CvdPreset.monochrome:
        backgroundColor = const Color(0xFF111111);
        fontColor = const Color(0xFFEDEDED);
        break;
      case CvdPreset.custom:
        // 유지
        break;
    }
    _save();
    notifyListeners();
  }

  // 현재 설정으로 ThemeData 만들기
  ThemeData toThemeData() {
    final base = ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      scaffoldBackgroundColor: backgroundColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.teal,
        brightness: Brightness.dark,
        background: backgroundColor,
        onBackground: fontColor,
        surface: backgroundColor,
        onSurface: fontColor,
        primary: fontColor, // 기본 위젯 대비 확보용
        onPrimary: backgroundColor,
      ),
    );
    return base.copyWith(
      textTheme: base.textTheme.apply(
        bodyColor: fontColor,
        displayColor: fontColor,
      ),
    );
  }
}
