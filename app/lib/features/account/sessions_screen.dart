import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:taskforge/core/auth/auth_api.dart';
import 'package:taskforge/core/auth/auth_providers.dart';
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
    try {
      for (final id in ids) {
        await ref.read(authSessionProvider).revokeSession(id);
      }
    } on AuthApiException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(authErrorMessage(e))));
    } on NetworkUnavailable catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(authErrorMessage(e))));
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
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
        title: const Text('Sessions'),
        actions: [
          if (others.isNotEmpty)
            TextButton(
              key: const Key('revoke-others'),
              onPressed: () =>
                  _revoke(context, ref, [for (final s in others) s.id]),
              child: const Text('Sign out other devices'),
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
                  s.userAgent.isEmpty ? 'Unknown device' : s.userAgent,
                ),
                subtitle: Text(s.current ? 'This device' : s.ipAddress),
                trailing: s.current
                    ? null
                    : IconButton(
                        key: Key('revoke-${s.id}'),
                        tooltip: 'Sign out this device',
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
            child: const Text('Retry'),
          ),
        ),
      ),
    );
  }
}
