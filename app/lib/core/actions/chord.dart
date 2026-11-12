import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// The chords the browser keeps for itself. The server holds the same list
/// (`backend/.../shortcuts/reserved_chords.json`); a test on each side reads
/// that file, so the two cannot drift.
const browserReserved = {
  'mod+t',
  'mod+w',
  'mod+n',
  'mod+shift+t',
  'mod+shift+n',
  'mod+q',
  'mod+l',
  'mod+r',
  'mod+shift+r',
  'mod+p',
  'mod+s',
  'mod+d',
  'alt+left',
  'alt+right',
};

/// One key combination, in the same words the server stores: modifiers in the
/// order `mod`, `ctrl`, `alt`, `shift`, then one key, joined by `+`
/// (`mod+shift+k`). `mod` is Cmd on macOS and Ctrl elsewhere, so a chord
/// means the same thing on every device.
@immutable
class Chord {
  const Chord({
    required this.key,
    this.mod = false,
    this.ctrl = false,
    this.alt = false,
    this.shift = false,
  });

  /// Reads the wire form; null for empty or anything that is not a chord.
  static Chord? parse(String wire) {
    final parts = wire.trim().toLowerCase().split('+');
    if (parts.isEmpty || parts.last.isEmpty) return null;
    final mods = parts.sublist(0, parts.length - 1);
    if (mods.any((m) => !_modifiers.contains(m))) return null;
    return Chord(
      key: parts.last,
      mod: mods.contains('mod'),
      ctrl: mods.contains('ctrl'),
      alt: mods.contains('alt'),
      shift: mods.contains('shift'),
    );
  }

  /// The chord a key press makes, or null for a lone modifier or a key we do
  /// not name. [isMac] decides whether Cmd or Ctrl is `mod`.
  static Chord? fromEvent(
    KeyEvent event,
    HardwareKeyboard keyboard, {
    required bool isMac,
  }) {
    var key = keyToken(event);
    if (key == null) return null;
    // "?" is Shift+/ on most keyboards; the person pressed one key.
    if (key == 'slash' && keyboard.isShiftPressed) key = 'question';
    final command = isMac ? keyboard.isMetaPressed : keyboard.isControlPressed;
    final other = isMac ? keyboard.isControlPressed : keyboard.isMetaPressed;
    final shift = key == 'question' ? false : keyboard.isShiftPressed;
    return Chord(
      key: key,
      mod: command,
      ctrl: other && isMac,
      alt: keyboard.isAltPressed,
      shift: shift,
    );
  }

  final String key;
  final bool mod;
  final bool ctrl;
  final bool alt;
  final bool shift;

  bool get hasModifier => mod || ctrl || alt;

  String get wire => [
    if (mod) 'mod',
    if (ctrl) 'ctrl',
    if (alt) 'alt',
    if (shift) 'shift',
    key,
  ].join('+');

  /// What to show a person: `Ctrl+Shift+K`, or `⌘⇧K` on macOS.
  String label({required bool isMac}) {
    final k = _keyLabels[key] ?? key.toUpperCase();
    if (isMac) {
      return '${ctrl ? '⌃' : ''}${alt ? '⌥' : ''}${shift ? '⇧' : ''}${mod ? '⌘' : ''}$k';
    }
    return [
      if (mod || ctrl) 'Ctrl',
      if (alt) 'Alt',
      if (shift) 'Shift',
      k,
    ].join('+');
  }

  /// Keys the browser keeps for itself: a binding on one could never fire.
  bool get isBrowserReserved => browserReserved.contains(wire);

  @override
  bool operator ==(Object other) => other is Chord && other.wire == wire;

  @override
  int get hashCode => wire.hashCode;

  @override
  String toString() => wire;

  static const _modifiers = {'mod', 'ctrl', 'alt', 'shift'};

  static const _keyLabels = {
    'slash': '/',
    'question': '?',
    'comma': ',',
    'period': '.',
    'enter': 'Enter',
    'escape': 'Esc',
    'space': 'Space',
    'tab': 'Tab',
    'backspace': 'Backspace',
    'delete': 'Delete',
    'up': '↑',
    'down': '↓',
    'left': '←',
    'right': '→',
    'home': 'Home',
    'end': 'End',
    'pageup': 'PgUp',
    'pagedown': 'PgDn',
  };
}

/// The wire word for the key of [event], or null when it is a modifier or
/// something the server does not accept.
String? keyToken(KeyEvent event) {
  if (event.character == '?') return 'question';
  final key = event.logicalKey;
  final named = _named[key];
  if (named != null) return named;
  final label = key.keyLabel.toLowerCase();
  if (label.length == 1 && RegExp(r'^[a-z0-9]$').hasMatch(label)) return label;
  return null;
}

final _named = <LogicalKeyboardKey, String>{
  LogicalKeyboardKey.enter: 'enter',
  LogicalKeyboardKey.numpadEnter: 'enter',
  LogicalKeyboardKey.escape: 'escape',
  LogicalKeyboardKey.space: 'space',
  LogicalKeyboardKey.tab: 'tab',
  LogicalKeyboardKey.backspace: 'backspace',
  LogicalKeyboardKey.delete: 'delete',
  LogicalKeyboardKey.arrowUp: 'up',
  LogicalKeyboardKey.arrowDown: 'down',
  LogicalKeyboardKey.arrowLeft: 'left',
  LogicalKeyboardKey.arrowRight: 'right',
  LogicalKeyboardKey.home: 'home',
  LogicalKeyboardKey.end: 'end',
  LogicalKeyboardKey.pageUp: 'pageup',
  LogicalKeyboardKey.pageDown: 'pagedown',
  LogicalKeyboardKey.slash: 'slash',
  LogicalKeyboardKey.comma: 'comma',
  LogicalKeyboardKey.period: 'period',
  LogicalKeyboardKey.f1: 'f1',
  LogicalKeyboardKey.f2: 'f2',
  LogicalKeyboardKey.f3: 'f3',
  LogicalKeyboardKey.f4: 'f4',
  LogicalKeyboardKey.f5: 'f5',
  LogicalKeyboardKey.f6: 'f6',
  LogicalKeyboardKey.f7: 'f7',
  LogicalKeyboardKey.f8: 'f8',
  LogicalKeyboardKey.f9: 'f9',
  LogicalKeyboardKey.f10: 'f10',
  LogicalKeyboardKey.f11: 'f11',
  LogicalKeyboardKey.f12: 'f12',
};
