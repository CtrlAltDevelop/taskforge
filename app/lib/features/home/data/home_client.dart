import 'package:grpc/grpc.dart' show GrpcError, StatusCode;
import 'package:grpc/grpc_connection_interface.dart' show ClientChannelBase;

import 'package:taskforge/core/auth/auth_session.dart';
import 'package:taskforge/core/offline/read_cache.dart';
import 'package:taskforge/core/workspace/scoped_requests.dart';
import 'package:taskforge/features/home/domain/home.dart';
import 'package:taskforge/gen/infrastructure/home/grpc/home.pbgrpc.dart' as pb;

/// Home, My work and the first-run checklist over gRPC.
abstract interface class HomeClient {
  /// The Home summary for [today] (ISO date) in the viewer's time zone.
  Future<HomeSummary> summary(
    String workspaceId, {
    required String today,
    required int utcOffsetMinutes,
  });

  Future<MyWorkPage> myWork(
    String workspaceId, {
    required String today,
    MyWorkQuery query = const MyWorkQuery(),
    String cursor = '',
    int limit = 25,
  });

  Future<void> recordRecent(String workspaceId, String taskId);
  Future<void> pinDashboard(
    String workspaceId,
    String dashboardId, {
    required bool pinned,
  });
}

abstract interface class OnboardingClient {
  Future<OnboardingState> get(String workspaceId);
  Future<OnboardingState> completeStep(String workspaceId, String step);
  Future<OnboardingState> dismiss(String workspaceId);

  /// Creates the starter's project; returns its id.
  Future<({String projectId, int taskCount})> applyStarter(
    String workspaceId,
    String starter, {
    String name = '',
    String key = '',
  });

  /// Sends the caller's sample tasks to the trash; returns how many.
  Future<int> deleteSamples(String workspaceId);
}

HomeException mapHomeError(Object error) {
  if (error is HomeException) return error;
  if (error is GrpcError) {
    final message = (error.message ?? '').replaceFirst(
      RegExp(r'^[A-Z][A-Z0-9_]*: '),
      '',
    );
    return switch (error.code) {
      StatusCode.invalidArgument => HomeException(
        HomeFailure.invalid,
        detail: message,
      ),
      StatusCode.permissionDenied => const HomeException(HomeFailure.denied),
      StatusCode.notFound => const HomeException(HomeFailure.notFound),
      StatusCode.unavailable ||
      StatusCode.deadlineExceeded => const HomeException(HomeFailure.network),
      _ => const HomeException(HomeFailure.other),
    };
  }
  if (isUnreachable(error)) return const HomeException(HomeFailure.network);
  return const HomeException(HomeFailure.other);
}

HomeTask homeTaskFromPb(pb.HomeTask t) => HomeTask(
  taskId: t.taskId,
  projectId: t.projectId,
  projectKey: t.projectKey,
  number: t.number,
  title: t.title,
  statusName: t.statusName,
  statusCategory: t.statusCategory,
  priority: t.priority,
  dueDate: t.dueDate,
);

HomeSummary summaryFromPb(pb.HomeSummary s) => HomeSummary(
  todayCount: s.todayCount,
  overdueCount: s.overdueCount,
  inProgressCount: s.inProgressCount,
  dueItems: List.unmodifiable(s.dueItems.map(homeTaskFromPb)),
  inProgressItems: List.unmodifiable(s.inProgressItems.map(homeTaskFromPb)),
  recent: List.unmodifiable(s.recent.map(homeTaskFromPb)),
  mentions: List.unmodifiable(
    s.mentions.map(
      (m) => HomeMention(
        id: m.id,
        type: m.type,
        taskId: m.taskId,
        actorId: m.actorId,
        createdAt: m.createdAt,
        read: m.read,
        payloadJson: m.payloadJson,
      ),
    ),
  ),
  unreadNotifications: s.unreadNotifications,
  unreadChat: s.unreadChat,
  week: List.unmodifiable(
    s.week.map((d) => HomeDay(date: d.date, seconds: d.seconds)),
  ),
  pinned: List.unmodifiable(
    s.pinnedDashboards.map(
      (p) => HomePin(
        dashboardId: p.dashboardId,
        name: p.name,
        projectId: p.projectId,
      ),
    ),
  ),
  computedAt: s.computedAt,
);

MyWorkPage myWorkFromPb(pb.HomeMyWork r) => MyWorkPage(
  List.unmodifiable(
    r.tasks.map(
      (t) => MyWorkItem(
        task: homeTaskFromPb(t.task),
        assigned: t.assigned,
        watching: t.watching,
      ),
    ),
  ),
  nextCursor: r.nextCursor,
);

