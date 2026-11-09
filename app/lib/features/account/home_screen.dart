import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:taskforge/core/auth/auth_providers.dart';
import 'package:taskforge/features/account/account_providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final account = ref.watch(accountProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('TaskForge'),
        actions: [
          IconButton(
            key: const Key('sign-out'),
            tooltip: 'Sign out',
            icon: const Icon(Icons.logout),
            onPressed: ref.read(authSessionProvider).signOut,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          account.when(
            data: (a) => ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person)),
              title: Text(a.email),
              subtitle: a.displayName.isEmpty ? null : Text(a.displayName),
            ),
            loading: () => const ListTile(title: LinearProgressIndicator()),
            error: (e, _) => ListTile(
              title: const Text('Could not load your account.'),
              trailing: TextButton(
                onPressed: () => ref.invalidate(accountProvider),
                child: const Text('Retry'),
              ),
            ),
          ),
          ListTile(
            key: const Key('open-sessions'),
            leading: const Icon(Icons.devices),
            title: const Text('Sessions'),
            subtitle: const Text('Devices signed in to your account'),
            onTap: () => context.go('/sessions'),
          ),
          ListTile(
            key: const Key('open-change-password'),
            leading: const Icon(Icons.lock_reset),
            title: const Text('Change password'),
            onTap: () => context.push('/change-password'),
          ),
          ListTile(
            leading: const Icon(Icons.network_check),
            title: const Text('Connectivity'),
            onTap: () => context.go('/debug'),
          ),
        ],
      ),
    );
  }
}
