import 'dart:convert';

import 'package:drift/drift.dart';

import 'package:taskforge/core/offline/local_db.dart';
import 'package:taskforge/core/offline/outbox.dart';

/// What lives in [CachedRows], by kind.
abstract final class Kinds {
  static const workspaces = 'workspaces';
  static const projects = 'projects';
  static const task = 'task';
  static const comment = 'comment';
  static const members = 'members';
  static const workflow = 'workflow';
  static const fields = 'fields';
}

/// How much the cache may hold unless the person chose another size.
const defaultCacheBytes = 50 * 1024 * 1024;
const _capKey = 'cache_cap_bytes';
const _keptKey = 'offline_projects';

/// The local copy and the outbox, over [LocalDb].
class OfflineStore {
  OfflineStore(this.db, {DateTime Function()? now})
    : _now = now ?? DateTime.now;

  final LocalDb db;
  final DateTime Function() _now;

  /// Closed to writes: set from the moment of sign-out, so a read or a send
  /// still in flight cannot put the previous person's rows back after the
  /// wipe. Opened again when somebody signs in.
  bool sealed = false;

  // ------------------------------------------------------------------ cache

  Future<void> put(
    String workspaceId,
    String kind,
    String id,
    String json, {
    String scope = '',
    int version = 0,
  }) async {
    if (sealed) return;
    await db
        .into(db.cachedRows)
        .insertOnConflictUpdate(
          CachedRowsCompanion.insert(
            workspaceId: workspaceId,
            kind: kind,
            id: id,
            scope: Value(scope),
            version: Value(version),
            json: json,
            savedAt: _now(),
          ),
        );
  }

  /// Writes every row in one transaction.
  Future<void> putAll(
    String workspaceId,
    String kind,
    Iterable<({String id, String json, int version})> rows, {
    String scope = '',
  }) async {
    if (sealed) return;
    await _putAll(workspaceId, kind, rows, scope);
  }

  Future<void> _putAll(
    String workspaceId,
    String kind,
    Iterable<({String id, String json, int version})> rows,
    String scope,
  ) => db.batch((b) {
    final at = _now();
    b.insertAllOnConflictUpdate(db.cachedRows, [
      for (final r in rows)
        CachedRowsCompanion.insert(
          workspaceId: workspaceId,
          kind: kind,
          id: r.id,
          scope: Value(scope),
          version: Value(r.version),
          json: r.json,
          savedAt: at,
        ),
    ]);
  });

  Future<String?> get(String workspaceId, String kind, String id) async {
    final row =
        await (db.select(db.cachedRows)..where(
              (r) =>
                  r.workspaceId.equals(workspaceId) &
                  r.kind.equals(kind) &
                  r.id.equals(id),
            ))
            .getSingleOrNull();
    return row?.json;
  }

  /// The JSON of every row of [kind] (in [scope] when given), oldest saved
  /// first.
  Future<List<String>> list(
    String workspaceId,
    String kind, {
    String? scope,
  }) async {
    final query = db.select(db.cachedRows)
      ..where(
        (r) =>
            r.workspaceId.equals(workspaceId) &
            r.kind.equals(kind) &
            (scope == null ? const Constant(true) : r.scope.equals(scope)),
      )
      ..orderBy([
        (r) => OrderingTerm.asc(r.savedAt),
        (r) => OrderingTerm.asc(r.id),
      ]);
    return [for (final r in await query.get()) r.json];
  }

  Future<void> remove(String workspaceId, String kind, String id) =>
      (db.delete(db.cachedRows)..where(
            (r) =>
                r.workspaceId.equals(workspaceId) &
                r.kind.equals(kind) &
                r.id.equals(id),
          ))
          .go();

  /// Removes the rows of [scope] that are not in [keep] (what the server no
  /// longer has), except those whose id is in [protect] (made here, not sent).
  Future<void> sweep(
    String workspaceId,
    String kind,
    String scope,
    Set<String> keep, {
    Set<String> protect = const {},
  }) =>
      (db.delete(db.cachedRows)..where(
            (r) =>
                r.workspaceId.equals(workspaceId) &
                r.kind.equals(kind) &
                r.scope.equals(scope) &
                r.id.isNotIn([...keep, ...protect]),
          ))
          .go();

  /// How many bytes of JSON the cache holds (of one workspace, or all).
  Future<int> sizeBytes({String? workspaceId}) async {
    final length = db.cachedRows.json.length.sum();
    final query = db.selectOnly(db.cachedRows)..addColumns([length]);
    if (workspaceId != null) {
      query.where(db.cachedRows.workspaceId.equals(workspaceId));
    }
    return (await query.map((r) => r.read(length)).getSingle()) ?? 0;
  }

  Future<int> cacheCap() async {
    final v = await _meta(_capKey);
    return int.tryParse(v ?? '') ?? defaultCacheBytes;
  }

  Future<void> setCacheCap(int bytes) => _setMeta(_capKey, '$bytes');

