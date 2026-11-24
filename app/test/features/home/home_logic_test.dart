import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskforge/core/version.dart';
import 'package:taskforge/core/ui/breakpoints.dart';
import 'package:taskforge/features/home/application/home_providers.dart';
import 'package:taskforge/features/home/domain/home.dart';
import 'package:taskforge/features/home/presentation/home_greeting.dart';
import 'package:taskforge/features/home/presentation/home_screen.dart';
import 'package:taskforge/features/system/presentation/whats_new.dart';
import 'package:taskforge/l10n/gen/app_localizations.dart';

void main() {
  group('the clock', () {
    test('moves on at 05:00, 12:00, 17:00 and midnight', () {
      DateTime next(int h, [int m = 0]) =>
          nextClockBoundary(DateTime(2026, 11, 18, h, m));
      expect(next(0, 30), DateTime(2026, 11, 18, 5));
      expect(next(5), DateTime(2026, 11, 18, 12));
      expect(next(11, 59), DateTime(2026, 11, 18, 12));
      expect(next(12), DateTime(2026, 11, 18, 17));
      expect(next(17), DateTime(2026, 11, 19));
      expect(next(23, 59), DateTime(2026, 11, 19));
    });

    test('isoDate pads', () {
      expect(isoDate(DateTime(2026, 1, 5)), '2026-01-05');
    });
  });

  group('the greeting', () {
    final l = lookupAppLocalizations(const Locale('en'));

    test('follows the hour and names the person', () {
      expect(greetingFor(l, 8, 'Zoe'), 'Good morning, Zoe');
      expect(greetingFor(l, 12, 'Zoe'), 'Good afternoon, Zoe');
      expect(greetingFor(l, 18, 'Zoe'), 'Good evening, Zoe');
    });

    test('is evening after midnight until five, never a stale morning', () {
      expect(greetingFor(l, 0, 'Zoe'), 'Good evening, Zoe');
      expect(greetingFor(l, 4, ''), 'Good evening');
      expect(greetingFor(l, 5, ''), 'Good morning');
    });

    test('is spoken in the language on screen', () {
      final fa = lookupAppLocalizations(const Locale('fa'));
      expect(greetingFor(fa, 8, 'زویا'), 'صبح بخیر، زویا');
    });
  });

  group('card preferences', () {
    test('default to every card in order, none hidden', () {
      const cards = HomeCards();
      expect(cards.shown, homeCardIds);
    });

    test('survive a round trip and pick up cards added later', () {
      final saved = const HomeCards(
        order: ['time', 'today'],
        hidden: {'today'},
      ).toJson();
      final loaded = HomeCards.fromJson(saved);
      expect(loaded.order.take(2), ['time', 'today']);
      expect(loaded.order.toSet(), homeCardIds.toSet());
      expect(loaded.hidden, {'today'});
      expect(loaded.shown.first, 'time');
    });

    test('ignore unknown ids and broken text', () {
      expect(HomeCards.fromJson('not json').order, homeCardIds);
      final odd = HomeCards.fromJson(
        '{"order":["ghost","recent"],"hidden":["ghost"]}',
      );
      expect(odd.order.first, 'recent');
      expect(odd.hidden, isEmpty);
    });
  });

  test('one column on a phone, two on a tablet, three on a desktop', () {
    expect(homeColumns(ScreenSize.compact), 1);
    expect(homeColumns(ScreenSize.medium), 2);
    expect(homeColumns(ScreenSize.expanded), 3);
  });

  test('fewer columns when the width cannot give each card enough room', () {
    expect(fitColumns(3, 1200), 3);
    expect(fitColumns(3, 750), 2);
    expect(fitColumns(3, 500), 1);
    expect(fitColumns(2, 2000), 2);
    expect(fitColumns(3, 100), 1);
  });

  group('what is new', () {
    test('first install shows nothing, whatever the version', () {
      expect(notesFor(null, '1.1.0'), isEmpty);
      expect(notesFor(null, '1.0.0'), isEmpty);
    });

    test('an upgrade shows this build\'s notes', () {
      expect(notesFor('1.0.0', '1.1.0'), releaseNotes);
      expect(notesFor('0.9.0', '1.0.0'), releaseNotes);
      expect(notesFor('1.0.0', '1.0.1'), releaseNotes);
    });

    test('the same version and a downgrade show none', () {
      expect(notesFor('1.1.0', '1.1.0'), isEmpty);
      expect(notesFor('1.1.0', '1.0.0'), isEmpty);
    });

    test('the version comes from the app version source', () {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      expect(c.read(appVersionProvider), clientVersion);
    });

    test('every note has text in every language', () {
      for (final code in ['en', 'fa', 'ar', 'ps']) {
        final l = lookupAppLocalizations(Locale(code));
        for (final note in releaseNotes) {
          expect(note(l), isNotEmpty);
        }
      }
    });
  });

  test('MyWorkPage joins pages and keeps the last cursor', () {
    const a = MyWorkPage([], nextCursor: 'c1');
    const b = MyWorkPage([], nextCursor: '');
    expect(a.hasMore, isTrue);
    expect(a.plus(b).hasMore, isFalse);
  });
}
