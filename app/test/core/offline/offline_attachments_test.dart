import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskforge/core/auth/auth_api.dart';
import 'package:taskforge/core/auth/auth_providers.dart';
import 'package:taskforge/core/auth/auth_session.dart';
import 'package:taskforge/core/auth/token_store.dart';
import 'package:taskforge/core/offline/offline_providers.dart';
import 'package:taskforge/core/offline/offline_sync.dart';
import 'package:taskforge/core/offline/outbox.dart';
import 'package:taskforge/core/offline/outbox_files.dart';
import 'package:taskforge/core/sync/sync_providers.dart';
import 'package:taskforge/features/account/account_client.dart';
import 'package:taskforge/features/account/account_providers.dart';
import 'package:taskforge/features/attachments/application/attachments_providers.dart';
import 'package:taskforge/features/attachments/domain/attachments.dart';
import 'package:taskforge/features/comments/application/comments_providers.dart';
import 'package:taskforge/features/tasks/application/tasks_providers.dart';
import 'package:taskforge/features/workspaces/application/workspace_providers.dart';

import '../../features/attachments/fakes.dart';
import 'fakes.dart';

class _NoApi implements AuthApi {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _Session extends AuthSession {
  _Session() : super(api: _NoApi(), store: MemoryTokenStore());

  var _status = AuthStatus.signedIn;

  @override
  AuthStatus get status => _status;

