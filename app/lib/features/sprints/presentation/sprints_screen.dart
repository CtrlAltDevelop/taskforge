import 'package:taskforge/core/ui/breakpoints.dart';
import 'package:taskforge/core/ui/page/tf_page.dart';
import 'package:taskforge/core/ui/tf/tf_chip.dart';
import 'package:taskforge/core/ui/tf/tf_tabs.dart';
import 'package:taskforge/core/ui/tokens/spacing.dart';
import 'package:taskforge/core/ui/page/tf_select_field.dart';
import 'package:taskforge/core/ui/tf/tf_button.dart';
import 'package:taskforge/core/ui/scroll_if_short.dart';
import 'package:taskforge/core/ui/tf_icons.dart';
import 'package:taskforge/core/ui/tf_app_bar.dart';

import 'dart:math';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:taskforge/core/i18n/context_dates.dart';
import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/features/projects/application/projects_providers.dart';
import 'package:taskforge/features/projects/domain/projects.dart';
import 'package:taskforge/features/roles/application/roles_providers.dart';
import 'package:taskforge/features/roles/domain/roles.dart';
import 'package:taskforge/features/sprints/application/sprints_providers.dart';
import 'package:taskforge/features/sprints/domain/sprints.dart';
import 'package:taskforge/features/sprints/presentation/planning_panes.dart';
import 'package:taskforge/features/sprints/presentation/sprint_charts.dart';
import 'package:taskforge/features/sprints/presentation/sprint_dialogs.dart';
import 'package:taskforge/core/ui/tf/tf_feedback.dart';
import 'package:taskforge/core/ui/tf/tf_illustration.dart';

/// Width from which the backlog and the sprint sit side by side.
const planningBreakpoint = 820.0;

/// Least height of one planning pane when the two are stacked.
const _stackedPaneHeight = 360.0;

/// A project's sprints: planning (backlog | sprint) and reports.
class SprintsScreen extends ConsumerWidget {
  const SprintsScreen({super.key, required this.projectId});

  final String projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final project = ref.watch(projectProvider(projectId));
    final catalog = ref.watch(projectCatalogProvider(true));
    return Scaffold(
      appBar: TfAppBar(
        title: Text(
          project == null
              ? context.l10n.grpASprintsTitle
              : context.l10n.grpASprintsTitleProject(project.name),
        ),
      ),
      body: switch (project) {
        final p? when !p.enabledFeatures.contains(sprintsFeature) => TfEmpty(
          key: const Key('sprints-disabled'),
          illustration: TfIllustrationKind.tasks,
          title: context.l10n.grpASprintsDisabled,
        ),
        final p? => _Sprints(project: p),
        null when catalog.hasValue => TfEmpty(
          key: const Key('sprints-missing'),
          illustration: TfIllustrationKind.notFound,
          title: context.l10n.grpAProjectNotFound,
        ),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}

class _Sprints extends ConsumerStatefulWidget {
  const _Sprints({required this.project});

  final Project project;

  @override
  ConsumerState<_Sprints> createState() => _SprintsState();
}

class _SprintsState extends ConsumerState<_Sprints> {
  String? _picked;
  var _reports = false;
  var _hours = false;
  final _selected = <String>{};

  String get _pid => widget.project.id;

  /// The sprint on screen: the one picked, else the active one, else the
  /// first planned.
  Sprint? _current(List<Sprint> open) {
    for (final s in open) {
      if (s.id == _picked) return s;
    }
    return open.where((s) => s.isActive).firstOrNull ??
        open.where((s) => s.isPlanned).firstOrNull ??
        open.firstOrNull;
  }

  void _say(String text) => ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(text)));

