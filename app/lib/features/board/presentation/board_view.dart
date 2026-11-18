import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/features/home/application/home_providers.dart';
import 'package:taskforge/features/board/application/board_providers.dart';
import 'package:taskforge/features/board/domain/board.dart';
import 'package:taskforge/features/board/presentation/board_card.dart';
import 'package:taskforge/features/board/presentation/board_column.dart';
import 'package:taskforge/features/board/presentation/board_controls.dart';
import 'package:taskforge/features/board/presentation/edge_scroll.dart';
import 'package:taskforge/features/fields/application/fields_providers.dart';
import 'package:taskforge/features/fields/domain/field.dart';
import 'package:taskforge/features/members/application/members_providers.dart';
import 'package:taskforge/features/members/domain/members.dart';
import 'package:taskforge/features/projects/domain/projects.dart';
import 'package:taskforge/features/roles/application/roles_providers.dart';
import 'package:taskforge/features/roles/domain/roles.dart';
import 'package:taskforge/features/sprints/application/sprints_providers.dart';
import 'package:taskforge/features/sprints/domain/sprints.dart';
import 'package:taskforge/features/tasks/domain/tasks.dart';
import 'package:taskforge/features/tasks/presentation/list_lookups.dart';
import 'package:taskforge/features/tasks/presentation/task_actions.dart';
import 'package:taskforge/features/tasks/presentation/work/add_task.dart';
import 'package:taskforge/features/tasks/presentation/work/view_search.dart';
import 'package:taskforge/features/filters/application/filters_providers.dart';
import 'package:taskforge/features/tasks/presentation/work/work_states.dart';
import 'package:taskforge/features/tasks/presentation/work/view_toolbar.dart';
import 'package:taskforge/features/views/domain/board_layout.dart';
import 'package:taskforge/features/workflows/application/workflows_providers.dart';

/// Width below which a card is picked up with a long press (touch) instead of
/// a plain drag.
const touchBreakpoint = 700.0;

/// The board: a project's top-level tasks as cards in columns (by status or
/// another field), optionally in swimlanes by assignee. Cards drag between and
/// within columns, or move through a menu.
class BoardView extends ConsumerStatefulWidget {
  const BoardView({
    super.key,
    required this.project,
    required this.onOpen,
    this.openTaskId,
  });

  final Project project;
  final void Function(Task) onOpen;

  /// The task whose detail is open, so its card can show it.
  final String? openTaskId;

  @override
  ConsumerState<BoardView> createState() => _BoardViewState();
}

class _BoardViewState extends ConsumerState<BoardView> {
  final _horizontal = ScrollController();
  final _area = GlobalKey();
  late final _edge = EdgeScroller(
    controller: _horizontal,
    axis: Axis.horizontal,
    area: _area,
    direction: () => Directionality.of(context),
  );

  String get _id => widget.project.id;

  @override
  void initState() {
    super.initState();
    // The checklist's "try the board" step: only the app sees a board open.
    Future.microtask(() {
      if (mounted) ref.read(onboardingStepsProvider.notifier).note('try_board');
    });
  }

  @override
  void dispose() {
    _edge.stop();
    _horizontal.dispose();
    super.dispose();
  }

  ListLookups _lookups() => ListLookups(
    flow: ref.watch(workflowProvider(_id)).value,
    members: ref.watch(membersProvider).value ?? const <Member>[],
    fields: ref.watch(fieldsProvider(_id)).value ?? const <CustomField>[],
  );

  Future<void> _drop(
    BoardDrag drag,
    String laneKey,
    String column, {
    required String beforeId,
    required String afterId,
  }) async {
    final messenger = ScaffoldMessenger.of(context);
    final board = ref.read(boardProvider(_id).notifier);
    Future<void> send({bool override = false}) => board.move(
      drag.task,
      laneKey: laneKey,
      column: column,
      beforeId: beforeId,
      afterId: afterId,
      overrideBlocked: override,
    );
    try {
      await send();
    } on TaskException catch (e) {
      if (e.failure == TaskFailure.blocked && mounted) {
        if (!await askOverride(context, e)) return;
        try {
          await send(override: true);
        } on TaskException catch (again) {
          _refuse(messenger, again);
        }
        return;
      }
      _refuse(messenger, e);
    }
  }

