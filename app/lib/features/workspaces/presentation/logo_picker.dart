import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PickedLogo {
  const PickedLogo(this.bytes, this.filename);

  final List<int> bytes;
  final String filename;
}

typedef LogoPicker = Future<PickedLogo?> Function();

Future<PickedLogo?> _pickImage() async {
  final file = await FilePicker.pickFile(type: FileType.image);
  if (file == null) return null;
  return PickedLogo(await file.readAsBytes(), file.name);
}

/// Overridable in tests; the real one opens the platform's file dialog.
final logoPickerProvider = Provider<LogoPicker>((ref) => _pickImage);
