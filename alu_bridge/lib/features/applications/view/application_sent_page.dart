import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/primary_button.dart';
import '../../opportunities/widgets/match_chip.dart';
import '../models/application.dart';

class ApplicationSentPage extends StatelessWidget {
  const ApplicationSentPage({required this.application, super.key});

  final Application application;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle, size: 56, color: AppColors.ok),
              const SizedBox(height: 20),
              Text('Application sent!', style: AppTextStyles.h1, textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text(
                'Your application to ${application.oppTitle} is on its way. '
                'Track its status from the Applications tab.',
                style: AppTextStyles.sub,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              MatchChip(percent: application.matchScore),
              const SizedBox(height: 32),
              PrimaryButton(
                label: 'Back to exploring',
                onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
