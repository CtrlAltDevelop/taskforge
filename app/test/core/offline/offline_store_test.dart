import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskforge/core/offline/local_db.dart';
import 'package:taskforge/core/offline/offline_store.dart';
import 'package:taskforge/core/offline/outbox.dart';

var _clock = DateTime.utc(2026, 11, 12);

DateTime _tick() => _clock = _clock.add(const Duration(seconds: 1));

OutboxEntry _entry(
  OutboxOp op, {
  String id = 't1',
  OutboxEntity entity = OutboxEntity.task,
  Map<String, dynamic> payload = const {},
  String ws = 'w1',
}) => OutboxEntry(
  workspaceId: ws,
  projectId: 'p1',
  entity: entity,
  entityId: id,
  op: op,
  payload: payload,
  mutationId: 'm-$id-${op.name}',
  createdAt: _tick(),
);

void main() {
  late LocalDb db;
  late OfflineStore store;

  setUp(() {
    db = LocalDb(NativeDatabase.memory());
    store = OfflineStore(db, now: _tick);
  });

  tearDown(() => db.close());

  group('cache', () {
    test(
      'keeps rows by kind and project, newest write replacing the old',
      () async {
        await store.put(
          'w1',
          Kinds.task,
          'a',
          '{"n":1}',
          scope: 'p1',
          version: 1,
        );
        await store.put(
          'w1',
          Kinds.task,
          'a',
          '{"n":2}',
          scope: 'p1',
          version: 2,
        );
        await store.put('w1', Kinds.task, 'b', '{"n":3}', scope: 'p2');
        expect(await store.get('w1', Kinds.task, 'a'), '{"n":2}');
        expect(await store.list('w1', Kinds.task, scope: 'p1'), ['{"n":2}']);
        expect((await store.list('w1', Kinds.task)).length, 2);
        expect(await store.get('w2', Kinds.task, 'a'), isNull); // per workspace
      },
    );

    test('putAll writes a batch in one go', () async {
      await store.putAll('w1', Kinds.task, [
        (id: 'a', json: '1', version: 1),
        (id: 'b', json: '2', version: 1),
      ], scope: 'p1');
      expect((await store.list('w1', Kinds.task, scope: 'p1')).length, 2);
    });

    test(
      'sweep forgets what the server dropped but keeps what was made here',
      () async {
        await store.putAll('w1', Kinds.task, [
          (id: 'a', json: '1', version: 1),
          (id: 'gone', json: '2', version: 1),
          (id: 'mine', json: '3', version: 0),
        ], scope: 'p1');
        await store.sweep('w1', Kinds.task, 'p1', {'a'}, protect: {'mine'});
        expect(await store.get('w1', Kinds.task, 'gone'), isNull);
        expect(await store.get('w1', Kinds.task, 'a'), '1');
        expect(await store.get('w1', Kinds.task, 'mine'), '3');
      },
    );

    test('remove deletes one row', () async {
      await store.put('w1', Kinds.comment, 'c', '1');
      await store.remove('w1', Kinds.comment, 'c');
      expect(await store.get('w1', Kinds.comment, 'c'), isNull);
    });

    test('size counts the JSON, and trimming drops the oldest first', () async {
      for (var i = 0; i < 5; i++) {
        await store.put('w1', Kinds.task, 't$i', 'x' * 100, scope: 'p1');
      }
      expect(await store.sizeBytes(), 500);
      expect(await store.sizeBytes(workspaceId: 'w2'), 0);
      await store.setCacheCap(250);
      expect(await store.cacheCap(), 250);
      expect(await store.trimToCap(), 3);
      expect(await store.get('w1', Kinds.task, 't0'), isNull); // oldest went
      expect(await store.get('w1', Kinds.task, 't4'), isNotNull);
      expect(await store.trimToCap(), 0);
    });

    test('trimming never drops what the outbox still needs', () async {
      await store.put('w1', Kinds.task, 'mine', 'x' * 100);
      await store.put('w1', Kinds.task, 'other', 'x' * 100);
      await store.enqueue(_entry(OutboxOp.update, id: 'mine'));
      await store.setCacheCap(50);
      await store.trimToCap();
      expect(await store.get('w1', Kinds.task, 'mine'), isNotNull);
      expect(await store.get('w1', Kinds.task, 'other'), isNull);
    });

    test('a later edit expects the version the earlier one saved', () async {
      await store.enqueue(_entry(OutboxOp.update, id: 'a'));
      final first = (await store.queue('w1')).single;
      await store.setState(first.id, OutboxState.sending);
      await store.enqueue(_entry(OutboxOp.update, id: 'a'));
      await store.enqueue(_entry(OutboxOp.update, id: 'b'));
      await store.rebaseAfter(first.id, 'a', 5);
      final queue = await store.queue('w1');
      expect(queue[0].expectedVersion, isNot(5)); // the one sent
      expect(queue[1].expectedVersion, 5);
      expect(queue[2].expectedVersion, isNot(5)); // another task
    });

    test('a sealed store takes no writes', () async {
      store.sealed = true;
      await store.put('w1', Kinds.task, 't', '{}');
      await store.putAll('w1', Kinds.task, [(id: 'u', json: '{}', version: 1)]);
      await store.enqueue(_entry(OutboxOp.update, id: 'a'));
      store.sealed = false;
      expect(await store.get('w1', Kinds.task, 't'), isNull);
      expect(await store.get('w1', Kinds.task, 'u'), isNull);
      expect(await store.queue('w1'), isEmpty);
    });

    test('trimming spares the projects kept offline', () async {
      await store.put('w1', Kinds.task, 'kept', 'x' * 100, scope: 'p1');
      await store.put('w1', Kinds.task, 'loose', 'x' * 100, scope: 'p2');
      await store.setKeptProjects('w1', {'p1'});
      await store.setCacheCap(50);
      await store.trimToCap();
      expect(await store.get('w1', Kinds.task, 'kept'), isNotNull);
      expect(await store.get('w1', Kinds.task, 'loose'), isNull);
    });

    test('the comments of a kept project are spared with its tasks', () async {
      await store.put('w1', Kinds.task, 'T', 'x' * 100, scope: 'p1');
      await store.put('w1', Kinds.comment, 'c', 'x' * 100, scope: 'T');
      await store.put('w1', Kinds.task, 'U', 'x' * 100, scope: 'p2');
      await store.put('w1', Kinds.comment, 'd', 'x' * 100, scope: 'U');
      await store.setKeptProjects('w1', {'p1'});
      await store.setCacheCap(150);
      await store.trimToCap();
      expect(await store.get('w1', Kinds.comment, 'c'), isNotNull);
      expect(await store.get('w1', Kinds.task, 'T'), isNotNull);
      expect(await store.get('w1', Kinds.comment, 'd'), isNull);
      expect(await store.get('w1', Kinds.task, 'U'), isNull);
    });

    test('the projects read last go last', () async {
      var clock = DateTime.utc(2026, 11, 12);
      final timed = OfflineStore(
        store.db,
        now: () => clock = clock.add(const Duration(minutes: 1)),
      );
      for (final p in ['old', 'a', 'b', 'c']) {
        await timed.put('w1', Kinds.task, 't-$p', 'x' * 100, scope: p);
        await timed.markProjectRead('w1', p); // oldest read first
      }
      expect(await timed.recentProjects(3), {'a', 'b', 'c'});
      await timed.setCacheCap(300);
      await timed.trimToCap();
      expect(await timed.get('w1', Kinds.task, 't-old'), isNull); // went first
      expect(await timed.get('w1', Kinds.task, 't-c'), isNotNull);
      // Still over its cap: the recent ones go too, oldest first, never kept.
      await timed.setKeptProjects('w1', {'c'});
      await timed.setCacheCap(150);
      await timed.trimToCap();
      expect(await timed.get('w1', Kinds.task, 't-a'), isNull);
      expect(await timed.get('w1', Kinds.task, 't-c'), isNotNull);
    });

    test('a comment waiting on a task protects that task too', () async {
      await store.put('w1', Kinds.task, 'T', 'x' * 100);
      await store.enqueue(
        _entry(
          OutboxOp.create,
          id: 'c1',
          entity: OutboxEntity.comment,
          payload: {'taskId': 'T'},
        ),
      );
      await store.setCacheCap(10);
      await store.trimToCap();
      expect(await store.get('w1', Kinds.task, 'T'), isNotNull);
    });

    test('the default cap applies until one is chosen', () async {
      expect(await store.cacheCap(), defaultCacheBytes);
    });

    test('clearing the cache keeps the outbox', () async {
      await store.put('w1', Kinds.task, 'a', '1');
      await store.enqueue(_entry(OutboxOp.create));
      await store.clearCache();
      expect(await store.list('w1', Kinds.task), isEmpty);
      expect((await store.queue('w1')).length, 1);
    });

    test('clearing one workspace leaves the others', () async {
      await store.put('w1', Kinds.task, 'a', '1');
      await store.put('w2', Kinds.task, 'b', '1');
      await store.clearCache(workspaceId: 'w1');
      expect(await store.get('w2', Kinds.task, 'b'), '1');
      expect(await store.get('w1', Kinds.task, 'a'), isNull);
    });

    test('wipe removes everything, for sign-out', () async {
      await store.put('w1', Kinds.task, 'a', '1');
      await store.enqueue(_entry(OutboxOp.create));
      await store.setKeptProjects('w1', {'p1'});
      await store.wipe();
      expect(await store.list('w1', Kinds.task), isEmpty);
      expect(await store.queue('w1'), isEmpty);
      expect(await store.keptProjects('w1'), isEmpty);
    });
  });

  group('outbox', () {
    test('keeps the order changes were made in', () async {
      await store.enqueue(_entry(OutboxOp.create, id: 'a'));
      await store.enqueue(_entry(OutboxOp.create, id: 'b'));
      await store.enqueue(_entry(OutboxOp.update, id: 'c'));
      expect(
        [for (final e in await store.queue('w1')) e.entityId],
        ['a', 'b', 'c'],
      );
    });

    test('folds a later change into an earlier one', () async {
      await store.enqueue(_entry(OutboxOp.create, payload: {'title': 'A'}));
      await store.enqueue(_entry(OutboxOp.update, payload: {'title': 'B'}));
      final queue = await store.queue('w1');
      expect(queue.length, 1);
      expect(queue.single.op, OutboxOp.create);
      expect(queue.single.payload['title'], 'B');
    });

    test('a create then delete leaves nothing queued', () async {
      await store.enqueue(_entry(OutboxOp.create));
      await store.enqueue(_entry(OutboxOp.delete));
      expect(await store.queue('w1'), isEmpty);
    });

    test(
      'states and attempts are kept, and a conflict keeps their version',
      () async {
        await store.enqueue(_entry(OutboxOp.update));
        final id = (await store.queue('w1')).single.id;
        await store.setState(id, OutboxState.sending, countAttempt: true);
        await store.setState(
          id,
          OutboxState.conflict,
          theirs: '{"v":9}',
          error: 'x',
        );
        final e = (await store.queue('w1')).single;
        expect(
          (e.state, e.attempts, e.theirs, e.error),
          (OutboxState.conflict, 1, '{"v":9}', 'x'),
        );
        await store.setState(999, OutboxState.pending); // an entry that is gone
      },
    );

    test(
      'an entry that was being sent when the app stopped is queued again',
      () async {
        await store.enqueue(_entry(OutboxOp.update));
        final id = (await store.queue('w1')).single.id;
        await store.setState(id, OutboxState.sending);
        await store.requeueSending();
        expect((await store.queue('w1')).single.state, OutboxState.pending);
      },
    );

    test(
      'an entry can be rewritten (keep mine) or removed (take theirs)',
      () async {
        await store.enqueue(_entry(OutboxOp.update, payload: {'title': 'A'}));
        final id = (await store.queue('w1')).single.id;
        await store.rewrite(id, payload: {'title': 'C'}, expectedVersion: 7);
        var e = (await store.queue('w1')).single;
        expect((e.payload['title'], e.expectedVersion), ('C', 7));
        await store.rewrite(id);
        await store.removeEntry(id);
        expect(await store.queue('w1'), isEmpty);
      },
    );

    test('queues are per workspace', () async {
      await store.enqueue(_entry(OutboxOp.create, ws: 'w1'));
      await store.enqueue(_entry(OutboxOp.create, ws: 'w2', id: 'z'));
      expect((await store.queue('w2')).single.entityId, 'z');
    });

    test('counts and pending ids are watched', () async {
      final counts = store.watchCounts('w1');
      final ids = store.watchPendingIds('w1');
      final seen = <({int waiting, int attention})>[];
      final sub = counts.listen(seen.add);
      await store.enqueue(_entry(OutboxOp.create, id: 'a'));
      await store.enqueue(_entry(OutboxOp.update, id: 'b'));
      final bId = (await store.queue('w1')).last.id;
      await store.setState(bId, OutboxState.rejected, error: 'no');
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(seen.last, (waiting: 1, attention: 1));
      expect(await ids.first, {'a', 'b'});
      await sub.cancel();
    });
  });

  group('offline projects', () {
    test('the projects kept offline are remembered', () async {
      expect(await store.keptProjects('w1'), isEmpty);
      await store.setKeptProjects('w1', {'p1', 'p2'});
      expect(await store.keptProjects('w1'), {'p1', 'p2'});
    });
  });
}