  /// Runs [call]; a refusal is shown as text, never thrown at the screen.
  Future<T?> _try<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on SprintException catch (e) {
      if (mounted) _say(sprintErrorMessage(e, context.l10n));
      return null;
    }
  }

  Future<void> _move(
    Sprint sprint,
    SprintTask dragged, {
    required bool into,
  }) async {
    final ids = _selected.contains(dragged.id) ? {..._selected} : {dragged.id};
    final actions = ref.read(sprintActionsProvider);
    final result = await _try(
      () => into
          ? actions.add(sprint, ids.toList())
          : actions.remove(sprint, ids.toList()),
    );
    if (result == null || !mounted) return;
    setState(_selected.clear);
    if (result.addedAfterStart > 0) {
      _say(context.l10n.grpAAddedAfterStart(result.addedAfterStart));
    }
  }

  Future<void> _addSelected(Sprint sprint) async {
    final ids = _selected.toList();
    if (ids.isEmpty) return;
    final result = await _try(
      () => ref.read(sprintActionsProvider).add(sprint, ids),
    );
    if (result == null || !mounted) return;
    setState(_selected.clear);
    if (result.addedAfterStart > 0) {
      _say(context.l10n.grpAAddedAfterStart(result.addedAfterStart));
    }
  }

  Future<void> _removeSelected(Sprint sprint, Set<String> inSprint) async {
    final ids = _selected.where(inSprint.contains).toList();
    if (ids.isEmpty) return;
    final result = await _try(
      () => ref.read(sprintActionsProvider).remove(sprint, ids),
    );
    if (result != null && mounted) setState(_selected.clear);
  }

  Future<void> _form(List<Sprint> all, {Sprint? sprint}) async {
    final saved = await showDialog<Sprint>(
      context: context,
      builder: (_) =>
          SprintFormDialog(projectId: _pid, others: all, sprint: sprint),
    );
    if (saved != null && mounted) setState(() => _picked = saved.id);
  }

  Future<void> _start(Sprint sprint) async {
    final done = await _try(
      () => ref.read(sprintActionsProvider).start(sprint),
    );
    if (done != null && mounted) setState(() => _picked = done.sprint.id);
  }

  Future<void> _complete(Sprint sprint, List<Sprint> all) async {
    final choice = await showDialog<CarryChoice>(
      context: context,
      builder: (_) => CompleteSprintDialog(
        sprint: sprint,
        planned: [
          for (final s in all)
            if (s.isPlanned) s,
        ],
      ),
    );
    if (choice == null || !mounted) return;
    final done = await _try(
      () => ref
          .read(sprintActionsProvider)
          .complete(
            sprint,
            carryOver: choice.carryOver,
            nextSprintId: choice.nextSprintId,
          ),
    );
    if (done == null || !mounted) return;
    setState(
      () => _picked = choice.nextSprintId.isEmpty ? null : choice.nextSprintId,
    );
    _say(context.l10n.grpASprintCompleted(done.sprint.name));
  }

  Future<void> _points(SprintTask task) async {
    final text = await showDialog<String>(
      context: context,
      builder: (_) => PointsDialog(task: task),
    );
    if (text == null || !mounted) return;
    await _try(
      () => ref.read(sprintActionsProvider).setPoints(_pid, task, text),
    );
  }

  Future<void> _editCapacity(Sprint sprint) async {
    final text = await showDialog<String>(
      context: context,
      builder: (_) => CapacityDialog(
        hours: _hours,
        value: sprint.capacityIn(hours: _hours),
      ),
    );
    if (text == null || !mounted) return;
    await _try(
      () => ref
          .read(sprintActionsProvider)
          .setCapacity(sprint, hours: _hours, text: text),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sprints = ref.watch(sprintsProvider(_pid));
    return switch (sprints) {
      AsyncData(:final value) => _loaded(context, value),
      AsyncError(:final error) => TfError(
        key: const Key('sprints-error'),
        message: sprintErrorMessage(error, context.l10n),
        details: '$error',
        retryKey: const Key('sprints-retry'),
        onRetry: () => ref.invalidate(sprintsProvider(_pid)),
      ),
      _ => const Center(child: CircularProgressIndicator()),
    };
  }

  Widget _loaded(BuildContext context, List<Sprint> all) {
    final current = _current(all);
    final canManage = ref.watch(permissionSetProvider).can(Perm.sprintManage);
    return ScrollIfShort(
      minHeight: 900,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: pageGutter(ScreenSize.of(context)),
              vertical: TfSpace.sm,
            ),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: Wrap(
                spacing: TfSpace.sm,
                runSpacing: TfSpace.sm,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  TfSegmented<bool>(
                    key: const Key('sprints-tabs'),
                    options: {
                      false: context.l10n.grpAPlanning,
                      true: context.l10n.grpAReports,
                    },
                    value: _reports,
                    onChanged: (v) => setState(() => _reports = v),
                  ),
                  if (all.length > 1)
                    TfSelectField(
                      key: const Key('sprint-picker'),
                      options: {for (final s in all) s.id: s.name},
                      value: current?.id,
                      onChanged: (v) => setState(() {
                        _picked = v;
                        _selected.clear();
                      }),
                    ),
                  if (canManage)
                    TfButton(
                      key: const Key('new-sprint'),
                      icon: TfIcons.plus,
                      label: context.l10n.grpANewSprint,
                      variant: TfButtonVariant.secondary,
                      onPressed: () => _form(all),
                    ),
                ],
              ),
            ),
          ),
          if (current != null)
            _Header(
              sprint: current,
              canManage: canManage,
              onEdit: () => _form(all, sprint: current),
              onStart: () => _start(current),
              onComplete: () => _complete(current, all),
            ),
          const Divider(height: 1),
          Expanded(
            child: _reports
                ? _Reports(projectId: _pid, sprint: current ?? all.firstOrNull)
                : _planning(context, current, canManage),
          ),
        ],
      ),
    );
  }

  Widget _planning(BuildContext context, Sprint? sprint, bool canManage) {
    final canPoints = ref.watch(permissionSetProvider).can(Perm.taskUpdate);
    final backlog = ref.watch(backlogProvider(_pid));
    final inSprint = sprint == null
        ? const AsyncData<List<SprintTask>>([])
        : ref.watch(sprintTasksProvider((project: _pid, sprint: sprint.id)));
    final sprintIds = {
      for (final t in inSprint.value ?? const <SprintTask>[]) t.id,
    };
    final canPlan = sprint != null && !sprint.isCompleted && canManage;

    Widget row(SprintTask t, {required bool backlogSide}) => PlanningTaskRow(
      task: t,
      selected: _selected.contains(t.id),
      canDrag: canPlan,
      onToggle: (v) =>
          setState(() => v ? _selected.add(t.id) : _selected.remove(t.id)),
      onPoints: canPoints ? () => _points(t) : null,
    );

    final backlogPane = DropPane(
      key: const Key('backlog-pane'),
      accepts: (t) => canPlan && t.sprintId.isNotEmpty,
      onDrop: (t) {
        if (sprint != null) _move(sprint, t, into: false);
      },
      child: TaskListPane(
        title: context.l10n.grpABacklog,
        tasks: backlog,
        emptyTitle: context.l10n.grpABacklogEmpty,
        rowBuilder: (t) => row(t, backlogSide: true),
        actions: [
          if (canPlan)
            TfButton(
              key: const Key('add-to-sprint'),
              label: context.l10n.grpAAddToSprint,
              variant: TfButtonVariant.primary,
              onPressed: _selected.any((id) => !sprintIds.contains(id))
                  ? () => _addSelected(sprint)
                  : null,
            ),
        ],
      ),
    );

    final sprintPane = sprint == null
        ? TfEmpty(
            key: const Key('no-sprint'),
            illustration: TfIllustrationKind.tasks,
            title: context.l10n.grpANoOpenSprint,
          )
        : DropPane(
            key: const Key('sprint-pane'),
            accepts: (t) => canPlan && t.sprintId != sprint.id,
            onDrop: (t) => _move(sprint, t, into: true),
            child: TaskListPane(
              title: sprint.name,
              tasks: inSprint,
              emptyTitle: context.l10n.grpADragHere,
              header: _capacityBar(sprint, canManage),
              rowBuilder: (t) => row(t, backlogSide: false),
              actions: [
                if (canPlan)
                  TfButton(
                    key: const Key('remove-from-sprint'),
                    label: context.l10n.grpARemove,
                    variant: TfButtonVariant.ghost,
                    onPressed: _selected.any(sprintIds.contains)
                        ? () => _removeSelected(sprint, sprintIds)
                        : null,
                  ),
              ],
            ),
          );

    return LayoutBuilder(
      builder: (context, box) => box.maxWidth >= planningBreakpoint
          ? Row(
              children: [
                Expanded(child: backlogPane),
                const VerticalDivider(width: 1),
                Expanded(child: sprintPane),
              ],
            )
          // Stacked on a phone: each pane keeps a usable height and the page
          // scrolls, instead of squeezing both into one screen.
          : SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    height: max(box.maxHeight / 2, _stackedPaneHeight),
                    child: backlogPane,
                  ),
                  const Divider(height: 1),
                  SizedBox(
                    height: max(box.maxHeight / 2, _stackedPaneHeight),
                    child: sprintPane,
                  ),
                ],
              ),
            ),
    );
  }

  Widget _capacityBar(Sprint sprint, bool canManage) {
    // With no capacity set, the average velocity of past sprints is the guide
    // (points only: there is no history of hours).
    final velocity = _hours
        ? null
        : ref
              .watch(burndownProvider((project: _pid, sprint: sprint.id)))
              .value
              ?.averageVelocity;
    final guide = velocity != null && velocity > 0 ? velocity : null;
    return CapacityBar(
      capacity: Capacity(
        load: sprintLoad(sprint, hours: _hours),
        capacity: sprint.capacityIn(hours: _hours) ?? guide,
      ),
      hours: _hours,
      onHours: (v) => setState(() => _hours = v),
      onEdit: canManage ? () => _editCapacity(sprint) : null,
    );
  }
}

