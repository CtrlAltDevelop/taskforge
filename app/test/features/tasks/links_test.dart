import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskforge/app_router.dart';
import 'package:taskforge/features/tasks/domain/links.dart';
import 'package:taskforge/features/tasks/domain/tasks.dart';
import 'package:taskforge/features/workflows/domain/workflow.dart';

import '../projects/fakes.dart';
import '../projects/projects_test_support.dart';
import '../workflows/fakes.dart';
import 'fakes.dart';

Pumped? _lastPumped;

Future<FakeTasksClient> _open(
  WidgetTester tester, {
  String role = 'Owner',
  List<Task>? tasks,
  void Function(FakeTasksClient)? setUp,
  String open = 'a',
}) async {
  final server = FakeTasksClient(
    tasks ??
        [
          task('a', 'First', number: 1),
          task('b', 'Second', number: 2),
          task('c', 'Third', number: 3),
        ],
  );
  setUp?.call(server);
  final pumped = await pumpProjects(
    tester,
    role: role,
    projects: [project('p1', 'Web')],
    tasks: server,
    workflows: FakeWorkflowsClient(defaultWorkflow()),
    size: const Size(1400, 1400),
  );
  _lastPumped = pumped;
  await pumped.go(tester, '/projects/p1');
  await tester.tap(find.byKey(Key('task-$open')));
  await tester.pumpAndSettle();
  return server;
}

TaskLink _link(
  String id,
  LinkKind kind, {
  String? other,
  bool hidden = false,
}) => hidden
    ? TaskLink(id: id, kind: kind, restricted: true)
    : TaskLink(
        id: id,
        kind: kind,
        otherId: other!,
        otherProjectId: 'p1',
        otherDisplayId: 'WEB-9',
        otherTitle: 'Linked $id',
        otherStatusName: 'To do',
      );

