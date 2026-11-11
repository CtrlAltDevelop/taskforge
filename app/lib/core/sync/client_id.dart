import 'dart:math';

String _generate() {
  final random = Random.secure();
  return List.generate(
    16,
    (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0'),
  ).join();
}

/// This running app's own id, sent with every gRPC call. The live feed marks
/// each change with the id of the client that made it, so a client can tell an
/// echo of its own write (already on screen) from somebody else's change.
/// Changes per launch; it identifies nobody.
final String appClientId = _generate();