OnboardingState onboardingFromPb(pb.OnboardingState s) => OnboardingState(
  steps: Map.unmodifiable({for (final x in s.steps) x.step: x.done}),
  dismissed: s.dismissed,
  complete: s.complete,
  visible: s.visible,
  sampleProjectId: s.sampleProjectId,
  sampleCount: s.sampleCount,
  starters: List.unmodifiable(
    s.starters.map(
      (x) => OnboardingStarter(
        key: x.key,
        name: x.name,
        description: x.description,
      ),
    ),
  ),
);

class GrpcHomeClient implements HomeClient, OnboardingClient {
  GrpcHomeClient(ClientChannelBase channel, this._session, {this.cache})
    : _home = pb.HomeControllerClient(channel),
      _onboarding = pb.OnboardingControllerClient(channel);

  final pb.HomeControllerClient _home;
  final pb.OnboardingControllerClient _onboarding;
  final AuthSession _session;
  final ReadCache? cache;

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
      throw mapHomeError(e);
    }
  }

  @override
  Future<HomeSummary> summary(
    String workspaceId, {
    required String today,
    required int utcOffsetMinutes,
  }) => _run(() async {
    final r = await readThrough(
      cache,
      workspaceId,
      'home.summary',
      () => _home.summary(
        pb.HomeSummaryRequest(
          workspaceId: workspaceId,
          today: today,
          utcOffsetMinutes: utcOffsetMinutes,
        ),
        options: _options,
      ),
      pb.HomeSummary.fromBuffer,
    );
    return summaryFromPb(r);
  });

  @override
  Future<MyWorkPage> myWork(
    String workspaceId, {
    required String today,
    MyWorkQuery query = const MyWorkQuery(),
    String cursor = '',
    int limit = 25,
  }) => _run(() async {
    Future<pb.HomeMyWork> call() => _home.myWork(
      pb.HomeMyWorkRequest(
        workspaceId: workspaceId,
        relation: query.relation.wire,
        includeDone: query.includeDone,
        filterAst: query.filterAst,
        today: today,
        cursor: cursor,
        limit: limit,
      ),
      options: _options,
    );
    // Only the first page of an unfiltered list is kept for offline.
    final keep = cursor.isEmpty && query.filterAst.isEmpty;
    final r = keep
        ? await readThrough(
            cache,
            workspaceId,
            'home.mywork.${query.relation.name}.${query.includeDone}',
            call,
            pb.HomeMyWork.fromBuffer,
          )
        : await call();
    return myWorkFromPb(r);
  });

  @override
  Future<void> recordRecent(String workspaceId, String taskId) => _run(
    () => _home.recordRecent(
      pb.HomeRecordRecentRequest(workspaceId: workspaceId, taskId: taskId),
      options: _options,
    ),
  );

  @override
  Future<void> pinDashboard(
    String workspaceId,
    String dashboardId, {
    required bool pinned,
  }) => _run(
    () => _home.pinDashboard(
      pb.HomePinDashboardRequest(
        workspaceId: workspaceId,
        dashboardId: dashboardId,
        pinned: pinned,
      ),
      options: _options,
    ),
  );

  @override
  Future<OnboardingState> get(String workspaceId) => _run(() async {
    final r = await _onboarding.get(
      pb.OnboardingGetRequest(workspaceId: workspaceId),
      options: _options,
    );
    return onboardingFromPb(r);
  });

  @override
  Future<OnboardingState> completeStep(String workspaceId, String step) => _run(
    () async {
      final r = await _onboarding.completeStep(
        pb.OnboardingCompleteStepRequest(workspaceId: workspaceId, step: step),
        options: _options,
      );
      return onboardingFromPb(r);
    },
  );

  @override
  Future<OnboardingState> dismiss(String workspaceId) => _run(() async {
    final r = await _onboarding.dismiss(
      pb.OnboardingDismissRequest(workspaceId: workspaceId),
      options: _options,
    );
    return onboardingFromPb(r);
  });

  @override
  Future<({String projectId, int taskCount})> applyStarter(
    String workspaceId,
    String starter, {
    String name = '',
    String key = '',
  }) => _run(() async {
    final r = await _onboarding.applyStarter(
      pb.OnboardingApplyStarterRequest(
        workspaceId: workspaceId,
        starter: starter,
        name: name,
        key: key,
      ),
      options: _options,
    );
    return (projectId: r.projectId, taskCount: r.taskCount);
  });

  @override
  Future<int> deleteSamples(String workspaceId) => _run(() async {
    final r = await _onboarding.deleteSamples(
      pb.OnboardingDeleteSamplesRequest(workspaceId: workspaceId),
      options: _options,
    );
    return r.deleted;
  });
}
