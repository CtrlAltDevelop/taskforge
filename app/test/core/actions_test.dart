import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskforge/core/actions/action_registry.dart';
import 'package:taskforge/core/actions/app_action.dart';
import 'package:taskforge/core/actions/chord.dart';
import 'package:taskforge/core/actions/fuzzy.dart';
import 'package:taskforge/features/shortcuts/application/builtin_actions.dart';
import 'package:taskforge/features/shortcuts/presentation/cheat_sheet.dart';
import 'package:taskforge/features/shortcuts/presentation/command_palette.dart';

AppAction act(
  String id, {
  String title = 'Title',
  String keys = '',
  String label = 'A label',
  List<String> keywords = const [],
  bool Function(ActionContext)? available,
}) => AppAction(
  id: id,
  title: title,
  group: 'G',
  semanticLabel: label,
  keywords: keywords,
  defaultKeys: keys,
  available: available,
  run: (_) {},
);

class _FakeContext implements ActionContext {
  _FakeContext({this.location = '/'});

  @override
  final String location;

  @override
  String? get projectId =>
      RegExp(r'^/projects/([^/?]+)').firstMatch(location)?.group(1);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('registry', () {
    test('the built-in registry is valid and every id is unique', () {
      final registry = ActionRegistry(builtInActions);
      expect(registry.actions.length, builtInActions.length);
      expect(registry.byId('palette.open')!.defaultKeys, 'mod+k');
    });

    test('a repeated id is refused', () {
      expect(
        () => ActionRegistry([act('a.b'), act('a.b')]),
        throwsArgumentError,
      );
    });

    test('an id that is not lower-case dotted is refused', () {
      expect(() => ActionRegistry([act('Task Create')]), throwsArgumentError);
    });

    test('an action without an accessible label is refused', () {
      expect(
        () => ActionRegistry([act('a.b', label: ' ')]),
        throwsArgumentError,
      );
    });

    test('two defaults on one key are refused, naming both', () {
      expect(
        () => ActionRegistry([
          act('a.one', keys: 'alt+x'),
          act('a.two', keys: 'ALT+x'),
        ]),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            allOf(contains('a.one'), contains('a.two')),
          ),
        ),
      );
    });

    test('a default the browser keeps is refused', () {
      expect(
        () => ActionRegistry([act('a.b', keys: 'mod+w')]),
        throwsArgumentError,
      );
    });

