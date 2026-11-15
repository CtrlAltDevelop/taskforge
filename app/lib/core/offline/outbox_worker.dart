import 'dart:async';
import 'dart:convert';

import 'package:flutter/widgets.dart' show Locale;

import 'package:taskforge/core/offline/codecs.dart';
import 'package:taskforge/core/offline/offline_reason.dart';
import 'package:taskforge/core/offline/offline_store.dart';
import 'package:taskforge/core/offline/outbox.dart';
import 'package:taskforge/features/attachments/domain/attachments.dart';
import 'package:taskforge/features/chat/data/chat_client.dart';
import 'package:taskforge/features/chat/data/chat_codecs.dart';
import 'package:taskforge/features/chat/domain/chat.dart';
import 'package:taskforge/features/comments/data/comments_client.dart';
import 'package:taskforge/features/comments/domain/comments.dart';
import 'package:taskforge/features/tasks/data/tasks_client.dart';
import 'package:taskforge/features/tasks/domain/tasks.dart';
import 'package:taskforge/l10n/gen/app_localizations.dart';

/// What one pass over the outbox did.
class DrainResult {
  const DrainResult({
    this.sent = 0,
    this.conflicts = 0,
    this.rejected = 0,
    this.stoppedOffline = false,
  });

  final int sent;
  final int conflicts;
  final int rejected;

  /// It stopped because the server could not be reached; try again later.
  final bool stoppedOffline;

  bool get changedSomething => sent + conflicts + rejected > 0;
}

/// Sends the changes made offline, in the order they were made.
///
/// One entry at a time, each with its own mutation id (so a send that was cut
/// off is repeated safely). A change the server accepts leaves the queue and
/// its answer replaces the local copy. A change that clashes with someone
/// else's becomes a *conflict* and one the server refuses a *rejection*: both
/// wait for the person (nothing is ever dropped silently), and later changes to
/// the same task wait behind them. If the connection fails the pass stops and
/// the entry stays queued.
class OutboxWorker {
  OutboxWorker({
    required this.store,
    required this.tasks,
    required this.comments,
    this.chat,
    required this.workspace,
    required this.worked,
    required this.failed,
    this.uploadFile,
    this.dropFile,
  });

  final Future<OfflineStore?> Function() store;

  /// The real clients (not the offline ones: this is what sends).
  final TasksClient tasks;
  final CommentsClient comments;

  /// Where queued chat messages are sent (null: chat is not queued here).
  final ChatClient? chat;
  final String? Function() workspace;
  final void Function() worked;
  final void Function() failed;

  /// Uploads the kept file of an attachment entry; throws what the upload
  /// threw. Null where files cannot be queued.
  final Future<void> Function(OutboxEntry entry)? uploadFile;

  /// Deletes the kept file of an attachment entry.
  final Future<void> Function(OutboxEntry entry)? dropFile;

  bool _running = false;

  bool get running => _running;

  Future<DrainResult> drain() async {
    final ws = workspace();
    final db = await store();
    if (_running || ws == null || db == null) return const DrainResult();
    _running = true;
    try {
      return await _drain(db, ws);
    } finally {
      _running = false;
    }
  }

