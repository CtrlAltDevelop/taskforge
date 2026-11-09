import 'package:flutter/material.dart';

import 'package:taskforge/features/projects/domain/projects.dart';
import 'package:taskforge/features/projects/presentation/project_avatar.dart';

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
      const SizedBox(height: 8),
      Wrap(
        spacing: 8,
        children: [
          for (final c in projectColors)
            Semantics(
              label: 'Color $c',
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
                      ? const Icon(Icons.check, size: 16, color: Colors.white)
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
        segments: const [
          ButtonSegment(
            value: ProjectVisibility.open,
            label: Text('Open'),
            icon: Icon(Icons.public),
          ),
          ButtonSegment(
            value: ProjectVisibility.private,
            label: Text('Private'),
            icon: Icon(Icons.lock),
          ),
        ],
        selected: {value},
        onSelectionChanged: enabled ? (s) => onChanged(s.first) : null,
      ),
      const SizedBox(height: 4),
      Text(
        value == ProjectVisibility.open
            ? 'Everyone in the workspace can see it.'
            : 'Only invited members can see it.',
        style: Theme.of(context).textTheme.bodySmall,
      ),
    ],
  );
}
