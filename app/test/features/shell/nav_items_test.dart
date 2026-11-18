import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:taskforge/features/shell/nav_items.dart';

/// Every `path: '...'` of the router, in order.
List<String> _routerPaths() =>
    RegExp(r"path: '([^']+)'")
        .allMatches(File('lib/app_router.dart').readAsStringSync())
        .map((m) => m.group(1)!)
        .toList();

void main() {
  group('route coverage', () {
    test(
      'every route is in the frame, a child of a framed page, or outside it',
      () {
        final linked = {for (final i in navItems) i.path};
        final unreachable = [
          for (final path in _routerPaths())
            if (!linked.contains(path) &&
                !childRoutes.containsKey(path) &&
                !outsideFrameRoutes.contains(path))
              path,
        ];
        expect(unreachable, isEmpty, reason: 'give each a nav item or parent');
      },
    );

    test('every child route names a parent that can be opened', () {
      final linked = {for (final i in navItems) i.path};
      for (final MapEntry(:key, :value) in childRoutes.entries) {
        final ok =
            value == 'sidebar' ||
            linked.contains(value) ||
            childRoutes.containsKey(value);
        expect(ok, isTrue, reason: '$key → $value');
      }
    });

    test('nav items are unique by id and by path', () {
      expect({for (final i in navItems) i.id}.length, navItems.length);
      expect({for (final i in navItems) i.path}.length, navItems.length);
    });

    test('items that need a permission are never in the main group', () {
      for (final i in navSection(NavSection.main)) {
        expect(i.permission, isNull, reason: i.id);
      }
    });
  });

  group('activeNavItem', () {
    final cases = {
      '/': 'home',
      '/inbox': 'inbox',
      '/inbox/preferences': 'notifications',
      '/goals': 'goals',
      '/goals/g1': 'goals',
      '/docs/d1': 'docs',
      '/chat/s1': 'chat',
      '/workspaces/roles': 'roles',
      '/workspaces/settings': 'settings',
      '/projects/archived': 'archived',
      '/projects/private': 'private-projects',
      '/forms/f1/submissions': 'forms',
      '/developer/webhooks/w1': 'developer',
    };
    cases.forEach((path, id) {
      test('$path lights $id', () => expect(activeNavItem(path)?.id, id));
    });

    test('a project page lights no frame entry', () {
      expect(activeNavItem('/projects/p1'), isNull);
      expect(activeNavItem('/projects/p1/sprints'), isNull);
    });

    test('a lookalike prefix does not match', () {
      expect(activeNavItem('/goalsX'), isNull);
    });
  });

  group('pageTypeRoot (switching workspace)', () {
    final cases = {
      '/docs/d1': '/docs',
      '/goals/g1': '/goals',
      '/chat/s1': '/chat',
      '/forms/f1': '/forms',
      '/forms/f1/submissions': '/forms',
      '/developer/webhooks/w1': '/developer',
      '/projects/p1': '/',
      '/projects/p1/settings': '/',
      '/projects/archived': '/projects/archived',
      '/dashboards': '/dashboards',
      '/members': '/members',
      '/': '/',
    };
    cases.forEach((path, root) {
      test('$path → $root', () => expect(pageTypeRoot(path), root));
    });
  });
}
