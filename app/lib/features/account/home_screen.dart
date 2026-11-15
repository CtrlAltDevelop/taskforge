import 'package:taskforge/core/ui/content_width.dart';
import 'package:taskforge/core/ui/tf_app_bar.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:taskforge/core/auth/auth_providers.dart';
import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/features/account/account_providers.dart';
import 'package:taskforge/features/inbox/presentation/inbox_badge.dart';
import 'package:taskforge/features/projects/presentation/app_shell.dart';
import 'package:taskforge/features/system/application/system_providers.dart';
import 'package:taskforge/features/system/presentation/version_screens.dart';
import 'package:taskforge/features/workspaces/application/workspace_providers.dart';
import 'package:taskforge/features/workspaces/presentation/workspace_switcher.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final account = ref.watch(accountProvider);
    final workspaces = ref.watch(workspacesProvider);
    if (workspaces.hasError && !workspaces.hasValue) {
      return Scaffold(
        body: Center(
          child: TextButton(
            key: const Key('retry-workspaces'),
            onPressed: () => ref.invalidate(workspacesProvider),
            child: Text(context.l10n.homeLoadWorkspacesFailed),
          ),
        ),
      );
    }
    if (!workspaces.hasValue) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return ShellScaffold(
      appBar: TfAppBar(
        title: const WorkspaceSwitcher(),
        actions: [
          IconButton(
            key: const Key('open-inbox-bell'),
            tooltip: context.l10n.inbox,
            icon: const InboxBadge(child: Icon(Icons.notifications_outlined)),
            onPressed: () => context.go('/inbox'),
          ),
          IconButton(
            key: const Key('open-workspace-settings'),
            tooltip: context.l10n.workspaceSettings,
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/workspaces/settings'),
          ),
          IconButton(
            key: const Key('sign-out'),
            tooltip: context.l10n.signOut,
            icon: const Icon(Icons.logout),
            onPressed: ref.read(authSessionProvider).signOut,
          ),
        ],
      ),
      body: ContentWidth(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const DesktopUpdateNotice(),
            account.when(
              data: (a) => ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text(a.email),
                subtitle: a.displayName.isEmpty ? null : Text(a.displayName),
              ),
              loading: () => const ListTile(title: LinearProgressIndicator()),
              error: (e, _) => ListTile(
                title: Text(context.l10n.homeLoadAccountFailed),
                trailing: TextButton(
                  onPressed: () => ref.invalidate(accountProvider),
                  child: Text(context.l10n.retry),
                ),
              ),
            ),
            ListTile(
              key: const Key('open-calendar'),
              leading: const Icon(Icons.calendar_month_outlined),
              title: Text(context.l10n.calendar),
              subtitle: Text(context.l10n.calendarSubtitle),
              onTap: () => context.go('/calendar'),
            ),
            ListTile(
              key: const Key('open-notification-settings'),
              leading: const Icon(Icons.tune),
              title: Text(context.l10n.notificationSettings),
              subtitle: Text(context.l10n.notificationSettingsSubtitle),
              onTap: () => context.push('/inbox/preferences'),
            ),
            ListTile(
              key: const Key('open-offline'),
              leading: const Icon(Icons.cloud_off_outlined),
              title: Text(context.l10n.offlineAndStorage),
              subtitle: Text(context.l10n.offlineAndStorageSubtitle),
              onTap: () => context.push('/offline'),
            ),
            ListTile(
              key: const Key('open-language'),
              leading: const Icon(Icons.language),
              title: Text(context.l10n.languageAndRegion),
              subtitle: Text(context.l10n.languageAndRegionSubtitle),
              onTap: () => context.push('/settings/language'),
            ),
            ListTile(
              key: const Key('open-sessions'),
              leading: const Icon(Icons.devices),
              title: Text(context.l10n.sessions),
              subtitle: Text(context.l10n.sessionsSubtitle),
              onTap: () => context.go('/sessions'),
            ),
            ListTile(
              key: const Key('open-security'),
              leading: const Icon(Icons.verified_user_outlined),
              title: Text(context.l10n.secTitle),
              subtitle: Text(context.l10n.secSubtitle),
              onTap: () => context.push('/settings/security'),
            ),
            ListTile(
              key: const Key('open-change-password'),
              leading: const Icon(Icons.lock_reset),
              title: Text(context.l10n.changePassword),
              onTap: () => context.push('/change-password'),
            ),
            ListTile(
              leading: const Icon(Icons.network_check),
              title: Text(context.l10n.connectivity),
              onTap: () => context.go('/debug'),
            ),
            ListTile(
              key: const Key('open-about'),
              leading: const Icon(Icons.info_outline),
              title: Text(context.l10n.sysAboutTitle),
              onTap: () => context.push('/about'),
            ),
            // Administrators only: the call fails for everyone else, and the tile stays hidden.
            if (ref.watch(systemInfoProvider).hasValue)
              ListTile(
                key: const Key('open-system'),
                leading: const Icon(Icons.monitor_heart_outlined),
                title: Text(context.l10n.sysTitle),
                subtitle: Text(context.l10n.sysSubtitle),
                onTap: () => context.push('/system'),
              ),
          ],
        ),
      ),
    );
  }
}
