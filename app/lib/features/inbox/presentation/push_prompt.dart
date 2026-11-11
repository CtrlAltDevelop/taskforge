import 'package:flutter/material.dart';

/// Says why before the system asks: nobody should meet a permission box
/// without knowing what it is for. True when the person wants to go on.
Future<bool> explainPush(BuildContext context) async {
  final go = await showDialog<bool>(
    context: context,
    builder: (dialog) => AlertDialog(
      key: const Key('push-explainer'),
      title: const Text('Get a ping when it matters'),
      content: const Text(
        'TaskForge can show a notification when you are assigned a task, '
        'mentioned, or a task is due soon, even when the app is in the '
        'background. Next your device will ask for permission. You choose '
        'which kinds ping you, and quiet hours keep them from waking you.',
      ),
      actions: [
        TextButton(
          key: const Key('push-explainer-cancel'),
          onPressed: () => Navigator.of(dialog).pop(false),
          child: const Text('Not now'),
        ),
        FilledButton(
          key: const Key('push-explainer-continue'),
          onPressed: () => Navigator.of(dialog).pop(true),
          child: const Text('Continue'),
        ),
      ],
    ),
  );
  return go ?? false;
}
