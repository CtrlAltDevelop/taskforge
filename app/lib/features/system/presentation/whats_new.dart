import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/core/ui/tf/tf_button.dart';
import 'package:taskforge/core/ui/tf/tf_overlays.dart';
import 'package:taskforge/core/version.dart';
import 'package:taskforge/features/shortcuts/application/local_prefs.dart';
import 'package:taskforge/l10n/gen/app_localizations.dart';

/// What is new in this build, as lines of the ARB files (so they are
/// translated). They describe the build being run: its version is read from
/// the app's own version source ([clientVersion], set by the release build),
/// never typed here. Rewrite the list at each release.
final List<String Function(AppLocalizations)> releaseNotes = [
  (l) => l.wnHome,
  (l) => l.wnMyWork,
  (l) => l.wnStarters,
  (l) => l.wnStates,
];

/// The version this build is; tests replace it.
final appVersionProvider = Provider<String>((ref) => clientVersion);

const _lastSeenKey = 'app.lastSeenVersion';

/// The notes to show for a move from [seen] to [current]: this build's notes
/// when [current] is newer than [seen]. Nothing on first install (no [seen]),
/// on the same version or on a downgrade.
List<String Function(AppLocalizations)> notesFor(String? seen, String current) {
  if (seen == null) return const [];
  return (compareSemVer(current, seen) ?? 0) > 0 ? releaseNotes : const [];
}

/// Shows "What's new" once per version after an upgrade; never on a first
/// install. Wrap the screen it should appear over.
class WhatsNewHost extends ConsumerStatefulWidget {
  const WhatsNewHost({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<WhatsNewHost> createState() => _WhatsNewHostState();
}

class _WhatsNewHostState extends ConsumerState<WhatsNewHost> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _check());
  }

  Future<void> _check() async {
    final prefs = ref.read(localPrefsProvider);
    final current = ref.read(appVersionProvider);
    final seen = await prefs.read(_lastSeenKey);
    if (seen == current) return;
    // Recorded first: a crash or a dismissed dialog must not show it twice.
    await prefs.write(_lastSeenKey, current);
    final notes = notesFor(seen, current);
    if (!mounted || notes.isEmpty) return;
    await showWhatsNew(context, current, notes);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

@visibleForTesting
Future<void> showWhatsNew(
  BuildContext context,
  String version,
  List<String Function(AppLocalizations)> notes,
) {
  final l = context.l10n;
  return showTfDialog<void>(
    context,
    title: l.wnTitle(version),
    body: Column(
      key: const Key('whats-new'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final note in notes)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('•  '),
                Expanded(child: Text(note(l))),
              ],
            ),
          ),
      ],
    ),
    actions: [
      TfButton(
        key: const Key('whats-new-close'),
        label: l.wnClose,
        variant: TfButtonVariant.primary,
        onPressed: () => Navigator.of(context).pop(),
      ),
    ],
  );
}
