// Generates lib/l10n/app_en_XA.arb, the pseudo-language, from app_en.arb.
//
//   dart run tool/pseudo_locale.dart
//
// Letters get accents, text is padded by about a third and wrapped in
// brackets. Placeholders and plural syntax are left alone, so the file is
// still a valid translation. Run the app with
// `--dart-define=PSEUDO_LOCALE=true` to see it.
import 'dart:convert';
import 'dart:io';

const _from = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
const _to = 'åƀçðéƒĝĥíĵķłɱñöþqŕšţûṽŵxýžÅßÇÐÉFĜĤÍĴĶŁMÑÖÞQŔŠŢÛṼŴXÝŽ';

String _accent(String text) {
  final out = StringBuffer();
  for (final rune in text.runes) {
    final ch = String.fromCharCode(rune);
    final at = _from.indexOf(ch);
    out.write(at < 0 ? ch : _to[at]);
  }
  return out.toString();
}

/// Index of the `}` that closes the `{` at [open].
int _close(String s, int open) {
  var depth = 0;
  for (var i = open; i < s.length; i++) {
    if (s[i] == '{') depth++;
    if (s[i] == '}' && --depth == 0) return i;
  }
  return s.length - 1;
}

/// Accents the words of an ICU message, keeping placeholders and syntax.
String _transform(String s) {
  final out = StringBuffer();
  var i = 0;
  while (i < s.length) {
    if (s[i] != '{') {
      final next = s.indexOf('{', i);
      final end = next < 0 ? s.length : next;
      out.write(_accent(s.substring(i, end)));
      i = end;
      continue;
    }
    final end = _close(s, i);
    final inner = s.substring(i + 1, end);
    final header = RegExp(r'^(\w+),\s*(plural|select)\s*,').firstMatch(inner);
    if (header == null) {
      out.write('{$inner}'); // a placeholder
    } else {
      out.write('{${header.group(0)}');
      var j = header.end;
      while (j < inner.length) {
        final open = inner.indexOf('{', j);
        if (open < 0) {
          out.write(inner.substring(j));
          break;
        }
        out.write(inner.substring(j, open + 1));
        final close = _close(inner, open);
        out.write(_transform(inner.substring(open + 1, close)));
        out.write('}');
        j = close + 1;
      }
      out.write('}');
    }
    i = end + 1;
  }
  return out.toString();
}

String _pseudo(String message) {
  final padding = '~' * (message.length ~/ 3);
  return '[${_transform(message)} $padding]';
}

void main() {
  final template = jsonDecode(
    File('lib/l10n/app_en.arb').readAsStringSync(),
  ) as Map<String, dynamic>;
  final out = <String, dynamic>{'@@locale': 'en_XA'};
  for (final entry in template.entries) {
    if (entry.key.startsWith('@')) continue;
    out[entry.key] = _pseudo(entry.value as String);
  }
  File(
    'lib/l10n/app_en_XA.arb',
  ).writeAsStringSync('${const JsonEncoder.withIndent('  ').convert(out)}\n');
  stdout.writeln('Wrote ${out.length - 1} messages to lib/l10n/app_en_XA.arb');
}
