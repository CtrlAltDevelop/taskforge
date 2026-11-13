import 'package:flutter/widgets.dart' show Locale;

import 'package:taskforge/core/auth/auth_api.dart';
import 'package:taskforge/l10n/gen/app_localizations.dart';

const minPasswordLength = 10;

final _email = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

/// A form field's check; the strings come in the language on screen.
typedef AuthValidator = String? Function(String? value, AppLocalizations l10n);

AppLocalizations _english() => lookupAppLocalizations(const Locale('en'));

String? validateEmail(String? value, [AppLocalizations? l10n]) {
  final t = l10n ?? _english();
  final text = value?.trim() ?? '';
  if (text.isEmpty) return t.enterEmail;
  return _email.hasMatch(text) ? null : t.enterValidEmail;
}

String? validatePassword(String? value, [AppLocalizations? l10n]) {
  final t = l10n ?? _english();
  final text = value ?? '';
  if (text.isEmpty) return t.enterPassword;
  return text.length >= minPasswordLength
      ? null
      : t.passwordTooShort(minPasswordLength);
}

String? validateResetCode(String? value, [AppLocalizations? l10n]) =>
    (value ?? '').trim().isEmpty ? (l10n ?? _english()).enterResetCode : null;

/// Signing in only needs *something* typed: an older account may have a shorter
/// password than today's sign-up rule, and the server is the judge of correctness.
String? validateSignInPassword(String? value, [AppLocalizations? l10n]) =>
    (value ?? '').isEmpty ? (l10n ?? _english()).enterYourPassword : null;

/// What to tell the user about a failed sign-in or sign-up.
String authErrorMessage(Object error, [AppLocalizations? l10n]) {
  final t = l10n ?? _english();
  return switch (error) {
    AuthApiException(title: 'INVALID_CREDENTIALS') => t.errWrongCredentials,
    AuthApiException(title: 'RATE_LIMITED' || 'TOO_MANY_ATTEMPTS') =>
      t.errTooManyAttempts,
    AuthApiException(title: 'ACCOUNT_EXISTS') => t.errAccountExists,
    AuthApiException(title: 'BAD_RESPONSE') => t.errServerProblem,
    AuthApiException(title: 'SECOND_FACTOR_REQUIRED') =>
      t.grp1SecondFactorRequired,
    AuthApiException(:final message) => message,
    NetworkUnavailable() => t.errNoConnection,
    _ => t.errGeneric,
  };
}
