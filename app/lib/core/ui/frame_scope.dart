import 'package:flutter/widgets.dart';

/// What the app frame around a page offers it: the sidebar toggle (null
/// where there is no sidebar) and whether the frame already shows the
/// account menu (then the page's app bar leaves its own out).
class AppFrameScope extends InheritedWidget {
  const AppFrameScope({
    super.key,
    required this.hasAccountMenu,
    required this.toggleSidebar,
    required super.child,
  });

  final bool hasAccountMenu;
  final VoidCallback? toggleSidebar;

  static AppFrameScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppFrameScope>();

  @override
  bool updateShouldNotify(AppFrameScope old) =>
      old.hasAccountMenu != hasAccountMenu ||
      (old.toggleSidebar == null) != (toggleSidebar == null);
}

/// Marks a part of the page whose focused widgets handle some chords
/// themselves (F2 on a sidebar project renames it): the global shortcut
/// host leaves those chords to it while focus is inside.
class KeyClaim extends InheritedWidget {
  const KeyClaim({super.key, required this.chords, required super.child});

  /// Wire forms (`f2`, `mod+k`).
  final Set<String> chords;

  /// Whether the focused widget sits under a claim on [wire].
  static bool holds(BuildContext? focused, String wire) =>
      focused?.getInheritedWidgetOfExactType<KeyClaim>()?.chords.contains(
        wire,
      ) ??
      false;

  @override
  bool updateShouldNotify(KeyClaim old) => old.chords != chords;
}
