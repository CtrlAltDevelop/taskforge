import 'dart:ui' show Locale;

import 'package:flutter/foundation.dart';

import 'package:taskforge/l10n/gen/app_localizations.dart';

@immutable
class TrustedDevice {
  const TrustedDevice({
    required this.id,
    required this.label,
    required this.createdAt,
    required this.lastUsedAt,
    required this.expiresAt,
  });

  final String id;
  final String label;
  final DateTime? createdAt;
  final DateTime? lastUsedAt;
  final DateTime? expiresAt;
}

/// Whether the signed-in person has two-step verification on, how many
/// recovery codes are left, and the devices that skip the code.
@immutable
class SecondFactorStatus {
  const SecondFactorStatus({
    required this.enabled,
    required this.unusedRecoveryCodes,
    required this.devices,
  });

  static const off = SecondFactorStatus(
    enabled: false,
    unusedRecoveryCodes: 0,
    devices: [],
  );

  final bool enabled;
  final int unusedRecoveryCodes;
  final List<TrustedDevice> devices;
}

/// The shared secret and the `otpauth://` link an authenticator app reads
/// from the QR code.
@immutable
class TotpEnrolment {
  const TotpEnrolment({required this.secret, required this.otpauthUri});

  final String secret;
  final String otpauthUri;
}

/// A workspace's two-factor requirement and where the caller stands against it.
@immutable
class SecurityPolicy {
  const SecurityPolicy({
    required this.require2fa,
    required this.graceDays,
    required this.enforcedFrom,
    required this.inGrace,
    required this.enrolled,
    required this.blocked,
    required this.version,
  });

  static const none = SecurityPolicy(
    require2fa: false,
    graceDays: 7,
    enforcedFrom: null,
    inGrace: false,
    enrolled: false,
    blocked: false,
    version: 0,
  );

  final bool require2fa;
  final int graceDays;
  final DateTime? enforcedFrom;
  final bool inGrace;
  final bool enrolled;

  /// The grace period is over and the caller has not enrolled: the server
  /// refuses every workspace call until they do.
  final bool blocked;
  final int version;
}

@immutable
class RoleMapping {
  const RoleMapping({required this.group, required this.roleId});

  final String group;
  final String roleId;
}

/// The workspace's OpenID Connect provider. The client secret is write-only:
/// [hasSecret] says one is stored.
@immutable
class SsoProvider {
  const SsoProvider({
    required this.configured,
    required this.name,
    required this.issuer,
    required this.clientId,
    required this.hasSecret,
    required this.scopes,
    required this.allowedDomains,
    required this.groupClaim,
    required this.groupRoles,
    required this.defaultRoleId,
    required this.autoCreateUsers,
    required this.enabled,
    required this.enforceSso,
    required this.version,
    required this.redirectUri,
  });

  final bool configured;
  final String name;
  final String issuer;
  final String clientId;
  final bool hasSecret;
  final String scopes;
  final List<String> allowedDomains;
  final String groupClaim;
  final List<RoleMapping> groupRoles;
  final String defaultRoleId;
  final bool autoCreateUsers;
  final bool enabled;
  final bool enforceSso;
  final int version;

  /// The address to register at the provider as the redirect URI.
  final String redirectUri;
}

/// What the "Test" button found.
@immutable
class SsoCheck {
  const SsoCheck({
    required this.ok,
    required this.message,
    required this.keys,
    required this.redirectUri,
  });

  final bool ok;
  final String message;
  final int keys;
  final String redirectUri;
}

enum SecurityFailure {
  network,
  denied,
  invalid,
  invalidCode,
  locked,
  conflict,
  notFound,
  other,
}

class SecurityException implements Exception {
  const SecurityException(this.failure, [this.detail]);

  final SecurityFailure failure;
  final String? detail;

  @override
  String toString() => 'SecurityException($failure, $detail)';
}

/// What to tell the user about a failed security call.
String securityErrorMessage(Object error, [AppLocalizations? l10n]) {
  final t = l10n ?? lookupAppLocalizations(const Locale('en'));
  if (error is! SecurityException) return t.grpLGeneric;
  return switch (error.failure) {
    SecurityFailure.network => t.grpLNetCheckShort,
    SecurityFailure.denied => t.grpLNoPermDo,
    SecurityFailure.invalidCode => t.secWrongCode,
    SecurityFailure.locked => t.secLocked,
    SecurityFailure.conflict => t.secConflict,
    SecurityFailure.notFound => t.secNotFound,
    SecurityFailure.invalid =>
      error.detail != null && error.detail!.isNotEmpty
          ? error.detail!
          : t.grpLCheckValues,
    SecurityFailure.other => t.grpLGeneric,
  };
}
