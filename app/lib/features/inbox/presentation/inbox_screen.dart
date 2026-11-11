import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:taskforge/features/inbox/application/inbox_providers.dart';
import 'package:taskforge/features/inbox/domain/inbox.dart';
import 'package:taskforge/features/inbox/presentation/snooze_sheet.dart';
import 'package:taskforge/features/projects/presentation/app_shell.dart';
import 'package:taskforge/features/workspaces/presentation/workspace_switcher.dart';

enum NotificationMenu { toggleRead, snooze, unsnooze, archive, unarchive }

/// Everything addressed to this person in the current workspace, with
/// filters, and what can be done with each item.
class InboxScreen extends ConsumerStatefulWidget {
  const InboxScreen({super.key});

  @override
  ConsumerState<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends ConsumerState<InboxScreen> {
  var _filter = InboxFilter.all;

  InboxNotifier get _notifier => ref.read(inboxProvider(_filter).notifier);

  void _say(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  /// Runs [action], saying in words what went wrong.
  Future<void> _guard(Future<void> Function() action) async {
    try {
      await action();
    } on Object catch (e) {
      _say(inboxErrorMessage(e));
    }
  }

  void _open(InboxNotification n) {
    final notifier = _notifier;
    final messenger = ScaffoldMessenger.of(context);
    unawaited(
      notifier.markRead(n).catchError((Object e) {
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(inboxErrorMessage(e))));
      }),
    );
    if (n.canOpen) {
      context.go('/projects/${n.projectId}?task=${n.taskId}');
    }
  }

