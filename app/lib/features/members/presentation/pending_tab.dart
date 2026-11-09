import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/core/config.dart';
import 'package:taskforge/features/members/application/members_providers.dart';
import 'package:taskforge/features/members/domain/members.dart';
import 'package:taskforge/features/members/presentation/members_screen.dart';
import 'package:taskforge/features/roles/domain/roles.dart';
import 'package:taskforge/features/roles/presentation/permission_gate.dart';
import 'package:taskforge/features/workspaces/application/workspace_providers.dart';

String stateLabel(InviteState s) => switch (s) {
  InviteState.valid => 'Pending',
  InviteState.expired => 'Expired',
  InviteState.revoked => 'Revoked',
  InviteState.usedUp => 'Used up',
};

Future<void> copyInviteLink(BuildContext context, String token) async {
  await Clipboard.setData(ClipboardData(text: AppConfig.inviteUrl(token)));
  if (context.mounted) {
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Link copied.')));
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
      error: (e, _) => Center(
        child: TextButton(
          key: const Key('retry-invitations'),
          onPressed: () => ref.invalidate(invitationsProvider),
          child: Text('${inviteErrorMessage(e)} Retry'),
        ),
      ),
      data: (all) => all.isEmpty
          ? const Center(child: Text('No invitations yet.'))
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
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Invitation resent.')));
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
        ? '${i.uses} uses'
        : '${i.uses}/${i.maxUses} uses';
    return ListTile(
      key: Key('invite-${i.id}'),
      leading: Icon(i.isLink ? Icons.link : Icons.mail_outline),
      title: Text(i.isLink ? 'Invite link' : i.email),
      subtitle: Text(
        '${i.isLink ? '$uses · ' : ''}by ${i.createdByName} · '
        'expires ${formatDate(i.expiresAt)}',
      ),
      trailing: Wrap(
        spacing: 4,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          if (i.roleName.isNotEmpty)
            Chip(key: Key('role-${i.id}'), label: Text(i.roleName)),
          Chip(key: Key('state-${i.id}'), label: Text(stateLabel(i.state))),
          PermissionGate(
            permission: Perm.memberInvite,
            child: Wrap(
              children: [
                if (i.isLink && token.isNotEmpty && live)
                  IconButton(
                    key: Key('copy-${i.id}'),
                    tooltip: 'Copy link',
                    icon: const Icon(Icons.copy),
                    onPressed: () => copyInviteLink(context, token),
                  ),
                if (!i.isLink && i.state != InviteState.revoked)
                  IconButton(
                    key: Key('resend-${i.id}'),
                    tooltip: 'Resend',
                    icon: const Icon(Icons.send),
                    onPressed: () => _resend(context, ref),
                  ),
                if (live)
                  IconButton(
                    key: Key('revoke-${i.id}'),
                    tooltip: 'Revoke',
                    icon: const Icon(Icons.block),
                    onPressed: () => _revoke(context, ref),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
