import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bootstrap.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/primary_button.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../messaging/data/message_repository.dart';
import '../../messaging/view/chat_page.dart';
import '../../opportunities/widgets/match_chip.dart';
import '../../ventures/data/venture_repository.dart';
import '../models/application.dart';
import '../models/application_status.dart';
import '../widgets/status_timeline.dart';

class ApplicationDetailPage extends StatelessWidget {
  const ApplicationDetailPage({required this.application, super.key});

  final Application application;

  bool get _canMessage => switch (application.status) {
        ApplicationStatus.shortlisted ||
        ApplicationStatus.interview ||
        ApplicationStatus.offer =>
          true,
        _ => false,
      };

  Future<void> _openChat(BuildContext context) async {
    final studentUid = context.read<AuthBloc>().state.user!.uid;
    try {
      final venture = await sl<VentureRepository>().fetchById(application.ventureId);
      if (venture == null) {
        throw StateError('Venture not found');
      }

      final conversation = await sl<MessageRepository>().getOrCreateConversation(
        applicationId: application.id,
        currentUid: studentUid,
        participants: [studentUid, venture.founderUid],
      );
      if (!context.mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ChatPage(
            conversationId: conversation.id,
            currentUid: studentUid,
            title: venture.name,
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
      appBar: AppBar(title: Text(application.displayTitle)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            children: [
              Text('Your match', style: AppTextStyles.label),
              const SizedBox(width: 8),
              MatchChip(percent: application.matchScore),
            ],
          ),
          if (application.coverNote.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text('Your cover note', style: AppTextStyles.h3),
            const SizedBox(height: 8),
            Text(application.coverNote, style: AppTextStyles.body),
          ],
          const SizedBox(height: 24),
          Text('Status', style: AppTextStyles.h3),
          const SizedBox(height: 12),
          StatusTimeline(timeline: application.timeline),
          if (_canMessage) ...[
            const SizedBox(height: 12),
            PrimaryButton(
              label: 'Message venture',
              onPressed: () => _openChat(context),
            ),
          ],
        ],
      ),
    );
  }
}
