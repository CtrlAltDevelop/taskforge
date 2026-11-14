import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';

import 'package:taskforge/core/sync/sync_models.dart';
import 'package:taskforge/core/sync/sync_transport.dart';

/// What a catch-up read found: the changes after a cursor, or that the cursor
/// is older than the log (everything must be read again).
@immutable
class CatchUp {
  const CatchUp({this.events = const [], this.head = 0, this.gap = false});

  final List<SyncEvent> events;

  /// The cursor to continue from.
  final int head;
  final bool gap;
}

typedef Timers = Timer Function(Duration after, void Function() run);

Timer _realTimer(Duration after, void Function() run) => Timer(after, run);

/// The live connection: one socket, kept open.
///
/// Connects and signs in with a fresh token, joins the rooms asked for,
/// then reads what it missed (`catchUp` from the last cursor it saw, a little
/// before it, since ids can land slightly out of commit order) so no change is
/// lost to a gap. When the socket drops it tries again after a jittered,
/// growing pause, so a restarted server is not hit by every client at once.
/// Everything it hears goes out on [events], [presence] and [lost]; [state]
/// says whether the picture is live.
class SyncClient {
  SyncClient({
    required this.connector,
    required this.url,
    required this.token,
    required this.catchUp,
    required this.head,
    this.clientId = '',
    this.refreshToken,
    this.socketProof,
    this.onProofRefused,
    Random? random,
    Timers? timers,
    this.pingEvery = const Duration(seconds: 25),
    this.silenceLimit = const Duration(seconds: 70),
    this.handshakeLimit = const Duration(seconds: 10),
    this.firstRetry = const Duration(seconds: 1),
    this.longestRetry = const Duration(seconds: 30),
  }) : _random = random ?? Random(),
       _timers = timers ?? _realTimer;

  final SocketConnector connector;
  final Uri url;

  /// A valid access token (refreshed when it needs it), null when signed out.
  final Future<String?> Function() token;

  /// The changes after [cursor] (see [CatchUp]).
  final Future<CatchUp> Function(int cursor) catchUp;

  /// The cursor to start listening from on the very first connect.
  final Future<int> Function() head;

  /// This app's own id, which the server turns into the tag it puts on events this app made.
  final String clientId;

  /// Gets a new access token after the server refused the one in use.
  final Future<String?> Function()? refreshToken;

  /// A DPoP proof for the `authenticate` frame (phase 39): `htm=GET`, `htu` the socket URL, `ath`
  /// of the token. Null when the deployment does not bind sessions.
  final Future<String> Function(Uri url, String accessToken)? socketProof;

  /// Told about a refused proof (the frame carries the nonce or clock to retry with).
  final void Function(Map<String, dynamic> frame)? onProofRefused;
  final Random _random;
  final Timers _timers;
  final Duration pingEvery;
  final Duration silenceLimit;
  final Duration handshakeLimit;
  final Duration firstRetry;
  final Duration longestRetry;

  final _events = StreamController<SyncEvent>.broadcast();
  final _presence = StreamController<PresenceUpdate>.broadcast();
  final _lost = StreamController<RoomLost>.broadcast();
  final _state = ValueNotifier<SyncState>(SyncState.offline);
  final _rooms = <String>{};
  final _seen = <int>{};

  SocketConnection? _connection;
  StreamSubscription<String>? _listening;
  Timer? _retry;
  Timer? _ping;
  Timer? _watchdog;
  var _attempt = 0;
  var _epoch = 0;
  var _running = false;

  /// Signed in on the current socket: nothing may be sent before this.
  var _authenticated = false;
  int? _cursor;
  String _userId = '';
  String _origin = '';
  var _refused = false;
  final _joining = <String, Completer<void>>{};

  Stream<SyncEvent> get events => _events.stream;
  Stream<PresenceUpdate> get presence => _presence.stream;
  Stream<RoomLost> get lost => _lost.stream;
  ValueListenable<SyncState> get state => _state;

  /// The account the server says this connection belongs to (after ready).
  String get userId => _userId;

  /// The tag the server puts on events this client made (after ready).
  String get ownOrigin => _origin;

  /// The highest cursor seen (null before the first connect finished).
  int? get cursor => _cursor;

  /// The rooms this client wants to be in (re-joined after every reconnect).
  Set<String> get rooms => Set.unmodifiable(_rooms);

  void start() {
    if (_running) return;
    _running = true;
    _attempt = 0;
    unawaited(_connect());
  }

