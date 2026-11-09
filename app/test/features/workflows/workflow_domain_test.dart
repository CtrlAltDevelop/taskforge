import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskforge/features/workflows/domain/workflow.dart';
import 'package:taskforge/features/workflows/domain/workflow_draft.dart';

WorkflowStatus s(
  String id,
  String name,
  StatusCategory category, {
  bool isDefault = false,
  int taskCount = 0,
}) => WorkflowStatus(
  id: id,
  name: name,
  category: category,
  isDefault: isDefault,
  taskCount: taskCount,
);

final todo = s('todo', 'To do', StatusCategory.notStarted, isDefault: true);
final doing = s('doing', 'In progress', StatusCategory.active, taskCount: 2);
final done = s('done', 'Done', StatusCategory.done);

Workflow flow({
  bool restrict = false,
  List<WorkflowTransition> transitions = const [],
}) => Workflow(
  projectId: 'p1',
  statuses: [todo, doing, done],
  restrict: restrict,
  transitions: transitions,
);

Set<String> codes(WorkflowDraft d) => {
  for (final p in validateDraft(d)) p.code,
};

void main() {
  group('moves', () {
    test('without restriction every move is allowed', () {
      final w = flow();

      expect(
        w.refusal(from: 'todo', to: 'done', hasAssignee: false, roleId: 'r'),
        isNull,
      );
      expect(
        w.targets(from: 'todo', hasAssignee: false, roleId: 'r'),
        hasLength(3),
      );
    });

    test('restricted moves follow the arrows, and staying put is free', () {
      final w = flow(
        restrict: true,
        transitions: const [WorkflowTransition(from: 'todo', to: 'doing')],
      );

      expect(
        w.refusal(from: 'todo', to: 'done', hasAssignee: true, roleId: ''),
        isA<MoveRefusal>().having(
          (r) => r.reason,
          'reason',
          'To do → Done is not allowed.',
        ),
      );
      expect(
        w.refusal(from: 'todo', to: 'doing', hasAssignee: true, roleId: ''),
        isNull,
      );
      expect(
        w.refusal(from: 'todo', to: 'todo', hasAssignee: true, roleId: ''),
        isNull,
      );
      expect(
        [
          for (final t in w.targets(
            from: 'todo',
            hasAssignee: true,
            roleId: '',
          ))
            t.id,
        ],
        ['todo', 'doing'],
      );
    });

    test('the assignee and role conditions are checked', () {
      final w = flow(
        restrict: true,
        transitions: const [
          WorkflowTransition(
            from: 'todo',
            to: 'doing',
            requireAssignee: true,
            requiredRoleId: '7',
          ),
        ],
      );

      expect(
        w
            .refusal(
              from: 'todo',
              to: 'doing',
              hasAssignee: false,
              roleId: '7',
            )!
            .reason,
        contains('needs an assignee'),
      );
      expect(
        w
            .refusal(from: 'todo', to: 'doing', hasAssignee: true, roleId: '8')!
            .reason,
        contains('role'),
      );
      expect(
        w.refusal(from: 'todo', to: 'doing', hasAssignee: true, roleId: '7'),
        isNull,
      );
    });

    test('the default status and lookups', () {
      final w = flow();

      expect(w.defaultStatus.id, 'todo');
      expect(w.statusById('done')!.name, 'Done');
      expect(w.statusById('nope'), isNull);
    });
  });

  group('colours and categories', () {
    test('a hex colour parses, anything else is grey', () {
      expect(parseStatusColor('#1E88E5'), const Color(0xFF1E88E5));
      expect(parseStatusColor(''), const Color(0xFF9E9E9E));
      expect(parseStatusColor('blue'), const Color(0xFF9E9E9E));
    });

    test('categories parse and know which are final', () {
      expect(StatusCategory.parse('not_started'), StatusCategory.notStarted);
      expect(StatusCategory.parse('???'), StatusCategory.active);
      expect(StatusCategory.done.isFinal, isTrue);
      expect(StatusCategory.cancelled.isFinal, isTrue);
      expect(StatusCategory.active.isFinal, isFalse);
    });
  });

  group('editing a draft', () {
    final base = WorkflowDraft.of(flow());

    test('renames, recolours and recategorises one status only', () {
      final d = base
          .rename('doing', 'Doing')
          .recolor('doing', '#112233')
          .recategorize('doing', StatusCategory.cancelled);

      final doingNow = d.statuses.firstWhere((x) => x.key == 'doing');
      expect(
        (doingNow.name, doingNow.color, doingNow.category),
        ('Doing', '#112233', StatusCategory.cancelled),
      );
      expect(d.statuses.firstWhere((x) => x.key == 'todo').name, 'To do');
    });

    test('there is always at most one default', () {
      final d = base.makeDefault('doing');

      expect(
        [
          for (final x in d.statuses)
            if (x.isDefault) x.key,
        ],
        ['doing'],
      );
    });

    test('adding appends a new status', () {
      final d = base.add('new-1', name: 'QA', color: '#abcdef');

      expect(d.statuses.last.key, 'new-1');
      expect(d.statuses.last.isNew, isTrue);
      expect(d.statuses, hasLength(4));
    });

    test(
      'reorder follows the list widget (moving down counts its own removal)',
      () {
        expect(
          [for (final x in base.reorder(0, 2).statuses) x.key],
          ['doing', 'todo', 'done'],
        );
        expect(
          [for (final x in base.reorder(2, 0).statuses) x.key],
          ['done', 'todo', 'doing'],
        );
      },
    );

    test('transitions toggle on and off and take conditions', () {
      var d = base.toggleTransition('todo', 'doing');
      expect(d.allows('todo', 'doing'), isTrue);
      expect(d.allows('doing', 'todo'), isFalse);

      d = d.setConditions('todo', 'doing', requireAssignee: true);
      d = d.setConditions('todo', 'doing', requiredRoleId: '3');
      expect(d.transitions.single.requireAssignee, isTrue);
      expect(d.transitions.single.requiredRoleId, '3');

      d = d.toggleTransition('todo', 'doing');
      expect(d.transitions, isEmpty);
    });

    test('deleting a status with tasks needs a place for them', () {
      final d = base.remove('doing');

      expect(d.needMigration.map((x) => x.key), ['doing']);
      expect(codes(d), contains('STATUS_NEEDS_MIGRATION'));

      final moved = base.remove('doing', moveTasksTo: 'todo');
      expect(moved.needMigration, isEmpty);
      expect(moved.migrations, {'doing': 'todo'});
      expect(moved.statuses.map((x) => x.key), ['todo', 'done']);
    });

    test('deleting a status without tasks, or a new one, needs nothing', () {
      expect(base.remove('done').needMigration, isEmpty);
      final fresh = base.add('n').remove('n');
      expect(fresh.removed, isEmpty);
      expect(fresh.statuses, hasLength(3));
    });

    test('deleting also drops its transitions and migrations aimed at it', () {
      final d = base
          .toggleTransition('todo', 'doing')
          .toggleTransition('doing', 'done')
          .remove('doing', moveTasksTo: 'done')
          .remove('done');

      expect(d.transitions, isEmpty);
      expect(d.migrations.containsValue('done'), isFalse);
      expect(
        codes(d),
        contains('STATUS_NEEDS_MIGRATION'),
        reason: 'the target it chose was deleted too',
      );
    });
  });

  group('deleting more than one status', () {
    final base = WorkflowDraft.of(flow());

    test('deleting the place earlier tasks were sent to moves them on', () {
      final d = base
          .remove('doing', moveTasksTo: 'done')
          .remove('done', moveTasksTo: 'todo');

      expect(d.migrations, {'doing': 'todo'});
      expect(d.needMigration, isEmpty);
      // Only "To do" is left, so what is missing is a Done status, not a place
      // for the tasks.
      expect(codes(d), {'NO_DONE_STATUS'});
    });

    test('knows which statuses are about to receive tasks', () {
      final d = base.remove('doing', moveTasksTo: 'done');

      expect(d.isMigrationTarget('done'), isTrue);
      expect(d.isMigrationTarget('todo'), isFalse);
    });

    test('a target removed without a new one is asked about again', () {
      final d = base.remove('doing', moveTasksTo: 'done').remove('done');

      expect(d.needMigration.map((s) => s.key), ['doing']);
    });

    test('a place can be chosen after the fact', () {
      final d = base.remove('doing').setMigration('doing', 'todo');

      expect(d.needMigration, isEmpty);
      expect(d.migrations, {'doing': 'todo'});
    });

    test(
      'a status the server says still has tasks starts asking for a place',
      () {
        final d = base.remove('done').withUnknownTasks('done');

        expect(d.needMigration.map((s) => s.key), ['done']);
        expect(codes(d), contains('STATUS_NEEDS_MIGRATION'));
      },
    );
  });

  group('validation (the same rules as the server)', () {
    final base = WorkflowDraft.of(flow());

    test('the default workflow is valid', () {
      expect(validateDraft(base), isEmpty);
    });

    test('needs Not started and Done statuses and one non-final default', () {
      expect(
        codes(base.recategorize('done', StatusCategory.active)),
        contains('NO_DONE_STATUS'),
      );
      expect(
        codes(base.recategorize('todo', StatusCategory.active)),
        contains('NO_NOT_STARTED_STATUS'),
      );
      expect(codes(base.makeDefault('nope')), contains('NO_DEFAULT_STATUS'));
      expect(codes(base.makeDefault('done')), contains('DEFAULT_IS_FINAL'));
    });

    test('names must be 1-40 characters and unique ignoring case', () {
      expect(
        codes(base.rename('doing', '  ')),
        contains('STATUS_NAME_INVALID'),
      );
      expect(
        codes(base.rename('doing', 'n' * 41)),
        contains('STATUS_NAME_INVALID'),
      );
      expect(
        codes(base.rename('doing', 'to DO')),
        contains('STATUS_NAME_TAKEN'),
      );
    });

    test(
      'a name is counted in code points like the server, not UTF-16 units',
      () {
        final emoji = '\u{1F600}' * 21; // 21 characters, 42 UTF-16 units

        expect(
          codes(base.rename('doing', emoji)),
          isNot(contains('STATUS_NAME_INVALID')),
        );
        expect(
          codes(base.rename('doing', '\u{1F600}' * 41)),
          contains('STATUS_NAME_INVALID'),
        );
      },
    );

    test('at most thirty statuses', () {
      var d = base;
      for (var i = 0; i < 28; i++) {
        d = d.add('k$i', name: 'S$i');
      }
      expect(codes(d), contains('TOO_MANY_STATUSES'));
    });

    test('a restricted workflow must be connected and reach Done', () {
      final restricted = base.setRestrict(true);

      expect(
        codes(restricted),
        containsAll([
          'STATUS_UNREACHABLE',
          'NO_DONE_REACHABLE',
          'STATUS_DEAD_END',
        ]),
      );

      final connected = restricted
          .toggleTransition('todo', 'doing')
          .toggleTransition('doing', 'done')
          .toggleTransition('doing', 'todo');
      expect(validateDraft(connected), isEmpty);
    });

    test('a problem names the status it is about', () {
      final problems = validateDraft(base.rename('doing', ''));

      expect(
        problems.where((p) => p.code == 'STATUS_NAME_INVALID').single.statusKey,
        'doing',
      );
    });

    test('an unrestricted workflow ignores the graph', () {
      expect(codes(base), isNot(contains('STATUS_UNREACHABLE')));
    });
  });

  test('error messages are friendly', () {
    expect(
      workflowErrorMessage(const WorkflowException(WorkflowFailure.network)),
      contains('Cannot reach'),
    );
    expect(
      workflowErrorMessage(
        const WorkflowException(WorkflowFailure.denied, detail: 'You need x'),
      ),
      'You need x',
    );
    expect(workflowErrorMessage(StateError('x')), contains('Something went'));
  });
}
