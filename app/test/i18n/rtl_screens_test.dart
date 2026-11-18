import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:taskforge/app.dart';
import 'package:taskforge/core/deep_links.dart';
import 'package:taskforge/core/auth/auth_providers.dart';
import 'package:taskforge/core/auth/auth_session.dart';
import 'package:taskforge/core/auth/token_store.dart';
import 'package:taskforge/core/sync/sync_providers.dart';
import 'package:taskforge/features/account/account_providers.dart';
import 'package:taskforge/features/workspaces/application/workspace_providers.dart';

import '../features/workspaces/fakes.dart'
    show FakeAccounts, FakeWorkspaceClient, MockAuthApi;

import 'package:taskforge/app_router.dart';
import 'package:taskforge/features/search/presentation/search_overlay.dart';
import 'package:taskforge/features/shortcuts/presentation/command_palette.dart';

import 'package:taskforge/features/comments/application/comments_providers.dart';
import 'package:taskforge/features/sprints/domain/sprints.dart';
import 'package:taskforge/features/time/domain/time.dart';
import 'package:taskforge/features/audit/application/audit_providers.dart';
import 'package:taskforge/features/dashboards/application/dashboards_providers.dart';
import 'package:taskforge/features/imports/application/imports_providers.dart';
import 'package:taskforge/features/imports/presentation/import_io.dart';
import 'package:taskforge/features/inbox/application/inbox_providers.dart';
import 'package:taskforge/features/search/application/search_providers.dart';
import 'package:taskforge/features/shortcuts/application/local_prefs.dart';
import 'package:taskforge/features/sprints/application/sprints_providers.dart';
import 'package:taskforge/features/tasks/domain/tasks.dart';
import 'package:taskforge/features/time/application/time_providers.dart';

import 'package:taskforge/features/dashboards/domain/dashboards.dart';

import 'package:taskforge/features/chat/application/chat_providers.dart';
import 'package:taskforge/features/chat/domain/chat.dart';

import '../features/audit/fakes.dart';
import '../features/chat/fakes.dart' as chatfakes;
import '../features/dashboards/fakes.dart';
import '../features/docs/fakes.dart';
import '../features/imports/fakes.dart';
import '../features/inbox/fakes.dart';
import '../features/projects/fakes.dart';

import 'package:taskforge/features/security/application/security_providers.dart';
import 'package:taskforge/features/system/application/system_providers.dart';

import '../features/projects/projects_test_support.dart';
import '../features/security/fakes.dart';
import '../features/system/fakes.dart';
import '../features/search/fakes.dart';
import '../features/sprints/fakes.dart';
import '../features/tasks/fakes.dart';
import '../features/time/fakes.dart';

/// Every screen of the app, built in English, Persian and Arabic on a phone and
/// a desktop: no exception, no overflow, and the reading direction is the
/// language's. Layout defects found here are fixed in `lib`, not skipped.

const _phone = Size(390, 844);
const _desktop = Size(1280, 800);

/// Smallest phone still in use: catches overflows the 390 wide case hides.
const _smallPhone = Size(320, 568);
const _languages = ['en', 'fa', 'ar'];

/// A mixed-direction title: Persian text around a Latin key, and one long word.
const _bidiTitle = 'رفع خطای ورود WEB-12 در صفحه اصلی';
const _longWord = 'supercalifragilisticexpialidocious_with_a_very_long_name';

List<Task> _tasks() => [
  task('a', _bidiTitle, priority: TaskPriority.high, assignees: ['u1']),
  task('b', _longWord, number: 2, assignees: ['u2'], dueDate: '2026-11-20'),
  task('c', 'Charlie', number: 3, statusId: 'doing', statusName: 'Doing'),
];

/// Opens [location] signed in; the shared fakes are filled with realistic data.
typedef Opener = Future<void> Function(WidgetTester tester, ScreenEnv env);

class ScreenEnv {
  ScreenEnv(this.size, this.language);

  final Size size;
  final String language;
  Pumped? lastPumped;
  String? lastLocation;

