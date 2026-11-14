import 'package:grpc/grpc.dart' show GrpcError, StatusCode;
import 'package:grpc/grpc_connection_interface.dart' show ClientChannelBase;

import 'package:taskforge/core/auth/auth_session.dart';
import 'package:taskforge/core/workspace/scoped_requests.dart';
import 'package:taskforge/features/workload/domain/workload.dart';
import 'package:taskforge/gen/infrastructure/workload/grpc/workload.pbgrpc.dart'
    as pb;

/// Capacity, time off, holidays and the workload grid over gRPC. Moving or
/// reassigning a task is `Tasks.Update` (the tasks client), not here.
abstract interface class WorkloadClient {
  Future<WorkloadData> get(String workspaceId, WorkloadQuery query);
  Future<List<Capacity>> capacities(String workspaceId, {String userId = ''});
  Future<Capacity> setCapacity(
    String workspaceId,
    String userId,
    double hoursPerDay,
    List<int> workingDays,
  );
  Future<List<TimeOff>> listTimeOff(String workspaceId, {String userId = ''});
  Future<TimeOff> saveTimeOff(
    String workspaceId, {
    String id = '',
    required String userId,
    required DateTime start,
    required DateTime end,
    required TimeOffKind kind,
    required String note,
  });
  Future<void> deleteTimeOff(String workspaceId, String id);
  Future<List<Holiday>> holidays(String workspaceId);
  Future<Holiday> saveHoliday(
    String workspaceId, {
    String id = '',
    required DateTime date,
    required String name,
  });
  Future<void> deleteHoliday(String workspaceId, String id);
}

WorkloadException mapWorkloadError(Object error) {
  if (error is WorkloadException) return error;
  if (error is GrpcError) {
    final message = (error.message ?? '').replaceFirst(
      RegExp(r'^[A-Z][A-Z0-9_]*: '),
      '',
    );
    return switch (error.code) {
      StatusCode.invalidArgument => WorkloadException(
        WorkloadFailure.invalid,
        detail: message,
      ),
      StatusCode.alreadyExists => WorkloadException(
        WorkloadFailure.invalid,
        detail: message,
      ),
      StatusCode.aborted => const WorkloadException(WorkloadFailure.conflict),
      StatusCode.permissionDenied => const WorkloadException(
        WorkloadFailure.denied,
      ),
      StatusCode.notFound => const WorkloadException(WorkloadFailure.notFound),
      StatusCode.unavailable || StatusCode.deadlineExceeded =>
        const WorkloadException(WorkloadFailure.network),
      _ => const WorkloadException(WorkloadFailure.other),
    };
  }
  return const WorkloadException(WorkloadFailure.other);
}

Capacity capacityFromPb(pb.Capacity c) => Capacity(
  userId: c.userId,
  hoursPerDay: double.tryParse(c.hoursPerDay) ?? 8,
  workingDays: List.unmodifiable(c.workingDays),
  isSet: c.isSet,
);

TimeOff timeOffFromPb(pb.TimeOff t) => TimeOff(
  id: t.id,
  userId: t.userId,
  start: parseDay(t.startDate) ?? DateTime.utc(2000),
  end: parseDay(t.endDate) ?? DateTime.utc(2000),
  kind: TimeOffKind.parse(t.kind),
  note: t.note,
);

LoadTask loadTaskFromPb(pb.LoadTask t) => LoadTask(
  id: t.taskId,
  projectId: t.projectId,
  displayId: t.displayId,
  title: t.title,
  version: t.version,
  start: parseDay(t.startDate),
  due: parseDay(t.dueDate),
  estimateSec: t.estimateSec,
  assigneeIds: List.unmodifiable(t.assigneeIds),
  own: Map.unmodifiable({for (final o in t.own) o.userId: o.seconds}),
  reason: t.reason.isEmpty ? null : UnplacedReason.parse(t.reason),
);

WorkloadData workloadFromPb(pb.WorkloadAnswer a) => WorkloadData(
  start: parseDay(a.rangeStart) ?? DateTime.utc(2000),
  end: parseDay(a.rangeEnd) ?? DateTime.utc(2000),
  canSeeAll: a.canSeeAll,
  people: List.unmodifiable([
    for (final p in a.people)
      PersonLoad(
        userId: p.userId,
        capacity: capacityFromPb(p.capacity),
        timeOff: List.unmodifiable([
          for (final o in p.timeOff)
            TimeOff(
              id: '',
              userId: p.userId,
              start: parseDay(o.startDate) ?? DateTime.utc(2000),
              end: parseDay(o.endDate) ?? DateTime.utc(2000),
              kind: TimeOffKind.parse(o.kind),
              note: '',
            ),
        ]),
        days: Map.unmodifiable({
          for (final d in p.days)
            if (parseDay(d.date) != null)
              parseDay(d.date)!: List<Contribution>.unmodifiable([
                for (final c in d.contributions)
                  Contribution(c.taskId, c.seconds, warning: c.warning),
              ]),
        }),
      ),
  ]),
  tasks: Map.unmodifiable({
    for (final t in a.tasks) t.taskId: loadTaskFromPb(t),
  }),
  unplaced: List.unmodifiable(a.unestimated.map(loadTaskFromPb)),
  holidays: {
    for (final h in a.holidays)
      if (parseDay(h) != null) parseDay(h)!,
  },
  truncated: a.truncated,
);

