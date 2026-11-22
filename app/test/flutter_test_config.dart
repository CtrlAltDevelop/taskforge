import 'dart:async';

import 'package:drift/drift.dart';

import 'support/load_fonts.dart';

/// Tests open many in-memory databases, one per test: that is on purpose.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  await loadAppFonts();
  await testMain();
}
