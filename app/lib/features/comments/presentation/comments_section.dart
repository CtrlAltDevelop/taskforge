import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/core/i18n/context_dates.dart';
import 'package:taskforge/core/i18n/formatting.dart';
import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/core/i18n/locale_prefs.dart';
import 'package:taskforge/features/attachments/domain/attachments.dart'
    show UploadSource;
import 'package:taskforge/features/attachments/presentation/comment_attachments.dart';
import 'package:taskforge/features/comments/application/comments_providers.dart';
import 'package:taskforge/features/comments/domain/comment_text.dart';
import 'package:taskforge/features/comments/domain/comments.dart';
import 'package:taskforge/features/comments/presentation/comment_composer.dart';
import 'package:taskforge/features/comments/presentation/comment_dialogs.dart';
import 'package:taskforge/features/members/application/members_providers.dart';
import 'package:taskforge/features/roles/application/roles_providers.dart';
import 'package:taskforge/features/roles/domain/roles.dart';
import 'package:taskforge/l10n/gen/app_localizations.dart';

String _two(int n) => n.toString().padLeft(2, '0');

/// "Today", "Yesterday" or the date.
String dayLabel(
  DateTime at,
  DateTime now, {
  AppLocalizations? l10n,
  LocalePrefs? prefs,
}) {
  final l = l10n ?? lookupAppLocalizations(const Locale('en'));
  final d = DateTime(at.year, at.month, at.day);
  final today = DateTime(now.year, now.month, now.day);
  final gap = today.difference(d).inDays;
  if (gap == 0) return l.grpBToday;
  if (gap == 1) return l.grpBYesterday;
  return dateOrIso(d, prefs: prefs, l10n: l10n);
}

String clockOf(DateTime at, [LocalePrefs? prefs]) {
  final text = '${_two(at.toLocal().hour)}:${_two(at.toLocal().minute)}';
  return prefs == null ? text : prefs.digits(text);
}

/// How long an author may edit (the server's default; it has the last word).
const commentEditWindow = Duration(hours: 24);

enum _Action { reply, edit, delete, pin, subtask, history }

/// The comments under a task: pinned ones first, then the conversation grouped
/// by day (replies one level under what they answer), a way to load earlier
/// ones, reactions, and the composer.
class CommentsSection extends ConsumerStatefulWidget {
  const CommentsSection({
    super.key,
    required this.projectId,
    required this.taskId,
    this.archived = false,
    this.isPrivate = false,
  });

  final String projectId;
  final String taskId;
  final bool archived;

  /// Only a private project can have somebody added to it from a mention.
  final bool isPrivate;

  @override
  ConsumerState<CommentsSection> createState() => _CommentsSectionState();
}

class _CommentsSectionState extends ConsumerState<CommentsSection> {
  String? _replyingTo;
  String? _editing;

  TaskRef get _ref => (project: widget.projectId, task: widget.taskId);

  CommentsNotifier get _notifier => ref.read(commentsProvider(_ref).notifier);

