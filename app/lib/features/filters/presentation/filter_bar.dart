import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/core/ui/breakpoints.dart';
import 'package:taskforge/core/ui/tf/tf_button.dart';
import 'package:taskforge/core/ui/tf/tf_menu.dart';
import 'package:taskforge/core/ui/tf_icons.dart';
import 'package:taskforge/core/ui/tokens/spacing.dart';
import 'package:taskforge/features/filters/application/filters_providers.dart';
import 'package:taskforge/features/filters/domain/saved_filters.dart';
import 'package:taskforge/features/filters/presentation/filter_chips.dart';
import 'package:taskforge/features/filters/presentation/filter_panel.dart';
import 'package:taskforge/features/workspaces/application/workspace_providers.dart';

/// The filter of a project's views: a button that opens the editor, a menu of
/// saved filters and (unless [showChips] is off, the view toolbar draws them
/// on a row of their own) the chips of what is on.
class FilterBar extends ConsumerWidget {
  const FilterBar({
    super.key,
    required this.projectId,
    required this.canShare,
    this.showChips = true,
  });

  final String projectId;
  final bool canShare;
  final bool showChips;

  Future<void> _open(BuildContext context) => showDialog<void>(
    context: context,
    builder: (_) => FilterPanel(projectId: projectId, canShare: canShare),
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(activeFilterProvider(projectId));
    final active = state.query;
    final notifier = ref.read(activeFilterProvider(projectId).notifier);
    final saved = ref.watch(savedFiltersProvider(projectId)).value ?? const [];
    final l10n = context.l10n;
    return Wrap(
      spacing: TfSpace.xs,
      runSpacing: TfSpace.xs,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        // A phone has no room for the word until a filter is on.
        if (ScreenSize.of(context).isCompact && active.isEmpty)
          TfIconButton(
            key: const Key('filter-button'),
            icon: TfIcons.filter,
            tooltip: l10n.grpGFilter,
            size: TfButtonSize.small,
            onPressed: () => _open(context),
          )
        else
          TfButton(
            key: const Key('filter-button'),
            icon: TfIcons.filter,
            size: TfButtonSize.small,
            variant: active.isEmpty
                ? TfButtonVariant.ghost
                : TfButtonVariant.secondary,
            label: active.isEmpty
                ? l10n.grpGFilter
                : l10n.grpGFilterCount(active.conditionCount),
            onPressed: () => _open(context),
          ),
        TfMenu(
          items: [
            if (saved.isEmpty)
              TfMenuItem(label: l10n.grpGNoSavedFilters, onSelected: null),
            for (final f in saved)
              TfMenuItem(
                key: Key('saved-${f.id}'),
                icon: f.isShared ? TfIcons.users : TfIcons.user,
                label: f.isBroken ? l10n.grpGFieldGoneNamed(f.name) : f.name,
                onSelected: f.isBroken
                    ? null
                    : () => notifier.apply(f.query, saved: f.id, text: f.tfql),
              ),
            TfMenuItem(
              key: const Key('manage-filters'),
              label: l10n.grpGManageSaved,
              onSelected: () => showDialog<void>(
                context: context,
                builder: (_) => _ManageDialog(projectId: projectId),
              ),
            ),
          ],
          builder: (context, toggle) => TfIconButton(
            key: const Key('saved-filters-menu'),
            icon: TfIcons.bookmark,
            tooltip: l10n.grpGSavedFilters,
            size: TfButtonSize.small,
            onPressed: toggle,
          ),
        ),
        if (showChips && !active.isEmpty)
          FilterChips(projectId: projectId, onOpen: () => _open(context)),
      ],
    );
  }
}

class _ManageDialog extends ConsumerWidget {
  const _ManageDialog({required this.projectId});

  final String projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final saved = ref.watch(savedFiltersProvider(projectId)).value ?? const [];
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(context.l10n.grpGSavedFilters),
      content: SizedBox(
        width: 420,
        child: saved.isEmpty
            ? Text(
                context.l10n.grpGNothingSaved,
                key: const Key('no-saved-filters'),
              )
            : ListView(
                shrinkWrap: true,
                children: [
                  for (final f in saved)
                    ListTile(
                      key: Key('manage-${f.id}'),
                      leading: TfIcon(
                        f.isShared ? TfIcons.users : TfIcons.user,
                      ),
                      title: Text(f.name),
                      subtitle: Text(
                        f.isBroken ? context.l10n.grpGFieldItUsedGone : f.tfql,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: IconButton(
                        key: Key('delete-filter-${f.id}'),
                        tooltip: context.l10n.grpGDelete,
                        icon: const TfIcon(TfIcons.trash),
                        onPressed: () async {
                          final workspace = ref.read(workspaceScopeProvider);
                          if (workspace == null) return;
                          try {
                            await ref
                                .read(filtersClientProvider)
                                .delete(workspace, projectId, f.id);
                            if (ref
                                    .read(activeFilterProvider(projectId))
                                    .savedId ==
                                f.id) {
                              ref
                                  .read(
                                    activeFilterProvider(projectId).notifier,
                                  )
                                  .clear();
                            }
                            ref.invalidate(savedFiltersProvider(projectId));
                          } on FilterException catch (e) {
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text(filterErrorMessage(e, l10n)),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                ],
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(context.l10n.grpGClose),
        ),
      ],
    );
  }
}
