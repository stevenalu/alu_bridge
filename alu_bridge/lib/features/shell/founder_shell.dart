import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bootstrap.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/section_divider.dart';
import '../../core/widgets/status_pill.dart';
import '../../core/widgets/verified_badge.dart';
import '../auth/bloc/auth_bloc.dart';
import '../auth/bloc/auth_event.dart';
import '../opportunities/data/opportunity_repository.dart';
import '../opportunities/models/opportunity.dart';
import '../opportunities/view/manage_roles_page.dart';
import '../opportunities/view/post_role_page.dart';
import '../ventures/cubit/venture_cubit.dart';
import '../ventures/data/venture_repository.dart';
import '../ventures/models/venture.dart';
import '../ventures/view/verification_pending_page.dart';
import '../ventures/view/verify_venture_page.dart';

class FounderShell extends StatefulWidget {
  const FounderShell({super.key});

  @override
  State<FounderShell> createState() => _FounderShellState();
}

class _FounderShellState extends State<FounderShell> {
  int _index = 0;
  late final VentureCubit _ventureCubit;

  static const _tabs = ['Dashboard', 'Roles', 'Applicants', 'Messages', 'Venture'];
  static const _icons = [
    Icons.dashboard_outlined,
    Icons.work_outline,
    Icons.groups_outlined,
    Icons.chat_bubble_outline,
    Icons.storefront_outlined,
  ];

  @override
  void initState() {
    super.initState();
    final uid = context.read<AuthBloc>().state.user!.uid;
    _ventureCubit = VentureCubit(
      ventureRepository: sl<VentureRepository>(),
      founderUid: uid,
    );
  }

  @override
  void dispose() {
    _ventureCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _ventureCubit,
      child: Scaffold(
        backgroundColor: AppColors.navy50,
        appBar: AppBar(
          title: Text(_tabs[_index]),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () =>
                  context.read<AuthBloc>().add(const AuthSignOutRequested()),
            ),
          ],
        ),
        body: switch (_index) {
          0 => const _DashboardTab(),
          1 => BlocBuilder<VentureCubit, VentureState>(
              builder: (context, state) {
                final venture = state.venture;
                if (venture == null) {
                  return const Center(child: CircularProgressIndicator());
                }
                return ManageRolesPage(venture: venture);
              },
            ),
          _ => Center(child: Text(_tabs[_index])),
        },
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (index) => setState(() => _index = index),
          backgroundColor: Colors.white,
          indicatorColor: AppColors.navy100,
          destinations: [
            for (var i = 0; i < _tabs.length; i++)
              NavigationDestination(icon: Icon(_icons[i]), label: _tabs[i]),
          ],
        ),
      ),
    );
  }
}

class _DashboardTab extends StatelessWidget {
  const _DashboardTab();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VentureCubit, VentureState>(
      builder: (context, state) {
        if (state.status == VentureStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        final venture = state.venture;
        if (venture == null) {
          return _StatusCard(
            icon: Icons.storefront_outlined,
            title: 'Get your venture verified',
            message: 'Only verified ALU ventures can post roles for students.',
            action: PrimaryButton(
              label: 'Get verified',
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const VerifyVenturePage()),
              ),
            ),
          );
        }

        if (!venture.isVerified) {
          final rejected = venture.verification.status == VerificationStatus.rejected;
          return _StatusCard(
            icon: rejected ? Icons.error_outline : Icons.hourglass_top,
            title: rejected ? 'Verification rejected' : 'Verification pending',
            message: rejected
                ? 'Your submission was not approved. Review and resubmit your details.'
                : 'We are reviewing your venture. This usually takes a couple of days.',
            pill: StatusPill(
              label: rejected ? 'Rejected' : 'Pending review',
              tone: rejected ? PillTone.red : PillTone.warn,
            ),
            action: PrimaryButton(
              label: 'View status',
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => VerificationPendingPage(founderUid: venture.founderUid),
                ),
              ),
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.grey200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const VerifiedBadge(size: 32),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(venture.name, style: AppTextStyles.h2),
                            if (venture.tagline.isNotEmpty)
                              Text(venture.tagline, style: AppTextStyles.sub),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (venture.sector.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    StatusPill(label: venture.sector),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
            const SectionDivider(label: 'Overview'),
            const SizedBox(height: 16),
            StreamBuilder<List<Opportunity>>(
              stream: sl<OpportunityRepository>().watchByVenture(venture.id),
              builder: (context, snapshot) {
                final roles = snapshot.data ?? const <Opportunity>[];
                final live = roles.where((r) => r.status == OpportunityStatus.live).length;
                final drafts =
                    roles.where((r) => r.status == OpportunityStatus.draft).length;
                final applicants =
                    roles.fold<int>(0, (sum, r) => sum + r.applicantCount);
                return Row(
                  children: [
                    Expanded(child: _StatTile(label: 'Live roles', value: '$live')),
                    const SizedBox(width: 12),
                    Expanded(child: _StatTile(label: 'Drafts', value: '$drafts')),
                    const SizedBox(width: 12),
                    Expanded(child: _StatTile(label: 'Applicants', value: '$applicants')),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              label: 'Post a new role',
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => PostRolePage(venture: venture)),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        children: [
          Text(value, style: AppTextStyles.h1.copyWith(fontSize: 22)),
          const SizedBox(height: 4),
          Text(label, style: AppTextStyles.tiny),
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.icon,
    required this.title,
    required this.message,
    required this.action,
    this.pill,
  });

  final IconData icon;
  final String title;
  final String message;
  final Widget? pill;
  final Widget action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.grey200),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 40, color: AppColors.navy),
              const SizedBox(height: 16),
              Text(title, style: AppTextStyles.h2, textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text(message, style: AppTextStyles.sub, textAlign: TextAlign.center),
              if (pill != null) ...[const SizedBox(height: 12), pill!],
              const SizedBox(height: 20),
              action,
            ],
          ),
        ),
      ),
    );
  }
}
