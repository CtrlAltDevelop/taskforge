import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:go_router/go_router.dart';

import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/core/ui/theme_extension.dart';
import 'package:taskforge/features/board/application/board_providers.dart';
import 'package:taskforge/features/board/presentation/board_view.dart';
import 'package:taskforge/features/calendar/application/calendar_providers.dart';
import 'package:taskforge/features/calendar/presentation/calendar_view.dart';
import 'package:taskforge/features/projects/domain/projects.dart';
import 'package:taskforge/features/roles/application/roles_providers.dart';
import 'package:taskforge/features/roles/domain/roles.dart';
import 'package:taskforge/core/offline/presentation/offline_banner.dart';
import 'package:taskforge/core/sync/presentation/connection_status.dart';
import 'package:taskforge/core/sync/sync_providers.dart';
import 'package:taskforge/features/tasks/domain/tasks.dart';
import 'package:taskforge/features/timeline/application/timeline_providers.dart';
import 'package:taskforge/features/timeline/presentation/timeline_view.dart';

export 'package:taskforge/features/tasks/presentation/task_actions.dart'
    show TaskAction;
import 'package:taskforge/features/projects/application/projects_providers.dart';
import 'package:taskforge/features/tasks/application/task_detail_state.dart';
import 'package:taskforge/features/tasks/presentation/detail/task_frame.dart';
import 'package:taskforge/features/tasks/presentation/detail/task_presentation.dart';
import 'package:taskforge/features/tasks/presentation/detail/task_presenter.dart';
import 'package:taskforge/features/tasks/presentation/work/open_task.dart';
import 'package:taskforge/features/tasks/presentation/work/view_tabs.dart';
import 'package:taskforge/features/tasks/presentation/work/work_view.dart';
import 'package:taskforge/features/tasks/presentation/task_list.dart';
import 'package:taskforge/features/views/application/views_providers.dart';

export 'package:taskforge/features/tasks/presentation/quick_add.dart';
export 'package:taskforge/features/tasks/presentation/task_tile.dart';

/// Width from which the list is a table with the side panel beside it.
const wideBreakpoint = 900.0;

/// A project's tasks: the switcher, the view, and the open task. A task opens
/// as a window over the view (the default), a panel at its side, or a page
/// (a phone), always through [TaskOpenScope].
class TaskSection extends ConsumerStatefulWidget {
  const TaskSection({
    super.key,
    required this.project,
    this.initialTask,
    this.initialView,
  });

  final Project project;

  /// Open this task from the start (a link, a notification, a search hit).
  final String? initialTask;

  /// The view to start in (`list`, `board`, `calendar`, `timeline`); the list
  /// when it is null or unknown.
  final String? initialView;

  @override
  ConsumerState<TaskSection> createState() => _TaskSectionState();
}

class _TaskSectionState extends ConsumerState<TaskSection> {
  late var _view =
      WorkView.values.where((v) => v.name == widget.initialView).firstOrNull ??
      WorkView.list;

  /// The pinned layout in use as a tab (null: a plain List).
  String? _savedTab;

  /// The width of the section as last laid out, and how the open task is shown.
  var _width = 0.0;
  TaskPresentationKind? _shownKind;

  late final _presenter = TaskPresenter(
    navigator: () => Navigator.of(context, rootNavigator: true),
    builder: _routeContent,
    onClosed: _closed,
    barrierColor: () => context.tf.colors.text.withValues(alpha: 0.45),
    barrierLabel: () => context.l10n.grpDClose,
  );