  void _say(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  String _nameOf(String id) {
    if (id == ref.read(currentUserIdProvider)) return context.l10n.grpBYou;
    final members = ref.read(membersProvider).value ?? const [];
    for (final m in members) {
      if (m.userId == id) {
        return m.displayName.isEmpty ? m.email : m.displayName;
      }
    }
    return context.l10n.grpBSomeone;
  }

  /// Sends and says what went wrong. A mention of somebody who cannot see the
  /// task is the one failure with a way forward: add them (if allowed).
  Future<void> _send(
    String body, {
    String parentId = '',
    List<UploadSource> files = const [],
  }) async {
    try {
      await _notifier.send(body, parentId: parentId, files: files);
      if (mounted && parentId.isNotEmpty) setState(() => _replyingTo = null);
    } on CommentException catch (e) {
      if (e.failure == CommentFailure.mentionNoAccess) {
        final failed = _notifier.lastFailedId;
        if (failed != null) _notifier.discard(failed);
        // Posted after all (they were added): the composer is done with it.
        if (await _offerGrant(body, parentId, e.people, files)) return;
      } else {
        if (mounted) _say(commentErrorMessage(e, context.l10n));
      }
      rethrow;
    }
  }

  /// True when the comment went out after adding the people mentioned.
  Future<bool> _offerGrant(
    String body,
    String parentId,
    List<String> people,
    List<UploadSource> files,
  ) async {
    // The server decides who may add people; the client only knows it is a
    // private project, so it offers and shows the answer.
    final canGrant = widget.isPrivate;
    final names = people.map(_nameOf).join(', ');
    final grant = await askGrantAccess(
      context,
      names: names,
      canGrant: canGrant,
    );
    if (grant != true || !mounted) return false;
    try {
      await _notifier.send(
        body,
        parentId: parentId,
        grantAccess: true,
        files: files,
      );
      if (mounted && parentId.isNotEmpty) setState(() => _replyingTo = null);
      return true;
    } on CommentException catch (e) {
      if (mounted) _say(commentErrorMessage(e, context.l10n));
      return false;
    }
  }

  Future<void> _act(_Action action, Comment c) async {
    try {
      switch (action) {
        case _Action.reply:
          setState(() => _replyingTo = c.id);
        case _Action.edit:
          setState(() => _editing = c.id);
        case _Action.delete:
          if (await confirmDeleteComment(context)) await _notifier.delete(c);
        case _Action.pin:
          await _notifier.pin(c, pinned: !c.pinned);
        case _Action.subtask:
          await _notifier.toSubtask(c);
          if (mounted) _say(context.l10n.grpBSubtaskCreated);
        case _Action.history:
          final revisions = await _notifier.history(c);
          if (mounted) {
            await showHistory(context, revisions, _nameOf(c.authorId));
          }
      }
    } on CommentException catch (e) {
      if (mounted) _say(commentErrorMessage(e, context.l10n));
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(commentsProvider(_ref));
    final permissions = ref.watch(permissionSetProvider);
    final me = ref.watch(currentUserIdProvider);
    ref.watch(membersProvider); // names
    final canComment = !widget.archived && permissions.can(Perm.commentCreate);
    final canModerate = permissions.can(Perm.commentModerate);
    final canPin =
        !widget.archived && (canModerate || permissions.can(Perm.taskUpdate));
    final canSubtask = !widget.archived && permissions.can(Perm.taskCreate);

    final top = [
      for (final c in state.comments)
        if (!c.isReply || !state.comments.any((p) => p.id == c.parentId)) c,
    ];
    final replies = <String, List<Comment>>{};
    for (final c in state.comments) {
      if (c.isReply) (replies[c.parentId] ??= []).add(c);
    }
    final pinned = [
      for (final c in top)
        if (c.pinned && !c.deleted) c,
    ];
    final now = DateTime.now();
    var lastDay = '';

    Widget tile(Comment c, {bool reply = false}) => _CommentTile(
      key: Key('comment-${c.id}'),
      comment: c,
      reply: reply,
      author: _nameOf(c.authorId),
      me: me,
      names: _nameOf,
      canReact: canComment && !c.isLocal && !c.deleted,
      canReply: canComment && !reply && !c.isLocal && !c.deleted,
      canEdit:
          canComment &&
          c.authorId == me &&
          !c.deleted &&
          !c.isLocal &&
          now.difference(c.createdAt) <= commentEditWindow,
      canDelete:
          !widget.archived &&
          (c.authorId == me || canModerate) &&
          !c.deleted &&
          !c.isLocal,
      canPin: canPin && !c.deleted && !c.isLocal,
      canSubtask: canSubtask && !c.deleted && !c.isLocal,
      editing: _editing == c.id,
      archived: widget.archived,
      task: _ref,
      onAction: (a) => _act(a, c),
      onReact: (e) => _guard(() => _notifier.react(c, e)),
      onSaveEdit: (body, _) async {
        final l10n = context.l10n;
        try {
          await _notifier.edit(c, body);
          if (mounted) setState(() => _editing = null);
        } on CommentException catch (e) {
          if (mounted) _say(commentErrorMessage(e, l10n));
          rethrow;
        }
      },
      onCancelEdit: () => setState(() => _editing = null),
      onRetry: () => _guard(() => _notifier.retry(c.id)),
      onDiscard: () => _notifier.discard(c.id),
    );

    return Column(
      key: const Key('comments'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          state.comments.isEmpty
              ? context.l10n.grpBComments
              : context.l10n.grpBCommentsCount(state.comments.length),
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        if (state.error != null && state.comments.isEmpty)
          Row(
            children: [
              Expanded(
                child: Text(commentErrorMessage(state.error!, context.l10n)),
              ),
              TextButton(
                key: const Key('comments-retry'),
                onPressed: _notifier.load,
                child: Text(context.l10n.grpBRetry),
              ),
            ],
          )
        else if (state.loading && state.comments.isEmpty)
          const _Skeleton(key: Key('comments-loading'))
        else if (state.comments.isEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              context.l10n.grpBNoComments,
              key: const Key('no-comments'),
            ),
          ),
        if (state.hasEarlier)
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton(
              key: const Key('load-earlier'),
              onPressed: state.loadingEarlier ? null : _notifier.loadEarlier,
              child: Text(
                state.loadingEarlier
                    ? context.l10n.grpBLoading
                    : context.l10n.grpBLoadEarlier,
              ),
            ),
          ),
        if (pinned.isNotEmpty) ...[
          Text(
            context.l10n.grpBPinned,
            style: Theme.of(context).textTheme.labelMedium,
          ),
          for (final c in pinned)
            Padding(
              key: Key('pinned-${c.id}'),
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Card(
                color: Theme.of(context).colorScheme.secondaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: _BodyView(c.body),
                ),
              ),
            ),
          const Divider(),
        ],
        for (final c in top) ...[
          if (dayLabel(
                c.createdAt.toLocal(),
                now,
                l10n: context.l10n,
                prefs: context.localePrefs,
              ) !=
              lastDay)
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 2),
              child: Text(
                lastDay = dayLabel(
                  c.createdAt.toLocal(),
                  now,
                  l10n: context.l10n,
                  prefs: context.localePrefs,
                ),
                key: Key('day-$lastDay'),
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ),
          tile(c),
          for (final r in replies[c.id] ?? const <Comment>[])
            Padding(
              padding: const EdgeInsetsDirectional.only(start: 28),
              child: tile(r, reply: true),
            ),
          if (_replyingTo == c.id)
            Padding(
              padding: const EdgeInsetsDirectional.only(start: 28, top: 4),
              child: CommentComposer(
                key: const Key('reply-composer'),
                task: _ref,
                autofocus: true,
                hint: context.l10n.grpBReplyHint,
                sendLabel: context.l10n.grpBReply,
                onCancel: () => setState(() => _replyingTo = null),
                allowFiles: !widget.archived,
                onSend: (body, _, files) =>
                    _send(body, parentId: c.id, files: files),
              ),
            ),
        ],
        const SizedBox(height: 12),
        if (canComment)
          CommentComposer(
            key: const Key('main-composer'),
            task: _ref,
            allowFiles: true,
            onSend: (body, _, files) => _send(body, files: files),
          )
        else
          Text(
            widget.archived
                ? context.l10n.grpBArchivedReadOnly
                : context.l10n.grpBReadOnlyComments,
            key: const Key('comments-readonly'),
            style: Theme.of(context).textTheme.bodySmall,
          ),
      ],
    );
  }

  Future<void> _guard(Future<void> Function() call) async {
    try {
      await call();
    } on CommentException catch (e) {
      if (mounted) _say(commentErrorMessage(e, context.l10n));
    }
  }
}

