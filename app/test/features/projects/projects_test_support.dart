import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:taskforge/features/board/application/board_providers.dart';
import 'package:taskforge/features/filters/application/filters_providers.dart';
import 'package:taskforge/features/calendar/application/calendar_providers.dart';
import 'package:taskforge/features/attachments/application/attachments_providers.dart';
import 'package:taskforge/features/comments/application/comments_providers.dart';
import 'package:taskforge/features/timeline/application/timeline_providers.dart';
import 'package:taskforge/features/calendar/domain/calendar_math.dart';
import 'package:taskforge/features/views/application/views_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskforge/app_router.dart';
import 'package:taskforge/features/fields/application/fields_providers.dart';
import 'package:taskforge/features/members/application/members_providers.dart';
import 'package:taskforge/features/projects/domain/projects.dart';
import 'package:taskforge/features/tasks/application/tasks_providers.dart';
import 'package:taskforge/features/workflows/application/workflows_providers.dart';

import '../fields/fakes.dart';
import '../tasks/fakes.dart';
import '../time/fakes.dart';
import '../workflows/fakes.dart';

import '../members/fakes.dart';
import '../roles/fakes.dart';
import '../workspaces/fakes.dart';
import 'fakes.dart';
import '../views/fakes.dart';
import '../board/fakes.dart';
import '../filters/fakes.dart';
import '../calendar/fakes.dart';
import '../attachments/fakes.dart';
import '../inbox/fakes.dart';
import '../comments/fakes.dart';
import '../timeline/fakes.dart';

export '../workspaces/fakes.dart' show byKey;

/// The workspace members the project pickers offer; 'Zoe' is the signed-in user.
FakeMembersClient team() => FakeMembersClient(
  members: [member('u1', 'Zoe', owner: true), member('u2', 'Hank Hill')],
);

class Pumped {
  Pumped(this.container, this.projects);

  final ProviderContainer container;
  final FakeProjectsClient projects;

  Future<void> go(WidgetTester tester, String location) async {
    container.read(routerProvider).go(location);
    await tester.pumpAndSettle();
  }
}

/// The whole app signed in as [role], on a wide screen unless [size] says so.
Future<Pumped> pumpProjects(
  WidgetTester tester, {
  String role = 'Owner',
  List<Project> projects = const [],
  FakeProjectsClient? server,
  FakeTasksClient? tasks,
  FakeWorkflowsClient? workflows,
  FakeFieldsClient? fields,
  FakeViewsClient? views,
  FakeBoardClient? board,
  FakeCalendarClient? calendar,
  FakeTimelineClient? timeline,
  FakeCommentsClient? comments,
  FakeAttachments? attachments,
  FakeInboxClient? inbox,
  FakeTimeClient? time,
  FakeLocalNotifier? localNotifier,
  FakeFiltersClient? filters,
  Day? today,
  Override? sync,
  List<Override> overrides = const [],
  List<String> workspaces = const ['w1'],
  Size size = const Size(1400, 1200),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final fake = server ?? FakeProjectsClient(projects);
  final files = attachments ?? FakeAttachments();
  final container = await pumpSignedIn(
    tester,
    FakeWorkspaceClient([for (final id in workspaces) ws(id, 'WS $id')]),
    roles: FakeRolesClient(callerRole: (_) => role),
    projects: fake,
    inbox: inbox,
    time: time,
    localNotifier: localNotifier,
    sync: sync,
    overrides: [
      membersClientProvider.overrideWithValue(team()),
      viewsClientProvider.overrideWithValue(views ?? FakeViewsClient()),
      boardClientProvider.overrideWithValue(board ?? FakeBoardClient()),
      filtersClientProvider.overrideWithValue(filters ?? FakeFiltersClient()),
      calendarClientProvider.overrideWithValue(
        calendar ?? FakeCalendarClient(tasks ?? FakeTasksClient()),
      ),
      commentsClientProvider.overrideWithValue(
        comments ?? FakeCommentsClient(),
      ),
      attachmentsClientProvider.overrideWithValue(files),
      uploadsClientProvider.overrideWithValue(files),
      timelineClientProvider.overrideWithValue(
        timeline ?? FakeTimelineClient(tasks ?? FakeTasksClient()),
      ),
      if (today != null) todayProvider.overrideWithValue(today),
      tasksClientProvider.overrideWithValue(tasks ?? FakeTasksClient()),
      workflowsClientProvider.overrideWithValue(
        workflows ?? FakeWorkflowsClient(),
      ),
      fieldsClientProvider.overrideWithValue(fields ?? FakeFieldsClient()),
      ...overrides,
    ],
  );
  return Pumped(container, fake);
}

double top(WidgetTester tester, String key) =>
    tester.getTopLeft(find.byKey(Key(key))).dy;
