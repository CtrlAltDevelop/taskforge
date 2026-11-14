import 'package:taskforge/features/system/data/system_client.dart';
import 'package:taskforge/features/system/domain/system.dart';

/// A system client with a settable server version (default: same as the app, no minimum).
class FakeSystemClient implements SystemClient {
  FakeSystemClient({
    this.server = const ServerVersion(
      version: '0.0.0',
      minClientVersion: '0.0.0',
    ),
  });

  ServerVersion server;

  @override
  Future<ServerVersion> serverVersion() async => server;

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('FakeSystemClient.${invocation.memberName}');
}