  Future<void> stop() async {
    _running = false;
    _epoch++;
    _retry?.cancel();
    _retry = null;
    await _drop();
    _cursor = null;
    _seen.clear();
    _state.value = SyncState.offline;
  }

  Future<void> dispose() async {
    await stop();
    await _events.close();
    await _presence.close();
    await _lost.close();
    _state.dispose();
  }

  void subscribe(String room) {
    if (!_rooms.add(room)) return;
    _send({'type': 'subscribe', 'room': room});
  }

  void unsubscribe(String room) {
    if (!_rooms.remove(room)) return;
    _send({'type': 'unsubscribe', 'room': room});
  }

  /// Tells the others this person is on (or has left) a task.
  void sendPresence(String project, String task, String state) => _send({
    'type': 'presence',
    'project': project,
    'task': task,
    'state': state,
  });

  // ------------------------------------------------------------ connecting

  Future<void> _connect() async {
    if (!_running) return;
    final epoch = ++_epoch;
    _state.value = _cursor == null && _attempt == 0
        ? SyncState.connecting
        : SyncState.reconnecting;
    try {
      final access = _refused && refreshToken != null
          ? await refreshToken!()
          : await token();
      _refused = false;
      if (access == null) {
        _failed(epoch);
        return;
      }
      final connection = connector.connect(url);
      _connection = connection;
      await connection.ready.timeout(handshakeLimit);
      if (epoch != _epoch) return;
      final ready = Completer<void>();
      _listening = connection.frames.listen(
        (frame) => _hear(frame, epoch, ready),
        onDone: () => _closed(epoch),
        onError: (Object _) => _closed(epoch),
      );
      final proof = await socketProof?.call(url, access);
      connection.send(
        jsonEncode({
          'type': 'authenticate',
          'token': access,
          'dpop': ?proof,
          if (clientId.isNotEmpty) 'client_id': clientId,
        }),
      );
      await ready.future.timeout(handshakeLimit);
      if (epoch != _epoch) return;
      await _synchronise(epoch);
    } on Object {
      _failed(epoch);
    }
  }

  /// Joined and signed in: ask for the rooms, read what was missed, go live.
  Future<void> _synchronise(int epoch) async {
    // Every room is joined before anything is read, or a change could land after the catch-up and
    // before the join and be in neither.
    final joined = <Future<void>>[];
    for (final room in _rooms) {
      final done = _joining[room] = Completer<void>();
      joined.add(done.future);
      _send({'type': 'subscribe', 'room': room});
    }
    await Future.wait(joined).timeout(handshakeLimit);
    _joining.clear();
    if (epoch != _epoch) return;
    final since = _cursor;
    final CatchUp missed;
    var firstTime = false;
    if (since == null) {
      _cursor = await head();
      missed = const CatchUp();
      firstTime = true;
    } else {
      missed = await catchUp(since);
    }
    if (epoch != _epoch) return;
    if (missed.gap) {
      _cursor = missed.head;
      _seen.clear();
    } else if (missed.head > (_cursor ?? 0)) {
      _cursor = missed.head; // past entries this person cannot see, too
    }
    // Screens read before this socket listened may have missed a change made in
    // between, so the first connection also asks them to read again, once.
    if (missed.gap || firstTime) {
      _events.add(const SyncEvent(type: SyncEvent.gapType));
    }
    for (final event in missed.events) {
      _deliver(event);
    }
    _attempt = 0;
    _state.value = SyncState.live;
    _ping?.cancel();
    _ping = _timers(pingEvery, () => _beat(epoch));
    _arm(epoch);
  }

  void _beat(int epoch) {
    if (epoch != _epoch) return;
    _send({'type': 'ping'});
    _ping = _timers(pingEvery, () => _beat(epoch));
  }

  /// Nothing heard for [silenceLimit] means the connection is dead even though
  /// the socket never said so (a phone that lost its network).
  void _arm(int epoch) {
    _watchdog?.cancel();
    _watchdog = _timers(silenceLimit, () {
      if (epoch == _epoch) _closed(epoch);
    });
  }

  // --------------------------------------------------------------- hearing

