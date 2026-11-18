import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/core/config.dart';
import 'package:taskforge/core/i18n/context_dates.dart';
import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/l10n/gen/app_localizations.dart';
import 'package:taskforge/features/members/application/members_providers.dart';
import 'package:taskforge/features/members/domain/members.dart';
import 'package:taskforge/features/members/presentation/members_screen.dart';
import 'package:taskforge/features/roles/domain/roles.dart';
import 'package:taskforge/features/roles/presentation/permission_gate.dart';
import 'package:taskforge/features/workspaces/application/workspace_providers.dart';
import 'package:taskforge/core/ui/tf/tf_feedback.dart';

String stateLabel(InviteState s, [AppLocalizations? l10n]) {
  final t = l10n ?? lookupAppLocalizations(const Locale('en'));
  return switch (s) {
    InviteState.valid => t.grpJStatePending,
    InviteState.expired => t.grpJStateExpired,
    InviteState.revoked => t.grpJStateRevoked,
    InviteState.usedUp => t.grpJStateUsedUp,
  };
}

Future<void> copyInviteLink(BuildContext context, String token) async {
  await Clipboard.setData(ClipboardData(text: AppConfig.inviteUrl(token)));
  if (context.mounted) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(context.l10n.grpJLinkCopied)));
  }
}

class PendingTab extends ConsumerWidget {
  const PendingTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invitations = ref.watch(invitationsProvider);
    final tokens = ref.watch(knownTokensProvider);
    final workspaceId = ref.watch(workspaceScopeProvider);
    return invitations.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => TfError(
        message: inviteErrorMessage(e, context.l10n),
        details: '$e',
        retryKey: const Key('retry-invitations'),
        onRetry: () => ref.invalidate(invitationsProvider),
      ),
      data: (all) => all.isEmpty
          ? TfEmpty(title: context.l10n.grpJNoInvitations)
          : ListView(
              children: [
                for (final i in all)
                  _InvitationTile(
                    invitation: i,
                    token: i.token.isNotEmpty ? i.token : tokens[i.id] ?? '',
                    workspaceId: workspaceId!,
                  ),
              ],
            ),
    );
  }
}

class _InvitationTile extends ConsumerWidget {
  const _InvitationTile({
    required this.invitation,
    required this.token,
    required this.workspaceId,
  });

  final Invitation invitation;
  final String token;
  final String workspaceId;

  Future<void> _resend(BuildContext context, WidgetRef ref) async {
    final client = ref.read(membersClientProvider);
    final sent = await runWithFeedback(context, () async {
      final fresh = await client.resend(workspaceId, invitation.id);
      ref.read(knownTokensProvider.notifier).remember(fresh);
    });
    if (sent) ref.invalidate(invitationsProvider);
    if (sent && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.grpJInvitationResent)),
      );
    }
  }

  Future<void> _revoke(BuildContext context, WidgetRef ref) async {
    final revoked = await runWithFeedback(
      context,
      () => ref.read(membersClientProvider).revoke(workspaceId, invitation.id),
    );
    if (revoked) ref.invalidate(invitationsProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final i = invitation;
    final live = i.state == InviteState.valid;
    final uses = i.maxUses == 0
        ? context.l10n.grpJUsesCount(i.uses)
        : context.l10n.grpJUsesOfMax(i.uses, i.maxUses);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        key: Key('invite-${i.id}'),
        leading: Icon(i.isLink ? Icons.link : Icons.mail_outline),
        title: Text(i.isLink ? context.l10n.grpJInviteLink : i.email),
        subtitle: Text(
          '${i.isLink ? '$uses · ' : ''}'
          '${context.l10n.grpJInvitationMeta(i.createdByName, context.localDateOrEmpty(i.expiresAt))}',
        ),
        trailing: Wrap(
          spacing: 4,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            if (i.roleName.isNotEmpty)
              Chip(key: Key('role-${i.id}'), label: Text(i.roleName)),
            Chip(
              key: Key('state-${i.id}'),
              label: Text(stateLabel(i.state, context.l10n)),
            ),
            PermissionGate(
              permission: Perm.memberInvite,
              child: Wrap(
                children: [
                  if (i.isLink && token.isNotEmpty && live)
                    IconButton(
                      key: Key('copy-${i.id}'),
                      tooltip: context.l10n.grpJCopyLink,
                      icon: const Icon(Icons.copy),
                      onPressed: () => copyInviteLink(context, token),
                    ),
                  if (!i.isLink && i.state != InviteState.revoked)
                    IconButton(
                      key: Key('resend-${i.id}'),
                      tooltip: context.l10n.grpJResend,
                      icon: const Icon(Icons.send),
                      onPressed: () => _resend(context, ref),
                    ),
                  if (live)
                    IconButton(
                      key: Key('revoke-${i.id}'),
                      tooltip: context.l10n.grpJRevoke,
                      icon: const Icon(Icons.block),
                      onPressed: () => _revoke(context, ref),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
