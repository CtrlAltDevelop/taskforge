import 'package:flutter/material.dart';

import 'package:taskforge/core/config.dart';
import 'package:taskforge/features/workspaces/domain/workspace.dart';

/// The workspace's logo, or its initial when it has none.
class WorkspaceLogo extends StatelessWidget {
  const WorkspaceLogo({super.key, required this.workspace, this.radius = 16});

  final Workspace workspace;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final logo = workspace.logo;
    if (logo.isEmpty) {
      final name = workspace.name.trim();
      return CircleAvatar(
        radius: radius,
        child: Text(name.isEmpty ? '?' : name[0].toUpperCase()),
      );
    }
    final url = logo.startsWith('http') ? logo : '${AppConfig.restUrl}$logo';
    return CircleAvatar(radius: radius, backgroundImage: NetworkImage(url));
  }
}
