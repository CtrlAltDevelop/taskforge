import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/features/shortcuts/application/shortcuts_providers.dart';
import 'package:taskforge/features/shortcuts/presentation/command_palette.dart';

/// "+ Task" of the toolbar: runs the same registered `task.new` action as the
/// palette and its key, so what is asked and allowed cannot differ.
void runNewTask(BuildContext context, WidgetRef ref) => ref
    .read(actionRegistryProvider)
    .byId('task.new')
    ?.run(actionContextOf(context));
