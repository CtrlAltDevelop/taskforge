import 'package:material_ui/material_ui.dart';

import 'package:taskforge/core/i18n/context_dates.dart';
import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/features/chat/domain/chat.dart';
import 'package:taskforge/features/comments/domain/comment_text.dart';
import 'package:taskforge/features/comments/domain/comments.dart'
    show MentionPick, SendState;
import 'package:taskforge/features/comments/presentation/comments_section.dart'
    show BodyView, ReactionsBar, clockOf;

enum MessageAction { reply, edit, delete }

/// One message: who, when, the text, reactions, a way into its thread, and
/// the state of a send that is not through yet.
class MessageTile extends StatelessWidget {
  const MessageTile({
    super.key,
    required this.message,
    required this.author,
    required this.me,
    required this.names,
    required this.replyCount,
    required this.canReact,
    required this.canReply,
    required this.canDelete,
    required this.canEdit,
    required this.editing,
    required this.composerBuilder,
    required this.onAction,
    required this.onReact,
    required this.onOpenThread,
    required this.onRetry,
    required this.onDiscard,
  });

  final ChatMessage message;
  final String author;
  final String me;
  final String Function(String) names;
  final int replyCount;
  final bool canReact;
  final bool canReply;
  final bool canDelete;
  final bool canEdit;
  final bool editing;

  /// Builds the composer that edits this message (given its initial text).
  final Widget Function(String text, List<MentionPick> picks) composerBuilder;
  final void Function(MessageAction) onAction;
  final void Function(String emoji) onReact;
  final VoidCallback onOpenThread;
  final VoidCallback onRetry;
  final VoidCallback onDiscard;

  @override
  Widget build(BuildContext context) {
    final m = message;
    final theme = Theme.of(context);
    final l10n = context.l10n;
    if (m.deleted) {
      return Padding(
        padding: const EdgeInsetsDirectional.symmetric(vertical: 4),
        child: Text(
          l10n.chatRemoved,
          key: Key('removed-${m.id}'),
          style: theme.textTheme.bodySmall?.copyWith(
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }
    final menu = <PopupMenuEntry<MessageAction>>[
      if (canReply)
        PopupMenuItem(value: MessageAction.reply, child: Text(l10n.chatReply)),
      if (canEdit)
        PopupMenuItem(value: MessageAction.edit, child: Text(l10n.chatEdit)),
      if (canDelete)
        PopupMenuItem(
          value: MessageAction.delete,
          child: Text(l10n.chatDelete),
        ),
    ];
    return Opacity(
      opacity: m.sendState == SendState.sending ? 0.6 : 1,
      child: Padding(
        padding: const EdgeInsetsDirectional.symmetric(vertical: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Flexible(
                  child: Text(
                    author,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelLarge,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  clockOf(m.createdAt, context.localePrefs),
                  style: theme.textTheme.labelSmall,
                ),
                if (m.edited)
                  Padding(
                    padding: const EdgeInsetsDirectional.only(start: 6),
                    child: Text(
                      l10n.chatEdited,
                      key: Key('edited-${m.id}'),
                      style: theme.textTheme.labelSmall,
                    ),
                  ),
                const Spacer(),
                if (m.sendState == SendState.sent && menu.isNotEmpty)
                  PopupMenuButton<MessageAction>(
                    key: Key('menu-${m.id}'),
                    icon: const Icon(Icons.more_horiz, size: 18),
                    tooltip: l10n.chatMessageActions,
                    onSelected: onAction,
                    itemBuilder: (_) => menu,
                  ),
              ],
            ),
            if (editing)
              composerBuilder(composerTextOf(m.body), picksOf(m.body))
            else
              BodyView(m.body),
            if (m.sendState == SendState.sending)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.schedule, size: 12),
                  const SizedBox(width: 4),
                  Text(
                    l10n.chatSending,
                    key: Key('sending-${m.id}'),
                    style: theme.textTheme.labelSmall,
                  ),
                ],
              ),
            if (m.sendState == SendState.failed)
              Wrap(
                key: Key('failed-${m.id}'),
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 16,
                    color: theme.colorScheme.error,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    l10n.chatNotSent,
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                  TextButton(
                    key: Key('retry-${m.id}'),
                    onPressed: onRetry,
                    child: Text(l10n.retry),
                  ),
                  TextButton(
                    key: Key('discard-${m.id}'),
                    onPressed: onDiscard,
                    child: Text(l10n.chatDiscard),
                  ),
                ],
              ),
            if (m.sendState == SendState.sent) ...[
              ReactionsBar(
                id: m.id,
                reactions: m.reactions,
                me: me,
                names: names,
                canReact: canReact,
                onReact: onReact,
              ),
              if (replyCount > 0)
                TextButton(
                  key: Key('replies-${m.id}'),
                  onPressed: onOpenThread,
                  child: Text(l10n.chatReplies(replyCount)),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

/// A line that says where the new messages begin.
class UnreadDivider extends StatelessWidget {
  const UnreadDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.error;
    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(child: Divider(color: color)),
          Padding(
            padding: const EdgeInsetsDirectional.symmetric(horizontal: 8),
            child: Text(
              context.l10n.chatUnreadDivider,
              style: TextStyle(color: color, fontSize: 12),
            ),
          ),
          Expanded(child: Divider(color: color)),
        ],
      ),
    );
  }
}
