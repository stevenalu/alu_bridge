import 'package:flutter/material.dart';

import '../../../core/theme/app_text_styles.dart';
import '../../opportunities/widgets/match_chip.dart';
import '../models/application.dart';
import '../widgets/status_timeline.dart';

class ApplicationDetailPage extends StatelessWidget {
  const ApplicationDetailPage({required this.application, super.key});

  final Application application;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(application.oppTitle)),
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
        ],
      ),
    );
  }
}
