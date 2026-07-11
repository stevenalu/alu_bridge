import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class SectionDivider extends StatelessWidget {
  const SectionDivider({required this.label, super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(height: 2, color: AppColors.navy),
        const SizedBox(height: 12),
        Row(
          children: [
            Container(width: 14, height: 3, color: AppColors.red),
            const SizedBox(width: 8),
            Text(
              label.toUpperCase(),
              style: AppTextStyles.label.copyWith(letterSpacing: 2),
            ),
          ],
        ),
      ],
    );
  }
}