  /// Drops the oldest cached tasks and comments until the cache fits its cap
  /// again; never touches what the outbox still needs. Returns how many rows
  /// went.
  Future<int> trimToCap({String? workspaceId}) async {
    final cap = await cacheCap();
    var size = await sizeBytes(workspaceId: workspaceId);
    if (size <= cap) return 0;
    final waiting = await _waitingIds();
    final kept = {
      for (final ws in await _workspacesWithKept()) ...await keptProjects(ws),
    };
    final rows =
        await (db.select(db.cachedRows)
              ..where(
                (r) =>
                    r.kind.isIn(const [Kinds.task, Kinds.comment]) &
                    (workspaceId == null
                        ? const Constant(true)
                        : r.workspaceId.equals(workspaceId)),
              )
              ..orderBy([(r) => OrderingTerm.asc(r.savedAt)]))
            .get();
    var dropped = 0;
    for (final r in rows) {
      if (size <= cap) break;
      if (waiting.contains(r.id) || kept.contains(r.scope)) continue;
      await remove(r.workspaceId, r.kind, r.id);
      size -= r.json.length;
      dropped++;
    }
    return dropped;
  }

  Future<Set<String>> _waitingIds() async {
    final rows = await db.select(db.outboxRows).get();
    return {
      for (final r in rows) ...[r.entityId, ?_taskOf(r.payload)],
    };
  }

  static String? _taskOf(String payload) {
    final task = (jsonDecode(payload) as Map<String, dynamic>)['taskId'];
    return task is String ? task : null;
  }

  // ------------------------------------------------------- offline projects

  Future<Set<String>> _workspacesWithKept() async {
    final rows = await (db.select(
      db.offlineMeta,
    )..where((m) => m.key.like('$_keptKey:%'))).get();
    return {for (final r in rows) r.key.substring(_keptKey.length + 1)};
  }

  /// The projects the person asked to keep for offline use.
  Future<Set<String>> keptProjects(String workspaceId) async {
    final v = await _meta('$_keptKey:$workspaceId');
    return {...?v?.split(',').where((s) => s.isNotEmpty)};
  }

  Future<void> setKeptProjects(String workspaceId, Set<String> ids) =>
      _setMeta('$_keptKey:$workspaceId', ids.join(','));

  /// Whether a full list of [projectId] was read here, so an empty copy
  /// means "no tasks" and not "never read".
  Future<bool> projectRead(String workspaceId, String projectId) async =>
      await _meta('read:$workspaceId:$projectId') != null;

  Future<void> markProjectRead(String workspaceId, String projectId) =>
      _setMeta('read:$workspaceId:$projectId', '1');

  Future<String?> _meta(String key) async => (await (db.select(
    db.offlineMeta,
  )..where((m) => m.key.equals(key))).getSingleOrNull())?.value;

  Future<void> _setMeta(String key, String value) => db
      .into(db.offlineMeta)
      .insertOnConflictUpdate(
        OfflineMetaCompanion.insert(key: key, value: value),
      );

  // ----------------------------------------------------------------- cursor

  Future<String> cursor(String workspaceId) async =>
      (await (db.select(
            db.syncCursors,
          )..where((c) => c.workspaceId.equals(workspaceId))).getSingleOrNull())
          ?.cursor ??
      '';

  Future<void> setCursor(String workspaceId, String cursor) => db
      .into(db.syncCursors)
      .insertOnConflictUpdate(
        SyncCursorsCompanion.insert(workspaceId: workspaceId, cursor: cursor),
      );

  // ----------------------------------------------------------------- outbox

  OutboxEntry _entry(OutboxRow r) => OutboxEntry(
    id: r.id,
    workspaceId: r.workspaceId,
    projectId: r.projectId,
    entity: OutboxEntity.values.byName(r.entity),
    entityId: r.entityId,
    op: OutboxOp.values.byName(r.op),
    payload: OutboxEntry.payloadOf(r.payload),
    expectedVersion: r.expectedVersion,
    mutationId: r.mutationId,
    state: OutboxState.values.byName(r.state),
    error: r.error,
    theirs: r.theirs,
    attempts: r.attempts,
    createdAt: r.createdAt,
  );

  /// Every entry of the workspace, in the order they were made.
  Future<List<OutboxEntry>> queue(String workspaceId) async {
    final rows =
        await (db.select(db.outboxRows)
              ..where((r) => r.workspaceId.equals(workspaceId))
              ..orderBy([(r) => OrderingTerm.asc(r.id)]))
            .get();
    return [for (final r in rows) _entry(r)];
  }

  /// Every entry of every workspace.
  Future<List<OutboxEntry>> everyEntry() async => [
    for (final r in await db.select(db.outboxRows).get()) _entry(r),
  ];

  /// The queue of the workspace, again each time it changes.
  Stream<List<OutboxEntry>> watchQueue(String workspaceId) {
    final query = db.select(db.outboxRows)
      ..where((r) => r.workspaceId.equals(workspaceId))
      ..orderBy([(r) => OrderingTerm.asc(r.id)]);
    return query.watch().map((rows) => [for (final r in rows) _entry(r)]);
  }

