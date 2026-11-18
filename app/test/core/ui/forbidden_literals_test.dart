import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// The design-system gate (phases 44 and 49): no hex colour, ad-hoc
/// `BorderRadius.circular` or raw `Icons.*` anywhere in `lib/features` or
/// `lib/core`, nor a Material `Colors.*` name. Colours, radii and icons come
/// from the tokens (`tfClear`, `tfWhite`, `tfBlack`, the theme's tones),
/// `TfRadius` and `TfIcons`; only `lib/core/ui/tokens` may define the raw values. There is no
/// allow-list: fix the file, do not exempt it.
const _roots = ['lib/features', 'lib/core'];
const _tokensDir = 'lib/core/ui/tokens/';

final _rules = {
  'hex colour': RegExp(r'Color\(\s*0x[0-9A-Fa-f]{6,8}\s*\)'),
  'BorderRadius.circular': RegExp(r'BorderRadius\.circular\('),
  'raw Icons.*': RegExp(r'\bIcons\.[a-z]'),
  // Material's named colours (green, red, grey.shade500, even transparent):
  // use the theme's tones and the tokens (tfClear, tfWhite, tfBlack).
  'Colors.*': RegExp(r'\bColors\.[a-zA-Z]'),
};

/// `file: rule` for every breach.
List<String> _violations() => [
  for (final root in _roots)
    for (final f in Directory(root).listSync(recursive: true).whereType<File>())
      if (f.path.endsWith('.dart') &&
          !f.path.replaceAll(r'\', '/').contains(_tokensDir))
        for (final rule in _rules.entries)
          if (rule.value.hasMatch(f.readAsStringSync()))
            '${f.path.replaceAll(r'\', '/')}: ${rule.key}',
];

void main() {
  test(
    'no hex colour, BorderRadius.circular or Icons.* outside the tokens',
    () {
      expect(
        _violations(),
        isEmpty,
        reason: 'use the tokens (tfBlack, tfClear...), TfRadius and TfIcons',
      );
    },
  );

  test('the rules recognise what they are meant to catch', () {
    expect(_rules['hex colour']!.hasMatch('Color(0xFF112233)'), isTrue);
    expect(_rules['hex colour']!.hasMatch('tfClear'), isFalse);
    expect(
      _rules['BorderRadius.circular']!.hasMatch('BorderRadius.circular(8)'),
      isTrue,
    );
    expect(_rules['raw Icons.*']!.hasMatch('Icon(Icons.add)'), isTrue);
    expect(_rules['raw Icons.*']!.hasMatch('TfIcons.add'), isFalse);
    expect(_rules['Colors.*']!.hasMatch('Colors.green.shade700'), isTrue);
    expect(_rules['Colors.*']!.hasMatch('Colors.transparent'), isTrue);
    expect(_rules['Colors.*']!.hasMatch('TfColors.of(context)'), isFalse);
    expect(_rules['Colors.*']!.hasMatch('c.colors.success'), isFalse);
  });
}
