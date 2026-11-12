import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart' show XFile;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'package:taskforge/features/attachments/domain/attachments.dart';

/// Files picked while offline, copied here until they can be uploaded (the
/// original may be moved or deleted meanwhile). Only used where the local
/// database is (not in the browser).
class OutboxFiles {
  OutboxFiles(this._folder);

  final Future<Directory> Function() _folder;

  /// Copies [source] to a file called [id]; returns its path.
  Future<String> keep(UploadSource source, String id) async {
    final dir = await _folder();
    await dir.create(recursive: true);
    final file = File(p.join(dir.path, id));
    final sink = file.openWrite();
    try {
      await sink.addStream(source.read(0, await source.length()));
    } finally {
      await sink.close();
    }
    return file.path;
  }

  /// The kept file at [path] as an upload called [name].
  UploadSource open(String path, String name) =>
      XFileSource(XFile(path), nameOverride: name);

  Future<void> remove(String path) async {
    final file = File(path);
    if (await file.exists()) await file.delete();
  }

  /// Deletes every kept file whose path is not in [wanted] (the entry that
  /// asked for it is gone). Files changed within [grace] are left: one may be
  /// on its way into the outbox.
  Future<void> sweep(
    Set<String> wanted, {
    Duration grace = Duration.zero,
  }) async {
    final cutoff = DateTime.now().subtract(grace);
    final dir = await _folder();
    if (!await dir.exists()) return;
    await for (final f in dir.list()) {
      if (f is! File || wanted.contains(f.path)) continue;
      if (grace > Duration.zero && (await f.lastModified()).isAfter(cutoff)) {
        continue;
      }
      await f.delete();
    }
  }
}

/// Tests give it a temporary folder.
final outboxFilesProvider = Provider<OutboxFiles>(
  (ref) => OutboxFiles(() async {
    final base = await getApplicationSupportDirectory();
    return Directory(p.join(base.path, 'outbox_files'));
  }),
);
