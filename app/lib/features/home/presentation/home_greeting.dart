import 'package:taskforge/core/i18n/context_dates.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/core/ui/theme_extension.dart';
import 'package:taskforge/features/account/account_providers.dart';
import 'package:taskforge/features/home/application/home_providers.dart';
import 'package:taskforge/l10n/gen/app_localizations.dart';

/// The greeting for [hour] (local), with the person's [name] when known.
String greetingFor(AppLocalizations l, int hour, String name) {
  final hasName = name.isNotEmpty;
  if (hour >= greetingHours[0] && hour < greetingHours[1]) {
    return hasName ? l.homeGreetMorning(name) : l.homeGreetMorningAnon;
  }
  if (hour >= greetingHours[1] && hour < greetingHours[2]) {
    return hasName ? l.homeGreetAfternoon(name) : l.homeGreetAfternoonAnon;
  }
  return hasName ? l.homeGreetEvening(name) : l.homeGreetEveningAnon;
}

/// "Good morning, Sam" and the date in the person's calendar and digits. It
/// follows [homeClockProvider], so it changes at the next greeting boundary
/// and at midnight without anyone reopening the screen.
class HomeGreeting extends ConsumerWidget {
  const HomeGreeting({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = ref.watch(homeClockProvider);
    final account = ref.watch(accountProvider).value;
    final name = account == null
        ? ''
        : (account.displayName.isNotEmpty
              ? account.displayName.split(' ').first
              : '');
    final tf = context.tf;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          header: true,
          child: Text(
            greetingFor(context.l10n, now.hour, name),
            key: const Key('home-greeting'),
            style: tf.typography.title.copyWith(color: tf.colors.text),
          ),
        ),
        Text(
          context.localDate(now, long: true),
          key: const Key('home-date'),
          style: tf.typography.body.copyWith(color: tf.colors.textMuted),
        ),
      ],
    );
  }
}