  /// Adds [entry] to the queue, folded into what waits there (see
  /// [foldIntoQueue]); returns what the queue looks like for it afterwards.
  Future<void> enqueue(OutboxEntry entry) => db.transaction(() async {
    if (sealed) return;
    final change = foldIntoQueue(await queue(entry.workspaceId), entry);
    for (final id in change.drop) {
      await (db.delete(db.outboxRows)..where((r) => r.id.equals(id))).go();
    }
    for (final e in change.replace.entries) {
      await (db.update(db.outboxRows)..where((r) => r.id.equals(e.key))).write(
        OutboxRowsCompanion(
          payload: Value(e.value.payloadJson),
          expectedVersion: Value(e.value.expectedVersion),
        ),
      );
    }
    final add = change.add;
    if (add != null) {
      await db
          .into(db.outboxRows)
          .insert(
            OutboxRowsCompanion.insert(
              workspaceId: add.workspaceId,
              projectId: Value(add.projectId),
              entity: add.entity.name,
              entityId: add.entityId,
              op: add.op.name,
              payload: add.payloadJson,
              expectedVersion: Value(add.expectedVersion),
              attempts: Value(add.attempts),
              mutationId: add.mutationId,
              createdAt: add.createdAt,
            ),
          );
    }
  });

  Future<void> setState(
    int id,
    OutboxState state, {
    String error = '',
    String theirs = '',
    bool countAttempt = false,
  }) async {
    final row = await (db.select(
      db.outboxRows,
    )..where((r) => r.id.equals(id))).getSingleOrNull();
    if (row == null) return;
    await (db.update(db.outboxRows)..where((r) => r.id.equals(id))).write(
      OutboxRowsCompanion(
        state: Value(state.name),
        error: Value(error),
        theirs: Value(theirs),
        attempts: Value(row.attempts + (countAttempt ? 1 : 0)),
      ),
    );
  }

  Future<void> rewrite(
    int id, {
    Map<String, dynamic>? payload,
    int? expectedVersion,
  }) => (db.update(db.outboxRows)..where((r) => r.id.equals(id))).write(
    OutboxRowsCompanion(
      payload: payload == null
          ? const Value.absent()
          : Value(jsonEncode(payload)),
      expectedVersion: expectedVersion == null
          ? const Value.absent()
          : Value(expectedVersion),
    ),
  );

  /// A task's edits made after entry [afterId] were made on top of it: once
  /// it was saved (the task is at [version] now) they expect that version.
  Future<void> rebaseAfter(int afterId, String taskId, int version) =>
      (db.update(db.outboxRows)..where(
            (r) =>
                r.entity.equals('task') &
                r.entityId.equals(taskId) &
                r.op.equals('update') &
                r.state.equals('pending') &
                r.id.isBiggerThanValue(afterId),
          ))
          .write(OutboxRowsCompanion(expectedVersion: Value(version)));

  Future<void> removeEntry(int id) =>
      (db.delete(db.outboxRows)..where((r) => r.id.equals(id))).go();

  /// Puts every entry that was being sent when the app stopped back in line.
  Future<void> requeueSending() =>
      (db.update(db.outboxRows)..where((r) => r.state.equals('sending'))).write(
        const OutboxRowsCompanion(state: Value('pending')),
      );

  /// How many entries wait, and how many need a decision.
  Stream<({int waiting, int attention})> watchCounts(String workspaceId) {
    final query = db.select(db.outboxRows)
      ..where((r) => r.workspaceId.equals(workspaceId));
    return query.watch().map((rows) {
      var attention = 0;
      for (final r in rows) {
        if (r.state == 'conflict' || r.state == 'rejected') attention++;
      }
      return (waiting: rows.length - attention, attention: attention);
    });
  }

  /// The entities with an entry in the queue (to show the "pending" mark).
  Stream<Set<String>> watchPendingIds(String workspaceId) {
    final query = db.select(db.outboxRows)
      ..where((r) => r.workspaceId.equals(workspaceId));
    return query.watch().map((rows) => {for (final r in rows) r.entityId});
  }

  // ------------------------------------------------------------------ wipe

  /// Clears the cached copy (not the outbox: unsent changes are the person's
  /// work). [workspaceId] limits it to one workspace.
  Future<void> clearCache({String? workspaceId}) async {
    await (db.delete(db.cachedRows)..where(
          (r) => workspaceId == null
              ? const Constant(true)
              : r.workspaceId.equals(workspaceId),
        ))
        .go();
    // What was read is gone with it.
    await (db.delete(db.offlineMeta)..where(
          (m) => m.key.like(
            workspaceId == null ? 'read:%' : 'read:$workspaceId:%',
          ),
        ))
        .go();
  }

  /// Everything, outbox and cursors included: for sign-out.
  Future<void> wipe() => db.transaction(() async {
    await db.delete(db.cachedRows).go();
    await db.delete(db.outboxRows).go();
    await db.delete(db.syncCursors).go();
    await db.delete(db.offlineMeta).go();
  });
}