  Future<void> _menu(InboxNotification n, NotificationMenu choice) async {
    switch (choice) {
      case NotificationMenu.toggleRead:
        await _guard(() => _notifier.markRead(n, read: !n.isRead));
      case NotificationMenu.snooze:
        final until = await pickSnooze(context, ref.read(inboxNowProvider)());
        if (until != null && mounted) {
          await _guard(() => _notifier.snooze(n, until));
        }
      case NotificationMenu.unsnooze:
        await _guard(() => _notifier.snooze(n, null));
      case NotificationMenu.archive:
        await _guard(() => _notifier.archive(n));
      case NotificationMenu.unarchive:
        await _guard(() => _notifier.archive(n, archived: false));
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(inboxProvider(_filter));
    final now = ref.watch(inboxNowProvider)();
    return ShellScaffold(
      appBar: AppBar(
        title: const WorkspaceSwitcher(),
        actions: [
          IconButton(
            key: const Key('mark-all-read'),
            tooltip: 'Mark all read',
            icon: const Icon(Icons.done_all),
            onPressed: state.unread == 0
                ? null
                : () => _guard(_notifier.markAllRead),
          ),
          IconButton(
            key: const Key('open-notification-prefs'),
            tooltip: 'Notification settings',
            icon: const Icon(Icons.tune),
            onPressed: () => context.push('/inbox/preferences'),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              children: [
                Text('Inbox', style: Theme.of(context).textTheme.titleLarge),
                if (state.unread > 0) ...[
                  const SizedBox(width: 8),
                  Chip(
                    key: const Key('unread-total'),
                    label: Text('${state.unread} unread'),
                  ),
                ],
              ],
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                for (final f in InboxFilter.values)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      key: Key('filter-${f.wire}'),
                      label: Text(f.label),
                      selected: _filter == f,
                      onSelected: (_) => setState(() => _filter = f),
                    ),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(child: _body(state, now)),
        ],
      ),
    );
  }

  Widget _body(InboxState state, DateTime now) {
    if (state.loading && state.items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.error != null && state.items.isEmpty) {
      return Center(
        child: Semantics(
          liveRegion: true,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                inboxErrorMessage(state.error!),
                key: const Key('inbox-error'),
              ),
              TextButton(
                key: const Key('retry-inbox'),
                onPressed: _notifier.load,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }
    if (state.items.isEmpty) {
      return Center(
        child: Text(_empty(_filter), key: const Key('inbox-empty')),
      );
    }
    return RefreshIndicator(
      onRefresh: _notifier.refresh,
      child: ListView.builder(
        key: const Key('inbox-list'),
        itemCount: state.items.length + (state.hasMore ? 1 : 0),
        itemBuilder: (context, i) {
          if (i == state.items.length) {
            return Padding(
              padding: const EdgeInsets.all(8),
              child: Center(
                child: state.loadingMore
                    ? const CircularProgressIndicator()
                    : TextButton(
                        key: const Key('load-more'),
                        onPressed: _notifier.loadMore,
                        child: const Text('Load more'),
                      ),
              ),
            );
          }
          final n = state.items[i];
          return NotificationTile(
            key: Key('notification-${n.id}'),
            notification: n,
            now: now,
            filter: _filter,
            onTap: () => _open(n),
            onMenu: (c) => _menu(n, c),
          );
        },
      ),
    );
  }
}

String _empty(InboxFilter f) => switch (f) {
  InboxFilter.all => 'Nothing here. You are all caught up.',
  InboxFilter.unread => 'No unread notifications.',
  InboxFilter.mentions => 'Nobody has mentioned you.',
  InboxFilter.assigned => 'Nothing assigned to you lately.',
  InboxFilter.snoozed => 'Nothing is snoozed.',
  InboxFilter.archived => 'Nothing is archived.',
};

/// One row: who did what to which task, when, and a menu of what to do next.
class NotificationTile extends StatelessWidget {
  const NotificationTile({
    super.key,
    required this.notification,
    required this.now,
    required this.filter,
    required this.onTap,
    required this.onMenu,
  });

  final InboxNotification notification;
  final DateTime now;
  final InboxFilter filter;
  final VoidCallback onTap;
  final void Function(NotificationMenu) onMenu;

  @override
  Widget build(BuildContext context) {
    final n = notification;
    final theme = Theme.of(context);
    final unread = !n.isRead;
    final title = '${n.what} ${n.taskLabel}'.trim();
    final detail = n.excerpt.isNotEmpty
        ? n.excerpt
        : n.dueDate.isNotEmpty
        ? 'Due ${n.dueDate}'
        : null;
    return Semantics(
      label: '${unread ? 'Unread. ' : ''}$title',
      container: true,
      child: ListTile(
        onTap: onTap,
        tileColor: unread
            ? theme.colorScheme.primaryContainer.withAlpha(60)
            : null,
        leading: Stack(
          clipBehavior: Clip.none,
          children: [
            CircleAvatar(child: Icon(n.kind.icon)),
            if (unread)
              Positioned(
                right: -2,
                top: -2,
                child: Container(
                  key: Key('unread-${n.id}'),
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
        title: Text(
          title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: unread ? const TextStyle(fontWeight: FontWeight.w700) : null,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (detail != null)
              Text(detail, maxLines: 2, overflow: TextOverflow.ellipsis),
            Row(
              children: [
                Text(relativeTime(n.updatedAt, now), key: Key('time-${n.id}')),
                if (n.count > 1) ...[
                  const SizedBox(width: 8),
                  Chip(
                    key: Key('count-${n.id}'),
                    visualDensity: VisualDensity.compact,
                    label: Text('+${n.count - 1} more'),
                  ),
                ],
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<NotificationMenu>(
          key: Key('menu-${n.id}'),
          tooltip: 'More',
          onSelected: onMenu,
          itemBuilder: (_) => [
            PopupMenuItem(
              key: const Key('menu-toggle-read'),
              value: NotificationMenu.toggleRead,
              child: Text(n.isRead ? 'Mark unread' : 'Mark read'),
            ),
            if (n.isSnoozed(now))
              const PopupMenuItem(
                key: Key('menu-unsnooze'),
                value: NotificationMenu.unsnooze,
                child: Text('Stop snoozing'),
              )
            else
              const PopupMenuItem(
                key: Key('menu-snooze'),
                value: NotificationMenu.snooze,
                child: Text('Snooze…'),
              ),
            if (n.isArchived)
              const PopupMenuItem(
                key: Key('menu-unarchive'),
                value: NotificationMenu.unarchive,
                child: Text('Move to inbox'),
              )
            else
              const PopupMenuItem(
                key: Key('menu-archive'),
                value: NotificationMenu.archive,
                child: Text('Archive'),
              ),
          ],
        ),
      ),
    );
  }
}
