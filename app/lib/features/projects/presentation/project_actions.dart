import 'package:flutter/material.dart';

import 'package:taskforge/features/projects/domain/projects.dart';

/// Runs [action]; a [ProjectException] becomes a snackbar and `false`.
Future<bool> runProjectAction(
  BuildContext context,
  Future<void> Function() action,
) async {
  // Captured before the await: the page may be rebuilt by the refresh.
  final messenger = ScaffoldMessenger.of(context);
  try {
    await action();
    return true;
  } on ProjectException catch (e) {
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(projectErrorMessage(e))));
    return false;
  }
}
