import 'package:taskforge/core/ui/page/tf_form.dart';
import 'package:taskforge/core/ui/page/tf_page.dart';
import 'package:taskforge/core/ui/page/tf_select_field.dart';
import 'package:taskforge/core/ui/tf/tf_row.dart';
import 'package:taskforge/core/ui/tf/tf_tabs.dart';
import 'package:taskforge/core/ui/theme_extension.dart';
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

    final tf = context.tf;
    return Scaffold(
      appBar: TfAppBar(title: Text(l10n.languageAndRegion)),
      body: TfPage(
        children: [
          TfFormSection(
            title: l10n.languageLabel,
            children: [
              RadioGroup<String>(
                groupValue: prefs.effectiveLanguage,
                onChanged: (v) => change((p) => p.copyWith(language: v)),
                child: Column(
                  children: [
                    for (final code in supportedLanguages)
                      TfRow(
                        key: Key('language-$code'),
                        leading: Semantics(
                          label: languageNames[code],
                          child: Radio<String>(value: code),
                        ),
                        title: languageNames[code]!,
                        selected: code == prefs.effectiveLanguage,
                        onTap: () => change((p) => p.copyWith(language: code)),
                      ),
                  ],
                ),
              ),
            ],
          ),
          TfFormSection(
            title: l10n.calendarSystemLabel,
            children: [
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: TfSegmented<String>(
                  key: const Key('calendar-system'),
                  options: {
                    'gregorian': l10n.calendarGregorian,
                    'jalali': l10n.calendarJalali,
                  },
                  value: prefs.calendar,
                  onChanged: (v) => change((p) => p.copyWith(calendar: v)),
                ),
              ),
              TfFormField(
                label: l10n.weekStartLabel,
                child: TfSelectField<String>(
                  key: const Key('week-start'),
                  expand: true,
                  options: {
                    '': l10n.weekStartDefault,
                    'sat': l10n.weekSaturday,
                    'sun': l10n.weekSunday,
                    'mon': l10n.weekMonday,
                  },
                  value: prefs.weekStart,
                  onChanged: (v) => change((p) => p.copyWith(weekStart: v)),
                ),
              ),
              TfFormField(
                label: l10n.numeralsLabel,
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: TfSegmented<String>(
                    key: const Key('numerals'),
                    options: {
                      '': l10n.numeralsLatin,
                      'native': l10n.numeralsNative,
                    },
                    value: prefs.numerals,
                    onChanged: (v) => change((p) => p.copyWith(numerals: v)),
                  ),
                ),
              ),
            ],
          ),
          TfFormSection(
            title: l10n.previewLabel,
            children: [
              Text(
                formatDate(DateTime.now(), prefs, l10n, long: true),
                key: const Key('date-preview'),
                style: tf.typography.lead.copyWith(color: tf.colors.text),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
