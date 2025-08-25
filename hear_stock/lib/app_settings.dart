import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 색각(또는 대비) 프리셋 목록.
/// - `custom`은 사용자가 임의로 지정한 색 구성을 의미함.
enum CvdPreset {
  defaultDark,
  highContrastDark,
  protanopiaFriendly,
  deuteranopiaFriendly,
  tritanopiaFriendly,
  monochrome,
  custom,
}

/// 앱 전역 테마/접근성 설정 저장소.
/// - 배경색/글자색/폰트 배율/버튼 색 등을 보관하고 변경 시 `notifyListeners()`로 앱 전체에 반영.
/// - `SharedPreferences`를 통해 디스크에 영구 저장/로드.
class AppSettings extends ChangeNotifier {
  /* --------------------------------------------------------------------------
   * 상태 필드 (전역에서 사용)
   * ------------------------------------------------------------------------ */

  /// 화면 전반의 배경색 (Scaffold 등)
  Color backgroundColor;

  /// 기본 텍스트 색상 (onBackground에 해당)
  Color fontColor;

  /// 전역 글자 배율 (MaterialApp.builder에서 MediaQuery.textScaleFactor로 반영)
  double fontScale;

  /// 현재 선택된 색상 프리셋
  CvdPreset preset;

  /// 버튼 배경색 (Elevated/Filled 등)
  Color buttonBgColor;

  /// 버튼 글자색 (버튼 텍스트/아이콘)
  Color buttonFgColor;

  /* --------------------------------------------------------------------------
   * 생성자
   * ------------------------------------------------------------------------ */

  AppSettings({
    this.backgroundColor = const Color(0xFF262626),
    this.fontColor = Colors.white,
    this.fontScale = 1.0,
    this.preset = CvdPreset.defaultDark,
    // 버튼 색은 기본적으로 "밝은 배경 + 어두운 글자" 조합
    Color? buttonBgColor,
    Color? buttonFgColor,
  }) : buttonBgColor = buttonBgColor ?? Colors.white,
       buttonFgColor = buttonFgColor ?? const Color(0xFF262626);

  /* --------------------------------------------------------------------------
   * 영구 저장 키 (SharedPreferences)
   * ------------------------------------------------------------------------ */

  static const _kBg = 'bgColor';
  static const _kFont = 'fontColor';
  static const _kScale = 'fontScale';
  static const _kPreset = 'presetIndex';
  static const _kBtnBg = 'buttonBgColor';
  static const _kBtnFg = 'buttonFgColor';

  /* --------------------------------------------------------------------------
   * 로드 / 저장
   * ------------------------------------------------------------------------ */

  /// 디스크에서 설정을 로드하여 현재 인스턴스에 반영.
  /// 존재하지 않는 값은 합리적인 기본값으로 대체.
  Future<void> load() async {
    final p = await SharedPreferences.getInstance();

    backgroundColor = Color(p.getInt(_kBg) ?? const Color(0xFF262626).value);
    fontColor = Color(p.getInt(_kFont) ?? Colors.white.value);
    fontScale = p.getDouble(_kScale) ?? 1.0;

    final pi = p.getInt(_kPreset) ?? CvdPreset.defaultDark.index;
    preset = CvdPreset.values[pi];

    // 버튼 색은 저장된 값이 없으면 "폰트색/배경색을 반전"하는 기본값 사용
    buttonBgColor = Color(p.getInt(_kBtnBg) ?? fontColor.value);
    buttonFgColor = Color(p.getInt(_kBtnFg) ?? backgroundColor.value);

    notifyListeners();
  }

  /// 현재 설정을 디스크에 저장 (비공개 유틸).
  Future<void> _save() async {
    final p = await SharedPreferences.getInstance();
    await p.setInt(_kBg, backgroundColor.value);
    await p.setInt(_kFont, fontColor.value);
    await p.setDouble(_kScale, fontScale);
    await p.setInt(_kPreset, preset.index);
    await p.setInt(_kBtnBg, buttonBgColor.value);
    await p.setInt(_kBtnFg, buttonFgColor.value);
  }

  /* --------------------------------------------------------------------------
   * 공개 업데이트 API (설정 변경 시 반드시 notify)
   * ------------------------------------------------------------------------ */

  /// 전역 폰트 배율 변경 (0.8~1.8 범위로 클램프)
  void setFontScale(double scale) {
    fontScale = scale.clamp(0.8, 1.8);
    _save();
    notifyListeners();
  }

  /// 사용자 정의 배경/글자색 지정.
  /// - 버튼 색은 기본적으로 배경/글자 반전 조합을 적용.
  /// - 프리셋은 `custom`으로 전환.
  void setCustomColors(Color bg, Color font) {
    backgroundColor = bg;
    fontColor = font;
    buttonBgColor = font; // 가독성 위해 반전 조합
    buttonFgColor = bg;
    preset = CvdPreset.custom;
    _save();
    notifyListeners();
  }

  /// 버튼 색을 개별적으로 지정.
  void setButtonColors(Color bg, Color fg) {
    buttonBgColor = bg;
    buttonFgColor = fg;
    _save();
    notifyListeners();
  }

  /// 버튼 배경만 주면, 글자색은 배경의 명도에 따라 자동(검정/흰색) 결정.
  void setButtonBgAuto(Color bg) {
    final on = _autoOnColor(bg);
    setButtonColors(bg, on);
  }

  /// 간단한 대비 로직: 배경이 밝으면 검정, 어두우면 흰색.
  /// 필요 시 WCAG 대비 계산으로 고도화 가능.
  Color _autoOnColor(Color bg) {
    return bg.computeLuminance() > 0.5 ? Colors.black : Colors.white;
  }

