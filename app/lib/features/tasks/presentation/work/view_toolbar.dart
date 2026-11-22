import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/core/ui/breakpoints.dart';
import 'package:taskforge/core/ui/tf/tf_button.dart';
import 'package:taskforge/core/ui/tf/tf_field.dart';
import 'package:taskforge/core/ui/tf_icons.dart';
import 'package:taskforge/core/ui/tokens/spacing.dart';
import 'package:taskforge/features/filters/application/filters_providers.dart';
import 'package:taskforge/features/filters/presentation/filter_bar.dart';
import 'package:taskforge/features/filters/presentation/filter_chips.dart';
import 'package:taskforge/features/filters/presentation/filter_panel.dart';
import 'package:taskforge/features/tasks/presentation/work/toolbar_parts.dart';
import 'package:taskforge/features/tasks/presentation/work/view_search.dart';

const _searchWidth = 200.0;

/// From this width the controls wrap onto more rows instead of scrolling.
const _wrapFrom = 600.0;

/// The one toolbar of every view: search, filter, group, sort, fields, the
/// view's own controls and "+ Task", in that order. A view fills the slots it
/// has (a calendar has no sort), and the row wraps rather than hides a control
/// when the width runs out; the filter and the search are the same
/// state in every view, so they stay when the tab changes. What is filtered
/// shows as chips on a row of their own below.
class ViewToolbar extends ConsumerWidget {
  const ViewToolbar({
    super.key,
    required this.projectId,
    this.canShare = false,
    this.group,
    this.sort,
    this.fields,
    this.specific = const [],
    this.onAddTask,
  });

  /// Empty for the calendar of every project (it has its own filter).
  final String projectId;

  /// May save layouts for the whole project (`project.update`).
  final bool canShare;
  final Widget? group;
  final Widget? sort;
  final Widget? fields;

  /// The view's own controls: swimlanes, Month/Week/Day, zoom, refresh.
  final List<Widget> specific;

  /// "+ Task" (null when the person may not create).
  final VoidCallback? onAddTask;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scoped = projectId.isNotEmpty;
    final filtered =
        scoped && !ref.watch(activeFilterProvider(projectId)).query.isEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsetsDirectional.symmetric(
            horizontal: pageGutter(ScreenSize.of(context)),
            vertical: TfSpace.xs,
          ),
          child: Row(
            children: [
              Expanded(
                child: LayoutBuilder(
                  builder: (context, box) {
                    final controls = [
                      if (scoped) _SearchSlot(projectId: projectId),
                      if (scoped)
                        FilterBar(
                          projectId: projectId,
                          canShare: canShare,
                          showChips: false,
                        ),
                      ?group,
                      ?sort,
                      ?fields,
                      ...specific,
                    ];
                    // A phone keeps one row that scrolls; wider screens wrap.
                    return box.maxWidth < _wrapFrom
                        ? SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(spacing: TfSpace.xs, children: controls),
                          )
                        : Wrap(
                            spacing: TfSpace.xs,
                            runSpacing: TfSpace.xs,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: controls,
                          );
                  },
                ),
              ),
              if (onAddTask != null) ...[
                const SizedBox(width: TfSpace.sm),
                ScreenSize.of(context).isCompact
                    ? TfIconButton(
                        key: const Key('toolbar-add-task'),
                        icon: TfIcons.plus,
                        tooltip: context.l10n.wvAddTask,
                        size: TfButtonSize.small,
                        variant: TfButtonVariant.primary,
                        onPressed: onAddTask,
                      )
                    : TfButton(
                        key: const Key('toolbar-add-task'),
                        label: context.l10n.wvAddTask,
                        icon: TfIcons.plus,
                        size: TfButtonSize.small,
                        variant: TfButtonVariant.primary,
                        onPressed: onAddTask,
                      ),
              ],
            ],
          ),
        ),
        if (filtered)
          Padding(
            key: const Key('filter-chips-row'),
            padding: const EdgeInsetsDirectional.fromSTEB(
              TfSpace.sm,
              0,
              TfSpace.sm,
              TfSpace.xs,
            ),
            child: FilterChips(
              projectId: projectId,
              onOpen: () => showDialog<void>(
                context: context,
                builder: (_) =>
                    FilterPanel(projectId: projectId, canShare: canShare),
              ),
            ),
          ),
      ],
    );
  }
}

class _SearchSlot extends ConsumerStatefulWidget {
  const _SearchSlot({required this.projectId});

  /// An icon until it is tapped (the field would push the other controls off
  /// the row); open while there is something typed.
  final String projectId;

  @override
  ConsumerState<_SearchSlot> createState() => _SearchSlotState();
}

class _SearchSlotState extends ConsumerState<_SearchSlot> {
  // Starts from what the person typed in another view.
  late final _controller = TextEditingController(
    text: ref.read(viewSearchProvider(widget.projectId)),
  );
  late var _open = _controller.text.isNotEmpty;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_open) {
      return ToolbarIcon(
        key: const Key('view-search-open'),
        icon: TfIcons.search,
        tooltip: context.l10n.wvSearchHint,
        onPressed: () => setState(() => _open = true),
      );
    }
    return SizedBox(
      key: const Key('view-search'),
      width: _searchWidth,
      child: TfSearchField(
        controller: _controller,
        autofocus: true,
        hint: context.l10n.wvSearchHint,
        clearTooltip: context.l10n.wvSearchClear,
        onChanged: ref.read(viewSearchProvider(widget.projectId).notifier).set,
      ),
    );
  }
}
