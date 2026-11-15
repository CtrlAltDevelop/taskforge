import 'package:material_ui/material_ui.dart';

import 'package:taskforge/core/i18n/l10n_context.dart';

/// Asks for one line of text; null when cancelled or left empty.
Future<String?> promptText(
  BuildContext context, {
  required String title,
  String? label,
  String initial = '',
}) async {
  final text = await showDialog<String>(
    context: context,
    builder: (_) => _PromptDialog(
      title: title,
      label: label ?? context.l10n.grpGName,
      initial: initial,
    ),
  );
  final trimmed = text?.trim() ?? '';
  return trimmed.isEmpty ? null : trimmed;
}

class _PromptDialog extends StatefulWidget {
  const _PromptDialog({
    required this.title,
    required this.label,
    required this.initial,
  });

  final String title;
  final String label;
  final String initial;

  @override
  State<_PromptDialog> createState() => _PromptDialogState();
}

class _PromptDialogState extends State<_PromptDialog> {
  late final _controller = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.title),
    content: TextField(
      key: const Key('prompt-field'),
      controller: _controller,
      autofocus: true,
      decoration: InputDecoration(labelText: widget.label),
      onSubmitted: (v) => Navigator.of(context).pop(v),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: Text(context.l10n.grpGCancel),
      ),
      FilledButton(
        key: const Key('prompt-ok'),
        onPressed: () => Navigator.of(context).pop(_controller.text),
        child: Text(context.l10n.grpGCreate),
      ),
    ],
  );
}
