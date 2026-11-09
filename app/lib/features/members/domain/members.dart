import 'package:flutter/foundation.dart';

const maxInviteEmails = 20;
const maxLinkUses = 1000;

@immutable
class Member {
  const Member({
    required this.userId,
    required this.displayName,
    required this.email,
    required this.isOwner,
    this.joinedAt,
  });

  final String userId;
  final String displayName;
  final String email;
  final bool isOwner;
  final DateTime? joinedAt;

  /// Name shown to people; falls back to the email when none was set.
  String get label => displayName.isEmpty ? email : displayName;

  /// Up to two letters for the avatar.
  String get initials {
    final words = label.trim().split(RegExp(r'\s+'));
    final letters = words.length > 1
        ? '${words.first[0]}${words.last[0]}'
        : words.first.substring(0, words.first.length > 1 ? 2 : 1);
    return letters.toUpperCase();
  }
}

enum InviteState { valid, expired, revoked, usedUp }

InviteState parseInviteState(String raw) => switch (raw) {
  'expired' => InviteState.expired,
  'revoked' => InviteState.revoked,
  'used_up' => InviteState.usedUp,
  _ => InviteState.valid,
};

@immutable
class Invitation {
  const Invitation({
    required this.id,
    required this.email,
    required this.isLink,
    required this.createdByName,
    required this.expiresAt,
    required this.maxUses,
    required this.uses,
    required this.state,
    this.token = '',
  });

  final String id;
  final String email;
  final bool isLink;
  final String createdByName;
  final DateTime? expiresAt;

  /// 0 means unlimited.
  final int maxUses;
  final int uses;
  final InviteState state;

  /// Only known right after create / resend; empty when listed.
  final String token;
}

/// Outcome of inviting several addresses at once.
@immutable
class InviteResult {
  const InviteResult({required this.invitations, required this.skippedEmails});

  final List<Invitation> invitations;
  final List<String> skippedEmails;
}

/// What anyone holding a link may see before joining.
@immutable
class InvitePreview {
  const InvitePreview({
    required this.workspaceName,
    required this.inviterName,
    required this.emailBound,
    required this.state,
  });

  final String workspaceName;
  final String inviterName;
  final bool emailBound;
  final InviteState state;
}

enum InviteFailure {
  forbidden,
  ownerProtected,
  emailMismatch,
  expired,
  revoked,
  beforeRemoval,
  usedUp,
  notFound,
  rateLimited,
  invalid,
  exists,
  network,
  other,
}

class InviteException implements Exception {
  const InviteException(this.failure, [this.detail]);

  final InviteFailure failure;
  final String? detail;

  @override
  String toString() => 'InviteException($failure, $detail)';
}

/// What to tell the user about a failed members / invitations call.
String inviteErrorMessage(Object error) {
  if (error is! InviteException) return 'Something went wrong. Try again.';
  return switch (error.failure) {
    InviteFailure.forbidden => 'You do not have permission to do that.',
    InviteFailure.ownerProtected =>
      'The owner cannot be removed and cannot leave this workspace.',
    InviteFailure.emailMismatch =>
      'This invitation is for another email address.',
    InviteFailure.expired => 'This invitation has expired. Ask for a new one.',
    InviteFailure.revoked => 'This invitation was revoked.',
    InviteFailure.beforeRemoval =>
      'This invitation predates your removal. Ask for a new one.',
    InviteFailure.usedUp => 'This invitation has already been used up.',
    InviteFailure.notFound => 'This invitation does not exist.',
    InviteFailure.rateLimited =>
      'Too many invitations just now. Wait a while and try again.',
    InviteFailure.invalid => error.detail ?? 'Check the values and try again.',
    InviteFailure.exists => 'That person is already invited or a member.',
    InviteFailure.network =>
      'Cannot reach the server. Check your connection and try again.',
    InviteFailure.other => 'Something went wrong. Try again.',
  };
}

/// The user-facing line for a non-valid preview state.
String inviteStateMessage(InviteState state) => switch (state) {
  InviteState.expired => inviteErrorMessage(
    const InviteException(InviteFailure.expired),
  ),
  InviteState.revoked => inviteErrorMessage(
    const InviteException(InviteFailure.revoked),
  ),
  InviteState.usedUp => inviteErrorMessage(
    const InviteException(InviteFailure.usedUp),
  ),
  InviteState.valid => '',
};
