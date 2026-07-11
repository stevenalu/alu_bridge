import 'package:flutter/material.dart';

import '../../features/auth/models/app_user.dart';
import '../../features/auth/view/onboarding_page.dart';
import '../../features/auth/view/reset_password_page.dart';
import '../../features/auth/view/role_picker_page.dart';
import '../../features/auth/view/sign_in_page.dart';
import '../../features/auth/view/sign_up_page.dart';
import '../../features/auth/view/splash_page.dart';
import '../../features/shell/founder_shell.dart';
import '../../features/shell/student_shell.dart';
import 'routes.dart';

abstract class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.splash:
        return MaterialPageRoute(builder: (_) => const SplashPage());
      case Routes.onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingPage());
      case Routes.rolePicker:
        return MaterialPageRoute(builder: (_) => const RolePickerPage());
      case Routes.signIn:
        return MaterialPageRoute(builder: (_) => const SignInPage());
      case Routes.resetPassword:
        return MaterialPageRoute(builder: (_) => const ResetPasswordPage());
      case Routes.signUp:
        final role = settings.arguments! as UserRole;
        return MaterialPageRoute(builder: (_) => SignUpPage(role: role));
      case Routes.studentShell:
        return MaterialPageRoute(builder: (_) => const StudentShell());
      case Routes.founderShell:
        return MaterialPageRoute(builder: (_) => const FounderShell());
      default:
        return MaterialPageRoute(builder: (_) => const OnboardingPage());
    }
  }
}
