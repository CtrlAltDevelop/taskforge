import 'package:material_ui/material_ui.dart';

import 'package:taskforge/core/i18n/formatting.dart';
import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/core/i18n/locale_prefs.dart';
import 'package:taskforge/core/ui/theme_extension.dart';
import 'package:taskforge/core/ui/tf/tf_menu.dart';
import 'package:taskforge/core/ui/tf_icons.dart';
import 'package:taskforge/core/ui/tokens/shape.dart';
import 'package:taskforge/core/ui/tokens/spacing.dart';
import 'package:taskforge/features/audit/domain/activity_lines.dart'
    show relativeTime;
import 'package:taskforge/features/comments/domain/comments.dart';
import 'package:taskforge/features/comments/presentation/comments_section.dart'
    show BodyView;

TfIconData eventIcon(String field) => switch (field) {
  'title' => TfIcons.edit,
  'status_id' => TfIcons.refresh,
  'priority' => TfIcons.flag,
  'start_date' || 'due_date' => TfIcons.calendar,
  'estimate_sec' => TfIcons.clock,
  'assignees' => TfIcons.userPlus,
  'subtask_added' => TfIcons.plus,
  _ => TfIcons.edit,
};

/// A centred day label between hairlines.
class DayDivider extends StatelessWidget {
  const DayDivider({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final tf = context.tf;
    final line = Expanded(
      child: Divider(height: 1, thickness: tfHairline, color: tf.colors.border),
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: TfSpace.md),
      child: Row(
        spacing: TfSpace.sm,
        children: [
          line,
          Text(
            label,
            key: Key('day-$label'),
            style: tf.typography.caption.copyWith(color: tf.colors.textMuted),
          ),
          line,
        ],
      ),
    );
  }
}

/// One change to the task as a single muted line: no bubble, no actions.
/// The time is relative (exact on hover or long-press).
class SystemEvent extends StatelessWidget {
  const SystemEvent({
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
    final tf = context.tf;
    final c = tf.colors;
    final event = comment.event;
    final at = comment.createdAt.toLocal();
    final clock = '${_two(at.hour)}:${_two(at.minute)}';
    final exact =
        '${dateOrIso(at, prefs: prefs, l10n: context.l10n)} '
        '${prefs == null ? clock : prefs!.digits(clock)}';
    final person = event?.byPerson ?? false;
    final small = tf.typography.small.copyWith(color: c.textMuted);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: TfSpace.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: TfSpace.sm,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(color: c.sunken, shape: BoxShape.circle),
            child: Center(
              child: TfIcon(
                eventIcon(event?.field ?? ''),
                size: 12,
                color: c.textMuted,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: TfSpace.xxs),
              child: Text.rich(
                TextSpan(
                  style: small,
                  children: [
                    TextSpan(
                      text: person && !isMe ? '@$actor' : actor,
                      style: small.copyWith(
                        fontWeight: FontWeight.w600,
                        color: person ? c.accent : c.textMuted,
                      ),
                    ),
                    TextSpan(text: ' $phrase · '),
                    WidgetSpan(
                      alignment: PlaceholderAlignment.baseline,
                      baseline: TextBaseline.alphabetic,
                      child: TfTooltip(
                        message: exact,
                        child: Text(
                          relativeTime(
                            now,
                            comment.createdAt,
                            context.l10n,
                            prefs,
                          ),
                          key: Key('system-time-${comment.id}'),
                          style: small,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _two(int n) => n.toString().padLeft(2, '0');
}

/// A pinned message in the strip above the conversation.
class PinnedMessage extends StatelessWidget {
  const PinnedMessage({super.key, required this.comment, required this.author});

  final Comment comment;
  final String author;

  @override
  Widget build(BuildContext context) {
    final tf = context.tf;
    final c = tf.colors;
    return Container(
      padding: const EdgeInsets.all(TfSpace.sm),
      decoration: BoxDecoration(
        color: c.accentTone.bg,
        borderRadius: TfRadius.control,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: TfSpace.sm,
        children: [
          TfIcon(TfIcons.pin, size: 14, color: c.accentTone.fg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  author,
                  style: tf.typography.caption.copyWith(
                    color: c.accentTone.fg,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                BodyView(comment.body),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
