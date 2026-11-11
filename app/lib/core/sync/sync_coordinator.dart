// `Ref.exists` is deprecated for a replacement this Riverpod does not have yet;
// it is the only way to ask whether a screen's provider is alive without making it.
// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/core/permissions/refusals.dart';
import 'package:taskforge/core/sync/sync_models.dart';
import 'package:taskforge/core/sync/sync_providers.dart';
import 'package:taskforge/features/attachments/application/attachments_providers.dart';
import 'package:taskforge/features/board/application/board_providers.dart';
import 'package:taskforge/features/calendar/application/calendar_providers.dart';
import 'package:taskforge/features/comments/application/comments_providers.dart';
import 'package:taskforge/features/fields/application/fields_providers.dart';
import 'package:taskforge/features/inbox/application/inbox_providers.dart';
import 'package:taskforge/features/inbox/domain/inbox.dart';
import 'package:taskforge/features/members/application/members_providers.dart';
import 'package:taskforge/features/projects/application/projects_providers.dart';
import 'package:taskforge/features/roles/application/roles_providers.dart';
import 'package:taskforge/features/sprints/application/sprints_providers.dart';
import 'package:taskforge/features/tasks/application/tasks_providers.dart';
import 'package:taskforge/features/time/application/time_providers.dart';
import 'package:taskforge/features/timeline/application/timeline_providers.dart';
import 'package:taskforge/features/workflows/application/workflows_providers.dart';

/// Changes that come in a burst (a bulk edit, a cascade) are read once.
const syncCoalesce = Duration(milliseconds: 200);

/// Turns what the live feed says into reads of the screens that are open.
///
/// An event is a hint (what and how far), never the data: the open views read
/// themselves again (each keeps the newer version of a task, so an answer that
/// overtakes another cannot undo it). Events made by this very app are
/// skipped, because their result is already on screen. Watch this once, high
/// in the tree.
final syncCoordinatorProvider = Provider<void>((ref) {
  final client = ref.watch(syncClientProvider);
  if (client == null) return;
  ref.watch(
    presenceProvider,
  ); // listening from the start, so no frame is missed
  final pending = <String>{}; // project ids to read again
  final commentTasks = <TaskRef>{}; // tasks whose comments to read again
  final fileTasks = <TaskRef>{}; // tasks whose attachments to read again
  var everything = false;
  var inboxDirty = false; // the inbox and its badges to read again
  Timer? timer;

  void flush() {
    timer = null;
    final projects = everything
        ? {
            for (final r in client.rooms)
              if (r.startsWith('proj:')) r.substring(5),
          }
        : {...pending};
    final all = everything;
    pending.clear();
    everything = false;
    for (final task in commentTasks) {
      if (ref.exists(commentsProvider(task))) {
        unawaited(ref.read(commentsProvider(task).notifier).refresh());
      }
    }
    commentTasks.clear();
    for (final task in fileTasks) {
      if (ref.exists(attachmentsProvider(task))) {
        unawaited(ref.read(attachmentsProvider(task).notifier).refresh());
      }
    }
    if (fileTasks.isNotEmpty) ref.invalidate(storageUsageProvider);
    fileTasks.clear();
    if (inboxDirty) {
      inboxDirty = false;
      _readInboxAgain(ref);
    }
    for (final project in projects) {
      _readAgain(ref, project);
    }
    if (all || projects.isNotEmpty) {
      if (ref.exists(calendarProvider(''))) {
        ref.read(calendarProvider('').notifier).refresh();
      }
    }
  }

  void soon() => timer ??= Timer(syncCoalesce, flush);

  void hear(SyncEvent event) {
    final own = client.ownOrigin;
    if (own.isNotEmpty && event.origin == own) {
      return; // this app's own write: already on screen
    }
    if (event.isGap) {
      everything = true;
      inboxDirty = true;
      readTimeAgain(ref);
      readSprintsAgain(ref);
      _everythingElse(ref);
      soon();
      return;
    }
    if (event.type.startsWith('notification.')) {
      // The entity is this person: the badges and the open inbox read again.
      inboxDirty = true;
      soon();
      return;
    }
    if (event.type == 'timer.changed') {
      // The entity is this person: their timer, entries and totals read again.
      readTimeAgain(ref);
      return;
    }
    if (event.type.startsWith('sprint.')) {
      // A sprint changed (or its tasks moved): sprints, backlog and burndowns
      // read again.
      readSprintsAgain(ref);
      return;
    }
    if (event.type == 'access.changed') {
      _access(ref);
      everything = true;
      soon();
      return;
    }
    if (event.isTask) {
      ref.invalidate(backlogProvider(event.project));
      ref.invalidate(sprintTasksProvider);
      ref.read(recentChangesProvider.notifier).flash([event.entityId]);
      if (ref.exists(taskLinksProvider(event.entityId))) {
        ref.invalidate(taskLinksProvider(event.entityId));
      }
    }
    if (event.type.startsWith('attachment.')) {
      // The entity of an attachment event is its task.
      fileTasks.add((project: event.project, task: event.entityId));
      soon();
      return;
    }
    if (event.type.startsWith('comment.')) {
      // The entity of a comment event is its task.
      commentTasks.add((project: event.project, task: event.entityId));
      soon();
      return;
    }
    if (event.type.startsWith('project.')) ref.invalidate(projectsProvider);
    if (event.type == 'workflow.updated') {
      ref.invalidate(workflowProvider(event.project));
    }
    if (event.type == 'fields.updated') {
      ref.invalidate(fieldsProvider(event.project));
    }
    if (event.project.isNotEmpty) pending.add(event.project);
    soon();
  }

  final events = client.events.listen(hear);
  final lost = client.lost.listen((room) {
    if (room.reason == 'access') _access(ref);
  });
  ref.onDispose(() {
    timer?.cancel();
    unawaited(events.cancel());
    unawaited(lost.cancel());
  });
});

