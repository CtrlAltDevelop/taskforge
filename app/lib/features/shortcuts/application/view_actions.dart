import 'package:taskforge/core/actions/app_action.dart';

/// The ways to look at a project's tasks, in the order of the switcher.
const projectViews = ['list', 'board', 'calendar', 'timeline'];

String _label(String view) => view[0].toUpperCase() + view.substring(1);

/// Show the project as [view]: offered on a project page showing another one.
AppAction _show(String view, String keys) => AppAction(
  id: 'view.$view',
  title: '${_label(view)} view',
  group: 'This project',
  semanticLabel: 'Show this project as a $view',
  keywords: const ['view', 'switch', 'layout'],
  defaultKeys: keys,
  available: (c) => c.projectId != null && c.view != view,
  run: (c) => c.router.go(
    '/projects/${c.projectId}'
    '${view == 'list' ? '' : '?view=$view'}',
  ),
);

/// Actions that belong to the page they are on: the view switches, and what
/// only makes sense in one view (renaming a row is the list's).
final List<AppAction> viewActions = [
  _show('list', 'alt+1'),
  _show('board', 'alt+2'),
  _show('calendar', 'alt+3'),
  _show('timeline', 'alt+4'),
];
