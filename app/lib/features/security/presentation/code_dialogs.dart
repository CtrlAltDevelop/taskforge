import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';

import 'package:taskforge/core/i18n/l10n_context.dart';

/// Asks for a current authenticator code (or a recovery code) before a change
/// that weakens or replaces it. Returns the code, or null when cancelled.
Future<String?> askForCode(
  BuildContext context, {
  required String title,
  required String actionLabel,
}) => showDialog<String>(
  context: context,
  builder: (_) => _CodeDialog(title: title, actionLabel: actionLabel),
);

class _CodeDialog extends StatefulWidget {
  const _CodeDialog({required this.title, required this.actionLabel});

  final String title;
  final String actionLabel;

  @override
  State<_CodeDialog> createState() => _CodeDialogState();
}

class _CodeDialogState extends State<_CodeDialog> {
  final _code = TextEditingController();

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.title),
    content: TextField(
      key: const Key('sec-code'),
      controller: _code,
      autofocus: true,
      decoration: InputDecoration(labelText: context.l10n.secCodeOrRecovery),
      onSubmitted: (v) => Navigator.pop(context, v.trim()),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: Text(context.l10n.grpBCancel),
      ),
      FilledButton(
        key: const Key('sec-code-go'),
        onPressed: () => Navigator.pop(context, _code.text.trim()),
        child: Text(widget.actionLabel),
      ),
    ],
  );
}

/// Shows the recovery codes once, with copy and download. They cannot be shown
/// again: the server keeps only digests.
Future<void> showRecoveryCodes(BuildContext context, List<String> codes) =>
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _RecoveryCodesDialog(codes: codes),
    );

class _RecoveryCodesDialog extends StatelessWidget {
  const _RecoveryCodesDialog({required this.codes});

  final List<String> codes;

  String get _text => codes.join('\n');

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    return AlertDialog(
      title: Text(t.secRecoveryTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(t.secRecoveryBody),
            const SizedBox(height: 12),
            for (final code in codes)
              SelectableText(
                code,
                key: Key('sec-recovery-$code'),
                textDirection: TextDirection.ltr,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 16),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          key: const Key('sec-recovery-copy'),
          onPressed: () async {
            final messenger = ScaffoldMessenger.of(context);
            final copied = t.secCodesCopied;
            await Clipboard.setData(ClipboardData(text: _text));
            messenger.showSnackBar(SnackBar(content: Text(copied)));
          },
          child: Text(t.grpBCopy),
        ),
        TextButton(
          key: const Key('sec-recovery-save'),
          onPressed: () => FilePicker.saveFile(
            fileName: 'taskforge-recovery-codes.txt',
            bytes: Uint8List.fromList(utf8.encode('$_text\n')),
            mimeType: 'text/plain',
          ),
          child: Text(t.grpBSaveAsFile),
        ),
        FilledButton(
          key: const Key('sec-recovery-done'),
          onPressed: () => Navigator.pop(context),
          child: Text(t.secSavedThem),
        ),
      ],
    );
  }
}

/// A secret or URI shown in a left-to-right, selectable box with a copy button.
class CopyableValue extends StatelessWidget {
  const CopyableValue({super.key, required this.value, this.copyKey});

  final String value;
  final Key? copyKey;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: SelectableText(
          value,
          textDirection: TextDirection.ltr,
          style: const TextStyle(fontFamily: 'monospace'),
        ),
      ),
      IconButton(
        key: copyKey,
        tooltip: context.l10n.grpBCopy,
        icon: const Icon(Icons.copy),
        onPressed: () async {
          final messenger = ScaffoldMessenger.of(context);
          final copied = context.l10n.secCopied;
          await Clipboard.setData(ClipboardData(text: value));
          messenger.showSnackBar(SnackBar(content: Text(copied)));
        },
      ),
    ],
  );
}
