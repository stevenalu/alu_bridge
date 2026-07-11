import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bootstrap.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/primary_button.dart';
import '../applications/bloc/applications_bloc.dart';
import '../applications/data/application_repository.dart';
import '../applications/view/my_applications_page.dart';
import '../auth/bloc/auth_bloc.dart';
import '../auth/bloc/auth_event.dart';
import '../messaging/view/conversations_page.dart';
import '../opportunities/bloc/discovery_bloc.dart';
import '../opportunities/data/opportunity_repository.dart';
import '../opportunities/view/discover_page.dart';
import '../opportunities/view/explore_page.dart';
import '../profile/cubit/profile_cubit.dart';
import '../profile/data/profile_repository.dart';
import '../profile/view/build_profile_page.dart';
import '../profile/view/settings_page.dart';

class StudentShell extends StatefulWidget {
  const StudentShell({super.key});

  @override
  State<StudentShell> createState() => _StudentShellState();
}

class _StudentShellState extends State<StudentShell> {
  int _index = 0;
  late final DiscoveryBloc _discoveryBloc;
  late final ApplicationsBloc _applicationsBloc;

  static const _tabs = ['Home', 'Explore', 'Applications', 'Messages', 'Profile'];
  static const _icons = [
    Icons.home_outlined,
    Icons.explore_outlined,
    Icons.assignment_outlined,
    Icons.chat_bubble_outline,
    Icons.person_outline,
  ];

  @override
  void initState() {
    super.initState();
    final uid = context.read<AuthBloc>().state.user!.uid;
    _discoveryBloc = DiscoveryBloc(
      opportunityRepository: sl<OpportunityRepository>(),
      profileRepository: sl<ProfileRepository>(),
      studentUid: uid,
    )..add(const DiscoverySubscriptionRequested());
    _applicationsBloc = ApplicationsBloc(
      applicationRepository: sl<ApplicationRepository>(),
      studentUid: uid,
    )..add(const ApplicationsSubscriptionRequested());
  }

  @override
  void dispose() {
    _discoveryBloc.close();
    _applicationsBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _discoveryBloc),
        BlocProvider.value(value: _applicationsBloc),
      ],
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
          0 => const _HomeTab(),
          1 => const ExplorePage(),
          2 => const MyApplicationsPage(),
          3 => ConversationsPage(currentUid: context.read<AuthBloc>().state.user!.uid),
          4 => const SettingsPage(),
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

class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: PrimaryButton(
            label: 'Build your profile',
            onPressed: () {
              final uid = context.read<AuthBloc>().state.user!.uid;
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => BlocProvider(
                    create: (_) => ProfileCubit(
                      profileRepository: sl<ProfileRepository>(),
                      uid: uid,
                    ),
                    child: const BuildProfilePage(),
                  ),
                ),
              );
            },
          ),
        ),
        const Expanded(child: DiscoverPage()),
      ],
    );
  }
}
