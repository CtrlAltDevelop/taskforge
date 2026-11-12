import 'package:flutter/material.dart';

/// Asks for one line of text; null when cancelled or left empty.
Future<String?> promptText(
  BuildContext context, {
  required String title,
  String label = 'Name',
  String initial = '',
}) async {
  final text = await showDialog<String>(
    context: context,
    builder: (_) => _PromptDialog(title: title, label: label, initial: initial),
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
        child: const Text('Cancel'),
      ),
      FilledButton(
        key: const Key('prompt-ok'),
        onPressed: () => Navigator.of(context).pop(_controller.text),
        child: const Text('Create'),
      ),
    ],
  );
}
