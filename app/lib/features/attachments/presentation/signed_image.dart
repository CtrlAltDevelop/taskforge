import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/features/attachments/application/attachments_providers.dart';

/// A picture of a file (or its thumbnail) through a signed link. Links expire
/// in minutes, so a picture that fails to load asks for a fresh link once
/// before it gives up and shows [fallback].
class SignedImage extends ConsumerStatefulWidget {
  const SignedImage({
    super.key,
    required this.fileId,
    required this.fallback,
    this.thumb = false,
    this.fit = BoxFit.cover,
    this.semanticLabel,
  });

  final String fileId;
  final bool thumb;
  final BoxFit fit;
  final Widget fallback;
  final String? semanticLabel;

  @override
  ConsumerState<SignedImage> createState() => _SignedImageState();
}

class _SignedImageState extends ConsumerState<SignedImage> {
  var _refetches = 0;
  var _scheduled = false;

  ({String id, bool thumb}) get _key =>
      (id: widget.fileId, thumb: widget.thumb);

  void _refetch() {
    if (_scheduled || _refetches >= 1) return;
    _scheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scheduled = false;
      if (!mounted) return;
      setState(() => _refetches++);
      ref.invalidate(fileLinkProvider(_key));
    });
  }

  @override
  Widget build(BuildContext context) {
    const waiting = Center(
      child: SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
    return ref
        .watch(fileLinkProvider(_key))
        .when(
          loading: () => waiting,
          error: (_, _) => widget.fallback,
          data: (link) => Image.network(
            link.url,
            key: ValueKey(link.url),
            fit: widget.fit,
            semanticLabel: widget.semanticLabel,
            errorBuilder: (_, _, _) {
              _refetch();
              return _refetches < 1 ? waiting : widget.fallback;
            },
          ),
        );
  }
}