  void _hear(String raw, int epoch, Completer<void> ready) {
    if (epoch != _epoch) return;
    final Object? decoded;
    try {
      decoded = jsonDecode(raw);
    } on FormatException {
      return;
    }
    if (decoded is! Map<String, dynamic>) return;
    if (_state.value == SyncState.live) _arm(epoch);
    switch (decoded['type']) {
      case 'ready':
        final user = decoded['user'];
        if (user is Map<String, dynamic>) _userId = user['id'] as String? ?? '';
        _origin = decoded['origin'] as String? ?? '';
        _authenticated = true;
        if (!ready.isCompleted) ready.complete();
      case 'event':
        final event = decoded['event'];
        if (event is Map<String, dynamic>) _deliver(SyncEvent.fromJson(event));
      case 'presence':
        _presence.add(_presenceOf(decoded));
      case 'subscribed':
        _joining.remove(decoded['room'])?.complete();
      case 'unsubscribed':
        // Only the server taking a room away changes what is wanted: the echo of a
        // request made here must not undo a join made since.
        final room = decoded['room'] as String? ?? '';
        final reason = decoded['reason'] as String? ?? 'access';
        if (reason == 'access') {
          _rooms.remove(room);
          _lost.add(RoomLost(room, reason));
        }
      case 'error':
        _error(decoded, ready);
    }
  }

  void _error(Map<String, dynamic> frame, Completer<void> ready) {
    final code = frame['code'];
    final room = frame['room'];
    if (code == 'use_dpop_nonce') {
      // The token is fine; the server wants its nonce in the proof. Reconnect with it.
      onProofRefused?.call(frame);
      if (!ready.isCompleted) ready.completeError(StateError('nonce'));
    } else if (code == 'invalid_dpop_proof' || code == 'invalid_token') {
      onProofRefused?.call(frame);
      _refused = true;
      if (!ready.isCompleted) ready.completeError(StateError('proof'));
    } else if (code == 'unauthenticated') {
      _refused = true; // the next attempt gets a new token
      if (!ready.isCompleted) {
        ready.completeError(StateError('unauthenticated'));
      }
    } else if (code == 'forbidden' && room is String) {
      _rooms.remove(room);
      _joining.remove(room)?.complete();
      _lost.add(RoomLost(room, 'forbidden'));
    }
  }

  PresenceUpdate _presenceOf(Map<String, dynamic> frame) => PresenceUpdate(
    project: frame['project'] as String? ?? '',
    task: frame['task'] as String? ?? '',
    users: [
      for (final u in (frame['users'] as List<dynamic>? ?? const []))
        if (u is Map<String, dynamic>)
          PresenceUser(
            u['id'] as String? ?? '',
            editing: u['editing'] as bool? ?? false,
          ),
    ],
  );

  void _deliver(SyncEvent event) {
    if (event.cursor > 0) {
      if (!_seen.add(event.cursor)) {
        return; // heard already (live and catch-up overlap)
      }
      if (_seen.length > 2000) _seen.remove(_seen.reduce(min));
      if (event.cursor > (_cursor ?? 0)) _cursor = event.cursor;
    }
    _events.add(event);
  }

  // ------------------------------------------------------------- dropping

  void _send(Map<String, Object?> frame) {
    final connection = _connection;
    if (connection == null || !_authenticated) return;
    try {
      connection.send(jsonEncode(frame));
    } on Object {
      // The socket is going away; the reconnect joins the rooms again.
    }
  }

  void _closed(int epoch) {
    if (epoch != _epoch || !_running) return;
    _failed(epoch);
  }

  void _failed(int epoch) {
    if (epoch != _epoch || !_running) return;
    _epoch++; // whatever was still in flight on this connection must not go live
    unawaited(_drop());
    _state.value = SyncState.reconnecting;
    _attempt++;
    _retry?.cancel();
    _retry = _timers(retryDelay(_attempt), _connect);
  }

  /// The pause before attempt [attempt]: doubles each time up to
  /// [longestRetry], and is a random share of that (half to all of it), so the
  /// clients of a restarted server do not all come back in the same second.
  @visibleForTesting
  Duration retryDelay(int attempt) {
    final ceiling = min(
      longestRetry.inMilliseconds,
      firstRetry.inMilliseconds * pow(2, attempt - 1).toInt(),
    );
    return Duration(
      milliseconds: (ceiling * (0.5 + 0.5 * _random.nextDouble())).round(),
    );
  }

  Future<void> _drop() async {
    _authenticated = false;
    _joining.clear();
    _ping?.cancel();
    _watchdog?.cancel();
    final listening = _listening;
    _listening = null;
    final connection = _connection;
    _connection = null;
    await listening?.cancel();
    await connection?.close();
  }
}
