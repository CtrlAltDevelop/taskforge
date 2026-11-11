import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskforge/features/docs/application/docs_providers.dart';
import 'package:taskforge/features/docs/domain/doc_blocks.dart';
import 'package:taskforge/features/docs/domain/docs.dart';

import 'docs_ui_test.dart' show key, open, taskId;
import 'fakes.dart';

void main() {
  testWidgets(
    'a page with every block type is saved and reloads with identical content',
    (tester) async {
      final docs = FakeDocsClient()
        ..cards[taskId] = const TaskCardInfo(
          taskId: taskId,
          projectId: 'p1',
          key: 'WEB-1',
          title: 'Fix login',
          statusName: 'To do',
        );
      final pumped = await open(
        tester,
        docs,
        location: '/docs',
        size: const Size(1400, 4000),
      );

      await tester.tap(key('new-page'));
      await tester.pumpAndSettle();
      final id = docs.nodes.last.id;
      List<DocBlock> blocks() =>
          pumped.container.read(docSessionProvider(id)).blocks;

      await tester.enterText(key('doc-title'), 'Everything');
      await tester.pump();
      await tester.tap(key('empty-page'));
      await tester.pump();
      await tester.pump();
      await tester.enterText(
        find.byKey(ValueKey('field-${blocks().first.id}')),
        'Opening words',
      );
      await tester.pump();

      /// Adds a block at the end through the slash menu and returns it.
      Future<DocBlock?> add(String slash, String type) async {
        await tester.tap(key('add-block'));
        await tester.pump();
        await tester.pump();
        final field = tester
            .widgetList<TextField>(find.byType(TextField))
            .last
            .key!;
        await tester.enterText(find.byKey(field), '/$slash');
        await tester.pump();
        await tester.pump();
        await tester.tap(key('slash-$slash'));
        await tester.pumpAndSettle();
        // Image and task card wait for their dialog first.
        if (type == BlockType.image || type == BlockType.taskCard) return null;
        return blocks().lastWhere((b) => b.type == type);
      }

      Future<void> typeInto(DocBlock b, String text) async {
        await tester.enterText(find.byKey(ValueKey('field-${b.id}')), text);
        await tester.pump();
      }

      for (final (slash, type, text) in [
        ('h1', BlockType.heading, 'A heading'),
        ('bullet', BlockType.bullet, 'A bullet'),
        ('numbered', BlockType.numbered, 'A number'),
        ('todo', BlockType.checklist, 'A check'),
        ('quote', BlockType.quote, 'A quote'),
        ('callout', BlockType.callout, 'A callout'),
        ('code', BlockType.code, 'let x = 1;'),
      ]) {
        await typeInto((await add(slash, type))!, text);
      }

      final table = await add('table', BlockType.table);
      await tester.enterText(
        find.byKey(ValueKey('cell-${table!.id}-0-0')),
        'Cell',
      );
      await tester.pump();

      await add('divider', BlockType.divider);

      await add('image', BlockType.image);
      await tester.enterText(key('image-src'), 'https://example.com/i.png');
      await tester.enterText(key('image-alt'), 'Pic');
      await tester.tap(key('image-ok'));
      await tester.pumpAndSettle();

      await add('task', BlockType.taskCard);
      await tester.enterText(key('task-picker-field'), taskId);
      await tester.pump();
      await tester.tap(key('task-use-pasted'));
      await tester.pumpAndSettle();

      await tester.pump(const Duration(milliseconds: 1600));
      await tester.pumpAndSettle();

      final stored = [...docs.bodies[id]!];
      final types = stored.map((b) => b.type).toSet();
      expect(
        types,
        containsAll(<String>[
          BlockType.paragraph,
          BlockType.heading,
          BlockType.bullet,
          BlockType.numbered,
          BlockType.checklist,
          BlockType.quote,
          BlockType.callout,
          BlockType.code,
          BlockType.table,
          BlockType.divider,
          BlockType.image,
          BlockType.taskCard,
        ]),
      );
      expect(docs.nodes.last.title, 'Everything');
      expect(find.text('Saved'), findsOneWidget);

      // Leave the page and come back: a new session reads the server's copy.
      final readsBefore = docs.calls.where((c) => c == 'get:$id').length;
      await pumped.go(tester, '/docs');
      await tester.pumpAndSettle();
      await pumped.go(tester, '/docs/$id');
      await tester.pumpAndSettle();

      expect(
        docs.calls.where((c) => c == 'get:$id').length,
        greaterThan(readsBefore),
      );
      final reloaded = blocks();
      expect(sameBlocks(reloaded, stored), isTrue);
      expect(reloaded.length, stored.length);
      for (final text in [
        'Opening words',
        'A heading',
        'A bullet',
        'A number',
        'A check',
        'A quote',
        'A callout',
        'let x = 1;',
        'Cell',
      ]) {
        expect(find.text(text), findsOneWidget, reason: text);
      }
      expect(key('divider-block'), findsOneWidget);
      expect(key('task-card-$taskId'), findsOneWidget);
      expect(find.text('Everything'), findsWidgets);
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 30));
    },
  );
}
