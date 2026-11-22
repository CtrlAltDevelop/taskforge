import 'package:taskforge/core/ui/page/tf_page.dart';
import 'package:taskforge/core/ui/page/tf_dialog_frame.dart';
import 'package:taskforge/core/ui/page/tf_select_field.dart';
import 'package:taskforge/core/ui/tokens/spacing.dart';
import 'package:taskforge/core/ui/tf/tf_row.dart';
import 'package:taskforge/core/ui/tf/tf_panel.dart';
import 'package:taskforge/core/ui/tf/tf_button.dart';
import 'package:taskforge/core/ui/tf/tf_feedback.dart';
import 'package:taskforge/core/ui/tf_icons.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/features/developer/application/developer_providers.dart';
import 'package:taskforge/features/developer/domain/developer.dart';
import 'package:taskforge/features/developer/presentation/developer_screen.dart';
import 'package:taskforge/features/developer/presentation/token_dialogs.dart';
import 'package:taskforge/features/roles/application/roles_providers.dart';
import 'package:taskforge/features/roles/domain/roles.dart';
import 'package:taskforge/features/workspaces/application/workspace_providers.dart';

/// The role name the server never lets a service account hold.
const _ownerRole = 'Owner';

/// The roles a service account may be given: every one but the owner's.
Map<String, String> assignableRoles(RoleCatalog catalog) => {
  for (final r in catalog.roles)
    if (!(r.isBuiltin && r.name == _ownerRole)) r.id: r.name,
};

/// Settings, Developer, Service accounts: identities for integrations, each
/// with a role and its own tokens.
class ServiceAccountsTab extends ConsumerWidget {
  const ServiceAccountsTab({super.key});

  Future<void> _run(
    BuildContext context,
    WidgetRef ref,
    Future<void> Function(String ws) call,
  ) async {
    final ws = ref.read(workspaceScopeProvider);
    if (ws == null) return;
    try {
      await call(ws);
    } on DeveloperException catch (e) {
      if (context.mounted) {
        sayDeveloper(context, developerErrorMessage(e, context.l10n));
      }
    }
    ref.invalidate(serviceAccountsProvider);
  }

  Future<void> _create(BuildContext context, WidgetRef ref) async {
    final draft = await showDialog<({String name, String roleId})>(
      context: context,
      builder: (_) => const _AccountDialog(),
    );
    if (draft == null || !context.mounted) return;
    await _run(
      context,
      ref,
      (ws) => ref
          .read(developerClientProvider)
          .createServiceAccount(ws, name: draft.name, roleId: draft.roleId),
    );
  }

