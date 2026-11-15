import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

import 'package:taskforge/core/i18n/context_dates.dart';
import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/features/attachments/application/attachments_providers.dart';
import 'package:taskforge/features/attachments/data/uploads_client.dart';
import 'package:taskforge/features/attachments/domain/attachments.dart';
import 'package:taskforge/features/attachments/presentation/attachment_access.dart';
import 'package:taskforge/features/attachments/presentation/attachments_io.dart';
import 'package:taskforge/features/attachments/presentation/signed_image.dart';

/// Opens the lightbox for [file]: the picture (zoomable), the first part of a
/// text file, a video player, or, for a PDF and anything else, the thumbnail
/// and a button that hands the signed link to the system. [onDelete], when
/// given, adds a delete button (the caller has checked who may); it asks first.
Future<void> showAttachmentViewer(
  BuildContext context, {
  required Attachment file,
  VoidCallback? onDelete,
}) => showDialog<void>(
  context: context,
  builder: (_) => AttachmentViewer(file: file, onDelete: onDelete),
);

class AttachmentViewer extends ConsumerWidget {
  const AttachmentViewer({super.key, required this.file, this.onDelete});

  final Attachment file;
  final VoidCallback? onDelete;

  /// A fresh link (they expire quickly) opened outside the app.
  Future<void> _open(BuildContext context, WidgetRef ref) async {
    try {
      final link = await ref.read(uploadsClientProvider).link(file.id);
      final uri = Uri.tryParse(link.url);
      final opened = uri != null && await ref.read(urlOpenerProvider)(uri);
      if (!opened && context.mounted) {
        _say(context, context.l10n.grpHCouldNotOpenFile);
      }
    } on AttachmentException catch (e) {
      if (context.mounted) {
        _say(context, attachmentErrorMessage(e, context.l10n));
      }
    } on Object {
      // The platform refused the link (a PlatformException, a bad address).
      if (context.mounted) _say(context, context.l10n.grpHCouldNotOpenFile);
    }
  }

  Future<void> _delete(BuildContext context) async {
    if (!await confirmDeleteAttachment(context, file.filename)) return;
    if (!context.mounted) return;
    Navigator.pop(context);
    onDelete!();
  }

  void _say(BuildContext context, String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.sizeOf(context);
    return Dialog(
      key: const Key('attachment-viewer'),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 900,
          maxHeight: size.height * 0.85,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 8, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${file.filename} · ${context.localDigits(formatBytes(file.size, context.l10n))}',
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                  if (file.isPdf)
                    TextButton(
                      key: const Key('viewer-open'),
                      onPressed: () => _open(context, ref),
                      child: Text(context.l10n.grpHOpen),
                    ),
                  IconButton(
                    key: const Key('viewer-download'),
                    tooltip: context.l10n.grpHDownload,
                    onPressed: () => _open(context, ref),
                    icon: const Icon(Icons.download),
                  ),
                  if (onDelete != null)
                    IconButton(
                      key: const Key('viewer-delete'),
                      tooltip: context.l10n.grpHDelete,
                      onPressed: () => _delete(context),
                      icon: const Icon(Icons.delete_outline),
                    ),
                  IconButton(
                    key: const Key('viewer-close'),
                    tooltip: context.l10n.grpHClose,
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _Body(file: file),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.file});

  final Attachment file;

  @override
  Widget build(BuildContext context) {
    if (file.isImage) return _ImagePreview(file: file);
    if (file.isText) return _TextPreview(file: file);
    if (file.isVideo) return _VideoPreview(file: file);
    return _Fallback(file: file);
  }
}

class _Broken extends StatelessWidget {
  const _Broken(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Center(
    child: Semantics(
      liveRegion: true,
      child: Text(text, key: const Key('viewer-error')),
    ),
  );
}

class _ImagePreview extends StatelessWidget {
  const _ImagePreview({required this.file});

  final Attachment file;

  @override
  Widget build(BuildContext context) => InteractiveViewer(
    key: const Key('viewer-image'),
    maxScale: 6,
    child: SignedImage(
      fileId: file.id,
      fit: BoxFit.contain,
      semanticLabel: file.filename,
      fallback: _Broken(context.l10n.grpHCouldNotLoadPicture),
    ),
  );
}

class _TextPreview extends ConsumerWidget {
  const _TextPreview({required this.file});

