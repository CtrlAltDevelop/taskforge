import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskforge/core/offline/local_db.dart';

void main() {
  test('a new database has every table and the two indexes', () async {
    final db = LocalDb(NativeDatabase.memory());
    final tables = await db
        .customSelect("SELECT name FROM sqlite_master WHERE type = 'table'")
        .get();
    final names = {for (final t in tables) t.read<String>('name')};
    expect(
      names,
      containsAll([
        'cached_rows',
        'outbox_rows',
        'sync_cursors',
        'offline_meta',
      ]),
    );
    final indexes = await db
        .customSelect("SELECT name FROM sqlite_master WHERE type = 'index'")
        .get();
    expect({
      for (final i in indexes) i.read<String>('name'),
    }, containsAll(['cached_scope_idx', 'outbox_ws_idx']));
    expect(
      await db
          .customSelect('PRAGMA user_version')
          .getSingle()
          .then((r) => r.read<int>('user_version')),
      localSchemaVersion,
    );
    await db.close();
  });

  test('every version has a migration step that exists', () {
    // Version 1 is creation; each later version must register its step.
    for (var v = 2; v <= localSchemaVersion; v++) {
      expect(localMigrations.containsKey(v), isTrue, reason: 'version $v');
    }
  });

  test('a database from an older version is upgraded step by step and keeps its rows', () async {
    // The database as version 1 left it (only the cache table), opened by a
    // build whose schema is version 2.
    final raw = NativeDatabase.memory(
      setup: (d) {
        d.execute(
          'CREATE TABLE cached_rows (workspace_id TEXT NOT NULL, kind TEXT NOT NULL, id TEXT NOT NULL, scope TEXT NOT NULL DEFAULT \'\', version INTEGER NOT NULL DEFAULT 0, json TEXT NOT NULL, saved_at INTEGER NOT NULL, PRIMARY KEY (workspace_id, kind, id))',
        );
        d.execute(
          "INSERT INTO cached_rows VALUES ('w','task','a','p',1,'{}',1)",
        );
        d.execute('PRAGMA user_version = 1');
      },
    );
    final steps = <int>[];
    localMigrations[2] = (m, db) async {
      steps.add(2);
      await m.createTable(db.outboxRows);
      await m.createTable(db.syncCursors);
      await m.createTable(db.offlineMeta);
    };
    addTearDown(() => localMigrations.remove(2));
    final db = _NextVersion(raw);
    final rows = await db.select(db.cachedRows).get();
    expect(rows.single.id, 'a'); // nothing was lost
    expect(steps, [2]);
    await db.select(db.outboxRows).get(); // the new tables are there
    await db.close();
  });

  test('a version with no step is refused rather than guessed', () async {
    final raw = NativeDatabase.memory(
      setup: (d) {
        d.execute('CREATE TABLE x (a INTEGER)');
        d.execute('PRAGMA user_version = 1');
      },
    );
    final db = _NextVersion(raw);
    await expectLater(
      db.customSelect('SELECT 1').get(),
      throwsA(isA<StateError>()),
    );
  });
}

/// The next build's database: one version ahead of this one.
class _NextVersion extends LocalDb {
  _NextVersion(super.e);

  @override
  int get schemaVersion => localSchemaVersion + 1;
}
