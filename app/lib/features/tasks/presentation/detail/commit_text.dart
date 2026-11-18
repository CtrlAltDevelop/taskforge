import 'package:material_ui/material_ui.dart';

import 'package:taskforge/core/ui/theme_extension.dart';
import 'package:taskforge/core/ui/tokens/shape.dart';
import 'package:taskforge/core/ui/tokens/spacing.dart';

/// A text field that looks like plain text until pointed at, and saves when
/// it loses focus (or on Enter for one line). Someone else's value (or a
/// rollback) replaces ours unless we are typing.
class CommitTextField extends StatefulWidget {
  const CommitTextField({
    super.key,
    required this.fieldKey,
    required this.value,
    required this.enabled,
    required this.style,
    required this.onCommit,
    this.hint = '',
    this.initialText,
    this.maxLength,
    this.multiline = false,
    this.wrap = false,
    this.allowEmpty = true,
    this.onFocusChanged,
    this.onEdited,
    this.onLeftDirty,
    this.semanticLabel,
  });

  final Key fieldKey;
  final String value;
  final bool enabled;
  final TextStyle style;
  final String hint;

  /// What the box starts with when that is not [value] (a kept draft).
  final String? initialText;
  final int? maxLength;
  final bool multiline;

  /// One logical line that wraps over several (a long title); Enter saves.
  final bool wrap;

  /// False for a required field: blanking it puts the old value back.
  final bool allowEmpty;
  final String? semanticLabel;
  final void Function(String text) onCommit;
  final void Function(bool focused)? onFocusChanged;

  /// Every keystroke (a draft is kept from it).
  final void Function(String text)? onEdited;

  /// The field went away with text that was never committed.
  final void Function(String text)? onLeftDirty;

  @override
  State<CommitTextField> createState() => _CommitTextFieldState();
}

class _CommitTextFieldState extends State<CommitTextField> {
  late final _controller = TextEditingController(
    text: widget.initialText ?? widget.value,
  );
  final _focus = FocusNode();
  late var _saved = widget.value;

  bool get _dirty => _controller.text != _saved;

  /// Saves once per change: Enter and then losing focus must not send twice.
  void _commit(String text) {
    if (!widget.allowEmpty && text.trim().isEmpty) {
      _controller.text = widget.value;
      return;
    }
    if (text == _saved) return;
    _saved = text;
    widget.onCommit(text);
  }

  @override
  void initState() {
    super.initState();
    _focus.addListener(() {
      widget.onFocusChanged?.call(_focus.hasFocus);
      if (!_focus.hasFocus) _commit(_controller.text);
    });
  }

  @override
  void didUpdateWidget(CommitTextField old) {
    super.didUpdateWidget(old);
    if (widget.value != old.value) _saved = widget.value;
    if (!_focus.hasFocus && widget.value != _controller.text) {
      _controller.text = widget.value;
    }
  }

  @override
  void dispose() {
    if (_dirty && _controller.text.trim().isNotEmpty) {
      widget.onLeftDirty?.call(_controller.text);
    }
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.tf.colors;
    OutlineInputBorder edge(Color color) => OutlineInputBorder(
      borderRadius: TfRadius.control,
      borderSide: BorderSide(color: color, width: tfHairline),
    );
    return Semantics(
      label: widget.semanticLabel,
      textField: true,
      child: TextField(
        key: widget.fieldKey,
        controller: _controller,
        focusNode: _focus,
        enabled: widget.enabled,
        maxLength: widget.maxLength,
        maxLines: widget.multiline || widget.wrap ? null : 1,
        keyboardType: widget.multiline
            ? TextInputType.multiline
            : TextInputType.text,
        textInputAction: widget.multiline ? null : TextInputAction.done,
        minLines: widget.multiline ? 4 : 1,
        style: widget.style.copyWith(color: c.text),
        cursorColor: c.accent,
        onChanged: widget.onEdited,
        onSubmitted: widget.multiline ? null : _commit,
        decoration: InputDecoration(
          isDense: true,
          counterText: '',
          hintText: widget.hint,
          hintStyle: widget.style.copyWith(color: c.textSubtle),
          filled: true,
          fillColor: Colors.transparent,
          hoverColor: c.hover,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: TfSpace.sm,
            vertical: TfSpace.sm,
          ),
          border: edge(Colors.transparent),
          enabledBorder: edge(Colors.transparent),
          disabledBorder: edge(Colors.transparent),
          focusedBorder: edge(c.focus),
        ),
      ),
    );
  }
}
