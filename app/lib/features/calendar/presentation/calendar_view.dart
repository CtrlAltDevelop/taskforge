import 'package:taskforge/core/ui/scroll_if_short.dart';
import 'package:material_ui/material_ui.dart';
import 'package:taskforge/core/i18n/date_picker.dart';
import 'package:taskforge/core/i18n/context_dates.dart';
import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/core/ui/tf/tf_banner.dart';
import 'package:taskforge/features/account/locale_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/features/calendar/application/calendar_providers.dart';
import 'package:taskforge/features/calendar/domain/calendar_math.dart';
import 'package:taskforge/features/calendar/presentation/calendar_agenda.dart';
import 'package:taskforge/features/calendar/presentation/calendar_drag.dart';
import 'package:taskforge/features/calendar/presentation/calendar_grid.dart';
import 'package:taskforge/features/calendar/presentation/calendar_toolbar.dart';
import 'package:taskforge/features/calendar/presentation/calendar_tray.dart';
import 'package:taskforge/features/roles/application/roles_providers.dart';
import 'package:taskforge/features/roles/domain/roles.dart';
import 'package:taskforge/features/recurrence/application/recurrence_providers.dart';
import 'package:taskforge/features/recurrence/domain/recurrence.dart';
import 'package:taskforge/features/tasks/domain/tasks.dart';
import 'package:taskforge/features/tasks/presentation/task_actions.dart';
import 'package:taskforge/features/tasks/presentation/work/add_task.dart';
import 'package:taskforge/features/tasks/presentation/work/view_search.dart';
import 'package:taskforge/features/tasks/presentation/work/view_toolbar.dart';
import 'package:taskforge/features/workflows/application/workflows_providers.dart';

/// Below this width the calendar is an agenda: a month of dots and the tasks of
/// the chosen day. From [trayBreakpoint] the unscheduled tasks sit beside it.
const phoneBreakpoint = 640.0;
const trayBreakpoint = 900.0;
const trayWidth = 260.0;

/// Tasks by their dates: month, week or day, with drag to move or resize and
/// (for one project) a tray of tasks that have no date yet. [scope] is the
/// project id, or empty for the calendar of every project.
class CalendarView extends ConsumerStatefulWidget {
  const CalendarView({
    super.key,
    required this.scope,
    required this.onOpen,
    this.archived = false,
    this.openTaskId,
    this.projectColor,
    this.visible,
    this.legend,
  });

  final String scope;
  final bool archived;
  final void Function(Task) onOpen;
  final String? openTaskId;

  /// The colour of a task's project (for colouring by project).
  final Color Function(Task)? projectColor;

  /// Which tasks to show (null: all of them).
  final bool Function(Task)? visible;

  /// Shown under the toolbar (the workspace calendar's project chips).
  final Widget? legend;

  bool get workspaceWide => scope.isEmpty;

  @override
  ConsumerState<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends ConsumerState<CalendarView> {
  Day? _picked; // the agenda's chosen day

  String get _id => widget.scope;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 0 is Sunday in the locale's own numbering; ISO weekdays have Sunday = 7.
    final index = MaterialLocalizations.of(context).firstDayOfWeekIndex;
    final chosen = ref.read(localePrefsProvider);
    Future.microtask(() {
      if (!mounted) return;
      // The person's own week start (Language and region) beats the language's.
      ref
          .read(localeWeekStartProvider.notifier)
          .set(
            chosen.weekStart.isNotEmpty
                ? chosen.weekStartDay
                : (index == 0 ? DateTime.sunday : index),
          );
    });
  }

  Color _colorOf(Task task, String colorBy) {
    if (colorBy == 'priority') return priorityColor(task.priority);
    if (colorBy == 'project' && widget.projectColor != null) {
      return widget.projectColor!(task);
    }
    return ref
            .read(workflowProvider(task.projectId))
            .value
            ?.statusById(task.statusId)
            ?.swatch ??
        Colors.blueGrey;
  }

