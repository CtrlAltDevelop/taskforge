import 'package:material_ui/material_ui.dart';

import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/core/i18n/context_dates.dart';
import 'package:taskforge/core/ui/theme_extension.dart';
import 'package:taskforge/core/ui/tf/tf_avatar.dart';
import 'package:taskforge/core/ui/tf/tf_button.dart';
import 'package:taskforge/core/ui/tf/tf_interactive.dart';
import 'package:taskforge/core/ui/tf/tf_menu.dart';
import 'package:taskforge/core/ui/tf_icons.dart';
import 'package:taskforge/core/ui/tokens/shape.dart';
import 'package:taskforge/core/ui/tokens/spacing.dart';
import 'package:taskforge/features/attachments/presentation/comment_attachments.dart';
import 'package:taskforge/features/comments/application/comments_providers.dart';
import 'package:taskforge/features/comments/domain/comment_text.dart';
import 'package:taskforge/features/comments/domain/comments.dart';
import 'package:taskforge/features/comments/presentation/comment_composer.dart';
import 'package:taskforge/features/comments/presentation/comments_section.dart'
    show BodyView, clockOf;
import 'package:taskforge/features/tasks/presentation/detail/activity/reactions_row.dart';

enum MessageAction { reply, edit, delete, pin, subtask, history }

/// What the person may do with one message.
class MessageRights {
  const MessageRights({
    this.canReact = false,
    this.canReply = false,
    this.canEdit = false,
    this.canDelete = false,
    this.canPin = false,
    this.canSubtask = false,
  });

  final bool canReact;
  final bool canReply;
  final bool canEdit;
  final bool canDelete;
  final bool canPin;
  final bool canSubtask;
}

/// The callbacks a message reports to.
class MessageHandlers {
  const MessageHandlers({
    required this.onAction,
    required this.onReact,
    required this.onSaveEdit,
    required this.onCancelEdit,
    required this.onRetry,
    required this.onDiscard,
  });

  final void Function(MessageAction) onAction;
  final void Function(String emoji) onReact;
  final Future<void> Function(String body, List<MentionPick> picks) onSaveEdit;
  final VoidCallback onCancelEdit;
  final VoidCallback onRetry;
  final VoidCallback onDiscard;
}

const _avatar = 28.0;

/// One message as a bubble: the author's avatar, name and time, the text,
/// attachments, reactions, and a menu. Mine sit at the end in the accent
/// tone, everyone else's at the start. A run by one person shows the avatar
/// and name once ([grouped]).
class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.comment,
    required this.author,
    required this.me,
    required this.names,
    required this.rights,
    required this.handlers,
    required this.task,
    required this.archived,
    required this.offline,
    this.grouped = false,
    this.editing = false,
    this.reply = false,
  });

  final Comment comment;
  final String author;
  final String me;
  final String Function(String) names;
  final MessageRights rights;
  final MessageHandlers handlers;
  final TaskRef task;
  final bool archived;
  final bool offline;
  final bool grouped;
  final bool editing;
  final bool reply;

  bool get _mine => comment.authorId == me;

  @override
  Widget build(BuildContext context) {
    final tf = context.tf;
    final c = comment;
    if (c.deleted) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: TfSpace.xs),
        child: Text(
          context.l10n.grpBCommentRemoved,
          key: Key('removed-${c.id}'),
          style: tf.typography.small.copyWith(
            fontStyle: FontStyle.italic,
            color: tf.colors.textMuted,
          ),
        ),
      );
    }
    final column = Expanded(
      child: Column(
        crossAxisAlignment: _mine
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          _Header(
            comment: c,
            author: author,
            showName: !grouped,
            mine: _mine,
            rights: rights,
            onAction: handlers.onAction,
          ),
          _bubble(context),
          if (c.sendState == SendState.sent)
            CommentAttachments(task: task, commentId: c.id, archived: archived),
          _sendState(context),
          if (c.sendState == SendState.sent)
            ReactionsRow(
              id: c.id,
              reactions: c.reactions,
              me: me,
              names: names,
              canReact: rights.canReact,
              onReact: handlers.onReact,
            ),
        ],
      ),
    );
    final avatar = SizedBox(
      width: _avatar,
      child: grouped
          ? null
          : TfAvatar(name: author, colorSeed: c.authorId, size: _avatar),
    );
    return Opacity(
      opacity: c.sendState == SendState.sending ? 0.7 : 1,
      child: Padding(
        padding: EdgeInsets.only(
          top: grouped ? 0 : TfSpace.sm,
          bottom: TfSpace.xs,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: TfSpace.sm,
          children: _mine ? [column, avatar] : [avatar, column],
        ),
      ),
    );
  }

  Widget _bubble(BuildContext context) {
    final tf = context.tf;
    final c = tf.colors;
    if (editing) {
      return CommentComposer(
        key: Key('edit-${comment.id}'),
        task: task,
        initialText: composerTextOf(comment.body),
        initialPicks: picksOf(comment.body),
        sendLabel: context.l10n.grpBSave,
        autofocus: true,
        onCancel: handlers.onCancelEdit,
        onSend: (body, picks, _) => handlers.onSaveEdit(body, picks),
      );
    }
    return Container(
      constraints: const BoxConstraints(minWidth: 48),
      padding: const EdgeInsets.symmetric(
        horizontal: TfSpace.md,
        vertical: TfSpace.sm,
      ),
      decoration: BoxDecoration(
        color: _mine ? c.accentTone.bg : c.sunken,
        borderRadius: BorderRadiusDirectional.only(
          topStart: const Radius.circular(TfRadius.lg),
          topEnd: const Radius.circular(TfRadius.lg),
          bottomStart: Radius.circular(_mine ? TfRadius.lg : TfRadius.xs),
          bottomEnd: Radius.circular(_mine ? TfRadius.xs : TfRadius.lg),
        ),
      ),
      child: BodyView(comment.body),
    );
  }

  Widget _sendState(BuildContext context) {
    final tf = context.tf;
    final c = tf.colors;
    final l10n = context.l10n;
    switch (comment.sendState) {
      case SendState.sent:
        return const SizedBox.shrink();
      case SendState.sending:
        return Padding(
          padding: const EdgeInsets.only(top: TfSpace.xs),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: TfSpace.xs,
            children: [
              TfIcon(
                TfIcons.clock,
                size: 12,
                color: c.textMuted,
                semanticLabel: l10n.grpBWaitingToSend,
              ),
              Text(
                offline ? l10n.tdQueuedOffline : l10n.grpBSending,
                key: Key('sending-${comment.id}'),
                style: tf.typography.caption.copyWith(color: c.textMuted),
              ),
            ],
          ),
        );
      case SendState.failed:
        return Padding(
          padding: const EdgeInsets.only(top: TfSpace.xs),
          child: Row(
            key: Key('failed-${comment.id}'),
            mainAxisSize: MainAxisSize.min,
            spacing: TfSpace.xs,
            children: [
              TfIcon(TfIcons.error, size: 14, color: c.danger.fg),
              Text(
                l10n.grpBNotSent,
                style: tf.typography.small.copyWith(color: c.danger.fg),
              ),
              TfButton(
                key: Key('retry-${comment.id}'),
                label: l10n.grpBRetry,
                variant: TfButtonVariant.ghost,
                size: TfButtonSize.small,
                onPressed: handlers.onRetry,
              ),
              TfButton(
                key: Key('discard-${comment.id}'),
                label: l10n.grpBDiscard,
                variant: TfButtonVariant.ghost,
                size: TfButtonSize.small,
                onPressed: handlers.onDiscard,
              ),
            ],
          ),
        );
    }
  }
}

