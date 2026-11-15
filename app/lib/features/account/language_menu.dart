import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/core/i18n/locale_prefs.dart';
import 'package:taskforge/features/account/language_screen.dart';
import 'package:taskforge/features/account/locale_providers.dart';

/// A language switch for screens shown before sign-in. The choice is kept on
/// the device; it reaches the account once the person is signed in.
class LanguageMenuButton extends ConsumerWidget {
  const LanguageMenuButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(localePrefsProvider).effectiveLanguage;
    return PopupMenuButton<String>(
      key: const Key('language-menu'),
      tooltip: context.l10n.languageLabel,
      icon: const Icon(Icons.language),
      initialValue: current,
      onSelected: (code) => ref
          .read(localePrefsProvider.notifier)
          .update((p) => p.copyWith(language: code)),
      itemBuilder: (_) => [
        for (final code in supportedLanguages)
          PopupMenuItem(value: code, child: Text(languageNames[code]!)),
      ],
    );
  }
}
