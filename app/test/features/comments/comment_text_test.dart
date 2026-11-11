import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:taskforge/features/comments/domain/comment_text.dart';
import 'package:taskforge/features/comments/domain/comments.dart';

const ana = MentionPick('u-ana', 'Ana');
const anaMaria = MentionPick('u-am', 'Ana Maria');

Map<String, dynamic> doc(String body) =>
    jsonDecode(body) as Map<String, dynamic>;

void main() {
  group('what was typed becomes the document', () {
    test('plain text is one paragraph', () {
      final d = doc(bodyFromComposer('Looks good', const []));

      expect(d['type'], 'doc');
      expect((d['content'] as List).single['type'], 'paragraph');
    });

    test('nothing to say sends nothing', () {
      expect(bodyFromComposer('   ', const []), '');
      expect(bodyFromComposer('', const []), '');
    });

    test('a picked @name becomes a mention node, the words around it stay', () {
      final d = doc(bodyFromComposer('hey @Ana can you look?', [ana]));

      final nodes = ((d['content'] as List).single['content'] as List);
      expect(nodes.map((n) => n['type']), ['text', 'mention', 'text']);
      expect(nodes[0]['text'], 'hey ');
      expect(nodes[1]['attrs'], {'id': 'u-ana', 'label': 'Ana'});
      expect(nodes[2]['text'], ' can you look?');
    });

    test('the longest name wins and the same person twice is two nodes', () {
      final d = doc(
        bodyFromComposer('@Ana Maria and @Ana and @Ana', [ana, anaMaria]),
      );

      final ids = [
        for (final n in ((d['content'] as List).single['content'] as List))
          if (n['type'] == 'mention') n['attrs']['id'],
      ];
      expect(ids, ['u-am', 'u-ana', 'u-ana']);
    });

    test('an @name that was typed by hand, not picked, stays text', () {
      final d = doc(bodyFromComposer('hello @Bob', [ana]));

      final nodes = ((d['content'] as List).single['content'] as List);
      expect(nodes.single['type'], 'text');
      expect(nodes.single['text'], 'hello @Bob');
    });

    test('lines and lists keep their shape around mentions', () {
      final d = doc(bodyFromComposer('- ask @Ana\n- done', [ana]));

      expect((d['content'] as List).single['type'], 'bullet_list');
      expect(mentionedIn('- ask @Ana', [ana]), {'u-ana'});
      expect(mentionedIn('nobody', [ana]), isEmpty);
    });
  });

  group('a stored body is shown', () {
    test('as segments: text, link, mention', () {
      final body = jsonEncode({
        'type': 'doc',
        'content': [
          {
            'type': 'paragraph',
            'content': [
              {'type': 'text', 'text': 'see '},
              {
                'type': 'text',
                'text': 'this',
                'marks': [
                  {
                    'type': 'link',
                    'attrs': {'href': 'https://e.example'},
                  },
                ],
              },
              {'type': 'text', 'text': ' '},
              {
                'type': 'mention',
                'attrs': {'id': 'u1', 'label': 'Ana'},
              },
            ],
          },
        ],
      });

      final lines = segmentsOf(body);

      expect(lines, hasLength(1));
      expect(lines.single, [
        const Segment('see '),
        const Segment('this', href: 'https://e.example'),
        const Segment(' '),
        const Segment('@Ana', mentionId: 'u1'),
      ]);
      expect(plainTextOf(body), 'see this @Ana');
    });

    test('a removed or broken body shows nothing and never throws', () {
      expect(segmentsOf(''), isEmpty);
      expect(segmentsOf('not json'), isEmpty);
      expect(segmentsOf('[]'), isEmpty);
    });

    test('a bullet list reads as bullets', () {
      final body = bodyFromComposer('- one\n- two', const []);

      expect(plainTextOf(body), '• one\n• two');
    });
  });
}
