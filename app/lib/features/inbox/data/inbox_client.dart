import 'package:grpc/grpc.dart' show GrpcError, StatusCode;
import 'package:grpc/grpc_connection_interface.dart' show ClientChannelBase;

import 'package:taskforge/core/auth/auth_session.dart';
import 'package:taskforge/core/workspace/scoped_requests.dart';
import 'package:taskforge/features/inbox/domain/inbox.dart';
import 'package:taskforge/features/tasks/data/tasks_client.dart'
    show mapTaskError;
import 'package:taskforge/features/tasks/domain/tasks.dart' show TaskFailure;
import 'package:taskforge/gen/infrastructure/inbox/grpc/inbox.pbgrpc.dart'
    as pb;

abstract interface class InboxClient {
  Future<InboxPage> list(
    String workspaceId,
    InboxFilter filter, {
    String before = '',
    int pageSize = 30,
  });

  /// Marks [ids] (or everything with [all]) read, or unread; returns what is
  /// unread now in the workspace.
  Future<int> markRead(
    String workspaceId, {
    List<String> ids = const [],
    bool all = false,
    bool read = true,
  });

  /// Hides the notification until [until]; null brings it back.
  Future<InboxNotification> snooze(
    String workspaceId,
    String id,
    DateTime? until,
  );

  Future<int> archive(
    String workspaceId,
    List<String> ids, {
    required bool archived,
  });

  /// Unread in [workspaceId], or in every workspace when it is empty.
  Future<int> unreadCount(String workspaceId);

  Future<Prefs> prefs();
  Future<Prefs> setPref(
    String eventType, {
    required bool inbox,
    required bool push,
    required EmailMode email,
  });
  Future<Prefs> setSettings(InboxSettings settings);

  Future<WatchState> watchState(
    String workspaceId,
    String projectId,
    String taskId,
  );
  Future<WatchState> watch(
    String workspaceId,
    String projectId,
    String taskId, {
    required bool on,
  });

  Future<void> registerDevice(String platform, String token);
  Future<void> unregisterDevice(String token);
}

/// Maps whatever a call threw to what the screens understand.
InboxException mapInboxError(Object error) {
  if (error is InboxException) return error;
  if (error is GrpcError && error.code == StatusCode.invalidArgument) {
    final message = error.message ?? '';
    return InboxException(
      InboxFailure.invalid,
      detail: message.replaceFirst(RegExp(r'^[A-Z][A-Z0-9_]*: '), ''),
    );
  }
  final task = mapTaskError(error);
  return InboxException(switch (task.failure) {
    TaskFailure.denied => InboxFailure.denied,
    TaskFailure.forbidden => InboxFailure.forbidden,
    TaskFailure.invalid => InboxFailure.invalid,
    TaskFailure.notFound => InboxFailure.notFound,
    TaskFailure.network => InboxFailure.network,
    _ => InboxFailure.other,
  }, detail: task.detail);
}

InboxNotification notificationFromPb(pb.Notification n) => InboxNotification(
  id: n.id,
  workspaceId: n.workspaceId,
  type: n.type,
  taskId: n.taskId,
  projectId: n.projectId,
  actorId: n.actorId,
  actorName: n.actorName,
  payload: parsePayload(n.payload),
  count: n.count < 1 ? 1 : n.count,
  createdAt: parseTime(n.createdAt) ?? DateTime.now(),
  updatedAt: parseTime(n.updatedAt) ?? DateTime.now(),
  readAt: parseTime(n.readAt),
  snoozedUntil: parseTime(n.snoozedUntil),
  archivedAt: parseTime(n.archivedAt),
);

Prefs prefsFromPb(pb.PrefsAnswer a) => Prefs(
  List.unmodifiable([
    for (final r in a.prefs)
      PrefRow(
        eventType: r.eventType,
        label: r.label,
        inbox: r.inbox,
        push: r.push,
        email: EmailMode.of(r.emailMode),
      ),
  ]),
  InboxSettings(
    timezone: a.settings.timezone.isEmpty ? 'UTC' : a.settings.timezone,
    quietStart: a.settings.quietStart,
    quietEnd: a.settings.quietEnd,
    digestHour: a.settings.digestHour,
  ),
);

WatchState _watchFromPb(pb.WatchState s) =>
    WatchState(watching: s.watching, watcherCount: s.watcherCount);

class GrpcInboxClient implements InboxClient {
  GrpcInboxClient(ClientChannelBase channel, this._session)
    : _inbox = pb.InboxControllerClient(channel),
      _prefs = pb.PrefControllerClient(channel),
      _watchers = pb.WatcherControllerClient(channel),
      _devices = pb.DeviceControllerClient(channel);

  final pb.InboxControllerClient _inbox;
  final pb.PrefControllerClient _prefs;
  final pb.WatcherControllerClient _watchers;
  final pb.DeviceControllerClient _devices;
  final AuthSession _session;

