import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bootstrap.dart';
import 'core/routing/router.dart';
import 'core/routing/routes.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/bloc/auth_bloc.dart';
import 'features/auth/bloc/auth_event.dart';
import 'features/auth/bloc/auth_state.dart';
import 'features/auth/models/app_user.dart';

final navigatorKey = GlobalKey<NavigatorState>();

class AluBridgeApp extends StatelessWidget {
  const AluBridgeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          AuthBloc(authRepository: sl())..add(const AuthSubscriptionRequested()),
      child: MaterialApp(
        title: 'ALU Bridge',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        navigatorKey: navigatorKey,
        initialRoute: Routes.splash,
        onGenerateRoute: AppRouter.onGenerateRoute,
        builder: (context, child) {
          return BlocListener<AuthBloc, AuthState>(
            listenWhen: (previous, current) => previous.status != current.status,
            listener: (context, state) {
              final route = switch (state.status) {
                AuthStatus.unknown => null,
                AuthStatus.authenticated => state.user!.role == UserRole.student
                    ? Routes.studentShell
                    : Routes.founderShell,
                AuthStatus.unauthenticated => Routes.onboarding,
              };
              if (route != null) {
                navigatorKey.currentState?.pushNamedAndRemoveUntil(route, (_) => false);
              }
            },
            child: child!,
          );
        },
      ),
    );
  }
}
