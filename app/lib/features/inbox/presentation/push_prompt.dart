import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:flutter/material.dart';

/// Says why before the system asks: nobody should meet a permission box
/// without knowing what it is for. True when the person wants to go on.
Future<bool> explainPush(BuildContext context) async {
  final go = await showDialog<bool>(
    context: context,
    builder: (dialog) => AlertDialog(
      key: const Key('push-explainer'),
      title: Text(dialog.l10n.grpHPushTitle),
      content: Text(dialog.l10n.grpHPushBody),
      actions: [
        TextButton(
          key: const Key('push-explainer-cancel'),
          onPressed: () => Navigator.of(dialog).pop(false),
          child: Text(dialog.l10n.grpHNotNow),
        ),
        FilledButton(
          key: const Key('push-explainer-continue'),
          onPressed: () => Navigator.of(dialog).pop(true),
          child: Text(dialog.l10n.grpHContinue),
        ),
      ],
    ),
  );
  return go ?? false;
}
