// pages/ris/components/indicator_list.dart
import 'package:flutter/material.dart';
import 'indicator_button.dart';

class IndicatorList extends StatelessWidget {
  final List<String> titles;
  final String selectedTitle;
  final ValueChanged<String> onPressed;
  final ValueChanged<String> onLongPressed;

  const IndicatorList({
    super.key,
    required this.titles,
    required this.selectedTitle,
    required this.onPressed,
    required this.onLongPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children:
          titles.map((title) {
            final selected = title == selectedTitle;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Semantics(
                label: '$title 버튼',
                hint: '탭하면 값을 읽어주고, 길게 누르면 설명을 읽어줍니다.',
                button: true,
                selected: selected,
                child: Focus(
                  autofocus: selected,
                  child: IndicatorButton(
                    title: title,
                    selected: selected,
                    onPressed: () => onPressed(title),
                    onLongPressed: () => onLongPressed(title),
                  ),
                ),
              ),
            );
          }).toList(),
    );
  }
}