void main() {
  testWidgets('shows the links grouped by kind, a hidden one as restricted', (
    tester,
  ) async {
    await _open(
      tester,
      setUp: (s) => s.links['a'] = [
        _link('l1', LinkKind.blocks, other: 'b'),
        _link('l2', LinkKind.relates, other: 'c'),
        _link('l3', LinkKind.blockedBy, hidden: true),
      ],
    );

    expect(find.text('Blocks'), findsOneWidget);
    expect(find.text('Relates to'), findsOneWidget);
    expect(find.text('Is blocked by'), findsOneWidget);
    expect(find.text('WEB-9 Linked l1'), findsOneWidget);
    expect(find.text('Restricted task'), findsOneWidget);
  });

  testWidgets('a task with no links says so', (tester) async {
    await _open(tester);

    expect(find.byKey(const Key('no-links')), findsOneWidget);
  });

  testWidgets('adds a link: pick the kind and a task, and it shows up', (
    tester,
  ) async {
    final server = await _open(tester);

    await tester.tap(find.byKey(const Key('add-link')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('link-kind')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Is blocked by').last);
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('link-search')), 'third');
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('pick-b')), findsNothing);
    await tester.tap(find.byKey(const Key('pick-c')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('link-submit')));
    await tester.pumpAndSettle();

    expect(server.addedLinks.single.task, 'a');
    expect(server.addedLinks.single.other, 'c');
    expect(server.addedLinks.single.kind, LinkKind.blockedBy);
    expect(find.byKey(const Key('link-kind')), findsNothing);
    expect(find.text('WEB-3 Third'), findsOneWidget);
  });

  testWidgets('a task cannot be picked as a link to itself', (tester) async {
    await _open(tester);

    await tester.tap(find.byKey(const Key('add-link')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('pick-a')), findsNothing);
    expect(find.byKey(const Key('pick-b')), findsOneWidget);
  });

  testWidgets('a loop is refused in the dialog with the readable path', (
    tester,
  ) async {
    await _open(
      tester,
      setUp: (s) => s.failLink = const TaskException(
        TaskFailure.linkCycle,
        detail: 'WEB-1 → WEB-2 → WEB-1',
      ),
    );

    await tester.tap(find.byKey(const Key('add-link')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('pick-b')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('link-submit')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('link-error')), findsOneWidget);
    expect(find.textContaining('WEB-1 → WEB-2 → WEB-1'), findsOneWidget);
    expect(find.byKey(const Key('link-kind')), findsOneWidget);
  });

  testWidgets('a duplicates link can close the duplicate', (tester) async {
    final server = await _open(tester);

    await tester.tap(find.byKey(const Key('add-link')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('close-duplicate')), findsNothing);
    await tester.tap(find.byKey(const Key('link-kind')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Duplicates').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('close-duplicate')));
    await tester.tap(find.byKey(const Key('pick-b')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('link-submit')));
    await tester.pumpAndSettle();

    expect(server.addedLinks.single.close, isTrue);
  });

  testWidgets('removes a link', (tester) async {
    final server = await _open(
      tester,
      setUp: (s) => s.links['a'] = [_link('l1', LinkKind.blocks, other: 'b')],
    );

    await tester.tap(find.byKey(const Key('remove-link-l1')));
    await tester.pumpAndSettle();

    expect(server.removedLinks, ['l1']);
    expect(find.byKey(const Key('no-links')), findsOneWidget);
  });

  testWidgets('a viewer sees the links but cannot add or remove', (
    tester,
  ) async {
    await _open(
      tester,
      role: 'Viewer',
      setUp: (s) => s.links['a'] = [_link('l1', LinkKind.relates, other: 'b')],
    );

    expect(find.text('WEB-9 Linked l1'), findsOneWidget);
    expect(find.byKey(const Key('add-link')), findsNothing);
    expect(find.byKey(const Key('remove-link-l1')), findsNothing);
  });

  testWidgets('a blocked task shows the lock in the list and the detail', (
    tester,
  ) async {
    await _open(
      tester,
      tasks: [
        task('a', 'Stuck', isBlocked: true),
        task('b', 'Free', number: 2),
      ],
    );

    expect(find.byKey(const Key('blocked-badge')), findsNWidgets(2));
  });

  testWidgets('the lock names the open blockers in the list and the detail', (
    tester,
  ) async {
    await _open(
      tester,
      tasks: [
        task(
          'a',
          'Stuck',
          isBlocked: true,
          blockedBy: const ['WEB-4 (In progress)', 'Restricted task'],
        ),
      ],
    );

    final tips = tester
        .widgetList<Tooltip>(find.byType(Tooltip))
        .map((t) => t.message)
        .where((m) => m?.startsWith('Blocked by') ?? false)
        .toList();
    expect(tips, [
      'Blocked by WEB-4 (In progress), Restricted task',
      'Blocked by WEB-4 (In progress), Restricted task',
    ]);
  });

  testWidgets('the picker searches every project and skips the task itself', (
    tester,
  ) async {
    final server = await _open(
      tester,
      setUp: (s) => s.candidates = const [
        LinkCandidate(
          id: 'a',
          projectId: 'p1',
          displayId: 'WEB-1',
          title: 'First',
        ),
        LinkCandidate(
          id: 'x',
          projectId: 'p2',
          displayId: 'OPS-7',
          title: 'Rotate keys',
          statusName: 'To do',
        ),
      ],
    );

    await tester.tap(find.byKey(const Key('add-link')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('pick-a')), findsNothing);
    await tester.tap(find.byKey(const Key('pick-x')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('link-submit')));
    await tester.pumpAndSettle();

    expect(server.addedLinks.single.other, 'x');
  });

  Future<void> completeFirst(WidgetTester tester) async {
    await tester.tap(find.byKey(const Key('detail-status')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Done').last);
    await tester.pumpAndSettle();
  }

  testWidgets('completing a blocked task asks, and an admin can go ahead', (
    tester,
  ) async {
    final server = await _open(
      tester,
      setUp: (s) => s.blockedBy['a'] = 'WEB-2',
    );

    await completeFirst(tester);
    expect(find.byKey(const Key('blocked-text')), findsOneWidget);
    expect(find.textContaining('WEB-2'), findsWidgets);
    expect(server.tasks.first.statusName, 'To do');

    await tester.tap(find.byKey(const Key('complete-anyway')));
    await tester.pumpAndSettle();

    expect(server.overridden, ['a']);
    expect(server.tasks.first.statusName, 'Done');
  });

  testWidgets('cancelling the blocked dialog leaves the task where it was', (
    tester,
  ) async {
    final server = await _open(
      tester,
      setUp: (s) => s.blockedBy['a'] = 'WEB-2',
    );

    await completeFirst(tester);
    await tester.tap(find.byKey(const Key('blocked-cancel')));
    await tester.pumpAndSettle();

    expect(server.overridden, isEmpty);
    expect(server.tasks.first.statusName, 'To do');
    expect(
      find.descendant(
        of: find.byKey(const Key('cell-status-a')),
        matching: find.text('To do'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('a member without manage rights cannot override', (tester) async {
    final server = await _open(
      tester,
      role: 'Member',
      setUp: (s) {
        s.blockedBy['a'] = 'WEB-2';
        s.canOverride = false; // the server's word, not the app's role guess
      },
    );

    await completeFirst(tester);

    expect(find.byKey(const Key('complete-anyway')), findsNothing);
    await tester.tap(find.byKey(const Key('blocked-cancel')));
    await tester.pumpAndSettle();
    expect(server.overridden, isEmpty);
    expect(server.tasks.first.statusCategory, StatusCategory.notStarted);
  });

  testWidgets(
    'the server decides who is offered "complete anyway", not the role',
    (tester) async {
      // An Owner the server refuses (say, a project it does not manage).
      await _open(
        tester,
        setUp: (s) {
          s.blockedBy['a'] = 'WEB-2';
          s.canOverride = false;
        },
      );

      await completeFirst(tester);

      expect(find.byKey(const Key('complete-anyway')), findsNothing);
    },
  );

  testWidgets('completing a task with subtasks can be overridden too', (
    tester,
  ) async {
    final server = await _open(
      tester,
      tasks: [
        task('a', 'Parent', number: 1),
        task('b', 'Child', number: 2, parent: 'a', depth: 1),
      ],
      setUp: (s) => s.blockedBy['a'] = 'WEB-9',
    );

    await completeFirst(tester);
    await tester.tap(find.byKey(const Key('complete-all')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('blocked-text')), findsOneWidget);
    await tester.tap(find.byKey(const Key('complete-anyway')));
    await tester.pumpAndSettle();

    expect(server.overridden, ['a']);
    expect(server.moves.last.withSubtasks, isTrue);
  });

  testWidgets('a link to a task of another project opens that project there', (
    tester,
  ) async {
    await _open(
      tester,
      setUp: (s) => s.links['a'] = [
        const TaskLink(
          id: 'l1',
          kind: LinkKind.relates,
          otherId: 'x',
          otherProjectId: 'p2',
          otherDisplayId: 'OPS-7',
          otherTitle: 'Rotate keys',
        ),
      ],
    );

    await tester.tap(find.byKey(const Key('link-l1')));
    await tester.pumpAndSettle();

    final uri = _lastPumped!.container
        .read(routerProvider)
        .routeInformationProvider
        .value
        .uri;
    expect(uri.path, '/projects/p2');
    expect(uri.queryParameters['task'], 'x');
  });

  testWidgets('on a narrow screen the linked task opens as a page', (
    tester,
  ) async {
    final pumped = await pumpProjects(
      tester,
      projects: [project('p1', 'Web')],
      tasks: FakeTasksClient([
        task('a', 'First'),
        task('b', 'Second', number: 2),
      ]),
      workflows: FakeWorkflowsClient(defaultWorkflow()),
      size: const Size(420, 900),
    );

    await pumped.go(tester, '/projects/p1?task=b');
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('task-detail')), findsOneWidget);
    expect(find.byKey(const Key('detail-id')), findsOneWidget);
    expect(
      tester.widget<Text>(find.byKey(const Key('detail-id'))).data,
      'WEB-2',
    );
  });
}
