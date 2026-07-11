import 'package:equatable/equatable.dart';

import '../models/app_user.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState extends Equatable {
  const AuthState({
    this.status = AuthStatus.unknown,
    this.user,
    this.isSubmitting = false,
    this.failure,
    this.resetEmailSent = false,
  });

  final AuthStatus status;
  final AppUser? user;
  final bool isSubmitting;
  final String? failure;
  final bool resetEmailSent;

  @override
  List<Object?> get props => [status, user, isSubmitting, failure, resetEmailSent];
}