  Future<DrainResult> _drain(OfflineStore db, String ws) async {
    var sent = 0, conflicts = 0, rejected = 0;
    final blocked = <String>{};
    // A later edit of a task was made on top of the one before it, so once
    // that one is saved the next is expected to meet the version it made.
    final rebase = <String, int>{};
    final refused =
        <String, String>{}; // task id -> why its changes were refused
    for (final entry in await db.queue(ws)) {
      final key = _key(entry);
      if (entry.state.needsAttention) {
        blocked.add(key);
        if (entry.entity == OutboxEntity.task &&
            entry.op == OutboxOp.create &&
            entry.state == OutboxState.rejected) {
          refused[entry.entityId] = entry.error;
        }
        continue;
      }
      if (entry.state == OutboxState.sending) continue;
      final reason = refused[_taskOf(entry)];
      if (reason != null) {
        await db.setState(
          entry.id,
          OutboxState.rejected,
          error: dependentReason(reason),
        );
        rejected++;
        continue;
      }
      if (blocked.contains(key)) continue;
      final rebased = rebase[key];
      final current = rebased != null && entry.op == OutboxOp.update
          ? entry.copyWith(expectedVersion: rebased)
          : entry;
      if (current != entry) {
        await db.rewrite(entry.id, expectedVersion: rebased);
      }
      await db.setState(entry.id, OutboxState.sending, countAttempt: true);
      try {
        final version = await _send(db, ws, current);
        if (version != null) {
          rebase[key] = version;
          // Also for the next pass: an edit queued while this one was on its
          // way is not in the list this pass read.
          await db.rebaseAfter(entry.id, _taskOf(entry), version);
        }
        await db.removeEntry(entry.id);
        worked();
        sent++;
      } on TaskException catch (e) {
        if (e.failure != TaskFailure.network) worked(); // it answered
        final outcome = await _failed(db, entry, e.failure, e);
        if (outcome == _Outcome.offline) {
          return DrainResult(
            sent: sent,
            conflicts: conflicts,
            rejected: rejected,
            stoppedOffline: true,
          );
        }
        if (outcome == _Outcome.conflict) conflicts++;
        if (outcome == _Outcome.rejected) {
          rejected++;
          if (entry.entity == OutboxEntity.task &&
              entry.op == OutboxOp.create) {
            refused[entry.entityId] = taskReason(e);
          }
        }
        blocked.add(key);
      } on AttachmentException catch (e) {
        if (e.failure == AttachmentFailure.network) {
          failed();
          await db.setState(entry.id, OutboxState.pending);
          return DrainResult(
            sent: sent,
            conflicts: conflicts,
            rejected: rejected,
            stoppedOffline: true,
          );
        }
        worked();
        await db.setState(
          entry.id,
          OutboxState.rejected,
          error: attachmentReason(e),
        );
        rejected++;
      } on ChatException catch (e) {
        if (e.failure == ChatFailure.network) {
          failed();
          await db.setState(entry.id, OutboxState.pending);
          return DrainResult(
            sent: sent,
            conflicts: conflicts,
            rejected: rejected,
            stoppedOffline: true,
          );
        }
        worked(); // it answered, it only said no
        await db.setState(entry.id, OutboxState.rejected, error: chatReason(e));
        rejected++;
      } on CommentException catch (e) {
        if (e.failure == CommentFailure.network) {
          failed();
          await db.setState(entry.id, OutboxState.pending);
          return DrainResult(
            sent: sent,
            conflicts: conflicts,
            rejected: rejected,
            stoppedOffline: true,
          );
        }
        worked(); // it answered, it only said no
        await db.setState(
          entry.id,
          OutboxState.rejected,
          error: commentReason(e),
        );
        rejected++;
      }
    }
    return DrainResult(sent: sent, conflicts: conflicts, rejected: rejected);
  }

  /// What orders entries: those of one task (and the comments on it) stay in
  /// line; a comment is its own entry otherwise.
  static String _key(OutboxEntry e) => switch (e.entity) {
    OutboxEntity.task => 'task:${e.entityId}',
    OutboxEntity.chat => 'chat:${e.payload['spaceId']}',
    _ => 'task:${e.payload['taskId']}',
  };

  static String _taskOf(OutboxEntry e) => switch (e.entity) {
    OutboxEntity.task => e.entityId,
    OutboxEntity.chat => 'chat:${e.payload['spaceId']}',
    _ => '${e.payload['taskId']}',
  };

  Future<_Outcome> _failed(
    OfflineStore db,
    OutboxEntry entry,
    TaskFailure failure,
    TaskException error,
  ) async {
    switch (failure) {
      case TaskFailure.network:
        failed();
        await db.setState(entry.id, OutboxState.pending);
        return _Outcome.offline;
      case TaskFailure.conflict:
        final c = error.conflict;
        await db.setState(
          entry.id,
          OutboxState.conflict,
          error: taskReason(error),
          theirs: jsonEncode({
            'field': c?.field ?? '',
            'current': c?.current ?? '',
            'version': c?.version ?? 0,
          }),
        );
        return _Outcome.conflict;
      default:
        await db.setState(
          entry.id,
          OutboxState.rejected,
          error: taskReason(error),
        );
        return _Outcome.rejected;
    }
  }

