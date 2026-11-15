import 'package:flutter_test/flutter_test.dart';
import 'package:taskforge/features/workflows/domain/workflow.dart';
import 'package:taskforge/features/workflows/domain/workflow_draft.dart';
import 'package:taskforge/features/workflows/domain/workflow_merge.dart';

import 'fakes.dart';

/// [base] is what both people started from; [theirs] what the other saved; the
/// draft is mine, started from [base] and edited with [edit].
MergeResult merge({
  Workflow? base,
  required Workflow theirs,
  WorkflowDraft Function(WorkflowDraft)? edit,
}) {
  final start = base ?? defaultWorkflow();
  final mine = edit == null
      ? WorkflowDraft.of(start)
      : edit(WorkflowDraft.of(start));
  return mergeWorkflows(base: start, theirs: theirs, mine: mine);
}

Workflow theirs({
  List<WorkflowStatus>? statuses,
  bool restrict = false,
  bool restrictCreation = false,
  List<WorkflowTransition> transitions = const [],
}) {
  final b = defaultWorkflow();
  return Workflow(
    projectId: 'p1',
    version: 2,
    statuses: statuses ?? b.statuses,
    restrict: restrict,
    restrictCreation: restrictCreation,
    transitions: transitions,
  );
}

WorkflowStatus renamed(WorkflowStatus s, String name) => WorkflowStatus(
  id: s.id,
  name: name,
  color: s.color,
  category: s.category,
  position: s.position,
  isDefault: s.isDefault,
  taskCount: s.taskCount,
);

WorkflowStatus recolored(WorkflowStatus s, String color) => WorkflowStatus(
  id: s.id,
  name: s.name,
  color: color,
  category: s.category,
  position: s.position,
  isDefault: s.isDefault,
  taskCount: s.taskCount,
);

final basis = defaultWorkflow();
final todo = basis.statuses[0];
final doing = basis.statuses[1];
final done = basis.statuses[2];

String nameOf(MergeResult r, String key) =>
    r.draft.statuses.firstWhere((s) => s.key == key).name;

