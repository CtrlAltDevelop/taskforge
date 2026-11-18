import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:taskforge/core/deep_links.dart';
import 'package:material_ui/material_ui.dart';
import 'package:taskforge/features/calendar/domain/calendar_math.dart';
import 'package:taskforge/features/shortcuts/application/local_prefs.dart';
import 'package:taskforge/features/tasks/domain/tasks.dart';
import 'package:taskforge/features/workflows/domain/workflow.dart';

import '../features/board/fakes.dart';
import '../features/calendar/fakes.dart';
import '../features/projects/fakes.dart';
import '../features/projects/projects_test_support.dart';
import '../features/tasks/fakes.dart';
import '../features/timeline/fakes.dart';
import '../features/workflows/fakes.dart';
import 'tolerant_golden.dart';

/// Pictures of the work views (phase 46): list, board, calendar and timeline
/// on a wide screen, and the list and the board on a phone, each in light and
/// dark, in English and Persian. Regenerate with `flutter test
/// --update-goldens test/i18n/work_goldens_test.dart` after a deliberate
/// restyle.

const _wide = Size(1280, 800);
const _phone = Size(390, 844);

Task _dated(Task t, String start, String due) => Task(
  id: t.id,
  projectId: t.projectId,
  number: t.number,
  displayId: t.displayId,
  title: t.title,
  statusId: t.statusId,
  statusName: t.statusName,
  statusCategory: t.statusCategory,
  priority: t.priority,
  startDate: start,
  dueDate: due,
  assigneeIds: t.assigneeIds,
  version: t.version,
);

List<Task> _tasks() => [
  _dated(
    task('a', 'Design the new sign-in page', priority: TaskPriority.high),
    '2026-11-09',
    '2026-11-13',
  ),
  _dated(
    task(
      'b',
      'Fix the export bug that drops the last row of a long report',
      number: 2,
      statusId: 'doing',
      statusName: 'Doing',
      category: StatusCategory.active,
      assignees: ['u1', 'u2'],
    ),
    '2026-11-10',
    '2026-11-12',
  ),
  _dated(
    task(
      'c',
      'Ship the release',
      number: 3,
      statusId: 'done',
      statusName: 'Done',
      category: StatusCategory.done,
      priority: TaskPriority.urgent,
    ),
    '',
    '2026-11-05',
  ),
  _dated(task('d', 'Write the docs', number: 4), '', '2026-11-20'),
];

Future<Pumped> _open(
  WidgetTester tester,
  Size size,
  String language,
  String at,
) async {
  final prefs = MemoryPrefs();
  await prefs.write('locale.language', language);
  final server = FakeTasksClient(_tasks());
  final pumped = await pumpProjects(
    tester,
    size: size,
    projects: [project('p1', 'Web')],
    tasks: server,
    workflows: FakeWorkflowsClient(defaultWorkflow()),
    board: FakeBoardClient(server.tasks),
    calendar: FakeCalendarClient(server),
    timeline: FakeTimelineClient(server),
    today: day(2026, 11, 12),
    overrides: [
      localPrefsProvider.overrideWithValue(prefs),
      deepLinksProvider.overrideWith((ref) => const Stream<Uri>.empty()),
    ],
  );
  await pumped.go(tester, at);
  return pumped;
}

void main() {
  setUpAll(useTolerantGoldens);

  final views = <String, (Size, String)>{
    'list': (_wide, '/projects/p1'),
    'board': (_wide, '/projects/p1?view=board'),
    'calendar': (_wide, '/projects/p1?view=calendar'),
    'timeline': (_wide, '/projects/p1?view=timeline'),
    'phone_list': (_phone, '/projects/p1'),
    'phone_board': (_phone, '/projects/p1?view=board'),
  };
  for (final entry in views.entries) {
    for (final (mode, modeName) in [
      (ThemeMode.light, 'light'),
      (ThemeMode.dark, 'dark'),
    ]) {
      for (final language in ['en', 'fa']) {
        testWidgets('${entry.key}, $modeName, $language looks the same every '
            'run', (tester) async {
          final pumped = await _open(
            tester,
            entry.value.$1,
            language,
            entry.value.$2,
          );
          pumped.container.read(themeModeProvider.notifier).choose(mode);
          await tester.pumpAndSettle();

          await expectLater(
            find.byType(MaterialApp),
            matchesGoldenFile(
              'goldens/work_${entry.key}_${modeName}_$language.png',
            ),
          );
        });
      }
    }
  }
}
