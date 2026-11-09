import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/features/tasks/application/tasks_providers.dart';
import 'package:taskforge/features/workflows/application/workflows_providers.dart';
import 'package:taskforge/features/workflows/domain/workflow.dart';
import 'package:taskforge/features/workflows/domain/workflow_draft.dart';
import 'package:taskforge/features/workflows/domain/workflow_merge.dart';
import 'package:taskforge/features/workspaces/application/workspace_providers.dart';

/// What the workflow editor shows: the saved workflow, the draft being edited,
/// and whatever is wrong with it.
@immutable
class WorkflowEditorState {
  const WorkflowEditorState({
    this.base,
    this.draft,
    this.loading = true,
    this.loadError,
    this.saving = false,
    this.serverProblems = const [],
    this.saveError,
    this.mergeNotes = const [],
  });

  /// The saved workflow the draft started from.
  final Workflow? base;
  final WorkflowDraft? draft;
  final bool loading;
  final WorkflowException? loadError;
  final bool saving;

  /// What the server found wrong with the draft (its own dry run or a refused save).
  final List<WorkflowProblem> serverProblems;

  /// The last save failure that is not a list of problems.
  final WorkflowException? saveError;

  /// After someone else saved first: what was taken from them, kept from this
  /// draft, or given up, one sentence each. Save stays off until the person has
  /// read them (see [WorkflowEditor.acknowledgeMerge]), so nothing changes silently.
  final List<String> mergeNotes;

  bool get needsReview => mergeNotes.isNotEmpty;

  /// Every problem to show: this app's check first, then the server's that it
  /// did not already say.
  List<WorkflowProblem> get problems {
    final d = draft;
    if (d == null) return const [];
    final local = validateDraft(d);
    final seen = {for (final p in local) '${p.code}/${p.statusKey}'};
    return [
      ...local,
      for (final p in serverProblems)
        if (!seen.contains('${p.code}/${p.statusKey}')) p,
    ];
  }

  bool get dirty {
    final b = base;
    final d = draft;
    return b != null && d != null && d.differsFrom(b);
  }

  bool get canSave => dirty && !saving && problems.isEmpty && !needsReview;

  WorkflowEditorState copyWith({
    Workflow? base,
    WorkflowDraft? draft,
    bool? loading,
    WorkflowException? Function()? loadError,
    bool? saving,
    List<WorkflowProblem>? serverProblems,
    WorkflowException? Function()? saveError,
    List<String>? mergeNotes,
  }) => WorkflowEditorState(
    base: base ?? this.base,
    draft: draft ?? this.draft,
    loading: loading ?? this.loading,
    loadError: loadError == null ? this.loadError : loadError(),
    saving: saving ?? this.saving,
    serverProblems: serverProblems ?? this.serverProblems,
    saveError: saveError == null ? this.saveError : saveError(),
    mergeNotes: mergeNotes ?? this.mergeNotes,
  );
}

/// The editor of one project's workflow. Edits only change the draft; Save
/// sends the whole workflow at once and either all of it lands or none.
final workflowEditorProvider = NotifierProvider.autoDispose
    .family<WorkflowEditor, WorkflowEditorState, String>(WorkflowEditor.new);

class WorkflowEditor extends Notifier<WorkflowEditorState> {
  WorkflowEditor(this.projectId);

  final String projectId;
  var _checks = 0;
  var _nextKey = 0;

  String get _workspace {
    final id = ref.read(workspaceScopeProvider);
    if (id == null) throw const WorkflowException(WorkflowFailure.other);
    return id;
  }

  @override
  WorkflowEditorState build() {
    ref.watch(workspaceScopeProvider);
    Future.microtask(load);
    return const WorkflowEditorState();
  }

  /// (Re)reads the saved workflow and starts a fresh draft from it.
  Future<void> load() async {
    state = const WorkflowEditorState();
    try {
      final workflow = await ref
          .read(workflowsClientProvider)
          .get(_workspace, projectId);
      if (!ref.mounted) return;
      state = WorkflowEditorState(
        base: workflow,
        draft: WorkflowDraft.of(workflow),
        loading: false,
      );
    } on Object catch (e) {
      if (!ref.mounted) return;
      state = WorkflowEditorState(
        loading: false,
        loadError: _asWorkflowException(e),
      );
    }
  }

