import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:taskforge/app_router.dart' show safeReturnPath;
import 'package:taskforge/core/auth/auth_api.dart';
import 'package:taskforge/core/auth/auth_providers.dart';
import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/features/account/language_menu.dart';
import 'package:taskforge/features/auth/validators.dart' show authErrorMessage;

/// The second step of a sign-in: the 6-digit code from the authenticator app,
/// or a recovery code. The challenge ticket from the password step is short
/// lived; when it lapses the person starts again at the password.
class TwoFactorScreen extends ConsumerStatefulWidget {
  const TwoFactorScreen({super.key, required this.challenge, this.from});

  final SecondFactorRequired challenge;
  final String? from;

  @override
  ConsumerState<TwoFactorScreen> createState() => _TwoFactorScreenState();
}

class _TwoFactorScreenState extends ConsumerState<TwoFactorScreen> {
  final _code = TextEditingController();
  bool _recovery = false;
  bool _remember = false;
  bool _busy = false;
  String? _error;
  bool _expired = false;

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final code = _code.text.trim();
    if (code.isEmpty) return;
    final t = context.l10n;
    setState(() {
      _busy = true;
      _error = null;
    });
    final router = GoRouter.of(context);
    try {
      final result = await ref
          .read(secondFactorApiProvider)
          .verify(
            loginTicket: widget.challenge.loginTicket,
            code: code,
            recovery: _recovery,
            rememberDevice: _remember,
            deviceLabel: 'TaskForge',
          );
      if (result.trustedDeviceToken.isNotEmpty) {
        await ref
            .read(trustedDeviceStoreProvider)
            .write(result.trustedDeviceToken);
      }
      await ref.read(authSessionProvider).adoptTokens(result.tokens);
      router.go(safeReturnPath(widget.from));
    } on AuthApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _expired =
            e.title == 'SIGN_IN_EXPIRED' || e.title == 'CHALLENGE_INVALID';
        _error = switch (e.title) {
          'INVALID_CODE' => t.secWrongCode,
          'SECOND_FACTOR_LOCKED' || 'RATE_LIMITED' => t.secLocked,
          'TOO_MANY_ATTEMPTS' => t.secTooManyTries,
          'SIGN_IN_EXPIRED' || 'CHALLENGE_INVALID' => t.secSignInExpired,
          _ => authErrorMessage(e, t),
        };
      });
    } on NetworkUnavailable catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = authErrorMessage(e, t);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(t.secVerifyTitle),
        actions: const [LanguageMenuButton()],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: ListView(
            padding: const EdgeInsets.all(24),
            shrinkWrap: true,
            children: [
              Text(_recovery ? t.secEnterRecovery : t.secEnterAppCode),
              const SizedBox(height: 16),
              TextField(
                key: const Key('two-factor-code'),
                controller: _code,
                autofocus: true,
                enabled: !_expired,
                keyboardType: _recovery
                    ? TextInputType.text
                    : TextInputType.number,
                autofillHints: const [AutofillHints.oneTimeCode],
                decoration: InputDecoration(
                  labelText: _recovery ? t.secRecoveryCode : t.secAppCode,
                ),
                onSubmitted: (_) => _busy ? null : _submit(),
              ),
              CheckboxListTile(
                key: const Key('two-factor-remember'),
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                value: _remember,
                onChanged: _busy
                    ? null
                    : (v) => setState(() => _remember = v ?? false),
                title: Text(t.secRememberDevice),
              ),
              if (_error != null) ...[
                Text(_error!, style: TextStyle(color: colors.error)),
                const SizedBox(height: 8),
              ],
              FilledButton(
                key: const Key('two-factor-submit'),
                onPressed: _busy || _expired ? null : _submit,
                child: _busy
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(t.secVerify),
              ),
              TextButton(
                key: const Key('two-factor-toggle'),
                onPressed: _busy
                    ? null
                    : () => setState(() {
                        _recovery = !_recovery;
                        _code.clear();
                        _error = null;
                      }),
                child: Text(_recovery ? t.secUseAppCode : t.secUseRecovery),
              ),
              TextButton(
                key: const Key('two-factor-back'),
                onPressed: () => context.go('/sign-in'),
                child: Text(t.secBackToSignIn),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
