import 'package:flutter/foundation.dart';

import 'package:taskforge/features/workflows/domain/workflow.dart';

/// A status being edited. [key] is the saved id, or a made-up one while new.
@immutable
class DraftStatus {
  const DraftStatus({
    required this.key,
    required this.name,
    this.color = '',
    this.category = StatusCategory.active,
    this.isDefault = false,
    this.taskCount = 0,
    this.isNew = false,
  });

  factory DraftStatus.of(WorkflowStatus s) => DraftStatus(
    key: s.id,
    name: s.name,
    color: s.color,
    category: s.category,
    isDefault: s.isDefault,
    taskCount: s.taskCount,
  );

  final String key;
  final String name;
  final String color;
  final StatusCategory category;
  final bool isDefault;
  final int taskCount;
  final bool isNew;

  DraftStatus copyWith({
    String? name,
    String? color,
    StatusCategory? category,
    bool? isDefault,
    int? taskCount,
  }) => DraftStatus(
    key: key,
    name: name ?? this.name,
    color: color ?? this.color,
    category: category ?? this.category,
    isDefault: isDefault ?? this.isDefault,
    taskCount: taskCount ?? this.taskCount,
    isNew: isNew,
  );
}

/// The whole workflow as the editor holds it, changed only by returning a new
/// one. [migrations] says where the tasks of each deleted status go.
@immutable
class WorkflowDraft {
  const WorkflowDraft({
    required this.statuses,
    this.transitions = const [],
    this.restrict = false,
    this.restrictCreation = false,
    this.migrations = const {},
    this.removed = const [],
  });

  factory WorkflowDraft.of(Workflow w) => WorkflowDraft(
    statuses: [for (final s in w.statuses) DraftStatus.of(s)],
    transitions: w.transitions,
    restrict: w.restrict,
    restrictCreation: w.restrictCreation,
  );

  final List<DraftStatus> statuses;
  final List<WorkflowTransition> transitions;
  final bool restrict;

  /// New tasks may only start in the default status.
  final bool restrictCreation;

  /// Deleted status key -> key of the status that takes its tasks.
  final Map<String, String> migrations;

  /// Saved statuses that were deleted (the ones that may need a migration).
  final List<DraftStatus> removed;

  WorkflowDraft _with({
    List<DraftStatus>? statuses,
    List<WorkflowTransition>? transitions,
    bool? restrict,
    bool? restrictCreation,
    Map<String, String>? migrations,
    List<DraftStatus>? removed,
  }) => WorkflowDraft(
    statuses: statuses ?? this.statuses,
    transitions: transitions ?? this.transitions,
    restrict: restrict ?? this.restrict,
    restrictCreation: restrictCreation ?? this.restrictCreation,
    migrations: migrations ?? this.migrations,
    removed: removed ?? this.removed,
  );

  WorkflowDraft _edit(String key, DraftStatus Function(DraftStatus) change) =>
      _with(statuses: [for (final s in statuses) s.key == key ? change(s) : s]);

  WorkflowDraft rename(String key, String name) =>
      _edit(key, (s) => s.copyWith(name: name));

  WorkflowDraft recolor(String key, String color) =>
      _edit(key, (s) => s.copyWith(color: color));

  WorkflowDraft recategorize(String key, StatusCategory category) =>
      _edit(key, (s) => s.copyWith(category: category));

  WorkflowDraft makeDefault(String key) => _with(
    statuses: [for (final s in statuses) s.copyWith(isDefault: s.key == key)],
  );

  WorkflowDraft add(String key, {String name = '', String color = ''}) => _with(
    statuses: [
      ...statuses,
      DraftStatus(key: key, name: name, color: color, isNew: true),
    ],
  );

  /// Moves the status at list position [from] so that it ends up at [to] (an
  /// index in the list as it is after the move, as `onReorderItem` reports it).
  WorkflowDraft moveTo(int from, int to) {
    final next = [...statuses];
    final moved = next.removeAt(from);
    next.insert(to, moved);
    return _with(statuses: next);
  }

