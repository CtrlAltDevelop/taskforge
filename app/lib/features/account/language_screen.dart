import 'package:taskforge/core/ui/content_width.dart';
import 'package:taskforge/core/ui/tf_app_bar.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/core/i18n/formatting.dart';
import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/core/i18n/locale_prefs.dart';
import 'package:taskforge/features/account/locale_providers.dart';

/// Each language in its own script: a person who cannot read the current
/// language must still be able to find theirs, so these are never translated.
const languageNames = {
  'en': 'English',
  'fa': 'فارسی',
  'ar': 'العربية',
  'ps': 'پښتو',
};

/// Language, calendar, week start and digits.
class LanguageScreen extends ConsumerWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final prefs = ref.watch(localePrefsProvider);
    final messenger = ScaffoldMessenger.of(context);

    Future<void> change(LocalePrefs Function(LocalePrefs) edit) async {
      final synced = await ref.read(localePrefsProvider.notifier).update(edit);
      if (!synced) {
        messenger.showSnackBar(SnackBar(content: Text(l10n.prefsSaveFailed)));
      }
    }

    return Scaffold(
      appBar: TfAppBar(title: Text(l10n.languageAndRegion)),
      body: ContentWidth(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _Heading(l10n.languageLabel),
            RadioGroup<String>(
              groupValue: prefs.effectiveLanguage,
              onChanged: (v) => change((p) => p.copyWith(language: v)),
              child: Column(
                children: [
                  for (final code in supportedLanguages)
                    RadioListTile<String>(
                      key: Key('language-$code'),
                      value: code,
                      title: Text(languageNames[code]!),
                    ),
                ],
              ),
            ),
            const Divider(),
            _Heading(l10n.calendarSystemLabel),
            SegmentedButton<String>(
              key: const Key('calendar-system'),
              segments: [
                ButtonSegment(
                  value: 'gregorian',
                  label: Text(l10n.calendarGregorian),
                ),
                ButtonSegment(
                  value: 'jalali',
                  label: Text(l10n.calendarJalali),
                ),
              ],
              selected: {prefs.calendar},
              onSelectionChanged: (s) =>
                  change((p) => p.copyWith(calendar: s.first)),
            ),
            const SizedBox(height: 16),
            _Heading(l10n.weekStartLabel),
            DropdownButton<String>(
              key: const Key('week-start'),
              value: prefs.weekStart,
              isExpanded: true,
              items: [
                DropdownMenuItem(value: '', child: Text(l10n.weekStartDefault)),
                DropdownMenuItem(value: 'sat', child: Text(l10n.weekSaturday)),
                DropdownMenuItem(value: 'sun', child: Text(l10n.weekSunday)),
                DropdownMenuItem(value: 'mon', child: Text(l10n.weekMonday)),
              ],
              onChanged: (v) => change((p) => p.copyWith(weekStart: v ?? '')),
            ),
            const SizedBox(height: 16),
            _Heading(l10n.numeralsLabel),
            SegmentedButton<String>(
              key: const Key('numerals'),
              segments: [
                ButtonSegment(value: '', label: Text(l10n.numeralsLatin)),
                ButtonSegment(
                  value: 'native',
                  label: Text(l10n.numeralsNative),
                ),
              ],
              selected: {prefs.numerals},
              onSelectionChanged: (s) =>
                  change((p) => p.copyWith(numerals: s.first)),
            ),
            const Divider(height: 32),
            _Heading(l10n.previewLabel),
            Text(
              formatDate(DateTime.now(), prefs, l10n, long: true),
              key: const Key('date-preview'),
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _Heading extends StatelessWidget {
  const _Heading(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(text, style: Theme.of(context).textTheme.titleSmall),
  );
}
