import 'dart:async';

import 'package:taskforge/features/inbox/application/push.dart';
import 'package:taskforge/features/inbox/data/inbox_client.dart';
import 'package:taskforge/features/inbox/data/local_notifier.dart';
import 'package:taskforge/features/inbox/domain/inbox.dart';

/// Noon on a fixed day, so "later today" and relative times are the same
/// wherever the tests run.
final noon = DateTime(2026, 11, 11, 12);

InboxNotification note(
  String id,
  String type, {
  String workspace = 'w1',
  String task = 'a',
  String project = 'p1',
  String actor = 'Hank',
  Map<String, dynamic>? payload,
  int count = 1,
  DateTime? updatedAt,
  bool read = false,
  DateTime? snoozedUntil,
  bool archived = false,
}) => InboxNotification(
  id: id,
  workspaceId: workspace,
  type: type,
  taskId: task,
  projectId: project,
  actorId: 'u2',
  actorName: actor,
  payload: payload ?? {'key': 'WEB-1', 'title': 'Alpha'},
  count: count,
  createdAt: updatedAt ?? noon.subtract(const Duration(minutes: 5)),
  updatedAt: updatedAt ?? noon.subtract(const Duration(minutes: 5)),
  readAt: read ? noon.subtract(const Duration(minutes: 1)) : null,
  snoozedUntil: snoozedUntil,
  archivedAt: archived ? noon : null,
);

const defaultPrefs = Prefs([
  PrefRow(
    eventType: 'task.assigned',
    label: 'A task is assigned to you',
    inbox: true,
    push: true,
    email: EmailMode.off,
  ),
  PrefRow(
    eventType: 'user.mentioned',
    label: 'Someone mentions you',
    inbox: true,
    push: false,
    email: EmailMode.off,
  ),
  PrefRow(
    eventType: 'comment.added',
    label: 'A comment on a task you watch',
    inbox: true,
    push: false,
    email: EmailMode.digest,
  ),
], InboxSettings());

/// An in-memory server for the inbox: notifications in any workspace, the
/// caller's preferences, watched tasks and devices.
class FakeInboxClient implements InboxClient {
  FakeInboxClient({
    List<InboxNotification> initial = const [],
    this.pageSize = 50,
    DateTime Function()? now,
    this.prefsValue = defaultPrefs,
  }) : items = [...initial],
       now = now ?? (() => noon);

  final List<InboxNotification> items;
  int pageSize;
  final DateTime Function() now;
  Prefs prefsValue;

  /// Failure for the next call that changes something (or reads, see
  /// [failReads]).
  InboxException? failNext;
  bool failReads = false;
  Completer<void>? gate;

  final lists = <({String ws, InboxFilter filter, String before})>[];
  final markReads = <({List<String> ids, bool all, bool read})>[];
  final snoozes = <({String id, DateTime? until})>[];
  final archives = <({List<String> ids, bool archived})>[];
  final prefSets = <PrefRow>[];
  final settingsSets = <InboxSettings>[];
  final watchStates = <String, WatchState>{}; // by task id
  final watchCalls = <({String task, bool on})>[];
  final registered = <({String platform, String token})>[];
  final unregistered = <String>[];
  var prefsReads = 0;

  void _maybeFail() {
    final f = failNext;
    if (f != null) {
      failNext = null;
      throw f;
    }
  }

  Future<void> _wait() async {
    final g = gate;
    if (g != null) await g.future;
  }

  int _unread(String ws) => items
      .where(
        (n) =>
            (ws.isEmpty || n.workspaceId == ws) &&
            n.belongsTo(InboxFilter.unread, now()),
      )
      .length;

  @override
  Future<InboxPage> list(
    String workspaceId,
    InboxFilter filter, {
    String before = '',
    int pageSize = 30,
  }) async {
    lists.add((ws: workspaceId, filter: filter, before: before));
    await _wait();
    if (failReads) throw const InboxException(InboxFailure.network);
    final all = [
      for (final n in items)
        if (n.workspaceId == workspaceId && n.belongsTo(filter, now())) n,
    ]..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    final start = int.tryParse(before) ?? 0;
    final end = (start + this.pageSize).clamp(0, all.length);
    return InboxPage(
      all.sublist(start, end),
      end < all.length ? '$end' : '',
      _unread(workspaceId),
    );
  }

  void _set(List<String> ids, InboxNotification Function(InboxNotification) f) {
    for (final id in ids) {
      final i = items.indexWhere((n) => n.id == id);
      if (i >= 0) items[i] = f(items[i]);
    }
  }

