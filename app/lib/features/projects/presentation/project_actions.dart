import 'package:flutter/material.dart';

import 'package:taskforge/features/projects/domain/projects.dart';
import 'package:taskforge/core/i18n/l10n_context.dart';

/// Runs [action]; a [ProjectException] becomes a snackbar and `false`.
Future<bool> runProjectAction(
  BuildContext context,
  Future<void> Function() action,
) async {
  // Captured before the await: the page may be rebuilt by the refresh.
  final messenger = ScaffoldMessenger.of(context);
  final l10n = context.l10n;
  try {
    await action();
    return true;
  } on ProjectException catch (e) {
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(projectErrorMessage(e, l10n))));
    return false;
  }
}
