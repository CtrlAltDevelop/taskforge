import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:taskforge/features/imports/application/imports_providers.dart';
import 'package:taskforge/features/imports/domain/imports.dart';
import 'package:taskforge/features/imports/presentation/import_io.dart';

import '../projects/fakes.dart';
import '../projects/projects_test_support.dart';
import 'fakes.dart';

Finder key(String k) => find.byKey(Key(k));

PickedImport _file({String name = 'export.csv', int size = 5}) => PickedImport(
  name: name,
  size: size,
  open: () => Stream.value(List.filled(size, 1)),
);

class Opened {
  Opened(this.client, this.files, this.saved);

  final FakeImportsClient client;
  final FakeImportFiles files;
  final List<(String, Uint8List)> saved;
}

Future<Opened> _open(
  WidgetTester tester, {
  FakeImportsClient? client,
  FakeImportFiles? files,
  String role = 'Owner',
  PickedImport? picks,
  Size size = const Size(1000, 2200),
}) async {
  final server = client ?? FakeImportsClient();
  final sender = files ?? FakeImportFiles();
  final saved = <(String, Uint8List)>[];
  final pumped = await pumpProjects(
    tester,
    role: role,
    projects: [project('p1', 'Web')],
    size: size,
    overrides: [
      importsClientProvider.overrideWithValue(server),
      importFilesProvider.overrideWithValue(sender),
      importPickerProvider.overrideWithValue(() async => picks ?? _file()),
      exportSaverProvider.overrideWithValue((n, b) async => saved.add((n, b))),
    ],
  );
  await pumped.go(tester, '/import');
  return Opened(server, sender, saved);
}

Future<void> _tap(WidgetTester tester, String k) async {
  expect(key(k), findsOneWidget, reason: 'no $k');
  await tester.ensureVisible(key(k));
  await tester.pumpAndSettle();
  await tester.tap(key(k));
  await tester.pumpAndSettle();
}

/// Picks a value in a dropdown of the mapping tables.
Future<void> _choose(WidgetTester tester, String dropdown, String text) async {
  await tester.ensureVisible(key(dropdown));
  await tester.pumpAndSettle();
  await tester.tap(key(dropdown));
  await tester.pumpAndSettle();
  await tester.tap(find.text(text).last);
  await tester.pumpAndSettle();
}

Future<void> _toMapping(WidgetTester tester) async {
  await _tap(tester, 'source-jira_csv');
  await _tap(tester, 'source-next');
  await _tap(tester, 'import-pick');
}