/// Reads again whatever is open for [project]: the list, the board, the
/// calendar, the timeline and the unscheduled tray.
void _readAgain(Ref ref, String project) {
  if (ref.exists(taskListProvider(project))) {
    unawaited(ref.read(taskListProvider(project).notifier).refresh());
  }
  if (ref.exists(boardProvider(project))) {
    unawaited(ref.read(boardProvider(project).notifier).refresh());
  }
  if (ref.exists(calendarProvider(project))) {
    ref.read(calendarProvider(project).notifier).refresh();
  }
  if (ref.exists(timelineProvider(project))) {
    ref.read(timelineProvider(project).notifier).refresh();
  }
  if (ref.exists(trayProvider(project))) {
    unawaited(ref.read(trayProvider(project).notifier).load());
  }
}

/// Who may do what, who is in the workspace and which projects can be seen
/// may all have changed.
void _access(Ref ref) {
  ref.invalidate(permissionsProvider);
  ref.invalidate(membersProvider);
  ref.invalidate(projectsProvider);
  ref.read(refusalCountProvider.notifier).bump();
}

/// What a gap (the change log no longer reaches back far enough) asks for
/// besides the open views: the catalogues and the open lists of files.
void _everythingElse(Ref ref) {
  ref.invalidate(projectsProvider);
  ref.invalidate(membersProvider);
  // Every open list of files reads again, and what the workspace uses.
  ref.read(attachmentsResyncProvider.notifier).bump();
  ref.invalidate(storageUsageProvider);
}

/// The badges and whichever inbox list is open read again.
void _readInboxAgain(Ref ref) {
  ref.invalidate(unreadCountProvider);
  ref.invalidate(unreadTotalProvider);
  for (final filter in InboxFilter.values) {
    if (ref.exists(inboxProvider(filter))) {
      unawaited(ref.read(inboxProvider(filter).notifier).refresh());
    }
  }
}