  final Attachment file;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = ref.watch(_textProvider(file.id));
    return text.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => _Broken(context.l10n.grpHCouldNotReadFileViewer),
      data: (preview) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Flexible(
            child: SingleChildScrollView(
              child: SelectableText(
                preview.text,
                key: const Key('viewer-text'),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ),
          if (preview.truncated)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                context.l10n.grpHTextTruncated(
                  context.localDigits(
                    formatBytes(textPreviewBytes, context.l10n),
                  ),
                ),
                key: const Key('viewer-truncated'),
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ),
        ],
      ),
    );
  }
}

/// How much of a text file the lightbox reads.
const textPreviewBytes = 200 * 1024;

/// The first part of a text file.
final _textProvider = FutureProvider.autoDispose.family<TextPreview, String>((
  ref,
  id,
) async {
  final client = ref.read(uploadsClientProvider);
  final link = await client.link(id);
  return client.fetchText(link.url, maxBytes: textPreviewBytes);
});

class _VideoPreview extends ConsumerStatefulWidget {
  const _VideoPreview({required this.file});

  final Attachment file;

  @override
  ConsumerState<_VideoPreview> createState() => _VideoPreviewState();
}

class _VideoPreviewState extends ConsumerState<_VideoPreview> {
  VideoPlayerController? _controller;
  var _failed = false;

  /// Each start gets a number, so a slow earlier one cannot land after a
  /// later one (or after the viewer closed).
  var _generation = 0;
  var _renewals = 0;
  var _lastPosition = Duration.zero;
  var _lastPlaying = false;

  @override
  void initState() {
    super.initState();
    unawaited(_start());
  }

  /// Plays from a fresh signed link, from [at] (a renewal keeps the place).
  Future<void> _start({Duration at = Duration.zero, bool play = false}) async {
    final generation = ++_generation;
    VideoPlayerController? made;
    try {
      final link = await ref.read(uploadsClientProvider).link(widget.file.id);
      // Closed while the link was on its way: make nothing.
      if (!mounted || generation != _generation) return;
      made = ref.read(videoControllerFactoryProvider)(Uri.parse(link.url));
      await made.initialize();
      if (!mounted || generation != _generation) {
        await made.dispose();
        return;
      }
      if (at > Duration.zero) await made.seekTo(at);
      if (play) await made.play();
      if (!mounted || generation != _generation) {
        await made.dispose();
        return;
      }
      made.addListener(_changed);
      setState(() => _controller = made);
    } on Object {
      await made?.dispose();
      if (mounted && generation == _generation) {
        setState(() => _failed = true);
      }
    }
  }

  /// The play icon follows the player; a playback error (the link may have
  /// expired) renews the link once and carries on from the same place.
  void _changed() {
    final c = _controller;
    if (c == null || !mounted) return;
    if (c.value.hasError) {
      // An error wipes the value, so the place is the last one seen.
      if (_renewals < 1) {
        _renewals++;
        c
          ..removeListener(_changed)
          ..dispose();
        setState(() => _controller = null);
        unawaited(_start(at: _lastPosition, play: _lastPlaying));
      } else {
        setState(() => _failed = true);
      }
      return;
    }
    _lastPosition = c.value.position;
    _lastPlaying = c.value.isPlaying;
    setState(() {});
  }

  @override
  void dispose() {
    _generation++;
    _controller
      ?..removeListener(_changed)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = _controller;
    if (_failed) return _Broken(context.l10n.grpHCouldNotPlayVideo);
    if (c == null || !c.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }
    final playing = c.value.isPlaying;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: AspectRatio(
            aspectRatio: c.value.aspectRatio,
            child: VideoPlayer(c),
          ),
        ),
        IconButton(
          key: const Key('video-toggle'),
          tooltip: playing ? context.l10n.grpHPause : context.l10n.grpHPlay,
          onPressed: () => playing ? c.pause() : c.play(),
          icon: Icon(playing ? Icons.pause : Icons.play_arrow),
        ),
      ],
    );
  }
}

/// A PDF or any other kind: what the server drew of it, and what it is.
class _Fallback extends StatelessWidget {
  const _Fallback({required this.file});

  final Attachment file;

  @override
  Widget build(BuildContext context) {
    const plain = Icon(Icons.insert_drive_file_outlined, size: 64);
    return Column(
      key: const Key('viewer-fallback'),
      mainAxisSize: MainAxisSize.min,
      children: [
        if (file.hasThumb)
          Flexible(
            child: SignedImage(
              fileId: file.id,
              thumb: true,
              fit: BoxFit.contain,
              semanticLabel: file.filename,
              fallback: plain,
            ),
          )
        else
          plain,
        const SizedBox(height: 8),
        Text(file.mime, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
