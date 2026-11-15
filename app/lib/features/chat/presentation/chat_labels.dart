import 'package:material_ui/material_ui.dart';

import 'package:taskforge/features/chat/domain/chat.dart';
import 'package:taskforge/features/members/domain/members.dart';
import 'package:taskforge/l10n/gen/app_localizations.dart';

/// What a space is called: its name; a direct message takes the other
/// person's, and a person who left is "Former member".
String spaceTitle(Space space, List<Member> members, AppLocalizations l10n) {
  if (space.kind != SpaceKind.dm && space.name.isNotEmpty) return space.name;
  for (final m in members) {
    if (m.userId == space.peerId && space.peerId.isNotEmpty) return m.label;
  }
  return space.name.isEmpty ? l10n.chatFormerMember : space.name;
}

/// A person's name by id ("You" for [me], "Someone" when unknown).
String personName(
  String id,
  String me,
  List<Member> members,
  AppLocalizations l10n, {
  String fallback = '',
}) {
  if (id == me) return l10n.grpBYou;
  for (final m in members) {
    if (m.userId == id) return m.label;
  }
  return fallback.isEmpty ? l10n.chatFormerMember : fallback;
}

/// What to tell the person about a failed call.
String chatErrorMessage(Object error, AppLocalizations l10n) {
  if (error is! ChatException) return l10n.grpLGeneric;
  return switch (error.failure) {
    ChatFailure.conflict => l10n.grpLCommentConflict,
    ChatFailure.broadcastConfirm => l10n.chatBroadcastTitle,
    ChatFailure.mentionNoAccess => l10n.grpLMentionNoAccess,
    ChatFailure.denied => error.detail ?? l10n.grpLNoPerm,
    ChatFailure.forbidden => l10n.grpLNoPermDo,
    ChatFailure.invalid => error.detail ?? l10n.grpLCommentCheck,
    ChatFailure.archived => l10n.grpLArchived,
    ChatFailure.notFound => l10n.grpLCommentGone,
    ChatFailure.network => l10n.grpLNetOffline,
    ChatFailure.other => l10n.grpLGeneric,
  };
}

/// Shows [text] in a snack bar.
void chatSay(BuildContext context, String text) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(text)));
}
