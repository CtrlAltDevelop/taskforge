import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/features/attachments/domain/attachments.dart';
import 'package:taskforge/features/attachments/presentation/attachments_io.dart';

/// The ways to bring a file in, each as a button: the picker everywhere, the
/// camera and photo library on phones and tablets, a pasted image on desktop.
/// What was chosen goes to [onPicked]; a source that fails (a revoked
/// permission, a dialog that cannot open) is said in [onError], never thrown.
/// Keys are `$keyPrefix-add`, `-camera`, `-gallery` and `-paste`.
class AttachButtons extends ConsumerWidget {
  const AttachButtons({
    super.key,
    required this.keyPrefix,
    required this.onPicked,
    required this.onError,
    this.labelled = true,
  });

  final String keyPrefix;
  final Future<void> Function(List<UploadSource> sources) onPicked;
  final void Function() onError;

  /// The picker button reads "Add" (and is a text button); otherwise an icon.
  final bool labelled;

  Future<void> _pick(WidgetRef ref, SourcePicker picker) async {
    try {
      final sources = await picker();
      if (sources.isEmpty || !ref.context.mounted) return;
      await onPicked(sources);
    } on Object {
      if (ref.context.mounted) onError();
    }
  }

  Future<void> _paste(WidgetRef ref) async {
    try {
      final image = await ref.read(clipboardImageProvider)();
      if (image == null || !ref.context.mounted) return;
      await onPicked([image]);
    } on Object {
      if (ref.context.mounted) onError();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      if (labelled)
        TextButton.icon(
          key: Key('$keyPrefix-add'),
          onPressed: () => _pick(ref, ref.read(filePickerProvider)),
          icon: const Icon(Icons.attach_file, size: 18),
          label: const Text('Add'),
        )
      else
        IconButton(
          key: Key('$keyPrefix-add'),
          tooltip: 'Attach a file',
          onPressed: () => _pick(ref, ref.read(filePickerProvider)),
          icon: const Icon(Icons.attach_file, size: 20),
        ),
      if (isPhoneOrTablet) ...[
        IconButton(
          key: Key('$keyPrefix-camera'),
          tooltip: 'Take a photo',
          onPressed: () => _pick(ref, ref.read(cameraPickerProvider)),
          icon: const Icon(Icons.photo_camera_outlined, size: 20),
        ),
        IconButton(
          key: Key('$keyPrefix-gallery'),
          tooltip: 'Choose from gallery',
          onPressed: () => _pick(ref, ref.read(galleryPickerProvider)),
          icon: const Icon(Icons.photo_library_outlined, size: 20),
        ),
      ],
      if (canReadClipboardImage)
        IconButton(
          key: Key('$keyPrefix-paste'),
          tooltip: 'Paste an image',
          onPressed: () => _paste(ref),
          icon: const Icon(Icons.content_paste, size: 20),
        ),
    ],
  );
}
