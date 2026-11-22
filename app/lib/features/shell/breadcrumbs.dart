import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:taskforge/core/ui/theme_extension.dart';
import 'package:taskforge/core/ui/tf/tf_interactive.dart';
import 'package:taskforge/core/ui/tf/tf_menu.dart';
import 'package:taskforge/core/ui/tf_icons.dart';
import 'package:taskforge/core/ui/tokens/shape.dart';
import 'package:taskforge/core/ui/tokens/spacing.dart';
import 'package:taskforge/features/chat/application/chat_providers.dart';
import 'package:taskforge/features/docs/application/docs_providers.dart';
import 'package:taskforge/features/forms/application/forms_providers.dart';
import 'package:taskforge/features/goals/application/goals_providers.dart';
import 'package:taskforge/features/projects/application/projects_providers.dart';
import 'package:taskforge/features/tasks/application/tasks_providers.dart';
import 'package:taskforge/features/shell/crumbs.dart';
import 'package:taskforge/features/workspaces/application/workspace_providers.dart';
import 'package:taskforge/l10n/gen/app_localizations.dart';

/// Below this many pixels the middle of a long trail folds into "…".
const crumbFoldWidth = 560.0;

/// The trail for [uri] with the names the app already holds. Each name is
/// read only for the kind of page that is open, so a crumb never starts a
/// load the page itself does not make; null (still loading, or not visible)
/// leaves the generic word.
List<Crumb> currentCrumbs(WidgetRef ref, Uri uri, AppLocalizations l) =>
    crumbsFor(
      uri,
      l,
      workspace: ref.watch(currentWorkspaceProvider)?.name ?? l.appTitle,
      nameOf: (kind, id) => switch (kind) {
        'project' => ref.watch(projectProvider(id))?.name,
        'task' => _taskName(ref, uri, id),
        'doc' =>
          ref
              .watch(docTreeProvider(''))
              .value
              ?.where((d) => d.id == id)
              .firstOrNull
              ?.labelIn(l),
        'goal' => ref.watch(goalsProvider).value?.byId(id)?.name,
        'space' => _spaceName(ref, id),
        'form' =>
          ref
              .watch(formsProvider)
              .value
              ?.where((f) => f.id == id)
              .firstOrNull
              ?.name,
        _ => null,
      },
    );

String? _taskName(WidgetRef ref, Uri uri, String id) {
  final project = uri.pathSegments.length > 1 ? uri.pathSegments[1] : '';
  if (project.isEmpty) return null;
  final tasks = ref.watch(taskListProvider(project)).tasks;
  return tasks.where((t) => t.id == id).firstOrNull?.title;
}

String? _spaceName(WidgetRef ref, String id) {
  final name = ref
      .watch(spacesProvider)
      .list
      .all
      .where((s) => s.id == id)
      .firstOrNull
      ?.name;
  return name == null || name.isEmpty ? null : name;
}

/// Workspace › Project › View. Every segment but the last is a link; on a
/// narrow bar the middle folds into a "…" menu of the hidden ones.
class Breadcrumbs extends StatelessWidget {
  const Breadcrumbs({super.key, required this.crumbs});

  final List<Crumb> crumbs;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, box) {
      final fold = crumbs.length > 3 && box.maxWidth < crumbFoldWidth;
      final shown = fold ? [crumbs.first, crumbs.last] : crumbs;
      final hidden = fold ? crumbs.sublist(1, crumbs.length - 1) : <Crumb>[];
      return Row(
        key: const Key('breadcrumbs'),
        children: [
          for (final (i, crumb) in shown.indexed) ...[
            if (i > 0) const _Separator(),
            if (fold && i == 1) ...[_Fold(hidden: hidden), const _Separator()],
            Flexible(
              child: _Segment(crumb: crumb, last: i == shown.length - 1),
            ),
          ],
        ],
      );
    },
  );
}

class _Separator extends StatelessWidget {
  const _Separator();

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: TfSpace.xxs),
    child: TfIcon(
      TfIcons.chevronEnd,
      size: 12,
      color: context.tf.colors.textSubtle,
    ),
  );
}

class _Segment extends StatelessWidget {
  const _Segment({required this.crumb, required this.last});

  final Crumb crumb;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final tf = context.tf;
    final path = crumb.path;
    final text = Text(
      crumb.label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: (last ? tf.typography.bodyStrong : tf.typography.body).copyWith(
        color: last ? tf.colors.text : tf.colors.textMuted,
      ),
    );
    if (last || path == null) {
      return Semantics(
        header: last,
        child: Tooltip(message: crumb.label, child: text),
      );
    }
    return TfInteractive(
      onTap: () => context.go(path),
      builder: (context, states) => Container(
        padding: const EdgeInsets.symmetric(
          horizontal: TfSpace.xs,
          vertical: TfSpace.xxs,
        ),
        decoration: BoxDecoration(
          color: states.contains(WidgetState.hovered) ? tf.colors.hover : null,
          borderRadius: TfRadius.control,
          border: states.contains(WidgetState.focused)
              ? tfFocusRing(tf.colors)
              : null,
        ),
        child: text,
      ),
    );
  }
}

class _Fold extends StatelessWidget {
  const _Fold({required this.hidden});

  final List<Crumb> hidden;

  @override
  Widget build(BuildContext context) => TfMenu(
    items: [
      for (final c in hidden)
        TfMenuItem(
          label: c.label,
          onSelected: c.path == null ? null : () => context.go(c.path!),
        ),
    ],
    builder: (context, toggle) => TfInteractive(
      key: const Key('crumbs-fold'),
      onTap: toggle,
      semanticLabel: hidden.map((c) => c.label).join(', '),
      padTarget: true,
      builder: (context, _) => Text(
        '…',
        style: context.tf.typography.body.copyWith(
          color: context.tf.colors.textMuted,
        ),
      ),
    ),
  );
}
