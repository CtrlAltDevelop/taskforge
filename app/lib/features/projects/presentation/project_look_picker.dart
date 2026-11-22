import 'package:taskforge/core/ui/tf_icons.dart';
import 'package:material_ui/material_ui.dart';

import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/features/projects/domain/projects.dart';
import 'package:taskforge/features/projects/presentation/project_avatar.dart';
import 'package:taskforge/core/ui/tokens/colors.dart';
import 'package:taskforge/core/ui/tokens/spacing.dart';

/// Icon and color choice from the fixed sets; [enabled] false makes it inert.
class ProjectLookPicker extends StatelessWidget {
  const ProjectLookPicker({
    super.key,
    required this.icon,
    required this.color,
    required this.onIcon,
    required this.onColor,
    this.enabled = true,
  });

  final String icon;
  final String color;
  final ValueChanged<String> onIcon;
  final ValueChanged<String> onColor;
  final bool enabled;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Wrap(
        spacing: 8,
        children: [
          for (final i in projectIcons)
            ChoiceChip(
              key: Key('icon-$i'),
              label: Text(i),
              selected: i == icon,
              onSelected: enabled ? (_) => onIcon(i) : null,
            ),
        ],
      ),
      const SizedBox(height: TfSpace.sm),
      Wrap(
        spacing: 8,
        children: [
          for (final c in projectColors)
            Semantics(
              label: context.l10n.grpHColorLabel(c),
              selected: c == color,
              button: true,
              child: InkWell(
                key: Key('color-$c'),
                customBorder: const CircleBorder(),
                onTap: enabled ? () => onColor(c) : null,
                child: CircleAvatar(
                  radius: 14,
                  backgroundColor: parseProjectColor(c),
                  child: c == color
                      ? const TfIcon(TfIcons.check, size: 16, color: tfWhite)
                      : null,
                ),
              ),
            ),
        ],
      ),
    ],
  );
}

class VisibilityPicker extends StatelessWidget {
  const VisibilityPicker({
    super.key,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  final ProjectVisibility value;
  final ValueChanged<ProjectVisibility> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SegmentedButton<ProjectVisibility>(
        key: const Key('project-visibility'),
        segments: [
          ButtonSegment(
            value: ProjectVisibility.open,
            label: Text(context.l10n.grpHVisOpen),
            icon: const TfIcon(TfIcons.globe),
          ),
          ButtonSegment(
            value: ProjectVisibility.private,
            label: Text(context.l10n.grpHVisPrivate),
            icon: const TfIcon(TfIcons.lock),
          ),
        ],
        selected: {value},
        onSelectionChanged: enabled ? (s) => onChanged(s.first) : null,
      ),
      const SizedBox(height: TfSpace.xs),
      Text(
        value == ProjectVisibility.open
            ? context.l10n.grpHVisOpenHint
            : context.l10n.grpHVisPrivateHint,
        style: Theme.of(context).textTheme.bodySmall,
      ),
    ],
  );
}
