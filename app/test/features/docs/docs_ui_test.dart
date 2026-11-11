import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskforge/features/docs/application/docs_providers.dart';
import 'package:taskforge/features/docs/domain/doc_blocks.dart';
import 'package:taskforge/features/docs/domain/docs.dart';
import 'package:taskforge/features/docs/presentation/related_docs_panel.dart';
import 'package:taskforge/features/search/application/search_providers.dart';
import 'package:taskforge/features/workspaces/application/workspace_providers.dart';
import 'package:taskforge/features/search/domain/search.dart';

import '../projects/projects_test_support.dart';
import '../search/fakes.dart';
import 'fakes.dart';

Finder key(String k) => find.byKey(Key(k));

const taskId = '123e4567-e89b-12d3-a456-426614174000';

FakeDocsClient workspace() => FakeDocsClient(
  nodes: [
    node('a', 'Handbook'),
    node('a1', 'Setup', parent: 'a'),
    node('a2', 'Rules', parent: 'a'),
    node('b', 'Notes'),
  ],
  bodies: {
    'a': [heading('h1', 'Welcome'), para('p1', 'First line')],
    'b': [para('pb', 'Scratch')],
  },
);

Future<Pumped> open(
  WidgetTester tester,
  FakeDocsClient docs, {
  String location = '/docs/a',
  String role = 'Owner',
  Size size = const Size(1400, 1000),
  FakeSearchClient? search,
}) async {
  final pumped = await pumpProjects(
    tester,
    role: role,
    size: size,
    docs: docs,
    overrides: [
      if (search != null) searchClientProvider.overrideWithValue(search),
    ],
  );
  await pumped.go(tester, location);
  await tester.pumpAndSettle();
  return pumped;
}

Future<void> typeIn(WidgetTester tester, String k, String text) async {
  await tester.tap(key(k));
  await tester.pump();
  await tester.enterText(key(k), text);
  await tester.pump();
}

