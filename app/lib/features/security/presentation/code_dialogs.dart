import 'package:taskforge/core/ui/tokens/spacing.dart';
import 'package:taskforge/core/ui/page/tf_dialog_frame.dart';
import 'package:taskforge/core/ui/tf/tf_field.dart';
import 'package:taskforge/core/ui/tf/tf_button.dart';
import 'package:taskforge/core/ui/tf_icons.dart';

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
  Widget build(BuildContext context) => TfDialogFrame(
    title: widget.title,
    content: TfTextField(
      key: const Key('sec-code'),
      controller: _code,
      label: context.l10n.secCodeOrRecovery,
      onSubmitted: (v) => Navigator.pop(context, v.trim()),
      autofocus: true,
    ),
    actions: [
      TfButton(
        label: context.l10n.grpBCancel,
        variant: TfButtonVariant.ghost,
        onPressed: () => Navigator.pop(context),
      ),
      TfButton(
        key: const Key('sec-code-go'),
        label: widget.actionLabel,
        variant: TfButtonVariant.primary,
        onPressed: () => Navigator.pop(context, _code.text.trim()),
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
    return TfDialogFrame(
      title: t.secRecoveryTitle,
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(t.secRecoveryBody),
            const SizedBox(height: TfSpace.md),
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
        TfButton(
          key: const Key('sec-recovery-copy'),
          label: t.grpBCopy,
          variant: TfButtonVariant.ghost,
          onPressed: () async {
            final messenger = ScaffoldMessenger.of(context);
            final copied = t.secCodesCopied;
            await Clipboard.setData(ClipboardData(text: _text));
            messenger.showSnackBar(SnackBar(content: Text(copied)));
          },
        ),
        TfButton(
          key: const Key('sec-recovery-save'),
          label: t.grpBSaveAsFile,
          variant: TfButtonVariant.ghost,
          onPressed: () => FilePicker.saveFile(
            fileName: 'taskforge-recovery-codes.txt',
            bytes: Uint8List.fromList(utf8.encode('$_text\n')),
            mimeType: 'text/plain',
          ),
        ),
        TfButton(
          key: const Key('sec-recovery-done'),
          label: t.secSavedThem,
          variant: TfButtonVariant.primary,
          onPressed: () => Navigator.pop(context),
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
      TfIconButton(
        key: copyKey,
        icon: TfIcons.copy,
        tooltip: context.l10n.grpBCopy,
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