  Future<Pumped> open(
    WidgetTester tester,
    String location, {
    bool featuresOn = true,
    List<String> workspaces = const ['w1'],
    List<Override> overrides = const [],
    FakeDocsClient? docs,
    FakeSprintsClient? sprints,
    FakeInboxClient? inbox,
    FakeTimeClient? time,
    chatfakes.FakeChatClient? chatServer,
    String role = 'Owner',
  }) async {
    final prefs = MemoryPrefs();
    await prefs.write('locale.language', language);
    final pumped = await pumpProjects(
      tester,
      role: role,
      size: size,
      workspaces: workspaces,
      projects: [
        project(
          'p1',
          'Web',
          enabled: featuresOn
              ? {sprintsFeature, timeFeature, 'docs', 'automations'}
              : {},
        ),
        project('p2', 'مستندات Docs', archived: true),
      ],
      tasks: FakeTasksClient(_tasks()),
      docs: docs ?? _docs(),
      sprints: sprints ?? _sprints(),
      inbox: inbox ?? _inbox(),
      chat: chatServer,
      time: time ?? _time(),
      overrides: [
        localPrefsProvider.overrideWithValue(prefs),
        deepLinksProvider.overrideWith((ref) => const Stream<Uri>.empty()),
        searchClientProvider.overrideWithValue(FakeSearchClient()),
        auditClientProvider.overrideWithValue(
          FakeAuditClient(
            [
              entry(1, 'task.created'),
              entry(
                2,
                'task.status_changed',
                changes: {
                  'status_id': ['s1', 's2'],
                },
              ),
            ],
            labels: const {'s1': 'To do', 's2': 'Done'},
          ),
        ),
        auditNowProvider.overrideWithValue(
          () => DateTime.utc(2026, 11, 12, 12),
        ),
        dashboardsClientProvider.overrideWithValue(_dashboards()),
        dashboardRefreshProvider.overrideWithValue(null),
        viewerDayProvider.overrideWithValue(
          () => (today: '2026-11-12', offsetMinutes: 0),
        ),
        importsClientProvider.overrideWithValue(FakeImportsClient()),
        importFilesProvider.overrideWithValue(FakeImportFiles()),
        importPickerProvider.overrideWithValue(() async => null),
        exportSaverProvider.overrideWithValue((n, b) async {}),
        sprintTodayProvider.overrideWithValue(() => DateTime(2026, 11, 12)),
        currentUserIdProvider.overrideWithValue('u1'),
        timeNowProvider.overrideWithValue(() => DateTime(2026, 11, 11, 12)),
        inboxNowProvider.overrideWithValue(() => noon),
        ...overrides,
      ],
    );
    await pumped.go(tester, location);
    lastPumped = pumped;
    lastLocation = location;
    return pumped;
  }
}

FakeDocsClient _docs() => FakeDocsClient(
  nodes: [
    node('a', _bidiTitle),
    node('a1', 'Setup', parent: 'a'),
  ],
  bodies: {
    'a': [
      heading('h1', _bidiTitle),
      para('p1', 'متن فارسی with English WEB-12 inside.'),
      taskCard('t1', 'a'),
    ],
  },
);

FakeSprintsClient _sprints() => FakeSprintsClient(
  sprints: [mkSprint('s1', 'Sprint 1', goal: _bidiTitle)],
  tasks: [
    sTask('a', points: 3),
    sTask('b', points: 5),
    sTask('d', sprint: 's1'),
  ],
);

FakeInboxClient _inbox() => FakeInboxClient(
  initial: [
    note('n1', 'task.assigned'),
    note('n2', 'user.mentioned', read: true, actor: 'علی'),
  ],
);

FakeTimeClient _time() =>
    FakeTimeClient()..add(FakeTimeClient().make(task: 'a', seconds: 3600));

FakeDashboardsClient _dashboards() => (FakeDashboardsClient([
  dashboardOf('d1', 'Team', [widgetOf('w1', WidgetKind.number, title: 'Open')]),
]));

chatfakes.FakeChatClient _chatServer() => chatfakes.FakeChatClient(
  spaces: [
    chatfakes.space('gen', _bidiTitle, unread: 2, isDefault: true),
    chatfakes.space('rnd', _longWord),
    chatfakes.space('g', 'Leads', kind: SpaceKind.group),
    chatfakes.space('d', '', kind: SpaceKind.dm, peer: 'u2'),
  ],
  taskChats: const [
    TaskChatRef(taskId: 'a', projectId: 'p1', title: _bidiTitle),
  ],
  messages: [
    chatfakes.msg('m1', 'gen', 'متن فارسی with English WEB-12 inside.'),
    chatfakes.msg('m2', 'gen', _longWord, author: 'u1'),
  ],
);

