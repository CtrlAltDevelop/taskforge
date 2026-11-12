import 'package:drift/drift.dart';

part 'local_db.g.dart';

/// The local copy of what the server holds, one row per entity: the entity as
/// JSON in the form its client reads it (`kind` says which), the project it
/// belongs to (`scope`, empty when none) and its server version.
class CachedRows extends Table {
  TextColumn get workspaceId => text()();
  TextColumn get kind => text()();
  TextColumn get id => text()();
  TextColumn get scope => text().withDefault(const Constant(''))();
  IntColumn get version => integer().withDefault(const Constant(0))();
  TextColumn get json => text()();
  DateTimeColumn get savedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {workspaceId, kind, id};

  @override
  List<Set<Column<Object>>> get uniqueKeys => const [];
}

/// Changes made here that the server has not seen: replayed in order when
/// online. `state` is `pending`, `sending`, `conflict` (the server changed the
/// same thing: `theirs` holds its version) or `rejected` (refused: `error`
/// says why).
class OutboxRows extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get workspaceId => text()();
  TextColumn get projectId => text().withDefault(const Constant(''))();
  TextColumn get entity => text()();
  TextColumn get entityId => text()();
  TextColumn get op => text()();
  TextColumn get payload => text()();
  IntColumn get expectedVersion => integer().withDefault(const Constant(0))();
  TextColumn get mutationId => text()();
  TextColumn get state => text().withDefault(const Constant('pending'))();
  TextColumn get error => text().withDefault(const Constant(''))();
  TextColumn get theirs => text().withDefault(const Constant(''))();
  IntColumn get attempts => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
}

/// Where each workspace's live feed was read up to (the `Sync.Since` cursor).
class SyncCursors extends Table {
  TextColumn get workspaceId => text()();
  TextColumn get cursor => text()();

  @override
  Set<Column<Object>> get primaryKey => {workspaceId};
}

/// Small settings of the cache itself (its size cap, the projects kept offline).
class OfflineMeta extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}

/// The version of the local schema. Raise it with every change of a table and
/// add the step to [localMigrations]; `local_db_test.dart` runs every step.
const localSchemaVersion = 1;

/// One step per version: what to do to a database of version `n - 1` to make
/// it version `n`. Version 1 is the creation itself.
final Map<int, Future<void> Function(Migrator m, LocalDb db)> localMigrations =
    {};

@DriftDatabase(tables: [CachedRows, OutboxRows, SyncCursors, OfflineMeta])
class LocalDb extends _$LocalDb {
  LocalDb(super.e);

  @override
  int get schemaVersion => localSchemaVersion;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await customStatement(
        'CREATE INDEX IF NOT EXISTS cached_scope_idx '
        'ON cached_rows (workspace_id, kind, scope)',
      );
      await customStatement(
        'CREATE INDEX IF NOT EXISTS outbox_ws_idx '
        'ON outbox_rows (workspace_id, state, id)',
      );
    },
    onUpgrade: (m, from, to) async {
      for (var v = from + 1; v <= to; v++) {
        final step = localMigrations[v];
        if (step == null) {
          throw StateError('No migration to local schema version $v.');
        }
        await step(m, this);
      }
    },
  );
}
