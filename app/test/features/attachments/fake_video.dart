import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';

/// A video platform with no video: players "initialize" at once, remember what
/// they were told and can be made to fail, so the viewer's player logic can be
/// tested without a device.
class FakeVideoPlatform extends VideoPlayerPlatform {
  final created = <String>[]; // the url of each player, in order
  final disposed = <int>[];
  final playing = <int, bool>{};
  final seeks = <int, Duration>{};
  final _events = <int, StreamController<VideoEvent>>{};
  var _next = 1;

  /// Where the next player says it is.
  Duration position = Duration.zero;

  /// When set, every `create` waits for it (to close the viewer meanwhile).
  Completer<void>? createGate;

  int get live => created.length - disposed.length;

  /// Makes the player [id] report a playback error.
  void fail(int id) => _events[id]!.addError(
    PlatformException(code: '403', message: 'link expired'),
  );

  @override
  Future<void> init() async {}

  @override
  Future<int?> create(DataSource dataSource) async {
    if (createGate != null) await createGate!.future;
    final id = _next++;
    created.add(dataSource.uri ?? '');
    _events[id] = StreamController<VideoEvent>.broadcast();
    return id;
  }

  @override
  Future<int?> createWithOptions(VideoCreationOptions options) =>
      create(options.dataSource);

  @override
  Stream<VideoEvent> videoEventsFor(int playerId) {
    // The player listens right after this returns: tell it, a moment later,
    // that the video is ready.
    scheduleMicrotask(
      () => _events[playerId]?.add(
        VideoEvent(
          eventType: VideoEventType.initialized,
          duration: const Duration(seconds: 30),
          size: const Size(320, 180),
        ),
      ),
    );
    return _events[playerId]!.stream;
  }

  @override
  Future<void> dispose(int playerId) async {
    disposed.add(playerId);
    await _events.remove(playerId)?.close();
  }

  @override
  Future<void> setLooping(int playerId, bool looping) async {}

  @override
  Future<void> play(int playerId) async => playing[playerId] = true;

  @override
  Future<void> pause(int playerId) async => playing[playerId] = false;

  @override
  Future<void> setVolume(int playerId, double volume) async {}

  @override
  Future<void> setPlaybackSpeed(int playerId, double speed) async {}

  @override
  Future<void> seekTo(int playerId, Duration position) async =>
      seeks[playerId] = position;

  @override
  Future<Duration> getPosition(int playerId) async => position;

  @override
  Widget buildView(int playerId) => const SizedBox(key: Key('fake-video-view'));

  @override
  Widget buildViewWithOptions(VideoViewOptions options) =>
      const SizedBox(key: Key('fake-video-view'));

  @override
  Future<void> setMixWithOthers(bool mixWithOthers) async {}
}
