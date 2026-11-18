import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:taskforge/core/deep_links.dart';
import 'package:taskforge/features/home/application/home_providers.dart';
import 'package:taskforge/features/home/domain/home.dart';
import 'package:taskforge/features/shortcuts/application/local_prefs.dart';

import '../features/home/fakes.dart';
import '../features/projects/fakes.dart';
import '../features/projects/projects_test_support.dart';
import '../features/tasks/fakes.dart';
import '../features/workflows/fakes.dart';
import 'tolerant_golden.dart';

/// Pictures of Home (phone and desktop) and the first-run steps (starter and
/// invite), each in light and dark, English and Persian. Regenerate with
/// `flutter test --update-goldens test/i18n/home_goldens_test.dart` after a
/// deliberate restyle.

const _wide = Size(1280, 800);
const _phone = Size(390, 844);

HomeSummary _summary() => HomeSummary(
  todayCount: 3,
  overdueCount: 1,
  inProgressCount: 4,
  dueItems: [
    homeTask('a', title: 'Design the new sign-in page', due: '2026-11-18'),
    homeTask(
      'b',
      title: 'Fix the export bug',
      number: 2,
      due: '2026-11-10',
      status: 'In progress',
      category: 'active',
    ),
  ],
  recent: [homeTask('c', title: 'Write the docs', number: 3)],
  mentions: const [
    HomeMention(
      id: 'm1',
      type: 'mention',
      taskId: 'a',
      createdAt: '2026-11-18T08:00:00Z',
      read: false,
    ),
  ],
  unreadNotifications: 4,
  unreadChat: 2,
  week: [
    for (var i = 0; i < 7; i++)
      HomeDay(
        date: '2026-11-${12 + i}',
        seconds: const [0, 5400, 7200, 3600, 9000, 0, 1800][i],
      ),
  ],
  pinned: const [
    HomePin(dashboardId: 'd1', name: 'Sprint health', projectId: 'p1'),
  ],
  computedAt: '2026-11-18T07:30:00Z',
);

FakeHomeClient _home() => FakeHomeClient(
  summaryValue: _summary(),
  assigned: [
    MyWorkItem(
      task: homeTask('a', title: 'Design the new sign-in page'),
      assigned: true,
      watching: false,
    ),
    MyWorkItem(
      task: homeTask(
        'b',
        title: 'Fix the export bug',
        number: 2,
        status: 'In progress',
        category: 'active',
      ),
      assigned: true,
      watching: false,
    ),
  ],
  onboarding: OnboardingState(
    visible: true,
    steps: const {
      'create_task': true,
      'invite_member': false,
      'try_board': false,
      'open_palette': false,
    },
    sampleProjectId: 'p1',
  ),
);

Future<Pumped> _open(
  WidgetTester tester,
  Size size,
  String language,
  String at, {
  List<String> workspaces = const ['w1'],
}) async {
  final prefs = MemoryPrefs();
  await prefs.write('locale.language', language);
  final pumped = await pumpProjects(
    tester,
    size: size,
    projects: [project('p1', 'Web')],
    tasks: FakeTasksClient([task('a', 'Design the new sign-in page')]),
    workflows: FakeWorkflowsClient(defaultWorkflow()),
    home: _home(),
    workspaces: workspaces,
    overrides: [
      localPrefsProvider.overrideWithValue(prefs),
      homeNowProvider.overrideWithValue(() => DateTime(2026, 11, 18, 9, 30)),
      deepLinksProvider.overrideWith((ref) => const Stream<Uri>.empty()),
    ],
  );
  await pumped.go(tester, at);
  return pumped;
}

void main() {
  setUpAll(useTolerantGoldens);

  final views = <String, (Size, String)>{
    'phone': (_phone, '/'),
    'desktop': (_wide, '/'),
    'my_work': (_wide, '/my-work'),
    'starter': (_wide, '/welcome/starter'),
    'invite': (_wide, '/welcome/invite?project=p1'),
    // Step 1 of first run: no workspace yet, so the app is on its name step.
    'workspace': (_wide, '/onboarding'),
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
            workspaces: entry.key == 'workspace' ? const [] : const ['w1'],
          );
          pumped.container.read(themeModeProvider.notifier).choose(mode);
          await tester.pumpAndSettle();

          await expectLater(
            find.byType(MaterialApp),
            matchesGoldenFile(
              'goldens/home_${entry.key}_${modeName}_$language.png',
            ),
          );
        });
      }
    }
  }
}
