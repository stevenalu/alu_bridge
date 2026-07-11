import 'package:flutter/material.dart';

import '../../../core/routing/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../models/app_user.dart';

class RolePickerPage extends StatelessWidget {
  const RolePickerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Get started')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('How will you use ALU Bridge?', style: AppTextStyles.h2),
            const SizedBox(height: 20),
            _RoleCard(
              title: "I'm a student",
              subtitle: 'Discover and apply to internships at verified ventures.',
              onTap: () => _goToSignUp(context, UserRole.student),
            ),
            const SizedBox(height: 16),
            _RoleCard(
              title: "I'm a founder",
              subtitle: 'Post roles and hire ALU students for your venture.',
              onTap: () => _goToSignUp(context, UserRole.founder),
            ),
          ],
        ),
      ),
    );
  }

  void _goToSignUp(BuildContext context, UserRole role) {
    Navigator.of(context).pushNamed(Routes.signUp, arguments: role);
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({required this.title, required this.subtitle, required this.onTap});

  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.grey200),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.h3),
                  const SizedBox(height: 6),
                  Text(subtitle, style: AppTextStyles.sub),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.grey400),
          ],
        ),
      ),
    );
  }
}
