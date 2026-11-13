import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/core/i18n/date_picker.dart';
import 'package:taskforge/features/calendar/application/calendar_providers.dart'
    show todayProvider, trayProvider;
import 'package:taskforge/features/calendar/domain/calendar_math.dart';
import 'package:taskforge/features/calendar/presentation/calendar_tray.dart';
import 'package:taskforge/features/members/application/members_providers.dart';
import 'package:taskforge/features/projects/domain/projects.dart';
import 'package:taskforge/features/roles/application/roles_providers.dart';
import 'package:taskforge/features/roles/domain/roles.dart';
import 'package:taskforge/features/tasks/domain/tasks.dart';
import 'package:taskforge/features/timeline/application/timeline_providers.dart';
import 'package:taskforge/features/timeline/data/timeline_client.dart';
import 'package:taskforge/features/timeline/domain/timeline_math.dart';
import 'package:taskforge/features/timeline/domain/timeline_scene.dart';
import 'package:taskforge/features/timeline/presentation/timeline_chart.dart';
import 'package:taskforge/features/timeline/presentation/timeline_dialogs.dart';
import 'package:taskforge/features/timeline/presentation/timeline_export.dart';
import 'package:taskforge/features/timeline/presentation/timeline_list.dart';
import 'package:taskforge/features/timeline/presentation/timeline_painter.dart';
import 'package:taskforge/features/timeline/presentation/timeline_toolbar.dart';
import 'package:taskforge/features/workspaces/application/workspace_providers.dart';

/// Below this width the timeline opens as a list (the chart is still one tap
/// away): a phone has no room for a left panel and a time axis.
const timelineListBreakpoint = 600.0;
const _panelWidth = 220.0;

/// Tasks as bars on a time axis, with the blocking links between them. Drag a
/// bar to move it, an end to resize it; a move that would start a dependent
/// before its blocker finishes asks whether to shift the dependents too.
class TimelineView extends ConsumerStatefulWidget {
  const TimelineView({
    super.key,
    required this.project,
    required this.onOpen,
    this.openTaskId,
  });

  final Project project;
  final void Function(Task) onOpen;
  final String? openTaskId;

  @override
  ConsumerState<TimelineView> createState() => _TimelineViewState();
}

class _TimelineViewState extends ConsumerState<TimelineView> {
  final _h = ScrollController();
  final _v = ScrollController();
  final _left = ScrollController();
  final _hover = ValueNotifier<({Task? task, Dates? dates})>((
    task: null,
    dates: null,
  ));
  bool? _listChoice;
  var _syncing = false;
  ({Day origin, TimelineZoom zoom})? _centred;

  String get _id => widget.project.id;

  @override
  void initState() {
    super.initState();
    _v.addListener(() => _follow(_v, _left));
    _left.addListener(() => _follow(_left, _v));
  }

  @override
  void dispose() {
    _h.dispose();
    _v.dispose();
    _left.dispose();
    _hover.dispose();
    super.dispose();
  }

  void _follow(ScrollController from, ScrollController to) {
    if (_syncing || !from.hasClients || !to.hasClients) return;
    final target = from.offset.clamp(0.0, to.position.maxScrollExtent);
    if (target == to.offset) return;
    _syncing = true;
    to.jumpTo(target);
    _syncing = false;
  }

