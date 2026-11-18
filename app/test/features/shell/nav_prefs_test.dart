import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskforge/features/projects/domain/projects.dart';
import 'package:taskforge/features/shell/nav_prefs.dart';
import 'package:taskforge/features/shortcuts/application/local_prefs.dart';

Project _p(String id, String name) =>
    Project(id: id, name: name, key: id.toUpperCase());

ProviderContainer _container(MemoryPrefs prefs) {
  final c = ProviderContainer(
    overrides: [localPrefsProvider.overrideWithValue(prefs)],
  );
  addTearDown(c.dispose);
  return c;
}

void main() {
  group('orderedProjects', () {
    final all = [_p('a', 'Zulu'), _p('b', 'Alpha'), _p('c', 'Mike')];

    test('falls back to name order with no saved order', () {
      expect(orderedProjects(all, const []).map((p) => p.id), ['b', 'c', 'a']);
    });

    test('follows the saved order, new projects after it by name', () {
      expect(orderedProjects(all, ['a', 'b']).map((p) => p.id), [
        'a',
        'b',
        'c',
      ]);
    });

    test('ignores ids that no longer exist', () {
      expect(orderedProjects(all, ['gone', 'c']).map((p) => p.id), [
        'c',
        'b',
        'a',
      ]);
    });
  });

  group('movedOrder', () {
    final list = [_p('a', 'A'), _p('b', 'B'), _p('c', 'C')];

    test('moves an item down', () {
      expect(movedOrder(list, 0, 2, const []), ['b', 'c', 'a']);
    });

    test('moves an item up', () {
      expect(movedOrder(list, 2, 0, const []), ['c', 'a', 'b']);
    });

    test('keeps other lists\' ids after the moved list', () {
      expect(movedOrder(list, 0, 1, ['x', 'a', 'b']), ['b', 'a', 'c', 'x']);
    });
  });

  group('NavPrefs', () {
    test('groups start as the design says and a toggle flips them', () {
      const p = NavPrefs();
      expect(p.isOpen('workspace'), isFalse);
      expect(p.isOpen('admin'), isFalse);
      expect(p.isOpen('favorites'), isTrue);
      final flipped = p.copyWith(openSections: {'workspace', 'favorites'});
      expect(flipped.isOpen('workspace'), isTrue);
      expect(flipped.isOpen('favorites'), isFalse);
    });

    test('survives a round trip through JSON', () {
      const p = NavPrefs(
        collapsed: true,
        openSections: {'admin'},
        projectOrder: ['b', 'a'],
        recent: ['a'],
      );
      final back = NavPrefs.fromJson(p.toJson());
      expect(back.collapsed, isTrue);
      expect(back.openSections, {'admin'});
      expect(back.projectOrder, ['b', 'a']);
      expect(back.recent, ['a']);
    });

    test('a damaged copy reads as empty, not as an error', () {
      final p = NavPrefs.fromJson({
        'open': 5,
        'order': [1, 'a'],
        'recent': null,
      });
      expect(p.openSections, isEmpty);
      expect(p.projectOrder, ['a']);
      expect(p.recent, isEmpty);
    });
  });

  group('NavPrefsNotifier', () {
    test('saves what changes and loads it back', () async {
      final prefs = MemoryPrefs();
      final first = _container(prefs);
      first.read(navPrefsProvider);
      await Future<void>.delayed(Duration.zero);
      first.read(navPrefsProvider.notifier)
        ..toggleCollapsed()
        ..toggleSection('admin')
        ..setOrder(['b', 'a']);

      final second = _container(prefs);
      second.read(navPrefsProvider);
      await Future<void>.delayed(Duration.zero);
      final loaded = second.read(navPrefsProvider);
      expect(loaded.collapsed, isTrue);
      expect(loaded.isOpen('admin'), isTrue);
      expect(loaded.projectOrder, ['b', 'a']);
    });

    test(
      'a change made before the saved copy arrives is not overwritten',
      () async {
        final prefs = MemoryPrefs();
        await prefs.write('nav.v1', '{"collapsed":false,"recent":["old"]}');
        final c = _container(prefs);
        c.read(navPrefsProvider.notifier).toggleCollapsed();
        await Future<void>.delayed(Duration.zero);
        expect(c.read(navPrefsProvider).collapsed, isTrue);
      },
    );

    test('visiting a project before the saved copy arrives keeps what was saved', () async {
      final prefs = MemoryPrefs();
      await prefs.write(
        'nav.v1',
        '{"collapsed":true,"order":["b","a"],"open":["admin"],"recent":["x"]}',
      );
      final c = _container(prefs);
      c.read(navPrefsProvider.notifier).visited('p9'); // first frame
      await Future<void>.delayed(Duration.zero);
      final p = c.read(navPrefsProvider);
      expect(p.collapsed, isTrue);
      expect(p.projectOrder, ['b', 'a']);
      expect(p.isOpen('admin'), isTrue);
      expect(p.recent, ['p9', 'x']);
    });

    test('recent keeps the newest first, once each, up to the limit', () {
      final c = _container(MemoryPrefs());
      final n = c.read(navPrefsProvider.notifier);
      for (var i = 0; i < recentProjectsMax + 3; i++) {
        n.visited('p$i');
      }
      n.visited('p5');
      final recent = c.read(navPrefsProvider).recent;
      expect(recent.length, recentProjectsMax);
      expect(recent.first, 'p5');
      expect(recent.toSet().length, recent.length);
    });

    test('an unreadable saved copy is ignored', () async {
      final prefs = MemoryPrefs();
      await prefs.write('nav.v1', 'not json');
      final c = _container(prefs);
      c.read(navPrefsProvider);
      await Future<void>.delayed(Duration.zero);
      expect(c.read(navPrefsProvider).collapsed, isFalse);
    });
  });
}
