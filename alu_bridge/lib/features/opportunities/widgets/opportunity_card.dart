import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/verified_badge.dart';
import '../models/opportunity.dart';

class OpportunityCard extends StatelessWidget {
  const OpportunityCard({
    required this.opportunity,
    required this.isSaved,
    required this.onTap,
    required this.onSaveToggle,
    super.key,
  });

  final Opportunity opportunity;
  final bool isSaved;
  final VoidCallback onTap;
  final VoidCallback onSaveToggle;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Material(
        color: Colors.white,
        child: InkWell(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.grey200),
              borderRadius: BorderRadius.circular(18),
            ),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  Container(width: 4, color: isSaved ? AppColors.navy : AppColors.red),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              if (opportunity.verified) ...[
                                const VerifiedBadge(),
                                const SizedBox(width: 6),
                              ],
                              Expanded(
                                child: Text(
                                  opportunity.ventureName,
                                  style: AppTextStyles.tiny,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                icon: Icon(
                                  isSaved ? Icons.bookmark : Icons.bookmark_outline,
                                  color: isSaved ? AppColors.navy : AppColors.grey400,
                                ),
                                onPressed: onSaveToggle,
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            opportunity.title.isEmpty ? 'Untitled role' : opportunity.title,
                            style: AppTextStyles.h3,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              _Tag(opportunity.type),
                              _Tag(opportunity.location),
                              _Tag(opportunity.commitment),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    if (label.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(label, style: AppTextStyles.tiny),
    );
  }
}