class GrpcWorkloadClient implements WorkloadClient {
  GrpcWorkloadClient(ClientChannelBase channel, this._session)
    : _workload = pb.WorkloadControllerClient(channel),
      _capacity = pb.CapacityControllerClient(channel),
      _timeOff = pb.TimeOffControllerClient(channel),
      _holidays = pb.HolidayControllerClient(channel);

  final pb.WorkloadControllerClient _workload;
  final pb.CapacityControllerClient _capacity;
  final pb.TimeOffControllerClient _timeOff;
  final pb.HolidayControllerClient _holidays;
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
      throw mapWorkloadError(e);
    }
  }

  @override
  Future<WorkloadData> get(String workspaceId, WorkloadQuery query) =>
      _run(() async {
        final (first, last) = query.range;
        final r = await _workload.get(
          pb.WorkloadGetRequest(
            workspaceId: workspaceId,
            rangeStart: isoDay(first),
            rangeEnd: isoDay(last),
            projectIds: query.projectIds,
            userIds: query.userIds,
          ),
          options: _options,
        );
        return workloadFromPb(r);
      });

  @override
  Future<List<Capacity>> capacities(String workspaceId, {String userId = ''}) =>
      _run(() async {
        final r = await _capacity.get(
          pb.CapacityGetRequest(workspaceId: workspaceId, userId: userId),
          options: _options,
        );
        return List.unmodifiable(r.capacities.map(capacityFromPb));
      });

  @override
  Future<Capacity> setCapacity(
    String workspaceId,
    String userId,
    double hoursPerDay,
    List<int> workingDays,
  ) => _run(() async {
    final r = await _capacity.set(
      pb.CapacitySetRequest(
        workspaceId: workspaceId,
        userId: userId,
        hoursPerDay: hoursPerDay.toString(),
        workingDays: workingDays,
      ),
      options: _options,
    );
    return capacityFromPb(r.capacity);
  });

  @override
  Future<List<TimeOff>> listTimeOff(String workspaceId, {String userId = ''}) =>
      _run(() async {
        final r = await _timeOff.list(
          pb.TimeOffListRequest(workspaceId: workspaceId, userId: userId),
          options: _options,
        );
        return List.unmodifiable(r.entries.map(timeOffFromPb));
      });

  @override
  Future<TimeOff> saveTimeOff(
    String workspaceId, {
    String id = '',
    required String userId,
    required DateTime start,
    required DateTime end,
    required TimeOffKind kind,
    required String note,
  }) => _run(() async {
    final r = id.isEmpty
        ? await _timeOff.create(
            pb.TimeOffCreateRequest(
              workspaceId: workspaceId,
              userId: userId,
              startDate: isoDay(start),
              endDate: isoDay(end),
              kind: kind.wire,
              note: note.trim(),
            ),
            options: _options,
          )
        : await _timeOff.update(
            pb.TimeOffUpdateRequest(
              workspaceId: workspaceId,
              timeOffId: id,
              startDate: isoDay(start),
              endDate: isoDay(end),
              kind: kind.wire,
              note: note.trim(),
            ),
            options: _options,
          );
    return timeOffFromPb(r.entry);
  });

  @override
  Future<void> deleteTimeOff(String workspaceId, String id) => _run(() async {
    await _timeOff.delete(
      pb.TimeOffDeleteRequest(workspaceId: workspaceId, timeOffId: id),
      options: _options,
    );
  });

  @override
  Future<List<Holiday>> holidays(String workspaceId) => _run(() async {
    final r = await _holidays.list(
      pb.HolidayListRequest(workspaceId: workspaceId),
      options: _options,
    );
    return List.unmodifiable([
      for (final h in r.holidays)
        Holiday(
          id: h.id,
          date: parseDay(h.date) ?? DateTime.utc(2000),
          name: h.name,
        ),
    ]);
  });

  @override
  Future<Holiday> saveHoliday(
    String workspaceId, {
    String id = '',
    required DateTime date,
    required String name,
  }) => _run(() async {
    final r = id.isEmpty
        ? await _holidays.create(
            pb.HolidayCreateRequest(
              workspaceId: workspaceId,
              date: isoDay(date),
              name: name.trim(),
            ),
            options: _options,
          )
        : await _holidays.update(
            pb.HolidayUpdateRequest(
              workspaceId: workspaceId,
              holidayId: id,
              date: isoDay(date),
              name: name.trim(),
            ),
            options: _options,
          );
    final h = r.holiday;
    return Holiday(id: h.id, date: parseDay(h.date) ?? date, name: h.name);
  });

  @override
  Future<void> deleteHoliday(String workspaceId, String id) => _run(() async {
    await _holidays.delete(
      pb.HolidayDeleteRequest(workspaceId: workspaceId, holidayId: id),
      options: _options,
    );
  });
}