void main() {
  testWidgets('a member without data.manage sees nothing to do', (
    tester,
  ) async {
    await _open(tester, role: 'Member');
    expect(key('import-denied'), findsOneWidget);
    expect(key('import-wizard'), findsNothing);
    expect(key('open-export'), findsNothing);
  });

  testWidgets('the wizard goes Source, Upload, Map, Review, Import', (
    tester,
  ) async {
    final o = await _open(tester);
    expect(key('source-auto'), findsOneWidget);
    await _toMapping(tester);

    expect(o.files.uploads.single.name, 'export.csv');
    expect(o.files.uploads.single.read, 5); // the stream was sent, not a copy
    expect(o.files.uploads.single.source, 'jira_csv');
    expect(
      find.textContaining('4 tasks (2 sub-tasks), 2 comments, 1 links'),
      findsOneWidget,
    );
    expect(key('map-labels'), findsOneWidget);
    expect(find.textContaining('Sprint 1, Sprint 2'), findsOneWidget);

    await _tap(tester, 'map-next');
    expect(o.client.calls.last, startsWith('dryRun j1'));
    expect(find.text('4 tasks'), findsOneWidget);
    expect(key('review-counts'), findsOneWidget);

    await _tap(tester, 'import-start');
    expect(o.client.calls.any((c) => c.startsWith('start j1')), isTrue);
    expect(key('import-result'), findsOneWidget);
    expect(find.text('Import finished'), findsOneWidget);
    expect(key('import-stats'), findsOneWidget);
    expect(find.textContaining('4 tasks'), findsWidgets);
    expect(key('import-open-project'), findsOneWidget);
  });

  testWidgets('the choices made in Map are what is sent', (tester) async {
    final o = await _open(tester);
    await _toMapping(tester);

    await _tap(tester, 'map-target-existing');
    await _choose(tester, 'map-project', 'Web (WEB)');
    await _choose(tester, 'map-priority-High', 'Urgent');
    await _choose(tester, 'map-user-alice@acme.test', 'Leave unassigned');
    await _choose(tester, 'map-col-status', '(not in the file)');
    await tester.tap(key('map-labels'));
    await tester.pumpAndSettle();
    await _tap(tester, 'map-next');

    final sent = jsonDecode(
      o.client.calls.last.replaceFirst('dryRun j1 ', ''),
    ) as Map<String, dynamic>;
    expect(sent['target'], {'project_id': 'p1'});
    expect((sent['priorities'] as Map)['High'], 'urgent');
    expect((sent['users'] as Map)['alice@acme.test'], 'skip');
    expect((sent['columns'] as Map)['status'], '');
    expect(sent['labels'], isFalse);
  });

  testWidgets('a new project needs a name and a key before Review', (
    tester,
  ) async {
    final o = await _open(
      tester,
      client: FakeImportsClient()
        ..proposal = ImportProposal(
          job: job('j1'),
          mapping: const ImportMapping(columns: {'title': 'Summary'}),
          analysis: jiraAnalysis,
        ),
    );
    await _toMapping(tester);
    await _tap(tester, 'map-next');
    expect(find.text('Name the new project.'), findsOneWidget);
    expect(o.client.calls.where((c) => c.startsWith('dryRun')), isEmpty);

    await tester.enterText(key('map-new-name'), 'Shop');
    await tester.enterText(key('map-new-key'), 'shp');
    await _tap(tester, 'map-next');
    expect(o.client.calls.last, contains('"key":"SHP"'));
  });

  testWidgets('a CSV must have its title column mapped', (tester) async {
    final o = await _open(
      tester,
      client: FakeImportsClient()
        ..proposal = ImportProposal(
          job: job('j1', source: 'csv'),
          mapping: const ImportMapping(newName: 'x', newKey: 'ABC'),
          analysis: jiraAnalysis,
        ),
    );
    await _tap(tester, 'source-csv');
    await _tap(tester, 'source-next');
    await _tap(tester, 'import-pick');
    await _tap(tester, 'map-next');
    expect(
      find.text('Choose the column that holds the title.'),
      findsOneWidget,
    );
    await _choose(tester, 'map-col-title', 'Summary');
    await _tap(tester, 'map-next');
    expect(o.client.calls.last, startsWith('dryRun'));
  });

  testWidgets('a refused upload is explained and the step stays', (
    tester,
  ) async {
    final o = await _open(
      tester,
      files: FakeImportFiles()
        ..failWith = const ImportException(ImportFailure.tooBig),
    );
    await _toMapping(tester);
    expect(
      find.textContaining('larger than this server accepts'),
      findsOneWidget,
    );
    expect(key('import-pick'), findsOneWidget);
    expect(o.client.calls.where((c) => c.startsWith('analyze')), isEmpty);
    await tester.tap(key('upload-back'));
    await tester.pumpAndSettle();
    expect(key('source-next'), findsOneWidget);
  });

  testWidgets('cancelling the file chooser changes nothing', (tester) async {
    final o = await _open(tester);
    await _tap(tester, 'source-next');
    final pumped = await tester.runAsync(() async => null);
    expect(pumped, isNull);
    expect(o.files.uploads, isEmpty);
  });

  testWidgets('a zip with several data files asks which one', (tester) async {
    final client = FakeImportsClient()
      ..proposal = ImportProposal(
        job: job('j1'),
        mapping: proposed(),
        analysis: jiraAnalysis,
        members: const ['A/tasks.json', 'B/tasks.json'],
      );
    await _open(tester, client: client);
    await _toMapping(tester);
    await _choose(tester, 'import-member', 'B/tasks.json');
    expect(client.calls.last, 'analyze j1  B/tasks.json');
  });

  testWidgets('the source can be corrected after the file was read', (
    tester,
  ) async {
    final client = FakeImportsClient();
    await _open(tester, client: client);
    await _toMapping(tester);
    await _choose(tester, 'import-source', 'Any CSV file');
    expect(client.calls.last, 'analyze j1 csv ');
  });

  testWidgets('progress shows while it runs, then the result', (tester) async {
    final client = FakeImportsClient()
      ..stream = [
        job('j1', status: 'running', done: 1, phase: 'tasks', version: 2),
      ];
    await _open(tester, client: client);
    await _toMapping(tester);
    await _tap(tester, 'map-next');
    await _tap(tester, 'import-start');
    expect(key('import-progress'), findsOneWidget);
    expect(find.text('1 of 4 tasks'), findsOneWidget);
    expect(key('import-cancel'), findsOneWidget);
  });

  testWidgets('cancelling stops it and a stopped import can resume', (
    tester,
  ) async {
    final client = FakeImportsClient()
      ..stream = [
        job('j1', status: 'running', done: 1, phase: 'tasks', version: 2),
      ];
    await _open(tester, client: client);
    await _toMapping(tester);
    await _tap(tester, 'map-next');
    await _tap(tester, 'import-start');
    await _tap(tester, 'import-cancel');
    expect(client.calls, contains('cancel j1'));
    expect(find.text('Import cancelled'), findsOneWidget);
    await _tap(tester, 'import-resume');
    expect(client.calls.where((c) => c.startsWith('start')).length, 2);
  });

  testWidgets('a failed import shows why and offers resume and undo', (
    tester,
  ) async {
    final client = FakeImportsClient()
      ..stream = [
        job(
          'j1',
          status: 'failed',
          error: 'The database went away.',
          stats: {'tasks': 2},
          version: 2,
        ),
      ];
    await _open(tester, client: client);
    await _toMapping(tester);
    await _tap(tester, 'map-next');
    await _tap(tester, 'import-start');
    expect(find.text('The database went away.'), findsOneWidget);
    expect(key('import-resume'), findsOneWidget);
    expect(key('import-undo'), findsOneWidget);
  });

  testWidgets('undo asks first, then says what was removed', (tester) async {
    final client = FakeImportsClient()..removed = {'tasks': 4, 'kept': 1};
    await _open(tester, client: client);
    await _toMapping(tester);
    await _tap(tester, 'map-next');
    await _tap(tester, 'import-start');
    await _tap(tester, 'import-undo');
    expect(key('undo-dialog'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(client.calls.where((c) => c.startsWith('undo')), isEmpty);

    await _tap(tester, 'import-undo');
    await tester.tap(key('undo-confirm'));
    await tester.pumpAndSettle();
    expect(client.calls, contains('undo j1'));
    expect(find.text('Import undone'), findsOneWidget);
    expect(find.textContaining('Removed 4 tasks, kept 1'), findsOneWidget);
  });

  testWidgets('the problems of an import can be opened', (tester) async {
    await _open(tester);
    await _toMapping(tester);
    await _tap(tester, 'map-next');
    await _tap(tester, 'import-start');
    await _tap(tester, 'problems-tile');
    expect(find.text('The row has no title.'), findsOneWidget);
    expect(find.text('Row 3'), findsOneWidget);
  });

  testWidgets('Review warns about duplicates, rows left out and notes', (
    tester,
  ) async {
    final client = FakeImportsClient()
      ..report = const ImportReport(
        counts: {'tasks': 4},
        alreadyImported: 3,
        errors: 1,
        warningTotal: 1,
        warnings: [
          ImportProblem(
            line: 0,
            message: 'A linked issue is missing.',
            level: 'warning',
          ),
          ImportProblem(line: 7, message: 'No title.'),
        ],
      );
    await _open(tester, client: client);
    await _toMapping(tester);
    await _tap(tester, 'map-next');
    expect(key('review-already'), findsOneWidget);
    expect(
      find.textContaining('3 of these were imported before'),
      findsOneWidget,
    );
    expect(key('review-errors'), findsOneWidget);
    await _tap(tester, 'problems-tile');
    final errorAt = tester.getTopLeft(find.text('No title.')).dy;
    final warnAt = tester
        .getTopLeft(find.text('A linked issue is missing.'))
        .dy;
    expect(errorAt, lessThan(warnAt)); // errors first
  });

  testWidgets('history lists imports, undoes one and forgets another', (
    tester,
  ) async {
    final client = FakeImportsClient(
      jobs: [
        job('a', status: 'done', filename: 'old.csv', stats: {'tasks': 9}),
        job('b', status: 'uploaded', filename: 'never.csv'),
      ],
    );
    await _open(tester, client: client);
    expect(find.text('old.csv'), findsOneWidget);
    expect(find.textContaining('9 tasks'), findsOneWidget);

    await _tap(tester, 'job-undo-a');
    expect(key('history-undo-dialog'), findsOneWidget);
    await tester.tap(key('history-undo-confirm'));
    await tester.pumpAndSettle();
    expect(client.calls, contains('undo a'));

    await _tap(tester, 'job-discard-b');
    expect(client.calls, contains('discard b'));
    expect(find.text('never.csv'), findsNothing);
  });

  testWidgets('an empty history says so, and a failed read can retry', (
    tester,
  ) async {
    final client = FakeImportsClient();
    await _open(tester, client: client);
    expect(key('history-empty'), findsOneWidget);
  });

  testWidgets('an import that was analysed can be continued from history', (
    tester,
  ) async {
    final client = FakeImportsClient(
      jobs: [job('a', status: 'analyzed', filename: 'half.csv')],
    );
    await _open(tester, client: client);
    await _tap(tester, 'job-resume-a');
    expect(client.calls, contains('get a'));
    expect(key('review-back'), findsOneWidget); // landed on Review
  });

  testWidgets('people waiting to join can be given to a member', (
    tester,
  ) async {
    final client = FakeImportsClient()
      ..waiting = [
        const WaitingPerson(
          id: 'w1',
          name: 'Bob',
          email: 'bob@old.test',
          tasks: 3,
        ),
      ];
    await _open(tester, client: client);
    expect(find.textContaining('bob@old.test · 3 tasks'), findsOneWidget);
    await _tap(tester, 'claim-w1');
    expect(key('claim-dialog'), findsOneWidget);
    await _choose(tester, 'claim-member', 'Hank Hill');
    await tester.tap(key('claim-confirm'));
    await tester.pumpAndSettle();
    expect(client.calls.any((c) => c.startsWith('claim w1')), isTrue);
    expect(find.text('Assigned 2 tasks.'), findsOneWidget);
  });

  testWidgets('a refused call is shown in a message', (tester) async {
    final client = FakeImportsClient(
      jobs: [job('b', status: 'uploaded', filename: 'never.csv')],
    );
    await _open(tester, client: client);
    client.failWith = const ImportException(
      ImportFailure.conflict,
      detail: 'Cannot now.',
    );
    await _tap(tester, 'job-discard-b');
    expect(find.text('Cannot now.'), findsOneWidget);
  });

  group('export', () {
    testWidgets('builds the zip, fetches it and saves it', (tester) async {
      final o = await _open(tester);
      await tester.tap(key('open-export'));
      await tester.pumpAndSettle();
      expect(key('export-dialog'), findsOneWidget);
      await tester.tap(key('export-go'));
      await tester.pumpAndSettle();
      expect(o.client.calls, contains('export '));
      expect(o.files.fetched.single, '/exports/download?token=t');
      expect(o.saved.single.$1, 'taskforge-all.zip');
      expect(
        find.textContaining('Saved taskforge-all.zip (2 KB)'),
        findsOneWidget,
      );
    });

    testWidgets('one project can be chosen', (tester) async {
      final o = await _open(tester);
      await tester.tap(key('open-export'));
      await tester.pumpAndSettle();
      await tester.tap(key('export-scope-project'));
      await tester.pumpAndSettle();
      await tester.tap(key('export-go'));
      await tester.pumpAndSettle();
      expect(o.client.calls, contains('export p1'));
    });

    testWidgets('a failed export is explained and nothing is saved', (
      tester,
    ) async {
      final o = await _open(
        tester,
        client: FakeImportsClient()
          ..export = const ExportJob(
            id: 'e',
            status: 'failed',
            error: 'Disk full.',
          ),
      );
      await tester.tap(key('open-export'));
      await tester.pumpAndSettle();
      await tester.tap(key('export-go'));
      await tester.pumpAndSettle();
      expect(find.text('Disk full.'), findsOneWidget);
      expect(o.saved, isEmpty);
    });

    testWidgets('an export that is still being built is waited for', (
      tester,
    ) async {
      final client = FakeImportsClient()
        ..export = const ExportJob(id: 'e', status: 'running');
      await _open(tester, client: client);
      await tester.tap(key('open-export'));
      await tester.pumpAndSettle();
      await tester.tap(key('export-go'));
      await tester.pump();
      expect(key('export-busy'), findsOneWidget);
      client.export = const ExportJob(
        id: 'e',
        status: 'done',
        filename: 'x.zip',
        downloadPath: '/p',
      );
      await tester.pump(ExportController.pollEvery);
      await tester.pumpAndSettle();
      expect(client.exportPolls, isNotEmpty);
      expect(key('export-done'), findsOneWidget);
    });
  });

  group('settings', () {
    testWidgets('an admin finds Import and export in settings', (tester) async {
      final server = FakeImportsClient();
      final pumped = await pumpProjects(
        tester,
        projects: [project('p1', 'Web')],
        overrides: [importsClientProvider.overrideWithValue(server)],
      );
      await pumped.go(tester, '/workspaces/settings');
      await tester.ensureVisible(key('open-import'));
      await tester.tap(key('open-import'));
      await tester.pumpAndSettle();
      expect(key('import-wizard'), findsOneWidget);
    });

    testWidgets('a member does not', (tester) async {
      final pumped = await pumpProjects(
        tester,
        role: 'Member',
        projects: [project('p1', 'Web')],
      );
      await pumped.go(tester, '/workspaces/settings');
      expect(key('open-import'), findsNothing);
    });
  });

  group('zips and leaving', () {
    testWidgets('a zip with several data files asks which, then goes on', (
      tester,
    ) async {
      final client = FakeImportsClient();
      final files = FakeImportFiles(
        result: const UploadResult(
          id: 'j1',
          source: 'taskforge',
          filename: 'all.zip',
          size: 9,
          members: ['SEC/tasks.json', 'WEB/tasks.json'],
        ),
      );
      await _open(tester, client: client, files: files);
      await _tap(tester, 'source-next');
      await _tap(tester, 'import-pick');
      expect(client.calls.where((c) => c.startsWith('analyze')), isEmpty);
      expect(key('upload-member'), findsOneWidget);
      await _choose(tester, 'upload-member', 'WEB/tasks.json');
      expect(client.calls.last, 'analyze j1  WEB/tasks.json');
      expect(key('import-summary'), findsOneWidget); // on the Map step
    });

    testWidgets('a zip with one obvious file goes straight on', (tester) async {
      final client = FakeImportsClient();
      final files = FakeImportFiles(
        result: const UploadResult(
          id: 'j1',
          source: 'taskforge',
          filename: 'p.zip',
          size: 9,
          member: 'tasks.json',
          members: ['tasks.json', 'tasks.csv'],
        ),
      );
      await _open(tester, client: client, files: files);
      await _tap(tester, 'source-next');
      await _tap(tester, 'import-pick');
      expect(key('upload-member'), findsNothing);
      expect(key('import-summary'), findsOneWidget);
    });

    testWidgets('leaving the screen during an upload throws nothing', (
      tester,
    ) async {
      final files = FakeImportFiles()..hold = Completer<void>();
      await _open(tester, files: files);
      await _tap(tester, 'source-next');
      await tester.tap(key('import-pick'));
      await tester.pump();
      expect(key('import-busy'), findsOneWidget);
      final scaffold = tester.element(find.byType(Scaffold).first);
      GoRouter.of(scaffold).go('/projects');
      await tester.pumpAndSettle();
      files.hold!.complete();
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('a failed save is shown and the dialog stays usable', (
      tester,
    ) async {
      final saved = <String>[];
      final pumped = await pumpProjects(
        tester,
        projects: [project('p1', 'Web')],
        overrides: [
          importsClientProvider.overrideWithValue(FakeImportsClient()),
          importFilesProvider.overrideWithValue(FakeImportFiles()),
          exportSaverProvider.overrideWithValue((n, b) async {
            saved.add(n);
            throw StateError('disk full');
          }),
        ],
      );
      await pumped.go(tester, '/import');
      await tester.tap(key('open-export'));
      await tester.pumpAndSettle();
      await tester.tap(key('export-go'));
      await tester.pumpAndSettle();
      expect(key('export-save-error'), findsOneWidget);
      expect(key('export-done'), findsNothing);
      expect(saved, ['taskforge-all.zip']);
      expect(tester.takeException(), isNull);
    });
  });
}
