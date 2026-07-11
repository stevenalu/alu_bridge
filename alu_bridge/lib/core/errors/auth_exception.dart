import 'app_exception.dart';

class AuthException extends AppException {
  const AuthException(super.message);

  factory AuthException.fromCode(String code) {
    return switch (code) {
      'invalid-email' => const AuthException('That email address looks invalid.'),
      'user-disabled' => const AuthException('This account has been disabled.'),
      'user-not-found' => const AuthException('No account found with that email.'),
      'wrong-password' ||
      'invalid-credential' =>
        const AuthException('Incorrect email or password.'),
      'email-already-in-use' => const AuthException(
          'An account already exists with that email.',
        ),
      'weak-password' => const AuthException(
          'Choose a stronger password, at least 6 characters.',
        ),
      'operation-not-allowed' => const AuthException(
          'Email and password sign-in is currently disabled.',
        ),
      'too-many-requests' => const AuthException(
          'Too many attempts. Try again in a moment.',
        ),
      'network-request-failed' => const AuthException(
          'Check your internet connection and try again.',
        ),
      _ => const AuthException('Something went wrong. Please try again.'),
    };
  }
}
