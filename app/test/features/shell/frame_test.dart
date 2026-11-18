import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:taskforge/app_router.dart';
import 'package:taskforge/features/roles/domain/roles.dart';
import 'package:taskforge/features/shortcuts/application/local_prefs.dart';
import 'package:taskforge/features/shell/nav_access.dart';
import 'package:taskforge/features/shell/nav_items.dart';
import 'package:taskforge/features/shell/nav_prefs.dart';
import 'package:taskforge/features/shell/sidebar.dart';
import 'package:taskforge/features/shell/sidebar_item.dart';

import 'package:taskforge/features/workspaces/application/workspace_providers.dart';

import '../projects/fakes.dart';
import '../projects/projects_test_support.dart';

String _where(Pumped p) => p.container
    .read(routerProvider)
    .routeInformationProvider
    .value
    .uri
    .toString();

double _sidebarWidth(WidgetTester tester) =>
    tester.getSize(byKey('sidebar')).width;

/// Moves a mouse over [finder] so hover-only parts (the … menu) show.
Future<void> _hover(WidgetTester tester, Finder finder) async {
  final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
  await mouse.addPointer(location: Offset.zero);
  addTearDown(mouse.removePointer);
  await mouse.moveTo(tester.getCenter(finder));
  await tester.pumpAndSettle();
}

/// Tabs until the row with [key] has keyboard focus.
Future<void> _tabTo(WidgetTester tester, String key) async {
  bool focused() => find
      .descendant(of: byKey(key), matching: find.byType(Focus))
      .evaluate()
      .any((e) => (e.widget as Focus).focusNode?.hasPrimaryFocus ?? false);
  for (var i = 0; i < 80 && !focused(); i++) {
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
  }
  expect(focused(), isTrue, reason: 'could not tab to $key');
}

Future<void> _key(WidgetTester tester, LogicalKeyboardKey key) async {
  await tester.sendKeyEvent(key);
  await tester.pumpAndSettle();
}

