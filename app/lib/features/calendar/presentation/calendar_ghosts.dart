import 'package:taskforge/core/ui/tf_icons.dart';
import 'package:taskforge/core/ui/tokens/typography.dart';
import 'package:taskforge/core/ui/tokens/spacing.dart';
import 'package:material_ui/material_ui.dart';

import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/features/calendar/domain/calendar_math.dart';
import 'package:taskforge/features/recurrence/domain/recurrence.dart';

/// The ghosts (dates a repeating task has not made yet) that fall on [day].
List<RepeatGhost> ghostsOn(List<RepeatGhost> ghosts, Day day) {
  final iso = formatDay(day);
  return [
    for (final g in ghosts)
      if (g.dueDate == iso) g,
  ];
}

/// One faded line for a task a repeat will make on that day.
class GhostTile extends StatelessWidget {
  const GhostTile({super.key, required this.ghost, this.dense = false});

  final RepeatGhost ghost;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final faded = Theme.of(context).colorScheme.outline;
    if (dense) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: TfSpace.xs),
        child: Row(
          children: [
            TfIcon(TfIcons.repeat, size: 12, color: faded),
            const SizedBox(width: TfSpace.xxs),
            Expanded(
              child: Text(
                ghost.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: faded,
                  fontSize: TfFontSize.caption,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      );
    }
    return ListTile(
      key: Key('ghost-${ghost.seriesId}-${ghost.dueDate}'),
      leading: TfIcon(TfIcons.repeat, size: TfIconSize.control, color: faded),
      title: Text(
        ghost.title,
        style: TextStyle(color: faded, fontStyle: FontStyle.italic),
      ),
      subtitle: Text(context.l10n.grpFRepeatsNotMade),
    );
  }
}

/// Under each week of the grid: the ghosts of its seven days, two lines a day
/// at most.
class GhostRow extends StatelessWidget {
  const GhostRow({super.key, required this.weekFirst, required this.ghosts});

  final Day weekFirst;
  final List<RepeatGhost> ghosts;

  static const _perDay = 2;

  @override
  Widget build(BuildContext context) {
    final days = [
      for (var c = 0; c < 7; c++) ghostsOn(ghosts, addDays(weekFirst, c)),
    ];
    if (days.every((d) => d.isEmpty)) return const SizedBox.shrink();
    return Row(
      key: Key('ghost-row-${formatDay(weekFirst)}'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final day in days)
          Expanded(
            child: Column(
              children: [
                for (final g in day.take(_perDay))
                  GhostTile(ghost: g, dense: true),
                if (day.length > _perDay)
                  Text(
                    context.l10n.grpFPlusMore(day.length - _perDay),
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
