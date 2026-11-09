import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskforge/features/workflows/application/workflow_editor.dart';
import 'package:taskforge/features/workflows/application/workflows_providers.dart';
import 'package:taskforge/features/workflows/domain/workflow.dart';
import 'package:taskforge/features/workspaces/application/workspace_providers.dart';

import 'fakes.dart';

ProviderContainer _container(FakeWorkflowsClient server) {
  final container = ProviderContainer(
    overrides: [
      workflowsClientProvider.overrideWithValue(server),
      workspaceScopeProvider.overrideWithValue('w1'),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

Future<WorkflowEditorState> _loaded(ProviderContainer container) async {
  final sub = container.listen(workflowEditorProvider('p1'), (_, _) {});
  addTearDown(sub.close);
  while (container.read(workflowEditorProvider('p1')).loading) {
    await Future<void>.delayed(Duration.zero);
  }
  return container.read(workflowEditorProvider('p1'));
}

WorkflowEditor _editor(ProviderContainer c) =>
    c.read(workflowEditorProvider('p1').notifier);

WorkflowEditorState _state(ProviderContainer c) =>
    c.read(workflowEditorProvider('p1'));

void main() {
  test(
    'starts loading, then holds the saved workflow and a clean draft',
    () async {
      final container = _container(FakeWorkflowsClient());

      expect(_state(container).loading, isTrue);
      final state = await _loaded(container);

      expect(state.base!.statuses, hasLength(3));
      expect(state.draft!.statuses.map((s) => s.key), [
        'todo',
        'doing',
        'done',
      ]);
      expect(state.dirty, isFalse);
      expect(state.problems, isEmpty);
      expect(state.canSave, isFalse);
    },
  );

  test('a failed load is reported and can be retried', () async {
    final server = FakeWorkflowsClient()
      ..failNext = const WorkflowException(WorkflowFailure.network);
    final container = _container(server);

    final failed = await _loaded(container);
    expect(failed.loadError?.failure, WorkflowFailure.network);

    await _editor(container).load();
    expect(_state(container).draft, isNotNull);
    expect(_state(container).loadError, isNull);
  });

  test(
    'editing makes the draft dirty; breaking it blocks Save with the reason',
    () async {
      final container = _container(FakeWorkflowsClient());
      await _loaded(container);

      _editor(container).edit((d) => d.rename('doing', 'Doing'));
      expect(_state(container).dirty, isTrue);
      expect(_state(container).canSave, isTrue);

      _editor(container).edit((d) => d.rename('doing', ''));
      expect(_state(container).canSave, isFalse);
      expect(_state(container).problems.single.code, 'STATUS_NAME_INVALID');
    },
  );

  test('editing back to the saved values is not a change', () async {
    final container = _container(FakeWorkflowsClient());
    await _loaded(container);

    _editor(container).edit((d) => d.rename('doing', 'X'));
    _editor(container).edit((d) => d.rename('doing', 'In progress'));

    expect(_state(container).dirty, isFalse);
  });

  test('discard puts the draft back', () async {
    final container = _container(FakeWorkflowsClient());
    await _loaded(container);
    _editor(container).edit((d) => d.rename('doing', 'Changed'));

    _editor(container).discard();

    expect(_state(container).draft!.statuses[1].name, 'In progress');
    expect(_state(container).dirty, isFalse);
  });

  test('save sends the whole draft at the version it started from', () async {
    final server = FakeWorkflowsClient();
    final container = _container(server);
    await _loaded(container);
    final editor = _editor(container);
    editor.edit((d) => d.add(editor.newKey(), name: 'QA'));

    final saved = await editor.save();

    expect(saved, isTrue);
    expect(server.saved.single.statuses.map((s) => s.name), [
      'To do',
      'In progress',
      'Done',
      'QA',
    ]);
    expect(_state(container).base!.version, 2);
    expect(_state(container).draft!.statuses.last.key, 'new-0');
    expect(_state(container).dirty, isFalse);
  });

  test('save does nothing while the draft has problems', () async {
    final server = FakeWorkflowsClient();
    final container = _container(server);
    await _loaded(container);
    _editor(container).edit((d) => d.rename('doing', ''));

    expect(await _editor(container).save(), isFalse);
    expect(server.saved, isEmpty);
  });

  test(
    'a save the server rejects lists its problems and keeps the draft',
    () async {
      final server = FakeWorkflowsClient()
        ..rejectWith = const [
          WorkflowProblem('TRANSITION_ROLE_UNKNOWN', 'A role is gone.'),
        ];
      final container = _container(server);
      await _loaded(container);
      _editor(container).edit((d) => d.rename('doing', 'Doing'));

      final saved = await _editor(container).save();

      expect(saved, isFalse);
      final state = _state(container);
      expect(state.problems.map((p) => p.code), ['TRANSITION_ROLE_UNKNOWN']);
      expect(state.draft!.statuses[1].name, 'Doing');
      expect(state.saving, isFalse);
      expect(state.canSave, isFalse);
    },
  );

  test('another kind of failure is kept for the screen to show', () async {
    final server = FakeWorkflowsClient();
    final container = _container(server);
    await _loaded(container);
    _editor(container).edit((d) => d.rename('doing', 'Doing'));
    server.failNext = const WorkflowException(WorkflowFailure.forbidden);

    expect(await _editor(container).save(), isFalse);

    expect(_state(container).saveError?.failure, WorkflowFailure.forbidden);
    expect(_state(container).canSave, isTrue, reason: 'nothing was lost');
  });

  test('the server dry run adds problems only it can see', () async {
    final server = FakeWorkflowsClient()
      ..problems = const [WorkflowProblem('ROLE_GONE', 'A role is gone.')];
    final container = _container(server);
    await _loaded(container);

    _editor(container).edit((d) => d.rename('doing', 'Doing'));
    await Future<void>.delayed(Duration.zero);

    expect(_state(container).problems.map((p) => p.code), ['ROLE_GONE']);
    expect(server.validated, hasLength(1));
  });

  test(
    'the dry run is skipped while the draft is locally invalid or unchanged',
    () async {
      final server = FakeWorkflowsClient();
      final container = _container(server);
      await _loaded(container);

      _editor(container).edit((d) => d.rename('doing', ''));
      _editor(container).edit((d) => d.rename('doing', 'In progress'));
      await Future<void>.delayed(Duration.zero);

      expect(server.validated, isEmpty);
    },
  );

  test('a problem the app already found is not listed twice', () async {
    final server = FakeWorkflowsClient()
      ..problems = const [
        WorkflowProblem('NO_DONE_STATUS', 'There must be a "Done" status.'),
      ];
    final container = _container(server);
    await _loaded(container);

    _editor(container)
        .edit((d) => d.recategorize('done', StatusCategory.active));
    await Future<void>.delayed(Duration.zero);

    expect(
      _state(container).problems.where((p) => p.code == 'NO_DONE_STATUS'),
      hasLength(1),
    );
  });

  test('new keys never repeat', () async {
    final container = _container(FakeWorkflowsClient());
    await _loaded(container);

    final keys = {for (var i = 0; i < 5; i++) _editor(container).newKey()};

    expect(keys, hasLength(5));
  });

  test('a dry run still in flight does not mark a discarded draft', () async {
    final server = FakeWorkflowsClient()
      ..problems = const [WorkflowProblem('LATE', 'Late answer.')];
    final container = _container(server);
    await _loaded(container);

    _editor(container).edit((d) => d.rename('doing', 'Doing'));
    _editor(container).discard(); // before the answer arrives
    await Future<void>.delayed(Duration.zero);

    expect(_state(container).serverProblems, isEmpty);
    expect(_state(container).problems, isEmpty);
  });

  test('a dry run in flight does not mark a workflow just saved', () async {
    final server = FakeWorkflowsClient()
      ..problems = const [WorkflowProblem('LATE', 'Late answer.')];
    final container = _container(server);
    await _loaded(container);

    _editor(container).edit((d) => d.rename('doing', 'Doing'));
    final saved = await _editor(container).save();
    await Future<void>.delayed(Duration.zero);

    expect(saved, isTrue);
    expect(_state(container).problems, isEmpty);
  });

  test('a delete the server says still has tasks asks for a place', () async {
    final server = FakeWorkflowsClient()
      ..rejectWith = const [
        WorkflowProblem(
          'STATUS_NEEDS_MIGRATION',
          'In progress has tasks: choose a status to move them to.',
          'doing',
        ),
      ];
    final container = _container(server);
    await _loaded(container);
    _editor(container).edit((d) => d.remove('doing'));

    expect(await _editor(container).save(), isFalse);
    expect(_state(container).draft!.needMigration.map((s) => s.key), ['doing']);

    server.rejectWith = null;
    _editor(container).edit((d) => d.setMigration('doing', 'todo'));
    expect(await _editor(container).save(), isTrue);
    expect(server.saved.single.migrations, {'doing': 'todo'});
  });

  group('someone else saved first', () {
    Future<ProviderContainer> conflicted(
      FakeWorkflowsClient server,
      Workflow theirs,
      void Function(WorkflowEditor) edit,
    ) async {
      final container = _container(server);
      await _loaded(container);
      edit(_editor(container));
      server.workflow = theirs; // saved by someone else meanwhile
      await _editor(container).save();
      return container;
    }

    test(
      'the draft is kept and merged, nothing is saved, notes are listed',
      () async {
        final server = FakeWorkflowsClient();
        final container = await conflicted(
          server,
          defaultWorkflow(version: 5).copyWithStatuses(
            const WorkflowStatus(id: 'qa', name: 'QA', position: 3),
          ),
          (e) => e.edit((d) => d.rename('doing', 'Mine')),
        );

        final state = _state(container);
        expect(server.saved, isEmpty);
        expect(state.saveError?.failure, WorkflowFailure.conflict);
        expect(state.base!.version, 5);
        expect(state.draft!.statuses.map((s) => s.name), [
          'To do',
          'Mine',
          'Done',
          'QA',
        ]);
        expect(state.mergeNotes, ['Added by someone else: QA.']);
        expect(state.needsReview, isTrue);
        expect(state.canSave, isFalse, reason: 'not until it has been read');
      },
    );

    test(
      'saving after reading sends the merged draft at their version',
      () async {
        final server = FakeWorkflowsClient();
        final container = await conflicted(
          server,
          defaultWorkflow(version: 5).copyWithStatuses(
            const WorkflowStatus(id: 'qa', name: 'QA', position: 3),
          ),
          (e) => e.edit((d) => d.rename('doing', 'Mine')),
        );

        _editor(container).acknowledgeMerge();
        expect(_state(container).canSave, isTrue);
        final saved = await _editor(container).save();

        expect(saved, isTrue);
        expect(server.saved.single.statuses.map((s) => s.key), [
          'todo',
          'doing',
          'done',
          'qa',
        ]);
        expect(server.workflow.version, 6);
        expect(_state(container).needsReview, isFalse);
      },
    );

    test('their changes are never undone by my save', () async {
      final server = FakeWorkflowsClient();
      final container = await conflicted(
        server,
        defaultWorkflow(version: 3).copyWithStatuses(
          const WorkflowStatus(id: 'qa', name: 'QA', position: 3),
        ),
        (e) => e.edit((d) => d.rename('todo', 'Backlog')),
      );
      _editor(container).acknowledgeMerge();
      await _editor(container).save();

      expect(server.workflow.statuses.any((s) => s.name == 'QA'), isTrue);
      expect(server.workflow.statuses.first.name, 'Backlog');
    });

    test('a change that touches nothing of mine needs no review', () async {
      final server = FakeWorkflowsClient();
      final container = await conflicted(
        server,
        defaultWorkflow(version: 4),
        (e) => e.edit((d) => d.rename('doing', 'Mine')),
      );

      final state = _state(container);
      expect(state.mergeNotes, isEmpty);
      expect(state.needsReview, isFalse);
      expect(state.canSave, isTrue);
      expect(await _editor(container).save(), isTrue);
      expect(server.workflow.statuses[1].name, 'Mine');
    });

    test('edits made while reviewing are kept and the notes stay', () async {
      final server = FakeWorkflowsClient();
      final container = await conflicted(
        server,
        defaultWorkflow(version: 5).copyWithStatuses(
          const WorkflowStatus(id: 'qa', name: 'QA', position: 3),
        ),
        (e) => e.edit((d) => d.rename('doing', 'Mine')),
      );

      _editor(container).edit((d) => d.rename('done', 'Shipped'));

      expect(_state(container).mergeNotes, isNotEmpty);
      expect(_state(container).draft!.statuses[2].name, 'Shipped');
    });

    test(
      'throwing my draft away reloads what was saved and clears the notes',
      () async {
        final server = FakeWorkflowsClient();
        final container = await conflicted(
          server,
          defaultWorkflow(version: 5).copyWithStatuses(
            const WorkflowStatus(id: 'qa', name: 'QA', position: 3),
          ),
          (e) => e.edit((d) => d.rename('doing', 'Mine')),
        );

        await _editor(container).load();

        final state = _state(container);
        expect(state.mergeNotes, isEmpty);
        expect(state.dirty, isFalse);
        expect(state.draft!.statuses.map((s) => s.name), [
          'To do',
          'In progress',
          'Done',
          'QA',
        ]);
      },
    );

    test('discard also clears the notes', () async {
      final server = FakeWorkflowsClient();
      final container = await conflicted(
        server,
        defaultWorkflow(version: 5).copyWithStatuses(
          const WorkflowStatus(id: 'qa', name: 'QA', position: 3),
        ),
        (e) => e.edit((d) => d.rename('doing', 'Mine')),
      );

      _editor(container).discard();

      expect(_state(container).needsReview, isFalse);
      expect(_state(container).dirty, isFalse);
    });

    test(
      'if their version cannot be read the draft is left as it was',
      () async {
        final server = FakeWorkflowsClient();
        final container = _container(server);
        await _loaded(container);
        _editor(container).edit((d) => d.rename('doing', 'Mine'));
        server.workflow = defaultWorkflow(version: 5);
        // The save conflicts; reading theirs afterwards fails.
        final editor = _editor(container);
        final saving = editor.save();
        server.failNextGetAfterUpdate = true;
        await saving;

        expect(_state(container).draft!.statuses[1].name, 'Mine');
        expect(_state(container).saving, isFalse);
        expect(_state(container).saveError?.failure, WorkflowFailure.conflict);
      },
    );

    test('the error says the changes are still there', () {
      expect(
        workflowErrorMessage(const WorkflowException(WorkflowFailure.conflict)),
        contains('Your changes are still here'),
      );
    });
  });

  group('the creation rule', () {
    test('turning it on is a change that is saved', () async {
      final server = FakeWorkflowsClient();
      final container = _container(server);
      await _loaded(container);

      _editor(container).edit((d) => d.setRestrictCreation(true));
      expect(_state(container).dirty, isTrue);
      expect(await _editor(container).save(), isTrue);

      expect(server.saved.single.restrictCreation, isTrue);
      expect(server.workflow.restrictCreation, isTrue);
      expect(_state(container).dirty, isFalse);
    });

    test('putting it back is not a change', () async {
      final container = _container(FakeWorkflowsClient());
      await _loaded(container);

      _editor(container).edit((d) => d.setRestrictCreation(true));
      _editor(container).edit((d) => d.setRestrictCreation(false));

      expect(_state(container).dirty, isFalse);
    });
  });
}
