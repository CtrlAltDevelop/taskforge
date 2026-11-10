import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/features/board/application/board_providers.dart';
import 'package:taskforge/features/board/domain/board.dart';
import 'package:taskforge/features/board/presentation/board_card.dart';
import 'package:taskforge/features/board/presentation/board_column.dart';
import 'package:taskforge/features/board/presentation/board_toolbar.dart';
import 'package:taskforge/features/board/presentation/edge_scroll.dart';
import 'package:taskforge/features/fields/application/fields_providers.dart';
import 'package:taskforge/features/fields/domain/field.dart';
import 'package:taskforge/features/members/application/members_providers.dart';
import 'package:taskforge/features/members/domain/members.dart';
import 'package:taskforge/features/projects/domain/projects.dart';
import 'package:taskforge/features/roles/application/roles_providers.dart';
import 'package:taskforge/features/roles/domain/roles.dart';
import 'package:taskforge/features/tasks/domain/tasks.dart';
import 'package:taskforge/features/tasks/presentation/list_lookups.dart';
import 'package:taskforge/features/tasks/presentation/task_actions.dart';
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
        content: Text(taskErrorMessage(e)),
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
        BoardToolbar(projectId: _id, lookups: lookups),
        Expanded(
          child: state.error != null && state.lanes.isEmpty
              ? Center(
                  child: TextButton(
                    key: const Key('retry-board'),
                    onPressed: () =>
                        ref.read(boardProvider(_id).notifier).load(),
                    child: Text('${taskErrorMessage(state.error!)} Retry'),
                  ),
                )
              : state.loading && state.lanes.isEmpty
              ? const Center(
                  key: Key('board-loading'),
                  child: CircularProgressIndicator(),
                )
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
    final lanes = state.lanes;
    final choices = <MoveChoice>[
      for (final c in lanes.firstOrNull?.columns ?? const <BoardColumn>[])
        (key: c.key, label: lookups.groupLabel(layout.groupBy, c.key)),
    ];
    Widget columns(BoardLane lane) => Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final column in lane.columns)
          BoardColumnView(
            key: ValueKey('${lane.key}|${column.key}'),
            laneKey: lane.key,
            column: column,
            title: lookups.groupLabel(layout.groupBy, column.key),
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
                          ? 'Unassigned'
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
