import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/core/ui/breakpoints.dart';
import 'package:taskforge/core/ui/tf/tf_button.dart';
import 'package:taskforge/core/ui/tf/tf_interactive.dart';
import 'package:taskforge/core/ui/tf/tf_menu.dart';
import 'package:taskforge/core/ui/theme_extension.dart';
import 'package:taskforge/core/ui/tf_icons.dart';
import 'package:taskforge/core/ui/tokens/shape.dart';
import 'package:taskforge/core/ui/tokens/spacing.dart';
import 'package:taskforge/features/projects/domain/projects.dart';
import 'package:taskforge/features/sprints/domain/sprints.dart';
import 'package:taskforge/features/tasks/presentation/work/layouts_menu.dart';
import 'package:taskforge/features/tasks/presentation/work/work_view.dart';
import 'package:taskforge/features/views/application/views_providers.dart';
import 'package:taskforge/features/views/domain/list_layout.dart';

const _scrollDuration = Duration(milliseconds: 150);

/// The view tab bar of a project: List, Board, Calendar, Timeline, Sprints and
/// Dashboards (those the project has on), the saved layouts pinned as tabs,
/// and "+ View" to pin another. The bar scrolls sideways when it is too wide
/// and keeps the active tab on screen.
class ViewTabs extends ConsumerStatefulWidget {
  const ViewTabs({
    super.key,
    required this.project,
    required this.view,
    required this.savedTab,
    required this.onView,
    required this.onSavedTab,
    required this.canManage,
  });

  final Project project;
  final WorkView view;

  /// The id of the pinned layout in use as a tab (null: a plain List).
  final String? savedTab;
  final ValueChanged<WorkView> onView;
  final ValueChanged<SavedView> onSavedTab;

  /// May pin, move and remove tabs (`project.update`).
  final bool canManage;

  @override
  ConsumerState<ViewTabs> createState() => _ViewTabsState();
}

class _ViewTabsState extends ConsumerState<ViewTabs> {
  final _active = GlobalKey();
  String? _lastActive;