  /// [moveTo] for the older list callback, where [to] still counts the item's
  /// own place.
  WorkflowDraft reorder(int from, int to) =>
      moveTo(from, to > from ? to - 1 : to);

  /// Deletes a status. Its tasks (if any) go to [moveTasksTo]; the transitions
  /// that touched it go with it, and so does any migration that pointed at it.
  WorkflowDraft remove(String key, {String? moveTasksTo}) {
    final gone = statuses.where((s) => s.key == key).firstOrNull;
    if (gone == null) return this;
    // Tasks already sent here follow on to where this one's go (or lose their
    // place, which the editor then asks about again).
    final migrated = {
      for (final e in migrations.entries)
        if (e.key != key) e.key: ?(e.value == key ? moveTasksTo : e.value),
      key: ?(!gone.isNew && gone.taskCount > 0 ? moveTasksTo : null),
    };
    return _with(
      statuses: [
        for (final s in statuses)
          if (s.key != key) s,
      ],
      transitions: [
        for (final t in transitions)
          if (t.from != key && t.to != key) t,
      ],
      migrations: migrated,
      removed: gone.isNew ? removed : [...removed, gone],
    );
  }

  /// Whether tasks of a deleted status are going to [key].
  bool isMigrationTarget(String key) => migrations.values.contains(key);

  /// Chooses (or changes) where the tasks of the deleted status [from] go.
  WorkflowDraft setMigration(String from, String to) =>
      _with(migrations: {...migrations, from: to});

  /// The server says the deleted status [key] still has tasks (someone added
  /// one after the editor loaded): treat it as having some, so it asks for a place.
  WorkflowDraft withUnknownTasks(String key) => _with(
    removed: [
      for (final s in removed)
        s.key == key && s.taskCount == 0 ? s.copyWith(taskCount: 1) : s,
    ],
  );

  WorkflowDraft setRestrict(bool value) => _with(restrict: value);

  WorkflowDraft setRestrictCreation(bool value) =>
      _with(restrictCreation: value);

  bool allows(String from, String to) =>
      transitions.any((t) => t.from == from && t.to == to);

  WorkflowDraft toggleTransition(String from, String to) => allows(from, to)
      ? _with(
          transitions: [
            for (final t in transitions)
              if (!(t.from == from && t.to == to)) t,
          ],
        )
      : _with(
          transitions: [
            ...transitions,
            WorkflowTransition(from: from, to: to),
          ],
        );

  WorkflowDraft setConditions(
    String from,
    String to, {
    String? requiredRoleId,
    bool? requireAssignee,
  }) => _with(
    transitions: [
      for (final t in transitions)
        if (t.from == from && t.to == to)
          WorkflowTransition(
            from: from,
            to: to,
            requiredRoleId: requiredRoleId ?? t.requiredRoleId,
            requireAssignee: requireAssignee ?? t.requireAssignee,
          )
        else
          t,
    ],
  );

  /// Whether saving this would change [w] (anything but an identical copy).
  bool differsFrom(Workflow w) {
    if (restrict != w.restrict ||
        restrictCreation != w.restrictCreation ||
        statuses.length != w.statuses.length ||
        transitions.length != w.transitions.length ||
        migrations.isNotEmpty) {
      return true;
    }
    for (var i = 0; i < statuses.length; i++) {
      final a = statuses[i];
      final b = w.statuses[i];
      if (a.key != b.id ||
          a.name != b.name ||
          a.color != b.color ||
          a.category != b.category ||
          a.isDefault != b.isDefault) {
        return true;
      }
    }
    return transitions.any(
      (t) => !w.transitions.any(
        (o) =>
            o.from == t.from &&
            o.to == t.to &&
            o.requiredRoleId == t.requiredRoleId &&
            o.requireAssignee == t.requireAssignee,
      ),
    );
  }

  /// Deleted statuses that still have tasks but nowhere to put them yet.
  List<DraftStatus> get needMigration => [
    for (final s in removed)
      if (s.taskCount > 0 && !statuses.any((k) => k.key == migrations[s.key]))
        s,
  ];
}

