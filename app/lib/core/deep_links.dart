import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Links the OS hands the app (`taskforge://...`): the one that launched it,
/// then any that arrive while it runs. app_links emits the initial link first.
/// Web has real URLs, so it has no native links. Tests override this stream.
final deepLinkStreamProvider = Provider<Stream<Uri>>(
  (ref) => kIsWeb ? const Stream.empty() : AppLinks().uriLinkStream,
);

final deepLinksProvider = StreamProvider<Uri>(
  (ref) => ref.watch(deepLinkStreamProvider),
);
