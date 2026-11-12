import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart' show XFile;

/// A file the person chose, read as a stream (never whole).
class PickedImport {
  const PickedImport({
    required this.name,
    required this.size,
    required this.open,
  });

  final String name;
  final int size;
  final Stream<List<int>> Function() open;

  factory PickedImport.ofFile(XFile file, String name, int size) =>
      PickedImport(name: name, size: size, open: file.openRead);
}

/// Opens the system file chooser; null when the person cancels. Replaced in
/// tests.
final importPickerProvider = Provider<Future<PickedImport?> Function()>(
  (ref) => () async {
    final files = await FilePicker.pickFiles(
      allowedExtensions: const ['csv', 'json', 'zip'],
      type: FileType.custom,
    );
    if (files.isEmpty) return null;
    final f = files.first;
    return PickedImport.ofFile(f.xFile, f.name, await f.xFile.length());
  },
);

/// Saves an export zip; replaced in tests.
final exportSaverProvider =
    Provider<Future<void> Function(String name, Uint8List bytes)>(
      (ref) => (name, bytes) async {
        await FilePicker.saveFile(
          fileName: name,
          bytes: bytes,
          mimeType: 'application/zip',
        );
      },
    );
