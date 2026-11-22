import 'package:taskforge/core/ui/tokens/spacing.dart';
import 'package:taskforge/core/ui/tf_icons.dart';

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/features/chat/application/chat_providers.dart';
import 'package:taskforge/features/chat/domain/chat.dart';
import 'package:taskforge/features/chat/presentation/chat_dialogs.dart';
import 'package:taskforge/features/chat/presentation/chat_labels.dart';
import 'package:taskforge/features/chat/presentation/message_tile.dart';
import 'package:taskforge/features/comments/application/chat_prefs.dart';
import 'package:taskforge/features/comments/domain/comments.dart'
    show MentionPick, Person;
import 'package:taskforge/features/comments/presentation/comment_composer.dart';
import 'package:taskforge/features/comments/presentation/comments_section.dart'
    show CommentsSkeleton;
import 'package:taskforge/features/members/application/members_providers.dart';
import 'package:taskforge/features/members/domain/members.dart';
import 'package:taskforge/l10n/gen/app_localizations.dart';
import 'package:taskforge/core/ui/tf/tf_feedback.dart';
import 'package:taskforge/core/ui/tf/tf_illustration.dart';

/// How far from the newest message still counts as "at the bottom".
const _bottomSlack = 48.0;

/// One space open: header, messages (unread divider, "jump to latest"),
/// threads, and the composer; read-only banners where nobody can write.
/// Give it a `ValueKey(space.id)` so each space starts fresh.
class ConversationPane extends ConsumerStatefulWidget {
  const ConversationPane({super.key, required this.space});

  final Space space;

  @override
  ConsumerState<ConversationPane> createState() => _ConversationPaneState();
}

class _ConversationPaneState extends ConsumerState<ConversationPane> {
  final _scroll = ScrollController();
  var _atBottom = true;
  String? _thread;
  String? _editing;
  String? _markedUpTo;

  /// Where this person had read up to when the space was opened: the unread
  /// divider stays there while the conversation is open.
  DateTime? _readAtOpen;
  var _captured = false;

