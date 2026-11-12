/// How well [query] matches [text], or null when it does not. Higher is
/// better: a prefix of the text or of a word beats letters picked from
/// anywhere in order ("tsk" finds "Create task"), and an early, tight match
/// beats a late, spread one. Case is ignored.
int? fuzzyScore(String query, String text) {
  final q = query.trim().toLowerCase();
  if (q.isEmpty) return 0;
  final t = text.toLowerCase();
  if (t.startsWith(q)) return 1000 - t.length;
  final word = t.indexOf(' $q');
  if (word >= 0) return 800 - word;
  final inside = t.indexOf(q);
  if (inside >= 0) return 600 - inside;
  // Letters in order, each as early as it can be; gaps cost points.
  var at = 0;
  var gaps = 0;
  var last = -1;
  for (var i = 0; i < q.length; i++) {
    final found = t.indexOf(q[i], at);
    if (found < 0) return null;
    if (last >= 0) gaps += found - last - 1;
    last = found;
    at = found + 1;
  }
  return 400 - gaps - last;
}