  Future<void> _setRole(
    BuildContext context,
    WidgetRef ref,
    ServiceAccount account,
  ) async {
    final draft = await showDialog<({String name, String roleId})>(
      context: context,
      builder: (_) => _AccountDialog(account: account),
    );
    if (draft == null || !context.mounted) return;
    await _run(
      context,
      ref,
      (ws) => ref
          .read(developerClientProvider)
          .setServiceAccountRole(ws, account.id, draft.roleId),
    );
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    ServiceAccount account,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => TfDialogFrame(
        title: c.l10n.devAccountDeleteTitle(account.name),
        content: Text(c.l10n.devAccountDeleteBody),
        actions: [
          TfButton(
            label: c.l10n.grpCCancel,
            variant: TfButtonVariant.ghost,
            onPressed: () => Navigator.of(c).pop(false),
          ),
          TfButton(
            key: const Key('confirm-delete-account'),
            label: c.l10n.devAccountDelete,
            variant: TfButtonVariant.primary,
            onPressed: () => Navigator.of(c).pop(true),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    await _run(
      context,
      ref,
      (ws) => ref
          .read(developerClientProvider)
          .deleteServiceAccount(ws, account.id),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accounts = ref.watch(serviceAccountsProvider);
    return accounts.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => TfError(
        details: '$e',
        retryKey: const Key('retry-accounts'),
        onRetry: () => ref.invalidate(serviceAccountsProvider),
      ),
      data: (rows) => TfPage(
        children: [
          Text(context.l10n.devAccountsHint),
          const SizedBox(height: TfSpace.md),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TfButton(
              key: const Key('new-account'),
              label: context.l10n.devAccountNew,
              variant: TfButtonVariant.primary,
              icon: TfIcons.plus,
              onPressed: () => _create(context, ref),
            ),
          ),
          const SizedBox(height: TfSpace.sm),
          if (rows.isEmpty)
            Padding(
              padding: const EdgeInsets.all(TfSpace.xl),
              child: Text(context.l10n.devAccountsEmpty),
            ),
          for (final a in rows)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: TfSpace.xs),
              child: TfPanel(
                padding: EdgeInsets.zero,
                child: TfRow(
                  key: Key('account-${a.id}'),
                  title: a.name,
                  subtitle: context.l10n.devAccountSubtitle(
                    a.roleName,
                    a.tokenCount,
                  ),
                  leading: const TfIcon(TfIcons.key),
                  trailing: Wrap(
                    spacing: TfSpace.xs,
                    children: [
                      TfButton(
                        key: Key('account-tokens-${a.id}'),
                        label: context.l10n.devAccountTokens,
                        variant: TfButtonVariant.ghost,
                        onPressed: () => showAccountTokens(context, ref, a),
                      ),
                      TfButton(
                        key: Key('account-role-${a.id}'),
                        label: context.l10n.devAccountChangeRole,
                        variant: TfButtonVariant.ghost,
                        onPressed: () => _setRole(context, ref, a),
                      ),
                      TfButton(
                        key: Key('account-delete-${a.id}'),
                        label: context.l10n.devAccountDelete,
                        variant: TfButtonVariant.ghost,
                        onPressed: () => _delete(context, ref, a),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Create (no [account]) or change the role of one: name and role.
class _AccountDialog extends ConsumerStatefulWidget {
  const _AccountDialog({this.account});

  final ServiceAccount? account;

  @override
  ConsumerState<_AccountDialog> createState() => _AccountDialogState();
}

class _AccountDialogState extends ConsumerState<_AccountDialog> {
  late final _name = TextEditingController(text: widget.account?.name ?? '');
  late String? _roleId = widget.account?.roleId;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.account != null;
    final roles = ref
        .watch(rolesProvider)
        .maybeWhen(data: assignableRoles, orElse: () => <String, String>{});
    final ready =
        _roleId != null &&
        roles.containsKey(_roleId) &&
        _name.text.trim().isNotEmpty;
    return TfDialogFrame(
      title: editing
          ? context.l10n.devAccountChangeRole
          : context.l10n.devAccountNew,
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              key: const Key('account-name'),
              controller: _name,
              enabled: !editing,
              maxLength: 80,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: context.l10n.devAccountName,
              ),
            ),
            const SizedBox(height: TfSpace.sm),
            TfSelectField<String>(
              key: const Key('account-role'),
              options: roles,
              value: _roleId,
              onChanged: (v) => setState(() => _roleId = v),
              label: context.l10n.devAccountRole,
              expand: true,
              itemKey: (id) => Key('account-role-option-$id'),
            ),
          ],
        ),
      ),
      actions: [
        TfButton(
          label: context.l10n.grpCCancel,
          variant: TfButtonVariant.ghost,
          onPressed: () => Navigator.of(context).pop(),
        ),
        TfButton(
          key: const Key('save-account'),
          label: editing
              ? context.l10n.devAccountSave
              : context.l10n.devAccountCreate,
          variant: TfButtonVariant.primary,
          onPressed: ready
              ? () =>
                    Navigator.of(context)
                        .pop((name: _name.text.trim(), roleId: _roleId!))
              : null,
        ),
      ],
    );
  }
}

/// One account's tokens: list, revoke, and make one (shown once).
Future<void> showAccountTokens(
  BuildContext context,
  WidgetRef ref,
  ServiceAccount account,
) async {
  await showDialog<void>(
    context: context,
    builder: (_) => _AccountTokensDialog(account: account),
  );
  ref.invalidate(serviceAccountsProvider);
}

class _AccountTokensDialog extends ConsumerWidget {
  const _AccountTokensDialog({required this.account});

  final ServiceAccount account;

  Future<void> _create(BuildContext context, WidgetRef ref) async {
    final ws = ref.read(workspaceScopeProvider);
    if (ws == null) return;
    final issued = await showCreateTokenDialog(
      context,
      ref,
      ws,
      serviceAccountId: account.id,
    );
    if (issued == null || !context.mounted) return;
    ref.invalidate(serviceAccountTokensProvider(account.id));
    await showSecretDialog(context, issued);
  }

  Future<void> _revoke(BuildContext context, WidgetRef ref, ApiToken t) async {
    final ws = ref.read(workspaceScopeProvider);
    if (ws == null) return;
    try {
      await ref.read(developerClientProvider).revokeToken(ws, t.id);
    } on DeveloperException catch (e) {
      if (context.mounted) {
        sayDeveloper(context, developerErrorMessage(e, context.l10n));
      }
    }
    ref.invalidate(serviceAccountTokensProvider(account.id));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = ref.watch(serviceAccountTokensProvider(account.id));
    return TfDialogFrame(
      title: context.l10n.devAccountTokensTitle(account.name),
      content: SizedBox(
        width: 460,
        child: tokens.when(
          loading: () => const LinearProgressIndicator(),
          error: (e, _) => TfError(
            details: '$e',
            onRetry: () =>
                ref.invalidate(serviceAccountTokensProvider(account.id)),
          ),
          data: (rows) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (rows.isEmpty) Text(context.l10n.devAccountTokensEmpty),
              for (final t in rows)
                TfRow(
                  key: Key('account-token-${t.id}'),
                  title: t.name,
                  subtitle: [
                    context.l10n.devTokenPrefix(t.prefix),
                    switch (t.status) {
                      'revoked' => context.l10n.devTokenRevoked,
                      'expired' => context.l10n.devTokenExpired,
                      _ => context.l10n.devTokenActive,
                    },
                  ].join(' · '),
                  leading: const TfIcon(TfIcons.key),
                  trailing: t.isActive
                      ? TfButton(
                          key: Key('account-revoke-${t.id}'),
                          label: context.l10n.devTokenRevoke,
                          variant: TfButtonVariant.ghost,
                          onPressed: () => _revoke(context, ref, t),
                        )
                      : null,
                ),
            ],
          ),
        ),
      ),
      actions: [
        TfButton(
          key: const Key('new-account-token'),
          label: context.l10n.devTokenNew,
          variant: TfButtonVariant.ghost,
          icon: TfIcons.plus,
          onPressed: () => _create(context, ref),
        ),
        TfButton(
          label: context.l10n.devDone,
          variant: TfButtonVariant.primary,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}