  @override
  Future<int> markRead(
    String workspaceId, {
    List<String> ids = const [],
    bool all = false,
    bool read = true,
  }) async {
    markReads.add((ids: ids, all: all, read: read));
    await _wait();
    _maybeFail();
    final targets = all
        ? [
            for (final n in items)
              if (n.workspaceId == workspaceId) n.id,
          ]
        : ids;
    _set(
      targets,
      (n) => n.copyWith(readAt: () => read ? (n.readAt ?? now()) : null),
    );
    return _unread(workspaceId);
  }

  @override
  Future<InboxNotification> snooze(
    String workspaceId,
    String id,
    DateTime? until,
  ) async {
    snoozes.add((id: id, until: until));
    await _wait();
    _maybeFail();
    _set([id], (n) => n.copyWith(snoozedUntil: () => until));
    return items.firstWhere((n) => n.id == id);
  }

  @override
  Future<int> archive(
    String workspaceId,
    List<String> ids, {
    required bool archived,
  }) async {
    archives.add((ids: ids, archived: archived));
    await _wait();
    _maybeFail();
    _set(ids, (n) => n.copyWith(archivedAt: () => archived ? now() : null));
    return _unread(workspaceId);
  }

  @override
  Future<int> unreadCount(String workspaceId) async {
    await _wait();
    if (failReads) throw const InboxException(InboxFailure.network);
    return _unread(workspaceId);
  }

  @override
  Future<Prefs> prefs() async {
    prefsReads++;
    await _wait();
    if (failReads) throw const InboxException(InboxFailure.network);
    return prefsValue;
  }

  @override
  Future<Prefs> setPref(
    String eventType, {
    required bool inbox,
    required bool push,
    required EmailMode email,
  }) async {
    final row = PrefRow(
      eventType: eventType,
      label: prefsValue.of(eventType)?.label ?? eventType,
      inbox: inbox,
      push: push,
      email: email,
    );
    prefSets.add(row);
    await _wait();
    _maybeFail();
    prefsValue = Prefs([
      for (final r in prefsValue.rows)
        if (r.eventType == eventType) row else r,
    ], prefsValue.settings);
    return prefsValue;
  }

  @override
  Future<Prefs> setSettings(InboxSettings settings) async {
    settingsSets.add(settings);
    await _wait();
    _maybeFail();
    prefsValue = Prefs(prefsValue.rows, settings);
    return prefsValue;
  }

  @override
  Future<WatchState> watchState(
    String workspaceId,
    String projectId,
    String taskId,
  ) async {
    await _wait();
    if (failReads) throw const InboxException(InboxFailure.network);
    return watchStates[taskId] ?? const WatchState(watcherCount: 1);
  }

  @override
  Future<WatchState> watch(
    String workspaceId,
    String projectId,
    String taskId, {
    required bool on,
  }) async {
    watchCalls.add((task: taskId, on: on));
    await _wait();
    _maybeFail();
    final before = watchStates[taskId] ?? const WatchState(watcherCount: 1);
    return watchStates[taskId] = WatchState(
      watching: on,
      watcherCount: before.watcherCount + (on ? 1 : -1),
    );
  }

  @override
  Future<void> registerDevice(String platform, String token) async {
    registered.add((platform: platform, token: token));
  }

  @override
  Future<void> unregisterDevice(String token) async {
    unregistered.add(token);
  }
}

/// Records what would have been shown to the person by the system.
class FakeLocalNotifier extends LocalNotifier {
  FakeLocalNotifier({this.grant = true});

  bool grant;
  var permissionAsks = 0;
  final shown = <({int id, String title, String body, String payload})>[];

  @override
  Future<bool> requestPermission() async {
    permissionAsks++;
    return grant;
  }

  @override
  Future<void> show({
    required int id,
    required String title,
    required String body,
    String payload = '',
  }) async {
    shown.add((id: id, title: title, body: body, payload: payload));
  }

  /// The ongoing notifications now showing, by id (the timer's).
  final ongoing = <int, ({String title, String body, DateTime since})>{};

  @override
  Future<void> showOngoing({
    required int id,
    required String title,
    required String body,
    required DateTime since,
    String payload = '',
  }) async {
    ongoing[id] = (title: title, body: body, since: since);
  }

  @override
  Future<void> cancel(int id) async => ongoing.remove(id);
}

class FakePushTokenSource implements PushTokenSource {
  FakePushTokenSource([this.value]);

  PushToken? value;

  @override
  Future<PushToken?> token() async => value;
}
