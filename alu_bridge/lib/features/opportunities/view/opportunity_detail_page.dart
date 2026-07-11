import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bootstrap.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/status_pill.dart';
import '../../../core/widgets/verified_badge.dart';
import '../../applications/view/apply_page.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/models/app_user.dart';
import '../data/opportunity_repository.dart';
import '../models/opportunity.dart';

class OpportunityDetailPage extends StatelessWidget {
  const OpportunityDetailPage({required this.opportunity, super.key});

  final Opportunity opportunity;

  @override
  Widget build(BuildContext context) {
    final role = context.watch<AuthBloc>().state.user?.role;
    final isFounderOwner = role == UserRole.founder;

    return Scaffold(
      appBar: AppBar(title: Text(opportunity.title)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            children: [
              if (opportunity.verified) ...[
                const VerifiedBadge(),
                const SizedBox(width: 6),
              ],
              Text(opportunity.ventureName, style: AppTextStyles.sub),
            ],
          ),
          const SizedBox(height: 8),
          Text(opportunity.title, style: AppTextStyles.h1),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              StatusPill(label: opportunity.type),
              StatusPill(label: opportunity.location),
              StatusPill(label: opportunity.commitment),
              if (opportunity.duration.isNotEmpty) StatusPill(label: opportunity.duration),
              if (opportunity.stipend.isNotEmpty) StatusPill(label: opportunity.stipend),
            ],
          ),
          const SizedBox(height: 24),
          Text('About the role', style: AppTextStyles.h3),
          const SizedBox(height: 8),
          Text(opportunity.description, style: AppTextStyles.body),
          if (opportunity.responsibilities.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text('Responsibilities', style: AppTextStyles.h3),
            const SizedBox(height: 8),
            for (final responsibility in opportunity.responsibilities)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text('•  $responsibility', style: AppTextStyles.body),
              ),
          ],
          if (opportunity.requiredSkills.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text('Required skills', style: AppTextStyles.h3),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final skill in opportunity.requiredSkills)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.navy50,
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text(skill, style: AppTextStyles.tiny.copyWith(color: AppColors.navy)),
                  ),
              ],
            ),
          ],
          const SizedBox(height: 32),
          if (isFounderOwner)
            _FounderActions(opportunity: opportunity)
          else
            PrimaryButton(
              label: 'Apply now',
              onPressed: opportunity.status == OpportunityStatus.live
                  ? () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ApplyPage(opportunity: opportunity),
                        ),
                      )
                  : null,
            ),
        ],
      ),
    );
  }
}

class _FounderActions extends StatelessWidget {
  const _FounderActions({required this.opportunity});

  final Opportunity opportunity;

  @override
  Widget build(BuildContext context) {
    final repository = sl<OpportunityRepository>();

    return Row(
      children: [
        if (opportunity.status == OpportunityStatus.draft)
          Expanded(
            child: PrimaryButton(
              label: 'Publish',
              onPressed: () {
                repository.updateStatus(opportunity.id, OpportunityStatus.live);
                Navigator.of(context).pop();
              },
            ),
          ),
        if (opportunity.status == OpportunityStatus.live)
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                repository.updateStatus(opportunity.id, OpportunityStatus.closed);
                Navigator.of(context).pop();
              },
              child: const Text('Close role'),
            ),
          ),
      ],
    );
  }
}
