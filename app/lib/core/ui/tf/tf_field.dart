import 'package:material_ui/material_ui.dart';

import 'package:taskforge/core/ui/theme_extension.dart';
import 'package:taskforge/core/ui/tf_icons.dart';
import 'package:taskforge/core/ui/tokens/spacing.dart';

/// A text input with the design-system border, focus ring and error text.
class TfTextField extends StatelessWidget {
  const TfTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.errorText,
    this.onChanged,
    this.onSubmitted,
    this.obscure = false,
    this.maxLines = 1,
    this.enabled = true,
    this.autofocus = false,
    this.focusNode,
    this.prefix,
  });

  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool obscure;
  final int maxLines;
  final bool enabled;
  final bool autofocus;
  final FocusNode? focusNode;
  final TfIconData? prefix;

  @override
  Widget build(BuildContext context) {
    final tf = context.tf;
    final c = tf.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(label!, style: tf.typography.label.copyWith(color: c.textMuted)),
          const SizedBox(height: TfSpace.xs),
        ],
        TextField(
          controller: controller,
          focusNode: focusNode,
          autofocus: autofocus,
          enabled: enabled,
          obscureText: obscure,
          maxLines: obscure ? 1 : maxLines,
          onChanged: onChanged,
          onSubmitted: onSubmitted,
          style: tf.typography.body.copyWith(color: c.text),
          cursorColor: c.accent,
          decoration: InputDecoration(
            hintText: hint,
            errorText: errorText,
            errorStyle: tf.typography.small.copyWith(color: c.danger.fg),
            prefixIcon: prefix == null
                ? null
                : Padding(
                    padding: const EdgeInsets.all(TfSpace.sm + 2),
                    child: TfIcon(prefix!, color: c.textSubtle),
                  ),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 32,
              minHeight: 32,
            ),
          ),
        ),
      ],
    );
  }
}

/// A search box: magnifier, clear button when there is text.
class TfSearchField extends StatefulWidget {
  const TfSearchField({
    super.key,
    required this.onChanged,
    required this.hint,
    required this.clearTooltip,
    this.controller,
    this.autofocus = false,
  });

  final ValueChanged<String> onChanged;
  final String hint;
  final String clearTooltip;
  final TextEditingController? controller;
  final bool autofocus;

  @override
  State<TfSearchField> createState() => _TfSearchFieldState();
}

class _TfSearchFieldState extends State<TfSearchField> {
  late final TextEditingController _controller =
      widget.controller ?? TextEditingController();

  @override
  void dispose() {
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.tf.colors;
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: _controller,
      builder: (context, value, _) => TextField(
        controller: _controller,
        autofocus: widget.autofocus,
        onChanged: widget.onChanged,
        style: context.tf.typography.body.copyWith(color: c.text),
        cursorColor: c.accent,
        decoration: InputDecoration(
          hintText: widget.hint,
          prefixIcon: Padding(
            padding: const EdgeInsets.all(TfSpace.sm + 2),
            child: TfIcon(TfIcons.search, color: c.textSubtle),
          ),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 32,
            minHeight: 32,
          ),
          suffixIcon: value.text.isEmpty
              ? null
              : IconButton(
                  tooltip: widget.clearTooltip,
                  icon: TfIcon(TfIcons.close, color: c.textMuted),
                  onPressed: () {
                    _controller.clear();
                    widget.onChanged('');
                  },
                ),
        ),
      ),
    );
  }
}
