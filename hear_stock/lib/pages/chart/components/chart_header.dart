import 'package:flutter/material.dart';

class ChartHeader extends StatelessWidget {
  final String headerTitle;
  final String subtitle;

  ChartHeader({required this.headerTitle, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          headerTitle,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
