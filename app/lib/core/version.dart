/// This build's version. The release build passes `--dart-define=APP_VERSION=<VERSION>`; the
/// fallback is kept in step with the repository's VERSION file by `deploy/scripts/set-version.sh`.
const clientVersion = String.fromEnvironment(
  'APP_VERSION',
  defaultValue: '1.0.0',
); // VERSION

/// `major.minor.patch[-pre]` parsed for comparison; null when [text] is not SemVer.
({int major, int minor, int patch, bool pre})? parseSemVer(String text) {
  final m = RegExp(
    r'^v?(\d+)\.(\d+)\.(\d+)(-[0-9A-Za-z.-]+)?(\+[0-9A-Za-z.-]+)?$',
  ).firstMatch(text.trim());
  if (m == null) return null;
  return (
    major: int.parse(m.group(1)!),
    minor: int.parse(m.group(2)!),
    patch: int.parse(m.group(3)!),
    pre: m.group(4) != null,
  );
}

/// Negative when [a] is older than [b], zero when equal, positive when newer; null if either is
/// not SemVer. A pre-release sorts before its release.
int? compareSemVer(String a, String b) {
  final x = parseSemVer(a);
  final y = parseSemVer(b);
  if (x == null || y == null) return null;
  final parts = [x.major - y.major, x.minor - y.minor, x.patch - y.patch];
  for (final d in parts) {
    if (d != 0) return d;
  }
  return x.pre == y.pre ? 0 : (x.pre ? -1 : 1);
}
