import 'package:taskforge/features/members/data/members_client.dart';
import 'package:taskforge/features/members/domain/members.dart';
import 'package:taskforge/features/workspaces/domain/workspace.dart';

Member member(String id, String name, {bool owner = false}) => Member(
  userId: id,
  displayName: name,
  email: '${name.toLowerCase().replaceAll(' ', '.')}@example.com',
  isOwner: owner,
  joinedAt: DateTime.utc(2026, 3, 4),
);

Invitation invitation(
  String id, {
  String email = '',
  InviteState state = InviteState.valid,
  String token = '',
}) => Invitation(
  id: id,
  email: email,
  isLink: email.isEmpty,
  createdByName: 'Zoe',
  expiresAt: DateTime.utc(2026, 4, 1),
  maxUses: email.isEmpty ? 0 : 1,
  uses: 0,
  state: state,
  token: token,
);

class FakeMembersClient implements MembersClient {
  FakeMembersClient({
    List<Member> members = const [],
    List<Invitation> invitations = const [],
  }) : members = [...members],
       invitations = [...invitations];

  final List<Member> members;
  final List<Invitation> invitations;
  final removed = <String>[];
  final invitedBatches = <List<String>>[];
  final accepted = <String>[];
  final declined = <String>[];
  final links = <({int expiresIn, int maxUses})>[];
  final resent = <String>[];
  int leaves = 0;
  List<String> skipped = const [];
  InviteException? failNext;
  InviteException? acceptFails;
  InvitePreview? previewResult;
  InviteException? previewFails;
  Workspace? joins;

  void _maybeFail() {
    final e = failNext;
    failNext = null;
    if (e != null) throw e;
  }

  @override
  Future<List<Member>> listMembers(String workspaceId) async => [...members];

  @override
  Future<void> removeMember(String workspaceId, String userId) async {
    _maybeFail();
    removed.add(userId);
    members.removeWhere((m) => m.userId == userId);
  }

  @override
  Future<void> leave(String workspaceId) async {
    _maybeFail();
    leaves++;
  }

  @override
  Future<InviteResult> invite(String workspaceId, List<String> emails) async {
    _maybeFail();
    invitedBatches.add(emails);
    final created = [
      for (final (i, e) in emails.indexed) invitation('n$i', email: e),
    ];
    invitations.addAll([
      for (final c in created) invitation(c.id, email: c.email),
    ]);
    return InviteResult(invitations: created, skippedEmails: skipped);
  }

  @override
  Future<Invitation> createLink(
    String workspaceId, {
    required int expiresIn,
    required int maxUses,
  }) async {
    _maybeFail();
    links.add((expiresIn: expiresIn, maxUses: maxUses));
    return invitation('link1', token: 'linktok');
  }

  @override
  Future<List<Invitation>> listInvitations(String workspaceId) async => [
    ...invitations,
  ];

  @override
  Future<Invitation> revoke(String workspaceId, String id) async {
    _maybeFail();
    final i = invitations.indexWhere((x) => x.id == id);
    return invitations[i] = invitation(
      id,
      email: invitations[i].email,
      state: InviteState.revoked,
    );
  }

  @override
  Future<Invitation> resend(String workspaceId, String id) async {
    _maybeFail();
    resent.add(id);
    return invitation(id, email: 'x@example.com');
  }

  @override
  Future<InvitePreview> preview(String token) async {
    final e = previewFails;
    if (e != null) throw e;
    return previewResult ??
        const InvitePreview(
          workspaceName: 'Globex',
          inviterName: 'Hank',
          emailBound: false,
          state: InviteState.valid,
        );
  }

  @override
  Future<Workspace> accept(String token) async {
    final e = acceptFails;
    if (e != null) throw e;
    accepted.add(token);
    return joins ??
        const Workspace(id: 'wG', name: 'Globex', slug: 'globex', version: 1);
  }

  @override
  Future<void> decline(String token) async => declined.add(token);
}
