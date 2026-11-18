import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Phase 49's screen-reader rules, checked on the source: a Material
/// `IconButton` (icon only) must carry a `tooltip:` (which is also its
/// semantic label), and every `Image`/`SvgPicture` must name itself
/// (`semanticLabel`/`semanticsLabel`) or say it is decorative
/// (`excludeFromSemantics: true`). `TfIconButton` requires a tooltip in its
/// constructor, so it needs no check.
final _calls = {
  RegExp(r'(?<![A-Za-z.])IconButton(?:\.[a-z]+)?\('): [r'tooltip:'],
  RegExp(r'(?<![A-Za-z.])Image\.[a-z]+\('): [
    r'semanticLabel:',
    r'excludeFromSemantics:\s*true',
  ],
  RegExp(r'(?<![A-Za-z.])SvgPicture\.[a-z]+\('): [
    r'semanticsLabel:',
    r'excludeFromSemantics:\s*true',
  ],
};

/// The text of the argument list opened at [open] (the index of its `(`).
String _args(String src, int open) {
  var depth = 0;
  for (var i = open; i < src.length; i++) {
    final ch = src[i];
    if (ch == '(') depth++;
    if (ch == ')' && --depth == 0) return src.substring(open, i);
  }
  return src.substring(open);
}

List<String> _offenders() {
  final out = <String>[];
  for (final f in Directory('lib').listSync(recursive: true)) {
    if (f is! File || !f.path.endsWith('.dart')) continue;
    final src = f.readAsStringSync();
    for (final MapEntry(key: call, value: needs) in _calls.entries) {
      for (final m in call.allMatches(src)) {
        final args = _args(src, m.end - 1);
        if (!needs.any((n) => RegExp(n).hasMatch(args))) {
          final line = '\n'.allMatches(src.substring(0, m.start)).length + 1;
          out.add('${f.path}:$line ${m.group(0)}');
        }
      }
    }
  }
  return out;
}

void main() {
  test('every icon-only button has a tooltip; every image a label or is '
      'marked decorative', () {
    expect(
      _offenders(),
      isEmpty,
      reason: 'add tooltip:/semanticLabel: or excludeFromSemantics: true',
    );
  });

  test('the scanner catches what it is meant to', () {
    expect(_args('IconButton(icon: x, tooltip: "a")', 10), contains('tooltip'));
    expect(_args('f(g(1), h(2)) tail', 1), '(g(1), h(2)');
  });
}
