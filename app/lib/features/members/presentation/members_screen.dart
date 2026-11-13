import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/features/members/application/members_providers.dart';
import 'package:taskforge/features/members/domain/members.dart';
import 'package:taskforge/features/members/presentation/invite_dialog.dart';
import 'package:taskforge/features/members/presentation/pending_tab.dart';
import 'package:taskforge/features/members/presentation/role_picker.dart';
import 'package:taskforge/features/roles/domain/roles.dart';
import 'package:taskforge/features/roles/presentation/permission_gate.dart';
import 'package:taskforge/features/workspaces/application/workspace_providers.dart';

String formatDate(DateTime? date) {
  if (date == null) return '';
  final d = date.toLocal();
  String two(int n) => n.toString().padLeft(2, '0');
  return '${d.year}-${two(d.month)}-${two(d.day)}';
}

/// Runs [action]; shows the failure as a snackbar. True when it succeeded.
Future<bool> runWithFeedback(
  BuildContext context,
  Future<void> Function() action,
) async {
  final messenger = ScaffoldMessenger.of(context);
  try {
    await action();
    return true;
  } on InviteException catch (e) {
    messenger.showSnackBar(SnackBar(content: Text(inviteErrorMessage(e))));
    return false;
  }
}

class MembersScreen extends ConsumerWidget {
  const MembersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            key: const Key('back-home'),
            tooltip: context.l10n.grpJBack,
            icon: const BackButtonIcon(),
            onPressed: () => context.go('/'),
          ),
          title: Text(context.l10n.grpJMembers),
          actions: [
            PermissionGate(
              permission: Perm.memberInvite,
              disabledWhenDenied: true,
              child: TextButton.icon(
                key: const Key('open-invite'),
                icon: const Icon(Icons.person_add),
                label: Text(context.l10n.grpJInvite),
                onPressed: () => showDialog<void>(
                  context: context,
                  builder: (_) => const InviteDialog(),
                ),
              ),
            ),
          ],
          bottom: TabBar(
            tabs: [
              Tab(
                key: const Key('tab-members'),
                text: context.l10n.grpJMembers,
              ),
              Tab(
                key: const Key('tab-pending'),
                text: context.l10n.grpJPending,
              ),
            ],
          ),
        ),
        body: const TabBarView(children: [_MembersTab(), PendingTab()]),
      ),
    );
  }
}

class _MembersTab extends ConsumerStatefulWidget {
  const _MembersTab();

  @override
  ConsumerState<_MembersTab> createState() => _MembersTabState();
}

class _MembersTabState extends ConsumerState<_MembersTab> {
  String _query = '';

  Future<bool> _confirm(String title, String body, String action) async =>
      await showDialog<bool>(
        context: context,
        builder: (dialog) => AlertDialog(
          title: Text(title),
          content: Text(body),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialog).pop(false),
              child: Text(context.l10n.cancel),
            ),
            FilledButton(
              key: const Key('confirm-action'),
              onPressed: () => Navigator.of(dialog).pop(true),
              child: Text(action),
            ),
          ],
        ),
      ) ??
      false;

  Future<void> _remove(String workspaceId, Member member) async {
    final ok = await _confirm(
      context.l10n.grpJRemoveMemberTitle(member.label),
      context.l10n.grpJRemoveMemberBody,
      context.l10n.grpJRemove,
    );
    if (!ok || !mounted) return;
    final removed = await runWithFeedback(
      context,
      () => ref
          .read(membersClientProvider)
          .removeMember(workspaceId, member.userId),
    );
    if (removed) ref.invalidate(membersProvider);
  }

  void _showProfile(String workspaceId, Member m) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheet) => SafeArea(
        child: Padding(
          key: const Key('member-profile'),
          padding: const EdgeInsetsDirectional.fromSTEB(24, 0, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(radius: 32, child: Text(m.initials)),
              const SizedBox(height: 12),
              Text(m.label, style: Theme.of(sheet).textTheme.titleLarge),
              Text(m.email),
              Text(context.l10n.grpJJoined(formatDate(m.joinedAt))),
              const SizedBox(height: 8),
              RolePicker(
                key: const Key('profile-role'),
                member: m,
                onChanged: () => Navigator.of(sheet).pop(),
              ),
              if (!m.isOwner)
                PermissionGate(
                  permission: Perm.memberRemove,
                  child: TextButton.icon(
                    key: const Key('profile-remove'),
                    icon: const Icon(Icons.person_remove),
                    label: Text(context.l10n.grpJRemoveFromWorkspace),
                    onPressed: () {
                      Navigator.of(sheet).pop();
                      _remove(workspaceId, m);
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _leave(String workspaceId, String name) async {
    final ok = await _confirm(
      context.l10n.grpJLeaveTitle(name),
      context.l10n.grpJLeaveBody,
      context.l10n.grpJLeave,
    );
    if (!ok || !mounted) return;
    final left = await runWithFeedback(
      context,
      () => ref.read(membersClientProvider).leave(workspaceId),
    );
    if (!left || !mounted) return;
    ref.read(workspacesProvider.notifier).forget(workspaceId);
    // The router's zero-workspace guard sends the user to onboarding if none remain.
    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    final workspace = ref.watch(currentWorkspaceProvider);
    final members = ref.watch(membersProvider);
    if (workspace == null) return const SizedBox.shrink();
    return members.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: TextButton(
          key: const Key('retry-members'),
          onPressed: () => ref.invalidate(membersProvider),
          child: Text(context.l10n.grpJErrorRetry(inviteErrorMessage(e))),
        ),
      ),
      data: (all) {
        final q = _query.trim().toLowerCase();
        final shown = [
          for (final m in all)
            if (q.isEmpty ||
                m.displayName.toLowerCase().contains(q) ||
                m.email.toLowerCase().contains(q))
              m,
        ];
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextField(
              key: const Key('member-search'),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                labelText: context.l10n.grpJSearchMembers,
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
            const SizedBox(height: 8),
            for (final m in shown)
              ListTile(
                key: Key('member-${m.userId}'),
                onTap: () => _showProfile(workspace.id, m),
                leading: CircleAvatar(child: Text(m.initials)),
                title: Text(m.label),
                subtitle: Text(
                  '${context.l10n.grpJJoined(formatDate(m.joinedAt))}'
                  '${m.displayName.isEmpty ? '' : ' · ${m.email}'}',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RolePicker(key: Key('role-${m.userId}'), member: m),
                    if (!m.isOwner)
                      PermissionGate(
                        permission: Perm.memberRemove,
                        child: IconButton(
                          key: Key('remove-${m.userId}'),
                          tooltip: context.l10n.grpJRemoveMember(m.label),
                          icon: const Icon(Icons.person_remove),
                          onPressed: () => _remove(workspace.id, m),
                        ),
                      ),
                  ],
                ),
              ),
            const Divider(),
            if (workspace.isOwner)
              ListTile(
                key: const Key('owner-cannot-leave'),
                leading: const Icon(Icons.info_outline),
                title: Text(context.l10n.grpJOwnerCannotLeave),
              )
            else
              OutlinedButton(
                key: const Key('leave-workspace'),
                onPressed: () => _leave(workspace.id, workspace.name),
                child: Text(context.l10n.grpJLeaveWorkspace),
              ),
          ],
        );
      },
    );
  }
}
