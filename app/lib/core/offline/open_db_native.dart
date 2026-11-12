import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'package:taskforge/core/offline/local_db.dart';

/// Mobile and desktop: one SQLite file in the app's support folder, opened
/// on first use and in a background isolate.
LocalDb? openLocalDb() => LocalDb(
  LazyDatabase(() async {
    final dir = await getApplicationSupportDirectory();
    return NativeDatabase.createInBackground(
      File(p.join(dir.path, 'taskforge_offline.sqlite')),
    );
  }),
);
