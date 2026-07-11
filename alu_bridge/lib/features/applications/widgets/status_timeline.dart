import 'package:flutter/material.dart';

import '../../../core/extensions/date_extensions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../models/application.dart';
import '../models/application_status.dart';

class StatusTimeline extends StatelessWidget {
  const StatusTimeline({required this.timeline, super.key});

  final List<TimelineEntry> timeline;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < timeline.length; i++)
          _TimelineRow(entry: timeline[i], isLast: i == timeline.length - 1),
      ],
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({required this.entry, required this.isLast});

  final TimelineEntry entry;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(color: AppColors.navy, shape: BoxShape.circle),
              ),
              if (!isLast) Expanded(child: Container(width: 2, color: AppColors.grey200)),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(entry.status.label, style: AppTextStyles.h3),
                  const SizedBox(height: 2),
                  Text(entry.at.shortDateTime, style: AppTextStyles.tiny),
                  if (entry.note != null && entry.note!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(entry.note!, style: AppTextStyles.sub),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
