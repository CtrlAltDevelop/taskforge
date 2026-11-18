import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/core/i18n/context_dates.dart';
import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/core/offline/offline_providers.dart';
import 'package:taskforge/core/ui/theme_extension.dart';
import 'package:taskforge/core/ui/tf/tf_button.dart';
import 'package:taskforge/core/ui/tf/tf_chip.dart';
import 'package:taskforge/core/ui/tf/tf_feedback.dart' show TfSkeleton;
import 'package:taskforge/core/ui/tokens/motion.dart';
import 'package:taskforge/core/ui/tf_icons.dart';
import 'package:taskforge/core/ui/tokens/spacing.dart';
import 'package:taskforge/features/audit/presentation/activity_section.dart';
import 'package:taskforge/features/comments/application/chat_prefs.dart';
import 'package:taskforge/features/comments/application/comments_providers.dart';
import 'package:taskforge/features/comments/domain/chat_sentence.dart';
import 'package:taskforge/features/comments/domain/comments.dart';
import 'package:taskforge/features/comments/presentation/comment_composer.dart';
import 'package:taskforge/features/comments/presentation/comments_section.dart'
    show commentEditWindow, dayLabel;
import 'package:taskforge/features/members/application/members_providers.dart';
import 'package:taskforge/features/roles/application/roles_providers.dart';
import 'package:taskforge/features/roles/domain/roles.dart';
import 'package:taskforge/features/tasks/presentation/detail/activity/activity_actions.dart';
import 'package:taskforge/features/tasks/presentation/detail/activity/feed_items.dart';
import 'package:taskforge/features/tasks/presentation/detail/activity/feed_rows.dart';
import 'package:taskforge/features/tasks/presentation/detail/activity/message_bubble.dart';
import 'package:taskforge/features/tasks/presentation/detail/task_composer.dart';
import 'package:taskforge/features/workflows/application/workflows_providers.dart';

/// How near the end counts as "reading the latest" (new messages then pull
/// the list along).
const _tailSlack = 96.0;

/// The whole conversation of a task and its changes: pinned messages, the
/// feed by day (virtualized), the full activity record, and the composer
/// pinned at the bottom. On a wide screen the feed scrolls on its own; with
/// [leading] slivers (the phone) it is the end of the page's one scroll and
/// only the composer stays put.
class ActivityPanel extends ConsumerStatefulWidget {
  const ActivityPanel({
    super.key,
    required this.projectId,
    required this.taskId,
    this.archived = false,
    this.isPrivate = false,
    this.leading = const [],
    this.topBar,
  });

  final String projectId;
  final String taskId;
  final bool archived;

  /// Only a private project can have somebody added to it from a mention.
  final bool isPrivate;

  /// Slivers drawn above the conversation in the same scroll (phone).
  final List<Widget> leading;

  /// A fixed bar above everything (phone header).
  final Widget? topBar;

  @override
  ConsumerState<ActivityPanel> createState() => _ActivityPanelState();
}

class _ActivityPanelState extends ConsumerState<ActivityPanel> {
  final _scroll = ScrollController();
  String? _replyingTo;
  String? _editing;
  Timer? _tick;
  var _count = 0;
  var _atTail = true;

  bool get _own => widget.leading.isEmpty;

  TaskRef get _ref => (project: widget.projectId, task: widget.taskId);

  late final _actions = ActivityActions(
    context: () => context,
    ref: ref,
    task: _ref,
    projectId: widget.projectId,
    isPrivate: widget.isPrivate,
    mounted: () => mounted,
    setReplying: (id) => setState(() => _replyingTo = id),
    setEditing: (id) => setState(() => _editing = id),
  );

  @override
  void initState() {
    super.initState();
    // Relative times ("5 min ago") move on while the chat is open.
    _tick = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
    _scroll.addListener(() {
      final p = _scroll.position;
      final tail = p.maxScrollExtent - p.pixels <= _tailSlack;
      if (tail != _atTail && mounted) setState(() => _atTail = tail);
    });
  }

  @override
  void dispose() {
    _tick?.cancel();
    _scroll.dispose();
    super.dispose();
  }

  /// A new message while reading the latest (or the first load) shows it.
  void _followTail(int count) {
    final grew = count > _count;
    final first = _count == 0 && count > 0;
    _count = count;
    if (!_own || !grew || !(first || _atTail)) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scroll.hasClients) return;
      _scroll.jumpTo(_scroll.position.maxScrollExtent);
      // Rows built on the way change the estimate: settle once more.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _scroll.hasClients) {
          _scroll.jumpTo(_scroll.position.maxScrollExtent);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(commentsProvider(_ref));
    final permissions = ref.watch(permissionSetProvider);
    final me = ref.watch(currentUserIdProvider);
    ref.watch(membersProvider); // names
    ref.watch(workflowProvider(widget.projectId)); // status names
    final hide = ref.watch(hideChatChangesProvider);
    final offline = !ref.watch(networkProvider);
    final now = ref.watch(chatNowProvider)();
    final l10n = context.l10n;
    final canComment = !widget.archived && permissions.can(Perm.commentCreate);
    final canModerate = permissions.can(Perm.commentModerate);
    final canPin =
        !widget.archived && (canModerate || permissions.can(Perm.taskUpdate));
    final canSubtask = !widget.archived && permissions.can(Perm.taskCreate);

