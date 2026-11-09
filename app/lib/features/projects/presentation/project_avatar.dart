import 'package:flutter/material.dart';

import 'package:taskforge/features/projects/domain/projects.dart';

/// Parses `#RRGGBB`; null for anything else.
Color? parseProjectColor(String hex) {
  final match = RegExp(r'^#([0-9A-Fa-f]{6})$').firstMatch(hex);
  return match == null
      ? null
      : Color(0xFF000000 | int.parse(match[1]!, radix: 16));
}

/// The project's icon on its color; the key's first letter when it has no icon.
class ProjectAvatar extends StatelessWidget {
  const ProjectAvatar({super.key, required this.project, this.radius = 16});

  final Project project;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final color =
        parseProjectColor(project.color) ??
        Theme.of(context).colorScheme.primary;
    return CircleAvatar(
      radius: radius,
      backgroundColor: color.withValues(alpha: 0.2),
      child: Text(
        project.icon.isEmpty
            ? project.key.characters.firstOrNull ?? '?'
            : project.icon,
        style: TextStyle(fontSize: radius * 0.9, color: color),
      ),
    );
  }
}
