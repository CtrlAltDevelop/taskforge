import 'package:flutter/foundation.dart';

/// Where a comment is on its way to the server.
enum SendState { sent, sending, failed }

/// One comment, or a reply (one level deep). [body] is the rich-text document
/// as JSON, empty once the comment was removed ([deleted]).
@immutable
class Comment {
  const Comment({
    required this.id,
    required this.taskId,
    required this.authorId,
    required this.createdAt,
    this.parentId = '',
    this.body = '',
    this.editedAt,
    this.deleted = false,
    this.pinned = false,
    this.version = 1,
    this.mentionIds = const [],
    this.reactions = const {},
    this.editCount = 0,
    this.sendState = SendState.sent,
  });

  final String id;
  final String taskId;
  final String authorId;
  final String parentId;
  final String body;
  final DateTime createdAt;
  final DateTime? editedAt;
  final bool deleted;
  final bool pinned;

  /// The lock to send back with an edit.
  final int version;
  final List<String> mentionIds;

  /// Emoji -> the ids of everyone who gave it, oldest first.
  final Map<String, List<String>> reactions;
  final int editCount;
  final SendState sendState;

  bool get isReply => parentId.isNotEmpty;
  bool get edited => editedAt != null;
  bool get isLocal => sendState != SendState.sent;

  bool reactedBy(String emoji, String userId) =>
      reactions[emoji]?.contains(userId) ?? false;

  Comment copyWith({
    String? id,
    String? body,
    SendState? sendState,
    bool? pinned,
    bool? deleted,
  }) => Comment(
    id: id ?? this.id,
    taskId: taskId,
    authorId: authorId,
    createdAt: createdAt,
    parentId: parentId,
    body: body ?? this.body,
    editedAt: editedAt,
    deleted: deleted ?? this.deleted,
    pinned: pinned ?? this.pinned,
    version: version,
    mentionIds: mentionIds,
    reactions: reactions,
    editCount: editCount,
    sendState: sendState ?? this.sendState,
  );
}

@immutable
class CommentPage {
  const CommentPage(this.comments, this.cursor);

  /// Oldest first.
  final List<Comment> comments;

  /// Pass as `before` to load the comments before these (empty: none).
  final String cursor;

  bool get hasEarlier => cursor.isNotEmpty;
}

/// A person who can see the task, so may be mentioned.
@immutable
class Person {
  const Person(this.userId, this.displayName);

  final String userId;
  final String displayName;
}

/// One body a comment has had.
@immutable
class Revision {
  const Revision(this.body, this.at, {required this.current});

  final String body;
  final DateTime at;
  final bool current;
}

/// A person picked from the mention list, as it stands in the composer text.
@immutable
class MentionPick {
  const MentionPick(this.userId, this.label);

  final String userId;

  /// What the composer shows: `@` plus this.
  final String label;

  String get token => '@$label';
}

enum CommentFailure {
  conflict,
  locked,
  mentionNoAccess,
  denied,
  forbidden,
  invalid,
  archived,
  notFound,
  network,
  other,
}

class CommentException implements Exception {
  const CommentException(this.failure, {this.detail, this.people = const []});

  final CommentFailure failure;
  final String? detail;

  /// For [CommentFailure.mentionNoAccess]: ids of those who cannot see the task.
  final List<String> people;

  @override
  String toString() => 'CommentException($failure, $detail)';
}

String commentErrorMessage(Object error) {
  if (error is! CommentException) return 'Something went wrong. Try again.';
  return switch (error.failure) {
    CommentFailure.conflict => 'Someone changed this comment first.',
    CommentFailure.locked => 'That comment can no longer be edited.',
    CommentFailure.mentionNoAccess =>
      'Somebody you mentioned cannot see this task.',
    CommentFailure.denied => error.detail ?? 'You do not have permission.',
    CommentFailure.forbidden => 'You do not have permission to do that.',
    CommentFailure.invalid =>
      error.detail ?? 'Check the comment and try again.',
    CommentFailure.archived =>
      'This project is archived. Restore it to make changes.',
    CommentFailure.notFound => 'That comment no longer exists.',
    CommentFailure.network =>
      'Cannot reach the server. Check your connection and try again.',
    CommentFailure.other => 'Something went wrong. Try again.',
  };
}

/// The emoji offered as reactions.
const quickReactions = ['👍', '❤️', '🎉', '😄', '👀', '🙏'];