  void _keepActiveVisible(String activeId) {
    if (_lastActive == activeId) return;
    _lastActive = activeId;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final tab = _active.currentContext;
      if (!mounted || tab == null) return;
      Scrollable.ensureVisible(tab, duration: _scrollDuration);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final project = widget.project;
    final id = project.id;
    final state = ref.watch(listLayoutProvider(id));
    final notifier = ref.read(listLayoutProvider(id).notifier);
    final tabs = pinnedTabs(state.shared);
    final loose = [
      for (final v in state.shared)
        if (!v.pinnedAsTab) v,
    ];
    // A tab that was unpinned or deleted leaves the plain List in use.
    final savedTab = tabs.any((v) => v.id == widget.savedTab)
        ? widget.savedTab
        : null;
    final plainList = savedTab == null;
    _keepActiveVisible(savedTab ?? widget.view.name);
    Widget builtIn(WorkView v, TfIconData icon, String label) => _Tab(
      key: Key('tab-${v.name}'),
      tabKey: widget.view == v && plainList ? _active : null,
      icon: icon,
      label: label,
      selected: widget.view == v && plainList,
      onTap: () => widget.onView(v),
    );
    return Container(
      key: const Key('view-switch'),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: context.tf.colors.border,
            width: tfHairline,
          ),
        ),
      ),
      padding: const EdgeInsetsDirectional.symmetric(horizontal: TfSpace.sm),
      child: LayoutBuilder(
        builder: (context, box) {
          final row = Row(
            children: [
              builtIn(WorkView.list, TfIcons.list, l10n.grpFViewList),
              builtIn(WorkView.board, TfIcons.board, l10n.grpFViewBoard),
              builtIn(WorkView.calendar, TfIcons.calendar, l10n.calendar),
              builtIn(
                WorkView.timeline,
                TfIcons.timeline,
                l10n.grpFViewTimeline,
              ),
              if (project.enabledFeatures.contains(sprintsFeature))
                _Tab(
                  key: const Key('tab-sprints'),
                  icon: TfIcons.clock,
                  label: l10n.grpESprints,
                  selected: false,
                  onTap: () => context.go('/projects/$id/sprints'),
                ),
              _Tab(
                key: const Key('tab-dashboards'),
                icon: TfIcons.dashboard,
                label: l10n.grpKTDashboards,
                selected: false,
                onTap: () => context.go('/projects/$id/dashboards'),
              ),
              for (final v in tabs)
                _SavedTab(
                  key: Key('tab-saved-${v.id}'),
                  tabKey: savedTab == v.id ? _active : null,
                  view: v,
                  selected:
                      widget.view == WorkView.list && widget.savedTab == v.id,
                  first: v.id == tabs.first.id,
                  last: v.id == tabs.last.id,
                  canManage: widget.canManage,
                  onTap: () => widget.onSavedTab(v),
                  notifier: notifier,
                ),
              if (widget.canManage) _AddView(loose: loose, notifier: notifier),
            ],
          );
          // A Scrollable only when the tabs do not fit: the bar then scrolls
          // sideways and keeps the active tab on screen.
          return _tabsWidth(context, tabs) <= box.maxWidth
              ? row
              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: row,
                );
        },
      ),
    );
  }

  double _addViewWidth(BuildContext context) =>
      ScreenSize.of(context).isExpanded
      ? 100
      : context.tf.density.controlHeight;

  /// The width the tabs take together (icon, label, padding, a saved tab's
  /// menu), to scroll only a bar that does not fit.
  double _tabsWidth(BuildContext context, List<SavedView> tabs) {
    final l10n = context.l10n;
    final tf = context.tf;
    final style = tf.typography.label.copyWith(fontWeight: FontWeight.w600);
    final direction = Directionality.of(context);
    double tab(String label) {
      final text = TextPainter(
        text: TextSpan(text: label, style: style),
        textDirection: direction,
        textScaler: MediaQuery.textScalerOf(context),
        maxLines: 1,
      )..layout();
      return text.width + 16 + 6 + 2 * TfSpace.sm;
    }

    return [
          l10n.grpFViewList,
          l10n.grpFViewBoard,
          l10n.calendar,
          l10n.grpFViewTimeline,
          l10n.grpKTDashboards,
          if (widget.project.enabledFeatures.contains(sprintsFeature))
            l10n.grpESprints,
          for (final v in tabs) v.name,
        ].fold(0.0, (sum, label) => sum + tab(label)) +
        (widget.canManage ? _addViewWidth(context) : 0) +
        (widget.canManage ? tabs.length * tf.density.controlHeight : 0) +
        2 * TfSpace.sm;
  }
}

class _Tab extends StatelessWidget {
  const _Tab({
    super.key,
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.tabKey,
  });

  final TfIconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  /// Set on the active tab: the bar scrolls to it.
  final GlobalKey? tabKey;

