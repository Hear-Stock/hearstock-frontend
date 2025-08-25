import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// 페이지 임포트 (랜딩, 홈)
import 'landing_page.dart';
import 'pages/home/home_page.dart';
import 'pages/settings/settings_page.dart';
import 'app_settings.dart';

// 페이지 임포트
import 'pages/chart/chart_page.dart';
import 'pages/ris/ris_page.dart';
import 'pages/developer/developer_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  final settings = AppSettings();
  await settings.load();

  runApp(MyApp(settings: settings));
}

class MyApp extends StatelessWidget {
  final AppSettings settings;
  const MyApp({super.key, required this.settings});

  @override
  Widget build(BuildContext context) {
    // settings가 바뀌면 전체 앱을 리빌드
    return AnimatedBuilder(
      animation: settings,
      builder: (context, _) {
        final baseTheme = settings.toThemeData();
        final themeWithFont = baseTheme.copyWith(
          // Pretendard 적용
          textTheme: baseTheme.textTheme.apply(fontFamily: 'Pretendard'),
        );

        return MaterialApp(
          title: 'HearStock',
          theme: themeWithFont,
          // 전역 글자 배율 적용 (원래 폰트 크기 × 배율)
          builder: (context, child) {
            final media = MediaQuery.of(context);
            return MediaQuery(
              data: media.copyWith(textScaleFactor: settings.fontScale),
              child: child!,
            );
          },
          initialRoute: '/home',
          routes: {
            '/': (context) => LandingPage(),
            '/home': (context) => HomePage(),
            '/chart': (context) => ChartPage(),
            '/rsi': (context) => RsiPage(),
            '/dev': (context) => DeveloperPage(),
            '/settings':
                (context) => SettingsPage(settings: settings), // 설정 페이지
          },
        );
      },
    );
  }
}
