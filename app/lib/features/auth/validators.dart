import 'package:taskforge/core/auth/auth_api.dart';

const minPasswordLength = 10;

final _email = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

String? validateEmail(String? value) {
  final text = value?.trim() ?? '';
  if (text.isEmpty) return 'Enter your email address.';
  return _email.hasMatch(text) ? null : 'Enter a valid email address.';
}

String? validatePassword(String? value) {
  final text = value ?? '';
  if (text.isEmpty) return 'Enter a password.';
  return text.length >= minPasswordLength
      ? null
      : 'Use at least $minPasswordLength characters.';
}

String? validateResetCode(String? value) =>
    (value ?? '').trim().isEmpty ? 'Enter the code from your email.' : null;

/// Signing in only needs *something* typed: an older account may have a shorter
/// password than today's sign-up rule, and the server is the judge of correctness.
String? validateSignInPassword(String? value) =>
    (value ?? '').isEmpty ? 'Enter your password.' : null;

/// What to tell the user about a failed sign-in or sign-up.
String authErrorMessage(Object error) => switch (error) {
  AuthApiException(title: 'INVALID_CREDENTIALS') => 'Wrong email or password.',
  AuthApiException(title: 'RATE_LIMITED' || 'TOO_MANY_ATTEMPTS') =>
    'Too many attempts. Try again in a few minutes.',
  AuthApiException(title: 'ACCOUNT_EXISTS') =>
    'An account with that email already exists.',
  AuthApiException(title: 'BAD_RESPONSE') =>
    'The server had a problem. Try again in a moment.',
  AuthApiException(:final message) => message,
  NetworkUnavailable() =>
    'Cannot reach the server. Check your connection and try again.',
  _ => 'Something went wrong. Try again.',
};
