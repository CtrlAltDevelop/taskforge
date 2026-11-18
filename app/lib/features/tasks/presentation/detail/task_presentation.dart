import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/core/ui/theme_extension.dart';
import 'package:taskforge/core/ui/tokens/shape.dart';
import 'package:taskforge/core/ui/tokens/spacing.dart';
import 'package:taskforge/features/projects/domain/projects.dart';
import 'package:taskforge/features/tasks/application/task_detail_state.dart';
import 'package:taskforge/features/tasks/application/tasks_providers.dart';
import 'package:taskforge/features/tasks/domain/tasks.dart';
import 'package:taskforge/features/tasks/presentation/detail/task_screen.dart';

/// The window of a modal never grows past this, nor past the screen less a
/// margin.
const modalMaxWidth = 1200.0;
const modalMaxHeight = 900.0;
const modalMargin = TfSpace.xl;

/// How wide the drag handle of a side panel is.
const _peekGrip = 8.0;

/// The chrome around one [TaskScreen]: a centred window ([modal]), a panel at
/// the side of the list ([peek]) or a page of its own ([page]). Moving to
/// another task (previous/next, a breadcrumb, a subtask) changes [current]
/// and nothing else moves. It also tells the action registry what Esc, `[`
/// and `]` do while it is on top.
class TaskPresentation extends ConsumerStatefulWidget {
  const TaskPresentation({
    super.key,
    required this.project,
    required this.current,
    required this.kind,
    required this.onClose,
    required this.onOpen,
    required this.onKind,
  });

  final Project project;

  /// The id of the task shown; null once it is closing.
  final ValueListenable<String?> current;
  final TaskPresentationKind kind;
  final VoidCallback onClose;
  final void Function(String taskId) onOpen;
  final void Function(TaskPresentationKind) onKind;

  @override
  ConsumerState<TaskPresentation> createState() => _TaskPresentationState();
}

class _TaskPresentationState extends ConsumerState<TaskPresentation> {
  late final _commands = ref.read(taskCommandsProvider);
  Route<dynamic>? _route;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _route = ModalRoute.of(context);
    _commands
      ..route = _route
      ..close = widget.onClose
      ..previous = (() => _step(-1))
      ..next = (() => _step(1));
  }

  @override
  void dispose() {
    _commands.clearPresentation(_route);
    super.dispose();
  }

  /// The tasks as the project lists them, for previous and next.
  List<Task> get _order => ref.read(taskListProvider(widget.project.id)).tasks;

  int _index(List<Task> order) =>
      order.indexWhere((t) => t.id == widget.current.value);

  void _step(int by) {
    final order = _order;
    final at = _index(order);
    final to = at + by;
    if (at < 0 || to < 0 || to >= order.length) return;
    widget.onOpen(order[to].id);
  }

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<String?>(
    valueListenable: widget.current,
    builder: (context, id, _) {
      if (id == null) return const SizedBox.shrink();
      final order = ref.watch(
        taskListProvider(widget.project.id).select((s) => s.tasks),
      );
      final at = order.indexWhere((t) => t.id == id);
      final screen = TaskScreen(
        key: ValueKey(id),
        project: widget.project,
        taskId: id,
        kind: widget.kind,
        onClose: widget.onClose,
        onOpen: (t) => widget.onOpen(t.id),
        onKind: widget.onKind,
        onPrevious: at > 0 ? () => _step(-1) : null,
        onNext: at >= 0 && at < order.length - 1 ? () => _step(1) : null,
      );
      return switch (widget.kind) {
        TaskPresentationKind.modal => _ModalCard(child: screen),
        TaskPresentationKind.peek => _PeekPane(child: screen),
        TaskPresentationKind.page => Scaffold(
          backgroundColor: context.tf.colors.canvas,
          body: SafeArea(child: screen),
        ),
      };
    },
  );
}

/// The centred window: as wide as is useful, never past the screen.
class _ModalCard extends StatelessWidget {
  const _ModalCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final c = context.tf.colors;
    return LayoutBuilder(
      builder: (context, box) => Center(
        child: SizedBox(
          width: math.min(box.maxWidth - 2 * modalMargin, modalMaxWidth),
          height: math.min(box.maxHeight - 2 * modalMargin, modalMaxHeight),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: TfRadius.dialog,
              boxShadow: TfShadow.modal,
            ),
            child: Material(
              key: const Key('task-modal'),
              color: c.raised,
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: TfRadius.dialog,
                side: BorderSide(color: c.border, width: tfHairline),
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

/// The side panel beside a wide list: its width follows the drag handle on
/// the edge facing the list and is remembered.
class _PeekPane extends ConsumerWidget {
  const _PeekPane({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.tf.colors;
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final width = ref.watch(peekWidthProvider);
    final notifier = ref.read(peekWidthProvider.notifier);
    return SizedBox(
      width: width,
      child: Stack(
        children: [
          Positioned.fill(
            child: Material(
              color: c.raised,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: BorderDirectional(
                    start: BorderSide(color: c.border, width: tfHairline),
                  ),
                ),
                child: child,
              ),
            ),
          ),
          PositionedDirectional(
            start: 0,
            top: 0,
            bottom: 0,
            width: _peekGrip,
            child: MouseRegion(
              cursor: SystemMouseCursors.resizeColumn,
              child: GestureDetector(
                key: const Key('peek-resize'),
                behavior: HitTestBehavior.translucent,
                onHorizontalDragUpdate: (d) =>
                    notifier.resize(width + (rtl ? d.delta.dx : -d.delta.dx)),
                onHorizontalDragEnd: (_) => notifier.remember(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
