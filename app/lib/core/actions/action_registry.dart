import 'package:taskforge/core/actions/app_action.dart';
import 'package:taskforge/core/actions/chord.dart';

/// Every action of the app. Building one checks the rules a registry must
/// keep: ids are unique and well formed, every entry has an accessible label,
/// and no two defaults share a key.
class ActionRegistry {
  ActionRegistry(List<AppAction> actions)
    : actions = List.unmodifiable(actions) {
    final ids = <String>{};
    final keys = <String, String>{};
    for (final a in actions) {
      if (!_id.hasMatch(a.id)) {
        throw ArgumentError('Action id "${a.id}" is not well formed.');
      }
      if (!ids.add(a.id)) throw ArgumentError('Action id "${a.id}" is twice.');
      if (a.semanticLabel.trim().isEmpty) {
        throw ArgumentError('Action "${a.id}" has no accessible label.');
      }
      if (a.defaultKeys.isEmpty) continue;
      final chord = Chord.parse(a.defaultKeys);
      if (chord == null || chord.isBrowserReserved) {
        throw ArgumentError('Action "${a.id}" has a bad default key.');
      }
      final other = keys[chord.wire];
      if (other != null) {
        throw ArgumentError('"$other" and "${a.id}" both default to $chord.');
      }
      keys[chord.wire] = a.id;
    }
  }

  static final _id = RegExp(r'^[a-z][a-z0-9_.:-]{0,79}$');

  final List<AppAction> actions;

  AppAction? byId(String id) {
    for (final a in actions) {
      if (a.id == id) return a;
    }
    return null;
  }

  /// The actions that make sense where the person is now.
  List<AppAction> available(ActionContext context) => [
    for (final a in actions)
      if (a.isAvailable(context)) a,
  ];
}

/// The chord each action answers to now: its default unless the person
/// changed it; an unbound action maps to null.
class Bindings {
  const Bindings(this.registry, [this.overrides = const {}]);

  final ActionRegistry registry;

  /// Action id to wire chord ("" = unbound on purpose).
  final Map<String, String> overrides;

  Chord? chordOf(String actionId) {
    final override = overrides[actionId];
    if (override != null) return Chord.parse(override);
    final action = registry.byId(actionId);
    if (action == null || action.defaultKeys.isEmpty) return null;
    return Chord.parse(action.defaultKeys);
  }

  /// The action a key press runs, if any.
  AppAction? actionFor(Chord chord) {
    for (final a in registry.actions) {
      if (chordOf(a.id) == chord) return a;
    }
    return null;
  }

  /// The other action already on [chord], which makes binding it to
  /// [actionId] a clash; null when the key is free.
  AppAction? conflict(String actionId, Chord chord) {
    final other = actionFor(chord);
    return other != null && other.id != actionId ? other : null;
  }
}
