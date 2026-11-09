import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// The one place the app builds its [FlutterSecureStorage].
///
/// On macOS the data-protection keychain needs a signed team and a
/// `keychain-access-groups` entitlement, which an unsigned dev build lacks
/// (error -34018, so sign-in could never save its tokens). The login keychain
/// works for any signed build, so it is used instead.
FlutterSecureStorage appSecureStorage() => const FlutterSecureStorage(
  mOptions: MacOsOptions(usesDataProtectionKeychain: false),
);
