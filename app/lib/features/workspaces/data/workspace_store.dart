import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:taskforge/core/auth/secure_storage.dart';

/// Remembers the selected workspace id on this device.
abstract interface class WorkspaceStore {
  Future<String?> read();
  Future<void> write(String? id);
}

class MemoryWorkspaceStore implements WorkspaceStore {
  String? _id;

  @override
  Future<String?> read() async => _id;

  @override
  Future<void> write(String? id) async => _id = id;
}

/// Same storage as the tokens; the id is not secret but needs no second plugin.
class SecureWorkspaceStore implements WorkspaceStore {
  SecureWorkspaceStore([FlutterSecureStorage? storage])
    : _storage = storage ?? appSecureStorage();

  static const _key = 'workspace.selected';
  final FlutterSecureStorage _storage;

  @override
  Future<String?> read() => _storage.read(key: _key);

  @override
  Future<void> write(String? id) => id == null
      ? _storage.delete(key: _key)
      : _storage.write(key: _key, value: id);
}