  void _say(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  /// Scrolls so [anchor] is in the middle whenever the chart's range or zoom
  /// changes (the first read, a step through time, a new zoom).
  void _centre(TimeAxis axis, TimelineZoom zoom, Day anchor) {
    final key = (origin: axis.origin, zoom: zoom);
    if (_centred == key) return;
    _centred = key;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_h.hasClients) return;
      final width = _h.position.viewportDimension;
      final max = _h.position.maxScrollExtent;
      _h.jumpTo((axis.xOf(anchor) - width / 2).clamp(0.0, max));
    });
  }

  Future<void> _move(Task task, Dates dates, {bool fromTray = false}) async {
    final notifier = ref.read(timelineProvider(_id).notifier);
    final tray = fromTray ? ref.read(trayProvider(_id).notifier) : null;
    tray?.remove(task.id);
    try {
      final plan = await notifier.propose(task, dates);
      if (plan == null || !mounted) return;
      final choice = await askShift(context, plan);
      switch (choice) {
        case ShiftChoice.shift:
          await notifier.shiftDependents(plan);
        case ShiftChoice.keep:
          await notifier.keepDependents(plan);
          if (mounted) _say(context.l10n.grpIMovedLinksBreak);
        case ShiftChoice.cancel:
          notifier.discard(plan);
          tray?.restore(task);
      }
    } on TaskException catch (e) {
      tray?.restore(task);
      if (mounted) _say(taskErrorMessage(e, context.l10n));
    }
  }

  Future<void> _schedule(Task task) async {
    final picked = await showAppDatePicker(
      context: context,
      initialDate: ref.read(todayProvider),
      firstDate: day(2000, 1, 1),
      lastDate: day(2100, 12, 31),
    );
    if (picked == null) return;
    final d = dayOf(picked);
    await _move(task, Dates(start: d, due: d), fromTray: true);
  }

  void _openTray(bool canMove) => showModalBottomSheet<void>(
    context: context,
    builder: (sheet) => SizedBox(
      height: 420,
      child: CalendarTray(
        projectId: _id,
        canMove: canMove,
        draggable: false,
        onOpen: (t) {
          Navigator.pop(sheet);
          widget.onOpen(t);
        },
        onSchedule: (t) {
          Navigator.pop(sheet);
          _schedule(t);
        },
      ),
    ),
  );

  Future<void> _editWorkingDays(WorkingDays current) async {
    final chosen = await editWorkingDays(context, current);
    if (chosen == null || !mounted) return;
    final workspace = ref.read(workspaceScopeProvider);
    if (workspace == null) return;
    try {
      await ref.read(timelineClientProvider).setWorkingDays(workspace, chosen);
      ref.invalidate(workingDaysProvider);
    } on TaskException catch (e) {
      if (mounted) _say(taskErrorMessage(e, context.l10n));
    }
  }

  Future<void> _export(TimelineScene scene, TimelineZoom zoom) async {
    final scheme = Theme.of(context).colorScheme;
    final style = Theme.of(context).textTheme.bodySmall ?? const TextStyle();
    final today = ref.read(todayProvider);
    final bytes = await renderTimelinePng(
      scene: scene,
      zoom: zoom,
      scheme: scheme,
      textStyle: style.copyWith(color: scheme.onSurface),
      today: today,
    );
    final saved = await FilePicker.saveFile(
      fileName: 'timeline-${widget.project.key}.png',
      bytes: bytes,
      mimeType: 'image/png',
    );
    if (saved != null && mounted) _say(context.l10n.grpITimelineSaved);
  }

  bool Function(Day) _nonWorking(WorkingDays w) {
    final off = w.holidays.toSet();
    return (d) => !w.days.contains(d.weekday - 1) || off.contains(formatDay(d));
  }

  @override
  Widget build(BuildContext context) {
    final layout = ref.watch(timelineLayoutProvider(_id)).layout;
    final state = ref.watch(timelineProvider(_id));
    final anchor = ref.watch(timelineAnchorProvider(_id));
    final critical = ref.watch(criticalPathProvider(_id)).value ?? const {};
    final days = ref.watch(workingDaysProvider).value ?? const WorkingDays();
    final today = ref.watch(todayProvider);
    final members = ref.watch(membersProvider).value ?? const [];
    final permissions = ref.watch(permissionSetProvider);
    final archived = widget.project.isArchived;
    final canMove = !archived && permissions.can(Perm.taskUpdate);
    final zoom = zoomOf(layout);
    final range = readRange(zoom, anchor);
    final axis = TimeAxis(range.first, zoom.pxPerDay);
    final rows = buildRows(
      state.tasks,
      layout.groupBy,
      assigneeName: (id) =>
          members.where((m) => m.userId == id).firstOrNull?.displayName ?? id,
    );
    final scene = TimelineScene(
      rows: rows,
      axis: axis,
      lastDay: range.last,
      links: state.links,
      critical: critical,
      nonWorking: _nonWorking(days),
    );
    _centre(axis, zoom, anchor);
    return LayoutBuilder(
      builder: (context, box) {
        final narrow = box.maxWidth < timelineListBreakpoint;
        final listMode = _listChoice ?? narrow;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TimelineToolbar(
              projectId: _id,
              listMode: listMode,
              onListMode: (v) => setState(() => _listChoice = v),
              onExport: () => _export(scene, zoom),
              onWorkingDays: permissions.can(Perm.workspaceUpdate)
                  ? () => _editWorkingDays(days)
                  : null,
            ),
            if (state.loading) const LinearProgressIndicator(minHeight: 2),
            if (state.error != null)
              MaterialBanner(
                content: Text(taskErrorMessage(state.error!, context.l10n)),
                actions: [
                  TextButton(
                    key: const Key('timeline-retry'),
                    onPressed: ref.read(timelineProvider(_id).notifier).refresh,
                    child: Text(context.l10n.grpIRetry),
                  ),
                ],
              ),
            Expanded(
              child: listMode
                  ? TimelineList(
                      rows: rows,
                      critical: critical,
                      onOpen: widget.onOpen,
                    )
                  : _chart(scene, zoom, today, canMove),
            ),
            _footer(canMove, archived),
          ],
        );
      },
    );
  }

  Widget _chart(
    TimelineScene scene,
    TimelineZoom zoom,
    Day today,
    bool canMove,
  ) {
    final scheme = Theme.of(context).colorScheme;
    final small = Theme.of(context).textTheme.bodySmall ?? const TextStyle();
    return Semantics(
      label: context.l10n.grpITimelineChartLabel(scene.byId.length),
      child: Column(
        children: [
          SizedBox(
            height: exportHeaderHeight,
            child: Row(
              children: [
                const SizedBox(width: _panelWidth),
                Expanded(
                  child: ClipRect(
                    child: CustomPaint(
                      key: const Key('timeline-axis'),
                      painter: AxisHeaderPainter(
                        axis: scene.axis,
                        zoom: zoom,
                        scheme: scheme,
                        style: small.copyWith(color: scheme.onSurfaceVariant),
                        horizontal: _h,
                        lastDay: scene.lastDay,
                      ),
                      child: const SizedBox.expand(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                SizedBox(width: _panelWidth, child: _panel(scene)),
                const VerticalDivider(width: 1),
                Expanded(
                  child: TimelineChart(
                    scene: scene,
                    zoom: zoom,
                    today: today,
                    horizontal: _h,
                    vertical: _v,
                    canMove: canMove,
                    selectedId: widget.openTaskId,
                    onMove: _move,
                    onOpen: widget.onOpen,
                    onZoomStep: _zoomBy,
                    onHover: (task, dates) =>
                        _hover.value = (task: task, dates: dates),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _zoomBy(int steps) {
    final layout = ref.read(timelineLayoutProvider(_id)).layout;
    final now = zoomOf(layout);
    final next = steps > 0 ? now.finer : now.coarser;
    if (next != now) {
      ref
          .read(timelineLayoutProvider(_id).notifier)
          .update((l) => l.copyWith(zoom: next.name));
    }
  }

  Widget _panel(TimelineScene scene) => ListView.builder(
    key: const Key('timeline-panel'),
    controller: _left,
    itemExtent: rowHeight,
    itemCount: scene.rows.length,
    itemBuilder: (context, i) {
      final row = scene.rows[i];
      final task = row.task;
      if (task == null) {
        return Padding(
          padding: const EdgeInsetsDirectional.only(start: 8),
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              row.header!,
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ),
        );
      }
      return InkWell(
        key: Key('timeline-name-${task.id}'),
        onTap: () => widget.onOpen(task),
        child: Padding(
          padding: EdgeInsetsDirectional.only(
            start: 8 + 12.0 * row.depth,
            end: 4,
          ),
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              '${task.displayId}  ${task.title}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: task.id == widget.openTaskId
                  ? const TextStyle(fontWeight: FontWeight.bold)
                  : null,
            ),
          ),
        ),
      );
    },
  );

  Widget _footer(bool canMove, bool archived) => Padding(
    padding: const EdgeInsetsDirectional.fromSTEB(12, 4, 12, 4),
    child: Row(
      children: [
        Expanded(
          child: ValueListenableBuilder(
            valueListenable: _hover,
            builder: (context, hover, _) {
              final task = hover.task;
              final text = task == null
                  ? (canMove ? context.l10n.grpITimelineDragHint : '')
                  : '${task.displayId}  ${task.title} · ${datesText(_shown(task, hover.dates), context.l10n)}'
                        '${lengthText(_shown(task, hover.dates), context.l10n).isEmpty ? '' : ' · ${lengthText(_shown(task, hover.dates), context.l10n)}'}';
              return Text(
                text,
                key: const Key('timeline-info'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              );
            },
          ),
        ),
        TextButton.icon(
          key: const Key('timeline-unscheduled'),
          icon: const Icon(Icons.event_note_outlined),
          label: Text(context.l10n.grpIUnscheduled),
          onPressed: () => _openTray(canMove),
        ),
      ],
    ),
  );

  Task _shown(Task task, Dates? dates) => dates == null
      ? task
      : task.apply(TaskPatch(startDate: dates.startIso, dueDate: dates.dueIso));
}
