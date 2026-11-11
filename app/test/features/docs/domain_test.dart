import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:taskforge/features/docs/domain/doc_blocks.dart';
import 'package:taskforge/features/docs/domain/doc_merge.dart';
import 'package:taskforge/features/docs/domain/doc_ops.dart';
import 'package:taskforge/features/docs/domain/docs.dart';

import 'fakes.dart';

const sample = '''
[
 {"id":"a","type":"heading","attrs":{"level":2},"content":[{"type":"text","text":"Plan"}]},
 {"id":"b","type":"paragraph","content":[
   {"type":"text","text":"Hello ","marks":[{"type":"bold"}]},
   {"type":"text","text":"link","marks":[{"type":"italic"},{"type":"link","attrs":{"href":"https://x.dev"}}]},
   {"type":"hard_break"},
   {"type":"mention","attrs":{"doc_id":"d1","label":"Spec"}},
   {"type":"emoji","code":"smile"}]},
 {"id":"c","type":"bullet_item","attrs":{"indent":1},"content":[]},
 {"id":"d","type":"checklist_item","attrs":{"indent":0,"checked":true},"content":[{"type":"text","text":"done"}]},
 {"id":"e","type":"code","attrs":{"language":"dart"},"text":"print(1);"},
 {"id":"f","type":"table","attrs":{"header":true},"rows":[[[{"type":"text","text":"A"}],[]],[[],[{"type":"text","text":"B"}]]]},
 {"id":"g","type":"divider"},
 {"id":"h","type":"image","attrs":{"src":"https://x.dev/a.png","alt":"a","width":300}},
 {"id":"i","type":"callout","attrs":{"tone":"warning"},"content":[{"type":"text","text":"careful"}]},
 {"id":"j","type":"task_card","attrs":{"task_id":"t1"}},
 {"id":"k","type":"whiteboard","future":{"nodes":[1,2,{"x":null}]},"attrs":{"z":1}}
]''';

