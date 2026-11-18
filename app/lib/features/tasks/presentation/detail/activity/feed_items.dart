import 'package:flutter/foundation.dart';

import 'package:taskforge/features/comments/domain/comments.dart';

/// Messages by the same person closer together than this share one avatar
/// and name (they read as one run).
const groupWindow = Duration(minutes: 5);

/// One row of the feed, in the order it is drawn.
@immutable
sealed class FeedItem {
  const FeedItem();

  /// Stable across rebuilds, for keeping a row's state when rows move.
  String get id;
}

/// "Today", "Yesterday" or a date, above the day's rows.
class DayItem extends FeedItem {
  const DayItem(this.label);

  final String label;

  @override
  String get id => 'feed-day-$label';
}

/// A change to the task (status, due date...), one muted line.
class SystemItem extends FeedItem {
  const SystemItem(this.comment);

  final Comment comment;

  @override
  String get id => 'feed-system-${comment.id}';
}

/// A message with the replies under it (one level). [grouped] when it
/// continues a run by the same person: no avatar, no name.
class MessageItem extends FeedItem {
  const MessageItem(this.comment, this.replies, {this.grouped = false});

  final Comment comment;
  final List<Comment> replies;
  final bool grouped;

  @override
  String get id => 'feed-message-${comment.id}';
}

/// What the feed shows for [comments] (oldest first, as the server gives
/// them): changes dropped when [hideChanges], replies folded under the
/// message they answer, a [DayItem] whenever [dayOf] changes, and runs by one
/// person marked as grouped.
List<FeedItem> buildFeed(
  List<Comment> comments, {
  required bool hideChanges,
  required String Function(DateTime at) dayOf,
}) {
  final shown = hideChanges
      ? [
          for (final c in comments)
            if (!c.isSystem) c,
        ]
      : comments;
  final known = {for (final c in comments) c.id};
  final replies = <String, List<Comment>>{};
  for (final c in shown) {
    if (c.isReply) (replies[c.parentId] ??= []).add(c);
  }
  final items = <FeedItem>[];
  var lastDay = '';
  Comment? lastMessage;
  for (final c in shown) {
    if (c.isReply && known.contains(c.parentId)) continue;
    final day = dayOf(c.createdAt.toLocal());
    if (day != lastDay) {
      items.add(DayItem(day));
      lastDay = day;
      lastMessage = null;
    }
    if (c.isSystem) {
      items.add(SystemItem(c));
      lastMessage = null;
      continue;
    }
    final mine = replies[c.id] ?? const <Comment>[];
    final previous = lastMessage;
    final grouped =
        previous != null &&
        !previous.deleted &&
        !c.deleted &&
        previous.authorId == c.authorId &&
        (replies[previous.id] ?? const []).isEmpty &&
        c.createdAt.difference(previous.createdAt) < groupWindow;
    items.add(MessageItem(c, mine, grouped: grouped));
    lastMessage = c;
  }
  return items;
}
