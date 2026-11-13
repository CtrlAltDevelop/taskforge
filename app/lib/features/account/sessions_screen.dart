import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:taskforge/core/auth/auth_api.dart';
import 'package:taskforge/core/auth/auth_providers.dart';
import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/features/account/account_client.dart';
import 'package:taskforge/features/account/account_providers.dart';
import 'package:taskforge/features/auth/validators.dart';

class SessionsScreen extends ConsumerWidget {
  const SessionsScreen({super.key});

  /// Ends [ids] on the server, then refreshes the list. Failures are shown, not thrown.
  Future<void> _revoke(
    BuildContext context,
    WidgetRef ref,
    List<String> ids,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    try {
      for (final id in ids) {
        await ref.read(authSessionProvider).revokeSession(id);
      }
    } on AuthApiException catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text(authErrorMessage(e, l10n))),
      );
    } on NetworkUnavailable catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text(authErrorMessage(e, l10n))),
      );
    }
    ref.invalidate(sessionsProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessions = ref.watch(sessionsProvider);
    final others =
        sessions.value?.where((s) => !s.current).toList() ??
        const <SessionInfo>[];
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          key: const Key('back-home'),
          tooltip: context.l10n.grpIBack,
          icon: const BackButtonIcon(),
          onPressed: () => context.go('/'),
        ),
        title: Text(context.l10n.grpISessions),
        actions: [
          if (others.isNotEmpty)
            TextButton(
              key: const Key('revoke-others'),
              onPressed: () =>
                  _revoke(context, ref, [for (final s in others) s.id]),
              child: Text(context.l10n.grpISignOutOthers),
            ),
        ],
      ),
      body: sessions.when(
        data: (items) => ListView(
          children: [
            for (final s in items)
              ListTile(
                leading: const Icon(Icons.devices),
                title: Text(
                  s.userAgent.isEmpty
                      ? context.l10n.grpIUnknownDevice
                      : s.userAgent,
                ),
                subtitle: Text(
                  s.current ? context.l10n.grpIThisDevice : s.ipAddress,
                ),
                trailing: s.current
                    ? null
                    : IconButton(
                        key: Key('revoke-${s.id}'),
                        tooltip: context.l10n.grpISignOutThis,
                        icon: const Icon(Icons.close),
                        onPressed: () => _revoke(context, ref, [s.id]),
                      ),
              ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: TextButton(
            onPressed: () => ref.invalidate(sessionsProvider),
            child: Text(context.l10n.grpIRetry),
          ),
        ),
      ),
    );
  }
}
