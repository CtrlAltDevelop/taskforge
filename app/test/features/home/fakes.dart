import 'package:taskforge/features/home/data/home_client.dart';
import 'package:taskforge/features/home/domain/home.dart';

HomeTask homeTask(
  String id, {
  String project = 'p1',
  String key = 'WEB',
  int number = 1,
  String title = 'A task',
  String status = 'To do',
  String category = 'not_started',
  String due = '',
}) => HomeTask(
  taskId: id,
  projectId: project,
  projectKey: key,
  number: number,
  title: title,
  statusName: status,
  statusCategory: category,
  dueDate: due,
);

/// Home, My work and the checklist without a server.
class FakeHomeClient implements HomeClient, OnboardingClient {
  FakeHomeClient({
    this.summaryValue = const HomeSummary(),
    this.assigned = const [],
    this.onboarding = const OnboardingState(),
  });

  HomeSummary summaryValue;
  Object? summaryError;
  Object? assignedError;
  Object? onboardingError;
  Object? myWorkError;
  Object? starterError;
  Object? pinError;
  List<MyWorkItem> assigned;
  OnboardingState onboarding;

  /// Pages of My work by cursor ('' first); a page's next cursor names the next.
  Map<String, MyWorkPage> pages = {};

  final calls = <String>[];
  final myWorkQueries = <MyWorkQuery>[];
  int summaryCalls = 0;
  String? lastToday;

  @override
  Future<HomeSummary> summary(
    String workspaceId, {
    required String today,
    required int utcOffsetMinutes,
  }) async {
    summaryCalls++;
    lastToday = today;
    if (summaryError != null) throw summaryError!;
    return summaryValue;
  }

  @override
  Future<MyWorkPage> myWork(
    String workspaceId, {
    required String today,
    MyWorkQuery query = const MyWorkQuery(),
    String cursor = '',
    int limit = 25,
  }) async {
    myWorkQueries.add(query);
    if (query.relation == MyWorkRelation.assigned && limit != 25) {
      if (assignedError != null) throw assignedError!;
      return MyWorkPage(assigned);
    }
    if (myWorkError != null) throw myWorkError!;
    return pages[cursor] ?? MyWorkPage(assigned);
  }

  @override
  Future<void> recordRecent(String workspaceId, String taskId) async =>
      calls.add('recent $taskId');

  @override
  Future<void> pinDashboard(
    String workspaceId,
    String dashboardId, {
    required bool pinned,
  }) async {
    if (pinError != null) throw pinError!;
    calls.add('pin $dashboardId $pinned');
  }

  @override
  Future<OnboardingState> get(String workspaceId) async {
    if (onboardingError != null) throw onboardingError!;
    return onboarding;
  }

  OnboardingState _tick(String step) => onboarding = OnboardingState(
    steps: {...onboarding.steps, step: true},
    dismissed: onboarding.dismissed,
    complete:
        onboarding.steps.length == checklistSteps.length &&
        {...onboarding.steps, step: true}.values.every((v) => v),
    visible: onboarding.visible,
    sampleProjectId: onboarding.sampleProjectId,
    sampleCount: onboarding.sampleCount,
    starters: onboarding.starters,
  );

  @override
  Future<OnboardingState> completeStep(String workspaceId, String step) async {
    calls.add('step $step');
    return _tick(step);
  }

  @override
  Future<OnboardingState> dismiss(String workspaceId) async {
    calls.add('dismiss');
    return onboarding = OnboardingState(
      steps: onboarding.steps,
      dismissed: true,
      sampleProjectId: onboarding.sampleProjectId,
      sampleCount: onboarding.sampleCount,
      starters: onboarding.starters,
    );
  }

  @override
  Future<({String projectId, int taskCount})> applyStarter(
    String workspaceId,
    String starter, {
    String name = '',
    String key = '',
  }) async {
    calls.add('starter $starter');
    if (starterError != null) throw starterError!;
    return (projectId: 'p-new', taskCount: 4);
  }

  @override
  Future<int> deleteSamples(String workspaceId) async {
    calls.add('delete-samples');
    final n = onboarding.sampleCount;
    onboarding = OnboardingState(
      steps: onboarding.steps,
      dismissed: onboarding.dismissed,
      complete: onboarding.complete,
      visible: onboarding.visible,
      sampleProjectId: onboarding.sampleProjectId,
    );
    return n;
  }
}