Map<String, Opener> screenCases() => {
  'chat': (t, e) => e.open(
    t,
    '/chat',
    chatServer: _chatServer(),
    overrides: [chatMeProvider.overrideWithValue('u1')],
  ),
  'chat conversation': (t, e) => e.open(
    t,
    '/chat/gen',
    chatServer: _chatServer(),
    overrides: [chatMeProvider.overrideWithValue('u1')],
  ),
  'home': (t, e) => e.open(t, '/'),
  'language': (t, e) => e.open(t, '/settings/language'),
  'appearance': (t, e) => e.open(t, '/settings/appearance'),
  'security': (t, e) => e.open(t, '/settings/security'),
  'system': (t, e) => e.open(t, '/system'),
  'about': (t, e) => e.open(t, '/about'),
  'developer': (t, e) => e.open(t, '/developer'),
  'forms': (t, e) => e.open(t, '/forms'),
  'goals': (t, e) => e.open(t, '/goals'),
  'workload': (t, e) => e.open(t, '/workload'),
  'sessions': (t, e) => e.open(t, '/sessions'),
  'workspace settings': (t, e) => e.open(t, '/workspaces/settings'),
  'roles': (t, e) => e.open(t, '/workspaces/roles'),
  'members': (t, e) => e.open(t, '/members'),
  'project list': (t, e) => e.open(t, '/projects/p1'),
  'project board': (t, e) => e.open(t, '/projects/p1?view=board'),
  'project timeline': (t, e) => e.open(t, '/projects/p1?view=timeline'),
  'project calendar': (t, e) => e.open(t, '/projects/p1?view=calendar'),
  'task detail': (t, e) => e.open(t, '/projects/p1?task=a'),
  'project settings': (t, e) => e.open(t, '/projects/p1/settings'),
  'sprints': (t, e) => e.open(t, '/projects/p1/sprints'),
  'automations': (t, e) => e.open(t, '/projects/p1/automations'),
  'workflow': (t, e) => e.open(t, '/projects/p1/workflow'),
  'fields': (t, e) => e.open(t, '/projects/p1/fields'),
  'archived projects': (t, e) => e.open(t, '/projects/archived'),
  'private projects': (t, e) => e.open(t, '/projects/private'),
  'docs': (t, e) => e.open(t, '/docs'),
  'inbox': (t, e) => e.open(t, '/inbox'),
  'inbox prefs': (t, e) => e.open(t, '/inbox/preferences'),
  'timesheet': (t, e) => e.open(t, '/timesheet'),
  'audit': (t, e) => e.open(t, '/audit'),
  'import': (t, e) => e.open(t, '/import'),
  'dashboards': (t, e) => e.open(t, '/dashboards'),
  'calendar': (t, e) => e.open(t, '/calendar'),
  'offline': (t, e) => e.open(t, '/offline'),
  'debug': (t, e) => e.open(t, '/debug'),
  'onboarding': (t, e) => e.open(t, '/', workspaces: const []),
  'change password': (t, e) => e.open(t, '/change-password'),
  'docs page': (t, e) => e.open(t, '/docs/a'),
  'invite': (t, e) => e.open(t, '/invite/tok'),
  'private docs project': (t, e) => e.open(t, '/docs', featuresOn: false),
  'task trash': (t, e) async {
    await e.open(t, '/projects/p1');
    final trash = find.byKey(const Key('open-task-trash'));
    if (trash.evaluate().isNotEmpty) {
      await t.tap(trash);
      await t.pumpAndSettle();
    }
  },
  'search overlay': (t, e) async {
    await e.open(t, '/');
    openSearch(t.element(find.byType(Scaffold).first));
    await t.pumpAndSettle();
    expect(find.byKey(const Key('search-field')), findsOneWidget);
  },
  'command palette': (t, e) async {
    await e.open(t, '/');
    openCommandPalette(t.element(find.byType(Scaffold).first));
    await t.pumpAndSettle();
    expect(find.byKey(const Key('palette-field')), findsOneWidget);
  },
};

