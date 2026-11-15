import 'package:material_ui/material_ui.dart';

import 'package:taskforge/features/docs/domain/doc_blocks.dart';

/// A text field controller that knows how each character looks (bold, link,
/// page mention ...) and paints it so. [rich] follows the text: whatever
/// changed it, the new characters take the look of their neighbours.
class MarkedTextController extends TextEditingController {
  MarkedTextController(Rich rich) : _rich = rich, super(text: rich.text);

  Rich _rich;

  /// The text with its looks, current with [text].
  Rich get rich {
    if (_rich.text != text) _rich = _rich.withText(text);
    return _rich;
  }

  /// Replaces text and looks (not for typing: the selection is kept in range).
  set rich(Rich value) {
    _rich = value;
    final sel = selection;
    this.value = TextEditingValue(
      text: value.text,
      selection: sel.isValid
          ? TextSelection(
              baseOffset: sel.baseOffset.clamp(0, value.length),
              extentOffset: sel.extentOffset.clamp(0, value.length),
            )
          : const TextSelection.collapsed(offset: 0),
    );
  }

  /// Sets the looks of the current text (a toggle) without moving the cursor.
  void restyle(Rich value) {
    _rich = value;
    notifyListeners();
  }

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final current = rich;
    if (current.isEmpty || value.composing.isValid && withComposing) {
      return super.buildTextSpan(
        context: context,
        style: style,
        withComposing: withComposing,
      );
    }
    final scheme = Theme.of(context).colorScheme;
    final spans = <InlineSpan>[];
    var i = 0;
    while (i < current.length) {
      final attr = current.attrs[i];
      var j = i + 1;
      while (j < current.length && current.attrs[j] == attr) {
        j++;
      }
      spans.add(
        TextSpan(
          text: current.text.substring(i, j),
          style: _styleOf(attr, scheme),
        ),
      );
      i = j;
    }
    return TextSpan(style: style, children: spans);
  }

  TextStyle? _styleOf(Attr attr, ColorScheme scheme) {
    final atom = attr.atom;
    if (atom != null) {
      if (atom.isBreak) return null;
      return TextStyle(
        color: atom.isMention ? scheme.primary : scheme.outline,
        backgroundColor: scheme.primaryContainer.withValues(alpha: 0.5),
        fontWeight: FontWeight.w500,
      );
    }
    if (attr.marks.isEmpty) return null;
    final link = attr.link;
    return TextStyle(
      fontWeight: attr.bold ? FontWeight.bold : null,
      fontStyle: attr.italic ? FontStyle.italic : null,
      fontFamily: attr.code ? 'monospace' : null,
      backgroundColor: attr.code ? scheme.surfaceContainerHighest : null,
      color: link != null ? scheme.primary : null,
      decoration: TextDecoration.combine([
        if (attr.strike) TextDecoration.lineThrough,
        if (link != null) TextDecoration.underline,
      ]),
    );
  }
}
