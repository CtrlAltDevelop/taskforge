import 'dart:async';

import 'package:web_socket_channel/web_socket_channel.dart';

/// One open socket: frames in, frames out. A seam so the client can be tested
/// with a fake that the test drives by hand.
abstract interface class SocketConnection {
  /// Completes once the handshake is done; errors if it could not be.
  Future<void> get ready;

  /// Text frames from the server; done when the socket closed.
  Stream<String> get frames;

  /// The close code the server sent (null while open or unknown).
  int? get closeCode;

  void send(String frame);

  Future<void> close();
}

abstract interface class SocketConnector {
  SocketConnection connect(Uri url);
}

class WebSocketConnector implements SocketConnector {
  const WebSocketConnector();

  @override
  SocketConnection connect(Uri url) =>
      _WebSocketConnection(WebSocketChannel.connect(url));
}

class _WebSocketConnection implements SocketConnection {
  _WebSocketConnection(this._channel);

  final WebSocketChannel _channel;

  @override
  Future<void> get ready => _channel.ready;

  @override
  Stream<String> get frames =>
      _channel.stream.where((e) => e is String).cast<String>();

  @override
  int? get closeCode => _channel.closeCode;

  @override
  void send(String frame) => _channel.sink.add(frame);

  @override
  Future<void> close() async {
    // Not awaited: on a connection that never opened, `close()` never completes.
    unawaited(_channel.sink.close());
  }
}
