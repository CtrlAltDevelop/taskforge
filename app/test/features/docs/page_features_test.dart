import 'package:taskforge/core/ui/page/tf_tile.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskforge/features/docs/domain/doc_blocks.dart';
import 'package:taskforge/features/docs/domain/docs.dart';

import 'docs_ui_test.dart' show key, open, taskId, typeIn, workspace;
import 'fakes.dart';

Future<void> autosave(WidgetTester tester) async {
  await tester.pump(const Duration(milliseconds: 1600));
  await tester.pump();
}

DocNode nodeOf(FakeDocsClient docs, String id) =>
    docs.nodes.firstWhere((n) => n.id == id);

void main() {
  testWidgets('the page icon can be changed, and is saved and shown', (
    tester,
  ) async {
    final docs = workspace();
    await open(tester, docs);

    await tester.tap(key('doc-icon'));
    await tester.pumpAndSettle();
    await tester.enterText(key('icon-field'), 'abcdefg');
    await tester.tap(key('icon-ok'));
    await tester.pump();
    expect(find.text('Use at most four characters.'), findsOneWidget);

    await tester.enterText(key('icon-field'), '🚀');
    await tester.tap(key('icon-ok'));
    await tester.pumpAndSettle();
    await autosave(tester);
    await tester.pumpAndSettle();

    expect(docs.updates.last.fields, contains('icon'));
    expect(docs.updates.last.icon, '🚀');
    expect(nodeOf(docs, 'a').icon, '🚀');
    // The tree row and the page header both show it.
    expect(find.text('🚀'), findsWidgets);
    await tester.pump(const Duration(seconds: 2));
  });

  testWidgets('the icon can be cleared and a viewer cannot change it', (
    tester,
  ) async {
    final docs = workspace();
    await open(tester, docs);

    await tester.tap(key('doc-icon'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(docs.updates, isEmpty);

    await tester.tap(key('doc-icon'));
    await tester.pumpAndSettle();
    await tester.enterText(key('icon-field'), '');
    await tester.tap(key('icon-ok'));
    await tester.pumpAndSettle();
    // Nothing changed (it was empty): no save of the icon.
    await autosave(tester);
    expect(docs.updates.every((u) => !u.fields.contains('icon')), isTrue);
    await tester.pump(const Duration(seconds: 2));
  });

  testWidgets('a read-only page has an icon that cannot be changed', (
    tester,
  ) async {
    final docs = workspace()..defaultCanEdit = false;
    await open(tester, docs, role: 'Viewer');

    expect(tester.widget<IconButton>(key('doc-icon')).onPressed, isNull);
  });

  testWidgets('Show archived lists archived pages and restores one', (
    tester,
  ) async {
    final docs = workspace()..nodes.add(node('z', 'Old plans', archived: true));
    await open(tester, docs, location: '/docs');

    expect(key('page-row-z'), findsNothing);
    await tester.tap(key('show-archived'));
    await tester.pumpAndSettle();
    expect(key('page-row-z'), findsOneWidget);
    expect(docs.calls.where((c) => c == 'tree:').length, greaterThan(1));

    await tester.tap(key('page-menu-z'));
    await tester.pumpAndSettle();
    expect(find.text('Archive'), findsNothing);
    await tester.tap(find.text('Restore'));
    await tester.pumpAndSettle();
    expect(docs.calls, contains('restore:z'));
    expect(nodeOf(docs, 'z').archived, isFalse);

    await tester.tap(key('show-archived'));
    await tester.pumpAndSettle();
    expect(key('page-row-z'), findsOneWidget);
    await tester.pump(const Duration(seconds: 2));
  });

  testWidgets('Show archived toggles off again', (tester) async {
    final docs = workspace()..nodes.add(node('z', 'Old plans', archived: true));
    await open(tester, docs, location: '/docs');

    await tester.tap(key('show-archived'));
    await tester.pumpAndSettle();
    await tester.tap(key('show-archived'));
    await tester.pumpAndSettle();

    expect(key('page-row-z'), findsNothing);
  });

  testWidgets('pasting a task link into a paragraph makes a task card', (
    tester,
  ) async {
    final docs = workspace()
      ..cards[taskId] = const TaskCardInfo(
        taskId: taskId,
        projectId: 'p1',
        key: 'WEB-1',
        title: 'Fix login',
        statusName: 'To do',
      );
    docs.bodies['a'] = [para('p1', '')];
    await open(tester, docs);

    await tester.tap(key('field-p1'));
    await tester.pump();
    // The whole link arrives in one change, as a paste does.
    await tester.enterText(
      key('field-p1'),
      'http://localhost:5173/projects/p1?task=$taskId',
    );
    await tester.pump();
    await tester.pumpAndSettle();
    await autosave(tester);

    expect(key('task-card-$taskId'), findsOneWidget);
    expect(docs.bodies['a']!.first.type, BlockType.taskCard);
    expect(docs.bodies['a']!.first.taskId, taskId);
    // A paragraph follows the card.
    expect(docs.bodies['a']!.last.type, BlockType.paragraph);
    await tester.pump(const Duration(seconds: 2));
  });

  testWidgets('a pasted bare task id in the middle of a page makes a card', (
    tester,
  ) async {
    final docs = workspace();
    docs.bodies['a'] = [para('p1', ''), para('p2', 'after')];
    await open(tester, docs);

    await tester.tap(key('field-p1'));
    await tester.pump();
    await tester.enterText(key('field-p1'), taskId.toUpperCase());
    await tester.pump();
    await tester.pumpAndSettle();
    await autosave(tester);

    expect(docs.bodies['a']!.map((b) => b.type), [
      BlockType.taskCard,
      BlockType.paragraph,
    ]);
    await tester.pump(const Duration(seconds: 2));
  });

  testWidgets('a link with other words, or typed slowly, stays text', (
    tester,
  ) async {
    final docs = workspace();
    docs.bodies['a'] = [para('p1', '')];
    await open(tester, docs);

    await typeIn(tester, 'field-p1', 'see https://x/?task=$taskId now');
    await autosave(tester);
    expect(docs.bodies['a']!.single.type, BlockType.paragraph);

    await tester.enterText(key('field-p1'), 'abc');
    await tester.pump();
    await tester.enterText(key('field-p1'), 'abc$taskId'.substring(0, 5));
    await tester.pump();
    await autosave(tester);
    expect(docs.bodies['a']!.single.type, BlockType.paragraph);
    await tester.pump(const Duration(seconds: 2));
  });

  testWidgets('the page access dialog restricts a page to people', (
    tester,
  ) async {
    final docs = workspace();
    await open(tester, docs);

    await tester.tap(key('open-share'));
    await tester.pumpAndSettle();
    await tester.tap(key('share-restricted'));
    await tester.pumpAndSettle();
    final member = find.byWidgetPredicate(
      (w) =>
          w.key is ValueKey<String> &&
          (w.key! as ValueKey<String>).value.startsWith('share-member-'),
    );
    expect(member, findsWidgets);
    await tester.tap(member.first);
    await tester.pump();
    await tester.tap(member.first);
    await tester.pump();
    await tester.tap(member.first);
    await tester.pump();

    await tester.tap(key('share-save'));
    await tester.pumpAndSettle();
    expect(docs.calls.where((c) => c.startsWith('access:a:true')), isNotEmpty);
  });

  testWidgets('the page access dialog shows a refusal', (tester) async {
    final docs = workspace();
    await open(tester, docs);

    await tester.tap(key('open-share'));
    await tester.pumpAndSettle();
    await tester.tap(key('share-restricted'));
    await tester.pumpAndSettle();
    docs.failNext = const DocException(DocFailure.denied);
    await tester.tap(key('share-save'));
    await tester.pumpAndSettle();

    expect(key('share-error'), findsOneWidget);
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();
    expect(key('share-dialog'), findsNothing);
  });

  testWidgets('without page management the access dialog is read-only', (
    tester,
  ) async {
    final docs = workspace()..defaultCanManage = false;
    await open(tester, docs);

    await tester.tap(key('open-share'));
    await tester.pumpAndSettle();

    expect(key('share-save'), findsNothing);
    expect(find.textContaining('doc.manage'), findsOneWidget);
    expect(
      tester.widget<TfToggleTile>(key('share-restricted')).onChanged,
      isNull,
    );
  });

  testWidgets('the conflict dialog can be postponed and reopened', (
    tester,
  ) async {
    final docs = workspace();
    await open(tester, docs);

    await typeIn(tester, 'field-p1', 'mine');
    docs.externalSave('a', [heading('h1', 'Welcome'), para('p1', 'theirs')]);
    await tester.pump(const Duration(milliseconds: 1600));
    await tester.pumpAndSettle();
    expect(key('conflict-dialog'), findsOneWidget);

    await tester.tap(key('conflict-later'));
    await tester.pumpAndSettle();
    expect(key('conflict-dialog'), findsNothing);
    expect(key('conflict-banner'), findsOneWidget);

    await tester.tap(key('open-conflict'));
    await tester.pumpAndSettle();
    expect(key('conflict-mine-p1'), findsOneWidget);
    await tester.tap(key('conflict-mine-p1'));
    await tester.pump();
    await tester.tap(key('conflict-apply'));
    await tester.pumpAndSettle();

    expect(docs.bodies['a']![1].plain, 'mine');
    await tester.pump(const Duration(seconds: 2));
  });
}