const skipLocationCheck = {
  'onboarding',
  'private docs project',
  'task trash',
  'search overlay',
  'command palette',
};

void main() {
  for (final entry in screenCases().entries) {
    group(entry.key, () {
      for (final size in [_smallPhone, _phone, _desktop]) {
        for (final language in _languages) {
          final label =
              '$language ${size.width.toInt()}x${size.height.toInt()}';
          testWidgets(label, (tester) async {
            ScreenEnv? lastEnv;
            final errors = <String>[];
            final previous = FlutterError.onError;
            FlutterError.onError = (d) =>
                errors.add(d.toString().split('\n').take(40).join('\n'));
            try {
              lastEnv = ScreenEnv(size, language);
              await entry.value(tester, lastEnv);
              await tester.pump(const Duration(milliseconds: 300));
            } finally {
              FlutterError.onError = previous;
            }
            final thrown = tester.takeException();
            expect(errors, isEmpty, reason: errors.join(' --- '));
            expect(thrown, isNull);
            final env = lastEnv;
            final wanted = env.lastLocation;
            if (wanted != null && wanted != '/' || env.lastPumped != null) {
              final at = env.lastPumped!.container
                  .read(routerProvider)
                  .routeInformationProvider
                  .value
                  .uri;
              final expected = Uri.parse(env.lastLocation!).path;
              if (!skipLocationCheck.contains(entry.key)) {
                expect(at.path, expected, reason: 'redirected away');
              }
            }
            final scaffold = find.byType(Scaffold).first;
            expect(
              Directionality.of(tester.element(scaffold)),
              language == 'en' ? TextDirection.ltr : TextDirection.rtl,
            );
          });
        }
      }
    });
  }

  // The signed-out pages: nobody is signed in, so these cannot use pumpProjects.
  const signedOut = {
    'sign in': '/sign-in',
    'sign up': '/sign-up',
    'forgot password': '/forgot-password',
    'reset password': '/reset-password',
  };
  for (final entry in signedOut.entries) {
    group(entry.key, () {
      for (final size in [_smallPhone, _phone, _desktop]) {
        for (final language in _languages) {
          testWidgets(
            '$language ${size.width.toInt()}x${size.height.toInt()}',
            (tester) async {
              final errors = <String>[];
              final previous = FlutterError.onError;
              FlutterError.onError = (d) => errors.add(
                d.toString().split(RegExp('\n')).take(40).join(' | '),
              );
              try {
                tester.view
                  ..physicalSize = size
                  ..devicePixelRatio = 1;
                addTearDown(tester.view.reset);
                final prefs = MemoryPrefs();
                await prefs.write('locale.language', language);
                final session = AuthSession(
                  api: MockAuthApi(),
                  store: MemoryTokenStore(),
                );
                await session.restore();
                final container = ProviderContainer(
                  overrides: [
                    authSessionProvider.overrideWithValue(session),
                    syncClientProvider.overrideWithValue(null),
                    accountClientProvider.overrideWithValue(FakeAccounts()),
                    workspaceClientProvider.overrideWithValue(
                      FakeWorkspaceClient(),
                    ),
                    localPrefsProvider.overrideWithValue(prefs),
                    securityClientProvider.overrideWithValue(
                      FakeSecurityClient(),
                    ),
                    systemClientProvider.overrideWithValue(FakeSystemClient()),
                  ],
                );
                addTearDown(container.dispose);
                await tester.pumpWidget(
                  UncontrolledProviderScope(
                    container: container,
                    child: const TaskForgeApp(),
                  ),
                );
                await tester.pumpAndSettle();
                container.read(routerProvider).go(entry.value, extra: 'ticket');
                await tester.pumpAndSettle();
                expect(
                  container
                      .read(routerProvider)
                      .routeInformationProvider
                      .value
                      .uri
                      .path,
                  entry.value,
                );
              } finally {
                FlutterError.onError = previous;
              }
              expect(errors, isEmpty, reason: errors.join(' --- '));
              expect(tester.takeException(), isNull);
              expect(
                Directionality.of(tester.element(find.byType(Scaffold).first)),
                language == 'en' ? TextDirection.ltr : TextDirection.rtl,
              );
            },
          );
        }
      }
    });
  }
}