/// The same rules the server applies (`workflows/validate.py`), so the editor
/// can say what is wrong while typing. The server stays the authority on Save.
List<WorkflowProblem> validateDraft(WorkflowDraft draft) {
  final problems = <WorkflowProblem>[];
  final names = <String>{};
  for (final s in draft.statuses) {
    final name = s.name.trim();
    // Code points, as the server counts them (Dart's length counts UTF-16 units).
    if (name.isEmpty || name.runes.length > maxStatusNameLength) {
      problems.add(
        WorkflowProblem(
          'STATUS_NAME_INVALID',
          'A name must be 1-$maxStatusNameLength characters.',
          s.key,
        ),
      );
    } else if (!names.add(name.toLowerCase())) {
      problems.add(
        WorkflowProblem(
          'STATUS_NAME_TAKEN',
          'Two statuses are called $name.',
          s.key,
        ),
      );
    }
  }
  if (draft.statuses.length > maxStatuses) {
    problems.add(
      const WorkflowProblem(
        'TOO_MANY_STATUSES',
        'A project can have at most $maxStatuses statuses.',
      ),
    );
  }
  final categories = {for (final s in draft.statuses) s.category};
  if (!categories.contains(StatusCategory.notStarted)) {
    problems.add(
      const WorkflowProblem(
        'NO_NOT_STARTED_STATUS',
        'There must be a "Not started" status.',
      ),
    );
  }
  if (!categories.contains(StatusCategory.done)) {
    problems.add(
      const WorkflowProblem('NO_DONE_STATUS', 'There must be a "Done" status.'),
    );
  }
  final defaults = draft.statuses.where((s) => s.isDefault).toList();
  if (defaults.isEmpty) {
    problems.add(
      const WorkflowProblem(
        'NO_DEFAULT_STATUS',
        'Choose the status new tasks start in.',
      ),
    );
  } else if (defaults.length > 1) {
    problems.add(
      const WorkflowProblem(
        'MANY_DEFAULT_STATUSES',
        'Only one status can be the default.',
      ),
    );
  } else if (defaults.first.category.isFinal) {
    problems.add(
      WorkflowProblem(
        'DEFAULT_IS_FINAL',
        '${defaults.first.name}: new tasks cannot start Done or Cancelled.',
        defaults.first.key,
      ),
    );
  }
  for (final s in draft.needMigration) {
    problems.add(
      WorkflowProblem(
        'STATUS_NEEDS_MIGRATION',
        '${s.name} has tasks: choose a status to move them to.',
        s.key,
      ),
    );
  }
  if (draft.restrict) problems.addAll(_graphProblems(draft, defaults));
  return problems;
}

List<WorkflowProblem> _graphProblems(
  WorkflowDraft draft,
  List<DraftStatus> defaults,
) {
  if (defaults.length != 1) return const [];
  final edges = <String, Set<String>>{
    for (final s in draft.statuses) s.key: {},
  };
  for (final t in draft.transitions) {
    if (edges.containsKey(t.from) && edges.containsKey(t.to)) {
      edges[t.from]!.add(t.to);
    }
  }
  final reached = {defaults.first.key};
  final queue = [defaults.first.key];
  while (queue.isNotEmpty) {
    for (final next in edges[queue.removeAt(0)]!) {
      if (reached.add(next)) queue.add(next);
    }
  }
  return [
    for (final s in draft.statuses)
      if (!reached.contains(s.key))
        WorkflowProblem(
          'STATUS_UNREACHABLE',
          '${s.name} can never be reached.',
          s.key,
        ),
    if (!draft.statuses.any(
      (s) => s.category == StatusCategory.done && reached.contains(s.key),
    ))
      const WorkflowProblem(
        'NO_DONE_REACHABLE',
        'No Done status can be reached.',
      ),
    for (final s in draft.statuses)
      if (!s.category.isFinal && edges[s.key]!.isEmpty)
        WorkflowProblem('STATUS_DEAD_END', '${s.name} leads nowhere.', s.key),
  ];
}
