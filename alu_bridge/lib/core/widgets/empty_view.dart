import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class EmptyView extends StatelessWidget {
  const EmptyView({required this.message, this.icon = Icons.inbox_outlined, super.key});

  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 40, color: AppColors.grey400),
            const SizedBox(height: 12),
            Text(message, style: AppTextStyles.sub, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