class _Header extends ConsumerWidget {
  const _Header({
    required this.sprint,
    required this.canManage,
    required this.onEdit,
    required this.onStart,
    required this.onComplete,
  });

  final Sprint sprint;
  final bool canManage;
  final VoidCallback onEdit;
  final VoidCallback onStart;
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final today = ref.watch(sprintTodayProvider)();
    final left = daysLeft(sprint, today);
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: pageGutter(ScreenSize.of(context)),
        vertical: TfSpace.sm,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: TfSpace.sm,
                  runSpacing: TfSpace.xs,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(sprint.name, style: theme.textTheme.titleLarge),
                    TfChip(
                      key: const Key('sprint-state'),
                      label: sprint.state.name,
                    ),
                    Text(
                      context.l10n.grpADatesRange(
                        context.localIso(sprint.startDate),
                        context.localIso(sprint.endDate),
                      ),
                      style: theme.textTheme.bodySmall,
                    ),
                    if (sprint.isActive)
                      Text(
                        context.l10n.grpADaysLeft(left),
                        key: const Key('days-left'),
                        style: theme.textTheme.labelLarge,
                      ),
                  ],
                ),
                if (sprint.goal.isNotEmpty)
                  Text(
                    context.l10n.grpASprintGoalText(sprint.goal),
                    key: const Key('sprint-goal-text'),
                  ),
              ],
            ),
          ),
          if (sprint.isActive) ...[
            const SizedBox(width: TfSpace.sm),
            TfButton(
              key: const Key('sprint-on-board'),
              label: context.l10n.grpAShowOnBoard,
              variant: TfButtonVariant.ghost,
              icon: TfIcons.board,
              onPressed: () {
                ref
                    .read(boardCurrentSprintProvider(sprint.projectId).notifier)
                    .set(on: true);
                context.go('/projects/${sprint.projectId}?view=board');
              },
            ),
          ],
          if (canManage) ...[
            const SizedBox(width: TfSpace.sm),
            TfIconButton(
              key: const Key('edit-sprint'),
              icon: TfIcons.edit,
              tooltip: context.l10n.grpAEditSprint,
              onPressed: onEdit,
            ),
            if (sprint.isPlanned) ...[
              const SizedBox(width: TfSpace.sm),
              TfButton(
                key: const Key('start-sprint'),
                label: context.l10n.grpAStartSprint,
                variant: TfButtonVariant.primary,
                onPressed: onStart,
              ),
            ],
            if (sprint.isActive) ...[
              const SizedBox(width: TfSpace.sm),
              TfButton(
                key: const Key('complete-sprint'),
                label: context.l10n.grpACompleteSprint,
                variant: TfButtonVariant.primary,
                onPressed: onComplete,
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _Reports extends StatelessWidget {
  const _Reports({required this.projectId, required this.sprint});

  final String projectId;
  final Sprint? sprint;

  @override
  Widget build(BuildContext context) {
    final s = sprint;
    if (s == null) {
      return TfEmpty(
        key: const Key('reports-empty'),
        illustration: TfIllustrationKind.tasks,
        title: context.l10n.grpANoSprintsYet,
      );
    }
    return TfPage(
      maxWidth: TfPageWidth.wide,
      lazy: true,
      children: [
        BurndownPanel(projectId: projectId, sprint: s),
        const SizedBox(height: TfSpace.xl),
        VelocityPanel(projectId: projectId, sprint: s),
      ],
    );
  }
}