void main() {
  final projects = [
    project('p1', 'Website'),
    project('p2', 'Billing', favorite: true),
    project('p3', 'Zebra'),
  ];

  group('layout by width', () {
    testWidgets('360: a bottom bar, no sidebar', (tester) async {
      await pumpProjects(
        tester,
        projects: projects,
        size: const Size(360, 800),
      );
      expect(byKey('bottom-nav'), findsOneWidget);
      expect(byKey('sidebar'), findsNothing);
    });

    testWidgets('768: the strip, with the full sidebar as an overlay', (
      tester,
    ) async {
      await pumpProjects(
        tester,
        projects: projects,
        size: const Size(768, 900),
      );
      expect(byKey('bottom-nav'), findsNothing);
      expect(_sidebarWidth(tester), sidebarStripWidth);

      await tester.tap(byKey('open-sidebar'));
      await tester.pumpAndSettle();
      expect(find.byType(Drawer), findsOneWidget);
      expect(find.text('Website'), findsWidgets);
    });

    for (final width in [1280.0, 1920.0]) {
      testWidgets('$width: the open sidebar', (tester) async {
        await pumpProjects(tester, projects: projects, size: Size(width, 1000));
        expect(_sidebarWidth(tester), sidebarWidth);
        expect(find.text('Website'), findsOneWidget);
      });
    }
  });

  group('collapsing', () {
    testWidgets('the toggle and "[" collapse it, and the choice is kept', (
      tester,
    ) async {
      final app = await pumpProjects(tester, projects: projects);
      await tester.tap(byKey('sidebar-toggle'));
      await tester.pumpAndSettle();
      expect(_sidebarWidth(tester), sidebarStripWidth);
      expect(app.container.read(navPrefsProvider).collapsed, isTrue);

      await _key(tester, LogicalKeyboardKey.bracketLeft);
      expect(_sidebarWidth(tester), sidebarWidth);
      expect(app.container.read(navPrefsProvider).collapsed, isFalse);
    });

    testWidgets('"[" is ignored while typing in a field', (tester) async {
      await pumpProjects(tester, projects: projects);
      await tester.tap(byKey('open-search'));
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.bracketLeft);
      await tester.pumpAndSettle();
      expect(_sidebarWidth(tester), sidebarWidth);
    });
  });

  group('keyboard', () {
    testWidgets('the arrows walk the sidebar and Enter opens a page', (
      tester,
    ) async {
      final app = await pumpProjects(tester, projects: projects);
      await _tabTo(tester, 'open-inbox');
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(_where(app), '/chat');
    });

    testWidgets('focus returns to the same item after Enter opens a page', (
      tester,
    ) async {
      await pumpProjects(tester, projects: projects);
      await _tabTo(tester, 'open-inbox');
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      final focused = find
          .descendant(of: byKey('open-chat'), matching: find.byType(Focus))
          .evaluate()
          .any((e) => (e.widget as Focus).focusNode?.hasPrimaryFocus ?? false);
      expect(focused, isTrue);
    });

    testWidgets('Tab stays in the sidebar before it reaches the page', (
      tester,
    ) async {
      await pumpProjects(tester, projects: projects);
      await _tabTo(tester, 'project-p3');
      // The last project is reached before anything of the page (x > sidebar).
      final focus = FocusManager.instance.primaryFocus!;
      expect(focus.rect.left, lessThan(sidebarWidth));
    });
  });

  group('go-to keys', () {
    testWidgets('g then c opens Chat, g then i the inbox', (tester) async {
      final app = await pumpProjects(tester, projects: projects);
      await _key(tester, LogicalKeyboardKey.keyG);
      await _key(tester, LogicalKeyboardKey.keyC);
      expect(_where(app), '/chat');

      await _key(tester, LogicalKeyboardKey.keyG);
      await _key(tester, LogicalKeyboardKey.keyI);
      expect(_where(app), '/inbox');
    });

    testWidgets('g then a letter nobody has does nothing', (tester) async {
      final app = await pumpProjects(tester, projects: projects);
      await _key(tester, LogicalKeyboardKey.keyG);
      await _key(tester, LogicalKeyboardKey.keyZ);
      expect(_where(app), '/');
    });

    testWidgets('the cheat sheet lists the go-to keys', (tester) async {
      await pumpProjects(tester, projects: projects);
      await tester.tap(byKey('open-help'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        byKey('go-nav.chat'),
        100,
        scrollable: find.descendant(
          of: find.byType(Dialog),
          matching: find.byType(Scrollable),
        ),
      );
      expect(byKey('go-nav.chat'), findsOneWidget);
    });
  });

  group('permissions', () {
    testWidgets('the Owner finds Audit under Admin, a Viewer does not', (
      tester,
    ) async {
      await pumpProjects(tester, projects: projects);
      await tester.tap(byKey('section-admin'));
      await tester.pumpAndSettle();
      expect(byKey('nav-audit'), findsOneWidget);
      expect(byKey('nav-import'), findsOneWidget);
    });

    testWidgets('a Viewer has neither, and no Create project', (tester) async {
      await pumpProjects(tester, projects: projects, role: 'Viewer');
      await tester.tap(byKey('section-admin'));
      await tester.pumpAndSettle();
      expect(byKey('nav-audit'), findsNothing);
      expect(byKey('nav-import'), findsNothing);
      expect(byKey('new-project'), findsNothing);
    });

    test('nothing gated shows before the permission answer is in', () {
      final item = navItems.firstWhere((i) => i.id == 'audit');
      final loading = NavAccess(
        permissions: Permissions.none,
        ready: false,
        systemAdmin: false,
      );
      expect(loading.allows(item), isFalse);
      expect(
        loading.visible(NavSection.main).map((i) => i.id),
        containsAll(['home', 'inbox', 'chat']),
      );
      expect(
        loading.visible(NavSection.admin).map((i) => i.id),
        isNot(contains('audit')),
      );
    });

    test('the system page needs the server to answer for it', () {
      final item = navItems.firstWhere((i) => i.id == 'system');
      const none = Permissions.none;
      expect(
        const NavAccess(
          permissions: none,
          ready: true,
          systemAdmin: false,
        ).allows(item),
        isFalse,
      );
      expect(
        const NavAccess(
          permissions: none,
          ready: true,
          systemAdmin: true,
        ).allows(item),
        isTrue,
      );
    });
  });

  group('projects in the sidebar', () {
    testWidgets('favourites come first, then the rest by name', (tester) async {
      await pumpProjects(tester, projects: projects);
      expect(find.text('Favorites'), findsOneWidget);
      expect(top(tester, 'project-p2'), lessThan(top(tester, 'project-p1')));
      expect(top(tester, 'project-p1'), lessThan(top(tester, 'project-p3')));
    });

    testWidgets('a saved order is followed', (tester) async {
      final app = await pumpProjects(tester, projects: projects);
      app.container.read(navPrefsProvider.notifier).setOrder(['p3', 'p1']);
      await tester.pumpAndSettle();
      expect(top(tester, 'project-p3'), lessThan(top(tester, 'project-p1')));
    });

    testWidgets('a project that was opened shows under Recent', (tester) async {
      await pumpProjects(tester, projects: projects);
      final inSidebar = find.descendant(
        of: byKey('sidebar'),
        matching: find.text('Recent'),
      );
      expect(inSidebar, findsNothing);
      await tester.tap(byKey('project-p3'));
      await tester.pumpAndSettle();
      expect(inSidebar, findsOneWidget);
      expect(byKey('recent-p3'), findsOneWidget);
    });

    testWidgets('the … menu favourites a project', (tester) async {
      final app = await pumpProjects(tester, projects: projects);
      await _hover(tester, byKey('project-p1'));
      await tester.tap(byKey('project-menu-p1'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Add favorite'));
      await tester.pumpAndSettle();
      // Both favourites now sit above the rest.
      expect(top(tester, 'project-p1'), lessThan(top(tester, 'project-p3')));
      expect(
        app.projects.projects.firstWhere((p) => p.id == 'p1').isFavorite,
        isTrue,
      );
    });

    testWidgets('F2 renames the focused project', (tester) async {
      final app = await pumpProjects(tester, projects: projects);
      await _tabTo(tester, 'project-p1');
      await _key(tester, LogicalKeyboardKey.f2);
      expect(byKey('rename-project-field'), findsOneWidget);
      await tester.enterText(byKey('rename-project-field'), 'Site');
      await tester.tap(byKey('rename-project-save'));
      await tester.pumpAndSettle();
      expect(find.text('Site'), findsWidgets);
      expect(
        app.projects.projects.firstWhere((p) => p.id == 'p1').name,
        'Site',
      );
    });

    testWidgets('500 projects stay a lazy list', (tester) async {
      await pumpProjects(
        tester,
        projects: [for (var i = 0; i < 500; i++) project('x$i', 'Project $i')],
      );
      final built = find.byType(SidebarItem).evaluate().length;
      expect(built, lessThan(80));
    });
  });

  group('create menu', () {
    testWidgets('offers what the Owner can create', (tester) async {
      await pumpProjects(tester, projects: projects);
      await tester.tap(byKey('create-menu'));
      await tester.pumpAndSettle();
      expect(find.text('Create a project'), findsOneWidget);
      expect(find.text('Create a doc'), findsOneWidget);
      expect(find.text('New'), findsOneWidget);
    });

    testWidgets('leaves out what a Viewer cannot', (tester) async {
      await pumpProjects(tester, projects: projects, role: 'Viewer');
      await tester.tap(byKey('create-menu'));
      await tester.pumpAndSettle();
      expect(find.text('Create a project'), findsNothing);
    });
  });

  group('breadcrumbs', () {
    testWidgets('workspace › project › view on a project page', (tester) async {
      final app = await pumpProjects(tester, projects: projects);
      await app.go(tester, '/projects/p1');
      final trail = byKey('breadcrumbs');
      expect(
        find.descendant(of: trail, matching: find.text('WS w1')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: trail, matching: find.text('Website')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: trail, matching: find.text('List')),
        findsOneWidget,
      );
    });

    testWidgets('a link segment goes there', (tester) async {
      final app = await pumpProjects(tester, projects: projects);
      await app.go(tester, '/projects/p1/sprints');
      await tester.tap(
        find.descendant(
          of: byKey('breadcrumbs'),
          matching: find.text('Website'),
        ),
      );
      await tester.pumpAndSettle();
      expect(_where(app), '/projects/p1');
    });

    testWidgets('a long trail folds its middle on a narrow bar', (
      tester,
    ) async {
      final app = await pumpProjects(
        tester,
        projects: projects,
        size: const Size(700, 900),
      );
      await app.go(tester, '/projects/p1?view=board&task=t1');
      expect(byKey('crumbs-fold'), findsOneWidget);
    });
  });

  group('phone', () {
    testWidgets('More lists every place the bar has no room for', (
      tester,
    ) async {
      await pumpProjects(
        tester,
        projects: projects,
        size: const Size(360, 800),
      );
      await tester.tap(byKey('more-tab'));
      await tester.pumpAndSettle();
      for (final id in ['calendar', 'goals', 'docs', 'audit', 'import']) {
        await tester.scrollUntilVisible(
          byKey('more-$id'),
          80,
          scrollable: find.descendant(
            of: byKey('more-sheet'),
            matching: find.byType(Scrollable),
          ),
        );
        expect(byKey('more-$id'), findsOneWidget, reason: id);
      }
    });

    testWidgets('the title opens a searchable project switcher', (
      tester,
    ) async {
      final app = await pumpProjects(
        tester,
        projects: projects,
        size: const Size(360, 800),
      );
      await app.go(tester, '/projects/p1');
      await tester.tap(byKey('project-switcher'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.descendant(
          of: byKey('switcher-search'),
          matching: find.byType(EditableText),
        ),
        'zeb',
      );
      await tester.pumpAndSettle();
      expect(byKey('switch-project-p3'), findsOneWidget);
      expect(byKey('switch-project-p1'), findsNothing);
      await tester.tap(byKey('switch-project-p3'));
      await tester.pumpAndSettle();
      expect(_where(app), '/projects/p3');
    });
  });

  group('every frame entry opens its page', () {
    testWidgets('the fixed and workspace entries navigate', (tester) async {
      final app = await pumpProjects(tester, projects: projects);
      await tester.tap(byKey('section-workspace'));
      await tester.pumpAndSettle();
      for (final id in [
        'inbox',
        'chat',
        'dashboards',
        'goals',
        'docs',
        'calendar',
        'workload',
        'timesheet',
        'forms',
        'templates',
      ]) {
        final item = navItems.firstWhere((i) => i.id == id);
        await tester.tap(byKey(sidebarKey(item)));
        await tester.pumpAndSettle();
        expect(_where(app), startsWith(item.path), reason: id);
      }
    });
  });

  testWidgets('a workspace switch keeps the page type', (tester) async {
    final app = await pumpProjects(
      tester,
      projects: projects,
      workspaces: ['w1', 'w2'],
    );
    await app.go(tester, '/docs/d1');
    app.container.read(selectedWorkspaceIdProvider.notifier).select('w2');
    await tester.pumpAndSettle();
    expect(_where(app), '/docs');
  });

  group('large text', () {
    for (final width in [360.0, 768.0, 1280.0]) {
      testWidgets('200% text at $width wide does not overflow', (tester) async {
        tester.platformDispatcher.textScaleFactorTestValue = 2;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        final app = await pumpProjects(
          tester,
          projects: projects,
          size: Size(width, 900),
        );
        await app.go(tester, '/projects/p1?view=board&task=t1');
        expect(tester.takeException(), isNull);
      });
    }
  });

  testWidgets('press-and-drag reorders the projects and keeps the order', (
    tester,
  ) async {
    final app = await pumpProjects(tester, projects: projects);
    expect(top(tester, 'project-p1'), lessThan(top(tester, 'project-p3')));
    final drag = await tester.startGesture(
      tester.getCenter(byKey('project-p1')),
    );
    await tester.pump(const Duration(milliseconds: 600)); // the long press
    for (var i = 0; i < 12; i++) {
      await drag.moveBy(const Offset(0, 10));
      await tester.pump(const Duration(milliseconds: 20));
    }
    await drag.up();
    await tester.pumpAndSettle();
    expect(top(tester, 'project-p3'), lessThan(top(tester, 'project-p1')));
    expect(app.container.read(navPrefsProvider).projectOrder.first, 'p3');
  });

  group('collapsed strip', () {
    for (final width in [1280.0, 1920.0]) {
      testWidgets(
        '$width: collapsed is a strip and stays after a page change',
        (tester) async {
          final app = await pumpProjects(
            tester,
            projects: projects,
            size: Size(width, 900),
          );
          await tester.tap(byKey('sidebar-toggle'));
          await tester.pumpAndSettle();
          await app.go(tester, '/inbox');
          expect(_sidebarWidth(tester), sidebarStripWidth);
        },
      );
    }
  });

  testWidgets('right-to-left: the sidebar sits on the right', (tester) async {
    final prefs = MemoryPrefs();
    await prefs.write('locale.language', 'fa');
    await pumpProjects(
      tester,
      projects: projects,
      overrides: [localPrefsProvider.overrideWithValue(prefs)],
    );
    final box = tester.getRect(byKey('sidebar'));
    expect(box.right, 1400);
    expect(box.width, sidebarWidth);
  });

  testWidgets('g then f, e and v open Forms, Templates, Developer', (
    tester,
  ) async {
    final app = await pumpProjects(tester, projects: projects);
    for (final (letter, path) in [
      (LogicalKeyboardKey.keyF, '/forms'),
      (LogicalKeyboardKey.keyE, '/templates'),
      (LogicalKeyboardKey.keyV, '/developer'),
    ]) {
      await _key(tester, LogicalKeyboardKey.keyG);
      await _key(tester, letter);
      expect(_where(app), startsWith(path));
    }
  });
}
