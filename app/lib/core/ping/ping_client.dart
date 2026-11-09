/// One transport's "is the server reachable" probe.
abstract interface class PingClient {
  /// Short name shown on the button, e.g. `REST`.
  String get label;

  /// Returns the server's reply text, or throws if it cannot be reached.
  Future<String> ping();
}
