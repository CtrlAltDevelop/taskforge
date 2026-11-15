import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskforge/features/docs/domain/doc_blocks.dart';
import 'package:taskforge/features/docs/domain/docs.dart';

import 'docs_ui_test.dart' show key, open, taskId, typeIn, workspace;
import 'fakes.dart';

/// A workspace whose page `a` holds just [blocks].
FakeDocsClient withBlocks(List<DocBlock> blocks) {
  final docs = workspace();
  docs.bodies['a'] = [...blocks];
  return docs;
}

/// Lets the autosave run and finish.
Future<void> autosave(WidgetTester tester) async {
  await tester.pump(const Duration(milliseconds: 1600));
  await tester.pump();
}

DocBlock saved(FakeDocsClient docs, String id) =>
    docs.bodies['a']!.firstWhere((b) => b.id == id);

TextEditingController controllerOf(WidgetTester tester, String k) =>
    tester.widget<TextField>(key(k)).controller!;

void main() {
  testWidgets('a code block shows its text and saves edits and language', (
    tester,
  ) async {
    final docs = withBlocks([
      DocBlock.create(BlockType.code, id: 'c1').withCodeText('print(1)'),
    ]);
    await open(tester, docs);

    expect(find.text('print(1)'), findsOneWidget);
    await typeIn(tester, 'field-c1', 'print(2)');
    await typeIn(tester, 'lang-c1', 'python');
    await autosave(tester);

    expect(saved(docs, 'c1').codeText, 'print(2)');
    expect(saved(docs, 'c1').language, 'python');
  });

  testWidgets('a table is edited cell by cell and by rows and columns', (
    tester,
  ) async {
    final docs = withBlocks([DocBlock.create(BlockType.table, id: 't1')]);
    await open(tester, docs);

    expect(key('table-t1'), findsOneWidget);
    await typeIn(tester, 'cell-t1-0-0', 'Name');
    await typeIn(tester, 'cell-t1-1-1', 'Ada');
    await tester.tap(key('table-add-row-t1'));
    await tester.pump();
    await tester.tap(key('table-add-column-t1'));
    await tester.pump();
    await autosave(tester);

    var rows = saved(docs, 't1').rows;
    expect((rows.length, rows.first.length), (3, 3));
    expect((rows[0][0].text, rows[1][1].text), ('Name', 'Ada'));
    expect(rows[2].every((c) => c.text.isEmpty), isTrue);

    await tester.tap(key('table-remove-row-t1'));
    await tester.pump();
    await tester.tap(key('table-remove-column-t1'));
    await tester.pump();
    await autosave(tester);

    rows = saved(docs, 't1').rows;
    expect((rows.length, rows.first.length), (2, 2));
    expect(rows[1][1].text, 'Ada');
  });

  testWidgets('a one-cell table cannot lose its last row or column', (
    tester,
  ) async {
    final docs = withBlocks([
      DocBlock.create(BlockType.table, id: 't1').withRows([
        [Rich.plain('only')],
      ]),
    ]);
    await open(tester, docs);

    expect(
      tester.widget<TextButton>(key('table-remove-row-t1')).onPressed,
      isNull,
    );
    expect(
      tester.widget<TextButton>(key('table-remove-column-t1')).onPressed,
      isNull,
    );
    expect(find.text('only'), findsOneWidget);
  });

  testWidgets('a ragged table is padded when a row is added', (tester) async {
    final docs = withBlocks([
      DocBlock.create(BlockType.table, id: 't1').withRows([
        [Rich.plain('a'), Rich.plain('b')],
        [Rich.plain('c')],
      ]),
    ]);
    await open(tester, docs);

    await tester.tap(key('table-add-row-t1'));
    await tester.pump();
    await autosave(tester);

    final rows = saved(docs, 't1').rows;
    expect(rows.map((r) => r.length), [2, 2, 2]);
  });

  testWidgets('a read-only table has no edit buttons', (tester) async {
    final docs = withBlocks([DocBlock.create(BlockType.table, id: 't1')])
      ..defaultCanEdit = false;
    await open(tester, docs, role: 'Viewer');

    expect(key('table-t1'), findsOneWidget);
    expect(key('table-add-row-t1'), findsNothing);
  });

  testWidgets('a callout changes tone and keeps its text', (tester) async {
    final docs = withBlocks([
      DocBlock.create(
        BlockType.callout,
        id: 'k1',
      ).withRich(Rich.plain('Careful')),
    ]);
    await open(tester, docs);

    expect(key('callout-k1'), findsOneWidget);
    for (final tone in ['warning', 'success', 'danger', 'info']) {
      await tester.tap(key('callout-tone-k1'));
      await tester.pump();
      await autosave(tester);
      expect(saved(docs, 'k1').tone, tone);
    }
    expect(saved(docs, 'k1').plain, 'Careful');
  });

  testWidgets('a read-only callout cannot change tone', (tester) async {
    final docs = withBlocks([DocBlock.create(BlockType.callout, id: 'k1')])
      ..defaultCanEdit = false;
    await open(tester, docs, role: 'Viewer');

    expect(tester.widget<IconButton>(key('callout-tone-k1')).onPressed, isNull);
  });

  testWidgets('dividers and quotes render and a quote is editable', (
    tester,
  ) async {
    final docs = withBlocks([
      DocBlock.create(BlockType.quote, id: 'q1').withRich(Rich.plain('Wise')),
      DocBlock.create(BlockType.divider, id: 'd1'),
    ]);
    await open(tester, docs);

    expect(key('divider-block'), findsOneWidget);
    expect(find.text('Wise'), findsOneWidget);
    await typeIn(tester, 'field-q1', 'Wiser');
    await autosave(tester);

    expect(saved(docs, 'q1').plain, 'Wiser');
    expect(saved(docs, 'd1').type, BlockType.divider);
  });

  testWidgets('an image without an address says so and takes one', (
    tester,
  ) async {
    final docs = withBlocks([DocBlock.create(BlockType.image, id: 'i1')]);
    await open(tester, docs);

    expect(key('image-empty'), findsOneWidget);
    await tester.tap(key('edit-image-i1'));
    await tester.pumpAndSettle();

    // A bad address is refused in the dialog.
    await tester.enterText(key('image-src'), 'ftp://nope');
    await tester.tap(key('image-ok'));
    await tester.pump();
    expect(find.text('Use an http or https address.'), findsOneWidget);

    await tester.enterText(key('image-src'), 'https://example.com/cat.png');
    await tester.enterText(key('image-alt'), 'A cat');
    await tester.tap(key('image-ok'));
    await tester.pumpAndSettle();
    await autosave(tester);

    expect(saved(docs, 'i1').src, 'https://example.com/cat.png');
    expect(saved(docs, 'i1').alt, 'A cat');
    // The test environment cannot load it: the description stands in.
    expect(find.text('A cat'), findsWidgets);
  });

  testWidgets('cancelling the image dialog keeps the block as it was', (
    tester,
  ) async {
    final docs = withBlocks([DocBlock.create(BlockType.image, id: 'i1')]);
    await open(tester, docs);

    await tester.tap(key('edit-image-i1'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(key('image-empty'), findsOneWidget);
    expect(docs.updates, isEmpty);
  });

  testWidgets('a read-only image has no edit button', (tester) async {
    final docs = withBlocks([
      DocBlock.create(
        BlockType.image,
        id: 'i1',
      ).withAttrs({'src': 'https://example.com/a.png'}),
    ])..defaultCanEdit = false;
    await open(tester, docs, role: 'Viewer');
    await tester.pump();

    expect(key('edit-image-i1'), findsNothing);
    expect(key('image-broken'), findsOneWidget);
    expect(find.text('Image could not load'), findsOneWidget);
  });

  testWidgets('a block of an unknown kind is kept and shown as a placeholder', (
    tester,
  ) async {
    final docs = withBlocks([
      const DocBlock({'id': 'u1', 'type': 'whiteboard', 'k': 1}),
      para('p1', 'x'),
    ]);
    await open(tester, docs);

    expect(key('unknown-u1'), findsOneWidget);
    await typeIn(tester, 'field-p1', 'y');
    await autosave(tester);
    expect(saved(docs, 'u1').json['k'], 1);
  });

  testWidgets('the block menu moves, adds below and deletes blocks', (
    tester,
  ) async {
    final docs = withBlocks([para('p1', 'one'), para('p2', 'two')]);
    await open(tester, docs);

    Future<void> choose(String block, String label) async {
      await tester.tap(key('block-menu-$block'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(label));
      await tester.pumpAndSettle();
    }

    await choose('p1', 'Move down');
    await autosave(tester);
    expect(docs.bodies['a']!.map((b) => b.id), ['p2', 'p1']);

    await choose('p1', 'Move up');
    await choose('p2', 'Add block below');
    await autosave(tester);
    expect(docs.bodies['a']!.length, 3);

    await choose('p2', 'Delete');
    await autosave(tester);
    expect(docs.bodies['a']!.map((b) => b.id), isNot(contains('p2')));
  });

  testWidgets('the block menu turns a block into another kind', (tester) async {
    final docs = withBlocks([para('p1', 'one')]);
    await open(tester, docs);

    await tester.tap(key('block-menu-p1'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Turn into Heading 2'));
    await tester.pumpAndSettle();
    await autosave(tester);

    expect(saved(docs, 'p1').type, BlockType.heading);
    expect(saved(docs, 'p1').level, 2);
    expect(saved(docs, 'p1').plain, 'one');
  });

  testWidgets('turning a block into an image asks for it; cancel keeps it', (
    tester,
  ) async {
    final docs = withBlocks([para('p1', '')]);
    await open(tester, docs);

    await tester.tap(key('block-menu-p1'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Turn into Image'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(key('image-empty'), findsNothing);

    await tester.tap(key('block-menu-p1'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Turn into Image'));
    await tester.pumpAndSettle();
    await tester.enterText(key('image-src'), 'https://example.com/b.png');
    await tester.tap(key('image-ok'));
    await tester.pumpAndSettle();
    await autosave(tester);

    expect(saved(docs, 'p1').type, BlockType.image);
    // A paragraph follows so the page can go on.
    expect(docs.bodies['a']!.last.type, BlockType.paragraph);
  });

  testWidgets('turning a block into a task card picks a task or cancels', (
    tester,
  ) async {
    final docs = withBlocks([para('p1', '')])
      ..cards[taskId] = const TaskCardInfo(
        taskId: taskId,
        projectId: 'p1',
        key: 'WEB-1',
        title: 'Fix login',
        statusName: 'To do',
      );
    await open(tester, docs);

    await tester.tap(key('block-menu-p1'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Turn into Task card'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(key('task-card-$taskId'), findsNothing);

    await tester.tap(key('block-menu-p1'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Turn into Task card'));
    await tester.pumpAndSettle();
    await tester.enterText(key('task-picker-field'), 'https://x/?task=$taskId');
    await tester.pump();
    await tester.tap(key('task-use-pasted'));
    await tester.pumpAndSettle();
    await autosave(tester);

    expect(key('task-card-$taskId'), findsOneWidget);
    expect(saved(docs, 'p1').taskId, taskId);
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 30));
  });

  testWidgets('a clicked empty page starts with a paragraph', (tester) async {
    final docs = withBlocks(const []);
    await open(tester, docs);

    await tester.tap(key('empty-page'));
    await tester.pump();
    await tester.pump();
    expect(find.byType(TextField), findsWidgets);
    await tester.tap(key('add-block'));
    await tester.pump();
    await autosave(tester);

    expect(docs.bodies['a']!.length, 2);
  });

  testWidgets('a read-only page offers no editing', (tester) async {
    final docs = withBlocks([para('p1', 'one')])..defaultCanEdit = false;
    await open(tester, docs, role: 'Viewer');

    expect(key('block-menu-p1'), findsNothing);
    expect(key('add-block'), findsNothing);
    expect(tester.widget<TextField>(key('field-p1')).readOnly, isTrue);
  });

  testWidgets('a checklist item can be ticked and indented with Tab', (
    tester,
  ) async {
    final docs = withBlocks([
      DocBlock.create(BlockType.checklist, id: 'c1').withRich(Rich.plain('do')),
      DocBlock.create(BlockType.numbered, id: 'n1').withRich(Rich.plain('a')),
      DocBlock.create(BlockType.numbered, id: 'n2').withRich(Rich.plain('b')),
      DocBlock.create(BlockType.bullet, id: 'b1').withRich(Rich.plain('c')),
    ]);
    await open(tester, docs);

    expect(find.text('2.'), findsOneWidget);
    await tester.tap(key('check-c1'));
    await tester.pump();
    await tester.tap(key('field-n1'));
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    await autosave(tester);

    expect(saved(docs, 'c1').checked, isTrue);
    expect(saved(docs, 'n1').indent, 1);
  });

  testWidgets('Backspace at the start joins a block to the one above', (
    tester,
  ) async {
    final docs = withBlocks([para('p1', 'one'), para('p2', 'two')]);
    await open(tester, docs);

    await tester.tap(key('field-p2'));
    await tester.pump();
    controllerOf(tester, 'field-p2').selection = const TextSelection.collapsed(
      offset: 0,
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.backspace);
    await tester.pump();
    await tester.pump();
    await autosave(tester);

    expect(docs.bodies['a']!.map((b) => b.plain), ['onetwo']);
  });

  testWidgets('arrow keys move between blocks at the edges', (tester) async {
    final docs = withBlocks([para('p1', 'one'), para('p2', 'two')]);
    await open(tester, docs);

    await tester.tap(key('field-p1'));
    await tester.pump();
    controllerOf(tester, 'field-p1').selection = const TextSelection.collapsed(
      offset: 3,
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    expect(
      tester.widget<TextField>(key('field-p2')).focusNode!.hasFocus,
      isTrue,
    );

    controllerOf(tester, 'field-p2').selection = const TextSelection.collapsed(
      offset: 0,
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
    await tester.pump();
    expect(
      tester.widget<TextField>(key('field-p1')).focusNode!.hasFocus,
      isTrue,
    );
  });

  testWidgets('a Markdown shortcut turns the paragraph into a bullet', (
    tester,
  ) async {
    final docs = withBlocks([para('p1', '')]);
    await open(tester, docs);

    await typeIn(tester, 'field-p1', '- ');
    await autosave(tester);

    expect(saved(docs, 'p1').type, BlockType.bullet);
  });

  testWidgets('the toolbar link button asks for an address and applies it', (
    tester,
  ) async {
    final docs = withBlocks([para('p1', 'hello world')]);
    await open(tester, docs);

    Future<void> select() async {
      await tester.tap(key('field-p1'));
      await tester.pump();
      controllerOf(tester, 'field-p1').selection = const TextSelection(
        baseOffset: 0,
        extentOffset: 5,
      );
      await tester.pump();
      await tester.pump();
    }

    await select();
    await tester.tap(key('tb-link'));
    await tester.pumpAndSettle();
    await tester.enterText(key('link-field'), 'not a link');
    await tester.tap(key('link-ok'));
    await tester.pump();
    expect(find.text('Use an http, https or mailto address.'), findsOneWidget);

    await tester.enterText(key('link-field'), 'https://example.com');
    await tester.tap(key('link-ok'));
    await tester.pumpAndSettle();
    await autosave(tester);

    final first = (saved(docs, 'p1').json['content']! as List).first as Map;
    expect(first['text'], 'hello');
    expect(first['marks'].toString(), contains('https://example.com'));

    // Cancelling the dialog leaves the link alone.
    await select();
    await tester.tap(key('tb-link'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(docs.updates.length, 1);
  });

  testWidgets('Ctrl+B bolds the selection', (tester) async {
    final docs = withBlocks([para('p1', 'hello world')]);
    await open(tester, docs);

    await tester.tap(key('field-p1'));
    await tester.pump();
    controllerOf(tester, 'field-p1').selection = const TextSelection(
      baseOffset: 0,
      extentOffset: 5,
    );
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyB);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await tester.pump();
    await autosave(tester);

    final first = (saved(docs, 'p1').json['content']! as List).first as Map;
    expect(first['marks'], [
      {'type': 'bold'},
    ]);
  });

  testWidgets('the slash menu and the toolbar float anchored to the block', (
    tester,
  ) async {
    final docs = withBlocks([para('p1', '')]);
    await open(tester, docs);

    await tester.tap(key('field-p1'));
    await tester.pump();
    await tester.enterText(key('field-p1'), '/');
    await tester.pump();
    await tester.pump();

    expect(key('floating-toolbar'), findsNothing);
    expect(
      tester.getTopLeft(key('slash-menu')).dy,
      greaterThanOrEqualTo(tester.getBottomLeft(key('field-p1')).dy - 1),
    );
    // Typing on past a space closes the menu.
    await tester.enterText(key('field-p1'), '/ no');
    await tester.pump();
    await tester.pump();
    expect(key('slash-menu'), findsNothing);
    expect(key('page-picker'), findsNothing);

    await tester.enterText(key('field-p1'), 'text here');
    await tester.pump();
    controllerOf(tester, 'field-p1').selection = const TextSelection(
      baseOffset: 0,
      extentOffset: 4,
    );
    await tester.pump();
    await tester.pump();
    expect(
      tester.getBottomLeft(key('floating-toolbar')).dy,
      lessThanOrEqualTo(tester.getTopLeft(key('field-p1')).dy + 1),
    );
    await autosave(tester);
  });

  testWidgets('Enter on a slash query picks the first match', (tester) async {
    final docs = withBlocks([para('p1', '')]);
    await open(tester, docs);

    await typeIn(tester, 'field-p1', '/code');
    await tester.pump();
    await tester.enterText(key('field-p1'), '/code\n');
    await tester.pump();
    await tester.pump();
    await autosave(tester);

    expect(saved(docs, 'p1').type, BlockType.code);
  });
}
