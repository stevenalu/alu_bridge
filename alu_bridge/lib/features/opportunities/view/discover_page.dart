import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/empty_view.dart';
import '../bloc/discovery_bloc.dart';
import '../widgets/opportunity_card.dart';
import 'opportunity_detail_page.dart';

class DiscoverPage extends StatelessWidget {
  const DiscoverPage({super.key});

  static const _previewCount = 5;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DiscoveryBloc, DiscoveryState>(
      builder: (context, state) {
        if (state.status == DiscoveryStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        final roles = state.opportunities.take(_previewCount).toList();
        if (roles.isEmpty) {
          return const EmptyView(message: 'No live roles yet. Check back soon.');
        }
        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text('Latest roles', style: AppTextStyles.h2),
            const SizedBox(height: 16),
            for (final role in roles) ...[
              OpportunityCard(
                opportunity: role,
                isSaved: state.savedRoleIds.contains(role.id),
                onSaveToggle: () =>
                    context.read<DiscoveryBloc>().add(DiscoverySaveToggled(role.id)),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => OpportunityDetailPage(opportunity: role),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ],
        );
      },
    );
  }
}
