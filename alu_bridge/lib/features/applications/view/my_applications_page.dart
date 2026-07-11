import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/extensions/date_extensions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/empty_view.dart';
import '../../../core/widgets/loading_list.dart';
import '../../../core/widgets/status_pill.dart';
import '../../opportunities/widgets/match_chip.dart';
import '../bloc/applications_bloc.dart';
import '../models/application.dart';
import '../models/application_status.dart';
import 'application_detail_page.dart';

class MyApplicationsPage extends StatelessWidget {
  const MyApplicationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ApplicationsBloc, ApplicationsState>(
      builder: (context, state) {
        if (state.status == ApplicationsStatus.loading) {
          return const LoadingList();
        }
        if (state.applications.isEmpty) {
          return const EmptyView(message: 'You have not applied to any roles yet.');
        }
        return ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: state.applications.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final application = state.applications[index];
            return _ApplicationTile(application: application);
          },
        );
      },
    );
  }
}

class _ApplicationTile extends StatelessWidget {
  const _ApplicationTile({required this.application});

  final Application application;

  PillTone get _tone => switch (application.status) {
        ApplicationStatus.rejected => PillTone.red,
        ApplicationStatus.offer || ApplicationStatus.shortlisted => PillTone.ok,
        ApplicationStatus.interview => PillTone.warn,
        _ => PillTone.neutral,
      };

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ApplicationDetailPage(application: application),
        ),
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
                Expanded(child: Text(application.oppTitle, style: AppTextStyles.h3)),
                MatchChip(percent: application.matchScore),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                StatusPill(label: application.status.label, tone: _tone),
                const SizedBox(width: 8),
                Text('Applied ${application.createdAt.shortDate}', style: AppTextStyles.tiny),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
