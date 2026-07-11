import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bootstrap.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/primary_button.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../messaging/data/message_repository.dart';
import '../../messaging/view/chat_page.dart';
import '../../opportunities/widgets/match_chip.dart';
import '../bloc/applicants_bloc.dart';
import '../models/application.dart';
import '../models/application_status.dart';
import '../widgets/status_timeline.dart';

class ApplicantDetailPage extends StatelessWidget {
  const ApplicantDetailPage({required this.applicant, super.key});

  final Application applicant;

  bool get _canMessage => switch (applicant.status) {
        ApplicationStatus.shortlisted ||
        ApplicationStatus.interview ||
        ApplicationStatus.offer =>
          true,
        _ => false,
      };

  Future<void> _openChat(BuildContext context) async {
    final founderUid = context.read<AuthBloc>().state.user!.uid;
    try {
      final conversation = await sl<MessageRepository>().getOrCreateConversation(
        applicationId: applicant.id,
        currentUid: founderUid,
        participants: [founderUid, applicant.studentUid],
      );
      if (!context.mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ChatPage(
            conversationId: conversation.id,
            currentUid: founderUid,
            title: applicant.studentName,
          ),
        ),
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open this conversation. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(applicant.studentName)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            children: [
              Text('Match', style: AppTextStyles.label),
              const SizedBox(width: 8),
              MatchChip(percent: applicant.matchScore),
            ],
          ),
          if (applicant.studentHeadline.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(applicant.studentHeadline, style: AppTextStyles.sub),
          ],
          if (applicant.coverNote.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text('Cover note', style: AppTextStyles.h3),
            const SizedBox(height: 8),
            Text(applicant.coverNote, style: AppTextStyles.body),
          ],
          const SizedBox(height: 24),
          Text('Status', style: AppTextStyles.h3),
          const SizedBox(height: 12),
          StatusTimeline(timeline: applicant.timeline),
          const SizedBox(height: 12),
          _ActionButtons(applicant: applicant),
          if (_canMessage) ...[
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => _openChat(context),
              child: const Text('Message applicant'),
            ),
          ],
        ],
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({required this.applicant});

  final Application applicant;

  void _transition(BuildContext context, ApplicationStatus status) {
    context.read<ApplicantsBloc>().add(
          ApplicantStatusChanged(appId: applicant.id, status: status),
        );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return switch (applicant.status) {
      ApplicationStatus.submitted || ApplicationStatus.underReview => Row(
          children: [
            Expanded(
              child: PrimaryButton(
                label: 'Shortlist',
                onPressed: () => _transition(context, ApplicationStatus.shortlisted),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: () => _transition(context, ApplicationStatus.rejected),
                child: const Text('Reject'),
              ),
            ),
          ],
        ),
      ApplicationStatus.shortlisted => Row(
          children: [
            Expanded(
              child: PrimaryButton(
                label: 'Move to interview',
                onPressed: () => _transition(context, ApplicationStatus.interview),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: () => _transition(context, ApplicationStatus.rejected),
                child: const Text('Reject'),
              ),
            ),
          ],
        ),
      ApplicationStatus.interview => Row(
          children: [
            Expanded(
              child: PrimaryButton(
                label: 'Make an offer',
                onPressed: () => _transition(context, ApplicationStatus.offer),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: () => _transition(context, ApplicationStatus.rejected),
                child: const Text('Reject'),
              ),
            ),
          ],
        ),
      ApplicationStatus.offer || ApplicationStatus.rejected => const SizedBox.shrink(),
    };
  }
}