void main() {
  testWidgets('words typed while a quiet reload runs are kept', (tester) async {
    final docs = workspace();
    final pumped = await open(tester, docs);

    docs.holdGet = Completer<void>();
    pumped.container.read(docSessionProvider('a').notifier).remoteSaved(5);
    await tester.pump();
    await typeIn(tester, 'field-p1', 'typed meanwhile');
    docs.holdGet!.complete();
    await tester.pump();
    docs.holdGet = null;
    await tester.pump();

    expect(find.text('typed meanwhile'), findsOneWidget);
    expect(
      pumped.container.read(docSessionProvider('a')).blocks[1].plain,
      'typed meanwhile',
    );
    await tester.pump(const Duration(seconds: 2));
    await tester.pump();
  });

  testWidgets('the tree shows nested pages and opens one', (tester) async {
    await open(tester, workspace(), location: '/docs');

    expect(key('page-row-a'), findsOneWidget);
    expect(key('page-row-a1'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('Setup')).dx,
      greaterThan(tester.getTopLeft(find.text('Handbook')).dx),
    );
    expect(key('no-page-open'), findsOneWidget);

    await tester.tap(key('page-row-b'));
    await tester.pumpAndSettle();

    expect(find.text('Scratch'), findsOneWidget);
    expect(key('breadcrumb'), findsOneWidget);
  });

  testWidgets('a page can be collapsed, created, nudged and archived', (
    tester,
  ) async {
    final docs = workspace();
    await open(tester, docs, location: '/docs');

    await tester.tap(key('toggle-a'));
    await tester.pump();
    expect(key('page-row-a1'), findsNothing);
    await tester.tap(key('toggle-a'));
    await tester.pump();

    await tester.tap(key('new-page'));
    await tester.pumpAndSettle();
    expect(docs.calls, contains('create:'));
    expect(key('doc-title'), findsOneWidget);

    await tester.tap(key('page-menu-a2'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Move up'));
    await tester.pumpAndSettle();
    expect(docs.calls, contains('move:a2>a@0'));

    await tester.tap(key('page-menu-b'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Archive'));
    await tester.pumpAndSettle();
    expect(docs.calls, contains('archive:b'));
    expect(key('page-row-b'), findsNothing);
  });

  testWidgets('dragging a page onto another nests it', (tester) async {
    final docs = workspace();
    await open(tester, docs, location: '/docs');

    final g = await tester.startGesture(tester.getCenter(key('page-row-b')));
    await tester.pump(kLongPressTimeout + const Duration(milliseconds: 50));
    await g.moveTo(tester.getCenter(key('page-row-a')));
    await tester.pump();
    await g.up();
    await tester.pumpAndSettle();

    expect(docs.calls, contains('move:b>a@2'));
  });

  testWidgets('moving to a page can be chosen from a list', (tester) async {
    final docs = workspace();
    await open(tester, docs, location: '/docs');

    await tester.tap(key('page-menu-b'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Move to...'));
    await tester.pumpAndSettle();
    await tester.tap(key('move-to-a1'));
    await tester.pumpAndSettle();

    expect(docs.calls, contains('move:b>a1@0'));
  });

  testWidgets('typing saves by itself after the delay and says so', (
    tester,
  ) async {
    final docs = workspace();
    await open(tester, docs);

    expect(find.text('Saved'), findsOneWidget);
    await typeIn(tester, 'field-p1', 'First line, edited');
    expect(find.text('Unsaved changes'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1000));
    expect(docs.updates, isEmpty);
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pump();

    expect(docs.updates.single.fields, ['blocks']);
    expect(docs.updates.single.expected, 1);
    expect(docs.bodies['a']![1].plain, 'First line, edited');
    expect(find.text('Saved'), findsOneWidget);
  });

  testWidgets('keystrokes inside the delay make one save', (tester) async {
    final docs = workspace();
    await open(tester, docs);

    await typeIn(tester, 'field-p1', 'one');
    await tester.pump(const Duration(milliseconds: 1000));
    await tester.enterText(key('field-p1'), 'one two');
    await tester.pump(const Duration(milliseconds: 1000));
    expect(docs.updates, isEmpty);
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pump();

    expect(docs.updates, hasLength(1));
    expect(docs.updates.single.blocks[1].plain, 'one two');
  });

  testWidgets('a failed save says so and Retry saves again', (tester) async {
    final docs = workspace();
    await open(tester, docs);

    await typeIn(tester, 'field-p1', 'x');
    docs.failNext = const DocException(DocFailure.network);
    await tester.pump(const Duration(milliseconds: 1600));
    await tester.pump();

    expect(find.text('Could not save'), findsOneWidget);
    await tester.tap(key('retry-save'));
    await tester.pump();
    await tester.pump();

    expect(find.text('Saved'), findsOneWidget);
  });

  testWidgets('the title saves too', (tester) async {
    final docs = workspace();
    await open(tester, docs);

    await typeIn(tester, 'doc-title', 'Renamed');
    await tester.pump(const Duration(milliseconds: 1600));
    await tester.pump();

    expect(docs.updates.single.fields, ['title']);
    expect(docs.updates.single.title, 'Renamed');
  });

  testWidgets('Enter splits a block and the slash menu changes its type', (
    tester,
  ) async {
    final docs = workspace();
    await open(tester, docs);

    await tester.tap(key('field-p1'));
    await tester.pump();
    await tester.enterText(key('field-p1'), 'First\n line');
    await tester.pump();
    await tester.pump();
    expect(find.byType(TextField), findsWidgets);
    final fields = tester.widgetList<TextField>(find.byType(TextField));
    expect(
      fields.map((f) => f.controller?.text),
      containsAll(['First', ' line']),
    );

    await tester.tap(key('add-block'));
    await tester.pump();
    await tester.pump();
    final last =
        tester.widgetList<TextField>(find.byType(TextField)).last.key!
            as ValueKey<String>;
    await tester.enterText(find.byKey(last), '/quo');
    await tester.pump();
    expect(key('slash-menu'), findsOneWidget);
    await tester.tap(key('slash-quote'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1600));
    await tester.pump();

    expect(docs.bodies['a']!.last.type, 'quote');
  });

  testWidgets('the floating toolbar bolds the selection', (tester) async {
    final docs = workspace();
    await open(tester, docs);

    await tester.tap(key('field-p1'));
    await tester.pump();
    final field = tester.widget<TextField>(key('field-p1'));
    field.controller!.selection = const TextSelection(
      baseOffset: 0,
      extentOffset: 5,
    );
    await tester.pump();
    expect(key('floating-toolbar'), findsOneWidget);

    await tester.tap(key('tb-bold'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1600));
    await tester.pump();

    final content = docs.bodies['a']![1].json['content']! as List;
    expect((content.first as Map)['marks'], [
      {'type': 'bold'},
    ]);
    expect((content.first as Map)['text'], 'First');
  });

  testWidgets('/task embeds a card that shows live status', (tester) async {
    final docs = workspace()
      ..cards[taskId] = const TaskCardInfo(
        taskId: taskId,
        projectId: 'p1',
        key: 'WEB-1',
        title: 'Fix login',
        statusName: 'To do',
        statusCategory: 'todo',
      );
    final search = FakeSearchClient(
      answer: (text, types, cursor) => SearchResults(
        hits: {
          SearchKind.task: [
            SearchHit(
              kind: SearchKind.task,
              id: taskId,
              title: 'Fix login',
              taskId: taskId,
              projectId: 'p1',
              key: 'WEB-1',
            ),
          ],
        },
      ),
    );
    final pumped = await open(tester, docs, search: search);

    await tester.tap(key('add-block'));
    await tester.pump();
    await tester.pump();
    final last =
        tester.widgetList<TextField>(find.byType(TextField)).last.key!
            as ValueKey<String>;
    await tester.enterText(find.byKey(last), '/task');
    await tester.pump();
    await tester.tap(key('slash-task'));
    await tester.pumpAndSettle();
    await tester.enterText(key('task-picker-field'), 'login');
    await tester.pumpAndSettle();
    await tester.tap(key('task-hit-$taskId'));
    await tester.pumpAndSettle();

    expect(key('task-card-$taskId'), findsOneWidget);
    expect(find.text('To do'), findsOneWidget);

    // The task moves on: the realtime event makes the card read again.
    docs.cards[taskId] = const TaskCardInfo(
      taskId: taskId,
      projectId: 'p1',
      key: 'WEB-1',
      title: 'Fix login',
      statusName: 'Done',
      statusCategory: 'done',
    );
    pumped.container.invalidate(docCardsProvider);
    await tester.pumpAndSettle();

    expect(find.text('Done'), findsOneWidget);
    await tester.pump(const Duration(seconds: 2));
  });

  testWidgets('a task the viewer cannot open is a no-access placeholder', (
    tester,
  ) async {
    final docs = workspace();
    docs.bodies['a'] = [taskCard('c1', 'hidden-task'), para('p1', 'x')];
    await open(tester, docs);

    expect(key('task-card-hidden-hidden-task'), findsOneWidget);
    expect(find.text('No access to this task'), findsOneWidget);
  });

  testWidgets('[[ offers pages and inserts a mention', (tester) async {
    final docs = workspace();
    await open(tester, docs);

    await tester.tap(key('field-p1'));
    await tester.pump();
    await tester.enterText(key('field-p1'), 'See [[No');
    await tester.pump();
    expect(key('page-picker'), findsOneWidget);
    await tester.tap(key('pick-page-b'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1600));
    await tester.pump();

    final content = docs.bodies['a']![1].json['content']! as List;
    expect(
      content.whereType<Map>().any(
        (n) => n['type'] == 'mention' && (n['attrs'] as Map)['doc_id'] == 'b',
      ),
      isTrue,
    );
    expect(key('mention-b'), findsOneWidget);
  });

  testWidgets('a conflict opens the merge dialog; applying saves the merge', (
    tester,
  ) async {
    final docs = workspace();
    await open(tester, docs);

    await typeIn(tester, 'field-p1', 'mine');
    // Meanwhile somebody changed the same block and added another.
    docs.externalSave('a', [
      heading('h1', 'Welcome'),
      para('p1', 'theirs'),
      para('p2', 'extra'),
    ]);
    await tester.pump(const Duration(milliseconds: 1600));
    await tester.pumpAndSettle();

    expect(key('conflict-dialog'), findsOneWidget);
    expect(key('conflict-banner'), findsOneWidget);

    await tester.tap(key('conflict-theirs-p1'));
    await tester.pump();
    await tester.tap(key('conflict-apply'));
    await tester.pumpAndSettle();

    expect(docs.updates.last.expected, 2);
    expect(docs.bodies['a']!.map((b) => b.plain), [
      'Welcome',
      'theirs',
      'extra',
    ]);
    expect(find.text('Saved'), findsOneWidget);
  });

  testWidgets('a conflict whose blocks were left out is fetched with Get', (
    tester,
  ) async {
    final docs = workspace()..omitConflictBlocks = true;
    await open(tester, docs);

    await typeIn(tester, 'field-p1', 'mine');
    docs.externalSave('a', [
      heading('h1', 'Welcome'),
      para('p1', 'First line'),
      para('p2', 'x'),
    ]);
    final before = docs.calls.where((c) => c == 'get:a').length;
    await tester.pump(const Duration(milliseconds: 1600));
    await tester.pumpAndSettle();

    expect(docs.calls.where((c) => c == 'get:a').length, before + 1);
    expect(key('conflict-dialog'), findsOneWidget);
    // Nothing overlaps: it says the changes merge by themselves.
    expect(find.textContaining('will be merged'), findsOneWidget);

    await tester.tap(key('conflict-apply'));
    await tester.pumpAndSettle();
    expect(docs.bodies['a']!.map((b) => b.plain), ['Welcome', 'mine', 'x']);
  });

  testWidgets('discarding my changes shows the server page', (tester) async {
    final docs = workspace();
    await open(tester, docs);

    await typeIn(tester, 'field-p1', 'mine');
    docs.externalSave('a', [heading('h1', 'Welcome'), para('p1', 'theirs')]);
    await tester.pump(const Duration(milliseconds: 1600));
    await tester.pumpAndSettle();
    await tester.tap(key('conflict-take-theirs'));
    await tester.pumpAndSettle();

    expect(find.text('theirs'), findsOneWidget);
    expect(find.text('Saved'), findsOneWidget);
  });

  testWidgets('the history drawer previews a revision and restores it', (
    tester,
  ) async {
    final docs = workspace();
    docs.revisionList['a'] = [
      (
        info: const RevisionInfo(id: 11, version: 1, title: 'Handbook'),
        blocks: [para('p1', 'The old text')],
      ),
    ];
    await open(tester, docs);

    await tester.tap(key('open-revisions'));
    await tester.pumpAndSettle();
    await tester.tap(key('revision-11'));
    await tester.pumpAndSettle();
    expect(find.text('The old text'), findsOneWidget);

    await tester.tap(key('revision-restore'));
    await tester.pumpAndSettle();

    expect(docs.calls, contains('restoreRevision:11@1'));
    expect(docs.bodies['a']!.single.plain, 'The old text');
    expect(find.text('The old text'), findsWidgets);
  });

  testWidgets('the restrict dialog sends the switch and the people', (
    tester,
  ) async {
    final docs = workspace();
    await open(tester, docs);

    await tester.tap(key('open-share'));
    await tester.pumpAndSettle();
    await tester.tap(key('share-restricted'));
    await tester.pumpAndSettle();
    final box = find.byType(CheckboxListTile);
    expect(box, findsWidgets);
    await tester.tap(box.first);
    await tester.pump();
    await tester.tap(key('share-save'));
    await tester.pumpAndSettle();

    final call = docs.calls.firstWhere((c) => c.startsWith('access:a:true'));
    expect(call.split(':').last, isNotEmpty);
    expect(key('restricted-badge'), findsOneWidget);
  });

  testWidgets('without doc.manage the restrict dialog only reads', (
    tester,
  ) async {
    final docs = workspace()..defaultCanManage = false;
    await open(tester, docs);

    await tester.tap(key('open-share'));
    await tester.pumpAndSettle();

    expect(key('share-save'), findsNothing);
    expect(find.textContaining('doc.manage'), findsOneWidget);
  });

  testWidgets('a page without edit rights is read-only', (tester) async {
    final docs = workspace()..canEdit['a'] = false;
    await open(tester, docs, role: 'Viewer');

    expect(key('read-only-badge'), findsOneWidget);
    expect(tester.widget<TextField>(key('field-p1')).readOnly, isTrue);
    expect(tester.widget<TextField>(key('doc-title')).readOnly, isTrue);
    expect(key('add-block'), findsNothing);
    expect(key('new-page'), findsNothing);
    expect(key('open-revisions'), findsOneWidget);
  });

  testWidgets('an archived page is read-only and can be restored', (
    tester,
  ) async {
    final docs = FakeDocsClient(
      nodes: [node('z', 'Old', archived: true)],
      bodies: {
        'z': [para('p', 'gone')],
      },
    );
    await open(tester, docs, location: '/docs/z');

    expect(key('archived-banner'), findsOneWidget);
    expect(tester.widget<TextField>(key('field-p')).readOnly, isTrue);

    await tester.tap(key('restore-page'));
    await tester.pumpAndSettle();

    expect(docs.calls, contains('restore:z'));
    expect(key('archived-banner'), findsNothing);
  });

  testWidgets('a page that is not there says so', (tester) async {
    await open(tester, workspace(), location: '/docs/nope');

    expect(key('doc-not-found'), findsOneWidget);
  });

  testWidgets('who else is editing shows as a hint', (tester) async {
    final docs = workspace()
      ..editing['a'] = [const DocEditor(userId: 'u2', editing: true)];
    await open(tester, docs);

    expect(key('editing-hint'), findsOneWidget);
    expect(find.textContaining('is editing'), findsOneWidget);
    expect(docs.presenceCalls, contains('a:viewing'));
  });

  testWidgets('the Markdown export can be copied', (tester) async {
    final copied = <String>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          copied.add((call.arguments as Map)['text'] as String);
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    await open(tester, workspace());

    await tester.tap(key('export-md'));
    await tester.pumpAndSettle();

    expect(find.textContaining('# Handbook'), findsOneWidget);
    await tester.tap(key('export-copy'));
    await tester.pump();
    await tester.pump();
    expect(find.text('Markdown copied.'), findsOneWidget);
    expect(copied.single, startsWith('# Handbook'));
  });

  testWidgets('backlinks list the pages that mention this one', (tester) async {
    final docs = workspace()..backlinkMap['a'] = [node('b', 'Notes')];
    await open(tester, docs);

    await tester.tap(key('backlinks-panel'));
    await tester.pumpAndSettle();

    expect(key('backlink-b'), findsOneWidget);
  });

  testWidgets('an unknown block shows a placeholder and is saved untouched', (
    tester,
  ) async {
    final docs = workspace();
    final odd = DocBlock({
      'id': 'u',
      'type': 'whiteboard',
      'z': [1],
    });
    docs.bodies['a'] = [para('p1', 'x'), odd];
    await open(tester, docs);

    expect(key('unknown-u'), findsOneWidget);
    await typeIn(tester, 'field-p1', 'xy');
    await tester.pump(const Duration(milliseconds: 1600));
    await tester.pump();

    expect(docs.bodies['a']!.last.json, odd.json);
  });

  testWidgets('on a phone the tree is a drawer', (tester) async {
    await open(tester, workspace(), size: const Size(420, 900));

    expect(key('page-tree'), findsNothing);
    await tester.tap(key('open-page-tree'));
    await tester.pumpAndSettle();
    expect(key('tree-drawer'), findsOneWidget);
    await tester.tap(key('page-row-b'));
    await tester.pumpAndSettle();

    expect(find.text('Scratch'), findsOneWidget);
  });

  testWidgets('on a phone with no page open the tree fills the screen', (
    tester,
  ) async {
    await open(
      tester,
      workspace(),
      location: '/docs',
      size: const Size(420, 900),
    );

    expect(key('page-tree'), findsOneWidget);
  });

  testWidgets('the sidebar has a Docs entry', (tester) async {
    await open(tester, workspace(), location: '/docs');

    expect(key('open-docs'), findsOneWidget);
  });

  testWidgets('a task related docs can be linked and unlinked', (tester) async {
    final docs = workspace();
    docs.related['t1'] = [RelatedDoc(doc: node('b', 'Notes'), kind: 'card')];
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          docsClientProvider.overrideWithValue(docs),
          workspaceScopeProvider.overrideWithValue('w1'),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: RelatedDocsPanel(
              projectId: 'p1',
              taskId: 't1',
              canEdit: true,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(key('related-doc-b'), findsOneWidget);
    expect(key('unlink-doc-b'), findsNothing);

    await tester.tap(key('add-related-doc'));
    await tester.pumpAndSettle();
    await tester.tap(key('related-pick-a'));
    await tester.pumpAndSettle();
    expect(docs.calls, contains('link:t1:a'));
    expect(key('related-doc-a'), findsOneWidget);

    await tester.tap(key('unlink-doc-a'));
    await tester.pumpAndSettle();
    expect(docs.calls, contains('unlink:t1:a'));
    expect(key('related-doc-a'), findsNothing);
  });
}
