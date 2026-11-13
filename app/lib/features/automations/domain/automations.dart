import 'dart:convert';
import 'dart:ui' show Locale;

import 'package:flutter/foundation.dart';

import 'package:taskforge/l10n/gen/app_localizations.dart';

// Limits mirror the server (`spec.py`); the server stays the authority.
const maxRulesPerProject = 50;
const maxActionsPerRule = 10;
const maxAutomationName = 80;
const maxCommentText = 2000;
const maxTitleText = 500;
const maxRecipients = 20;
const maxDaysBefore = 30;
const maxRuleJsonBytes = 20000;
const customFieldPrefix = 'field:';
const todayToken = '{today}';

/// The words an action's text may hold; the server fills them in.
const placeholders = [
  '{title}',
  '{key}',
  '{status}',
  '{today}',
  '{automation}',
];
const recipientWords = ['assignees', 'owner', 'creator'];
const assignModes = ['set', 'add', 'clear'];

/// Built-in task fields a rule can watch.
const watchableFields = {
  'title': 'Title',
  'description': 'Description',
  'priority': 'Priority',
  'start_date': 'Start date',
  'due_date': 'Due date',
  'due_time': 'Due time',
  'estimate_sec': 'Estimate',
  'points': 'Points',
  'status': 'Status',
  'assignee_ids': 'Assignees',
};

/// Built-in task fields an action can set.
const settableFields = {
  'title': 'Title',
  'priority': 'Priority',
  'start_date': 'Start date',
  'due_date': 'Due date',
  'due_time': 'Due time',
  'estimate_sec': 'Estimate (seconds)',
};
const dateFields = {'start_date', 'due_date'};

enum TriggerType {
  taskCreated('task_created', 'A task is created'),
  statusChanged('status_changed', 'A status changes'),
  fieldChanged('field_changed', 'A field changes'),
  assigned('assigned', 'Someone is assigned'),
  dueDateReached('due_date_reached', 'A due date is reached'),
  commentAdded('comment_added', 'A comment is added');

  const TriggerType(this.wire, this.label);

  final String wire;
  final String label;

  /// [label] in the language of [l].
  String labelIn(AppLocalizations l) => switch (this) {
    taskCreated => l.grpMTrigTaskCreated,
    statusChanged => l.grpMTrigStatusChanged,
    fieldChanged => l.grpMTrigFieldChanged,
    assigned => l.grpMTrigAssigned,
    dueDateReached => l.grpMTrigDueDateReached,
    commentAdded => l.grpMTrigCommentAdded,
  };

  static TriggerType? tryParse(String wire) =>
      values.where((t) => t.wire == wire).firstOrNull;
}

enum ActionType {
  setField('set_field', 'Set a field'),
  setStatus('set_status', 'Set the status'),
  setAssignee('set_assignee', 'Change assignees'),
  addComment('add_comment', 'Add a comment'),
  createSubtask('create_subtask', 'Create a subtask'),
  notify('notify', 'Notify people'),
  webhook('webhook', 'Call a webhook');

  const ActionType(this.wire, this.label);

  final String wire;
  final String label;

  /// [label] in the language of [l].
  String labelIn(AppLocalizations l) => switch (this) {
    setField => l.grpMActSetField,
    setStatus => l.grpMActSetStatus,
    setAssignee => l.grpMActSetAssignee,
    addComment => l.grpMActAddComment,
    createSubtask => l.grpMActCreateSubtask,
    notify => l.grpMActNotify,
    webhook => l.grpMActWebhook,
  };

  static ActionType? tryParse(String wire) =>
      values.where((t) => t.wire == wire).firstOrNull;
}

/// The "When" card. Only the options of its [type] are used.
@immutable
class Trigger {
  const Trigger({
    this.type = TriggerType.taskCreated,
    this.toStatus = '',
    this.field = '',
    this.userId = '',
    this.daysBefore = 0,
  });

  final TriggerType type;
  final String toStatus;
  final String field;
  final String userId;
  final int daysBefore;

  Trigger copyWith({
    TriggerType? type,
    String? toStatus,
    String? field,
    String? userId,
    int? daysBefore,
  }) => Trigger(
    type: type ?? this.type,
    toStatus: toStatus ?? this.toStatus,
    field: field ?? this.field,
    userId: userId ?? this.userId,
    daysBefore: daysBefore ?? this.daysBefore,
  );

