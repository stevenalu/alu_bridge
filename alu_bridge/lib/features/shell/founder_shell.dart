import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bootstrap.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/status_pill.dart';
import '../../core/widgets/verified_badge.dart';
import '../auth/bloc/auth_bloc.dart';
import '../auth/bloc/auth_event.dart';
import '../opportunities/view/manage_roles_page.dart';
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
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Get your venture verified',
                  style: AppTextStyles.h2,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Only verified ALU ventures can post roles.',
                  style: AppTextStyles.sub,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                PrimaryButton(
                  label: 'Get verified',
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const VerifyVenturePage()),
                  ),
                ),
              ],
            ),
          );
        }

        if (venture.isVerified) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const VerifiedBadge(size: 28),
                const SizedBox(height: 12),
                Text(venture.name, style: AppTextStyles.h2),
                const SizedBox(height: 4),
                Text(venture.tagline, style: AppTextStyles.sub, textAlign: TextAlign.center),
              ],
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              StatusPill(
                label: venture.verification.status == VerificationStatus.pending
                    ? 'Pending review'
                    : 'Verification rejected',
                tone: venture.verification.status == VerificationStatus.pending
                    ? PillTone.warn
                    : PillTone.red,
              ),
              const SizedBox(height: 16),
              PrimaryButton(
                label: 'View status',
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => VerificationPendingPage(founderUid: venture.founderUid),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
