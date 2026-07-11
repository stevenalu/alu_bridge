import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/auth_exception.dart';
import '../data/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(const AuthState()) {
    on<AuthSubscriptionRequested>(_onSubscriptionRequested);
    on<AuthUserChanged>(_onUserChanged);
    on<AuthSignInSubmitted>(_onSignInSubmitted);
    on<AuthSignUpSubmitted>(_onSignUpSubmitted);
    on<AuthSignOutRequested>(_onSignOutRequested);
    on<AuthPasswordResetSubmitted>(_onPasswordResetSubmitted);
  }

  final AuthRepository _authRepository;
  StreamSubscription<User?>? _userSubscription;

  void _onSubscriptionRequested(
    AuthSubscriptionRequested event,
    Emitter<AuthState> emit,
  ) {
    _userSubscription?.cancel();
    _userSubscription = _authRepository.authStateChanges.listen(
      (user) => add(AuthUserChanged(user)),
    );
  }

  Future<void> _onUserChanged(AuthUserChanged event, Emitter<AuthState> emit) async {
    final firebaseUser = event.user;
    if (firebaseUser == null) {
      emit(const AuthState(status: AuthStatus.unauthenticated));
      return;
    }
    try {
      final appUser = await _authRepository.fetchAppUser(firebaseUser.uid);
      emit(AuthState(status: AuthStatus.authenticated, user: appUser));
    } catch (_) {
      emit(const AuthState(status: AuthStatus.unauthenticated));
    }
  }

  Future<void> _onSignInSubmitted(
    AuthSignInSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthState(status: state.status, user: state.user, isSubmitting: true));
    try {
      await _authRepository.signIn(email: event.email, password: event.password);
      emit(AuthState(status: state.status, user: state.user));
    } on AuthException catch (e) {
      emit(AuthState(status: state.status, user: state.user, failure: e.message));
    }
  }

  Future<void> _onSignUpSubmitted(
    AuthSignUpSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthState(status: state.status, user: state.user, isSubmitting: true));
    try {
      await _authRepository.signUp(
        email: event.email,
        password: event.password,
        fullName: event.fullName,
        role: event.role,
      );
      emit(AuthState(status: state.status, user: state.user));
    } on AuthException catch (e) {
      emit(AuthState(status: state.status, user: state.user, failure: e.message));
    }
  }

  Future<void> _onSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _authRepository.signOut();
  }

  Future<void> _onPasswordResetSubmitted(
    AuthPasswordResetSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthState(status: state.status, user: state.user, isSubmitting: true));
    try {
      await _authRepository.sendPasswordReset(event.email);
      emit(AuthState(status: state.status, user: state.user, resetEmailSent: true));
    } on AuthException catch (e) {
      emit(AuthState(status: state.status, user: state.user, failure: e.message));
    }
  }

  @override
  Future<void> close() {
    _userSubscription?.cancel();
    return super.close();
  }
}
