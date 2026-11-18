import 'package:flutter/foundation.dart';

import 'package:taskforge/features/shell/nav_items.dart';
import 'package:taskforge/l10n/gen/app_localizations.dart';

/// One step of the breadcrumb trail; the last one has no [path].
@immutable
class Crumb {
  const Crumb(this.label, [this.path]);

  final String label;
  final String? path;

  @override
  bool operator ==(Object other) =>
      other is Crumb && other.label == label && other.path == path;

  @override
  int get hashCode => Object.hash(label, path);

  @override
  String toString() => path == null ? label : '$label→$path';
}

/// The name of a project, doc, goal, chat space, form or task by id, when it
/// is already loaded; null falls back to a generic word.
typedef NameOf = String? Function(String kind, String id);

String? _noNames(String kind, String id) => null;

/// Workspace › Project › View (› Task), or Workspace › Section › Item, for
/// any in-app [uri]. Every crumb but the last links to its page.
List<Crumb> crumbsFor(
  Uri uri,
  AppLocalizations l, {
  required String workspace,
  NameOf nameOf = _noNames,
}) {
  final root = Crumb(workspace, '/');
  final path = uri.path;
  final s = uri.pathSegments.where((p) => p.isNotEmpty).toList();
  if (path == '/' || s.isEmpty) return [root, Crumb(l.grpKTHome)];
  if (s.first == 'projects' && s.length >= 2 && activeNavItem(path) == null) {
    return [root, ..._projectCrumbs(uri, s, l, nameOf)];
  }
  if (path == '/settings/sso') {
    return [root, Crumb(l.secTitle, '/settings/security'), Crumb(l.ssoTitle)];
  }
  if (path == '/workspaces/new') return [root, Crumb(l.grpKTCreateWorkspace)];
  final item = activeNavItem(path);
  if (item == null) return [root];
  final label = item.labelOf(l);
  if (item.path == path) return [root, Crumb(label)];
  return [root, Crumb(label, item.path), ..._detail(item, s, l, nameOf)];
}

List<Crumb> _projectCrumbs(
  Uri uri,
  List<String> s,
  AppLocalizations l,
  NameOf nameOf,
) {
  final id = s[1];
  final home = '/projects/$id';
  final project = Crumb(nameOf('project', id) ?? l.grpHProject, home);
  if (s.length > 2) {
    final page = switch (s[2]) {
      'settings' => l.grpKTProjectSettings,
      'sprints' => l.grpKTSprints,
      'automations' => l.grpKTAutomations,
      'workflow' => l.grpKTWorkflow,
      'fields' => l.grpKTCustomFields,
      'dashboards' => l.grpKTDashboards,
      _ => null,
    };
    return [project, if (page != null) Crumb(page)];
  }
  final view = uri.queryParameters['view'] ?? 'list';
  final viewLabel = switch (view) {
    'board' => l.grpMLblViewBoard,
    'calendar' => l.grpMLblViewCalendar,
    'timeline' => l.grpMLblViewTimeline,
    _ => l.grpMLblViewList,
  };
  final task = uri.queryParameters['task'];
  if (task == null || task.isEmpty) return [project, Crumb(viewLabel)];
  final viewPath = view == 'list' ? home : '$home?view=$view';
  return [
    project,
    Crumb(viewLabel, viewPath),
    Crumb(nameOf('task', task) ?? l.shellCrumbTask),
  ];
}

List<Crumb> _detail(
  NavItem item,
  List<String> s,
  AppLocalizations l,
  NameOf nameOf,
) {
  final id = s.length > 1 ? s[1] : '';
  return switch (item.id) {
    'docs' => [Crumb(nameOf('doc', id) ?? l.shellCrumbDoc)],
    'goals' => [Crumb(nameOf('goal', id) ?? l.shellCrumbGoal)],
    'chat' => [Crumb(nameOf('space', id) ?? l.shellCrumbSpace)],
    'workload' => [Crumb(l.wlSettings)],
    'developer' => [Crumb(l.devDeliveriesTitle)],
    'forms' when id == 'new' => [Crumb(l.formsNew)],
    'forms' when s.length > 2 => [
      Crumb(nameOf('form', id) ?? l.formsEdit, '/forms/$id'),
      Crumb(l.formsSubmissions),
    ],
    'forms' => [Crumb(nameOf('form', id) ?? l.formsEdit)],
    _ => const [],
  };
}
