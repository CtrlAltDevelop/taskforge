import 'package:grpc/grpc.dart' show GrpcError, StatusCode;
import 'package:grpc/grpc_connection_interface.dart' show ClientChannelBase;

import 'package:taskforge/core/auth/auth_session.dart';
import 'package:taskforge/core/workspace/scoped_requests.dart';
import 'package:taskforge/gen/infrastructure/shortcuts/grpc/shortcuts.pbgrpc.dart'
    as pb;

enum ShortcutFailure { invalid, conflict, network, other }

class ShortcutException implements Exception {
  const ShortcutException(this.failure, {this.detail = '', this.other = ''});

  final ShortcutFailure failure;
  final String detail;

  /// For a conflict: the id of the action that holds the keys.
  final String other;

  @override
  String toString() => 'ShortcutException($failure: $detail)';
}

/// A person's own key bindings, kept on the server so they follow them to
/// every device. Maps action id to wire chord ("" = unbound on purpose).
abstract interface class ShortcutsClient {
  Future<Map<String, String>> get();
  Future<Map<String, String>> set(String actionId, String keys);
  Future<Map<String, String>> reset(String actionId);
}

ShortcutException mapShortcutError(Object error) {
  if (error is ShortcutException) return error;
  if (error is GrpcError) {
    final message = (error.message ?? '').replaceFirst(
      RegExp(r'^[A-Z][A-Z0-9_]*: '),
      '',
    );
    return switch (error.code) {
      StatusCode.invalidArgument => ShortcutException(
        ShortcutFailure.invalid,
        detail: message,
      ),
      StatusCode.alreadyExists => ShortcutException(
        ShortcutFailure.conflict,
        detail: message,
      ),
      StatusCode.unavailable || StatusCode.deadlineExceeded =>
        const ShortcutException(ShortcutFailure.network),
      _ => const ShortcutException(ShortcutFailure.other),
    };
  }
  return const ShortcutException(ShortcutFailure.network);
}

class GrpcShortcutsClient implements ShortcutsClient {
  GrpcShortcutsClient(ClientChannelBase channel, this._session)
    : _client = pb.ShortcutControllerClient(channel);

  final pb.ShortcutControllerClient _client;
  final AuthSession _session;

  // Personal, not per workspace: no workspace header.
  late final _options = scopedCallOptions(_session, () => null);

  Future<Map<String, String>> _run(
    Future<pb.ShortcutList> Function() call,
  ) async {
    try {
      pb.ShortcutList answer;
      try {
        answer = await call();
      } on GrpcError catch (e) {
        if (e.code != StatusCode.unauthenticated) rethrow;
        if (await _session.forceRefresh() == null) rethrow;
        answer = await call();
      }
      return {for (final s in answer.shortcuts) s.actionId: s.keys};
    } on Object catch (e) {
      throw mapShortcutError(e);
    }
  }

  @override
  Future<Map<String, String>> get() =>
      _run(() => _client.get(pb.ShortcutGetRequest(), options: _options));

  @override
  Future<Map<String, String>> set(String actionId, String keys) => _run(
    () => _client.set(
      pb.ShortcutSetRequest(actionId: actionId, keys: keys),
      options: _options,
    ),
  );

  @override
  Future<Map<String, String>> reset(String actionId) => _run(
    () => _client.set(
      pb.ShortcutSetRequest(actionId: actionId, reset: true),
      options: _options,
    ),
  );
}
