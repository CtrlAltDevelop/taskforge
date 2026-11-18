import 'package:taskforge/core/ui/tokens/spacing.dart';
import 'package:taskforge/core/ui/page/tf_page.dart';
import 'package:taskforge/core/ui/page/tf_dialog_frame.dart';
import 'package:taskforge/core/ui/tf/tf_row.dart';
import 'package:taskforge/core/ui/tf/tf_panel.dart';
import 'package:taskforge/core/ui/tf/tf_button.dart';
import 'package:taskforge/core/ui/tf_icons.dart';
import 'package:taskforge/core/ui/tf_app_bar.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:taskforge/core/i18n/context_dates.dart';
import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/features/members/application/members_providers.dart';
import 'package:taskforge/features/members/domain/members.dart';
import 'package:taskforge/features/members/presentation/invite_dialog.dart';
import 'package:taskforge/features/members/presentation/pending_tab.dart';
import 'package:taskforge/features/members/presentation/role_picker.dart';
import 'package:taskforge/features/roles/domain/roles.dart';
import 'package:taskforge/features/roles/presentation/permission_gate.dart';
import 'package:taskforge/features/workspaces/application/workspace_providers.dart';
import 'package:taskforge/core/ui/tf/tf_feedback.dart';

/// Runs [action]; shows the failure as a snackbar. True when it succeeded.
Future<bool> runWithFeedback(
  BuildContext context,
  Future<void> Function() action,
) async {
  final messenger = ScaffoldMessenger.of(context);
  final l10n = context.l10n;
  try {
    await action();
    return true;
  } on InviteException catch (e) {
    messenger.showSnackBar(
      SnackBar(content: Text(inviteErrorMessage(e, l10n))),
    );
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
        appBar: TfAppBar(
          leading: TfIconButton(
            key: const Key('back-home'),
            icon: TfIcons.arrowStart,
            tooltip: context.l10n.grpJBack,
            onPressed: () => context.go('/'),
          ),
          title: Text(context.l10n.grpJMembers),
          actions: [
            PermissionGate(
              permission: Perm.memberInvite,
              disabledWhenDenied: true,
              child: TfButton(
                key: const Key('open-invite'),
                label: context.l10n.grpJInvite,
                variant: TfButtonVariant.ghost,
                icon: TfIcons.userPlus,
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
        builder: (dialog) => TfDialogFrame(
          title: title,
          content: Text(body),
          actions: [
            TfButton(
              label: context.l10n.cancel,
              variant: TfButtonVariant.ghost,
              onPressed: () => Navigator.of(dialog).pop(false),
            ),
            TfButton(
              key: const Key('confirm-action'),
              label: action,
              variant: TfButtonVariant.primary,
              onPressed: () => Navigator.of(dialog).pop(true),
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
              Text(
                context.l10n.grpJJoined(context.localDateOrEmpty(m.joinedAt)),
              ),
              const SizedBox(height: 8),
              RolePicker(
                key: const Key('profile-role'),
                member: m,
                onChanged: () => Navigator.of(sheet).pop(),
              ),
              if (!m.isOwner)
                PermissionGate(
                  permission: Perm.memberRemove,
                  child: TfButton(
                    key: const Key('profile-remove'),
                    label: context.l10n.grpJRemoveFromWorkspace,
                    variant: TfButtonVariant.ghost,
                    icon: TfIcons.userMinus,
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
      error: (e, _) => TfError(
        message: inviteErrorMessage(e, context.l10n),
        details: '$e',
        retryKey: const Key('retry-members'),
        onRetry: () => ref.invalidate(membersProvider),
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
        return TfPage(
          maxWidth: TfPageWidth.wide,
          lazy: true,
          children: [
            TextField(
              key: const Key('member-search'),
              decoration: InputDecoration(
                prefixIcon: const TfIcon(TfIcons.search),
                labelText: context.l10n.grpJSearchMembers,
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
            const SizedBox(height: 8),
            for (final m in shown)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: TfSpace.xs),
                child: TfPanel(
                  padding: EdgeInsets.zero,
                  child: TfRow(
                    key: Key('member-${m.userId}'),
                    title: m.label,
                    subtitle:
                        '${context.l10n.grpJJoined(context.localDateOrEmpty(m.joinedAt))}'
                        '${m.displayName.isEmpty ? '' : ' · ${m.email}'}',
                    leading: CircleAvatar(child: Text(m.initials)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: RolePicker(
                            key: Key('role-${m.userId}'),
                            member: m,
                          ),
                        ),
                        if (!m.isOwner)
                          PermissionGate(
                            permission: Perm.memberRemove,
                            child: TfIconButton(
                              key: Key('remove-${m.userId}'),
                              icon: TfIcons.userMinus,
                              tooltip: context.l10n.grpJRemoveMember(m.label),
                              onPressed: () => _remove(workspace.id, m),
                            ),
                          ),
                      ],
                    ),
                    onTap: () => _showProfile(workspace.id, m),
                  ),
                ),
              ),
            const Divider(),
            if (workspace.isOwner)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: TfSpace.xs),
                child: TfPanel(
                  padding: EdgeInsets.zero,
                  child: TfRow(
                    key: const Key('owner-cannot-leave'),
                    title: context.l10n.grpJOwnerCannotLeave,
                    leading: const TfIcon(TfIcons.info),
                  ),
                ),
              )
            else
              TfButton(
                key: const Key('leave-workspace'),
                label: context.l10n.grpJLeaveWorkspace,
                onPressed: () => _leave(workspace.id, workspace.name),
              ),
          ],
        );
      },
    );
  }
}