void main() {
  group('block model', () {
    test('every block type survives a round trip unchanged', () {
      final blocks = parseBlocks(sample);

      expect(blocks.map((b) => b.type), [
        'heading',
        'paragraph',
        'bullet_item',
        'checklist_item',
        'code',
        'table',
        'divider',
        'image',
        'callout',
        'task_card',
        'whiteboard',
      ]);
      expect(jsonDecode(encodeBlocks(blocks)), jsonDecode(sample));
    });

    test('an unknown block and unknown inline nodes are kept untouched', () {
      final blocks = parseBlocks(sample);
      final unknown = blocks.last;
      final edited = replaceBlock(
        blocks,
        blocks[1].withRich(blocks[1].rich.replaceRange(0, 0, 'X')),
      );

      expect(unknown.isKnown, isFalse);
      expect(jsonDecode(encodeBlocks(edited)).last, jsonDecode(sample).last);
      // The newer inline node and the mention are still there after an edit.
      final content = edited[1].json['content'] as List;
      expect(content.map((n) => (n as Map)['type']), [
        'text',
        'text',
        'text',
        'hard_break',
        'mention',
        'emoji',
      ]);
      expect((content.last as Map)['code'], 'smile');
    });

    test('typing after bold text stays bold, other text is not touched', () {
      final r = Rich.fromInlines([
        {
          'type': 'text',
          'text': 'ab',
          'marks': [
            {'type': 'bold'},
          ],
        },
        {'type': 'text', 'text': 'cd'},
      ]);

      final typed = r.withText('abXcd');

      expect(typed.attrs[2].bold, isTrue);
      expect(typed.attrs[3].bold, isFalse);
      expect(typed.toInlines().map((n) => n['text']), ['abX', 'cd']);
    });

    test('toggling a mark marks the selection, then unmarks it', () {
      final r = Rich.plain('hello world');

      final bold = r.toggleMark(0, 5, boldMark);

      expect(bold.allHave(0, 5, boldMark), isTrue);
      expect(bold.attrs[6].bold, isFalse);
      expect(bold.toggleMark(0, 5, boldMark).toInlines(), r.toInlines());
    });

    test('a link is set and taken off', () {
      final r = Rich.plain('see docs').setLink(4, 8, 'https://a.dev');

      expect(r.attrs[5].link, 'https://a.dev');
      expect(r.setLink(4, 8, '').attrs[5].link, isNull);
    });

    test('a mention cut in half becomes plain text, an intact one stays', () {
      final atom = Atom.mention('d1', 'Spec');
      final r = Rich('Spec', List.filled(4, Attr(const [], atom)));

      expect(r.toInlines().single['type'], 'mention');
      expect(r.withText('Spc').toInlines().single['type'], 'text');
    });

    test('same JSON compares equal whatever the key order', () {
      expect(
        sameJson(
          {
            'a': 1,
            'b': [1, 2],
          },
          {
            'b': [1, 2],
            'a': 1,
          },
        ),
        isTrue,
      );
      expect(sameJson({'a': 1}, {'a': 2}), isFalse);
    });

    test('an empty body is an empty page; a non-list is refused', () {
      expect(parseBlocks(''), isEmpty);
      expect(() => parseBlocks('{}'), throwsFormatException);
    });

    test('turning a paragraph into a heading keeps its text and id', () {
      final b = para('p', 'Hi').turnInto('heading', attrs: {'level': 2});

      expect((b.id, b.type, b.level, b.plain), ('p', 'heading', 2, 'Hi'));
    });

    test('task card ids are listed once', () {
      expect(
        taskCardIds([
          taskCard('1', 'x'),
          taskCard('2', 'x'),
          taskCard('3', 'y'),
        ]),
        ['x', 'y'],
      );
    });
  });

  group('block operations', () {
    test('Enter splits the block and a heading continues as a paragraph', () {
      final blocks = [heading('h', 'Hello')];

      final r = splitBlock(blocks, 'h', Rich.plain('He'), Rich.plain('llo'));

      expect(r.blocks.map((b) => (b.type, b.plain)), [
        ('heading', 'He'),
        ('paragraph', 'llo'),
      ]);
      expect(r.focus, r.blocks[1].id);
    });

    test('Enter in an empty list item ends the list', () {
      final item = DocBlock.create(BlockType.bullet, id: 'i');

      final r = splitBlock([item], 'i', Rich.empty, Rich.empty);

      expect(r.blocks.single.type, 'paragraph');
    });

    test('Backspace at the start turns a heading into text, then joins up', () {
      final blocks = [para('a', 'One'), heading('b', 'Two')];

      final first = mergeUp(blocks, 'b')!;
      final second = mergeUp(first.blocks, 'b')!;

      expect(first.blocks[1].type, 'paragraph');
      expect(second.blocks.single.plain, 'OneTwo');
      expect((second.focus, second.offset), ('a', 3));
    });

    test('numbered items count in runs and restart after other blocks', () {
      DocBlock n(String id, {int indent = 0}) => DocBlock.create(
        BlockType.numbered,
        id: id,
      ).withAttrs({'indent': indent});

      final out = numbering([
        n('1'),
        n('2'),
        n('2a', indent: 1),
        n('3'),
        para('p', 'x'),
        n('4'),
      ]);

      expect(out, {'1': 1, '2': 2, '2a': 1, '3': 3, '4': 1});
    });

    test('Markdown shortcuts map to block types', () {
      expect(markdownShortcut('## ')?.attrs, {'level': 2});
      expect(markdownShortcut('- ')?.type, 'bullet_item');
      expect(markdownShortcut('[] ')?.type, 'checklist_item');
      expect(markdownShortcut('---')?.type, 'divider');
      expect(markdownShortcut('#### '), isNull);
      expect(markdownShortcut('hello'), isNull);
    });

    test('a task id is found in a pasted link', () {
      const id = '123e4567-e89b-12d3-a456-426614174000';

      expect(taskIdFromText('http://h/projects/p?task=$id'), id);
      expect(taskIdFromText('nothing'), isNull);
    });

    test('move and remove keep the others in place', () {
      final b = [para('a', '1'), para('b', '2'), para('c', '3')];

      expect(moveBlock(b, 'c', -1).map((x) => x.id), ['a', 'c', 'b']);
      expect(moveBlock(b, 'a', -1).map((x) => x.id), ['a', 'b', 'c']);
      expect(removeBlock(b, 'b').map((x) => x.id), ['a', 'c']);
    });
  });

  group('page tree', () {
    final tree = DocTreeView([
      node('a', 'A'),
      node('a1', 'A1', parent: 'a'),
      node('a2', 'A2', parent: 'a'),
      node('b', 'B'),
    ]);

    test('drops compute the parent and the index among new siblings', () {
      expect(tree.dropAt('b', 'a', DropZone.into), (parent: 'a', index: 2));
      expect(tree.dropAt('b', 'a1', DropZone.before), (parent: 'a', index: 0));
      expect(tree.dropAt('a1', 'a2', DropZone.after), (parent: 'a', index: 1));
      expect(tree.dropAt('b', 'a', DropZone.before), (parent: '', index: 0));
    });

    test('a page cannot go under itself or its own subpage', () {
      expect(tree.dropAt('a', 'a1', DropZone.into), isNull);
      expect(tree.dropAt('a', 'a', DropZone.after), isNull);
    });

    test('nudging stops at the ends', () {
      expect(tree.nudge('a2', -1), (parent: 'a', index: 0));
      expect(tree.nudge('a1', -1), isNull);
      expect(tree.nudge('b', 1), isNull);
    });

    test('the breadcrumb runs from the top down', () {
      expect(tree.trail('a2').map((d) => d.id), ['a', 'a2']);
    });
  });

  group('merge', () {
    final base = [para('a', 'one'), para('b', 'two'), para('c', 'three')];

    test('changes to different blocks both survive', () {
      final mine = [para('a', 'ONE'), base[1], base[2]];
      final theirs = [base[0], base[1], para('c', 'THREE')];

      final r = mergeBlocks(base, mine, theirs);

      expect(r.clean, isTrue);
      expect(r.blocks.map((b) => b.plain), ['ONE', 'two', 'THREE']);
    });

    test('blocks added on both sides are kept in place', () {
      final mine = [base[0], para('m', 'mine'), base[1], base[2]];
      final theirs = [base[0], base[1], para('t', 'theirs'), base[2]];

      final r = mergeBlocks(base, mine, theirs);

      expect(r.blocks.map((b) => b.id), ['a', 'm', 'b', 't', 'c']);
    });

    test('a block removed on one side and untouched on the other goes', () {
      final r = mergeBlocks(
        base,
        [base[0], base[2]],
        [base[0], base[1], para('c', 'THREE')],
      );

      expect(r.clean, isTrue);
      expect(r.blocks.map((b) => b.plain), ['one', 'THREE']);
    });

    test(
      'a block both changed is a conflict: mine by default, theirs on ask',
      () {
        final mine = [para('a', 'mine'), base[1], base[2]];
        final theirs = [para('a', 'theirs'), base[1], base[2]];

        final keep = mergeBlocks(base, mine, theirs);
        final take = mergeBlocks(base, mine, theirs, takeTheirs: {'a'});

        expect(keep.conflicts.single.id, 'a');
        expect(keep.blocks.first.plain, 'mine');
        expect(take.blocks.first.plain, 'theirs');
      },
    );

    test('changed here but removed there is a conflict, mine kept', () {
      final r = mergeBlocks(
        base,
        [base[0], para('b', 'TWO'), base[2]],
        [base[0], base[2]],
      );

      expect(r.conflicts.single.theirs, isNull);
      expect(r.blocks.map((b) => b.id), ['a', 'b', 'c']);
      expect(
        mergeBlocks(
          base,
          [base[0], para('b', 'TWO'), base[2]],
          [base[0], base[2]],
          takeTheirs: {'b'},
        ).blocks.map((b) => b.id),
        ['a', 'c'],
      );
    });

    test('an unknown block nobody touched is kept through a merge', () {
      final x = DocBlock({'id': 'x', 'type': 'whiteboard', 'z': 1});

      final r = mergeBlocks([x], [x, para('n', 'new')], [x]);

      expect(r.blocks.first.json['z'], 1);
      expect(r.blocks.length, 2);
    });
  });

  test('conflict and failure texts', () {
    expect(
      docErrorMessage(const DocException(DocFailure.notFound)),
      contains('does not exist'),
    );
    expect(docErrorMessage(StateError('x')), contains('Something went wrong'));
  });
}