  void _refuse(ScaffoldMessengerState messenger, TaskException e) => messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        key: const Key('move-refused'),
        content: Text(taskErrorMessage(e, context.l10n)),
      ),
    );

  Future<void> _add(String title, String laneKey, String column) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref
          .read(boardProvider(_id).notifier)
          .add(title, laneKey: laneKey, column: column);
    } on TaskException catch (e) {
      _refuse(messenger, e);
    }
  }

  /// "Current sprint" is offered when the project has Sprints on and one is
  /// active (it stays while the filter is on, so it can be switched off).
  bool _sprintFilterOffered() {
    if (!widget.project.enabledFeatures.contains(sprintsFeature)) return false;
    final sprints = ref.watch(sprintsProvider(_id)).value;
    return ref.watch(boardCurrentSprintProvider(_id)) ||
        (sprints?.any((s) => s.isActive) ?? false);
  }

  @override
  Widget build(BuildContext context) {
    final layout = ref.watch(boardLayoutProvider(_id)).layout;
    final state = ref.watch(boardProvider(_id));
    final lookups = _lookups();
    final permissions = ref.watch(permissionSetProvider);
    final editable = !widget.project.isArchived;
    final canMove = editable && permissions.can(Perm.taskUpdate);
    final canCreate = editable && permissions.can(Perm.taskCreate);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ViewToolbar(
          key: const Key('board-toolbar'),
          projectId: _id,
          canShare: editable && permissions.can(Perm.projectUpdate),
          group: BoardColumnsMenu(projectId: _id, lookups: lookups),
          fields: BoardFieldsMenu(projectId: _id, lookups: lookups),
          specific: boardSpecificControls(
            context,
            ref,
            _id,
            sprintFilter: _sprintFilterOffered(),
          ),
          onAddTask: canCreate ? () => runNewTask(context, ref) : null,
        ),
        Expanded(
          child: state.error != null && state.lanes.isEmpty
              ? WorkError(
                  error: state.error!,
                  retryKey: const Key('retry-board'),
                  onRetry: () => ref.read(boardProvider(_id).notifier).load(),
                )
              : state.loading && state.lanes.isEmpty
              ? const BoardSkeleton()
              : _board(context, state, layout, lookups, canMove, canCreate),
        ),
      ],
    );
  }

  Widget _board(
    BuildContext context,
    BoardState state,
    BoardLayout layout,
    ListLookups lookups,
    bool canMove,
    bool canCreate,
  ) {
    final collapsed = ref.watch(collapsedColumnsProvider(_id));
    final touch = MediaQuery.sizeOf(context).width < touchBreakpoint;
    final query = ref.watch(viewSearchProvider(_id));
    final lanes = query.isEmpty
        ? state.lanes
        : [
            for (final lane in state.lanes)
              lane.mapColumns((c) {
                final shown = searched(c.tasks, query);
                return c.copyWith(tasks: shown, count: shown.length);
              }),
          ];
    final cards = lanes.fold(
      0,
      (n, lane) => lane.columns.fold(n, (m, c) => m + c.count),
    );
    final narrowed =
        query.isNotEmpty || !ref.watch(activeFilterProvider(_id)).query.isEmpty;
    // Filters or search hide every card: say so (an empty project keeps its
    // columns, which hold the "add" fields).
    if (cards == 0 && narrowed && !state.loading) {
      return WorkEmpty(projectId: _id);
    }
    final choices = <MoveChoice>[
      for (final c in lanes.firstOrNull?.columns ?? const <BoardColumn>[])
        (
          key: c.key,
          label: lookups.groupLabel(layout.groupBy, c.key, context.l10n),
        ),
    ];
    Widget columns(BoardLane lane) => Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final column in lane.columns)
          BoardColumnView(
            key: ValueKey('${lane.key}|${column.key}'),
            laneKey: lane.key,
            column: column,
            title: lookups.groupLabel(layout.groupBy, column.key, context.l10n),
            color: lookups.groupColor(layout.groupBy, column.key),
            limit: layout.limits[column.key],
            collapsed: collapsed.contains(column.key),
            canMove: canMove,
            longPressDrag: touch,
            lookups: lookups,
            cardFields: layout.cardFields,
            openTaskId: widget.openTaskId,
            moveChoices: choices,
            onOpen: widget.onOpen,
            onDrop: (drag, {required beforeId, required afterId}) => _drop(
              drag,
              lane.key,
              column.key,
              beforeId: beforeId,
              afterId: afterId,
            ),
            onMoveTo: (task, to) => _drop(
              BoardDrag(task, lane.key),
              lane.key,
              to,
              beforeId: '',
              afterId: '',
            ),
            onDragMove: _edge.follow,
            onDragEnd: _edge.stop,
            onLoadMore: () => ref
                .read(boardProvider(_id).notifier)
                .loadMore(lane.key, column.key),
            onSetLimit: (limit) => ref
                .read(boardLayoutProvider(_id).notifier)
                .update((l) => l.withLimit(column.key, limit)),
            onToggleCollapse: () => ref
                .read(collapsedColumnsProvider(_id).notifier)
                .toggle(column.key),
            onAdd: canCreate
                ? (title) => _add(title, lane.key, column.key)
                : null,
          ),
      ],
    );
    final Widget content = layout.swimlane.isEmpty
        ? columns(lanes.first)
        : SingleChildScrollView(
            key: const Key('board-lanes'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final lane in lanes) ...[
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                      12,
                      12,
                      12,
                      0,
                    ),
                    child: Text(
                      lane.key.isEmpty
                          ? context.l10n.grpFUnassigned
                          : lookups.person(lane.key),
                      key: Key('lane-${lane.key}'),
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                  SizedBox(height: 380, child: columns(lane)),
                ],
              ],
            ),
          );
    return Scrollbar(
      key: _area,
      controller: _horizontal,
      child: SingleChildScrollView(
        key: const Key('board-scroll'),
        controller: _horizontal,
        scrollDirection: Axis.horizontal,
        child: content,
      ),
    );
  }
}