  /// 프리셋 지정.
  /// - 배경/글자/버튼 색을 해당 프리셋의 권장 조합으로 설정.
  void setPreset(CvdPreset p) {
    preset = p;
    switch (p) {
      case CvdPreset.defaultDark:
        backgroundColor = const Color(0xFF262626);
        fontColor = const Color(0xFFFFFFFF);
        buttonBgColor = const Color(0xFF4E9BFF);
        buttonFgColor = Colors.white;
        break;

      case CvdPreset.highContrastDark:
        backgroundColor = const Color(0xFF000000);
        fontColor = const Color(0xFFFFFFFF);
        buttonBgColor = Colors.white;
        buttonFgColor = Colors.black;
        break;

      case CvdPreset.protanopiaFriendly:
        backgroundColor = const Color(0xFF000000);
        fontColor = const Color(0xFF00FFFF);
        buttonBgColor = const Color(0xFF00B8D4); // 청록 계열
        buttonFgColor = Colors.black;
        break;

      case CvdPreset.deuteranopiaFriendly:
        backgroundColor = const Color(0xFF000000);
        fontColor = const Color(0xFFFFD700);
        buttonBgColor = const Color(0xFFFFD54F); // 따뜻한 노랑
        buttonFgColor = Colors.black;
        break;

      case CvdPreset.tritanopiaFriendly:
        backgroundColor = const Color(0xFF000000);
        fontColor = const Color(0xFFFF00FF);
        buttonBgColor = const Color(0xFFB388FF); // 보라 계열
        buttonFgColor = Colors.black;
        break;

      case CvdPreset.monochrome:
        backgroundColor = const Color(0xFF111111);
        fontColor = const Color(0xFFEDEDED);
        buttonBgColor = const Color(0xFFDDDDDD);
        buttonFgColor = Colors.black;
        break;

      case CvdPreset.custom:
        // 사용자 지정 값 유지
        break;
    }
    _save();
    notifyListeners();
  }

  /* --------------------------------------------------------------------------
   * ThemeData 생성
   *  - Material3 기반의 전역 테마를 생성해 MaterialApp.theme에 연결.
   *  - 버튼류(Filled/Outlined/Elevated/Text)는 아래 ButtonTheme들로 일괄 제어.
   * ------------------------------------------------------------------------ */

  /// 현재 설정값으로부터 `ThemeData`를 생성.
  ThemeData toThemeData() {
    // 1) 기본 테마 + 컬러 스킴 구성
    final base = ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      scaffoldBackgroundColor: backgroundColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.teal, // 포커스/리플 등 보조 용도
        brightness: Brightness.dark,
        background: backgroundColor,
        onBackground: fontColor,
        surface: backgroundColor,
        onSurface: fontColor,
        // 버튼 색은 아래 ButtonTheme들에서 오버라이드하므로 primary는 보조적
        primary: fontColor,
        onPrimary: backgroundColor,
      ),
    );

    // 2) 버튼 테마 (앱 전체 일관 스타일)
    final elevated = ElevatedButtonThemeData(
      style: ButtonStyle(
        minimumSize: const MaterialStatePropertyAll(Size(48, 44)),
        backgroundColor: MaterialStatePropertyAll(buttonBgColor),
        foregroundColor: MaterialStatePropertyAll(buttonFgColor),
        overlayColor: MaterialStatePropertyAll(buttonFgColor.withOpacity(0.08)),
        shape: MaterialStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        textStyle: const MaterialStatePropertyAll(
          TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );

    final filled = FilledButtonThemeData(
      style: ButtonStyle(
        minimumSize: const MaterialStatePropertyAll(Size(48, 44)),
        backgroundColor: MaterialStatePropertyAll(buttonBgColor),
        foregroundColor: MaterialStatePropertyAll(buttonFgColor),
        overlayColor: MaterialStatePropertyAll(buttonFgColor.withOpacity(0.08)),
        shape: MaterialStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        textStyle: const MaterialStatePropertyAll(
          TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );

    final outlined = OutlinedButtonThemeData(
      style: ButtonStyle(
        minimumSize: const MaterialStatePropertyAll(Size(48, 44)),
        foregroundColor: MaterialStatePropertyAll(buttonBgColor), // 텍스트/아이콘
        side: MaterialStatePropertyAll(
          BorderSide(color: buttonBgColor, width: 1.2),
        ),
        overlayColor: MaterialStatePropertyAll(buttonBgColor.withOpacity(0.08)),
        shape: MaterialStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        textStyle: const MaterialStatePropertyAll(
          TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );

    final textBtn = TextButtonThemeData(
      style: ButtonStyle(
        minimumSize: const MaterialStatePropertyAll(Size(36, 40)),
        foregroundColor: MaterialStatePropertyAll(buttonBgColor), // 텍스트 컬러
        overlayColor: MaterialStatePropertyAll(buttonBgColor.withOpacity(0.12)),
        textStyle: const MaterialStatePropertyAll(
          TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );

    // 3) 최종 ThemeData 반환 (텍스트 색 적용 + 버튼 테마 바인딩)
    return base.copyWith(
      textTheme: base.textTheme.apply(
        bodyColor: fontColor,
        displayColor: fontColor,
      ),
      elevatedButtonTheme: elevated,
      filledButtonTheme: filled,
      outlinedButtonTheme: outlined,
      textButtonTheme: textBtn,
    );
  }
}