  String? get _selected => _presenter.current.value;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialTask;
    if (initial != null) _showSoon(initial);
  }

  @override
  void dispose() {
    _presenter.dispose();
    super.dispose();
  }

  WorkView? _viewNamed(String? name) =>
      WorkView.values.where((v) => v.name == name).firstOrNull;

  /// The route says which view and task are on screen (the palette's actions
  /// read it there): keep it in step with what was picked.
  void _syncUrl() {
    final query = {
      'task': ?_selected,
      if (_view != WorkView.list) 'view': _view.name,
    };
    GoRouter.maybeOf(context)?.replace(
      Uri(
        path: '/projects/${widget.project.id}',
        queryParameters: query.isEmpty ? null : query,
      ).toString(),
    );
  }

  /// How the task opens at [width]: a phone gets a page; a side panel needs
  /// room for the list, else it is a window.
  TaskPresentationKind _kindFor(double width) {
    if (width < phoneBelow) return TaskPresentationKind.page;
    final chosen = ref.read(taskPresentationProvider);
    if (chosen == TaskPresentationKind.peek && width < wideBreakpoint) {
      return TaskPresentationKind.modal;
    }
    return chosen;
  }

  /// Shows [id] now. Opening another task while one is up only swaps it.
  void _show(String id, {bool animate = true}) {
    final kind = _kindFor(_width);
    _shownKind = kind;
    if (kind == TaskPresentationKind.peek) {
      setState(() => _presenter.showInline(id));
    } else {
      _presenter.show(id, kind, animate: animate);
    }
    _syncUrl();
    _refreshView();
  }

  /// From a place where the tree may be mid-build (a route change).
  void _showSoon(String id) =>
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _selected != id) _show(id, animate: false);
      });

  void _closed() {
    if (!mounted) return;
    _shownKind = null;
    setState(() {});
    _syncUrl();
    _refreshView();
  }

  void _chooseKind(TaskPresentationKind kind) {
    ref.read(taskPresentationProvider.notifier).choose(kind);
    final id = _selected;
    if (id != null) _show(id, animate: false);
  }

  @override
  void didUpdateWidget(TaskSection old) {
    super.didUpdateWidget(old);
    // The route changed under us (an action, a search hit, a link).
    if (widget.initialView != old.initialView) {
      final view = _viewNamed(widget.initialView) ?? WorkView.list;
      if (view != _view) {
        setState(() {
          _view = view;
          _savedTab = null;
        });
      }
    }
    if (widget.initialTask != old.initialTask &&
        widget.initialTask != _selected) {
      final id = widget.initialTask;
      if (id == null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _presenter.close();
        });
      } else {
        _showSoon(id);
      }
    }
  }

  /// A card shows what the detail may have just changed: read the board again
  /// when the detail closes or another task opens.
  void _refreshView() {
    switch (_view) {
      case WorkView.board:
        ref.read(boardProvider(widget.project.id).notifier).refresh();
      case WorkView.calendar:
        ref.read(calendarProvider(widget.project.id).notifier).refresh();
      case WorkView.timeline:
        ref.read(timelineProvider(widget.project.id).notifier).refresh();
      case WorkView.list:
        break;
    }
  }

  Widget _routeContent(
    BuildContext context,
    ValueListenable<String?> current,
    TaskPresentationKind kind,
  ) => Consumer(
    builder: (context, ref, _) => _presentation(
      ref.watch(projectProvider(widget.project.id)) ?? widget.project,
      kind,
    ),
  );

  Widget _presentation(Project project, TaskPresentationKind kind) =>
      TaskPresentation(
        project: project,
        current: _presenter.current,
        kind: kind,
        onClose: _presenter.close,
        onOpen: _show,
        onKind: _chooseKind,
      );

  @override
  Widget build(BuildContext context) {
    ref.watch(
      liveProjectProvider(widget.project.id),
    ); // this project's changes arrive live
    return LayoutBuilder(
      builder: (context, box) {
        final wide = box.maxWidth >= wideBreakpoint;
        _width = box.maxWidth;
        final kind = _kindFor(box.maxWidth);
        final open = _selected;
        if (open != null && _shownKind != null && kind != _shownKind) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && _selected == open) _show(open, animate: false);
          });
        }
        final permissions = ref.watch(permissionSetProvider);
        final switcher = ViewTabs(
          project: widget.project,
          view: _view,
          savedTab: _savedTab,
          canManage:
              !widget.project.isArchived && permissions.can(Perm.projectUpdate),
          onView: (v) {
            setState(() {
              _view = v;
              _savedTab = null;
            });
            _syncUrl();
          },
          onSavedTab: (v) {
            ref
                .read(listLayoutProvider(widget.project.id).notifier)
                .useShared(v);
            setState(() {
              _view = WorkView.list;
              _savedTab = v.id;
            });
            _syncUrl();
          },
        );
        // Every view opens a task through [openTask]: one door.
        Widget body(BuildContext inner) {
          void openIt(Task t) => openTask(inner, t);
          return switch (_view) {
            WorkView.board => BoardView(
              project: widget.project,
              openTaskId: open,
              onOpen: openIt,
            ),
            WorkView.timeline => TimelineView(
              project: widget.project,
              openTaskId: open,
              onOpen: openIt,
            ),
            WorkView.calendar => CalendarView(
              scope: widget.project.id,
              archived: widget.project.isArchived,
              openTaskId: open,
              onOpen: openIt,
            ),
            WorkView.list => TaskListView(
              project: widget.project,
              wide: wide,
              selected: open,
              onOpen: openIt,
            ),
          };
        }

        // Always a Row, so opening or closing the side panel keeps the view
        // (its scroll position, focus and picked rows) where it is.
        return TaskOpenScope(
          open: (t) => _show(t.id),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const ConnectionBanner(),
              const OfflineBanner(),
              switcher,
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(child: Builder(builder: body)),
                    if (open != null && kind == TaskPresentationKind.peek)
                      _presentation(widget.project, kind),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
