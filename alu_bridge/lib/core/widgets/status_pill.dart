import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

enum PillTone { neutral, ok, warn, red }

class StatusPill extends StatelessWidget {
  const StatusPill({required this.label, this.tone = PillTone.neutral, super.key});

  final String label;
  final PillTone tone;

  @override
  Widget build(BuildContext context) {
    final (Color bg, Color fg) = switch (tone) {
      PillTone.ok => (AppColors.ok50, AppColors.ok),
      PillTone.warn => (AppColors.warn50, AppColors.warn),
      PillTone.red => (AppColors.red50, AppColors.red),
      PillTone.neutral => (AppColors.grey100, AppColors.grey600),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(99)),
      child: Text(label, style: AppTextStyles.tiny.copyWith(color: fg)),
    );
  }
}
