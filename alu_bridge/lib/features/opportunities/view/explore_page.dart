import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/widgets/empty_view.dart';
import '../bloc/discovery_bloc.dart';
import '../widgets/opportunity_card.dart';
import 'filters_sheet.dart';
import 'opportunity_detail_page.dart';

class ExplorePage extends StatelessWidget {
  const ExplorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: (query) =>
                      context.read<DiscoveryBloc>().add(DiscoverySearchChanged(query)),
                  decoration: const InputDecoration(hintText: 'Search roles or skills'),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.tune),
                onPressed: () => showModalBottomSheet<void>(
                  context: context,
                  builder: (sheetContext) => BlocProvider.value(
                    value: context.read<DiscoveryBloc>(),
                    child: const FiltersSheet(),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: BlocBuilder<DiscoveryBloc, DiscoveryState>(
            builder: (context, state) {
              if (state.status == DiscoveryStatus.loading) {
                return const Center(child: CircularProgressIndicator());
              }
              final roles = state.visible;
              if (roles.isEmpty) {
                return const EmptyView(message: 'No roles match your search yet.');
              }
              return ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: roles.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final role = roles[index];
                  return OpportunityCard(
                    opportunity: role,
                    isSaved: state.savedRoleIds.contains(role.id),
                    onSaveToggle: () =>
                        context.read<DiscoveryBloc>().add(DiscoverySaveToggled(role.id)),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => OpportunityDetailPage(opportunity: role),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
