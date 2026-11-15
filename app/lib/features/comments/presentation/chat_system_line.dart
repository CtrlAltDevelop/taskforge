import 'package:material_ui/material_ui.dart';

import 'package:taskforge/core/i18n/formatting.dart';
import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/core/i18n/locale_prefs.dart';
import 'package:taskforge/features/audit/domain/activity_lines.dart'
    show relativeTime;
import 'package:taskforge/features/comments/domain/comments.dart';

IconData chatEventIcon(String field) => switch (field) {
  'title' => Icons.edit_outlined,
  'status_id' => Icons.swap_horiz,
  'priority' => Icons.flag_outlined,
  'start_date' || 'due_date' => Icons.event_outlined,
  'estimate_sec' => Icons.timer_outlined,
  'assignees' => Icons.person_add_alt_outlined,
  'subtask_added' => Icons.subdirectory_arrow_right,
  _ => Icons.edit_note,
};

/// One change to the task, as a single muted line: no bubble, no actions.
/// The time is relative (exact on hover or long-press).
class ChatSystemLine extends StatelessWidget {
  const ChatSystemLine({
    super.key,
    required this.comment,
    required this.now,
    required this.actor,
    required this.phrase,
    this.isMe = false,
    this.prefs,
  });

  final Comment comment;
  final DateTime now;

  /// The person's name, or what the automation, form or import is called.
  final String actor;
  final String phrase;
  final bool isMe;
  final LocalePrefs? prefs;

  @override
  Widget build(BuildContext context) {
    final event = comment.event;
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final at = comment.createdAt.toLocal();
    final exact =
        '${dateOrIso(at, prefs: prefs, l10n: context.l10n)} '
        '${_clock(at)}';
    final person = event?.byPerson ?? false;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 8, top: 2),
            child: Icon(
              chatEventIcon(event?.field ?? ''),
              size: 14,
              color: muted,
            ),
          ),
          Expanded(
            child: Text.rich(
              TextSpan(
                style: theme.textTheme.bodySmall?.copyWith(color: muted),
                children: [
                  TextSpan(
                    text: person && !isMe ? '@$actor' : actor,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: person ? theme.colorScheme.primary : muted,
                    ),
                  ),
                  TextSpan(text: ' $phrase · '),
                  WidgetSpan(
                    alignment: PlaceholderAlignment.baseline,
                    baseline: TextBaseline.alphabetic,
                    child: Tooltip(
                      message: exact,
                      child: Text(
                        relativeTime(
                          now,
                          comment.createdAt,
                          context.l10n,
                          prefs,
                        ),
                        key: Key('system-time-${comment.id}'),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: muted,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _clock(DateTime at) {
    String two(int n) => n.toString().padLeft(2, '0');
    final text = '${two(at.hour)}:${two(at.minute)}';
    return prefs == null ? text : prefs!.digits(text);
  }
}