  /// Sends [e]; returns the version it left a task at, when it edited one.
  Future<int?> _send(OfflineStore db, String ws, OutboxEntry e) async {
    switch ((e.entity, e.op)) {
      case (OutboxEntity.task, OutboxOp.create):
        final p = e.payload;
        final made = await tasks.create(
          ws,
          e.projectId,
          title: '${p['title']}',
          priority: TaskPriority.parse('${p['priority']}'),
          assigneeIds: [
            for (final a in (p['assigneeIds'] as List? ?? const [])) '$a',
          ],
          parentId: '${p['parentId'] ?? ''}',
          statusId: '${p['statusId'] ?? ''}',
          fieldValues: {
            for (final f in ((p['fieldValues'] as Map?) ?? const {}).entries)
              '${f.key}': '${f.value}',
          },
          clientId: e.entityId,
          mutationId: e.mutationId,
        );
        await _remember(db, ws, made);
        return made.version;
      case (OutboxEntity.task, OutboxOp.update):
        final saved = await tasks.update(
          ws,
          _stub(e),
          patchFromMap(e.payload),
          expectedVersion: e.expectedVersion,
          mutationId: e.mutationId,
        );
        await _remember(db, ws, saved);
        return saved.version;
      case (OutboxEntity.task, OutboxOp.delete):
        final mode = '${e.payload['mode'] ?? ''}';
        await tasks.delete(
          ws,
          e.projectId,
          e.entityId,
          mode: DeleteMode.values.where((m) => m.wire == mode).firstOrNull,
          mutationId: e.mutationId,
        );
      case (OutboxEntity.comment, OutboxOp.create):
        final p = e.payload;
        final made = await comments.create(
          ws,
          e.projectId,
          '${p['taskId']}',
          '${p['body']}',
          parentId: '${p['parentId'] ?? ''}',
          grantAccess: p['grantAccess'] == true,
          clientId: e.entityId,
          mutationId: e.mutationId,
        );
        await db.put(
          ws,
          Kinds.comment,
          made.id,
          commentToJson(made),
          scope: made.taskId,
          version: made.version,
        );
      case (OutboxEntity.chat, OutboxOp.create):
        final p = e.payload;
        final made = await chat?.send(
          ws,
          '${p['spaceId']}',
          '${p['body']}',
          parentId: '${p['parentId'] ?? ''}',
          clientId: e.entityId,
          mutationId: e.mutationId,
          confirmBroadcast: p['confirmBroadcast'] == true,
          grantAccess: p['grantAccess'] == true,
        );
        if (made != null) {
          await db.put(
            ws,
            Kinds.chatMessage,
            made.id,
            chatMessageToJson(made),
            scope: made.spaceId,
            version: made.version,
          );
        }
      case (OutboxEntity.attachment, OutboxOp.create):
        await uploadFile?.call(e);
        await dropFile?.call(e);
      case (OutboxEntity.comment, _) ||
          (OutboxEntity.attachment, _) ||
          (OutboxEntity.chat, _):
        break; // these are only ever created offline
    }
    return null;
  }

  Task _stub(OutboxEntry e) => Task(
    id: e.entityId,
    projectId: e.projectId,
    number: 0,
    displayId: '',
    title: '',
    statusId: '',
    version: e.expectedVersion,
  );

  Future<void> _remember(OfflineStore db, String ws, Task t) => db.put(
    ws,
    Kinds.task,
    t.id,
    taskToJson(t),
    scope: t.projectId,
    version: t.version,
  );

  // ------------------------------------------------------------ decisions

  /// "Keep mine" for a conflict: send my change again on top of theirs.
  Future<void> keepMine(OutboxEntry entry) async {
    final db = await store();
    if (db == null) return;
    final theirs = _theirs(entry);
    await db.rewrite(entry.id, expectedVersion: theirs.version);
    await db.setState(entry.id, OutboxState.pending);
  }

