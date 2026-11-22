import 'package:taskforge/core/ui/tokens/shape.dart';
import 'package:taskforge/core/ui/tokens/spacing.dart';
import 'package:taskforge/core/ui/tf_icons.dart';
import 'package:material_ui/material_ui.dart';

import 'package:taskforge/core/i18n/formatting.dart';
import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/core/i18n/locale_prefs.dart';
import 'package:taskforge/features/comments/domain/comment_text.dart';
import 'package:taskforge/features/comments/domain/comments.dart';
import 'package:taskforge/l10n/gen/app_localizations.dart';

String _two(int n) => n.toString().padLeft(2, '0');

/// "Today", "Yesterday" or the date.
String dayLabel(
  DateTime at,
  DateTime now, {
  AppLocalizations? l10n,
  LocalePrefs? prefs,
}) {
  final l = l10n ?? lookupAppLocalizations(const Locale('en'));
  final d = DateTime(at.year, at.month, at.day);
  final today = DateTime(now.year, now.month, now.day);
  final gap = today.difference(d).inDays;
  if (gap == 0) return l.grpBToday;
  if (gap == 1) return l.grpBYesterday;
  return dateOrIso(d, prefs: prefs, l10n: l10n);
}

String clockOf(DateTime at, [LocalePrefs? prefs]) {
  final text = '${_two(at.toLocal().hour)}:${_two(at.toLocal().minute)}';
  return prefs == null ? text : prefs.digits(text);
}

/// How long an author may edit (the server's default; it has the last word).
const commentEditWindow = Duration(hours: 24);

class ReactionsBar extends StatelessWidget {
  const ReactionsBar({
    super.key,
    required this.id,
    required this.reactions,
    required this.me,
    required this.names,
    required this.canReact,
    required this.onReact,
  });

  final String id;

  /// Emoji -> ids of those who gave it.
  final Map<String, List<String>> reactions;
  final String me;
  final String Function(String) names;
  final bool canReact;
  final void Function(String) onReact;

  @override
  Widget build(BuildContext context) {
    if (reactions.isEmpty && !canReact) return const SizedBox.shrink();
    return Wrap(
      spacing: 4,
      runSpacing: 2,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (final e in reactions.entries)
          Tooltip(
            message: e.value.map(names).join(', '),
            child: FilterChip(
              key: Key('reaction-$id-${e.key}'),
              visualDensity: VisualDensity.compact,
              label: Text('${e.key} ${e.value.length}'),
              selected: e.value.contains(me),
              onSelected: canReact ? (_) => onReact(e.key) : null,
            ),
          ),
        if (canReact)
          PopupMenuButton<String>(
            key: Key('react-$id'),
            icon: const TfIcon(TfIcons.smile, size: 18),
            tooltip: context.l10n.grpBAddReaction,
            onSelected: onReact,
            itemBuilder: (_) => [
              for (final e in quickReactions)
                PopupMenuItem(value: e, child: Text(e)),
            ],
          ),
      ],
    );
  }
}

/// A comment's text: mentions in bold and colour, links underlined.
class BodyView extends StatelessWidget {
  const BodyView(this.body, {super.key});

  final String body;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final lines = segmentsOf(body);
    return SelectableText.rich(
      TextSpan(
        children: [
          for (var i = 0; i < lines.length; i++) ...[
            for (final s in lines[i])
              TextSpan(
                text: s.text,
                style: s.isMention
                    ? TextStyle(
                        fontWeight: FontWeight.bold,
                        color: scheme.primary,
                      )
                    : s.href != null
                    ? TextStyle(
                        color: scheme.primary,
                        decoration: TextDecoration.underline,
                      )
                    : s.bold
                    ? const TextStyle(fontWeight: FontWeight.bold)
                    : null,
              ),
            if (i < lines.length - 1) const TextSpan(text: '\n'),
          ],
        ],
      ),
    );
  }
}

/// Grey placeholder rows shown while the first page of comments loads.
class CommentsSkeleton extends StatelessWidget {
  const CommentsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final grey = Theme.of(context).colorScheme.surfaceContainerHighest;
    Widget bar(double width) => Container(
      width: width,
      height: 10,
      decoration: BoxDecoration(color: grey, borderRadius: TfRadius.chip),
    );
    return Column(
      children: [
        for (var i = 0; i < 3; i++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: TfSpace.sm),
            child: Row(
              children: [
                CircleAvatar(radius: 12, backgroundColor: grey),
                const SizedBox(width: TfSpace.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      bar(120),
                      const SizedBox(height: TfSpace.sm),
                      bar(220),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