    final items = buildFeed(
      state.comments,
      hideChanges: hide,
      dayOf: (at) => dayLabel(at, now, l10n: l10n, prefs: context.localePrefs),
    );
    _followTail(state.comments.length);
    final talk = state.comments.where((c) => !c.isSystem).length;
    final pinned = [
      for (final c in state.comments)
        if (c.pinned && !c.deleted && !c.isReply) c,
    ];

    MessageRights rightsOf(Comment c, {required bool reply}) {
      final live = !c.deleted && !c.isLocal;
      return MessageRights(
        canReact: canComment && live,
        canReply: canComment && !reply && live,
        canEdit:
            canComment &&
            c.authorId == me &&
            live &&
            now.difference(c.createdAt) <= commentEditWindow,
        canDelete:
            !widget.archived && (c.authorId == me || canModerate) && live,
        canPin: canPin && live,
        canSubtask: canSubtask && live,
      );
    }

    Widget bubble(Comment c, {bool reply = false, bool grouped = false}) =>
        MessageBubble(
          key: Key('comment-${c.id}'),
          comment: c,
          author: _actions.nameOf(c.authorId),
          me: me,
          names: _actions.nameOf,
          rights: rightsOf(c, reply: reply),
          task: _ref,
          archived: widget.archived,
          offline: offline,
          grouped: grouped,
          reply: reply,
          editing: _editing == c.id,
          handlers: MessageHandlers(
            onAction: (a) => _actions.act(a, c),
            onReact: (e) => _actions.guard(() => _actions.notifier.react(c, e)),
            onSaveEdit: (body, _) => _actions.saveEdit(c, body),
            onCancelEdit: () => setState(() => _editing = null),
            onRetry: () => _actions.guard(() => _actions.notifier.retry(c.id)),
            onDiscard: () => _actions.notifier.discard(c.id),
          ),
        );

