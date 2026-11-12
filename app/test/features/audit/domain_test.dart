import 'package:flutter_test/flutter_test.dart';
import 'package:taskforge/features/audit/domain/activity_lines.dart';
import 'package:taskforge/features/audit/domain/audit.dart';
import 'package:taskforge/features/audit/domain/describe.dart';

import 'fakes.dart';

void main() {
  const labels = {'s1': 'To do', 's2': 'Done', 'u2': 'Zoe', 'u3': 'Max'};

  group('describeEntry', () {
    test('a status change names both statuses', () {
      final e = entry(
        1,
        'task.status_changed',
        changes: {
          'status_id': ['s1', 's2'],
        },
      );
      expect(describeEntry(e, labels), 'changed status To do → Done');
    });

    test('assigning says who was added and who removed', () {
      final e = entry(
        1,
        'task.assignees_changed',
        changes: {
          'assignees': [
            ['u2'],
            ['u3'],
          ],
        },
      );
      expect(describeEntry(e, labels), 'assigned Max and unassigned Zoe');
    });

    test('an edit shows short values and hides the rest', () {
      final e = entry(
        1,
        'task.updated',
        changes: {
          'title': ['Old', 'New'],
          'description': [
            {'size': 900},
            {'size': 950},
          ],
        },
      );
      expect(
        describeEntry(e, labels),
        'changed title “Old” → “New”, description',
      );
    });

    test('an unknown action reads as plain words', () {
      expect(describeEntry(entry(1, 'role.created'), labels), 'role created');
    });

    test('a file names itself, not its bytes', () {
      final e = entry(1, 'attachment.created', changes: {'filename': 'a.txt'});
      expect(describeEntry(e, labels), 'attached “a.txt”');
    });
  });

  group('activityLines', () {
    final t = DateTime.utc(2026, 11, 12, 10);
    AuditEntry edit(int id, int minutesAgo, Map<String, dynamic> c) => entry(
      id,
      'task.updated',
      at: t.subtract(Duration(minutes: minutesAgo)),
      changes: c,
    );

    test('edits by one person within ten minutes fold into one line', () {
      final lines = activityLines([
        edit(3, 0, {
          'title': ['B', 'C'],
        }),
        edit(2, 2, {
          'title': ['A', 'B'],
          'priority': ['none', 'high'],
        }),
      ]);
      expect(lines, hasLength(1));
      expect(lines.single.merged, 2);
      expect(lines.single.entry.changes['title'], ['A', 'C']);
      expect(lines.single.entry.changes['priority'], ['none', 'high']);
    });

    test(
      'another person, a long gap or another kind of change stays apart',
      () {
        final lines = activityLines([
          edit(4, 0, {
            'title': ['b', 'c'],
          }),
          entry(
            3,
            'task.status_changed',
            at: t.subtract(const Duration(minutes: 1)),
          ),
          edit(2, 2, {
            'title': ['a', 'b'],
          }),
          entry(
            1,
            'task.updated',
            actor: 'u9',
            at: t.subtract(const Duration(minutes: 3)),
          ),
        ]);
        expect(lines, hasLength(4));
      },
    );
  });

  test('relative times and day headings', () {
    final now = DateTime(2026, 11, 12, 12);
    expect(
      relativeTime(now, now.subtract(const Duration(seconds: 5))),
      'just now',
    );
    expect(
      relativeTime(now, now.subtract(const Duration(minutes: 5))),
      '5 min ago',
    );
    expect(
      relativeTime(now, now.subtract(const Duration(hours: 2))),
      '2 h ago',
    );
    expect(dayHeading(now, now), 'Today');
    expect(dayHeading(now, now.subtract(const Duration(days: 1))), 'Yesterday');
  });

  test('filters compare by value and know when they are empty', () {
    expect(const AuditFilters().isEmpty, isTrue);
    expect(
      const AuditFilters(action: 'task.'),
      const AuditFilters(action: 'task.'),
    );
    expect(const AuditFilters(action: 'task.').isEmpty, isFalse);
    final cleared = AuditFilters(since: DateTime(2026)).copyWith(since: null);
    expect(cleared.since, isNull);
  });
}
