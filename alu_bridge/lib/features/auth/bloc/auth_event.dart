import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/app_user.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthSubscriptionRequested extends AuthEvent {
  const AuthSubscriptionRequested();
}

class AuthUserChanged extends AuthEvent {
  const AuthUserChanged(this.user);

  final User? user;

  @override
  List<Object?> get props => [user];
}

class AuthSignInSubmitted extends AuthEvent {
  const AuthSignInSubmitted({required this.email, required this.password});

  final String email;
  final String password;

  @override
  List<Object?> get props => [email, password];
}

class AuthSignUpSubmitted extends AuthEvent {
  const AuthSignUpSubmitted({
    required this.fullName,
    required this.email,
    required this.password,
    required this.role,
  });

  final String fullName;
  final String email;
  final String password;
  final UserRole role;

  @override
  List<Object?> get props => [fullName, email, password, role];
}

class AuthSignOutRequested extends AuthEvent {
  const AuthSignOutRequested();
}

class AuthPasswordResetSubmitted extends AuthEvent {
  const AuthPasswordResetSubmitted(this.email);

  final String email;

  @override
  List<Object?> get props => [email];
}
