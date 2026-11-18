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
import 'package:taskforge/features/developer/application/developer_providers.dart';
import 'package:taskforge/features/developer/domain/developer.dart';
import 'package:taskforge/features/developer/presentation/token_dialogs.dart';
import 'package:taskforge/features/developer/presentation/webhooks_tab.dart';
import 'package:taskforge/features/roles/application/roles_providers.dart';
import 'package:taskforge/features/roles/domain/roles.dart';
import 'package:taskforge/features/workspaces/application/workspace_providers.dart';
import 'package:taskforge/core/ui/tf/tf_feedback.dart';

/// A readable date for an ISO instant, in the person's calendar and digits.
String whenText(BuildContext context, String iso) {
  final at = DateTime.tryParse(iso);
  return at == null ? '' : context.localIso(at.toLocal());
}

void sayDeveloper(BuildContext context, String text) =>
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));

/// Settings, Developer: the caller's API tokens and the workspace's webhooks.
class DeveloperScreen extends ConsumerWidget {
  const DeveloperScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canHooks = ref.watch(permissionSetProvider).can(Perm.webhookManage);
    return DefaultTabController(
      length: canHooks ? 2 : 1,
      child: Scaffold(
        appBar: TfAppBar(
          leading: TfIconButton(
            key: const Key('back-settings'),
            icon: TfIcons.arrowStart,
            tooltip: context.l10n.grpEBack,
            onPressed: () => context.go('/workspaces/settings'),
          ),
          title: Text(context.l10n.devTitle),
          bottom: TabBar(
            tabs: [
              Tab(text: context.l10n.devTokensTab),
              if (canHooks) Tab(text: context.l10n.devWebhooksTab),
            ],
          ),
        ),
        body: TabBarView(
          children: [const _TokensTab(), if (canHooks) const WebhooksTab()],
        ),
      ),
    );
  }
}

class _TokensTab extends ConsumerWidget {
  const _TokensTab();

  Future<void> _create(BuildContext context, WidgetRef ref) async {
    final ws = ref.read(workspaceScopeProvider);
    if (ws == null) return;
    final issued = await showCreateTokenDialog(context, ref, ws);
    if (issued == null || !context.mounted) return;
    ref.invalidate(apiTokensProvider);
    await showSecretDialog(context, issued);
  }

  Future<void> _revoke(
    BuildContext context,
    WidgetRef ref,
    ApiToken token,
  ) async {
    final ws = ref.read(workspaceScopeProvider);
    if (ws == null) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => TfDialogFrame(
        title: c.l10n.devTokenRevokeTitle(token.name),
        content: Text(c.l10n.devTokenRevokeBody),
        actions: [
          TfButton(
            label: c.l10n.grpCCancel,
            variant: TfButtonVariant.ghost,
            onPressed: () => Navigator.of(c).pop(false),
          ),
          TfButton(
            key: const Key('confirm-revoke'),
            label: c.l10n.devTokenRevoke,
            variant: TfButtonVariant.primary,
            onPressed: () => Navigator.of(c).pop(true),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    try {
      await ref.read(developerClientProvider).revokeToken(ws, token.id);
    } on DeveloperException catch (e) {
      if (context.mounted) {
        sayDeveloper(context, developerErrorMessage(e, context.l10n));
      }
    }
    ref.invalidate(apiTokensProvider);
  }

  String _status(BuildContext context, ApiToken t) => switch (t.status) {
    'revoked' => context.l10n.devTokenRevoked,
    'expired' => context.l10n.devTokenExpired,
    _ => context.l10n.devTokenActive,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = ref.watch(apiTokensProvider);
    return tokens.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => TfError(
        details: '$e',
        retryKey: const Key('retry-tokens'),
        onRetry: () => ref.invalidate(apiTokensProvider),
      ),
      data: (rows) => TfPage(
        children: [
          Text(context.l10n.devTokensHint),
          const SizedBox(height: 12),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TfButton(
              key: const Key('new-token'),
              label: context.l10n.devTokenNew,
              variant: TfButtonVariant.primary,
              icon: TfIcons.plus,
              onPressed: () => _create(context, ref),
            ),
          ),
          const SizedBox(height: 8),
          if (rows.isEmpty)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text(context.l10n.devTokensEmpty),
            ),
          for (final t in rows)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: TfSpace.xs),
              child: TfPanel(
                padding: EdgeInsets.zero,
                child: TfRow(
                  key: Key('token-${t.id}'),
                  title: t.name,
                  subtitle: [
                    context.l10n.devTokenPrefix(t.prefix),
                    _status(context, t),
                    t.lastUsedAt.isEmpty
                        ? context.l10n.devTokenNeverUsed
                        : context.l10n.devTokenUsed(
                            whenText(context, t.lastUsedAt),
                          ),
                  ].join(' · '),
                  leading: const TfIcon(TfIcons.key),
                  trailing: t.isActive
                      ? TfButton(
                          key: Key('revoke-${t.id}'),
                          label: context.l10n.devTokenRevoke,
                          variant: TfButtonVariant.ghost,
                          onPressed: () => _revoke(context, ref, t),
                        )
                      : null,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
