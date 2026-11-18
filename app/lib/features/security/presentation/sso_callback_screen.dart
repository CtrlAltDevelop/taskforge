import 'package:taskforge/core/ui/tf/tf_button.dart';
import 'package:taskforge/core/ui/tf_app_bar.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:taskforge/core/auth/auth_api.dart';
import 'package:taskforge/core/auth/auth_providers.dart';
import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/features/auth/validators.dart' show authErrorMessage;
import 'package:taskforge/features/security/presentation/sso_flow.dart';

/// Where single sign-on lands (`/sso/callback`, also reached from the native
/// deep link). It carries either a one-time `ticket`, which is traded for the
/// usual tokens, or an `sso_error` title saying why the provider sign-in failed.
class SsoCallbackScreen extends ConsumerStatefulWidget {
  const SsoCallbackScreen({super.key, this.ticket, this.error});

  final String? ticket;
  final String? error;

  @override
  ConsumerState<SsoCallbackScreen> createState() => _SsoCallbackScreenState();
}

class _SsoCallbackScreenState extends ConsumerState<SsoCallbackScreen> {
  String? _message;

  @override
  void initState() {
    super.initState();
    Future.microtask(_finish);
  }

  String _explain(String title) {
    final t = context.l10n;
    return switch (title) {
      'SSO_EMAIL_UNVERIFIED' => t.ssoErrUnverified,
      'SSO_DOMAIN_NOT_ALLOWED' => t.ssoErrDomain,
      'SSO_NO_ACCOUNT' => t.ssoErrNoAccount,
      'SSO_MEMBER_REMOVED' => t.ssoErrRemoved,
      'ACCOUNT_DISABLED' => t.ssoErrDisabled,
      _ => t.ssoErrGeneric,
    };
  }

  Future<void> _finish() async {
    final error = widget.error;
    final ticket = widget.ticket;
    if (error != null && error.isNotEmpty) {
      setState(() => _message = _explain(error));
      return;
    }
    if (ticket == null || ticket.isEmpty) {
      setState(() => _message = _explain(''));
      return;
    }
    final router = GoRouter.of(context);
    final verifier = await ref.read(ssoPendingStoreProvider).take();
    if (verifier == null) {
      if (mounted) setState(() => _message = _explain(''));
      return;
    }
    try {
      final result = await ref
          .read(secondFactorApiProvider)
          .ssoExchange(ticket: ticket, verifier: verifier);
      await ref.read(authSessionProvider).adoptTokens(result.tokens);
      router.go('/');
    } on AuthApiException catch (e) {
      if (mounted) setState(() => _message = _explain(e.title));
    } on NetworkUnavailable catch (e) {
      if (mounted) setState(() => _message = authErrorMessage(e, context.l10n));
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final message = _message;
    return Scaffold(
      appBar: TfAppBar(title: Text(t.ssoTitleShort)),
      body: Center(
        child: message == null
            ? const CircularProgressIndicator()
            : Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      message,
                      key: const Key('sso-error'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TfButton(
                      key: const Key('sso-back'),
                      label: t.secBackToSignIn,
                      variant: TfButtonVariant.primary,
                      onPressed: () => context.go('/sign-in'),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
