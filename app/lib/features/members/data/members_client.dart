import 'dart:convert';

import 'package:grpc/grpc.dart' show GrpcError, StatusCode;
import 'package:grpc/grpc_connection_interface.dart' show ClientChannelBase;
import 'package:http/http.dart' as http;

import 'package:taskforge/core/auth/auth_session.dart';
import 'package:taskforge/core/permissions/permission_denied.dart';
import 'package:taskforge/core/workspace/scoped_requests.dart';
import 'package:taskforge/features/members/domain/members.dart';
import 'package:taskforge/features/workspaces/domain/workspace.dart';
import 'package:taskforge/core/offline/read_cache.dart';
import 'package:taskforge/gen/infrastructure/workspaces/grpc/workspaces.pbgrpc.dart'
    as pb;

abstract interface class MembersClient {
  Future<List<Member>> listMembers(String workspaceId);
  Future<void> removeMember(String workspaceId, String userId);
  Future<Member> setRole(String workspaceId, String userId, String roleId);
  Future<void> leave(String workspaceId);

  Future<InviteResult> invite(
    String workspaceId,
    List<String> emails, {
    String roleId = '',
  });

  /// [expiresIn] in seconds (0 = server default); [maxUses] 0 = unlimited.
  Future<Invitation> createLink(
    String workspaceId, {
    required int expiresIn,
    required int maxUses,
    String roleId = '',
  });
  Future<List<Invitation>> listInvitations(String workspaceId);
  Future<Invitation> revoke(String workspaceId, String id);
  Future<Invitation> resend(String workspaceId, String id);

  /// Public: no session needed.
  Future<InvitePreview> preview(String token);
  Future<Workspace> accept(String token);
  Future<void> decline(String token);
}

/// Maps a transport failure to an [InviteException]. The gRPC message starts
/// with a `TITLE: ` that tells the not-found cases apart, so it is read here,
/// before [stripErrorTitle] would drop it.
InviteException mapInviteError(Object error) {
  if (error is InviteException) return error;
  if (error is GrpcError) {
    final message = error.message ?? '';
    final title = RegExp(r'^([A-Z][A-Z0-9_]*): ').firstMatch(message)?.group(1);
    final denied = parsePermissionDenied(error);
    return switch (error.code) {
      StatusCode.notFound => InviteException(switch (title) {
        'INVITE_EXPIRED' => InviteFailure.expired,
        'INVITE_REVOKED' => InviteFailure.revoked,
        'INVITE_USED_UP' => InviteFailure.usedUp,
        'INVITE_BEFORE_REMOVAL' => InviteFailure.beforeRemoval,
        _ => InviteFailure.notFound,
      }),
      StatusCode.permissionDenied when denied != null => InviteException(
        InviteFailure.denied,
        denied.message,
      ),
      StatusCode.permissionDenied => InviteException(switch (title) {
        'OWNER_PROTECTED' => InviteFailure.ownerProtected,
        'INVITE_EMAIL_MISMATCH' => InviteFailure.emailMismatch,
        _ => InviteFailure.forbidden,
      }),
      StatusCode.resourceExhausted => const InviteException(
        InviteFailure.rateLimited,
      ),
      StatusCode.alreadyExists => const InviteException(InviteFailure.exists),
      StatusCode.invalidArgument => InviteException(
        InviteFailure.invalid,
        stripErrorTitle(message),
      ),
      StatusCode.unavailable || StatusCode.deadlineExceeded =>
        const InviteException(InviteFailure.network),
      _ => const InviteException(InviteFailure.other),
    };
  }
  if (error is http.ClientException) {
    return const InviteException(InviteFailure.network);
  }
  return const InviteException(InviteFailure.other);
}

Invitation _invitation(pb.Invitation i) => Invitation(
  id: i.id,
  email: i.email,
  isLink: i.isLink,
  createdByName: i.createdByName,
  expiresAt: DateTime.tryParse(i.expiresAt),
  maxUses: i.maxUses,
  uses: i.uses,
  state: parseInviteState(i.state),
  token: i.token,
  roleId: i.roleId,
  roleName: i.roleName,
);

Member _member(pb.Member m) => Member(
  userId: m.userId,
  displayName: m.displayName,
  email: m.email,
  isOwner: m.isOwner,
  roleId: m.roleId,
  roleName: m.roleName,
  joinedAt: DateTime.tryParse(m.joinedAt),
);

class GrpcMembersClient implements MembersClient {
  GrpcMembersClient(
    ClientChannelBase channel,
    this._session, {
    required this.restUrl,
    http.Client? httpClient,
    this.onRefusal,
    this.cache,
  }) : _members = pb.MemberControllerClient(channel),
       _invites = pb.InvitationControllerClient(channel),
       _http = httpClient ?? http.Client();

  final pb.MemberControllerClient _members;
  final pb.InvitationControllerClient _invites;
  final AuthSession _session;
  final String restUrl;
  final http.Client _http;

  /// Keeps the last member list for when the server cannot be reached.
  final ReadCache? cache;

  /// Called when a mutating call is refused (permissions may be stale).
  final void Function()? onRefusal;

  // The workspace id travels in each request body, so no x-workspace header.
  late final _options = scopedCallOptions(_session, () => null);

