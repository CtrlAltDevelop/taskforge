import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Phase 44's design-system lint: a screen under `lib/features/` must not
/// carry a hex colour, an ad-hoc `BorderRadius.circular` or a raw `Icons.*`;
/// it uses the tokens, `TfRadius` and `TfIcons`. Screens not migrated yet are
/// in the allow-list; it can only shrink, and phase 49 empties it.
///
/// After migrating a file, remove it from the list (the test says which).
const _allowListPath = 'test/core/ui/ui_lint_allowlist.txt';

final _rules = {
  'hex colour': RegExp(r'Color\(\s*0x[0-9A-Fa-f]{6,8}\s*\)'),
  'BorderRadius.circular': RegExp(r'BorderRadius\.circular\('),
  'raw Icons.*': RegExp(r'\bIcons\.[a-z]'),
};

Set<String> _violators() => {
  for (final f in Directory(
    'lib/features',
  ).listSync(recursive: true).whereType<File>())
    if (f.path.endsWith('.dart') &&
        _rules.values.any((r) => r.hasMatch(f.readAsStringSync())))
      f.path.replaceAll(r'\', '/'),
};

void main() {
  final allowed = File(_allowListPath)
      .readAsLinesSync()
      .where((l) => l.trim().isNotEmpty && !l.startsWith('#'))
      .toSet();
  final found = _violators();

  test(
    'no migrated screen uses a hex colour, BorderRadius.circular or Icons.*',
    () {
      expect(
        found.difference(allowed),
        isEmpty,
        reason: 'use tokens, TfRadius, TfIcons',
      );
    },
  );

  test('the allow-list only names files that still break a rule', () {
    expect(
      allowed.difference(found),
      isEmpty,
      reason: 'remove migrated files from $_allowListPath',
    );
  });

  test('the rules recognise what they are meant to catch', () {
    expect(_rules['hex colour']!.hasMatch('Color(0xFF112233)'), isTrue);
    expect(
      _rules['BorderRadius.circular']!.hasMatch('BorderRadius.circular(8)'),
      isTrue,
    );
    expect(_rules['raw Icons.*']!.hasMatch('Icon(Icons.add)'), isTrue);
    expect(_rules['raw Icons.*']!.hasMatch('TfIcons.add'), isFalse);
  });
}
