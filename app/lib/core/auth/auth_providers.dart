import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/core/auth/device_info.dart';
import 'package:taskforge/core/auth/second_factor_api.dart';
import 'package:taskforge/core/auth/trusted_device_store.dart';
import 'package:taskforge/core/config.dart';

import 'package:taskforge/core/auth/auth_session.dart';

/// The one [AuthSession]. `main` overrides it with the restored, real one.
final authSessionProvider = Provider<AuthSession>(
  (ref) => throw UnimplementedError('override authSessionProvider'),
);

/// The second-factor and single-sign-on steps of a sign-in (no bearer token).
final secondFactorApiProvider = Provider<SecondFactorApi>(
  (ref) => HttpSecondFactorApi(
    AppConfig.restUrl,
    cookieMode: kIsWeb,
    deviceInfo: PlatformDeviceInfoSource.shared,
  ),
);

/// The remembered-device token of this install.
final trustedDeviceStoreProvider = Provider<TrustedDeviceStore>(
  (ref) => SecureTrustedDeviceStore(),
);
