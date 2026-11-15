import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:taskforge/core/auth/auth_providers.dart';
import 'package:taskforge/core/auth/second_factor_api.dart';
import 'package:taskforge/core/auth/secure_storage.dart';
import 'package:taskforge/core/config.dart';
import 'package:taskforge/core/i18n/l10n_context.dart';

/// The deep link the system browser returns to on mobile and desktop
/// (`taskforge://sso/callback?ticket=...`). It must match the server's
/// `DJANGO_SSO_NATIVE_RETURN_URL`.
const ssoNativeReturnUrl = 'taskforge://sso/callback';

/// Where the identity provider's round trip ends: the web build's own
/// `/sso/callback` page, or the native deep link.
String ssoReturnUrl() =>
    kIsWeb ? '${AppConfig.webUrl}/sso/callback' : ssoNativeReturnUrl;

/// Holds the PKCE verifier of an SSO attempt across the redirect. On the web
/// the whole page leaves and comes back, so it cannot live in memory.
abstract interface class SsoPendingStore {
  Future<String?> take();
  Future<void> put(String verifier);
}

class SecureSsoPendingStore implements SsoPendingStore {
  SecureSsoPendingStore([FlutterSecureStorage? storage])
    : _storage = storage ?? appSecureStorage();

  static const _key = 'auth.sso_verifier';

  final FlutterSecureStorage _storage;

  @override
  Future<void> put(String verifier) =>
      _storage.write(key: _key, value: verifier);

  @override
  Future<String?> take() async {
    final value = await _storage.read(key: _key);
    await _storage.delete(key: _key);
    return value;
  }
}

final ssoPendingStoreProvider = Provider<SsoPendingStore>(
  (ref) => SecureSsoPendingStore(),
);

/// Opens a URL; replaced in tests. The web build leaves the page itself (the
/// provider redirects back to it), elsewhere the system browser is used.
final ssoLauncherProvider = Provider<Future<bool> Function(Uri)>(
  (ref) =>
      (uri) => launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
        webOnlyWindowName: '_self',
      ),
);

/// Starts single sign-on for the workspace whose URL name is [slug]. Returns
/// false when the browser could not be opened.
Future<bool> startSso(WidgetRef ref, String slug) async {
  final pkce = SsoPkce.generate();
  await ref.read(ssoPendingStoreProvider).put(pkce.verifier);
  final uri = ref
      .read(secondFactorApiProvider)
      .ssoStartUri(
        workspaceSlug: slug,
        returnTo: ssoReturnUrl(),
        codeChallenge: pkce.challenge,
      );
  return ref.read(ssoLauncherProvider)(uri);
}

/// Asks for the workspace's URL name and sends the person to its provider.
Future<void> showSsoDialog(BuildContext context, WidgetRef ref) async {
  final slug = await showDialog<String>(
    context: context,
    builder: (_) => const _SsoSlugDialog(),
  );
  if (slug == null || slug.isEmpty || !context.mounted) return;
  final failed = context.l10n.ssoOpenFailed;
  final messenger = ScaffoldMessenger.of(context);
  final opened = await startSso(ref, slug);
  if (!opened) messenger.showSnackBar(SnackBar(content: Text(failed)));
}

class _SsoSlugDialog extends StatefulWidget {
  const _SsoSlugDialog();

  @override
  State<_SsoSlugDialog> createState() => _SsoSlugDialogState();
}

class _SsoSlugDialogState extends State<_SsoSlugDialog> {
  final _slug = TextEditingController();

  @override
  void dispose() {
    _slug.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    return AlertDialog(
      title: Text(t.ssoContinue),
      content: TextField(
        key: const Key('sso-slug'),
        controller: _slug,
        autofocus: true,
        autocorrect: false,
        decoration: InputDecoration(
          labelText: t.ssoWorkspaceName,
          helperText: t.ssoWorkspaceHelp,
        ),
        onSubmitted: (v) => Navigator.pop(context, v.trim().toLowerCase()),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(t.grpBCancel),
        ),
        FilledButton(
          key: const Key('sso-go'),
          onPressed: () =>
              Navigator.pop(context, _slug.text.trim().toLowerCase()),
          child: Text(t.ssoContinueShort),
        ),
      ],
    );
  }
}
