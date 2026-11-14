import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:http/http.dart' as http;

import 'package:taskforge/app.dart';
import 'package:taskforge/core/auth/auth_api.dart';
import 'package:taskforge/core/auth/auth_providers.dart';
import 'package:taskforge/core/auth/auth_session.dart';
import 'package:taskforge/core/auth/device_info.dart';
import 'package:taskforge/core/auth/dpop/dpop_http_client.dart';
import 'package:taskforge/core/auth/dpop/dpop_key_store.dart';
import 'package:taskforge/core/auth/dpop/dpop_manager.dart';
import 'package:taskforge/core/auth/http_client.dart' show createBaseHttpClient;
import 'package:taskforge/core/auth/token_store.dart';
import 'package:taskforge/core/auth/trusted_device_store.dart';
import 'package:taskforge/core/config.dart';
import 'package:taskforge/features/workspaces/application/workspace_providers.dart';
import 'package:taskforge/features/workspaces/data/workspace_store.dart';

Future<void> main() async {
  // Every `http.Client()` made while the app runs is the proof-adding one (DPoP, phase 39), so
  // no REST client has to know about it; public routes and other hosts pass through untouched.
  final probe = createBaseHttpClient();
  DpopManager.shared = DpopManager(
    keys: createDpopKeyStore(),
    origin: AppConfig.dpopOrigin,
    probe: probe,
  );
  await http.runWithClient(
    _run,
    () => DpopHttpClient(createBaseHttpClient(), DpopManager.shared),
  );
}

Future<void> _run() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Invite links are `/invite/<token>`, not `/#/invite/<token>`.
  usePathUrlStrategy();
  // Web: the refresh token stays in an HttpOnly cookie and only the short-lived
  // access token is held, in memory. Elsewhere tokens live in the Keychain/Keystore.
  final trustedDevices = SecureTrustedDeviceStore();
  final session = AuthSession(
    api: HttpAuthApi(
      AppConfig.restUrl,
      cookieMode: kIsWeb,
      trustedDevices: trustedDevices,
      deviceInfo: PlatformDeviceInfoSource.shared,
    ),
    store: kIsWeb ? MemoryTokenStore() : SecureTokenStore(),
    cookieSession: kIsWeb,
  );
  await session.restore();
  runApp(
    ProviderScope(
      overrides: [
        authSessionProvider.overrideWithValue(session),
        trustedDeviceStoreProvider.overrideWithValue(trustedDevices),
        workspaceStoreProvider.overrideWithValue(SecureWorkspaceStore()),
      ],
      child: const TaskForgeApp(),
    ),
  );
}
