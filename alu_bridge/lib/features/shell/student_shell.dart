import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_colors.dart';
import '../auth/bloc/auth_bloc.dart';
import '../auth/bloc/auth_event.dart';

class StudentShell extends StatefulWidget {
  const StudentShell({super.key});

  @override
  State<StudentShell> createState() => _StudentShellState();
}

class _StudentShellState extends State<StudentShell> {
  int _index = 0;

  static const _tabs = ['Home', 'Explore', 'Applications', 'Messages', 'Profile'];
  static const _icons = [
    Icons.home_outlined,
    Icons.explore_outlined,
    Icons.assignment_outlined,
    Icons.chat_bubble_outline,
    Icons.person_outline,
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
