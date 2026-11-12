import 'dart:convert';
import 'dart:io' show SocketException;

import 'package:grpc/grpc.dart' show GrpcError, StatusCode;
import 'package:http/http.dart' as http;
import 'package:protobuf/protobuf.dart' show GeneratedMessage;

import 'package:taskforge/core/offline/offline_store.dart';

/// Kind of the rows [ReadCache] keeps in the local database.
const readCacheKind = 'pb';

/// Whether [e] means "the server could not be reached".
bool isUnreachable(Object e) =>
    e is SocketException ||
    e is http.ClientException ||
    e is GrpcError &&
        (e.code == StatusCode.unavailable ||
            e.code == StatusCode.deadlineExceeded);

/// Keeps the last answer of a read (the reply message as it came) so it can
/// be shown again when the server cannot be reached: the workspaces, the
/// projects, the workflow, the fields and the members.
class ReadCache {
  const ReadCache({
    required this.store,
    required this.online,
    required this.failed,
    required this.worked,
  });

  final Future<OfflineStore?> Function() store;
  final bool Function() online;
  final void Function() failed;
  final void Function() worked;

  /// Runs [call] and keeps its answer under [key] (in [workspaceId], '' when
  /// it belongs to none). Offline, a kept answer is returned straight away;
  /// if the call cannot reach the server, so is it. Nothing kept: the
  /// failure stands.
  Future<R> through<R extends GeneratedMessage>(
    String workspaceId,
    String key,
    Future<R> Function() call,
    R Function(List<int>) parse,
  ) async {
    final db = await store();
    if (db == null) return call();
    if (!online()) {
      final kept = await _kept(db, workspaceId, key, parse);
      if (kept != null) return kept;
    }
    try {
      final reply = await call();
      worked();
      await db.put(
        workspaceId,
        readCacheKind,
        key,
        base64Encode(reply.writeToBuffer()),
      );
      return reply;
    } on Object catch (e) {
      if (!isUnreachable(e)) rethrow;
      failed();
      final kept = await _kept(db, workspaceId, key, parse);
      if (kept == null) rethrow;
      return kept;
    }
  }

  Future<R?> _kept<R extends GeneratedMessage>(
    OfflineStore db,
    String workspaceId,
    String key,
    R Function(List<int>) parse,
  ) async {
    final json = await db.get(workspaceId, readCacheKind, key);
    if (json == null) return null;
    try {
      return parse(base64Decode(json));
    } on FormatException {
      return null; // an older shape: read it from the server instead
    }
  }
}

/// [call] through [cache] when there is one (tests and the browser have none).
Future<R> readThrough<R extends GeneratedMessage>(
  ReadCache? cache,
  String workspaceId,
  String key,
  Future<R> Function() call,
  R Function(List<int>) parse,
) => cache == null ? call() : cache.through(workspaceId, key, call, parse);
