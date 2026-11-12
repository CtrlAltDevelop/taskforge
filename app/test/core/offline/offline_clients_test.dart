import 'package:flutter_test/flutter_test.dart';
import 'package:taskforge/features/views/domain/list_layout.dart';
import 'package:taskforge/core/offline/codecs.dart';
import 'package:taskforge/core/offline/offline_store.dart';
import 'package:taskforge/core/offline/outbox.dart';
import 'package:taskforge/core/offline/outbox_worker.dart';
import 'package:taskforge/features/comments/data/offline_comments_client.dart';
import 'package:taskforge/features/comments/domain/comments.dart';
import 'package:taskforge/features/tasks/data/offline_tasks_client.dart';
import 'package:taskforge/features/tasks/domain/tasks.dart';

import 'fakes.dart';

void main() {
  late Harness h;
  late OfflineTasksClient tasks;
  late OfflineCommentsClient comments;
  late OutboxWorker worker;

  setUp(() {
    h = Harness.create();
    tasks = OfflineTasksClient(h.server.t, h.env);
    comments = OfflineCommentsClient(h.server.c, h.env);
    worker = OutboxWorker(
      store: () async => h.store,
      tasks: h.server.t,
      comments: h.server.c,
      workspace: () => 'w1',
      worked: () => h.online = true,
      failed: () => h.online = false,
    );
  });

  tearDown(() => h.close());

  Future<List<Task>> listed() => tasks.list('w1', 'p1').toList();

  /// Reads the project once while the server is up, then loses the connection.
  Future<void> browseThenGoOffline() async {
    await listed();
    h.server.reachable = false;
    h.online = false;
  }

  group('reading', () {
    test(
      'what was read is answered from the copy when the server is gone',
      () async {
        h.server.tasks
          ..['a'] = serverTask('a', 'Alpha')
          ..['b'] = serverTask('b', 'Bravo', position: 'bbbbbb');
        expect((await listed()).length, 2);
        h.server.reachable = false;
        h.online = false;
        expect([for (final t in await listed()) t.title], ['Alpha', 'Bravo']);
        expect((await tasks.get('w1', 'p1', 'a')).title, 'Alpha');
      },
    );

    test(
      'a task the server dropped leaves the copy at the next read',
      () async {
        h.server.tasks
          ..['a'] = serverTask('a', 'Alpha')
          ..['b'] = serverTask('b', 'Bravo');
        await listed();
        h.server.tasks.remove('b');
        await listed();
        h.server.reachable = false;
        h.online = false;
        expect([for (final t in await listed()) t.id], ['a']);
      },
    );

    test('subtasks come back under their parent, in tree order', () async {
      h.server.tasks
        ..['a'] = serverTask('a', 'A', position: 'aaaaaa')
        ..['b'] = serverTask('b', 'B', position: 'bbbbbb')
        ..['a1'] = serverTask('a1', 'A1', parent: 'a', depth: 1);
      await listed();
      h.server.reachable = false;
      h.online = false;
      expect([for (final t in await listed()) t.id], ['a', 'a1', 'b']);
    });

    test('an unread project has nothing to show offline', () async {
      h.online = false;
      await expectLater(
        listed(),
        throwsA(
          isA<TaskException>().having(
            (e) => e.failure,
            'failure',
            TaskFailure.network,
          ),
        ),
      );
    });

    test('a project kept offline shows as empty rather than failing', () async {
      await h.store.setKeptProjects('w1', {'p1'});
      h.online = false;
      expect(await listed(), isEmpty);
    });

    test(
      'losing the connection while reading falls back to the copy',
      () async {
        h.server.tasks['a'] = serverTask('a', 'Alpha');
        await listed();
        h.server.reachable = false; // the app does not know yet
        expect([for (final t in await listed()) t.title], ['Alpha']);
        expect(h.online, isFalse); // and now it does
      },
    );

    test(
      'a filtered list is not copied (it would stand for the whole project)',
      () async {
        h.server.tasks['a'] = serverTask('a', 'Alpha');
        await tasks.list('w1', 'p1', query: const _Filtered()).toList();
        expect(await h.store.list('w1', Kinds.task), isEmpty);
      },
    );

    test('a task read on its own is copied too', () async {
      h.server.tasks['a'] = serverTask('a', 'Alpha');
      await tasks.get('w1', 'p1', 'a');
      h.server.reachable = false;
      h.online = false;
      expect((await tasks.get('w1', 'p1', 'a')).title, 'Alpha');
      await expectLater(
        tasks.get('w1', 'p1', 'zzz'),
        throwsA(isA<TaskException>()),
      );
    });

    test('calls that need the server say so while offline', () async {
      h.online = false;
      expect(() => tasks.searchTasks('w1', 'x'), throwsA(isA<TaskException>()));
      expect(() => tasks.listLinks('w1', 't'), throwsA(isA<TaskException>()));
      expect(() => tasks.listTrash('w1', 'p1'), throwsA(isA<TaskException>()));
    });
  });

  group('working offline', () {
    test(
      'a task made offline shows at once, pending, and is sent once',
      () async {
        await browseThenGoOffline();
        final made = await tasks.create('w1', 'p1', title: 'Offline task');
        expect(made.displayId, pendingDisplayId);
        expect(made.version, 0);
        expect((await listed()).map((t) => t.title), ['Offline task']);
        expect((await h.store.queue('w1')).single.op, OutboxOp.create);

        h.server.reachable = true;
        final result = await worker.drain();
        expect(result.sent, 1);
        expect(
          h.server.tasks[made.id]?.title,
          'Offline task',
        ); // the id it chose
        expect(await h.store.queue('w1'), isEmpty);
        final cached = taskFromJson(
          (await h.store.get('w1', Kinds.task, made.id))!,
        );
        expect(cached.displayId, 'WEB-1'); // numbered by the server now
      },
    );

    test('an answer that was lost does not make the task twice', () async {
      await browseThenGoOffline();
      final made = await tasks.create('w1', 'p1', title: 'Once');
      h.server.reachable = true;
      h.server.dropNextAnswer = true;
      final first = await worker.drain();
      expect(first.stoppedOffline, isTrue); // sent, but the answer never came
      expect(h.server.tasks.length, 1);
      expect((await h.store.queue('w1')).single.state, OutboxState.pending);
      final second = await worker.drain();
      expect(second.sent, 1);
      expect(h.server.tasks.length, 1);
      expect(h.server.tasks.containsKey(made.id), isTrue);
    });

    test(
      'an edit made after a lost answer is not folded into the resend',
      () async {
        await browseThenGoOffline();
        final made = await tasks.create('w1', 'p1', title: 'Once');
        h.server.reachable = true;
        h.server.dropNextAnswer = true;
        await worker.drain(); // applied, answer lost: the create may be there
        await tasks.update('w1', made, const TaskPatch(title: 'Renamed'));
        expect(await h.store.queue('w1'), hasLength(2)); // not merged into it
        final r = await worker.drain();
        expect(r.sent, 2);
        expect(h.server.tasks[made.id]!.title, 'Renamed');
      },
    );

    test('a call cut off on its way is not folded into either', () async {
      h.server.tasks['a'] = serverTask('a', 'Alpha');
      await listed();
      final base = await tasks.get('w1', 'p1', 'a');
      h.server.reachable = false; // goes down between the check and the call
      await tasks.update('w1', base, const TaskPatch(title: 'One'));
      final first = (await h.store.queue('w1')).single;
      expect(first.attempts, 1); // it was tried
      await tasks.update('w1', base, const TaskPatch(dueDate: '2026-12-01'));
      expect(await h.store.queue('w1'), hasLength(2));
    });

    test(
      'edits of one task are folded and the server sees one update',
      () async {
        h.server.tasks['a'] = serverTask('a', 'Alpha');
        await listed();
        h.server.reachable = false;
        h.online = false;
        final base = await tasks.get('w1', 'p1', 'a');
        await tasks.update('w1', base, const TaskPatch(title: 'One'));
        await tasks.update(
          'w1',
          base,
          const TaskPatch(title: 'Two', dueDate: '2026-12-01'),
        );
        expect((await h.store.queue('w1')).length, 1);
        expect((await tasks.get('w1', 'p1', 'a')).title, 'Two');

        h.server.reachable = true;
        await worker.drain();
        expect(h.server.sent, ['update a v1']);
        expect(h.server.tasks['a']!.title, 'Two');
        expect(h.server.tasks['a']!.dueDate, '2026-12-01');
      },
    );

    test('a task made and deleted offline never reaches the server', () async {
      await browseThenGoOffline();
      final made = await tasks.create('w1', 'p1', title: 'Gone soon');
      final comment = await comments.create('w1', 'p1', made.id, 'hello');
      expect(comment.sendState, SendState.sending);
      await tasks.delete('w1', 'p1', made.id);
      expect(await h.store.queue('w1'), isEmpty);
      h.server.reachable = true;
      await worker.drain();
      expect(h.server.sent, isEmpty);
    });

    test(
      'a task the server has, deleted offline, is deleted when back',
      () async {
        h.server.tasks['a'] = serverTask('a', 'Alpha');
        await listed();
        h.server.reachable = false;
        h.online = false;
        final gone = await tasks.delete('w1', 'p1', 'a');
        expect(gone.deletedAt, isNotEmpty);
        expect(await listed(), isEmpty);
        h.server.reachable = true;
        await worker.drain();
        expect(h.server.tasks, isEmpty);
      },
    );

    test(
      'an edit of a task that is itself still queued joins its create',
      () async {
        await browseThenGoOffline();
        final made = await tasks.create('w1', 'p1', title: 'Draft');
        h.online = true; // the app thinks it is back, the server is not
        final edited = await tasks.update(
          'w1',
          made,
          const TaskPatch(title: 'Final'),
        );
        expect(edited.title, 'Final');
        final queue = await h.store.queue('w1');
        expect(queue.length, 1);
        expect(queue.single.payload['title'], 'Final');
        h.server.reachable = true;
        await worker.drain();
        expect(h.server.tasks[made.id]!.title, 'Final');
      },
    );

    test(
      'a subtask made under a task made offline follows its parent',
      () async {
        await browseThenGoOffline();
        final parent = await tasks.create('w1', 'p1', title: 'Parent');
        final child = await tasks.create(
          'w1',
          'p1',
          title: 'Child',
          parentId: parent.id,
        );
        expect(child.depth, 1);
        final order = [for (final t in await listed()) t.title];
        expect(order, ['Parent', 'Child']);
        h.server.reachable = true;
        await worker.drain();
        expect(h.server.tasks[child.id]!.parentId, parent.id);
        expect(h.server.sent, ['create ${parent.id}', 'create ${child.id}']);
      },
    );

    test(
      'a comment written offline shows as sending, then is sent once',
      () async {
        h.server.tasks['a'] = serverTask('a', 'Alpha');
        await listed();
        h.server.reachable = false;
        h.online = false;
        final mine = await comments.create('w1', 'p1', 'a', 'see you later');
        expect(mine.isLocal, isTrue);
        expect(mine.authorId, 'u1');
        final page = await comments.list('w1', 'p1', 'a');
        expect(page.comments.single.sendState, SendState.sending);
        h.server.reachable = true;
        await worker.drain();
        await worker.drain();
        expect(h.server.comments.length, 1);
        final back = await comments.list('w1', 'p1', 'a');
        expect(back.comments.single.sendState, SendState.sent);
      },
    );

    test('comments that were read are available offline', () async {
      h.server.tasks['a'] = serverTask('a', 'Alpha');
      h.server.comments['c1'] = Comment(
        id: 'c1',
        taskId: 'a',
        authorId: 'u2',
        createdAt: DateTime.utc(2026, 11, 1),
        body: 'first',
      );
      await comments.list('w1', 'p1', 'a');
      h.server.reachable = false;
      h.online = false;
      expect(
        (await comments.list('w1', 'p1', 'a')).comments.single.body,
        'first',
      );
    });

    test('editing a comment needs the server', () async {
      h.online = false;
      expect(
        () => comments.edit(
          'w1',
          'p1',
          Comment(
            id: 'c',
            taskId: 'a',
            authorId: 'u1',
            createdAt: DateTime.utc(2026),
          ),
          'x',
        ),
        throwsA(isA<CommentException>()),
      );
    });

    test('the queue is sent in the order the changes were made, and stops when offline', () async {
      h.server.tasks
        ..['a'] = serverTask('a', 'Alpha')
        ..['b'] = serverTask('b', 'Bravo');
      await listed();
      h.server.reachable = false;
      h.online = false;
      final a = await tasks.get('w1', 'p1', 'a');
      final b = await tasks.get('w1', 'p1', 'b');
      await tasks.update('w1', a, const TaskPatch(title: 'A2'));
      await tasks.update('w1', b, const TaskPatch(title: 'B2'));
      h.server.reachable = true;
      // The line drops after the first one.
      h.server.dropNextAnswer = true;
      final first = await worker.drain();
      expect(first.stoppedOffline, isTrue);
      expect(h.server.sent, ['update a v1']);
      final rest = await worker.drain();
      expect(rest.sent, 2); // the repeat of the first, then the second
      expect(h.server.sent, ['update a v1', 'update b v1']);
      expect(h.server.tasks['a']!.version, 2); // applied once
    });
  });

  group('conflicts', () {
    Future<OutboxEntry> conflicted() async {
      h.server.tasks['a'] = serverTask('a', 'Alpha');
      await listed();
      h.server.reachable = false;
      h.online = false;
      final base = await tasks.get('w1', 'p1', 'a');
      await tasks.update(
        'w1',
        base,
        const TaskPatch(title: 'Mine', dueDate: '2026-12-01'),
      );
      // Meanwhile someone else renames it.
      h.server.tasks['a'] = serverTask('a', 'Theirs', version: 2);
      h.server.reachable = true;
      final r = await worker.drain();
      expect((r.conflicts, r.sent), (1, 0));
      return (await h.store.queue('w1')).single;
    }

    test('a clash becomes an item to decide, with their value', () async {
      final entry = await conflicted();
      expect(entry.state, OutboxState.conflict);
      final info = ConflictInfo.parse(entry.theirs);
      expect((info.field, info.current, info.version), ('title', 'Theirs', 2));
      expect(h.server.tasks['a']!.title, 'Theirs'); // nothing was overwritten
    });

    test('keep mine sends my change again on top of theirs', () async {
      final entry = await conflicted();
      await worker.keepMine(entry);
      final r = await worker.drain();
      expect(r.sent, 1);
      expect(h.server.tasks['a']!.title, 'Mine');
      expect(h.server.tasks['a']!.version, 3);
    });

    test('take theirs drops my change and reads theirs', () async {
      final entry = await conflicted();
      await worker.takeTheirs(entry);
      expect(await h.store.queue('w1'), isEmpty);
      expect((await tasks.get('w1', 'p1', 'a')).title, 'Theirs');
      expect(h.server.tasks['a']!.title, 'Theirs');
    });

    test('merge keeps only the fields chosen', () async {
      final entry = await conflicted();
      await worker.merge(entry, {'dueDate'}); // their title, my due date
      await worker.drain();
      expect(h.server.tasks['a']!.title, 'Theirs');
      expect(h.server.tasks['a']!.dueDate, '2026-12-01');
    });

    test('merge with nothing chosen is take theirs', () async {
      final entry = await conflicted();
      await worker.merge(entry, {});
      expect(await h.store.queue('w1'), isEmpty);
    });

    test('later edits of the task wait behind an undecided clash', () async {
      var entry = await conflicted();
      final base = await tasks.get('w1', 'p1', 'a');
      await tasks.update(
        'w1',
        base,
        const TaskPatch(priority: TaskPriority.high),
      );
      final queue = await h.store.queue('w1');
      expect(queue.length, 2); // not folded into the clash
      final r = await worker.drain();
      expect(r.sent, 0); // and not sent past it
      await worker.keepMine(entry);
      entry = (await h.store.queue('w1')).first;
      await worker.drain();
      expect((await h.store.queue('w1')), isEmpty);
    });

    test('other tasks go on while one waits for a decision', () async {
      await conflicted();
      h.server.tasks['b'] = serverTask('b', 'Bravo');
      await listed();
      h.server.reachable = false;
      h.online = false;
      final b = await tasks.get('w1', 'p1', 'b');
      await tasks.update('w1', b, const TaskPatch(title: 'B2'));
      h.server.reachable = true;
      final r = await worker.drain();
      expect(r.sent, 1);
      expect(h.server.tasks['b']!.title, 'B2');
    });
  });

  group('refusals', () {
    test('a refused change is shown with the reason, never dropped', () async {
      h.server.tasks['a'] = serverTask('a', 'Alpha');
      await listed();
      h.server.reachable = false;
      h.online = false;
      final base = await tasks.get('w1', 'p1', 'a');
      await tasks.update('w1', base, const TaskPatch(title: 'X'));
      h.server.reachable = true;
      h.server.refuse = const TaskException(TaskFailure.forbidden);
      final r = await worker.drain();
      expect(r.rejected, 1);
      final entry = (await h.store.queue('w1')).single;
      expect(entry.state, OutboxState.rejected);
      expect(entry.error, isNotEmpty);
      // Retrying after the reason is gone works.
      h.server.refuse = null;
      await worker.retry(entry);
      expect((await worker.drain()).sent, 1);
    });

    test('discarding a refused edit puts the server version back', () async {
      h.server.tasks['a'] = serverTask('a', 'Alpha');
      await listed();
      h.server.reachable = false;
      h.online = false;
      final base = await tasks.get('w1', 'p1', 'a');
      await tasks.update('w1', base, const TaskPatch(title: 'X'));
      h.server.reachable = true;
      h.server.refuse = const TaskException(TaskFailure.archived);
      await worker.drain();
      h.server.refuse = null;
      await worker.discard((await h.store.queue('w1')).single);
      expect(await h.store.queue('w1'), isEmpty);
      expect((await tasks.get('w1', 'p1', 'a')).title, 'Alpha');
    });

    test(
      'a refused create takes what depended on it down with it, visibly',
      () async {
        await browseThenGoOffline();
        final made = await tasks.create('w1', 'p1', title: 'Doomed');
        await comments.create('w1', 'p1', made.id, 'a note');
        h.server.reachable = true;
        h.server.refuse = const TaskException(TaskFailure.forbidden);
        final r = await worker.drain();
        expect(r.rejected, 2);
        final queue = await h.store.queue('w1');
        expect(queue.every((e) => e.state == OutboxState.rejected), isTrue);
        expect(
          queue.last.error,
          contains('depends on a change that was refused'),
        );
        // Letting the refused task go removes it from the copy.
        await worker.discard(queue.first);
        expect(await h.store.get('w1', Kinds.task, made.id), isNull);
      },
    );

    test('a refused comment is shown, the rest go on', () async {
      h.server.tasks['a'] = serverTask('a', 'Alpha');
      await listed();
      h.server.reachable = false;
      h.online = false;
      await comments.create('w1', 'p1', 'a', 'one');
      h.server.reachable = true;
      h.server.refuseComment = const CommentException(CommentFailure.forbidden);
      final r = await worker.drain();
      expect(r.rejected, 1);
      expect((await h.store.queue('w1')).single.state, OutboxState.rejected);
      expect(
        commentErrorText(const CommentException(CommentFailure.notFound)),
        isNotEmpty,
      );
    });

    test('a comment cut off by the network stays queued', () async {
      h.server.tasks['a'] = serverTask('a', 'Alpha');
      await listed();
      h.server.reachable = false;
      h.online = false;
      await comments.create('w1', 'p1', 'a', 'one');
      final r = await worker.drain();
      expect(r.stoppedOffline, isTrue);
      expect((await h.store.queue('w1')).single.state, OutboxState.pending);
    });
  });

  group('the worker', () {
    test(
      'does nothing without a workspace or a store, or when already running',
      () async {
        final lonely = OutboxWorker(
          store: () async => null,
          tasks: h.server.t,
          comments: h.server.c,
          workspace: () => null,
          worked: () {},
          failed: () {},
        );
        expect((await lonely.drain()).changedSomething, isFalse);
        expect(lonely.running, isFalse);
      },
    );

    test('an empty queue is a quiet pass', () async {
      final r = await worker.drain();
      expect(
        (r.sent, r.conflicts, r.rejected, r.stoppedOffline),
        (0, 0, 0, false),
      );
    });
  });
}

class _Filtered extends ListQuery {
  const _Filtered() : super(filterAst: '{"x":1}');
}