  late final _options = scopedCallOptions(_session, () => null);

  Future<T> _run<T>(Future<T> Function() call) async {
    try {
      try {
        return await call();
      } on GrpcError catch (e) {
        if (e.code != StatusCode.unauthenticated) rethrow;
        if (await _session.forceRefresh() == null) rethrow;
        return await call();
      }
    } on Object catch (e) {
      throw mapInboxError(e);
    }
  }

  @override
  Future<InboxPage> list(
    String workspaceId,
    InboxFilter filter, {
    String before = '',
    int pageSize = 30,
  }) => _run(() async {
    final page = await _inbox.list(
      pb.InboxListRequest(
        workspaceId: workspaceId,
        filter: filter.wire,
        before: before,
        pageSize: pageSize,
      ),
      options: _options,
    );
    return InboxPage(
      List.unmodifiable(page.notifications.map(notificationFromPb)),
      page.cursor,
      page.unreadCount,
    );
  });

  @override
  Future<int> markRead(
    String workspaceId, {
    List<String> ids = const [],
    bool all = false,
    bool read = true,
  }) => _run(
    () async => (await _inbox.markRead(
      pb.MarkReadRequest(
        workspaceId: workspaceId,
        ids: ids,
        all: all,
        read: read,
      ),
      options: _options,
    )).count,
  );

  @override
  Future<InboxNotification> snooze(
    String workspaceId,
    String id,
    DateTime? until,
  ) => _run(
    () async => notificationFromPb(
      await _inbox.snooze(
        pb.SnoozeRequest(
          workspaceId: workspaceId,
          id: id,
          until: until == null ? '' : _withOffset(until),
        ),
        options: _options,
      ),
    ),
  );

  @override
  Future<int> archive(
    String workspaceId,
    List<String> ids, {
    required bool archived,
  }) => _run(
    () async => (await _inbox.archive(
      pb.ArchiveRequest(workspaceId: workspaceId, ids: ids, archived: archived),
      options: _options,
    )).count,
  );

  @override
  Future<int> unreadCount(String workspaceId) => _run(
    () async => (await _inbox.unreadCount(
      pb.UnreadCountRequest(workspaceId: workspaceId),
      options: _options,
    )).count,
  );

  @override
  Future<Prefs> prefs() => _run(
    () async =>
        prefsFromPb(await _prefs.get(pb.PrefsGetRequest(), options: _options)),
  );

  @override
  Future<Prefs> setPref(
    String eventType, {
    required bool inbox,
    required bool push,
    required EmailMode email,
  }) => _run(
    () async => prefsFromPb(
      await _prefs.set(
        pb.PrefSetRequest(
          eventType: eventType,
          inbox: inbox,
          push: push,
          emailMode: email.wire,
        ),
        options: _options,
      ),
    ),
  );

  @override
  Future<Prefs> setSettings(InboxSettings settings) => _run(
    () async => prefsFromPb(
      await _prefs.setSettings(
        pb.SettingsSetRequest(
          timezone: settings.timezone,
          quietStart: settings.quietStart,
          quietEnd: settings.quietEnd,
          digestHour: settings.digestHour,
        ),
        options: _options,
      ),
    ),
  );

  @override
  Future<WatchState> watchState(
    String workspaceId,
    String projectId,
    String taskId,
  ) => _run(
    () async => _watchFromPb(
      await _watchers.get(
        pb.WatchGetRequest(
          workspaceId: workspaceId,
          projectId: projectId,
          taskId: taskId,
        ),
        options: _options,
      ),
    ),
  );

  @override
  Future<WatchState> watch(
    String workspaceId,
    String projectId,
    String taskId, {
    required bool on,
  }) => _run(() async {
    if (on) {
      return _watchFromPb(
        await _watchers.add(
          pb.WatchAddRequest(
            workspaceId: workspaceId,
            projectId: projectId,
            taskId: taskId,
          ),
          options: _options,
        ),
      );
    }
    return _watchFromPb(
      await _watchers.remove(
        pb.WatchRemoveRequest(
          workspaceId: workspaceId,
          projectId: projectId,
          taskId: taskId,
        ),
        options: _options,
      ),
    );
  });

  @override
  Future<void> registerDevice(String platform, String token) => _run(
    () => _devices.register(
      pb.DeviceRegisterRequest(platform: platform, token: token),
      options: _options,
    ),
  );

  @override
  Future<void> unregisterDevice(String token) => _run(
    () => _devices.unregister(
      pb.DeviceUnregisterRequest(token: token),
      options: _options,
    ),
  );
}

/// An ISO 8601 time with its UTC offset ("2026-11-12T09:00:00+03:30"), as the
/// server wants it: a bare local time would be read in the wrong zone.
String _withOffset(DateTime at) => at.toUtc().toIso8601String();