    test('every built-in action has a heading and a label', () {
      for (final a in builtInActions) {
        expect(a.group, isNotEmpty, reason: a.id);
        expect(a.semanticLabel.trim(), isNotEmpty, reason: a.id);
      }
    });
  });

  group('bindings', () {
    final registry = ActionRegistry([
      act('a.one', keys: 'alt+1'),
      act('a.two', keys: 'alt+2'),
      act('a.none'),
    ]);

    test('defaults apply until the person changes one', () {
      final b = Bindings(registry);
      expect(b.chordOf('a.one'), Chord.parse('alt+1'));
      expect(b.chordOf('a.none'), isNull);
      final changed = Bindings(registry, {'a.one': 'alt+9'});
      expect(changed.chordOf('a.one'), Chord.parse('alt+9'));
      expect(changed.actionFor(Chord.parse('alt+9')!)!.id, 'a.one');
      expect(changed.actionFor(Chord.parse('alt+1')!), isNull);
    });

    test('an empty override unbinds on purpose', () {
      final b = Bindings(registry, {'a.one': ''});
      expect(b.chordOf('a.one'), isNull);
    });

    test('binding a key another action holds is a conflict that names it', () {
      final b = Bindings(registry);
      expect(b.conflict('a.one', Chord.parse('alt+2')!)!.id, 'a.two');
      expect(b.conflict('a.two', Chord.parse('alt+2')!), isNull);
      expect(b.conflict('a.one', Chord.parse('alt+7')!), isNull);
    });
  });

  group('availability', () {
    test('the registry offers only what the context allows', () {
      final registry = ActionRegistry([
        act('a.always'),
        act('a.never', available: (_) => false),
      ]);
      expect(
        [for (final a in registry.available(_FakeContext())) a.id],
        ['a.always'],
      );
    });

    test('the project id comes from the route', () {
      expect(_FakeContext(location: '/projects/p9/settings').projectId, 'p9');
      expect(_FakeContext(location: '/projects/p9?task=t1').projectId, 'p9');
      expect(_FakeContext(location: '/inbox').projectId, isNull);
    });

    test('project pages are offered only inside a project', () {
      final registry = ActionRegistry(builtInActions);
      final outside = [
        for (final a in registry.available(_FakeContext(location: '/inbox')))
          a.id,
      ];
      final inside = [
        for (final a in registry.available(
          _FakeContext(location: '/projects/p1'),
        ))
          a.id,
      ];
      expect(outside, isNot(contains('project.settings')));
      expect(inside, contains('project.settings'));
      // Already on a page: no point offering to go there.
      expect(outside, isNot(contains('nav.inbox')));
      expect(inside, contains('nav.inbox'));
    });
  });

  group('chord', () {
    test('parse and wire round trip, modifiers in a fixed order', () {
      expect(Chord.parse('shift+mod+K')!.wire, 'mod+shift+k');
      expect(Chord.parse(''), isNull);
      expect(Chord.parse('hyper+k'), isNull);
    });

    test('labels follow the platform', () {
      final c = Chord.parse('mod+shift+k')!;
      expect(c.label(isMac: false), 'Ctrl+Shift+K');
      expect(c.label(isMac: true), '⇧⌘K');
      expect(Chord.parse('question')!.label(isMac: false), '?');
    });

    test('only a combination with a modifier counts while typing', () {
      expect(Chord.parse('slash')!.hasModifier, isFalse);
      expect(Chord.parse('mod+k')!.hasModifier, isTrue);
      expect(Chord.parse('shift+k')!.hasModifier, isFalse);
    });

    test('a letter key has a one-letter token', () {
      const down = KeyDownEvent(
        physicalKey: PhysicalKeyboardKey.keyK,
        logicalKey: LogicalKeyboardKey.keyK,
        timeStamp: Duration.zero,
      );
      expect(keyToken(down), 'k');
    });
  });

  group('fuzzy', () {
    test('no match is null, an empty query matches everything', () {
      expect(fuzzyScore('zzz', 'Create task'), isNull);
      expect(fuzzyScore('', 'Create task'), 0);
    });

    test('a prefix beats a word start beats inside beats scattered', () {
      final prefix = fuzzyScore('cre', 'Create task')!;
      final word = fuzzyScore('tas', 'Create task')!;
      final inside = fuzzyScore('eat', 'Create task')!;
      final scattered = fuzzyScore('ctk', 'Create task')!;
      expect(prefix, greaterThan(word));
      expect(word, greaterThan(inside));
      expect(inside, greaterThan(scattered));
    });

    test('ranking puts the better title first', () {
      final list = rankActions([
        act('a.b', title: 'Archived projects'),
        act('a.c', title: 'Projects overview'),
        act('a.d', title: 'Members'),
      ], 'proj');
      expect([for (final a in list) a.id], ['a.c', 'a.b']);
    });

    test('keywords match but rank below a title match', () {
      final list = rankActions([
        act('a.kw', title: 'Roles', keywords: const ['access']),
        act('a.title', title: 'Access log'),
      ], 'access');
      expect([for (final a in list) a.id], ['a.title', 'a.kw']);
    });

    test('with no text, recent actions come first then registration order', () {
      final list = rankActions(
        [act('a.one'), act('a.two'), act('a.three')],
        '',
        recent: const ['a.three'],
      );
      expect([for (final a in list) a.id], ['a.three', 'a.one', 'a.two']);
    });
  });

  group('palette query', () {
    test('prefixes pick what is searched', () {
      expect(parsePaletteQuery('> go').mode, PaletteMode.actions);
      expect(parsePaletteQuery('#web').mode, PaletteMode.projects);
      expect(parsePaletteQuery('#web').text, 'web');
      expect(parsePaletteQuery('@zoe').mode, PaletteMode.people);
      expect(parsePaletteQuery('WEB-12').mode, PaletteMode.all);
    });
  });

  test('the cheat sheet groups straight from the registry', () {
    final groups = groupActions(builtInActions);
    final all = groups.values.expand((a) => a).map((a) => a.id).toSet();
    expect(all, {for (final a in builtInActions) a.id});
  });
}
