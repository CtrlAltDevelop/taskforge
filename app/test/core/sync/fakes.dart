import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:taskforge/core/sync/sync_transport.dart';

/// A socket the test drives by hand.
class FakeConnection implements SocketConnection {
  final _frames = StreamController<String>();
  final _ready = Completer<void>();
  final sent = <Map<String, dynamic>>[];
  var closed = false;

  /// Answers every subscribe with `subscribed`, as the server does (unless a test wants to hold it back).
  var answerSubscribe = true;

  @override
  Future<void> get ready => _ready.future;

  @override
  Stream<String> get frames => _frames.stream;

  @override
  int? closeCode;

  @override
  void send(String frame) {
    final decoded = jsonDecode(frame) as Map<String, dynamic>;
    sent.add(decoded);
    if (answerSubscribe && decoded['type'] == 'subscribe') {
      scheduleMicrotask(() {
        if (!_frames.isClosed) {
          say({'type': 'subscribed', 'room': decoded['room']});
        }
      });
    }
  }

  @override
  Future<void> close() async {
    closed = true;
  }

  void open() => _ready.complete();

  void failToOpen() => _ready.completeError(StateError('refused'));

  void say(Map<String, dynamic> frame) => _frames.add(jsonEncode(frame));

  /// The server (or the network) ended the connection.
  Future<void> drop() => _frames.close();

  List<String> get sentTypes => [for (final f in sent) f['type'] as String];

  List<Map<String, dynamic>> sentOf(String type) => [
    for (final f in sent)
      if (f['type'] == type) f,
  ];
}

class FakeConnector implements SocketConnector {
  final connections = <FakeConnection>[];
  Uri? lastUrl;

  FakeConnection get last => connections.last;

  @override
  SocketConnection connect(Uri url) {
    lastUrl = url;
    return FakeConnection()..also(connections.add);
  }
}

extension on FakeConnection {
  void also(void Function(FakeConnection) f) => f(this);
}

class ManualTimer implements Timer {
  ManualTimer(this.delay, this._run);

  final Duration delay;
  final void Function() _run;
  var cancelled = false;
  var fired = false;

  @override
  void cancel() => cancelled = true;

  @override
  bool get isActive => !cancelled && !fired;

  @override
  int get tick => fired ? 1 : 0;

  void fire() {
    if (!isActive) return;
    fired = true;
    _run();
  }
}

class ManualTimers {
  final all = <ManualTimer>[];

  Timer call(Duration after, void Function() run) {
    final timer = ManualTimer(after, run);
    all.add(timer);
    return timer;
  }

  List<ManualTimer> get pending => [
    for (final t in all)
      if (t.isActive) t,
  ];

  /// The pending timer waiting [delay] (the reconnect, the heartbeat...).
  ManualTimer waiting(Duration delay) =>
      pending.lastWhere((t) => t.delay == delay);
}

/// A random source that always answers [value] (0 to 1).
class FixedRandom implements Random {
  FixedRandom(this.value);

  final double value;

  @override
  double nextDouble() => value;

  @override
  bool nextBool() => value >= 0.5;

  @override
  int nextInt(int max) => (value * max).floor();
}