  void end() {
    _status = AuthStatus.signedOut;
    notifyListeners();
  }
}

BytesSource _file(String name, int length) =>
    BytesSource(name, Uint8List.fromList(List.generate(length, (i) => i)));

const _task = (project: 'p1', task: 'a');

void main() {
  late Harness h;
  late Directory dir;
  late FakeAttachments server;
  late ProviderContainer container;
  late _Session session;

  setUp(() {
    h = Harness.create();
    dir = Directory.systemTemp.createTempSync('outbox_files_test');
    server = FakeAttachments();
    session = _Session();
    container = ProviderContainer(
      overrides: [
        authSessionProvider.overrideWithValue(session),
        offlineStoreFutureProvider.overrideWithValue(Future.value(h.store)),
        outboxFilesProvider.overrideWithValue(OutboxFiles(() async => dir)),
        rawTasksClientProvider.overrideWithValue(h.server.t),
        rawCommentsClientProvider.overrideWithValue(h.server.c),
        workspaceScopeProvider.overrideWithValue('w1'),
        syncClientProvider.overrideWithValue(null),
        reachabilityProbeProvider.overrideWithValue(() async {}),
        attachmentsClientProvider.overrideWithValue(server),
        uploadsClientProvider.overrideWithValue(server),
        currentUserIdProvider.overrideWithValue('u1'),
        accountProvider.overrideWith(
          (ref) async => const Account(email: 'e', displayName: 'n', id: 'u1'),
        ),
      ],
    );
    container.listen(attachmentsProvider(_task), (_, _) {});
  });

  tearDown(() async {
    container.dispose();
    await h.close();
    dir.deleteSync(recursive: true);
  });

  Future<void> settle() async {
    for (var i = 0; i < 30; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 2));
    }
  }

  group('kept files', () {
    test('are copied, reopened as an upload, and removed', () async {
      final files = OutboxFiles(() async => dir);
      final path = await files.keep(_file('a.txt', 6), 'id1');
      final source = files.open(path, 'a.txt');
      expect(await source.length(), 6);
      expect(
        [for (final c in await source.read(0, 6).toList()) ...c],
        [0, 1, 2, 3, 4, 5],
      );
      await files.remove(path);
      expect(File(path).existsSync(), isFalse);
    });

    test('a sweep drops the files nothing asks for', () async {
      final files = OutboxFiles(() async => dir);
      final keep = await files.keep(_file('a', 2), 'keep');
      final drop = await files.keep(_file('b', 2), 'drop');
      await files.sweep({keep});
      expect(File(keep).existsSync(), isTrue);
      expect(File(drop).existsSync(), isFalse);
    });
  });

  group('attachments offline', () {
    test('a file added offline is kept and queued, not uploaded', () async {
      container.read(networkProvider.notifier).failed();
      final notifier = container.read(attachmentsProvider(_task).notifier);
      await notifier.add([_file('notes.txt', 10)]);
      await settle();

      final queue = await h.store.queue('w1');
      expect(queue.single.entity, OutboxEntity.attachment);
      expect(queue.single.payload['taskId'], 'a');
      expect(File('${queue.single.payload['path']}').existsSync(), isTrue);
      expect(server.created, isEmpty);
      final item = container.read(attachmentsProvider(_task)).uploads.single;
      expect(item.state, UploadState.queued);
      expect(item.kept, isTrue); // shown with a clock, not a progress bar
    });

    test(
      'it goes up when the connection is back, and the file is let go',
      () async {
        container.read(networkProvider.notifier).failed();
        await container.read(attachmentsProvider(_task).notifier).add([
          _file('notes.txt', 10),
        ]);
        await settle();
        final path = '${(await h.store.queue('w1')).single.payload['path']}';

        final result = await container
            .read(offlineSyncProvider.notifier)
            .syncNow();
        await settle();

        expect(result.sent, 1);
        expect(server.created.single.filename, 'notes.txt');
        expect(await h.store.queue('w1'), isEmpty);
        expect(File(path).existsSync(), isFalse);
        final state = container.read(attachmentsProvider(_task));
        expect(state.uploads, isEmpty); // no longer waiting
        expect(state.attachments.map((a) => a.filename), ['notes.txt']);
      },
    );

    test('a refused upload waits for a decision with its reason', () async {
      container.read(networkProvider.notifier).failed();
      await container.read(attachmentsProvider(_task).notifier).add([
        _file('prog.exe', 10),
      ]);
      await settle();
      server.failCreate = const AttachmentException(AttachmentFailure.refused);

      final result = await container
          .read(offlineSyncProvider.notifier)
          .syncNow();

      expect(result.rejected, 1);
      final entry = (await h.store.queue('w1')).single;
      expect(entry.state, OutboxState.rejected);
      expect(entry.error, isNotEmpty);
      // Letting it go removes the kept file too.
      final path = '${entry.payload['path']}';
      await container.read(outboxWorkerProvider).discard(entry);
      expect(File(path).existsSync(), isFalse);
    });

    test('signing out removes the kept files with the rest', () async {
      container.read(networkProvider.notifier).failed();
      container.read(offlineSyncProvider);
      await container.read(attachmentsProvider(_task).notifier).add([
        _file('notes.txt', 10),
      ]);
      await settle();
      final path = '${(await h.store.queue('w1')).single.payload['path']}';
      expect(File(path).existsSync(), isTrue);
      session.end();
      await settle();
      expect(File(path).existsSync(), isFalse);
      expect(await h.store.queue('w1'), isEmpty);
    });

    test('deleting the task before it was sent drops its files', () async {
      container.read(networkProvider.notifier).failed();
      await container.read(attachmentsProvider(_task).notifier).add([
        _file('notes.txt', 10),
      ]);
      await settle();
      final made = (await h.store.queue('w1')).single;
      expect(made.entity, OutboxEntity.attachment);
      await h.store.enqueue(
        OutboxEntry(
          workspaceId: 'w1',
          projectId: 'p1',
          entity: OutboxEntity.task,
          entityId: 'a',
          op: OutboxOp.create,
          payload: const {'title': 'x'},
          mutationId: 'm',
          createdAt: DateTime.utc(2026),
        ),
      );
      await h.store.enqueue(
        OutboxEntry(
          workspaceId: 'w1',
          projectId: 'p1',
          entity: OutboxEntity.task,
          entityId: 'a',
          op: OutboxOp.delete,
          payload: const {},
          mutationId: 'm2',
          createdAt: DateTime.utc(2026, 1, 2),
        ),
      );
      expect(await h.store.queue('w1'), isEmpty);
    });
  });
}
