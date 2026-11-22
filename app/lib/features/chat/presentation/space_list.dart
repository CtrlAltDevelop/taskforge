import 'package:taskforge/core/ui/tokens/spacing.dart';
import 'package:taskforge/core/ui/tokens/shape.dart';
import 'package:taskforge/core/ui/tf_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/features/chat/application/chat_providers.dart';
import 'package:taskforge/features/chat/domain/chat.dart';
import 'package:taskforge/features/chat/presentation/chat_labels.dart';
import 'package:taskforge/features/comments/application/chat_prefs.dart';
import 'package:taskforge/features/members/application/members_providers.dart';
import 'package:taskforge/features/members/domain/members.dart';
import 'package:taskforge/core/ui/tf/tf_feedback.dart';
import 'package:taskforge/core/ui/tf/tf_illustration.dart';

/// The places to talk, grouped (Channels, Groups, Direct messages, Task
/// chats), with a search box. Tapping one calls [onOpen]; a task chat calls
/// [onOpenTask].
class SpaceListPane extends ConsumerStatefulWidget {
  const SpaceListPane({
    super.key,
    required this.selectedId,
    required this.onOpen,
    required this.onOpenTask,
  });

  final String? selectedId;
  final void Function(Space space) onOpen;
  final void Function(TaskChatRef chat) onOpenTask;

  @override
  ConsumerState<SpaceListPane> createState() => _SpaceListPaneState();
}

class _SpaceListPaneState extends ConsumerState<SpaceListPane> {
  var _query = '';

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(spacesProvider);
    final members = ref.watch(membersProvider).value ?? const <Member>[];
    final l10n = context.l10n;
    final list = state.list.matching(
      _query,
      (s) => spaceTitle(s, members, l10n),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(
            TfSpace.md,
            TfSpace.md,
            TfSpace.md,
            TfSpace.xs,
          ),
          child: TextField(
            key: const Key('chat-search'),
            decoration: InputDecoration(
              prefixIcon: const TfIcon(
                TfIcons.search,
                size: TfIconSize.control,
              ),
              hintText: l10n.chatSearchHint,
              isDense: true,
              border: const OutlineInputBorder(),
            ),
            onChanged: (v) => setState(() => _query = v),
          ),
        ),
        Expanded(child: _body(context, state, list, members)),
      ],
    );
  }

  Widget _body(
    BuildContext context,
    SpacesState state,
    SpaceList list,
    List<Member> members,
  ) {
    final l10n = context.l10n;
    if (state.loading && state.list.isEmpty) {
      return const _ListSkeleton(key: Key('chat-list-loading'));
    }
    if (state.error != null && state.list.isEmpty) {
      return TfError(
        key: const Key('chat-list-error'),
        compact: true,
        message: chatErrorMessage(state.error!, l10n),
        details: '${state.error}',
        retryKey: const Key('chat-list-retry'),
        onRetry: () => ref.read(spacesProvider.notifier).load(),
      );
    }
    if (list.isEmpty) {
      return TfEmpty(
        key: const Key('chat-list-empty'),
        compact: true,
        illustration: _query.isEmpty
            ? TfIllustrationKind.chat
            : TfIllustrationKind.search,
        title: _query.isEmpty ? l10n.chatNoSpaces : l10n.chatNoMatches,
      );
    }
    final now = ref.watch(chatNowProvider)();
    Widget header(String text, String key) => Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(
        TfSpace.lg,
        TfSpace.md,
        TfSpace.lg,
        TfSpace.xs,
      ),
      child: Text(
        text,
        key: Key(key),
        style: Theme.of(context).textTheme.labelLarge,
      ),
    );
    Widget tile(Space s, TfIconData icon) {
      final title = spaceTitle(s, members, l10n);
      return ListTile(
        key: Key('space-${s.id}'),
        dense: true,
        selected: s.id == widget.selectedId,
        leading: TfIcon(icon, size: 20),
        title: Text(
          title,
          overflow: TextOverflow.ellipsis,
          style: s.unreadCount > 0
              ? const TextStyle(fontWeight: FontWeight.bold)
              : null,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (s.isMuted(now))
              TfIcon(TfIcons.bellOff, size: 16, semanticLabel: l10n.chatMuted),
            if (s.unreadCount > 0)
              Badge(
                key: Key('unread-${s.id}'),
                label: Text(s.unreadCount > 99 ? '99+' : '${s.unreadCount}'),
              ),
          ],
        ),
        onTap: () => widget.onOpen(s),
      );
    }

    return ListView(
      key: const Key('chat-list'),
      children: [
        if (list.channels.isNotEmpty) ...[
          header(l10n.chatSectionChannels, 'section-channels'),
          for (final s in list.channels) tile(s, TfIcons.tag),
        ],
        if (list.groups.isNotEmpty) ...[
          header(l10n.chatSectionGroups, 'section-groups'),
          for (final s in list.groups) tile(s, TfIcons.lock),
        ],
        if (list.dms.isNotEmpty) ...[
          header(l10n.chatSectionDms, 'section-dms'),
          for (final s in list.dms) tile(s, TfIcons.user),
        ],
        if (list.taskChats.isNotEmpty) ...[
          header(l10n.chatSectionTaskChats, 'section-task-chats'),
          for (final t in list.taskChats)
            ListTile(
              key: Key('task-chat-${t.taskId}'),
              dense: true,
              leading: const TfIcon(TfIcons.success, size: 20),
              title: Text(t.title, overflow: TextOverflow.ellipsis),
              subtitle: t.displayId.isEmpty ? null : Text(t.displayId),
              onTap: () => widget.onOpenTask(t),
            ),
        ],
      ],
    );
  }
}

class _ListSkeleton extends StatelessWidget {
  const _ListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final grey = Theme.of(context).colorScheme.surfaceContainerHighest;
    return Column(
      children: [
        for (var i = 0; i < 5; i++)
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(
              TfSpace.lg,
              TfSpace.lg,
              TfSpace.lg,
              0,
            ),
            child: Container(
              height: 12,
              decoration: BoxDecoration(
                color: grey,
                borderRadius: TfRadius.chip,
              ),
            ),
          ),
      ],
    );
  }
}
