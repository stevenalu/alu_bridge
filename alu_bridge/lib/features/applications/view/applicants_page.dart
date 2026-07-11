import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/extensions/date_extensions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/empty_view.dart';
import '../../../core/widgets/loading_list.dart';
import '../../../core/widgets/status_pill.dart';
import '../../opportunities/widgets/match_chip.dart';
import '../bloc/applicants_bloc.dart';
import '../models/application.dart';
import '../models/application_status.dart';
import 'applicant_detail_page.dart';

enum _Stage { newApplicant, shortlist, interview, hired, rejected }

extension on _Stage {
  String get label => switch (this) {
        _Stage.newApplicant => 'New',
        _Stage.shortlist => 'Shortlist',
        _Stage.interview => 'Interview',
        _Stage.hired => 'Hired',
        _Stage.rejected => 'Rejected',
      };

  List<ApplicationStatus> get statuses => switch (this) {
        _Stage.newApplicant => [ApplicationStatus.submitted, ApplicationStatus.underReview],
        _Stage.shortlist => [ApplicationStatus.shortlisted],
        _Stage.interview => [ApplicationStatus.interview],
        _Stage.hired => [ApplicationStatus.offer],
        _Stage.rejected => [ApplicationStatus.rejected],
      };
}

class ApplicantsPage extends StatefulWidget {
  const ApplicantsPage({super.key});

  @override
  State<ApplicantsPage> createState() => _ApplicantsPageState();
}

class _ApplicantsPageState extends State<ApplicantsPage> {
  _Stage _stage = _Stage.newApplicant;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Wrap(
            spacing: 8,
            children: [
              for (final stage in _Stage.values)
                ChoiceChip(
                  label: Text(stage.label),
                  selected: _stage == stage,
                  onSelected: (_) => setState(() => _stage = stage),
                ),
            ],
          ),
        ),
        Expanded(
          child: BlocBuilder<ApplicantsBloc, ApplicantsState>(
            builder: (context, state) {
              if (state.status == ApplicantsStatus.loading) {
                return const LoadingList();
              }
              final applicants =
                  state.applications.where((a) => _stage.statuses.contains(a.status)).toList();
              if (applicants.isEmpty) {
                return const EmptyView(message: 'No applicants here yet.');
              }
              return ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: applicants.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final applicant = applicants[index];
                  return _ApplicantTile(applicant: applicant);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ApplicantTile extends StatelessWidget {
  const _ApplicantTile({required this.applicant});

  final Application applicant;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => ApplicantDetailPage(applicant: applicant)),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.grey200),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(applicant.studentName, style: AppTextStyles.h3)),
                MatchChip(percent: applicant.matchScore),
              ],
            ),
            if (applicant.studentHeadline.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(applicant.studentHeadline, style: AppTextStyles.sub),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                StatusPill(label: applicant.status.label),
                const SizedBox(width: 8),
                Text('Applied ${applicant.createdAt.shortDate}', style: AppTextStyles.tiny),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
