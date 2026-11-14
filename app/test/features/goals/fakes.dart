import 'package:taskforge/features/goals/data/goals_client.dart';
import 'package:taskforge/features/goals/domain/goals.dart';

/// A goals client for screens that only show "Contributes to" (the task page): no goal counts
/// any task, and the catalogue is empty.
class FakeGoalsClient implements GoalsClient {
  FakeGoalsClient({this.contributions = const []});

  List<Contribution> contributions;

  @override
  Future<List<Contribution>> forTask(String workspaceId, String taskId) async =>
      contributions;

  @override
  Future<GoalCatalog> list(String workspaceId) async => GoalCatalog.empty;

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('FakeGoalsClient.${invocation.memberName}');
}