  /// "Take theirs": forget my change and read the task again.
  Future<void> takeTheirs(OutboxEntry entry) async {
    final db = await store();
    if (db == null) return;
    await db.removeEntry(entry.id);
    await refreshTask(entry);
  }

  /// "Merge": keep only the fields in [mine] of my change, on top of theirs.
  Future<void> merge(OutboxEntry entry, Set<String> mine) async {
    final db = await store();
    if (db == null) return;
    final kept = {
      for (final f in entry.payload.entries)
        if (mine.contains(f.key)) f.key: f.value,
    };
    if (kept.isEmpty) return takeTheirs(entry);
    await db.rewrite(
      entry.id,
      payload: kept,
      expectedVersion: _theirs(entry).version,
    );
    await db.setState(entry.id, OutboxState.pending);
  }

  /// A refused change: try it again (the reason may be gone), or let it go.
  Future<void> retry(OutboxEntry entry) async {
    final db = await store();
    await db?.setState(entry.id, OutboxState.pending);
  }

  Future<void> discard(OutboxEntry entry) async {
    final db = await store();
    if (db == null) return;
    await db.removeEntry(entry.id);
    await dropFile?.call(entry);
    if (entry.entity == OutboxEntity.task && entry.op == OutboxOp.create) {
      await db.remove(entry.workspaceId, Kinds.task, entry.entityId);
      return;
    }
    await refreshTask(entry);
  }

  /// Reads the task of [entry] from the server into the local copy, when it
  /// can be reached (the copy keeps the person's edit until then).
  Future<void> refreshTask(OutboxEntry entry) async {
    final db = await store();
    if (db == null || entry.entity != OutboxEntity.task) return;
    try {
      final t = await tasks.get(
        entry.workspaceId,
        entry.projectId,
        entry.entityId,
      );
      await _remember(db, entry.workspaceId, t);
    } on TaskException {
      // Offline, or the task is gone: the next list read settles it.
    }
  }

  ConflictInfo _theirs(OutboxEntry e) => ConflictInfo.parse(e.theirs);
}

enum _Outcome { offline, conflict, rejected }

/// What the server said about a clash: which field, its value, its version.
class ConflictInfo {
  const ConflictInfo({
    required this.field,
    required this.current,
    required this.version,
  });

  final String field;
  final String current;
  final int version;

  factory ConflictInfo.parse(String json) {
    if (json.isEmpty) {
      return const ConflictInfo(field: '', current: '', version: 0);
    }
    final m = jsonDecode(json) as Map<String, dynamic>;
    return ConflictInfo(
      field: '${m['field'] ?? ''}',
      current: '${m['current'] ?? ''}',
      version: (m['version'] as num?)?.toInt() ?? 0,
    );
  }
}

/// What to tell the person about a refused comment, in the language of [l10n]
/// (English when null).
String commentErrorText(CommentException e, [AppLocalizations? l10n]) {
  final t = l10n ?? lookupAppLocalizations(const Locale('en'));
  return switch (e.failure) {
    CommentFailure.denied || CommentFailure.forbidden => t.grpRCmForbidden,
    CommentFailure.notFound => t.grpRCmGone,
    CommentFailure.archived => t.grpRCmArchived,
    CommentFailure.invalid => e.detail ?? t.grpRCmInvalid,
    CommentFailure.mentionNoAccess => t.grpRCmMention,
    _ => t.grpRCmRefused,
  };
}

/// What to tell the person about a refused chat message.
String chatReason(ChatException e, [AppLocalizations? l10n]) {
  final t = l10n ?? lookupAppLocalizations(const Locale('en'));
  return switch (e.failure) {
    ChatFailure.denied || ChatFailure.forbidden => t.grpRCmForbidden,
    ChatFailure.notFound => t.grpRCmGone,
    ChatFailure.archived => t.grpRCmArchived,
    ChatFailure.invalid => e.detail ?? t.grpRCmInvalid,
    ChatFailure.mentionNoAccess => t.grpRCmMention,
    _ => t.grpRCmRefused,
  };
}