/// Name, time, "edited", the pin, and the message's actions.
class _Header extends StatelessWidget {
  const _Header({
    required this.comment,
    required this.author,
    required this.showName,
    required this.mine,
    required this.rights,
    required this.onAction,
  });

  final Comment comment;
  final String author;
  final bool showName;
  final bool mine;
  final MessageRights rights;
  final void Function(MessageAction) onAction;

  List<TfMenuItem> _items(BuildContext context) {
    final l10n = context.l10n;
    TfMenuItem item(MessageAction a, String label, {bool danger = false}) =>
        TfMenuItem(label: label, danger: danger, onSelected: () => onAction(a));
    return [
      if (rights.canReply) item(MessageAction.reply, l10n.grpBReply),
      if (rights.canEdit) item(MessageAction.edit, l10n.grpBEdit),
      if (rights.canPin)
        item(MessageAction.pin, comment.pinned ? l10n.grpBUnpin : l10n.grpBPin),
      if (rights.canSubtask) item(MessageAction.subtask, l10n.grpBMakeSubtask),
      if (comment.edited) item(MessageAction.history, l10n.grpBEditHistory),
      if (rights.canDelete)
        item(MessageAction.delete, l10n.grpBDelete, danger: true),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final tf = context.tf;
    final c = tf.colors;
    final l10n = context.l10n;
    final items = comment.sendState == SendState.sent
        ? _items(context)
        : const <TfMenuItem>[];
    final meta = <Widget>[
      if (showName)
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 180),
          child: Text(
            author,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: tf.typography.label.copyWith(
              color: c.text,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      Text(
        clockOf(comment.createdAt, context.localePrefs),
        style: tf.typography.caption.copyWith(color: c.textSubtle),
      ),
      if (comment.edited)
        TfTooltip(
          message: l10n.grpBEditedTooltip(comment.editCount),
          child: TfInteractive(
            key: Key('edited-${comment.id}'),
            onTap: () => onAction(MessageAction.history),
            builder: (context, _) => Text(
              l10n.grpBEdited,
              style: tf.typography.caption.copyWith(color: c.textSubtle),
            ),
          ),
        ),
      if (comment.pinned) TfIcon(TfIcons.pin, size: 12, color: c.textMuted),
      if (items.isNotEmpty)
        TfMenu(
          items: items,
          builder: (context, toggle) => TfIconButton(
            key: Key('menu-${comment.id}'),
            icon: TfIcons.more,
            tooltip: l10n.grpBCommentActions,
            size: TfButtonSize.small,
            onPressed: toggle,
          ),
        ),
    ];
    return Wrap(
      alignment: mine ? WrapAlignment.end : WrapAlignment.start,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: TfSpace.sm,
      children: meta,
    );
  }
}
