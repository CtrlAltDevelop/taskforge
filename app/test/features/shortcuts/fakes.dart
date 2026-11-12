import 'package:taskforge/features/shortcuts/data/shortcuts_client.dart';

/// An in-memory set of bindings with the server's rules: a chord may belong
/// to one action only (the other is named), and it notes what was set.
class FakeShortcutsClient implements ShortcutsClient {
  FakeShortcutsClient([Map<String, String> initial = const {}])
    : stored = {...initial};

  final Map<String, String> stored;
  final List<String> calls = [];

  /// Set to make every call fail, e.g. offline.
  ShortcutException? failWith;

  @override
  Future<Map<String, String>> get() async {
    if (failWith != null) throw failWith!;
    return {...stored};
  }

  @override
  Future<Map<String, String>> set(String actionId, String keys) async {
    calls.add('set $actionId $keys');
    if (failWith != null) throw failWith!;
    if (keys.isNotEmpty) {
      for (final e in stored.entries) {
        if (e.value == keys && e.key != actionId) {
          throw ShortcutException(
            ShortcutFailure.conflict,
            detail: '$keys is already used by ${e.key}.',
            other: e.key,
          );
        }
      }
    }
    stored[actionId] = keys;
    return {...stored};
  }

  @override
  Future<Map<String, String>> reset(
    String actionId, {
    String defaultKeys = '',
  }) async {
    calls.add('reset $actionId');
    if (failWith != null) throw failWith!;
    if (defaultKeys.isNotEmpty) {
      for (final e in stored.entries) {
        if (e.value == defaultKeys && e.key != actionId) {
          throw ShortcutException(
            ShortcutFailure.conflict,
            detail: '$defaultKeys is already used by ${e.key}.',
            other: e.key,
          );
        }
      }
    }
    stored.remove(actionId);
    return {...stored};
  }
}
