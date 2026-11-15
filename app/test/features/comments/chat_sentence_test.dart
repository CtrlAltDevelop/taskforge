import 'dart:ui' show Locale;

import 'package:flutter_test/flutter_test.dart';
import 'package:taskforge/core/offline/codecs.dart';
import 'package:taskforge/features/comments/domain/chat_sentence.dart';
import 'package:taskforge/features/comments/domain/comments.dart';
import 'package:taskforge/l10n/gen/app_localizations.dart';

String _user(String id) => switch (id) {
  'u1' => 'Sara',
  'u2' => 'Hank',
  _ => '?',
};

String _status(String id) => switch (id) {
  's1' => 'To do',
  's2' => 'Done',
  _ => '?',
};

String phrase(ChatEvent e, [String language = 'en']) => chatPhrase(
  e,
  l: lookupAppLocalizations(Locale(language)),
  userName: _user,
  statusName: _status,
);

ChatEvent ev(String field, Object? from, Object? to, {String type = 'user'}) =>
    ChatEvent(actorType: type, actorId: 'u1', field: field, from: from, to: to);

void main() {
  group('ChatEvent', () {
    test('reads the server JSON', () {
      final e = ChatEvent.tryParse(
        '{"actor_type":"user","actor_id":"u1","field":"assignees",'
        '"from":["a"],"to":["a","b"]}',
      )!;

      expect(e.byPerson, isTrue);
      expect(e.field, 'assignees');
      expect(e.to, ['a', 'b']);
    });

    test('is empty for a user message and for broken text', () {
      expect(ChatEvent.tryParse(''), isNull);
      expect(ChatEvent.tryParse('not json'), isNull);
      expect(ChatEvent.tryParse('[1]'), isNull);
    });

    test('cannot be changed after it is made', () {
      final e = ChatEvent.tryParse('{"field":"assignees","to":["a"]}')!;

      expect(() => (e.to! as List).add('b'), throwsUnsupportedError);
    });

    test('survives the offline copy of a system message', () {
      final c = Comment(
        id: 'c1',
        taskId: 't',
        authorId: '',
        createdAt: DateTime.utc(2026, 1, 1),
        kind: 'system',
        event: ev('priority', 'low', 'high', type: 'automation'),
      );

      final back = commentFromJson(commentToJson(c));

      expect(back.isSystem, isTrue);
      expect(back.event, c.event);
      expect(back.event!.byPerson, isFalse);
    });

    test('a user message stays a user message in the offline copy', () {
      final c = Comment(
        id: 'c1',
        taskId: 't',
        authorId: 'u1',
        createdAt: DateTime.utc(2026, 1, 1),
      );

      final back = commentFromJson(commentToJson(c));

      expect(back.isSystem, isFalse);
      expect(back.event, isNull);
    });
  });

  group('the sentence in English', () {
    test('priority, status and title name both values', () {
      expect(
        phrase(ev('priority', 'low', 'high')),
        'changed priority from Low to High',
      );
      expect(
        phrase(ev('status_id', 's1', 's2')),
        'changed status from To do to Done',
      );
      expect(
        phrase(ev('title', 'Fix', 'Fix login')),
        'renamed this task from “Fix” to “Fix login”',
      );
    });

    test('dates, estimate and a missing value', () {
      expect(
        phrase(ev('due_date', '', '2026-03-05')),
        'changed the due date from none to 2026-03-05',
      );
      expect(
        phrase(ev('start_date', '2026-03-01', '2026-03-02')),
        'changed the start date from 2026-03-01 to 2026-03-02',
      );
      expect(
        phrase(ev('estimate_sec', null, 5400)),
        'changed the estimate from none to 1h 30m',
      );
    });

    test('assignees say who was added and who was removed', () {
      expect(phrase(ev('assignees', ['u2'], ['u2', 'u1'])), 'assigned Sara');
      expect(phrase(ev('assignees', ['u2', 'u1'], ['u2'])), 'unassigned Sara');
      expect(
        phrase(ev('assignees', ['u2'], ['u1'])),
        'assigned Sara and unassigned Hank',
      );
    });

    test('a new subtask names it; an unknown field never shows values', () {
      expect(
        phrase(ev('subtask_added', null, 'Write tests')),
        'added the subtask “Write tests”',
      );
      expect(phrase(ev('secret_field', 'x', 'y')), 'changed a field');
    });
  });

  group('the sentence in other languages', () {
    test('Persian and Arabic are not the English text', () {
      final e = ev('priority', 'low', 'high');

      final fa = phrase(e, 'fa');
      final ar = phrase(e, 'ar');

      expect(fa, contains('اولویت'));
      expect(ar, contains('الأولوية'));
      expect(fa, isNot(phrase(e)));
      expect(ar, isNot(phrase(e)));
    });

    test('Pashto too', () {
      expect(phrase(ev('title', 'a', 'b'), 'ps'), contains('سرلیک'));
    });
  });

  test('automations, forms and imports are named by what they are', () {
    final l = lookupAppLocalizations(const Locale('en'));

    expect(chatNonPersonActor('automation', l), 'an automation');
    expect(chatNonPersonActor('form', l), 'a form');
    expect(chatNonPersonActor('import', l), 'an import');
    expect(chatNonPersonActor('other', l), 'the system');
  });
}
