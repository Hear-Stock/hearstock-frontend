# THEME GUIDE

사용자가 지정한 테마에 따라

- Background Color
- Font Color
- Font Size (배율)

을 다르게 설정함

## 1. Background Color
### 1-1. BEFORE
```dart
return Scaffold(
  backgroundColor: Color(0xFF262626),
  body: ...
);
```
### 1-2. AFTER
- backgroundColor 뒤에 수정
```dart
return Scaffold(
  backgroundColor: Theme.of(context).colorScheme.background,
  body: ...
);
```

## 2. Font Color
### 2-1. BEFORE
```dart
Text(
  '어떤 주식을 찾으세요?',
  style: TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: Colors.white70,
  ),
),
```

### 2-2. AFTER
- style 뒤에 수정
- style 안의 color 삭제
```dart
Text(
  '어떤 주식을 찾으세요?',
  style: Theme.of(context).textTheme.titleMedium?.copyWith(
    fontSize: 20,
    fontWeight: FontWeight.bold,
  ),
),
```

### 2-3. IF - 색상을 좀 연하게 하고싶다면? 투명도 추가
```dart
color: Theme.of(
    context,
).colorScheme.onBackground.withOpacity(0.65),
```

### 2-4. FontSize 이렇게 설정하세요
- 제목: 24
- 설명: 18

## 3. Button Color
이건 사실 나도 왜 되는지 모름

```dart
// 선택되었을 때 (FilledButton)
if (selected) {
  return FilledButton(
    onPressed: () => onTimelineChanged(timeline),
    style: FilledButton.styleFrom(padding: pad, shape: shape),
    child: Text(
      timeline,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    ),
  );
}
// 외곽 버튼 (OutlinedButton)
return OutlinedButton(
  onPressed: () => onTimelineChanged(timeline),
  style: OutlinedButton.styleFrom(padding: pad, shape: shape),
  child: Text(timeline, style: const TextStyle(fontSize: 16)),
);
```