  Space get _space => widget.space;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_watchScroll);
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _watchScroll() {
    final at = !_scroll.hasClients || _scroll.position.pixels <= _bottomSlack;
    if (at != _atBottom) {
      setState(() => _atBottom = at);
      if (at) _scheduleMarkRead();
    }
  }

  void _jumpToLatest() {
    if (_scroll.hasClients) _scroll.jumpTo(0);
    setState(() => _atBottom = true);
    _scheduleMarkRead();
  }

  MessagesNotifier get _notifier =>
      ref.read(messagesProvider(_space.id).notifier);

  /// Tells the server what has been seen, once per newest message, when the
  /// conversation is visible and at the bottom.
  void _scheduleMarkRead() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_atBottom || _thread != null) return;
      final lifecycle = WidgetsBinding.instance.lifecycleState;
      if (lifecycle == AppLifecycleState.paused ||
          lifecycle == AppLifecycleState.hidden) {
        return;
      }
      final seen = [
        for (final m in ref.read(messagesProvider(_space.id)).messages)
          if (!m.isLocal) m,
      ];
      if (seen.isEmpty || seen.last.id == _markedUpTo) return;
      final current = ref.read(spacesProvider).list.byId(_space.id) ?? _space;
      if (current.unreadCount == 0 &&
          !(current.lastMessageAt?.isAfter(
                current.lastReadAt ?? DateTime.fromMillisecondsSinceEpoch(0),
              ) ??
              false)) {
        _markedUpTo = seen.last.id;
        return;
      }
      _markedUpTo = seen.last.id;
      unawaited(_notifier.markRead());
    });
  }

  Future<void> _send(String body, {String parentId = ''}) async {
    final l10n = context.l10n;
    try {
      try {
        await _notifier.send(body, parentId: parentId);
      } on ChatException catch (e) {
        if (e.failure != ChatFailure.broadcastConfirm) rethrow;
        if (!mounted || !await confirmBroadcast(context, e.memberCount)) {
          rethrow;
        }
        await _notifier.send(body, parentId: parentId, confirmBroadcast: true);
      }
    } on ChatException catch (e) {
      if (e.failure == ChatFailure.mentionNoAccess && await _offerGrant(e)) {
        await _sendGranted(body, parentId);
        return;
      }
      if (mounted) chatSay(context, chatErrorMessage(e, l10n));
      rethrow;
    }
  }

  /// Asks whether to add the people mentioned who are outside the space.
  Future<bool> _offerGrant(ChatException e) async {
    if (!mounted) return false;
    final members = ref.read(membersProvider).value ?? const <Member>[];
    final me = ref.read(chatMeProvider);
    final names = e.people
        .map((id) => personName(id, me, members, context.l10n))
        .join(', ');
    return askGrantMentioned(
      context,
      names: names,
      canGrant: _space.kind != SpaceKind.dm,
    );
  }

  Future<void> _sendGranted(String body, String parentId) async {
    final l10n = context.l10n;
    try {
      await _notifier.send(body, parentId: parentId, grantAccess: true);
    } on ChatException catch (e) {
      if (mounted) chatSay(context, chatErrorMessage(e, l10n));
      rethrow;
    }
  }

  Future<void> _saveEdit(ChatMessage m, String body) async {
    final l10n = context.l10n;
    try {
      try {
        await _notifier.edit(m, body);
      } on ChatException catch (e) {
        if (e.failure != ChatFailure.broadcastConfirm) rethrow;
        if (!mounted || !await confirmBroadcast(context, e.memberCount)) {
          rethrow;
        }
        await _notifier.edit(m, body, confirmBroadcast: true);
      }
      if (mounted) setState(() => _editing = null);
    } on ChatException catch (e) {
      if (mounted) chatSay(context, chatErrorMessage(e, l10n));
      rethrow;
    }
  }

  Future<void> _guard(Future<void> Function() action) async {
    final l10n = context.l10n;
    try {
      await action();
    } on ChatException catch (e) {
      if (mounted) chatSay(context, chatErrorMessage(e, l10n));
    }
  }

  Widget _composer({
    String parentId = '',
    String initialText = '',
    List<MentionPick> initialPicks = const [],
    ChatMessage? editing,
    Key? key,
  }) => CommentComposer(
    key: key ?? Key(parentId.isEmpty ? 'chat-composer' : 'thread-composer'),
    initialText: initialText,
    initialPicks: initialPicks,
    hint: context.l10n.chatWriteMessage,
    sendLabel: editing == null ? context.l10n.chatSend : context.l10n.save,
    autofocus: editing != null,
    onCancel: editing == null ? null : () => setState(() => _editing = null),
    broadcastNames: _space.kind == SpaceKind.dm
        ? const []
        : const ['channel', 'here'],
    mentionLookup: (ref, query) =>
        ref
            .watch(chatMentionableProvider((space: _space.id, query: query)))
            .value
            ?.people ??
        const <Person>[],
    onSend: (body, picks, files) => editing == null
        ? _send(body, parentId: parentId)
        : _saveEdit(editing, body),
  );

  MessageTile _tile(
    ChatMessage m,
    List<ChatMessage> all,
    String me,
    List<Member> members,
  ) {
    final l10n = context.l10n;
    final now = ref.read(chatNowProvider)();
    final canWrite = _space.canPost;
    return MessageTile(
      key: Key('message-${m.id}'),
      message: m,
      author: personName(m.authorId, me, members, l10n, fallback: m.authorName),
      me: me,
      names: (id) => personName(id, me, members, l10n),
      replyCount: m.isReply
          ? 0
          : repliesOf(all, m.id).where((r) => !r.deleted).length,
      canReact: canWrite,
      canReply: canWrite && !m.isReply,
      canEdit: canWrite && canEditMessage(m, me, now),
      canDelete: canWrite && m.authorId == me && !m.isLocal,
      editing: _editing == m.id,
      composerBuilder: (text, picks) => _composer(
        key: Key('edit-${m.id}'),
        initialText: text,
        initialPicks: picks,
        editing: m,
      ),
      onAction: (action) {
        switch (action) {
          case MessageAction.reply:
            setState(() => _thread = m.id);
            unawaited(_notifier.loadThread(m.id));
          case MessageAction.edit:
            setState(() => _editing = m.id);
          case MessageAction.delete:
            unawaited(_guard(() => _notifier.delete(m)));
        }
      },
      onReact: (emoji) => unawaited(_guard(() => _notifier.react(m, emoji))),
      onOpenThread: () {
        setState(() => _thread = m.id);
        unawaited(_notifier.loadThread(m.id));
      },
      onRetry: () => unawaited(_guard(() => _notifier.retry(m.id))),
      onDiscard: () => _notifier.discard(m.id),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(messagesProvider(_space.id));
    final members = ref.watch(membersProvider).value ?? const <Member>[];
    final me = ref.watch(chatMeProvider);
    if (!state.loading && !_captured) {
      _captured = true;
      _readAtOpen = _space.lastReadAt;
    }
    final parent = _thread == null
        ? null
        : state.messages.where((m) => m.id == _thread).firstOrNull;
    ref.listen(messagesProvider(_space.id), (_, _) => _scheduleMarkRead());
    if (!state.loading) _scheduleMarkRead();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _header(context, members),
        const Divider(height: 1),
        Expanded(
          child: parent != null
              ? _threadView(context, parent, state, me, members)
              : _timeline(context, state, me, members),
        ),
        const Divider(height: 1),
        _footer(context, l10n, parent?.id ?? ''),
      ],
    );
  }

  Widget _header(BuildContext context, List<Member> members) {
    final l10n = context.l10n;
    final now = ref.watch(chatNowProvider)();
    final live = ref.watch(spacesProvider).list.byId(_space.id) ?? _space;
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(
        TfSpace.lg,
        TfSpace.xs,
        TfSpace.xs,
        TfSpace.xs,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  spaceTitle(_space, members, l10n),
                  key: const Key('chat-title'),
                  style: Theme.of(context).textTheme.titleMedium,
                  overflow: TextOverflow.ellipsis,
                ),
                if (_space.kind != SpaceKind.dm)
                  Text(
                    l10n.chatMembersCount(_space.memberCount),
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
              ],
            ),
          ),
          if (live.isMuted(now))
            TfIcon(TfIcons.bellOff, size: 18, semanticLabel: l10n.chatMuted),
          IconButton(
            key: const Key('chat-settings'),
            tooltip: l10n.chatSettings,
            icon: const TfIcon(TfIcons.tune, size: TfIconSize.control),
            onPressed: () => showSpaceSettings(context, _space.id),
          ),
        ],
      ),
    );
  }

  Widget _timeline(
    BuildContext context,
    MessagesState state,
    String me,
    List<Member> members,
  ) {
    final l10n = context.l10n;
    if (state.loading) {
      return const SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
        padding: EdgeInsets.all(TfSpace.lg),
        child: CommentsSkeleton(key: Key('chat-loading')),
      );
    }
    if (state.error != null && state.messages.isEmpty) {
      return TfError(
        key: const Key('chat-error'),
        message: chatErrorMessage(state.error!, l10n),
        details: '${state.error}',
        retryKey: const Key('chat-retry'),
        onRetry: () => _notifier.load(),
      );
    }
    final timeline = topLevel(state.messages);
    if (timeline.isEmpty) {
      return TfEmpty(
        key: const Key('chat-empty'),
        illustration: TfIllustrationKind.chat,
        title: l10n.chatSayHi,
      );
    }
    final unreadId = firstUnreadId(timeline, _readAtOpen, me);
    // Newest at the bottom: the list runs from the bottom up.
    final rows = <Widget>[
      if (state.hasEarlier)
        TextButton(
          key: const Key('chat-load-earlier'),
          onPressed: state.loadingEarlier ? null : _notifier.loadEarlier,
          child: Text(l10n.chatLoadEarlier),
        ),
      for (final m in timeline) ...[
        if (m.id == unreadId) const UnreadDivider(key: Key('unread-divider')),
        _tile(m, state.messages, me, members),
      ],
    ];
    return Stack(
      children: [
        ListView.builder(
          key: const Key('chat-messages'),
          controller: _scroll,
          reverse: true,
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: TfSpace.lg,
            vertical: TfSpace.sm,
          ),
          itemCount: rows.length,
          itemBuilder: (_, i) => rows[rows.length - 1 - i],
        ),
        if (!_atBottom)
          PositionedDirectional(
            end: 16,
            bottom: 12,
            child: FilledButton.tonalIcon(
              key: const Key('jump-to-latest'),
              onPressed: _jumpToLatest,
              icon: const TfIcon(TfIcons.arrowDown, size: 18),
              label: Text(l10n.chatJumpLatest),
            ),
          ),
      ],
    );
  }

  Widget _threadView(
    BuildContext context,
    ChatMessage parent,
    MessagesState state,
    String me,
    List<Member> members,
  ) {
    final l10n = context.l10n;
    final replies = repliesOf(state.messages, parent.id);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            IconButton(
              key: const Key('thread-back'),
              tooltip: l10n.chatBack,
              icon: const TfIcon(TfIcons.arrowStart, size: TfIconSize.control),
              onPressed: () => setState(() => _thread = null),
            ),
            Text(
              l10n.chatThread,
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ],
        ),
        Expanded(
          child: ListView(
            key: const Key('thread-messages'),
            padding: const EdgeInsetsDirectional.symmetric(
              horizontal: TfSpace.lg,
            ),
            children: [
              _tile(parent, state.messages, me, members),
              const Divider(),
              for (final r in replies) _tile(r, state.messages, me, members),
            ],
          ),
        ),
      ],
    );
  }

  Widget _footer(BuildContext context, AppLocalizations l10n, String thread) {
    final space = ref.watch(spacesProvider).list.byId(_space.id) ?? _space;
    Widget banner(String key, String text, {Widget? action}) => Padding(
      padding: const EdgeInsetsDirectional.all(TfSpace.md),
      child: Row(
        children: [
          Expanded(child: Text(text, key: Key(key))),
          ?action,
        ],
      ),
    );
    if (space.archived) {
      return banner('chat-readonly', l10n.chatReadOnlyArchived);
    }
    if (space.readOnly) return banner('chat-readonly', l10n.chatReadOnlyFormer);
    if (space.canJoin) {
      return banner(
        'chat-not-member',
        l10n.chatNotMember,
        action: FilledButton(
          key: const Key('chat-join'),
          onPressed: () =>
              _guard(() => ref.read(spacesProvider.notifier).join(space.id)),
          child: Text(l10n.chatJoin),
        ),
      );
    }
    if (!space.joined) return banner('chat-readonly', l10n.chatReadOnlyFormer);
    // On a small screen the composer scrolls instead of squeezing the
    // messages out.
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.4,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsetsDirectional.all(TfSpace.md),
        child: _composer(parentId: thread),
      ),
    );
  }
}