class _CommentTile extends StatelessWidget {
  const _CommentTile({
    super.key,
    required this.comment,
    required this.reply,
    required this.author,
    required this.me,
    required this.names,
    required this.canReact,
    required this.canReply,
    required this.canEdit,
    required this.canDelete,
    required this.canPin,
    required this.canSubtask,
    required this.editing,
    required this.archived,
    required this.task,
    required this.onAction,
    required this.onReact,
    required this.onSaveEdit,
    required this.onCancelEdit,
    required this.onRetry,
    required this.onDiscard,
  });

  final Comment comment;
  final bool reply;
  final String author;
  final String me;
  final String Function(String) names;
  final bool canReact;
  final bool canReply;
  final bool canEdit;
  final bool canDelete;
  final bool canPin;
  final bool canSubtask;
  final bool editing;
  final bool archived;
  final TaskRef task;
  final void Function(_Action) onAction;
  final void Function(String emoji) onReact;
  final Future<void> Function(String body, List<MentionPick> picks) onSaveEdit;
  final VoidCallback onCancelEdit;
  final VoidCallback onRetry;
  final VoidCallback onDiscard;

  @override
  Widget build(BuildContext context) {
    final c = comment;
    final theme = Theme.of(context);
    if (c.deleted) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Text(
          context.l10n.grpBCommentRemoved,
          key: Key('removed-${c.id}'),
          style: theme.textTheme.bodySmall?.copyWith(
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }
    final menu = <PopupMenuEntry<_Action>>[
      if (canReply)
        PopupMenuItem(
          value: _Action.reply,
          child: Text(context.l10n.grpBReply),
        ),
      if (canEdit)
        PopupMenuItem(value: _Action.edit, child: Text(context.l10n.grpBEdit)),
      if (canPin)
        PopupMenuItem(
          value: _Action.pin,
          child: Text(c.pinned ? context.l10n.grpBUnpin : context.l10n.grpBPin),
        ),
      if (canSubtask)
        PopupMenuItem(
          value: _Action.subtask,
          child: Text(context.l10n.grpBMakeSubtask),
        ),
      if (c.edited)
        PopupMenuItem(
          value: _Action.history,
          child: Text(context.l10n.grpBEditHistory),
        ),
      if (canDelete)
        PopupMenuItem(
          value: _Action.delete,
          child: Text(context.l10n.grpBDelete),
        ),
    ];
    return Opacity(
      opacity: c.sendState == SendState.sending ? 0.6 : 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(author, style: theme.textTheme.labelLarge),
                const SizedBox(width: 8),
                Text(
                  clockOf(c.createdAt, context.localePrefs),
                  style: theme.textTheme.labelSmall,
                ),
                if (c.edited)
                  Tooltip(
                    message: context.l10n.grpBEditedTooltip(c.editCount),
                    child: InkWell(
                      key: Key('edited-${c.id}'),
                      onTap: () => onAction(_Action.history),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Text(
                          context.l10n.grpBEdited,
                          style: theme.textTheme.labelSmall,
                        ),
                      ),
                    ),
                  ),
                if (c.pinned) const Icon(Icons.push_pin, size: 14),
                const Spacer(),
                if (c.sendState == SendState.sent && menu.isNotEmpty)
                  PopupMenuButton<_Action>(
                    key: Key('menu-${c.id}'),
                    icon: const Icon(Icons.more_horiz, size: 18),
                    tooltip: context.l10n.grpBCommentActions,
                    onSelected: onAction,
                    itemBuilder: (_) => menu,
                  ),
              ],
            ),
            if (editing)
              CommentComposer(
                key: Key('edit-${c.id}'),
                task: task,
                initialText: composerTextOf(c.body),
                initialPicks: picksOf(c.body),
                sendLabel: context.l10n.grpBSave,
                autofocus: true,
                onCancel: onCancelEdit,
                onSend: (body, picks, _) => onSaveEdit(body, picks),
              )
            else
              _BodyView(c.body),
            if (c.sendState == SendState.sent)
              CommentAttachments(
                task: task,
                commentId: c.id,
                archived: archived,
              ),
            if (c.sendState == SendState.sending)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.schedule,
                    size: 12,
                    semanticLabel: context.l10n.grpBWaitingToSend,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    context.l10n.grpBSending,
                    key: Key('sending-${c.id}'),
                    style: theme.textTheme.labelSmall,
                  ),
                ],
              ),
            if (c.sendState == SendState.failed)
              Row(
                key: Key('failed-${c.id}'),
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 16,
                    color: theme.colorScheme.error,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    context.l10n.grpBNotSent,
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                  TextButton(
                    key: Key('retry-${c.id}'),
                    onPressed: onRetry,
                    child: Text(context.l10n.grpBRetry),
                  ),
                  TextButton(
                    key: Key('discard-${c.id}'),
                    onPressed: onDiscard,
                    child: Text(context.l10n.grpBDiscard),
                  ),
                ],
              ),
            if (c.sendState == SendState.sent)
              _Reactions(
                comment: c,
                me: me,
                names: names,
                canReact: canReact,
                onReact: onReact,
              ),
          ],
        ),
      ),
    );
  }
}

