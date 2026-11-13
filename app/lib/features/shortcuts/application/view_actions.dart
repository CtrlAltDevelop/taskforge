import 'package:taskforge/core/actions/app_action.dart';
import 'package:taskforge/features/shortcuts/application/action_groups.dart';

/// The ways to look at a project's tasks, in the order of the switcher.
const projectViews = ['list', 'board', 'calendar', 'timeline'];

/// Show the project as [view]: offered on a project page showing another one.
AppAction _show(String view, String keys) => AppAction(
  id: 'view.$view',
  titleOf: (l) => switch (view) {
    'list' => l.grpKViewList,
    'board' => l.grpKViewBoard,
    'calendar' => l.grpKViewCalendar,
    _ => l.grpKViewTimeline,
  },
  groupOf: groupThisProject,
  semanticOf: (l) => switch (view) {
    'list' => l.grpKShowList,
    'board' => l.grpKShowBoard,
    'calendar' => l.grpKShowCalendar,
    _ => l.grpKShowTimeline,
  },
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
