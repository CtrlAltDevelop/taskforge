import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/features/filters/application/filters_providers.dart';
import 'package:taskforge/features/filters/domain/saved_filters.dart';
import 'package:taskforge/features/filters/presentation/filter_panel.dart';
import 'package:taskforge/features/workspaces/application/workspace_providers.dart';

/// The filter of a project's views: a button that opens the editor, a menu of
/// saved filters and, while one is on, a chip that says what it is. The same
/// bar sits over the list, the board and the calendar.
class FilterBar extends ConsumerWidget {
  const FilterBar({super.key, required this.projectId, required this.canShare});

  final String projectId;
  final bool canShare;

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
    final count = active.conditionCount;
    return Wrap(
      spacing: 6,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        OutlinedButton.icon(
          key: const Key('filter-button'),
          icon: const Icon(Icons.filter_list, size: 18),
          label: Text(
            active.isEmpty
                ? context.l10n.grpGFilter
                : context.l10n.grpGFilterCount(count),
          ),
          onPressed: () => _open(context),
        ),
        PopupMenuButton<Object>(
          key: const Key('saved-filters-menu'),
          tooltip: context.l10n.grpGSavedFilters,
          icon: const Icon(Icons.bookmarks_outlined),
          onSelected: (choice) {
            if (choice is SavedFilter) {
              notifier.apply(choice.query, saved: choice.id, text: choice.tfql);
            } else {
              showDialog<void>(
                context: context,
                builder: (_) => _ManageDialog(projectId: projectId),
              );
            }
          },
          itemBuilder: (menu) => [
            if (saved.isEmpty)
              PopupMenuItem<Object>(
                enabled: false,
                child: Text(menu.l10n.grpGNoSavedFilters),
              ),
            for (final f in saved)
              PopupMenuItem<Object>(
                key: Key('saved-${f.id}'),
                value: f,
                enabled: !f.isBroken,
                child: Row(
                  children: [
                    Icon(
                      f.isShared ? Icons.group_outlined : Icons.person_outline,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        f.isBroken
                            ? menu.l10n.grpGFieldGoneNamed(f.name)
                            : f.name,
                      ),
                    ),
                  ],
                ),
              ),
            if (saved.isNotEmpty) const PopupMenuDivider(),
            PopupMenuItem<Object>(
              key: const Key('manage-filters'),
              value: 'manage',
              child: Text(menu.l10n.grpGManageSaved),
            ),
          ],
        ),
        if (!active.isEmpty)
          InputChip(
            key: const Key('active-filter'),
            label: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 320),
              child: Text(
                state.text.isEmpty
                    ? context.l10n.grpGConditionCount(count)
                    : state.text,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            onPressed: () => _open(context),
            onDeleted: notifier.clear,
            deleteButtonTooltipMessage: context.l10n.grpGClearFilterTip,
          ),
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
                      leading: Icon(
                        f.isShared
                            ? Icons.group_outlined
                            : Icons.person_outline,
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
                        icon: const Icon(Icons.delete_outline),
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
                              SnackBar(content: Text(filterErrorMessage(e))),
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