class _Reactions extends StatelessWidget {
  const _Reactions({
    required this.comment,
    required this.me,
    required this.names,
    required this.canReact,
    required this.onReact,
  });

  final Comment comment;
  final String me;
  final String Function(String) names;
  final bool canReact;
  final void Function(String) onReact;

  @override
  Widget build(BuildContext context) {
    if (comment.reactions.isEmpty && !canReact) return const SizedBox.shrink();
    return Wrap(
      spacing: 4,
      runSpacing: 2,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (final e in comment.reactions.entries)
          Tooltip(
            message: e.value.map(names).join(', '),
            child: FilterChip(
              key: Key('reaction-${comment.id}-${e.key}'),
              visualDensity: VisualDensity.compact,
              label: Text('${e.key} ${e.value.length}'),
              selected: e.value.contains(me),
              onSelected: canReact ? (_) => onReact(e.key) : null,
            ),
          ),
        if (canReact)
          PopupMenuButton<String>(
            key: Key('react-${comment.id}'),
            icon: const Icon(Icons.add_reaction_outlined, size: 18),
            tooltip: context.l10n.grpBAddReaction,
            onSelected: onReact,
            itemBuilder: (_) => [
              for (final e in quickReactions)
                PopupMenuItem(value: e, child: Text(e)),
            ],
          ),
      ],
    );
  }
}

