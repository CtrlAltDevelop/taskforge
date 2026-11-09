import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import 'package:taskforge/app.dart';
import 'package:taskforge/core/auth/auth_api.dart';
import 'package:taskforge/core/auth/auth_providers.dart';
import 'package:taskforge/core/auth/auth_session.dart';
import 'package:taskforge/core/auth/token_store.dart';
import 'package:taskforge/core/config.dart';
import 'package:taskforge/features/workspaces/application/workspace_providers.dart';
import 'package:taskforge/features/workspaces/data/workspace_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Invite links are `/invite/<token>`, not `/#/invite/<token>`.
  usePathUrlStrategy();
  // Web: the refresh token stays in an HttpOnly cookie and only the short-lived
  // access token is held, in memory. Elsewhere tokens live in the Keychain/Keystore.
  final session = AuthSession(
    api: HttpAuthApi(AppConfig.restUrl, cookieMode: kIsWeb),
    store: kIsWeb ? MemoryTokenStore() : SecureTokenStore(),
    cookieSession: kIsWeb,
  );
  await session.restore();
  runApp(
    ProviderScope(
      overrides: [
        authSessionProvider.overrideWithValue(session),
        workspaceStoreProvider.overrideWithValue(SecureWorkspaceStore()),
      ],
      child: const TaskForgeApp(),
    ),
  );
}
