import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/status_pill.dart';
import '../../../core/widgets/verified_badge.dart';
import '../../profile/view/settings_page.dart';
import '../models/venture.dart';

class VentureProfilePage extends StatelessWidget {
  const VentureProfilePage({required this.venture, super.key});

  final Venture venture;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          children: [
            const VerifiedBadge(size: 28),
            const SizedBox(width: 10),
            Expanded(child: Text(venture.name, style: AppTextStyles.h2)),
          ],
        ),
        if (venture.tagline.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(venture.tagline, style: AppTextStyles.sub),
        ],
        if (venture.sector.isNotEmpty) ...[
          const SizedBox(height: 12),
          StatusPill(label: venture.sector),
        ],
        if (venture.about.isNotEmpty) ...[
          const SizedBox(height: 20),
          Text('About', style: AppTextStyles.h3),
          const SizedBox(height: 8),
          Text(venture.about, style: AppTextStyles.body),
        ],
        const SizedBox(height: 24),
        OutlinedButton(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const SettingsPage()),
          ),
          style: OutlinedButton.styleFrom(foregroundColor: AppColors.navy),
          child: const Text('Account settings'),
        ),
      ],
    );
  }
}
