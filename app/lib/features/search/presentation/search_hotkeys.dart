import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:taskforge/features/search/presentation/search_overlay.dart';

/// Opens the search with `/` (when not typing in a field) or Ctrl/Cmd+K, from
/// anywhere on the page: it listens to the keyboard itself, so it works even
/// after a tap has taken focus away from everything.
class SearchHotkeys extends StatefulWidget {
  const SearchHotkeys({super.key, required this.child});

  final Widget child;

  @override
  State<SearchHotkeys> createState() => _SearchHotkeysState();
}

class _SearchHotkeysState extends State<SearchHotkeys> {
  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_onKey);
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_onKey);
    super.dispose();
  }

  static bool _typing() {
    final focused = FocusManager.instance.primaryFocus?.context;
    if (focused == null) return false;
    return focused.widget is EditableText ||
        focused.findAncestorWidgetOfExactType<EditableText>() != null;
  }

  bool _onKey(KeyEvent event) {
    if (event is! KeyDownEvent || !mounted) return false;
    // Only the page that is showing, never one under the search box or a dialog.
    if (ModalRoute.of(context)?.isCurrent == false) return false;
    final keys = HardwareKeyboard.instance;
    final command = keys.isControlPressed || keys.isMetaPressed;
    final isK = event.logicalKey == LogicalKeyboardKey.keyK;
    final isSlash = event.logicalKey == LogicalKeyboardKey.slash;
    if ((command && isK) || (isSlash && !command && !_typing())) {
      openSearch(context);
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
