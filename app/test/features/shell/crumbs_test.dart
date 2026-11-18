import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskforge/features/shell/crumbs.dart';
import 'package:taskforge/features/shell/nav_items.dart';
import 'package:taskforge/l10n/gen/app_localizations.dart';

void main() {
  final l = lookupAppLocalizations(const Locale('en'));
  List<String> trail(String uri, {NameOf? names}) => [
    for (final c in crumbsFor(
      Uri.parse(uri),
      l,
      workspace: 'Acme',
      nameOf: names ?? (_, _) => null,
    ))
      c.path == null ? '${c.label}.' : c.label,
  ];

  String? named(String kind, String id) => kind == 'project' ? 'Website' : null;

  group('every route family', () {
    final cases = <String, List<String>>{
      '/': ['Acme', 'Home.'],
      '/inbox': ['Acme', 'Inbox.'],
      '/inbox/preferences': ['Acme', 'Notification settings.'],
      '/chat': ['Acme', 'Chat.'],
      '/chat/s1': ['Acme', 'Chat', 'Space.'],
      '/docs/d1': ['Acme', 'Docs', 'Doc.'],
      '/goals/g1': ['Acme', 'Goals', 'Goal.'],
      '/forms/new': ['Acme', 'Forms', 'New form.'],
      '/forms/f1': ['Acme', 'Forms', 'Edit form.'],
      '/forms/f1/submissions': ['Acme', 'Forms', 'Edit form', 'Submissions.'],
      '/workload/settings': [
        'Acme',
        'Workload',
        'Capacity, time off and holidays.',
      ],
      '/developer/webhooks/w1': ['Acme', 'Developer', 'Deliveries.'],
      '/settings/security': ['Acme', 'Security.'],
      '/settings/sso': ['Acme', 'Security', 'Single sign-on.'],
      '/workspaces/new': ['Acme', 'Create a workspace.'],
      '/projects/archived': ['Acme', 'Archived projects.'],
    };
    cases.forEach((uri, expected) {
      test(uri, () {
        // Last segment has no link: the trail marks it with a dot.
        final got = trail(uri);
        expect(got.length, expected.length, reason: '$got');
        for (final (i, want) in expected.indexed) {
          expect(got[i], want, reason: uri);
        }
      });
    });
  });

  group('projects', () {
    test('the list view', () {
      expect(trail('/projects/p1', names: named), ['Acme', 'Website', 'List.']);
    });

    test('the board view', () {
      expect(trail('/projects/p1?view=board', names: named), [
        'Acme',
        'Website',
        'Board.',
      ]);
    });

    test('an open task adds a last segment and links the view', () {
      final crumbs = crumbsFor(
        Uri.parse('/projects/p1?view=board&task=t9'),
        l,
        workspace: 'Acme',
        nameOf: named,
      );
      expect(crumbs.map((c) => c.label), ['Acme', 'Website', 'Board', 'Task']);
      expect(crumbs[2].path, '/projects/p1?view=board');
      expect(crumbs.last.path, isNull);
    });

    test('a page of the project', () {
      expect(trail('/projects/p1/sprints', names: named), [
        'Acme',
        'Website',
        'Sprints.',
      ]);
    });

    test('an unknown project is just "Project"', () {
      expect(trail('/projects/p1'), ['Acme', 'Project', 'List.']);
    });
  });

  test('every segment but the last links, and the first is the workspace', () {
    for (final item in navItems) {
      final crumbs = crumbsFor(Uri.parse(item.path), l, workspace: 'Acme');
      expect(crumbs.first.path, '/', reason: item.path);
      expect(crumbs.last.path, isNull, reason: item.path);
      for (final c in crumbs.take(crumbs.length - 1)) {
        expect(c.path, isNotNull, reason: item.path);
      }
    }
  });
}
