import 'package:taskforge/features/automations/data/automations_client.dart';
import 'package:taskforge/features/automations/domain/automations.dart';

Automation rule(
  String id,
  String name, {
  bool enabled = true,
  Trigger trigger = const Trigger(type: TriggerType.statusChanged),
  List<RuleAction>? actions,
  String condition = '',
  String disabledReason = '',
  int version = 1,
  String lastRunStatus = '',
}) => Automation(
  id: id,
  projectId: 'p1',
  name: name,
  enabled: enabled,
  trigger: trigger,
  condition: condition,
  actions:
      actions ??
      const [RuleAction(type: ActionType.addComment, text: 'Hello {key}')],
  disabledReason: disabledReason,
  version: version,
  lastRunStatus: lastRunStatus,
  lastRunAt: lastRunStatus.isEmpty ? '' : '2026-11-12 10:00',
);

AutomationRun run(
  String id, {
  String ruleId = 'a1',
  String name = 'Rule one',
  RunStatus status = RunStatus.succeeded,
  String explanation = '',
  String error = '',
  List<RunStep> steps = const [],
  String startedAt = '2026-11-12 10:00',
}) => AutomationRun(
  id: id,
  automationId: ruleId,
  automationName: name,
  status: status,
  rawStatus: status.wire,
  taskKey: 'WEB-1',
  startedAt: startedAt,
  explanation: explanation,
  error: error,
  steps: steps,
);

/// An in-memory automations server for one project.
class FakeAutomationsClient implements AutomationsClient {
  FakeAutomationsClient({
    List<Automation> rules = const [],
    List<AutomationRun> runs = const [],
  }) : rules = [...rules],
       allRuns = [...runs];

  final List<Automation> rules;
  final List<AutomationRun> allRuns;
  final created = <RuleDraft>[];
  final updated = <({List<String> fields, RuleDraft draft})>[];
  final toggles = <String>[];
  final deleted = <String>[];
  final dryRuns = <String>[];
  final runRequests = <({String before, int limit})>[];
  AutomationException? failNext;
  DryRunResult dryAnswer = const DryRunResult(wouldRun: true);
  var _n = 0;

  void _maybeFail() {
    final f = failNext;
    if (f != null) {
      failNext = null;
      throw f;
    }
  }

  Automation _find(String id) => rules.firstWhere(
    (r) => r.id == id,
    orElse: () => throw const AutomationException(AutomationFailure.notFound),
  );

  void _replace(Automation next) {
    final i = rules.indexWhere((r) => r.id == next.id);
    rules[i] = next;
  }

  @override
  Future<List<Automation>> list(String workspaceId, String projectId) async {
    _maybeFail();
    return List.unmodifiable(rules);
  }

  @override
  Future<Automation> create(
    String workspaceId,
    String projectId,
    RuleDraft draft, {
    bool enabled = false,
  }) async {
    _maybeFail();
    created.add(draft);
    final made = Automation(
      id: 'n${++_n}',
      projectId: projectId,
      name: draft.name.trim(),
      enabled: enabled,
      trigger: draft.trigger,
      condition: draft.condition.trim(),
      actions: draft.actions,
    );
    rules.add(made);
    return made;
  }

  @override
  Future<Automation> update(
    String workspaceId,
    Automation rule,
    RuleDraft draft,
    List<String> fields,
  ) async {
    _maybeFail();
    final current = _find(rule.id);
    if (current.version != rule.version) {
      throw const AutomationException(AutomationFailure.conflict);
    }
    updated.add((fields: fields, draft: draft));
    final next = Automation(
      id: current.id,
      projectId: current.projectId,
      name: draft.name.trim(),
      enabled: current.enabled,
      trigger: draft.trigger,
      condition: draft.condition.trim(),
      actions: draft.actions,
      version: current.version + 1,
    );
    _replace(next);
    return next;
  }

  @override
  Future<Automation> toggle(
    String workspaceId,
    String projectId,
    String automationId, {
    required bool enabled,
  }) async {
    _maybeFail();
    final current = _find(automationId);
    if (enabled && current.disabledReason.isNotEmpty) {
      throw AutomationException(
        AutomationFailure.invalid,
        detail: 'Fix it first: ${current.disabledReason}',
      );
    }
    toggles.add('$automationId:$enabled');
    final next = Automation(
      id: current.id,
      projectId: current.projectId,
      name: current.name,
      enabled: enabled,
      trigger: current.trigger,
      condition: current.condition,
      actions: current.actions,
      version: current.version + 1,
    );
    _replace(next);
    return next;
  }

  @override
  Future<void> delete(
    String workspaceId,
    String projectId,
    String automationId,
  ) async {
    _maybeFail();
    _find(automationId);
    deleted.add(automationId);
    rules.removeWhere((r) => r.id == automationId);
  }

  @override
  Future<DryRunResult> dryRun(
    String workspaceId,
    String projectId,
    String automationId,
    String taskId,
  ) async {
    _maybeFail();
    dryRuns.add('$automationId:$taskId');
    return dryAnswer;
  }

  @override
  Future<List<AutomationRun>> runs(
    String workspaceId,
    String projectId, {
    String automationId = '',
    String taskId = '',
    String status = '',
    String before = '',
    int limit = 0,
  }) async {
    _maybeFail();
    runRequests.add((before: before, limit: limit));
    // `before` is `<started_at>#<run id>`: runs sharing a time page on by id.
    final cut = before.split('#');
    bool older(AutomationRun r) {
      final byTime = r.startedAt.compareTo(cut.first);
      return byTime < 0 ||
          (byTime == 0 && cut.length > 1 && r.id.compareTo(cut[1]) < 0);
    }

    final rows = [
      for (final r in allRuns)
        if ((automationId.isEmpty || r.automationId == automationId) &&
            (before.isEmpty || older(r)))
          r,
    ];
    return List.unmodifiable(limit > 0 ? rows.take(limit) : rows);
  }
}