  WorkflowException _asWorkflowException(Object e) => e is WorkflowException
      ? e
      : const WorkflowException(WorkflowFailure.other);

  /// A key for a status that does not exist on the server yet.
  String newKey() => 'new-${_nextKey++}';

  /// Replaces the draft with [change] of it, then has the server check it.
  void edit(WorkflowDraft Function(WorkflowDraft) change) {
    final d = state.draft;
    if (d == null || state.saving) return;
    state = state.copyWith(
      draft: change(d),
      serverProblems: const [],
      saveError: () => null,
    );
    _check();
  }

  /// Puts the draft back to the saved workflow.
  void discard() {
    final b = state.base;
    if (b == null) return;
    _checks++; // a dry run still in flight belongs to the draft being thrown away
    state = state.copyWith(
      draft: WorkflowDraft.of(b),
      serverProblems: const [],
      saveError: () => null,
      mergeNotes: const [],
    );
  }

  /// The person has read what the merge changed and wants to keep the result.
  void acknowledgeMerge() {
    if (!state.needsReview) return;
    state = state.copyWith(mergeNotes: const [], saveError: () => null);
    _check();
  }

  /// The server's dry run, only once this app's own check is clean (it adds
  /// what only the database knows, such as a deleted role).
  Future<void> _check() async {
    final generation = ++_checks;
    final d = state.draft;
    if (d == null || validateDraft(d).isNotEmpty || !state.dirty) return;
    try {
      final found = await ref
          .read(workflowsClientProvider)
          .validate(_workspace, projectId, d);
      if (!ref.mounted || generation != _checks) return;
      state = state.copyWith(serverProblems: found);
    } on Object {
      // The check is advice; Save reports the real outcome.
    }
  }

  /// Saves the whole workflow. Returns true when it was saved.
  Future<bool> save() async {
    final d = state.draft;
    final b = state.base;
    if (d == null || b == null || !state.canSave) return false;
    state = state.copyWith(saving: true, saveError: () => null);
    try {
      final saved = await ref
          .read(workflowsClientProvider)
          .update(_workspace, projectId, d, b.version);
      if (!ref.mounted) return true;
      _checks++;
      state = WorkflowEditorState(
        base: saved,
        draft: WorkflowDraft.of(saved),
        loading: false,
      );
      _refreshReaders();
      return true;
    } on Object catch (e) {
      if (!ref.mounted) return false;
      final failure = _asWorkflowException(e);
      if (failure.failure == WorkflowFailure.invalid) {
        // A deleted status that has tasks the editor did not know about: ask
        // for a place for them rather than leaving the save stuck.
        var next = d;
        for (final p in failure.problems) {
          if (p.code == 'STATUS_NEEDS_MIGRATION') {
            next = next.withUnknownTasks(p.statusKey);
          }
        }
        state = state.copyWith(
          draft: next,
          saving: false,
          serverProblems: failure.problems,
          saveError: () => failure,
        );
      } else if (failure.failure == WorkflowFailure.conflict) {
        await _mergeAfterConflict(d, b, failure);
      } else {
        state = state.copyWith(saving: false, saveError: () => failure);
      }
      return false;
    }
  }

  /// Someone else saved first. The draft is kept: the saved workflow is read
  /// again and merged with it (their work is never overwritten, mine is kept
  /// wherever it does not clash), and every decision is listed for review.
  Future<void> _mergeAfterConflict(
    WorkflowDraft mine,
    Workflow base,
    WorkflowException failure,
  ) async {
    try {
      final theirs = await ref
          .read(workflowsClientProvider)
          .get(_workspace, projectId);
      if (!ref.mounted) return;
      final merged = mergeWorkflows(base: base, theirs: theirs, mine: mine);
      state = WorkflowEditorState(
        base: theirs,
        draft: merged.draft,
        loading: false,
        mergeNotes: merged.notes,
        saveError: failure,
      );
    } on Object {
      // Could not read theirs: keep everything as it was and say it failed.
      if (!ref.mounted) return;
      state = state.copyWith(saving: false, saveError: () => failure);
    }
  }

  /// Task pickers and lists read the workflow and the tasks: a save may have
  /// renamed statuses and moved tasks.
  void _refreshReaders() {
    ref.invalidate(workflowProvider(projectId));
    ref.invalidate(taskListProvider(projectId));
  }
}