    Widget row(FeedItem item) => switch (item) {
      DayItem() => DayDivider(label: item.label),
      SystemItem() => _systemEvent(item.comment, now, me),
      MessageItem() => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          bubble(item.comment, grouped: item.grouped),
          for (final r in item.replies)
            Padding(
              padding: const EdgeInsetsDirectional.only(start: TfSpace.xl),
              child: bubble(r, reply: true),
            ),
          if (_replyingTo == item.comment.id)
            Padding(
              padding: const EdgeInsetsDirectional.only(
                start: TfSpace.xl,
                top: TfSpace.xs,
              ),
              child: CommentComposer(
                key: const Key('reply-composer'),
                task: _ref,
                autofocus: true,
                hint: l10n.grpBReplyHint,
                sendLabel: l10n.grpBReply,
                onCancel: () => setState(() => _replyingTo = null),
                allowFiles: !widget.archived,
                onSend: (body, _, files) => _actions.send(
                  body,
                  parentId: item.comment.id,
                  files: files,
                ),
              ),
            ),
        ],
      ),
    };

    final head = _header(context, talk: talk, hide: hide);
    final body = Stack(
      children: [
        CustomScrollView(
          controller: _scroll,
          slivers: [
            ...widget.leading,
            if (!_own) SliverToBoxAdapter(child: head),
            SliverToBoxAdapter(child: _status(context, state, items, pinned)),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: TfSpace.md),
              sliver: SliverList.builder(
                itemCount: items.length,
                findChildIndexCallback: (key) {
                  if (key is! ValueKey<String>) return null;
                  final i = items.indexWhere((e) => e.id == key.value);
                  return i < 0 ? null : i;
                },
                itemBuilder: (context, i) => KeyedSubtree(
                  key: ValueKey(items[i].id),
                  child: row(items[i]),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(TfSpace.md),
              sliver: SliverToBoxAdapter(
                // The complete record, including what happened before the
                // chat showed changes.
                child: ActivitySection(
                  key: ValueKey('activity-${widget.taskId}'),
                  projectId: widget.projectId,
                  taskId: widget.taskId,
                ),
              ),
            ),
          ],
        ),
        if (_own && !_atTail)
          PositionedDirectional(
            end: TfSpace.lg,
            bottom: TfSpace.md,
            child: TfButton(
              key: const Key('jump-latest'),
              label: l10n.tdJumpToLatest,
              icon: TfIcons.arrowDown,
              variant: TfButtonVariant.primary,
              size: TfButtonSize.small,
              onPressed: () => _scroll.animateTo(
                _scroll.position.maxScrollExtent,
                duration: TfMotion.of(context, TfDuration.base),
                curve: tfCurve,
              ),
            ),
          ),
      ],
    );
    return Column(
      key: const Key('comments'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ?widget.topBar,
        if (_own) head,
        Expanded(child: body),
        TaskComposer(
          task: _ref,
          canComment: canComment,
          archived: widget.archived,
          onSend: (body, files) => _actions.send(body, files: files),
        ),
      ],
    );
  }

  Widget _systemEvent(Comment c, DateTime now, String me) {
    final event = c.event;
    if (event == null) return const SizedBox.shrink();
    final l10n = context.l10n;
    final actor = event.byPerson
        ? _actions.nameOf(event.actorId)
        : chatNonPersonActor(event.actorType, l10n);
    return SystemEvent(
      key: Key('system-${c.id}'),
      comment: c,
      now: now,
      actor: actor,
      isMe: event.byPerson && event.actorId == me,
      prefs: context.localePrefs,
      phrase: chatPhrase(
        event,
        l: l10n,
        userName: _actions.nameOf,
        statusName: _actions.statusName,
        prefs: context.localePrefs,
      ),
    );
  }

  Widget _header(
    BuildContext context, {
    required int talk,
    required bool hide,
  }) {
    final tf = context.tf;
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        TfSpace.md,
        TfSpace.md,
        TfSpace.md,
        TfSpace.xs,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              talk == 0 ? l10n.chatTitle : l10n.chatTitleCount(talk),
              style: tf.typography.lead,
            ),
          ),
          TfChip(
            key: const Key('hide-changes'),
            label: l10n.chatHideChanges,
            selected: hide,
            onTap: () =>
                ref.read(hideChatChangesProvider.notifier).set(hidden: !hide),
          ),
        ],
      ),
    );
  }

  /// Load / error / empty states, "load earlier" and the pinned strip.
  Widget _status(
    BuildContext context,
    CommentsState state,
    List<FeedItem> items,
    List<Comment> pinned,
  ) {
    final l10n = context.l10n;
    final tf = context.tf;
    final notifier = _actions.notifier;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: TfSpace.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (state.error != null && state.comments.isEmpty)
            Row(
              children: [
                Expanded(child: Text(commentErrorMessage(state.error!, l10n))),
                TfButton(
                  key: const Key('comments-retry'),
                  label: l10n.grpBRetry,
                  onPressed: notifier.load,
                ),
              ],
            )
          else if (state.loading && state.comments.isEmpty)
            const _FeedSkeleton(key: Key('comments-loading'))
          else if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: TfSpace.lg),
              child: Column(
                spacing: TfSpace.sm,
                children: [
                  TfIcon(TfIcons.chat, size: 28, color: tf.colors.textSubtle),
                  Text(
                    l10n.chatEmpty,
                    key: const Key('no-comments'),
                    textAlign: TextAlign.center,
                    style: tf.typography.body.copyWith(
                      color: tf.colors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          if (state.hasEarlier)
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TfButton(
                key: const Key('load-earlier'),
                label: state.loadingEarlier
                    ? l10n.grpBLoading
                    : l10n.chatLoadEarlier,
                variant: TfButtonVariant.ghost,
                onPressed: state.loadingEarlier ? null : notifier.loadEarlier,
              ),
            ),
          if (pinned.isNotEmpty) ...[
            Text(
              l10n.grpBPinned,
              style: tf.typography.caption.copyWith(color: tf.colors.textMuted),
            ),
            for (final c in pinned)
              Padding(
                key: Key('pinned-${c.id}'),
                padding: const EdgeInsets.symmetric(vertical: TfSpace.xxs),
                child: PinnedMessage(
                  comment: c,
                  author: _actions.nameOf(c.authorId),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

/// Placeholder rows while the first page of messages loads.
class _FeedSkeleton extends StatelessWidget {
  const _FeedSkeleton({super.key});

  @override
  Widget build(BuildContext context) => Column(
    children: [
      for (var i = 0; i < 3; i++)
        const Padding(
          padding: EdgeInsets.symmetric(vertical: TfSpace.sm),
          child: Row(
            spacing: TfSpace.sm,
            children: [
              TfSkeleton(width: 28, height: 28, circle: true),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: TfSpace.sm,
                  children: [TfSkeleton(width: 120), TfSkeleton(width: 220)],
                ),
              ),
            ],
          ),
        ),
    ],
  );
}