  Map<String, Object> toJson() => {
    'type': type.wire,
    ...switch (type) {
      TriggerType.statusChanged => {
        if (toStatus.isNotEmpty) 'to_status': toStatus,
      },
      TriggerType.fieldChanged => {'field': field},
      TriggerType.assigned => {if (userId.isNotEmpty) 'user_id': userId},
      TriggerType.dueDateReached => {'days_before': daysBefore},
      _ => const <String, Object>{},
    },
  };

  /// Null when [json] is not a trigger this client knows.
  static Trigger? fromJson(Object? json) {
    if (json is! Map) return null;
    final type = TriggerType.tryParse('${json['type']}');
    if (type == null) return null;
    final days = json['days_before'];
    return Trigger(
      type: type,
      toStatus: '${json['to_status'] ?? ''}',
      field: '${json['field'] ?? ''}',
      userId: '${json['user_id'] ?? ''}',
      daysBefore: days is int ? days : 0,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is Trigger && jsonEncode(toJson()) == jsonEncode(other.toJson());

  @override
  int get hashCode => jsonEncode(toJson()).hashCode;
}

/// One "Then" card. Only the options of its [type] are used.
@immutable
class RuleAction {
  const RuleAction({
    this.type = ActionType.addComment,
    this.field = '',
    this.value = '',
    this.status = '',
    this.mode = 'set',
    this.userIds = const [],
    this.text = '',
    this.to = const [],
    this.url = '',
    this.method = 'POST',
  });

  final ActionType type;

  /// set_field: a built-in name or `field:<id>`.
  final String field;
  final String value;

  /// set_status.
  final String status;

  /// set_assignee: `set`, `add` or `clear`.
  final String mode;
  final List<String> userIds;

  /// add_comment: the comment; create_subtask: the title; notify: the message.
  final String text;

  /// notify: [recipientWords] and user ids.
  final List<String> to;

  /// webhook.
  final String url;
  final String method;

  RuleAction copyWith({
    ActionType? type,
    String? field,
    String? value,
    String? status,
    String? mode,
    List<String>? userIds,
    String? text,
    List<String>? to,
    String? url,
    String? method,
  }) => RuleAction(
    type: type ?? this.type,
    field: field ?? this.field,
    value: value ?? this.value,
    status: status ?? this.status,
    mode: mode ?? this.mode,
    userIds: userIds ?? this.userIds,
    text: text ?? this.text,
    to: to ?? this.to,
    url: url ?? this.url,
    method: method ?? this.method,
  );

  Map<String, Object> toJson() => switch (type) {
    ActionType.setField => {'type': type.wire, 'field': field, 'value': value},
    ActionType.setStatus => {'type': type.wire, 'status': status},
    ActionType.setAssignee => {
      'type': type.wire,
      'mode': mode,
      'user_ids': mode == 'clear' ? <String>[] : userIds,
    },
    ActionType.addComment => {'type': type.wire, 'text': text},
    ActionType.createSubtask => {'type': type.wire, 'title': text},
    ActionType.notify => {'type': type.wire, 'to': to, 'message': text},
    ActionType.webhook => {'type': type.wire, 'url': url, 'method': method},
  };

  static RuleAction? fromJson(Object? json) {
    if (json is! Map) return null;
    final type = ActionType.tryParse('${json['type']}');
    if (type == null) return null;
    List<String> strings(Object? raw) => [
      if (raw is List)
        for (final e in raw) '$e',
    ];
    return RuleAction(
      type: type,
      field: '${json['field'] ?? ''}',
      value: '${json['value'] ?? ''}',
      status: '${json['status'] ?? ''}',
      mode: '${json['mode'] ?? 'set'}',
      userIds: strings(json['user_ids']),
      text: '${json['text'] ?? json['title'] ?? json['message'] ?? ''}',
      to: strings(json['to']),
      url: '${json['url'] ?? ''}',
      method: '${json['method'] ?? 'POST'}',
    );
  }

  @override
  bool operator ==(Object other) =>
      other is RuleAction && jsonEncode(toJson()) == jsonEncode(other.toJson());

  @override
  int get hashCode => jsonEncode(toJson()).hashCode;
}

String encodeActions(List<RuleAction> actions) =>
    jsonEncode([for (final a in actions) a.toJson()]);

/// Actions out of the server's JSON; unknown ones are dropped.
List<RuleAction> decodeActions(String raw) {
  try {
    final list = jsonDecode(raw);
    if (list is! List) return const [];
    return List.unmodifiable([
      for (final item in list) ?RuleAction.fromJson(item),
    ]);
  } on FormatException {
    return const [];
  }
}

Trigger decodeTrigger(String raw) {
  try {
    return Trigger.fromJson(jsonDecode(raw)) ?? const Trigger();
  } on FormatException {
    return const Trigger();
  }
}

/// A rule as the form edits it, before it is saved.
@immutable
class RuleDraft {
  const RuleDraft({
    this.name = '',
    this.trigger = const Trigger(),
    this.condition = '',
    this.actions = const [],
  });

  final String name;
  final Trigger trigger;

  /// TFQL; empty for "always".
  final String condition;
  final List<RuleAction> actions;

  RuleDraft copyWith({
    String? name,
    Trigger? trigger,
    String? condition,
    List<RuleAction>? actions,
  }) => RuleDraft(
    name: name ?? this.name,
    trigger: trigger ?? this.trigger,
    condition: condition ?? this.condition,
    actions: actions ?? this.actions,
  );
}

/// What is wrong with [t], or null.
String? triggerProblem(Trigger t) => switch (t.type) {
  TriggerType.fieldChanged when t.field.isEmpty => 'Choose a field to watch.',
  TriggerType.dueDateReached
      when t.daysBefore < 0 || t.daysBefore > maxDaysBefore =>
    'Days before is 0 to $maxDaysBefore.',
  _ => null,
};

bool _validUrl(String raw) {
  final uri = Uri.tryParse(raw.trim());
  return uri != null &&
      (uri.scheme == 'http' || uri.scheme == 'https') &&
      uri.host.isNotEmpty &&
      uri.userInfo.isEmpty;
}

String? _lengthProblem(String text, int limit, String what) {
  final t = text.trim();
  return t.isEmpty || t.length > limit
      ? '$what is 1 to $limit characters.'
      : null;
}

/// What is wrong with [a], or null.
String? actionProblem(RuleAction a) => switch (a.type) {
  ActionType.setField when a.field.isEmpty => 'Choose a field to set.',
  ActionType.setField when a.value.trim().isEmpty => 'Give the field a value.',
  ActionType.setField
      when a.value == todayToken &&
          !dateFields.contains(a.field) &&
          !a.field.startsWith(customFieldPrefix) =>
    '{today} only fits a date.',
  ActionType.setStatus when a.status.isEmpty => 'Choose a status.',
  ActionType.setAssignee when !assignModes.contains(a.mode) =>
    'Choose how to assign.',
  ActionType.setAssignee when a.mode != 'clear' && a.userIds.isEmpty =>
    'Choose who to assign.',
  ActionType.addComment => _lengthProblem(a.text, maxCommentText, 'A comment'),
  ActionType.createSubtask => _lengthProblem(a.text, maxTitleText, 'A title'),
  ActionType.notify when a.to.isEmpty || a.to.length > maxRecipients =>
    'Choose 1 to $maxRecipients people to notify.',
  ActionType.notify => _lengthProblem(a.text, maxTitleText, 'A message'),
  ActionType.webhook when !_validUrl(a.url) =>
    'Enter an http or https address.',
  ActionType.webhook when a.method != 'POST' && a.method != 'PUT' =>
    'A webhook uses POST or PUT.',
  _ => null,
};

/// Unbalanced quotes or brackets in a TFQL text; the server checks the rest.
String? conditionProblem(String text) {
  var depth = 0;
  var quoted = false;
  for (var i = 0; i < text.length; i++) {
    final c = text[i];
    if (quoted) {
      if (c == '\\') {
        i++;
      } else if (c == '"') {
        quoted = false;
      }
    } else if (c == '"') {
      quoted = true;
    } else if (c == '(') {
      depth++;
    } else if (c == ')') {
      depth--;
      if (depth < 0) return 'A closing bracket has no opening one.';
    }
  }
  if (quoted) return 'A quote is not closed.';
  if (depth > 0) return 'A bracket is not closed.';
  return null;
}

/// The first thing wrong with the whole rule, or null when it may be saved.
String? draftProblem(RuleDraft d) {
  final name = d.name.trim();
  if (name.isEmpty || name.length > maxAutomationName) {
    return 'A rule name is 1 to $maxAutomationName characters.';
  }
  final t = triggerProblem(d.trigger);
  if (t != null) return t;
  final c = conditionProblem(d.condition);
  if (c != null) return c;
  if (d.actions.isEmpty) return 'A rule needs at least one action.';
  if (d.actions.length > maxActionsPerRule) {
    return 'A rule has at most $maxActionsPerRule actions.';
  }
  for (final (i, a) in d.actions.indexed) {
    final p = actionProblem(a);
    if (p != null) return 'Action ${i + 1}: $p';
  }
  if (utf8.encode(encodeActions(d.actions)).length > maxRuleJsonBytes) {
    return 'This rule is too large.';
  }
  return null;
}

/// A rule of a project.
@immutable
class Automation {
  const Automation({
    required this.id,
    required this.projectId,
    required this.name,
    required this.trigger,
    required this.actions,
    this.enabled = false,
    this.condition = '',
    this.ownerId = '',
    this.disabledReason = '',
    this.version = 1,
    this.lastRunAt = '',
    this.lastRunStatus = '',
  });

  final String id;
  final String projectId;
  final String name;
  final bool enabled;
  final Trigger trigger;
  final String condition;
  final List<RuleAction> actions;
  final String ownerId;

  /// Why the server switched the rule off; empty when the user did.
  final String disabledReason;
  final int version;
  final String lastRunAt;
  final String lastRunStatus;

  bool get wasSwitchedOffByServer => !enabled && disabledReason.isNotEmpty;

  RuleDraft toDraft() => RuleDraft(
    name: name,
    trigger: trigger,
    condition: condition,
    actions: actions,
  );
}

enum RunStatus {
  succeeded('succeeded', 'Succeeded'),
  failed('failed', 'Failed'),
  skippedCondition('skipped_condition', 'Skipped: condition'),
  skippedLoop('skipped_loop', 'Stopped: loop'),
  skippedRate('skipped_rate', 'Paused: too many runs');

  const RunStatus(this.wire, this.label);

  final String wire;
  final String label;

  /// [label] in the language of [l].
  String labelIn(AppLocalizations l) => switch (this) {
    succeeded => l.grpMRunSucceeded,
    failed => l.grpMRunFailed,
    skippedCondition => l.grpMRunSkippedCondition,
    skippedLoop => l.grpMRunSkippedLoop,
    skippedRate => l.grpMRunSkippedRate,
  };

  static RunStatus? tryParse(String wire) =>
      values.where((s) => s.wire == wire).firstOrNull;

  /// [meaning] in the language of [l].
  String meaningIn(AppLocalizations l) => switch (this) {
    succeeded => l.grpMMeanSucceeded,
    failed => l.grpMMeanFailed,
    skippedCondition => l.grpMMeanSkippedCondition,
    skippedLoop => l.grpMMeanSkippedLoop,
    skippedRate => l.grpMMeanSkippedRate,
  };

  /// What this status means, in plain words.
  String get meaning => switch (this) {
    succeeded => 'Every action ran.',
    failed => 'An action failed; the ones before it stay done.',
    skippedCondition =>
      'The event matched, but the task did not meet the condition.',
    skippedLoop =>
      'Rules triggered rules more than 5 hops deep, so this run was '
          'stopped to end a loop.',
    skippedRate =>
      'This rule already ran 30 times in the last minute, so this run was '
          'skipped.',
  };
}

/// One field a step changes (or would change).
@immutable
class StepChange {
  const StepChange({required this.field, this.from = '', this.to = ''});

  final String field;
  final String from;
  final String to;
}

/// What one action did (or, in a dry run, would do).
@immutable
class RunStep {
  const RunStep({
    required this.type,
    required this.status,
    this.changes = const [],
    this.detail = '',
    this.error = '',
  });

  final String type;

  /// ok, failed, not_run, planned, would_fail.
  final String status;
  final List<StepChange> changes;
  final String detail;
  final String error;

  bool get isFailure => status == 'failed' || status == 'would_fail';

  String get label =>
      ActionType.tryParse(type)?.label ?? type.replaceAll('_', ' ');

  /// [label] in the language of [l].
  String labelIn(AppLocalizations l) =>
      ActionType.tryParse(type)?.labelIn(l) ?? type.replaceAll('_', ' ');

  /// [status] in the language of [l] (unknown words are shown as sent).
  String statusIn(AppLocalizations l) => switch (status) {
    'ok' => l.grpMStepOk,
    'failed' => l.grpMStepFailed,
    'not_run' => l.grpMStepNotRun,
    'planned' => l.grpMStepPlanned,
    'would_fail' => l.grpMStepWouldFail,
    _ => status.replaceAll('_', ' '),
  };
}

List<RunStep> decodeSteps(String raw) {
  try {
    final list = jsonDecode(raw);
    if (list is! List) return const [];
    return List.unmodifiable([
      for (final s in list)
        if (s is Map)
          RunStep(
            type: '${s['type'] ?? ''}',
            status: '${s['status'] ?? ''}',
            detail: '${s['detail'] ?? ''}',
            error: '${s['error'] ?? ''}',
            changes: [
              if (s['changes'] is List)
                for (final c in s['changes'] as List)
                  if (c is Map)
                    StepChange(
                      field: '${c['field'] ?? ''}',
                      from: '${c['from'] ?? ''}',
                      to: '${c['to'] ?? ''}',
                    ),
            ],
          ),
    ]);
  } on FormatException {
    return const [];
  }
}

/// One evaluation of a rule.
@immutable
class AutomationRun {
  const AutomationRun({
    required this.id,
    required this.automationId,
    required this.automationName,
    required this.status,
    this.rawStatus = '',
    this.taskId = '',
    this.taskKey = '',
    this.depth = 0,
    this.steps = const [],
    this.error = '',
    this.explanation = '',
    this.startedAt = '',
    this.finishedAt = '',
  });

  final String id;
  final String automationId;
  final String automationName;
  final RunStatus? status;

  /// The status as sent, for one this client does not know.
  final String rawStatus;
  final String taskId;
  final String taskKey;
  final int depth;
  final List<RunStep> steps;
  final String error;

  /// Plain words on why nothing was done (the failed condition, a loop...).
  final String explanation;
  final String startedAt;
  final String finishedAt;

  bool get didNotRun =>
      status == RunStatus.skippedCondition ||
      status == RunStatus.skippedLoop ||
      status == RunStatus.skippedRate;
}

/// The answer of a dry run.
@immutable
class DryRunResult {
  const DryRunResult({
    required this.wouldRun,
    this.status = '',
    this.explanation = '',
    this.error = '',
    this.steps = const [],
  });

  final bool wouldRun;
  final String status;
  final String explanation;
  final String error;
  final List<RunStep> steps;
}

enum AutomationFailure { network, denied, invalid, notFound, conflict, other }

class AutomationException implements Exception {
  const AutomationException(this.failure, {this.detail});

  final AutomationFailure failure;
  final String? detail;

  @override
  String toString() => 'AutomationException($failure)';
}

String automationErrorMessage(Object error, [AppLocalizations? l10n]) {
  final t = l10n ?? lookupAppLocalizations(const Locale('en'));
  if (error is! AutomationException) return t.grpLGeneric;
  final detail = error.detail;
  final hasDetail = detail != null && detail.isNotEmpty;
  return switch (error.failure) {
    AutomationFailure.network => t.grpLNetCheckShort,
    AutomationFailure.denied => t.grpLAutoDenied,
    AutomationFailure.notFound => t.grpLGone,
    AutomationFailure.conflict => hasDetail ? detail : t.grpLAutoConflict,
    AutomationFailure.invalid => hasDetail ? detail : t.grpLNotValid,
    AutomationFailure.other => t.grpLGeneric,
  };
}

/// The fields of [draft] that differ from [old] (for a partial update).
List<String> changedFields(Automation old, RuleDraft draft) => [
  if (draft.name.trim() != old.name) 'name',
  if (draft.trigger != old.trigger) 'trigger',
  if (draft.condition.trim() != old.condition) 'condition',
  if (!listEquals(draft.actions, old.actions)) 'actions',
];
