import 'package:flutter_test/flutter_test.dart';
import 'package:taskforge/features/tasks/domain/list_rows.dart';
import 'package:taskforge/features/tasks/domain/tasks.dart';
import 'package:taskforge/features/views/domain/list_layout.dart';

import 'fakes.dart';

List<ListEntry> _entries(
  List<dynamic> tasks,
  ListQuery query, {
  Set<String> collapsedTasks = const {},
  Set<String> collapsedGroups = const {},
  bool loading = false,
  Map<String, int> counts = const {},
}) => listEntries(
  [...tasks.cast()],
  query,
  collapsedTasks: collapsedTasks,
  collapsedGroups: collapsedGroups,
  loading: loading,
  serverCounts: counts,
);

String _show(List<ListEntry> entries) => entries
    .map(
      (e) => switch (e) {
        TaskEntry(:final task, :final depth) => '${'-' * depth}${task.id}',
        GroupEntry(:final key, :final count, :final collapsed) =>
          '[$key:$count${collapsed ? ' closed' : ''}]',
      },
    )
    .join(' ');

void main() {
  final tasks = [
    task('a', 'A'),
    task('b', 'B', number: 2, parent: 'a', depth: 1),
    task('c', 'C', number: 3),
  ];

  test('without sort or grouping the rows are the tree', () {
    expect(_show(_entries(tasks, const ListQuery())), 'a -b c');
  });

  test('a folded parent hides its subtasks', () {
    expect(
      _show(_entries(tasks, const ListQuery(), collapsedTasks: {'a'})),
      'a c',
    );
  });

  test('a sorted list is flat: no indent, no chevrons', () {
    final rows = _entries(tasks, const ListQuery(sort: [SortKey('title')]));

    expect(_show(rows), 'a b c');
    expect(rows.whereType<TaskEntry>().every((e) => !e.hasChildren), isTrue);
  });

  group('grouped', () {
    final grouped = [
      withGroup(task('a', 'A'), 'todo'),
      withGroup(task('b', 'B', number: 2), 'todo'),
      withGroup(task('c', 'C', number: 3), 'done'),
    ];
    const query = ListQuery(groupBy: 'status');

    test('a header opens each group, with how many it holds', () {
      expect(_show(_entries(grouped, query)), '[todo:2] a b [done:1] c');
    });

    test('a collapsed group keeps its header and drops its tasks', () {
      expect(
        _show(_entries(grouped, query, collapsedGroups: {'todo'})),
        '[todo:2 closed] [done:1] c',
      );
    });

    test(
      'while loading the count is the server\'s, so it is right at once',
      () {
        final partial = grouped.sublist(0, 1);

        expect(
          _show(_entries(partial, query, loading: true, counts: {'todo': 40})),
          '[todo:40] a',
        );
        expect(_show(_entries(partial, query)), '[todo:1] a');
      },
    );

    test('a group the server has not counted falls back to what is held', () {
      expect(
        _show(_entries(grouped, query, loading: true)),
        '[todo:2] a b [done:1] c',
      );
    });
  });

  test('taskIds lists only tasks', () {
    final rows = _entries([
      withGroup(task('a', 'A'), 'x'),
    ], const ListQuery(groupBy: 'status'));

    expect(taskIds(rows), ['a']);
  });

  group('a task edited into another group', () {
    test('joins that group instead of splitting it with a second header', () {
      final moved = task('m', 'M', number: 4, statusId: 'done');
      final grouped = [
        task('a', 'A').withGroupKey('todo'),
        moved.withGroupKey(groupKeyOf(moved, 'status')),
        task('c', 'C', number: 3).withGroupKey('done'),
        task('d', 'D', number: 5).withGroupKey('todo'),
      ];
      expect(
        _show(_entries(grouped, const ListQuery(groupBy: 'status'))),
        '[todo:2] a d [done:2] m c',
      );
    });

    test('groupKeyOf names the group the way the server does', () {
      final t = task(
        't',
        'T',
        statusId: 's1',
        priority: TaskPriority.high,
        assignees: ['u1', 'u2'],
        fieldValues: {'f1': 'opt'},
      );
      expect(groupKeyOf(t, 'status'), 's1');
      expect(groupKeyOf(t, 'priority'), 'high');
      expect(groupKeyOf(t, 'assignee'), 'u1');
      expect(groupKeyOf(t, 'field:f1'), 'opt');
      expect(groupKeyOf(t, 'field:other'), '');
      expect(groupKeyOf(task('n', 'N'), 'assignee'), '');
    });
  });
}
