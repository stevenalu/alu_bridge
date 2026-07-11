import 'package:flutter/material.dart';

import '../../../bootstrap.dart';
import '../../../core/widgets/empty_view.dart';
import '../../ventures/models/venture.dart';
import '../data/opportunity_repository.dart';
import '../models/opportunity.dart';
import '../widgets/opportunity_card.dart';
import 'opportunity_detail_page.dart';
import 'post_role_page.dart';

class ManageRolesPage extends StatefulWidget {
  const ManageRolesPage({required this.venture, super.key});

  final Venture venture;

  @override
  State<ManageRolesPage> createState() => _ManageRolesPageState();
}

class _ManageRolesPageState extends State<ManageRolesPage> {
  OpportunityStatus _filter = OpportunityStatus.live;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: 8,
                  children: [
                    for (final status in OpportunityStatus.values)
                      ChoiceChip(
                        label: Text(_label(status)),
                        selected: _filter == status,
                        onSelected: (_) => setState(() => _filter = status),
                      ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => PostRolePage(venture: widget.venture),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<List<Opportunity>>(
            stream: sl<OpportunityRepository>().watchByVenture(widget.venture.id),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final roles =
                  snapshot.data!.where((o) => o.status == _filter).toList();
              if (roles.isEmpty) {
                return const EmptyView(message: 'No roles here yet.');
              }
              return ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: roles.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final role = roles[index];
                  return OpportunityCard(
                    opportunity: role,
                    isSaved: false,
                    onSaveToggle: () {},
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

  String _label(OpportunityStatus status) => switch (status) {
        OpportunityStatus.live => 'Live',
        OpportunityStatus.draft => 'Drafts',
        OpportunityStatus.closed => 'Closed',
      };
}
