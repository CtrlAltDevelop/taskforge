/// Left-to-right isolate marks (Unicode bidi): LRI ... PDI.
final _lri = String.fromCharCode(0x2066);
final _pdi = String.fromCharCode(0x2069);

/// Wraps [text] so it keeps its own left-to-right order inside right-to-left text.
///
/// Without it a task id such as `WEB-12` in a Persian sentence can render as
/// `12-WEB` or lose its hyphen, because the neutral characters take the direction
/// of whatever is around them. Idempotent: wrapping twice does not nest.
String isolateLtr(String text) {
  if (text.isEmpty) return text;
  if (text.startsWith(_lri) && text.endsWith(_pdi)) return text;
  return '$_lri$text$_pdi';
}
