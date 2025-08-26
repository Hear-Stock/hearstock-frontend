# MICHINT GUIDE

`아래로 스크롤하면 음성이 시작됩니다` 를 띄우는 애니메이션 위젯 사용 방법

## 폴더 위치
`lib/widgets/mic_hint.dart`

## 사용법
`*_page.dart`와 같은 페이지 파일 기준으로 작성
### 1. import
본인 코드 경로에 맞도록 설정
```dart
import '../../widgets/mic_hint.dart';
```

### 2. 코드 추가
들어갈 부분에 아래 코드 추가
```dart
Padding(
    padding: const EdgeInsets.symmetric(horizontal: 24),
    child: const MicHint(),
),
```