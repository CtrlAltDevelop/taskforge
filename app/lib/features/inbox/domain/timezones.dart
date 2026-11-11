/// Time zones the settings offer (IANA names) and the offsets, in minutes from
/// UTC, each has over the year (standard time, then daylight saving).
// ponytail: a short table, not the whole tz database; the field still takes
// any IANA-looking name the server accepts. Add zones as people ask.
const Map<String, List<int>> commonTimezones = {
  'UTC': [0],
  'Europe/London': [0, 60],
  'Europe/Paris': [60, 120],
  'Europe/Berlin': [60, 120],
  'Europe/Athens': [120, 180],
  'Europe/Istanbul': [180],
  'Europe/Moscow': [180],
  'Asia/Tehran': [210],
  'Asia/Dubai': [240],
  'Asia/Karachi': [300],
  'Asia/Kolkata': [330],
  'Asia/Dhaka': [360],
  'Asia/Bangkok': [420],
  'Asia/Shanghai': [480],
  'Asia/Tokyo': [540],
  'Australia/Sydney': [600, 660],
  'Pacific/Auckland': [720, 780],
  'America/Sao_Paulo': [-180],
  'America/New_York': [-300, -240],
  'America/Chicago': [-360, -300],
  'America/Denver': [-420, -360],
  'America/Los_Angeles': [-480, -420],
  'America/Anchorage': [-540, -480],
  'Pacific/Honolulu': [-600],
};

final _iana = RegExp(r'^[A-Za-z]+(?:/[A-Za-z0-9_+\-]+)+$');

/// Whether [name] looks like a time zone the server may know.
bool isValidTimezone(String name) =>
    name == 'UTC' || commonTimezones.containsKey(name) || _iana.hasMatch(name);

/// A zone from the table whose offset matches [offset] now, if any.
String? timezoneForOffset(Duration offset) {
  for (final e in commonTimezones.entries) {
    if (e.value.contains(offset.inMinutes)) return e.key;
  }
  return null;
}

/// `HH:MM` for [hour] and [minute].
String hhmm(int hour, int minute) =>
    '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

/// The (hour, minute) of an `HH:MM` text, or null.
({int hour, int minute})? parseHhmm(String text) {
  final m = RegExp(r'^(\d{1,2}):(\d{2})$').firstMatch(text);
  if (m == null) return null;
  final hour = int.parse(m.group(1)!);
  final minute = int.parse(m.group(2)!);
  return hour < 24 && minute < 60 ? (hour: hour, minute: minute) : null;
}