  @override
  Widget build(BuildContext context) {
    final tf = context.tf;
    final c = tf.colors;
    return TfInteractive(
      key: tabKey,
      onTap: onTap,
      selected: selected,
      semanticLabel: label,
      builder: (context, states) => Container(
        constraints: BoxConstraints(
          minHeight: tfTarget(context, tf.density.controlHeight + TfSpace.xs),
        ),
        padding: const EdgeInsetsDirectional.symmetric(horizontal: TfSpace.sm),
        decoration: BoxDecoration(
          color: states.contains(WidgetState.hovered) ? c.hover : null,
          border: Border(
            bottom: BorderSide(
              color: selected ? c.accent : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        foregroundDecoration: states.contains(WidgetState.focused)
            ? BoxDecoration(border: tfFocusRing(c))
            : null,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TfIcon(icon, color: selected ? c.accent : c.textMuted),
            const SizedBox(width: TfSpace.xs + TfSpace.xxs),
            Text(
              label,
              style: tf.typography.label.copyWith(
                color: selected ? c.text : c.textMuted,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A saved layout pinned as a tab, with its menu: move, unpin, delete.
class _SavedTab extends StatelessWidget {
  const _SavedTab({
    super.key,
    required this.view,
    required this.selected,
    required this.first,
    required this.last,
    required this.canManage,
    required this.onTap,
    required this.notifier,
    this.tabKey,
  });

  final SavedView view;
  final bool selected;
  final bool first;
  final bool last;
  final bool canManage;
  final VoidCallback onTap;
  final ListLayoutNotifier notifier;
  final GlobalKey? tabKey;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tab = _Tab(
      tabKey: tabKey,
      icon: TfIcons.bookmark,
      label: view.name,
      selected: selected,
      onTap: onTap,
    );
    if (!canManage) return tab;
    return Row(
      children: [
        tab,
        TfMenu(
          items: [
            if (!first)
              TfMenuItem(
                key: Key('tab-earlier-${view.id}'),
                icon: TfIcons.chevronStart,
                label: l10n.wvMoveEarlier,
                onSelected: () =>
                    _run(context, () => notifier.moveTab(view, -1)),
              ),
            if (!last)
              TfMenuItem(
                key: Key('tab-later-${view.id}'),
                icon: TfIcons.chevronEnd,
                label: l10n.wvMoveLater,
                onSelected: () =>
                    _run(context, () => notifier.moveTab(view, 1)),
              ),
            TfMenuItem(
              key: Key('tab-unpin-${view.id}'),
              icon: TfIcons.pinOff,
              label: l10n.wvUnpinTab,
              onSelected: () =>
                  _run(context, () => notifier.setTab(view, pinned: false)),
            ),
            TfMenuItem(
              key: Key('tab-delete-${view.id}'),
              icon: TfIcons.trash,
              danger: true,
              label: l10n.grpDDeleteShared(view.name),
              onSelected: () => deleteLayout(context, notifier, view),
            ),
          ],
          builder: (context, toggle) => TfIconButton(
            key: Key('tab-menu-${view.id}'),
            icon: TfIcons.more,
            tooltip: l10n.grpFMore,
            size: TfButtonSize.small,
            onPressed: toggle,
          ),
        ),
      ],
    );
  }
}

/// "+ View": the shared layouts not yet tabs, to pin one.
class _AddView extends StatelessWidget {
  const _AddView({required this.loose, required this.notifier});

  final List<SavedView> loose;
  final ListLayoutNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return TfMenu(
      items: [
        if (loose.isEmpty)
          TfMenuItem(label: l10n.wvNoSavedViews, onSelected: null),
        for (final v in loose)
          TfMenuItem(
            key: Key('tab-pin-${v.id}'),
            icon: TfIcons.pin,
            label: '${l10n.wvPinTab}: ${v.name}',
            onSelected: () =>
                _run(context, () => notifier.setTab(v, pinned: true)),
          ),
      ],
      builder: (context, toggle) => ScreenSize.of(context).isExpanded
          ? TfButton(
              key: const Key('tab-add-view'),
              label: l10n.wvAddView,
              icon: TfIcons.plus,
              size: TfButtonSize.small,
              variant: TfButtonVariant.ghost,
              onPressed: toggle,
            )
          : TfIconButton(
              key: const Key('tab-add-view'),
              icon: TfIcons.plus,
              tooltip: l10n.wvAddView,
              size: TfButtonSize.small,
              onPressed: toggle,
            ),
    );
  }
}

/// A tab change: the server may refuse it, then say why.
Future<void> _run(BuildContext context, Future<void> Function() change) async {
  final l10n = context.l10n;
  final messenger = ScaffoldMessenger.of(context);
  try {
    await change();
  } on ViewException catch (e) {
    messenger.showSnackBar(SnackBar(content: Text(viewErrorMessage(e, l10n))));
  }
}
