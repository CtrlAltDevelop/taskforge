import 'package:taskforge/core/ui/content_width.dart';
import 'package:taskforge/core/ui/tf_app_bar.dart';
import 'package:material_ui/material_ui.dart';
import 'package:taskforge/core/ui/tf_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/features/account/account_providers.dart';
import 'package:taskforge/features/system/application/system_providers.dart';
import 'package:taskforge/features/system/presentation/version_screens.dart';
import 'package:taskforge/features/workspaces/application/workspace_providers.dart';

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
    return Scaffold(
      appBar: TfAppBar(title: Text(context.l10n.grpKTHome)),
      body: ContentWidth(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const DesktopUpdateNotice(),
            account.when(
              data: (a) => ListTile(
                leading: const CircleAvatar(
                  child: TfIcon(TfIcons.user, size: 24),
                ),
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
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              clipBehavior: Clip.antiAlias,
              child: ListTile(
                key: const Key('open-calendar'),
                leading: const TfIcon(TfIcons.calendarDays, size: 24),
                title: Text(context.l10n.calendar),
                subtitle: Text(context.l10n.calendarSubtitle),
                onTap: () => context.go('/calendar'),
              ),
            ),
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              clipBehavior: Clip.antiAlias,
              child: ListTile(
                key: const Key('open-notification-settings'),
                leading: const TfIcon(TfIcons.tune, size: 24),
                title: Text(context.l10n.notificationSettings),
                subtitle: Text(context.l10n.notificationSettingsSubtitle),
                onTap: () => context.push('/inbox/preferences'),
              ),
            ),
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              clipBehavior: Clip.antiAlias,
              child: ListTile(
                key: const Key('open-offline'),
                leading: const TfIcon(TfIcons.cloudOff, size: 24),
                title: Text(context.l10n.offlineAndStorage),
                subtitle: Text(context.l10n.offlineAndStorageSubtitle),
                onTap: () => context.push('/offline'),
              ),
            ),
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              clipBehavior: Clip.antiAlias,
              child: ListTile(
                key: const Key('open-appearance'),
                leading: const TfIcon(TfIcons.sun, size: 24),
                title: Text(context.l10n.appearance),
                subtitle: Text(context.l10n.appearanceSubtitle),
                onTap: () => context.push('/settings/appearance'),
              ),
            ),
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              clipBehavior: Clip.antiAlias,
              child: ListTile(
                key: const Key('open-language'),
                leading: const TfIcon(TfIcons.globe, size: 24),
                title: Text(context.l10n.languageAndRegion),
                subtitle: Text(context.l10n.languageAndRegionSubtitle),
                onTap: () => context.push('/settings/language'),
              ),
            ),
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              clipBehavior: Clip.antiAlias,
              child: ListTile(
                key: const Key('open-sessions'),
                leading: const TfIcon(TfIcons.devices, size: 24),
                title: Text(context.l10n.sessions),
                subtitle: Text(context.l10n.sessionsSubtitle),
                onTap: () => context.go('/sessions'),
              ),
            ),
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              clipBehavior: Clip.antiAlias,
              child: ListTile(
                key: const Key('open-security'),
                leading: const TfIcon(TfIcons.shield, size: 24),
                title: Text(context.l10n.secTitle),
                subtitle: Text(context.l10n.secSubtitle),
                onTap: () => context.push('/settings/security'),
              ),
            ),
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              clipBehavior: Clip.antiAlias,
              child: ListTile(
                key: const Key('open-change-password'),
                leading: const TfIcon(TfIcons.key, size: 24),
                title: Text(context.l10n.changePassword),
                onTap: () => context.push('/change-password'),
              ),
            ),
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              clipBehavior: Clip.antiAlias,
              child: ListTile(
                leading: const TfIcon(TfIcons.wifi, size: 24),
                title: Text(context.l10n.connectivity),
                onTap: () => context.go('/debug'),
              ),
            ),
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              clipBehavior: Clip.antiAlias,
              child: ListTile(
                key: const Key('open-about'),
                leading: const TfIcon(TfIcons.info, size: 24),
                title: Text(context.l10n.sysAboutTitle),
                onTap: () => context.push('/about'),
              ),
            ),
            // Administrators only: the call fails for everyone else, and the tile stays hidden.
            if (ref.watch(systemInfoProvider).hasValue)
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                clipBehavior: Clip.antiAlias,
                child: ListTile(
                  key: const Key('open-system'),
                  leading: const TfIcon(TfIcons.activity, size: 24),
                  title: Text(context.l10n.sysTitle),
                  subtitle: Text(context.l10n.sysSubtitle),
                  onTap: () => context.push('/system'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
