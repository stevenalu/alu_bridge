import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_event.dart';
import '../../auth/models/app_user.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthBloc>().state.user;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (user != null) ...[
            Text(user.fullName, style: AppTextStyles.h3),
            const SizedBox(height: 4),
            Text(user.email, style: AppTextStyles.sub),
            const SizedBox(height: 4),
            Text(
              user.role == UserRole.student ? 'Student account' : 'Founder account',
              style: AppTextStyles.tiny,
            ),
            const SizedBox(height: 24),
          ],
          OutlinedButton(
            onPressed: () => context.read<AuthBloc>().add(const AuthSignOutRequested()),
            style: OutlinedButton.styleFrom(foregroundColor: AppColors.red),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );
  }
}
