import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/core/auth/auth_providers.dart';
import 'package:taskforge/core/config.dart';
import 'package:taskforge/core/grpc/grpc_providers.dart';
import 'package:taskforge/features/members/data/members_client.dart';
import 'package:taskforge/features/members/domain/members.dart';
import 'package:taskforge/features/workspaces/application/workspace_providers.dart';

final membersClientProvider = Provider<MembersClient>(
  (ref) => GrpcMembersClient(
    ref.watch(grpcChannelProvider),
    ref.watch(authSessionProvider),
    restUrl: AppConfig.restUrl,
  ),
);

/// Members of the current workspace; rebuilt on a workspace switch.
final membersProvider = FutureProvider.autoDispose<List<Member>>((ref) async {
  final id = ref.watch(workspaceScopeProvider);
  if (id == null) return const [];
  return ref.watch(membersClientProvider).listMembers(id);
});

/// Invitations of the current workspace (never carries tokens).
final invitationsProvider = FutureProvider.autoDispose<List<Invitation>>((
  ref,
) async {
  final id = ref.watch(workspaceScopeProvider);
  if (id == null) return const [];
  return ref.watch(membersClientProvider).listInvitations(id);
});

/// Link-invitation tokens seen this session, by invitation id; the server only
/// returns a token once, and never for email invitations.
final knownTokensProvider = NotifierProvider<KnownTokens, Map<String, String>>(
  KnownTokens.new,
);

class KnownTokens extends Notifier<Map<String, String>> {
  @override
  Map<String, String> build() => const {};

  void remember(Invitation invitation) {
    if (invitation.token.isEmpty) return;
    state = {...state, invitation.id: invitation.token};
  }
}

/// Public preview of an invitation link.
final invitePreviewProvider = FutureProvider.autoDispose
    .family<InvitePreview, String>(
      (ref, token) => ref.watch(membersClientProvider).preview(token),
      // Riverpod 3 retries failures; a dead link must show its message at once
      // (the screen has its own Retry button).
      retry: (_, _) => null,
    );
