import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/core/sync/sync_providers.dart';
import 'package:taskforge/features/members/application/members_providers.dart';

String _nameOf(WidgetRef ref, String userId) {
  final members = ref.watch(membersProvider).value ?? const [];
  for (final m in members) {
    if (m.userId == userId) {
      return m.displayName.isEmpty ? m.email : m.displayName;
    }
  }
  return 'Someone';
}

/// Says this person is on the task (for as long as the detail is open) and
/// shows who else is, as small avatars.
class PresenceStrip extends ConsumerStatefulWidget {
  const PresenceStrip({
    super.key,
    required this.projectId,
    required this.taskId,
  });

  final String projectId;
  final String taskId;

  @override
  ConsumerState<PresenceStrip> createState() => _PresenceStripState();
}

class _PresenceStripState extends ConsumerState<PresenceStrip> {
  PresenceReporter? _reporter;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reporter = ref.read(presenceReporterProvider);
    _reporter = reporter;
    reporter.enter(widget.projectId, widget.taskId);
  }

  @override
  void dispose() {
    _reporter?.leave(); // not left to the provider: it goes a frame later
    super.dispose();
  }

  @override
  void didUpdateWidget(PresenceStrip old) {
    super.didUpdateWidget(old);
    if (old.taskId != widget.taskId) {
      _reporter?.enter(widget.projectId, widget.taskId);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Held for as long as the detail is open: the reporter lives with it.
    ref.watch(presenceReporterProvider);
    final others = ref.watch(otherViewersProvider(widget.taskId));
    if (others.isEmpty) return const SizedBox.shrink();
    return Row(
      key: const Key('presence-strip'),
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final u in others.take(4))
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 4),
            child: Tooltip(
              message: u.editing
                  ? context.l10n.grpFPresenceEditing(_nameOf(ref, u.id))
                  : context.l10n.grpFPresenceViewing(_nameOf(ref, u.id)),
              child: CircleAvatar(
                key: Key('viewer-${u.id}'),
                radius: 12,
                backgroundColor: u.editing
                    ? Theme.of(context).colorScheme.tertiaryContainer
                    : null,
                child: Text(
                  _nameOf(ref, u.id).characters.first.toUpperCase(),
                  style: const TextStyle(fontSize: 11),
                ),
              ),
            ),
          ),
        if (others.length > 4)
          Text(context.l10n.grpFPlusCount(others.length - 4)),
      ],
    );
  }
}

/// "Ana is editing this": shown under the fields when someone else has the
/// task open for editing, so two people do not write over each other.
class EditingHint extends ConsumerWidget {
  const EditingHint({super.key, required this.taskId});

  final String taskId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final editing = [
      for (final u in ref.watch(otherViewersProvider(taskId)))
        if (u.editing) u,
    ];
    if (editing.isEmpty) return const SizedBox.shrink();
    final names = editing.map((u) => _nameOf(ref, u.id)).toSet().toList();
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        key: const Key('editing-hint'),
        children: [
          Icon(
            Icons.edit_outlined,
            size: 14,
            color: Theme.of(context).colorScheme.tertiary,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              names.length == 1
                  ? l10n.grpFEditingOne(names.single)
                  : l10n.grpFEditingMany(names.length),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
