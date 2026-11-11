import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/features/inbox/application/inbox_providers.dart';
import 'package:taskforge/features/inbox/data/inbox_client.dart';
import 'package:taskforge/features/inbox/data/local_notifier.dart';

/// The token a push service gave this device and which platform it is.
@immutable
class PushToken {
  const PushToken(this.platform, this.token);

  final String platform; // ios, android, web or desktop
  final String token;
}

/// Where a push token comes from (Firebase Messaging on a build that has it
/// configured). The default has none: the Firebase project files are not in
/// this repository, so push to a device needs a source plugged in here.
abstract interface class PushTokenSource {
  Future<PushToken?> token();
}

class NoPushTokenSource implements PushTokenSource {
  const NoPushTokenSource();

  @override
  Future<PushToken?> token() async => null;
}

final pushTokenSourceProvider = Provider<PushTokenSource>(
  (_) => const NoPushTokenSource(),
);

/// The system's notifications (shown while the app runs, asked for leave).
final localNotifierProvider = Provider<LocalNotifier>(
  (_) => SystemLocalNotifier(),
);

/// Tells the server which device to push to, and to stop on sign-out.
class PushRegistrar {
  PushRegistrar(this._client, this._source);

  final InboxClient _client;
  final PushTokenSource _source;
  String? _registered;

  /// Registers this device if the source has a token; false when it has none
  /// or the server refused (never throws: push is a nicety).
  Future<bool> register() async {
    try {
      final token = await _source.token();
      if (token == null) return false;
      if (token.token == _registered) return true; // already told the server
      await _client.registerDevice(token.platform, token.token);
      _registered = token.token;
      return true;
    } on Object {
      return false;
    }
  }

  Future<void> unregister() async {
    final token = _registered;
    if (token == null) return;
    _registered = null;
    try {
      await _client.unregisterDevice(token);
    } on Object {
      // Signing out must not wait on this: the server drops dead tokens.
    }
  }
}

final pushRegistrarProvider = Provider<PushRegistrar>(
  (ref) => PushRegistrar(
    ref.watch(inboxClientProvider),
    ref.watch(pushTokenSourceProvider),
  ),
);

/// Whether the system has agreed to show notifications: null until asked.
final pushPermissionProvider = NotifierProvider<PushPermission, bool?>(
  PushPermission.new,
);

class PushPermission extends Notifier<bool?> {
  @override
  bool? build() => null;

  /// Asks the system (the explanation was already shown) and registers the
  /// device when it agrees.
  Future<bool> ask() async {
    final granted = await ref.read(localNotifierProvider).requestPermission();
    if (!ref.mounted) return granted;
    state = granted;
    if (granted) unawaited(ref.read(pushRegistrarProvider).register());
    return granted;
  }
}
