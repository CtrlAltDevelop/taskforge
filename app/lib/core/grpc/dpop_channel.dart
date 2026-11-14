import 'package:grpc/grpc_connection_interface.dart'
    show CallOptions, ClientCall, ClientChannelBase, ClientConnection;
import 'package:grpc/grpc.dart' show ConnectionState;
import 'package:grpc/service_api.dart' show ClientMethod;

import 'package:taskforge/core/auth/dpop/dpop_manager.dart';

/// Wraps the app's gRPC channel so that every call carrying an access token also carries a DPoP
/// proof in the `dpop` metadata key (for the method's own path) and the token under the `DPoP`
/// scheme. The same wrapper serves native gRPC and gRPC-Web. Calls without a token (nothing
/// signed in) pass through untouched.
class DpopClientChannel extends ClientChannelBase {
  DpopClientChannel(this._inner, this._dpop);

  final ClientChannelBase _inner;
  final DpopManager _dpop;

  @override
  ClientCall<Q, R> createCall<Q, R>(
    ClientMethod<Q, R> method,
    Stream<Q> requests,
    CallOptions options,
  ) => _inner.createCall(
    method,
    requests,
    options.mergedWith(
      CallOptions(
        providers: [
          (metadata, uri) async {
            final header = metadata['authorization'];
            if (header == null) return;
            final token = header.split(' ').last;
            await _dpop.ensureFresh();
            metadata['authorization'] = 'DPoP $token';
            metadata['dpop'] = await _dpop.proof(
              method: 'POST',
              path: method.path,
              accessToken: token,
            );
          },
        ],
      ),
    ),
  );

  @override
  ClientConnection createConnection() => _inner.createConnection();

  @override
  Future<ClientConnection> getConnection() => _inner.getConnection();

  @override
  Future<void> shutdown() => _inner.shutdown();

  @override
  Future<void> terminate() => _inner.terminate();

  @override
  Stream<ConnectionState> get onConnectionStateChanged =>
      _inner.onConnectionStateChanged;
}
