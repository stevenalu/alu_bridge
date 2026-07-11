import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_colors.dart';
import '../auth/bloc/auth_bloc.dart';
import '../auth/bloc/auth_event.dart';

class FounderShell extends StatefulWidget {
  const FounderShell({super.key});

  @override
  State<FounderShell> createState() => _FounderShellState();
}

class _FounderShellState extends State<FounderShell> {
  int _index = 0;

  static const _tabs = ['Dashboard', 'Roles', 'Applicants', 'Messages', 'Venture'];
  static const _icons = [
    Icons.dashboard_outlined,
    Icons.work_outline,
    Icons.groups_outlined,
    Icons.chat_bubble_outline,
    Icons.storefront_outlined,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_tabs[_index]),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<AuthBloc>().add(const AuthSignOutRequested()),
          ),
        ],
      ),
      body: Center(child: Text(_tabs[_index])),
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
    );
  }
}
