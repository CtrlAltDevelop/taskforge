import 'package:flutter/foundation.dart';
import 'package:grpc/grpc_connection_interface.dart' show ClientChannelBase;
import 'package:grpc/grpc.dart' show GrpcError, StatusCode;
import 'package:grpc/service_api.dart' show CallOptions;
import 'package:protobuf/well_known_types/google/protobuf/empty.pb.dart';

import 'package:taskforge/core/auth/auth_session.dart';
import 'package:taskforge/gen/infrastructure/accounts/grpc/accounts.pbgrpc.dart';
import 'package:taskforge/gen/infrastructure/oauth/rotation/grpc/oauth_rotation.pbgrpc.dart';

@immutable
class Account {
  const Account({required this.email, required this.displayName});

  final String email;
  final String displayName;
}

@immutable
class SessionInfo {
  const SessionInfo({
    required this.id,
    required this.userAgent,
    required this.ipAddress,
    required this.lastUsedAt,
    required this.current,
  });

  final String id;
  final String userAgent;
  final String ipAddress;
  final String lastUsedAt;
  final bool current;
}

abstract interface class AccountClient {
  Future<Account> me();
  Future<List<SessionInfo>> sessions();
}

/// Reads the signed-in account over gRPC, attaching a fresh token to every call.
class GrpcAccountClient implements AccountClient {
  GrpcAccountClient(ClientChannelBase channel, this._session)
    : _accounts = AccountControllerClient(channel),
      _tokens = RotationTokenRpcControllerClient(channel);

  final AccountControllerClient _accounts;
  final RotationTokenRpcControllerClient _tokens;
  final AuthSession _session;

  CallOptions get _auth => CallOptions(
    timeout: const Duration(seconds: 10),
    providers: [
      (metadata, uri) async {
        final token = await _session.accessToken();
        if (token != null) metadata['authorization'] = 'Bearer $token';
      },
    ],
  );

  /// Runs [call]; if the server rejects the token (revoked elsewhere, or a wrong
  /// device clock hid its expiry) it refreshes once and retries. A refused
  /// refresh ends the session and the original error is surfaced.
  Future<T> _withRefresh<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on GrpcError catch (e) {
      if (e.code != StatusCode.unauthenticated) rethrow;
      if (await _session.forceRefresh() == null) rethrow;
      return call();
    }
  }

  @override
  Future<Account> me() async {
    final account = await _withRefresh(
      () => _accounts.me(Empty(), options: _auth),
    );
    return Account(
      email: account.email,
      displayName: account.profile.displayName,
    );
  }

  @override
  Future<List<SessionInfo>> sessions() async {
    final list = await _withRefresh(
      () => _tokens.sessions(Empty(), options: _auth),
    );
    // The server does not flag the caller's own session; this device knows its id.
    final currentId = await _session.currentSessionId();
    return [
      for (final s in list.sessions)
        SessionInfo(
          id: s.sessionId,
          userAgent: s.userAgent,
          ipAddress: s.ipAddress,
          lastUsedAt: s.lastUsedAt,
          current: s.current || s.sessionId == currentId,
        ),
    ];
  }
}
