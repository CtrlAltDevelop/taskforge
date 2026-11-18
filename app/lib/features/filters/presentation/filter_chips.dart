import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/core/ui/tf/tf_button.dart';
import 'package:taskforge/core/ui/tf/tf_chip.dart';
import 'package:taskforge/core/ui/tf_icons.dart';
import 'package:taskforge/core/ui/tokens/spacing.dart';
import 'package:taskforge/features/fields/application/fields_providers.dart';
import 'package:taskforge/features/filters/application/filters_providers.dart';
import 'package:taskforge/features/filters/domain/filter_fields.dart';
import 'package:taskforge/features/filters/domain/filter_query.dart';
import 'package:taskforge/features/members/application/members_providers.dart';
import 'package:taskforge/features/workflows/application/workflows_providers.dart';
import 'package:taskforge/l10n/gen/app_localizations.dart';

/// What the filter says, one removable chip per condition (or one chip with
/// the text the person wrote), and "Clear all" when there are several.
class FilterChips extends ConsumerWidget {
  const FilterChips({super.key, required this.projectId, required this.onOpen});

  final String projectId;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(activeFilterProvider(projectId));
    final notifier = ref.read(activeFilterProvider(projectId).notifier);
    final query = state.query;
    final l10n = context.l10n;
    final wide = isWorkspaceWideFilter(
      projectId,
    ); // the calendar of every project
    final fields = filterFields(
      flow: wide ? null : ref.watch(workflowProvider(projectId)).value,
      members: ref.watch(membersProvider).value ?? const [],
      fields: wide
          ? const []
          : ref.watch(fieldsProvider(projectId)).value ?? [],
      workspaceWide: wide,
    );
    final children = query.root.children;
    final byCondition = state.text.isEmpty && children.isNotEmpty;
    final labels = byCondition
        ? [for (final c in children) describeNode(c, fields, l10n)]
        : [
            state.text.isEmpty
                ? l10n.grpGConditionCount(query.conditionCount)
                : state.text,
          ];
    void removeAt(int i) => byCondition && children.length > 1
        ? notifier.apply(
            query.copyWith(
              root: query.root.copyWith(
                children: [
                  for (var j = 0; j < children.length; j++)
                    if (j != i) children[j],
                ],
              ),
            ),
          )
        : notifier.clear();
    return Wrap(
      spacing: TfSpace.xs,
      runSpacing: TfSpace.xs,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (var i = 0; i < labels.length; i++)
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 320),
            child: TfChip(
              key: Key(i == 0 ? 'active-filter' : 'filter-chip-$i'),
              label: labels[i],
              icon: TfIcons.filter,
              onTap: onOpen,
              onRemove: () => removeAt(i),
              removeTooltip: l10n.grpGClearFilterTip,
            ),
          ),
        if (labels.length > 1)
          TfButton(
            key: const Key('filter-clear-all'),
            label: l10n.wvClearAll,
            size: TfButtonSize.small,
            variant: TfButtonVariant.ghost,
            onPressed: notifier.clear,
          ),
      ],
    );
  }
}

/// "Priority is High" for a condition; a group reads as "(n conditions)".
String describeNode(
  FilterNode node,
  List<FilterField> fields,
  AppLocalizations l10n,
) {
  switch (node) {
    case FilterGroup():
      return l10n.grpGConditionCount(FilterQuery(root: node).conditionCount);
    case FilterCondition(:final field, :final cmp, :final values):
      final known = fields.where((f) => f.ref == field).firstOrNull;
      String value(FilterValue v) =>
          known?.choices.where((c) => c.id == v.value).firstOrNull?.label ??
          v.asText;
      final parts = [
        known?.label ?? field,
        operatorLabelIn(l10n, cmp) ?? cmp,
        if (!takesNoValue(cmp)) values.map(value).join(', '),
      ];
      return parts.join(' ');
  }
}