  /// Runs [call]; one refresh-and-retry when the token is rejected.
  Future<T> _run<T>(Future<T> Function() call, {bool isRead = false}) async {
    try {
      try {
        return await call();
      } on GrpcError catch (e) {
        if (e.code != StatusCode.unauthenticated) rethrow;
        if (await _session.forceRefresh() == null) rethrow;
        return await call();
      }
    } on Object catch (e) {
      final mapped = mapInviteError(e);
      if (!isRead &&
          (mapped.failure == InviteFailure.denied ||
              mapped.failure == InviteFailure.forbidden)) {
        onRefusal?.call();
      }
      throw mapped;
    }
  }

  @override
  Future<List<Member>> listMembers(String workspaceId) async {
    final reply = await _run(
      () => readThrough(
        cache,
        workspaceId,
        'members',
        () => _members.list(
          pb.MemberListRequest(workspaceId: workspaceId),
          options: _options,
        ),
        pb.MemberList.fromBuffer,
      ),
      isRead: true,
    );
    return [for (final m in reply.members) _member(m)];
  }

  @override
  Future<Member> setRole(
    String workspaceId,
    String userId,
    String roleId,
  ) async => _member(
    await _run(
      () => _members.setRole(
        pb.MemberSetRoleRequest(
          workspaceId: workspaceId,
          userId: userId,
          roleId: roleId,
        ),
        options: _options,
      ),
    ),
  );

  @override
  Future<void> removeMember(String workspaceId, String userId) async {
    await _run(
      () => _members.remove(
        pb.MemberRemoveRequest(workspaceId: workspaceId, userId: userId),
        options: _options,
      ),
    );
  }

  @override
  Future<void> leave(String workspaceId) async {
    await _run(
      () => _members.leave(
        pb.MemberLeaveRequest(workspaceId: workspaceId),
        options: _options,
      ),
    );
  }

  @override
  Future<InviteResult> invite(
    String workspaceId,
    List<String> emails, {
    String roleId = '',
  }) async {
    final reply = await _run(
      () => _invites.create(
        pb.InvitationCreateRequest(
          workspaceId: workspaceId,
          emails: emails,
          roleId: roleId,
        ),
        options: _options,
      ),
    );
    return InviteResult(
      invitations: [for (final i in reply.invitations) _invitation(i)],
      skippedEmails: [...reply.skippedEmails],
    );
  }

  @override
  Future<Invitation> createLink(
    String workspaceId, {
    required int expiresIn,
    required int maxUses,
    String roleId = '',
  }) async => _invitation(
    await _run(
      () => _invites.createLink(
        pb.InvitationCreateLinkRequest(
          workspaceId: workspaceId,
          expiresIn: expiresIn,
          maxUses: maxUses,
          roleId: roleId,
        ),
        options: _options,
      ),
    ),
  );

  @override
  Future<List<Invitation>> listInvitations(String workspaceId) async {
    final reply = await _run(
      () => _invites.list(
        pb.InvitationListRequest(workspaceId: workspaceId),
        options: _options,
      ),
      isRead: true,
    );
    return [for (final i in reply.invitations) _invitation(i)];
  }

  @override
  Future<Invitation> revoke(String workspaceId, String id) async => _invitation(
    await _run(
      () => _invites.revoke(
        pb.InvitationRevokeRequest(workspaceId: workspaceId, id: id),
        options: _options,
      ),
    ),
  );

  @override
  Future<Invitation> resend(String workspaceId, String id) async => _invitation(
    await _run(
      () => _invites.resend(
        pb.InvitationResendRequest(workspaceId: workspaceId, id: id),
        options: _options,
      ),
    ),
  );

  @override
  Future<Workspace> accept(String token) async {
    final w = await _run(
      () => _invites.accept(
        pb.InvitationAcceptRequest(token: token),
        options: _options,
      ),
    );
    return Workspace(
      id: w.id,
      name: w.name,
      slug: w.slug,
      logo: w.logo,
      version: w.version,
      isOwner: w.isOwner,
      defaultLocale: w.defaultLocale,
    );
  }

  @override
  Future<void> decline(String token) async {
    await _run(
      () => _invites.decline(
        pb.InvitationDeclineRequest(token: token),
        options: _options,
      ),
    );
  }

  @override
  Future<InvitePreview> preview(String token) async {
    try {
      final response = await _http.post(
        Uri.parse('$restUrl/api/v1/invites/preview'),
        headers: {'content-type': 'application/json'},
        body: jsonEncode({'token': token}),
      );
      if (response.statusCode == 404) {
        throw const InviteException(InviteFailure.notFound);
      }
      if (response.statusCode == 429) {
        throw const InviteException(InviteFailure.rateLimited);
      }
      if (response.statusCode >= 400) {
        throw const InviteException(InviteFailure.other);
      }
      final data =
          (jsonDecode(response.body) as Map<String, dynamic>)['data']
              as Map<String, dynamic>;
      return InvitePreview(
        workspaceName: data['workspace_name'] as String,
        inviterName: (data['inviter_name'] as String?) ?? '',
        emailBound: (data['email_bound'] as bool?) ?? false,
        state: parseInviteState((data['state'] as String?) ?? 'valid'),
      );
    } on Object catch (e) {
      throw mapInviteError(e);
    }
  }
}