void main() {
  test(
    'nobody else changed anything: my draft comes back as it was, no notes',
    () {
      final r = merge(
        theirs: defaultWorkflow(version: 2),
        edit: (d) => d.rename('doing', 'Doing'),
      );

      expect(r.english, isEmpty);
      expect(nameOf(r, 'doing'), 'Doing');
      expect(r.draft.differsFrom(defaultWorkflow(version: 2)), isTrue);
    },
  );

  group('one status', () {
    test(
      'a field only I changed stays mine; one only they changed is theirs',
      () {
        final r = merge(
          theirs: theirs(statuses: [todo, recolored(doing, '#E53935'), done]),
          edit: (d) => d.rename('doing', 'Doing'),
        );

        final s = r.draft.statuses[1];
        expect((s.name, s.color), ('Doing', '#E53935'));
        expect(r.english, [
          'Someone else changed the colour of In progress to #E53935.',
        ]);
      },
    );

    test('both changed the same field: theirs wins, my edit is named', () {
      final r = merge(
        theirs: theirs(statuses: [todo, renamed(doing, 'Active'), done]),
        edit: (d) => d.rename('doing', 'Doing'),
      );

      expect(nameOf(r, 'doing'), 'Active');
      expect(
        r.english.single,
        contains('Your change to the name of Active ("Doing") was dropped'),
      );
      expect(r.english.single, contains('"Active"'));
    });

    test('both made the same change: no conflict, no note', () {
      final r = merge(
        theirs: theirs(statuses: [todo, renamed(doing, 'Doing'), done]),
        edit: (d) => d.rename('doing', 'Doing'),
      );

      expect(nameOf(r, 'doing'), 'Doing');
      expect(r.english, isEmpty);
    });

    test('the category and the default follow the same rule', () {
      final r = merge(
        theirs: theirs(
          statuses: [
            todo,
            WorkflowStatus(
              id: 'doing',
              name: 'In progress',
              color: '#1E88E5',
              category: StatusCategory.cancelled,
              position: 1,
            ),
            done,
          ],
        ),
        edit: (d) => d.recategorize('doing', StatusCategory.notStarted),
      );

      expect(r.draft.statuses[1].category, StatusCategory.cancelled);
      expect(r.english.single, contains('category'));
    });
  });

  group('adding and deleting', () {
    test('a status someone else added is added, and said so', () {
      const qa = WorkflowStatus(id: 'qa', name: 'QA', position: 3);
      final r = merge(theirs: theirs(statuses: [todo, doing, done, qa]));

      expect(r.draft.statuses.map((s) => s.key), [
        'todo',
        'doing',
        'done',
        'qa',
      ]);
      expect(r.english, ['Added by someone else: QA.']);
    });

    test('a status someone else added is never lost to my save', () {
      const qa = WorkflowStatus(id: 'qa', name: 'QA', position: 3);
      final r = merge(
        theirs: theirs(statuses: [todo, doing, done, qa]),
        edit: (d) => d.rename('todo', 'Backlog'),
      );

      expect(r.draft.statuses.any((s) => s.key == 'qa'), isTrue);
    });

    test('my new status is kept next to theirs', () {
      const qa = WorkflowStatus(id: 'qa', name: 'QA', position: 3);
      final r = merge(
        theirs: theirs(statuses: [todo, doing, done, qa]),
        edit: (d) => d.add('new-0', name: 'Review'),
      );

      expect(r.draft.statuses.map((s) => s.key), [
        'todo',
        'doing',
        'done',
        'qa',
        'new-0',
      ]);
      expect(r.draft.statuses.last.isNew, isTrue);
    });

    test('a status they deleted stays deleted, even if I edited it', () {
      final untouched = merge(theirs: theirs(statuses: [todo, done]));
      final edited = merge(
        theirs: theirs(statuses: [todo, done]),
        edit: (d) => d.rename('doing', 'Doing'),
      );

      expect(untouched.draft.statuses.map((s) => s.key), ['todo', 'done']);
      expect(untouched.english, ['Deleted by someone else: In progress.']);
      expect(edited.draft.statuses.map((s) => s.key), ['todo', 'done']);
      expect(
        edited.english.single,
        contains('Your changes to it were dropped'),
      );
    });

    test('a status I deleted stays deleted when they left it alone', () {
      final busy = defaultWorkflow(doingTasks: 2);
      final r = merge(
        base: busy,
        theirs: Workflow(projectId: 'p1', version: 2, statuses: busy.statuses),
        edit: (d) => d.remove('doing', moveTasksTo: 'todo'),
      );

      expect(r.draft.statuses.map((s) => s.key), ['todo', 'done']);
      expect(r.draft.removed.map((s) => s.key), ['doing']);
      expect(r.draft.migrations, {'doing': 'todo'});
      expect(r.english, isEmpty);
    });

    test('a status I deleted but they edited is kept, and I am told', () {
      final r = merge(
        theirs: theirs(statuses: [todo, renamed(doing, 'Active'), done]),
        edit: (d) => d.remove('doing'),
      );

      expect(r.draft.statuses.map((s) => s.key), ['todo', 'doing', 'done']);
      expect(nameOf(r, 'doing'), 'Active');
      expect(r.draft.removed, isEmpty);
      expect(r.english.single, startsWith('Kept Active'));
    });

    test(
      'the place I chose for deleted tasks was deleted by them: asked again',
      () {
        final busy = defaultWorkflow(doingTasks: 2);
        final r = merge(
          base: busy,
          theirs: Workflow(
            projectId: 'p1',
            version: 2,
            statuses: [busy.statuses[0], busy.statuses[1]],
          ),
          edit: (d) => d.remove('doing', moveTasksTo: 'done'),
        );

        expect(r.draft.migrations, isEmpty);
        expect(
          r.english.any((n) => n.contains('choose another place')),
          isTrue,
        );
      },
    );

    test('the task count of a kept status is the saved one', () {
      final busy = WorkflowStatus(
        id: 'doing',
        name: 'In progress',
        color: '#1E88E5',
        position: 1,
        taskCount: 7,
      );
      final r = merge(theirs: theirs(statuses: [todo, busy, done]));

      expect(r.draft.statuses[1].taskCount, 7);
    });
  });

  group('order', () {
    test('my order stands when only I reordered', () {
      final r = merge(theirs: theirs(), edit: (d) => d.moveTo(0, 2));

      expect(r.draft.statuses.map((s) => s.key), ['doing', 'done', 'todo']);
      expect(r.english, isEmpty);
    });

    test('their order stands when only they reordered, and it is said', () {
      final r = merge(theirs: theirs(statuses: [done, todo, doing]));

      expect(r.draft.statuses.map((s) => s.key), ['done', 'todo', 'doing']);
      expect(r.english, ['Someone else reordered the statuses.']);
    });

    test(
      'both reordered differently: theirs stands, mine is named as dropped',
      () {
        final r = merge(
          theirs: theirs(statuses: [done, todo, doing]),
          edit: (d) => d.moveTo(0, 2),
        );

        expect(r.draft.statuses.map((s) => s.key), ['done', 'todo', 'doing']);
        expect(
          r.english.single,
          contains('Your new order of the statuses was dropped'),
        );
      },
    );

    test('a status others added keeps its place after my reordering', () {
      const qa = WorkflowStatus(id: 'qa', name: 'QA', position: 3);
      final r = merge(
        theirs: theirs(statuses: [todo, doing, done, qa]),
        edit: (d) => d.moveTo(0, 2),
      );

      expect(r.draft.statuses.map((s) => s.key), [
        'doing',
        'done',
        'todo',
        'qa',
      ]);
    });
  });

  group('the switches', () {
    test('a switch only I changed stays; only they changed is theirs', () {
      final mineOnly = merge(
        theirs: theirs(),
        edit: (d) => d.setRestrict(true),
      );
      final theirsOnly = merge(theirs: theirs(restrictCreation: true));

      expect(mineOnly.draft.restrict, isTrue);
      expect(mineOnly.english, isEmpty);
      expect(theirsOnly.draft.restrictCreation, isTrue);
      expect(theirsOnly.english, [
        'Someone else turned "New tasks start in the default status only" on.',
      ]);
    });

    test('we both flipped it differently: theirs stands and it is said', () {
      final r = merge(
        theirs: theirs(restrict: true),
        base: defaultWorkflow(restrict: false),
        edit: (d) => d.setRestrict(false).setRestrictCreation(true),
      );

      // Mine matched the base for "restrict" (I left it off), so theirs applies.
      expect(r.draft.restrict, isTrue);
      expect(r.draft.restrictCreation, isTrue);
    });

    test('a true clash on a switch goes to theirs with my change named', () {
      final base = defaultWorkflow(restrictCreation: false);
      final r = mergeWorkflows(
        base: base,
        theirs: Workflow(
          projectId: 'p1',
          version: 2,
          statuses: base.statuses,
          restrictCreation: true,
        ),
        mine: WorkflowDraft.of(base)
            .setRestrictCreation(true)
            .setRestrict(true),
      );

      // Same change on creation: no clash. restrict only mine: stays.
      expect(r.draft.restrictCreation, isTrue);
      expect(r.draft.restrict, isTrue);
      expect(r.english, isEmpty);
    });
  });

  group('moves', () {
    final arrow = [
      const WorkflowTransition(from: 'todo', to: 'doing'),
      const WorkflowTransition(from: 'doing', to: 'done'),
    ];

    test('a move only I added or removed stays; only they added is theirs', () {
      final mineAdds = merge(
        theirs: theirs(),
        edit: (d) => d.toggleTransition('todo', 'doing'),
      );
      final theirAdds = merge(theirs: theirs(transitions: arrow));

      expect(mineAdds.draft.transitions, hasLength(1));
      expect(mineAdds.english, isEmpty);
      expect(theirAdds.draft.transitions, hasLength(2));
      expect(theirAdds.english, [
        'Someone else allowed the move To do → In progress.',
        'Someone else allowed the move In progress → Done.',
      ]);
    });

    test('both sets of moves are kept when they differ', () {
      final r = merge(
        theirs: theirs(transitions: [arrow.first]),
        edit: (d) => d.toggleTransition('doing', 'done'),
      );

      expect(
        {for (final t in r.draft.transitions) '${t.from}>${t.to}'},
        {'todo>doing', 'doing>done'},
      );
    });

    test('a move they removed that I did not touch is removed', () {
      final base = defaultWorkflow(restrict: true, transitions: arrow);
      final r = merge(
        base: base,
        theirs: Workflow(
          projectId: 'p1',
          version: 2,
          statuses: base.statuses,
          restrict: true,
          transitions: [arrow.last],
        ),
      );

      expect(r.draft.transitions.map((t) => t.from), ['doing']);
      expect(r.english, ['Someone else removed the move To do → In progress.']);
    });

    test('conditions I changed stay; ones we both changed go to theirs', () {
      final base = defaultWorkflow(restrict: true, transitions: arrow);
      Workflow withRule(WorkflowTransition t) => Workflow(
        projectId: 'p1',
        version: 2,
        statuses: base.statuses,
        restrict: true,
        transitions: [t, arrow.last],
      );

      final mineOnly = merge(
        base: base,
        theirs: withRule(arrow.first),
        edit: (d) => d.setConditions('todo', 'doing', requireAssignee: true),
      );
      final both = merge(
        base: base,
        theirs: withRule(
          const WorkflowTransition(
            from: 'todo',
            to: 'doing',
            requiredRoleId: '2',
          ),
        ),
        edit: (d) => d.setConditions('todo', 'doing', requiredRoleId: '3'),
      );

      expect(mineOnly.draft.transitions.first.requireAssignee, isTrue);
      expect(mineOnly.english, isEmpty);
      expect(both.draft.transitions.first.requiredRoleId, '2');
      expect(both.english.single, contains('Your change to the conditions'));
    });

    test('the subtasks condition merges like the other conditions', () {
      final base = defaultWorkflow(restrict: true, transitions: arrow);
      Workflow withRule(bool subtasks) => Workflow(
        projectId: 'p1',
        version: 2,
        statuses: base.statuses,
        restrict: true,
        transitions: [
          arrow.first,
          WorkflowTransition(
            from: 'doing',
            to: 'done',
            requireSubtasksDone: subtasks,
          ),
        ],
      );

      final mineOnly = merge(
        base: base,
        theirs: withRule(false),
        edit: (d) =>
            d.setConditions('doing', 'done', requireSubtasksDone: true),
      );
      final theirsOnly = merge(base: base, theirs: withRule(true));

      expect(mineOnly.draft.transitions.last.requireSubtasksDone, isTrue);
      expect(mineOnly.english, isEmpty);
      expect(theirsOnly.draft.transitions.last.requireSubtasksDone, isTrue);
      expect(theirsOnly.english.single, contains('changed the conditions'));
    });

    test('a move to a status that is gone is dropped and counted', () {
      final r = merge(
        theirs: theirs(statuses: [todo, done]),
        edit: (d) => d.toggleTransition('todo', 'doing'),
      );

      expect(r.draft.transitions, isEmpty);
      expect(
        r.english.any((n) => n.contains('One of your moves was dropped')),
        isTrue,
      );
    });
  });

  test('the merged draft is always a valid starting point to review', () {
    const qa = WorkflowStatus(id: 'qa', name: 'QA', position: 3);
    final r = merge(
      theirs: theirs(statuses: [todo, renamed(doing, 'Active'), done, qa]),
      edit: (d) => d.rename('doing', 'Doing').add('n', name: 'Review'),
    );

    expect(validateDraft(r.draft), isEmpty);
    expect(r.draft.statuses.map((s) => s.name), [
      'To do',
      'Active',
      'Done',
      'QA',
      'Review',
    ]);
  });
}
