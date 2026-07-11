import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// Shows how well a student's skills overlap with a role's required skills.
/// The percentage itself is computed once per application in the
/// applications feature (Milestone 11) and stored on the application record.
class MatchChip extends StatelessWidget {
  const MatchChip({required this.percent, super.key});

  final int percent;

  @override
  Widget build(BuildContext context) {
    final Color color = switch (percent) {
      >= 70 => AppColors.ok,
      >= 40 => AppColors.warn,
      _ => AppColors.grey600,
    };
    final Color background = switch (percent) {
      >= 70 => AppColors.ok50,
      >= 40 => AppColors.warn50,
      _ => AppColors.grey100,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(99)),
      child: Text('$percent% match', style: AppTextStyles.tiny.copyWith(color: color)),
    );
  }
}