  void _say(String text) => ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(text)));

  /// Gives [task] new dates; a task that came from the tray leaves it (and
  /// comes back if the server refuses). A blocked task is rescheduled with a
  /// note about what blocks it.
  Future<void> _apply(Task task, Dates dates, {bool fromTray = false}) async {
    final current = Dates(
      start: parseDay(task.startDate),
      due: parseDay(task.dueDate),
    );
    if (dates == current) return;
    final tray = fromTray ? ref.read(trayProvider(_id).notifier) : null;
    tray?.remove(task.id);
    try {
      await ref.read(calendarProvider(_id).notifier).reschedule(task, dates);
      final warning = linkWarning(task, dates);
      if (warning != null && mounted) {
        _say(
          'Rescheduled. $warning'
          '${task.blockedBy.isEmpty ? '' : ' (Blocked by ${task.blockedBy.join(', ')}.)'}',
        );
      }
    } on TaskException catch (e) {
      tray?.restore(task);
      if (mounted) _say(taskErrorMessage(e, context.l10n));
    }
  }

  Future<void> _drop(CalDrag drag, Day target) async {
    final task = drag.task;
    await _apply(task, drag.datesOn(target), fromTray: drag.fromTray);
  }

  /// Asks for a day and gives [task] that day, keeping its length.
  Future<void> _schedule(Task task, {bool fromTray = false}) async {
    final today = ref.read(todayProvider);
    final span = spanOf(task);
    final initial = span?.first ?? today;
    final picked = await showAppDatePicker(
      context: context,
      initialDate: initial,
      firstDate: day(2000, 1, 1),
      lastDate: day(2100, 12, 31),
    );
    if (picked == null) return;
    await _apply(
      task,
      moveTask(task, dayOf(picked), grabbed: span?.first),
      fromTray: fromTray,
    );
  }

  Future<void> _more(Day d, List<Task> tasks, String colorBy) =>
      showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(context.localIso(d)),
          content: SizedBox(
            width: 360,
            height: 360,
            child: DayTasks(
              day: d,
              tasks: tasks,
              colorOf: (t) => _colorOf(t, colorBy),
              canMove: false,
              onOpen: (t) {
                Navigator.pop(context);
                widget.onOpen(t);
              },
              onReschedule: (_) {},
            ),
          ),
        ),
      );

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
          _schedule(t, fromTray: true);
        },
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final layout = ref.watch(calendarLayoutProvider(_id)).layout;
    final read = ref.watch(calendarProvider(_id));
    final query = ref.watch(viewSearchProvider(_id));
    final shown = widget.visible == null
        ? read.tasks
        : read.tasks.where(widget.visible!).toList();
    final state = read.copyWith(tasks: searched(shown, query));
    // Status colours come from each task's own project's workflow: watch those
    // so the colours fill in as they load.
    for (final id in {for (final t in read.tasks) t.projectId}) {
      ref.watch(workflowProvider(id));
    }
    final anchor = ref.watch(calendarAnchorProvider(_id));
    final weekStart = ref.watch(weekStartProvider(_id));
    final today = ref.watch(todayProvider);
    final permissions = ref.watch(permissionSetProvider);
    final canMove = !widget.archived && permissions.can(Perm.taskUpdate);
    ref.listen(calendarAnchorProvider(_id), (_, _) {
      if (_picked != null) setState(() => _picked = null);
    });
    return LayoutBuilder(
      builder: (context, box) {
        final phone = box.maxWidth < phoneBreakpoint;
        Future.microtask(() {
          if (mounted) {
            ref.read(compactCalendarProvider.notifier).set(phone);
          }
        });
        final sidebar = !widget.workspaceWide && box.maxWidth >= trayBreakpoint;
        final mode = phone ? CalendarMode.month : modeOf(layout);
        final jalali = ref.watch(calendarJalaliProvider);
        final range = visibleRange(mode, anchor, weekStart, jalali: jalali);
        final anchorMonth = jalali ? jalaliOf(anchor).month : anchor.month;
        final weeks = (daysBetween(range.first, range.last) + 1) ~/ 7;
        Color colorOf(Task t) => _colorOf(t, layout.colorBy);
        final ghosts =
            ref
                .watch(
                  repeatGhostsProvider((
                    project: _id,
                    start: formatDay(range.first),
                    end: formatDay(range.last),
                  )),
                )
                .value ??
            const <RepeatGhost>[];
        final Widget body;
        if (phone) {
          final selected = _picked ?? anchor;
          body = ScrollIfShort(
            minHeight: 560,
            child: Column(
              children: [
                MonthDots(
                  first: range.first,
                  weeks: weeks,
                  month: anchorMonth,
                  jalali: jalali,
                  tasks: state.tasks,
                  ghosts: ghosts,
                  today: today,
                  selected: selected,
                  onSelect: (d) => setState(() => _picked = d),
                ),
                const Divider(height: 1),
                Expanded(
                  child: DayTasks(
                    day: selected,
                    tasks: state.tasks,
                    ghosts: ghosts,
                    colorOf: colorOf,
                    canMove: canMove,
                    onOpen: widget.onOpen,
                    onReschedule: _schedule,
                  ),
                ),
              ],
            ),
          );
        } else if (mode == CalendarMode.day) {
          body = DayTasks(
            day: anchor,
            tasks: state.tasks,
            ghosts: ghosts,
            colorOf: colorOf,
            canMove: canMove,
            onOpen: widget.onOpen,
            onReschedule: _schedule,
          );
        } else {
          body = CalendarGrid(
            first: range.first,
            weeks: weeks,
            weekStart: weekStart,
            tasks: state.tasks,
            ghosts: ghosts,
            today: today,
            month: mode == CalendarMode.month ? anchorMonth : null,
            jalali: jalali,
            maxLanes: mode == CalendarMode.month ? 3 : 30,
            canMove: canMove,
            longPress: box.maxWidth < trayBreakpoint,
            openTaskId: widget.openTaskId,
            colorOf: colorOf,
            onOpen: widget.onOpen,
            onDrop: _drop,
            onMore: (d) => _more(d, state.tasks, layout.colorBy),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ViewToolbar(
              key: const Key('calendar-toolbar'),
              projectId: _id,
              canShare: !widget.archived && permissions.can(Perm.projectUpdate),
              specific: calendarSpecificControls(
                context,
                ref,
                _id,
                compact: phone,
                workspaceWide: widget.workspaceWide,
                onTray: sidebar || widget.workspaceWide
                    ? null
                    : () => _openTray(canMove),
              ),
              onAddTask:
                  widget.workspaceWide ||
                      widget.archived ||
                      !permissions.can(Perm.taskCreate)
                  ? null
                  : () => runNewTask(context, ref),
            ),
            if (widget.legend != null) widget.legend!,
            if (state.loading)
              const LinearProgressIndicator(key: Key('calendar-loading')),
            if (state.error != null)
              TfBanner(
                key: const Key('calendar-error'),
                kind: TfBannerKind.danger,
                message: taskErrorMessage(state.error!, context.l10n),
                actionLabel: context.l10n.retry,
                actionKey: const Key('retry-calendar'),
                onAction: ref.read(calendarProvider(_id).notifier).refresh,
              ),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: body),
                  if (sidebar) ...[
                    const VerticalDivider(width: 1),
                    SizedBox(
                      width: trayWidth,
                      child: CalendarTray(
                        projectId: _id,
                        canMove: canMove,
                        draggable: true,
                        onOpen: widget.onOpen,
                        onSchedule: (t) => _schedule(t, fromTray: true),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
