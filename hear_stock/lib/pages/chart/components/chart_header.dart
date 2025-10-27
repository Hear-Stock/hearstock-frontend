import 'package:flutter/material.dart';

class ChartHeader extends StatelessWidget {
  final String headerTitle;
  final String subtitle;

  const ChartHeader({
    super.key,
    required this.headerTitle,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          headerTitle,
          style: tt.headlineSmall?.copyWith(
            fontSize: 24,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: tt.titleMedium?.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: cs.onBackground.withOpacity(0.9),
          ),
        ),
      ],
    );
  }
}
