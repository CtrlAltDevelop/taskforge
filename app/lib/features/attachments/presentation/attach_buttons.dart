import 'package:taskforge/core/ui/tf_icons.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/core/i18n/l10n_context.dart';
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
          icon: const TfIcon(TfIcons.attachment, size: 18),
          label: Text(context.l10n.grpHAdd),
        )
      else
        IconButton(
          key: Key('$keyPrefix-add'),
          tooltip: context.l10n.grpHAttachFile,
          onPressed: () => _pick(ref, ref.read(filePickerProvider)),
          icon: const TfIcon(TfIcons.attachment, size: 20),
        ),
      if (isPhoneOrTablet) ...[
        IconButton(
          key: Key('$keyPrefix-camera'),
          tooltip: context.l10n.grpHTakePhoto,
          onPressed: () => _pick(ref, ref.read(cameraPickerProvider)),
          icon: const TfIcon(TfIcons.camera, size: 20),
        ),
        IconButton(
          key: Key('$keyPrefix-gallery'),
          tooltip: context.l10n.grpHChooseGallery,
          onPressed: () => _pick(ref, ref.read(galleryPickerProvider)),
          icon: const TfIcon(TfIcons.images, size: 20),
        ),
      ],
      if (canReadClipboardImage)
        IconButton(
          key: Key('$keyPrefix-paste'),
          tooltip: context.l10n.grpHPasteImage,
          onPressed: () => _paste(ref),
          icon: const TfIcon(TfIcons.clipboardPaste, size: 20),
        ),
    ],
  );
}
