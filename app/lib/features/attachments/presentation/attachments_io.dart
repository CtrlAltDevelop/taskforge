import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pasteboard/pasteboard.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

import 'package:taskforge/features/attachments/domain/attachments.dart';

/// What the person picked (empty when they cancelled). The providers below are
/// the seams tests replace: the real ones open the platform's own dialogs.
typedef SourcePicker = Future<List<UploadSource>> Function();

final filePickerProvider = Provider<SourcePicker>(
  (ref) => () async {
    final files = await FilePicker.pickFiles();
    return [for (final f in files) XFileSource(f.xFile, nameOverride: f.name)];
  },
);

/// Camera and photo library (phones and tablets).
final cameraPickerProvider = Provider<SourcePicker>(
  (ref) => () async {
    final shot = await ImagePicker().pickImage(source: ImageSource.camera);
    return [if (shot != null) XFileSource(shot)];
  },
);

final galleryPickerProvider = Provider<SourcePicker>(
  (ref) => () async {
    final shots = await ImagePicker().pickMultipleMedia();
    return [for (final s in shots) XFileSource(s)];
  },
);

/// An image on the clipboard, e.g. a screenshot. Not on the web: browsers give
/// a page the clipboard's images only through paste events, which Flutter web
/// does not pass on, so there the file picker and drag-and-drop are the way.
final clipboardImageProvider = Provider<Future<UploadSource?> Function()>(
  (ref) => () async {
    final bytes = await Pasteboard.image;
    if (bytes == null || bytes.isEmpty) return null;
    final stamp = DateTime.now().millisecondsSinceEpoch;
    return BytesSource('pasted-$stamp.png', bytes);
  },
);

/// Opens a link outside the app (the browser, a PDF reader).
final urlOpenerProvider = Provider<Future<bool> Function(Uri)>(
  (ref) =>
      (uri) => launchUrl(uri, mode: LaunchMode.externalApplication),
);

/// Makes the player for a signed video link; tests bring their own.
final videoControllerFactoryProvider =
    Provider<VideoPlayerController Function(Uri)>(
      (ref) => VideoPlayerController.networkUrl,
    );

bool get isPhoneOrTablet =>
    !kIsWeb &&
    (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS);

bool get canReadClipboardImage =>
    !kIsWeb &&
    {
      TargetPlatform.macOS,
      TargetPlatform.windows,
      TargetPlatform.linux,
    }.contains(defaultTargetPlatform);
