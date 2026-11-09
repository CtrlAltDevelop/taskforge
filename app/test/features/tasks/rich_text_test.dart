import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:taskforge/features/tasks/domain/rich_text.dart';

/// The node types the server accepts (`infrastructure/tasks/fields.py`).
const _serverNodes = {
  'doc',
  'paragraph',
  'heading',
  'bullet_list',
  'ordered_list',
  'list_item',
  'checklist',
  'checklist_item',
  'code_block',
  'blockquote',
  'horizontal_rule',
  'text',
  'hard_break',
  'link',
};

void _everyNodeIsAccepted(Object? node, [int depth = 0]) {
  if (node is! Map) return;
  expect(_serverNodes, contains(node['type']));
  expect(depth, lessThan(8), reason: 'the server caps depth at 8');
  if (node['type'] == 'text') expect(node['text'], isA<String>());
  for (final child in (node['content'] as List?) ?? const []) {
    _everyNodeIsAccepted(child, depth + 1);
  }
}

Map<String, Object?> _doc(String text) =>
    jsonDecode(markdownToDoc(text)) as Map<String, Object?>;

void main() {
  const sample = '''# Title
Some text with a [link](https://example.com) inside.
## Plan
- first
- second
1. one
2. two
- [ ] open item
- [x] done item
> a quote
---
```
code here
more code
```
last line''';

  test('every supported block round-trips through the document', () {
    expect(docToMarkdown(markdownToDoc(sample)), sample);
  });

  test('the document only uses node types the server accepts', () {
    _everyNodeIsAccepted(_doc(sample));
  });

  test('headings, lists and checklists get their structure', () {
    final blocks = (_doc(sample)['content'] as List).cast<Map>();
    final types = [for (final b in blocks) b['type']];

    expect(types, [
      'heading',
      'paragraph',
      'heading',
      'bullet_list',
      'ordered_list',
      'checklist',
      'blockquote',
      'horizontal_rule',
      'code_block',
      'paragraph',
    ]);
    expect(blocks[0]['attrs'], {'level': 1});
    expect(blocks[2]['attrs'], {'level': 2});
    expect((blocks[3]['content'] as List), hasLength(2));
    final checks = [
      for (final i in blocks[5]['content'] as List)
        (i as Map)['attrs']['checked'],
    ];
    expect(checks, [false, true]);
  });

  test('a link becomes a text node carrying a link mark', () {
    final paragraph =
        ((_doc('see [docs](https://x.dev/a)')['content'] as List).first as Map);
    final nodes = (paragraph['content'] as List).cast<Map>();

    expect(nodes.map((n) => n['text']), ['see ', 'docs']);
    expect(nodes.last['marks'], [
      {
        'type': 'link',
        'attrs': {'href': 'https://x.dev/a'},
      },
    ]);
  });

  test('blank lines stay as empty paragraphs and nothing is dropped', () {
    expect(docToMarkdown(markdownToDoc('First\n\nThird')), 'First\n\nThird');
  });

  test('empty input is no document, and bad input reads as empty', () {
    expect(markdownToDoc(''), '');
    expect(markdownToDoc('  \n '), '');
    expect(docToMarkdown(''), '');
    expect(docToMarkdown('not json'), '');
    expect(docToMarkdown('[]'), '');
  });

  test('an unclosed code fence runs to the end without crashing', () {
    expect(docToMarkdown(markdownToDoc('```\nabc')), '```\nabc\n```');
  });

  test('a document made elsewhere is shown, not lost', () {
    final other = jsonEncode({
      'type': 'doc',
      'content': [
        {
          'type': 'heading',
          'attrs': {'level': 3},
          'content': [
            {'type': 'text', 'text': 'Hi'},
          ],
        },
        {
          'type': 'checklist',
          'content': [
            {
              'type': 'checklist_item',
              'attrs': {'checked': true},
              'content': [
                {'type': 'text', 'text': 'Done'},
              ],
            },
          ],
        },
      ],
    });

    expect(docToMarkdown(other), '### Hi\n- [x] Done');
  });

  test('windows line endings are treated as newlines', () {
    expect(docToMarkdown(markdownToDoc('a\r\nb')), 'a\nb');
  });
}
