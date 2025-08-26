# THEME GUIDE

사용자가 지정한 테마에 따라
- Background Color
- Font Color
- Font Size (배율)

을 다르게 설정함

## <<< Background Color >>>
### BEFORE
```dart
return Scaffold(
  backgroundColor: **Color(0xFF262626)**,
  body: ...
);
```
### AFTER
```dart
return Scaffold(
  backgroundColor: **Theme.of(context).colorScheme.background**,
  body: ...
);
```

### EXAMPLE
```dart
return Scaffold(
  backgroundColor: Theme.of(context).colorScheme.background,
  body: ...
);
```

## <<< Font Color >>>
### BEFORE
```dart
Text(
  '어떤 주식을 찾으세요?',
  style: **TextStyle**(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    **color: Colors.white70,**
  ),
),
```

### AFTER
```dart
Text(
  '어떤 주식을 찾으세요?',
  style: **Theme.of(context).textTheme.titleMedium?.copyWith**(
    fontSize: 20, **// textScaleFactor가 여기에 곱해짐**
    fontWeight: FontWeight.bold,
    **// color 지우기 (테마가 fontColor 사용)**
  ),
),
```

### EXAMPLE
```dart
Text(
  '어떤 주식을 찾으세요?',
  style: Theme.of(context).textTheme.titleMedium?.copyWith(
    fontSize: 20,
    fontWeight: FontWeight.bold,
  ),
),
```

### IF - 색상을 좀 연하게 하고싶다면? 투명도 추가
```dart
color: Theme.of(
    context,
).colorScheme.onBackground.withOpacity(0.65),
```

### FontSize 이렇게 설정하세요
- 제목: 24
- 설명: 18