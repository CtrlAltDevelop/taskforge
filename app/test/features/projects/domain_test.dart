import 'package:flutter_test/flutter_test.dart';
import 'package:taskforge/features/projects/domain/projects.dart';

import 'fakes.dart';

void main() {
  group('deriveKey', () {
    test('uses initials of several words', () {
      expect(deriveKey('Web App Redesign'), 'WAR');
    });

    test('uses the first three letters of a single word', () {
      expect(deriveKey('Marketing'), 'MAR');
    });

    test('caps at six letters and ignores digits and symbols', () {
      expect(deriveKey('a b c d e f g h'), 'ABCDEF');
      expect(deriveKey('2026 !!'), '');
    });
  });

  group('validateProjectKey', () {
    test('accepts 2 to 6 capital letters', () {
      expect(validateProjectKey('WE'), isNull);
      expect(validateProjectKey('WEBAPP'), isNull);
    });

    test('rejects short, long, lowercase and non-letters', () {
      for (final bad in ['', 'W', 'WEBAPPS', 'web', 'W3B', 'WE-B']) {
        expect(validateProjectKey(bad), isNotNull, reason: bad);
      }
    });
  });

  test('normalizeKey uppercases, strips and caps', () {
    expect(normalizeKey('we-b_1app!x'), 'WEBAPP');
  });

  test('validateProjectName requires 1-80 characters', () {
    expect(validateProjectName('  '), isNotNull);
    expect(validateProjectName('a' * 81), isNotNull);
    expect(validateProjectName('Web'), isNull);
  });

  test('sidebarOrder puts favorites first and hides archived', () {
    final ordered = sidebarOrder([
      project('1', 'Zulu'),
      project('2', 'Beta', favorite: true),
      project('3', 'Alpha'),
      project('4', 'Gone', archived: true, favorite: true),
      project('5', 'Able', favorite: true),
    ]);

    expect(ordered.map((p) => p.name), ['Able', 'Beta', 'Alpha', 'Zulu']);
  });
}
