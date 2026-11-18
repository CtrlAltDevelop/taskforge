import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/core/ui/theme_extension.dart';
import 'package:taskforge/core/ui/tf_icons.dart';
import 'package:taskforge/core/ui/tokens/shape.dart';
import 'package:taskforge/core/ui/tokens/spacing.dart';
import 'package:taskforge/features/tasks/presentation/list_lookups.dart';
import 'package:taskforge/features/tasks/presentation/table_metrics.dart';
import 'package:taskforge/features/views/domain/list_layout.dart';

/// The sticky heading of the table: a select-all box and one cell per column.
/// A click sorts (shift adds a key), the right edge resizes.
class TableHeader extends StatelessWidget {
  const TableHeader({
    super.key,
    required this.layout,
    required this.columns,
    required this.lookups,
    required this.allPicked,
    required this.canPick,
    required this.onPickAll,
    required this.onSort,
    required this.onResize,
  });

  final ListLayout layout;
  final List<String> columns;
  final ListLookups lookups;
  final bool allPicked;
  final bool canPick;
  final ValueChanged<bool> onPickAll;
  final void Function(String column, bool add) onSort;
  final void Function(String column, double dx) onResize;

  @override
  Widget build(BuildContext context) {
    final c = context.tf.colors;
    ({int position, bool desc})? sortOf(String key) {
      final i = layout.sort.indexWhere((s) => s.key == key);
      return i < 0 ? null : (position: i + 1, desc: layout.sort[i].desc);
    }

    Widget cell(String key, String label, {required bool sortable}) =>
        _HeaderCell(
          columnKey: key,
          label: label,
          width: layout.widthOf(key),
          sort: sortOf(key),
          sortable: sortable,
          onSort: (add) => onSort(key, add),
          onResize: (dx) => onResize(key, dx),
        );
    return Container(
      key: const Key('table-header'),
      height: tableHeaderHeight,
      decoration: BoxDecoration(
        color: c.surface,
        border: Border(
          bottom: BorderSide(color: c.border, width: tfHairline),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: tableCheckWidth,
            child: Semantics(
              label: context.l10n.tblSelectAll,
              child: Checkbox(
                key: const Key('select-all'),
                value: allPicked,
                onChanged: canPick ? (on) => onPickAll(on == true) : null,
              ),
            ),
          ),
          cell('title', context.l10n.grpFColTitle, sortable: true),
          for (final col in columns)
            cell(
              col,
              lookups.columnLabel(col, context.l10n),
              sortable: lookups.sortable(col),
            ),
          const SizedBox(width: tableMenuWidth),
        ],
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  const _HeaderCell({
    required this.columnKey,
    required this.label,
    required this.width,
    required this.sort,
    required this.sortable,
    required this.onSort,
    required this.onResize,
  });

  final String columnKey;
  final String label;
  final double width;
  final ({int position, bool desc})? sort;
  final bool sortable;
  final void Function(bool add) onSort;
  final void Function(double dx) onResize;

  @override
  Widget build(BuildContext context) {
    final tf = context.tf;
    final c = tf.colors;
    return SizedBox(
      width: width,
      child: Stack(
        children: [
          Positioned.fill(
            child: InkWell(
              key: Key('header-$columnKey'),
              hoverColor: c.hover,
              splashFactory: NoSplash.splashFactory,
              onTap: sortable
                  ? () => onSort(HardwareKeyboard.instance.isShiftPressed)
                  : null,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: TfSpace.sm),
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        label,
                        overflow: TextOverflow.ellipsis,
                        style: tf.typography.label.copyWith(
                          color: sort == null ? c.textMuted : c.text,
                        ),
                      ),
                    ),
                    if (sort != null) ...[
                      const SizedBox(width: TfSpace.xs),
                      TfIcon(
                        sort!.desc ? TfIcons.arrowDown : TfIcons.arrowUp,
                        key: Key('sort-arrow-$columnKey'),
                        size: 14,
                        color: c.accent,
                        semanticLabel: sort!.desc
                            ? context.l10n.grpDDescending
                            : context.l10n.grpDAscending,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          PositionedDirectional(
            end: 0,
            top: 0,
            bottom: 0,
            width: 10,
            child: MouseRegion(
              cursor: SystemMouseCursors.resizeColumn,
              child: GestureDetector(
                key: Key('resize-$columnKey'),
                behavior: HitTestBehavior.opaque,
                onHorizontalDragUpdate: (d) => onResize(
                  Directionality.of(context) == TextDirection.rtl
                      ? -d.delta.dx
                      : d.delta.dx,
                ),
                child: VerticalDivider(
                  width: 10,
                  thickness: 1,
                  color: c.border,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
