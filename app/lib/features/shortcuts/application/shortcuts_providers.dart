import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/core/actions/action_registry.dart';
import 'package:taskforge/core/actions/chord.dart';
import 'package:taskforge/core/auth/auth_providers.dart';
import 'package:taskforge/core/grpc/grpc_providers.dart';
import 'package:taskforge/features/shortcuts/application/builtin_actions.dart';
import 'package:taskforge/features/shortcuts/data/shortcuts_client.dart';

final shortcutsClientProvider = Provider<ShortcutsClient>(
  (ref) => GrpcShortcutsClient(
    ref.watch(grpcChannelProvider),
    ref.watch(authSessionProvider),
  ),
);

/// The one registry of the app (see [builtInActions]).
final actionRegistryProvider = Provider<ActionRegistry>(
  (ref) => ActionRegistry(builtInActions),
);

/// The person's own bindings from the server. A failed read (offline, signed
/// out) leaves the defaults in force instead of breaking the keyboard.
class ShortcutOverrides extends AsyncNotifier<Map<String, String>> {
  @override
  Future<Map<String, String>> build() async {
    try {
      return await ref.read(shortcutsClientProvider).get();
    } on Object catch (e) {
      debugPrint('shortcuts: using defaults ($e)');
      return const {};
    }
  }

  Map<String, String> get _now => state.value ?? const {};

  /// Binds [actionId] to [chord] (null: unbound on purpose). Throws a
  /// [ShortcutException] the dialog shows; the bindings stay as they were.
  Future<void> bind(String actionId, Chord? chord) async {
    state = AsyncData(
      await ref.read(shortcutsClientProvider).set(actionId, chord?.wire ?? ''),
    );
  }

  /// Drops the override: the action answers to its default again.
  Future<void> reset(String actionId) async {
    state = AsyncData(await ref.read(shortcutsClientProvider).reset(actionId));
  }

  bool get hasOverrides => _now.isNotEmpty;
}

final shortcutOverridesProvider =
    AsyncNotifierProvider<ShortcutOverrides, Map<String, String>>(
      ShortcutOverrides.new,
    );

/// What each action answers to right now.
final bindingsProvider = Provider<Bindings>(
  (ref) => Bindings(
    ref.watch(actionRegistryProvider),
    ref.watch(shortcutOverridesProvider).value ?? const {},
  ),
);
