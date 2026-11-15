import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/features/chat/application/chat_providers.dart';
import 'package:taskforge/features/chat/domain/chat.dart';
import 'package:taskforge/features/chat/presentation/chat_labels.dart';
import 'package:taskforge/features/comments/application/chat_prefs.dart';
import 'package:taskforge/features/members/application/members_providers.dart';
import 'package:taskforge/features/members/domain/members.dart';

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
          padding: const EdgeInsetsDirectional.fromSTEB(12, 12, 12, 4),
          child: TextField(
            key: const Key('chat-search'),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
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
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              chatErrorMessage(state.error!, l10n),
              key: const Key('chat-list-error'),
              textAlign: TextAlign.center,
            ),
            TextButton(
              key: const Key('chat-list-retry'),
              onPressed: () => ref.read(spacesProvider.notifier).load(),
              child: Text(l10n.retry),
            ),
          ],
        ),
      );
    }
    if (list.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            _query.isEmpty ? l10n.chatNoSpaces : l10n.chatNoMatches,
            key: const Key('chat-list-empty'),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    final now = ref.watch(chatNowProvider)();
    Widget header(String text, String key) => Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 4),
      child: Text(
        text,
        key: Key(key),
        style: Theme.of(context).textTheme.labelLarge,
      ),
    );
    Widget tile(Space s, IconData icon) {
      final title = spaceTitle(s, members, l10n);
      return ListTile(
        key: Key('space-${s.id}'),
        dense: true,
        selected: s.id == widget.selectedId,
        leading: Icon(icon, size: 20),
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
              Icon(
                Icons.notifications_off_outlined,
                size: 16,
                semanticLabel: l10n.chatMuted,
              ),
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
          for (final s in list.channels) tile(s, Icons.tag),
        ],
        if (list.groups.isNotEmpty) ...[
          header(l10n.chatSectionGroups, 'section-groups'),
          for (final s in list.groups) tile(s, Icons.lock_outline),
        ],
        if (list.dms.isNotEmpty) ...[
          header(l10n.chatSectionDms, 'section-dms'),
          for (final s in list.dms) tile(s, Icons.person_outline),
        ],
        if (list.taskChats.isNotEmpty) ...[
          header(l10n.chatSectionTaskChats, 'section-task-chats'),
          for (final t in list.taskChats)
            ListTile(
              key: Key('task-chat-${t.taskId}'),
              dense: true,
              leading: const Icon(Icons.check_circle_outline, size: 20),
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
            padding: const EdgeInsetsDirectional.fromSTEB(16, 14, 16, 0),
            child: Container(
              height: 12,
              decoration: BoxDecoration(
                color: grey,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
      ],
    );
  }
}