/// A comment's text: mentions in bold and colour, links underlined.
class _BodyView extends StatelessWidget {
  const _BodyView(this.body);

  final String body;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final lines = segmentsOf(body);
    return SelectableText.rich(
      TextSpan(
        children: [
          for (var i = 0; i < lines.length; i++) ...[
            for (final s in lines[i])
              TextSpan(
                text: s.text,
                style: s.isMention
                    ? TextStyle(
                        fontWeight: FontWeight.bold,
                        color: scheme.primary,
                      )
                    : s.href != null
                    ? TextStyle(
                        color: scheme.primary,
                        decoration: TextDecoration.underline,
                      )
                    : s.bold
                    ? const TextStyle(fontWeight: FontWeight.bold)
                    : null,
              ),
            if (i < lines.length - 1) const TextSpan(text: '\n'),
          ],
        ],
      ),
    );
  }
}

/// Grey placeholder rows shown while the first page of comments loads.
class _Skeleton extends StatelessWidget {
  const _Skeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final grey = Theme.of(context).colorScheme.surfaceContainerHighest;
    Widget bar(double width) => Container(
      width: width,
      height: 10,
      decoration: BoxDecoration(
        color: grey,
        borderRadius: BorderRadius.circular(4),
      ),
    );
    return Column(
      children: [
        for (var i = 0; i < 3; i++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                CircleAvatar(radius: 12, backgroundColor: grey),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [bar(120), const SizedBox(height: 6), bar(220)],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
