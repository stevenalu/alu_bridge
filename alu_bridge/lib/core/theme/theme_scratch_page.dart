import 'package:flutter/material.dart';

import '../widgets/app_text_field.dart';
import '../widgets/primary_button.dart';
import '../widgets/section_divider.dart';
import '../widgets/status_pill.dart';
import '../widgets/verified_badge.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

class ThemeScratchPage extends StatelessWidget {
  const ThemeScratchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Theme scratch')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SectionDivider(label: 'Type'),
          const SizedBox(height: 16),
          Text('Bridging students to ventures', style: AppTextStyles.h1),
          const SizedBox(height: 6),
          Text('Discover roles', style: AppTextStyles.h2),
          const SizedBox(height: 6),
          Text('Software Engineering Intern', style: AppTextStyles.h3),
          const SizedBox(height: 6),
          Text(
            'A short description of the role goes here, wrapping over a couple of lines.',
            style: AppTextStyles.body,
          ),
          const SizedBox(height: 6),
          Text('Posted 2 days ago', style: AppTextStyles.tiny),
          const SizedBox(height: 32),
          const SectionDivider(label: 'Buttons'),
          const SizedBox(height: 16),
          PrimaryButton(label: 'Apply now', onPressed: () {}),
          const SizedBox(height: 12),
          OutlinedButton(onPressed: () {}, child: const Text('Save role')),
          const SizedBox(height: 12),
          TextButton(onPressed: () {}, child: const Text('Skip for now')),
          const SizedBox(height: 32),
          const SectionDivider(label: 'Fields'),
          const SizedBox(height: 16),
          const AppTextField(label: 'Email', hintText: 'you@alustudent.com'),
          const SizedBox(height: 16),
          const AppTextField(
            label: 'Password',
            hintText: 'Minimum 8 characters',
            obscureText: true,
            errorText: 'Password is too short',
          ),
          const SizedBox(height: 32),
          const SectionDivider(label: 'Status'),
          const SizedBox(height: 16),
          const Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              StatusPill(label: 'Submitted'),
              StatusPill(label: 'Shortlisted', tone: PillTone.ok),
              StatusPill(label: 'Pending review', tone: PillTone.warn),
              StatusPill(label: 'Rejected', tone: PillTone.red),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const VerifiedBadge(),
              const SizedBox(width: 8),
              Text('Verified venture', style: AppTextStyles.body),
            ],
          ),
          const SizedBox(height: 32),
          const SectionDivider(label: 'Card spine'),
          const SizedBox(height: 16),
          const _SpineCard(color: AppColors.red, title: 'Open role'),
          const SizedBox(height: 12),
          const _SpineCard(color: AppColors.navy, title: 'Saved role'),
        ],
      ),
    );
  }
}

class _SpineCard extends StatelessWidget {
  const _SpineCard({required this.color, required this.title});

  final Color color;
  final String title;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.grey200),
          borderRadius: BorderRadius.circular(18),
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(width: 4, color: color),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(title, style: AppTextStyles.h3),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
