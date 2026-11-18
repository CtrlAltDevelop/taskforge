import 'package:taskforge/core/ui/tf_app_bar.dart';

import 'package:taskforge/core/ui/tf_icons.dart';

import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:taskforge/core/i18n/context_dates.dart';
import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/features/inbox/application/inbox_providers.dart';
import 'package:taskforge/features/inbox/domain/inbox.dart';
import 'package:taskforge/features/inbox/presentation/snooze_sheet.dart';
import 'package:taskforge/l10n/gen/app_localizations.dart';

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
      if (mounted) _say(inboxErrorMessage(e, context.l10n));
    }
  }

  void _open(InboxNotification n) {
    final notifier = _notifier;
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    unawaited(
      notifier.markRead(n).catchError((Object e) {
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(inboxErrorMessage(e, l10n))));
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
    return Scaffold(
      appBar: TfAppBar(
        title: Text(context.l10n.grpEInbox),
        actions: [
          IconButton(
            key: const Key('mark-all-read'),
            tooltip: context.l10n.grpHMarkAllRead,
            icon: const TfIcon(TfIcons.checkAll, size: 24),
            onPressed: state.unread == 0
                ? null
                : () => _guard(_notifier.markAllRead),
          ),
          IconButton(
            key: const Key('open-notification-prefs'),
            tooltip: context.l10n.grpHNotificationSettings,
            icon: const TfIcon(TfIcons.tune, size: 24),
            onPressed: () => context.push('/inbox/preferences'),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 4),
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    context.l10n.grpHInbox,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                if (state.unread > 0) ...[
                  const SizedBox(width: 8),
                  Chip(
                    key: const Key('unread-total'),
                    label: Text(context.l10n.grpHUnreadCount(state.unread)),
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
                      label: Text(f.labelIn(context.l10n)),
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
                inboxErrorMessage(state.error!, context.l10n),
                key: const Key('inbox-error'),
              ),
              TextButton(
                key: const Key('retry-inbox'),
                onPressed: _notifier.load,
                child: Text(context.l10n.grpHRetry),
              ),
            ],
          ),
        ),
      );
    }
    if (state.items.isEmpty) {
      return Center(
        child: Text(
          _empty(context.l10n, _filter),
          key: const Key('inbox-empty'),
        ),
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
                        child: Text(context.l10n.grpHLoadMore),
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

String _empty(AppLocalizations l10n, InboxFilter f) => switch (f) {
  InboxFilter.all => l10n.grpHEmptyAll,
  InboxFilter.unread => l10n.grpHEmptyUnread,
  InboxFilter.mentions => l10n.grpHEmptyMentions,
  InboxFilter.assigned => l10n.grpHEmptyAssigned,
  InboxFilter.snoozed => l10n.grpHEmptySnoozed,
  InboxFilter.archived => l10n.grpHEmptyArchived,
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
    final title = '${n.whatIn(context.l10n)} ${n.taskLabel}'.trim();
    final detail = n.excerpt.isNotEmpty
        ? n.excerpt
        : n.dueDate.isNotEmpty
        ? context.l10n.grpHDueDate(n.dueDate)
        : null;
    return Semantics(
      label: unread ? context.l10n.grpHUnreadPrefix(title) : title,
      container: true,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        clipBehavior: Clip.antiAlias,
        color: unread ? theme.colorScheme.primaryContainer.withAlpha(60) : null,
        child: ListTile(
          onTap: onTap,
          leading: Stack(
            clipBehavior: Clip.none,
            children: [
              CircleAvatar(child: Icon(n.kind.icon)),
              if (unread)
                PositionedDirectional(
                  end: -2,
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
                  Flexible(
                    child: Text(
                      relativeTime(
                        n.updatedAt,
                        now,
                        context.l10n,
                        context.localePrefs,
                      ),
                      key: Key('time-${n.id}'),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (n.count > 1) ...[
                    const SizedBox(width: 8),
                    Chip(
                      key: Key('count-${n.id}'),
                      visualDensity: VisualDensity.compact,
                      label: Text(context.l10n.grpHMoreCount(n.count - 1)),
                    ),
                  ],
                ],
              ),
            ],
          ),
          trailing: PopupMenuButton<NotificationMenu>(
            key: Key('menu-${n.id}'),
            tooltip: context.l10n.grpHMore,
            onSelected: onMenu,
            itemBuilder: (_) => [
              PopupMenuItem(
                key: const Key('menu-toggle-read'),
                value: NotificationMenu.toggleRead,
                child: Text(
                  n.isRead
                      ? context.l10n.grpHMarkUnread
                      : context.l10n.grpHMarkRead,
                ),
              ),
              if (n.isSnoozed(now))
                PopupMenuItem(
                  key: const Key('menu-unsnooze'),
                  value: NotificationMenu.unsnooze,
                  child: Text(context.l10n.grpHStopSnoozing),
                )
              else
                PopupMenuItem(
                  key: const Key('menu-snooze'),
                  value: NotificationMenu.snooze,
                  child: Text(context.l10n.grpHSnoozeEllipsis),
                ),
              if (n.isArchived)
                PopupMenuItem(
                  key: const Key('menu-unarchive'),
                  value: NotificationMenu.unarchive,
                  child: Text(context.l10n.grpHMoveToInbox),
                )
              else
                PopupMenuItem(
                  key: const Key('menu-archive'),
                  value: NotificationMenu.archive,
                  child: Text(context.l10n.grpHArchive),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
