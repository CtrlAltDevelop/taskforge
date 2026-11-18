import 'package:material_ui/material_ui.dart';

import 'package:taskforge/core/ui/theme_extension.dart';
import 'package:taskforge/core/ui/tf/tf_chip.dart';
import 'package:taskforge/core/ui/tf_icons.dart';
import 'package:taskforge/core/ui/tokens/colors.dart';
import 'package:taskforge/core/ui/tokens/shape.dart';
import 'package:taskforge/core/ui/tokens/spacing.dart';

/// The four status categories a workflow status belongs to.
enum TfStatusKind {
  todo(TfIcons.todo),
  active(TfIcons.active),
  done(TfIcons.done),
  cancelled(TfIcons.cancel);

  const TfStatusKind(this.icon);
  final TfIconData icon;

  TfTone tone(TfColors c) => switch (this) {
    todo => c.statusTodo,
    active => c.statusActive,
    done => c.statusDone,
    cancelled => c.neutral,
  };
}

/// A status: a shape that differs per category, its name, and the category
/// colour. Colour is never the only carrier.
class TfStatusPill extends StatelessWidget {
  const TfStatusPill({
    super.key,
    required this.label,
    required this.kind,
    this.onTap,
  });

  final String label;
  final TfStatusKind kind;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => TfChip(
    label: label,
    tone: kind.tone(context.tf.colors),
    icon: kind.icon,
    onTap: onTap,
  );
}

/// Task priority, ordered from most to least urgent.
enum TfPriority {
  urgent(TfIcons.priorityUrgent),
  high(TfIcons.priorityHigh),
  normal(TfIcons.priorityNormal),
  low(TfIcons.priorityLow),
  none(TfIcons.priorityNone);

  const TfPriority(this.icon);
  final TfIconData icon;

  Color color(TfColors c) => switch (this) {
    urgent => c.danger.fg,
    high => c.warning.fg,
    normal => c.info.fg,
    low => c.textMuted,
    none => c.textSubtle,
  };
}

/// Priority as a glyph whose shape (not just colour) says how urgent it is.
/// [label] is the spoken name; pass [showLabel] to print it too.
class TfPriorityIcon extends StatelessWidget {
  const TfPriorityIcon({
    super.key,
    required this.priority,
    required this.label,
    this.showLabel = false,
  });

  final TfPriority priority;
  final String label;
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    final tf = context.tf;
    final color = priority.color(tf.colors);
    final glyph = TfIcon(
      priority.icon,
      color: color,
      semanticLabel: showLabel ? null : label,
    );
    if (!showLabel) return glyph;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        glyph,
        const SizedBox(width: TfSpace.xs),
        Text(label, style: tf.typography.small.copyWith(color: tf.colors.text)),
      ],
    );
  }
}

/// Radius shared by pills so a status and a chip line up in a row.
BorderRadius get tfPillRadius => TfRadius.chip;
