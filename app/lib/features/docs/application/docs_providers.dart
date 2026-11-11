import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/core/auth/auth_providers.dart';
import 'package:taskforge/core/grpc/grpc_providers.dart';
import 'package:taskforge/features/docs/data/docs_client.dart';
import 'package:taskforge/features/docs/domain/doc_blocks.dart';
import 'package:taskforge/features/docs/domain/doc_merge.dart';
import 'package:taskforge/features/docs/domain/docs.dart';
import 'package:taskforge/features/workspaces/application/workspace_providers.dart';

final docsClientProvider = Provider<DocsClient>(
  (ref) => GrpcDocsClient(
    ref.watch(grpcChannelProvider),
    ref.watch(authSessionProvider),
  ),
);

/// How long the editor waits after the last keystroke before it saves.
final docAutosaveDelayProvider = Provider<Duration>(
  (_) => const Duration(milliseconds: 1500),
);

/// How often the open page tells the server somebody is on it.
const docPresenceEvery = Duration(seconds: 20);

String get _none => '';

/// The pages of the workspace (project '') or of one project, in tree order.
final docTreeProvider = FutureProvider.autoDispose
    .family<List<DocNode>, String>((ref, project) async {
      final ws = ref.watch(workspaceScopeProvider);
      if (ws == null) return const [];
      return ref.watch(docsClientProvider).tree(ws, projectId: project);
    });

/// Where the cards of a page's tasks stand (the ids joined with commas).
final docCardsProvider = FutureProvider.autoDispose
    .family<Map<String, TaskCardInfo>, String>((ref, ids) async {
      final ws = ref.watch(workspaceScopeProvider);
      if (ws == null || ids.isEmpty) return const {};
      final cards = await ref
          .watch(docsClientProvider)
          .taskCards(ws, ids.split(','));
      return {for (final c in cards) c.taskId: c};
    });

final docRevisionsProvider = FutureProvider.autoDispose
    .family<List<RevisionInfo>, String>((ref, doc) async {
      final ws = ref.watch(workspaceScopeProvider);
      if (ws == null) return const [];
      return ref.watch(docsClientProvider).revisions(ws, doc);
    });

typedef RevisionKey = ({String doc, int revision});

final docRevisionProvider = FutureProvider.autoDispose
    .family<List<DocBlock>, RevisionKey>((ref, key) async {
      final ws = ref.watch(workspaceScopeProvider);
      if (ws == null) return const [];
      return ref.watch(docsClientProvider).revision(ws, key.doc, key.revision);
    });

final docBacklinksProvider = FutureProvider.autoDispose
    .family<List<DocNode>, String>((ref, doc) async {
      final ws = ref.watch(workspaceScopeProvider);
      if (ws == null) return const [];
      return ref.watch(docsClientProvider).backlinks(ws, doc);
    });

/// A task (`project` and `task` ids).
typedef DocTaskKey = ({String project, String task});

final relatedDocsProvider = FutureProvider.autoDispose
    .family<List<RelatedDoc>, DocTaskKey>((ref, key) async {
      final ws = ref.watch(workspaceScopeProvider);
      if (ws == null) return const [];
      return ref.watch(docsClientProvider).forTask(ws, key.project, key.task);
    });

/// Where the last save stands.
enum SaveState { saved, dirty, saving, error, conflict }

/// What the server has when a save was refused.
@immutable
class ConflictData {
  const ConflictData({required this.version, required this.blocks});

  final int version;
  final List<DocBlock> blocks;
}

@immutable
class DocEditState {
  const DocEditState({
    this.loading = true,
    this.error,
    this.page,
    this.title = '',
    this.blocks = const [],
    this.base = const [],
    this.version = 0,
    this.save = SaveState.saved,
    this.saveError,
    this.conflict,
    this.remoteChanged = false,
    this.editing = const [],
  });

  final bool loading;

  /// Why the page could not be read (not found, no access, offline).
  final DocException? error;
  final DocPage? page;
  final String title;
  final List<DocBlock> blocks;

  /// The body the server last gave or accepted (what a merge starts from).
  final List<DocBlock> base;
  final int version;
  final SaveState save;
  final DocException? saveError;
  final ConflictData? conflict;

  /// Somebody saved a newer version while this one has unsaved changes.
  final bool remoteChanged;
  final List<DocEditor> editing;

  bool get canEdit =>
      (page?.canEdit ?? false) && !(page?.node.archived ?? true);
  bool get canManage => page?.canManage ?? false;
  bool get archived => page?.node.archived ?? false;

  DocEditState copyWith({
    bool? loading,
    Object? error = _keep,
    DocPage? page,
    String? title,
    List<DocBlock>? blocks,
    List<DocBlock>? base,
    int? version,
    SaveState? save,
    Object? saveError = _keep,
    Object? conflict = _keep,
    bool? remoteChanged,
    List<DocEditor>? editing,
  }) => DocEditState(
    loading: loading ?? this.loading,
    error: identical(error, _keep) ? this.error : error as DocException?,
    page: page ?? this.page,
    title: title ?? this.title,
    blocks: blocks ?? this.blocks,
    base: base ?? this.base,
    version: version ?? this.version,
    save: save ?? this.save,
    saveError: identical(saveError, _keep)
        ? this.saveError
        : saveError as DocException?,
    conflict: identical(conflict, _keep)
        ? this.conflict
        : conflict as ConflictData?,
    remoteChanged: remoteChanged ?? this.remoteChanged,
    editing: editing ?? this.editing,
  );
}

const _keep = Object();

/// One open page: its text, the autosave and the conflict flow.
final docSessionProvider = NotifierProvider.autoDispose
    .family<DocSession, DocEditState, String>(DocSession.new);

class DocSession extends Notifier<DocEditState> {
  DocSession(this.docId);

  final String docId;
  Timer? _timer;
  var _saving = false;
  var _edits = 0;
  var _generation = 0;
  var _last = const DocEditState();

  DocsClient get _client => ref.read(docsClientProvider);
  String get _ws => ref.read(workspaceScopeProvider) ?? _none;

  @override
  DocEditState build() {
    listenSelf((_, next) => _last = next);
    final client = ref.read(docsClientProvider);
    final ws = ref.read(workspaceScopeProvider) ?? _none;
    ref.onDispose(() {
      _timer?.cancel();
      _generation++;
      final s = _last;
      // Leaving with unsaved words: send them (a refusal is lost, nobody is
      // there to show it to).
      if (s.canEdit && s.save == SaveState.dirty && s.conflict == null) {
        unawaited(_sendTo(client, ws, s).then((_) {}, onError: (Object _) {}));
      }
    });
    Future.microtask(load);
    return const DocEditState();
  }

  /// Reads the page. [quiet] keeps what is on screen while it loads.
  Future<void> load({bool quiet = false}) async {
    final gen = ++_generation;
    final editsBefore = _edits;
    if (!quiet) state = const DocEditState();
    try {
      final page = await _client.get(_ws, docId);
      if (gen != _generation) return;
      if (quiet && _edits != editsBefore) {
        // Words were typed while the page was being read: keep them, and let the
        // next save meet the newer version as a conflict.
        state = state.copyWith(remoteChanged: true);
        return;
      }
      state = DocEditState(
        loading: false,
        page: page,
        title: page.node.title,
        blocks: page.blocks,
        base: page.blocks,
        version: page.version,
        editing: page.editing,
      );
    } on DocException catch (e) {
      if (gen != _generation) return;
      state = quiet
          ? state.copyWith(loading: false)
          : DocEditState(loading: false, error: e);
    }
  }

  /// Takes new text. Saves after the autosave delay.
  void edit({String? title, List<DocBlock>? blocks}) {
    if (!state.canEdit) return;
    _edits++;
    state = state.copyWith(
      title: title,
      blocks: blocks,
      save: state.conflict != null ? SaveState.conflict : SaveState.dirty,
    );
    if (state.conflict != null) return;
    _timer?.cancel();
    _timer = Timer(ref.read(docAutosaveDelayProvider), () {
      unawaited(saveNow());
    });
  }

  Future<DocPage> _send(DocEditState s) => _sendTo(_client, _ws, s);

  Future<DocPage> _sendTo(DocsClient client, String ws, DocEditState s) {
    final fields = [
      if (s.title != (s.page?.node.title ?? '')) 'title',
      if (!sameBlocks(s.blocks, s.base)) 'blocks',
    ];
    return client.update(
      ws,
      docId,
      expectedVersion: s.version,
      fields: fields,
      title: s.title,
      blocks: s.blocks,
    );
  }

  /// Saves now (a save that is running finishes first, then this one goes).
  Future<void> saveNow() async {
    _timer?.cancel();
    if (_saving) {
      _timer = Timer(const Duration(milliseconds: 100), () {
        unawaited(saveNow());
      });
      return;
    }
    final s = state;
    if (!s.canEdit || s.save == SaveState.saved || s.conflict != null) return;
    _saving = true;
    final seq = _edits;
    state = s.copyWith(save: SaveState.saving, saveError: null);
    try {
      final answer = await _send(s);
      if (!ref.mounted) return;
      final untouched = seq == _edits;
      state = state.copyWith(
        page: answer,
        version: answer.version,
        base: answer.blocks.isEmpty && s.blocks.isNotEmpty
            ? s.blocks
            : answer.blocks,
        blocks: untouched && answer.blocks.isNotEmpty ? answer.blocks : null,
        title: untouched ? answer.node.title : null,
        save: untouched ? SaveState.saved : SaveState.dirty,
      );
      if (!untouched) {
        _timer = Timer(ref.read(docAutosaveDelayProvider), () {
          unawaited(saveNow());
        });
      }
    } on DocException catch (e) {
      if (!ref.mounted) return;
      if (e.failure == DocFailure.conflict) {
        await _openConflict(e);
      } else {
        state = state.copyWith(save: SaveState.error, saveError: e);
      }
    } finally {
      _saving = false;
    }
  }

  Future<void> _openConflict(DocException e) async {
    final c = e.conflict;
    var version = c?.version ?? 0;
    List<DocBlock>? theirs;
    final raw = c?.blocksJson;
    if (raw != null) {
      try {
        theirs = parseBlocks(raw);
      } on FormatException {
        theirs = null;
      }
    }
    if (theirs == null) {
      try {
        final page = await _client.get(_ws, docId);
        theirs = page.blocks;
        version = page.version;
      } on DocException catch (e2) {
        if (ref.mounted) {
          state = state.copyWith(save: SaveState.error, saveError: e2);
        }
        return;
      }
    }
    if (!ref.mounted) return;
    state = state.copyWith(
      save: SaveState.conflict,
      conflict: ConflictData(version: version, blocks: theirs),
    );
  }

  /// Keeps [merged] on top of the server's version and saves it.
  Future<void> resolveConflict(List<DocBlock> merged) async {
    final c = state.conflict;
    if (c == null) return;
    state = state.copyWith(
      blocks: merged,
      base: c.blocks,
      version: c.version,
      conflict: null,
      save: SaveState.dirty,
      remoteChanged: false,
    );
    _edits++;
    await saveNow();
  }

  /// Gives up my changes and shows the server's page.
  void takeTheirs() {
    final c = state.conflict;
    if (c == null) return;
    _timer?.cancel();
    state = state.copyWith(
      blocks: c.blocks,
      base: c.blocks,
      version: c.version,
      conflict: null,
      save: SaveState.saved,
      remoteChanged: false,
    );
  }

  /// Somebody saved [version]: read it, or, when there are unsaved changes,
  /// say so (the save will meet it as a conflict).
  void remoteSaved(int version) {
    if (version <= state.version || state.loading) return;
    if (state.save == SaveState.saved) {
      unawaited(load(quiet: true));
    } else {
      state = state.copyWith(remoteChanged: true);
    }
  }

  /// Puts revision [id] back as a new version.
  Future<void> restoreRevision(int id) async {
    final answer = await _client.restoreRevision(
      _ws,
      docId,
      id,
      expectedVersion: state.version,
    );
    _timer?.cancel();
    _edits++;
    state = state.copyWith(
      page: answer,
      title: answer.node.title,
      blocks: answer.blocks,
      base: answer.blocks,
      version: answer.version,
      save: SaveState.saved,
      conflict: null,
      remoteChanged: false,
    );
    ref.invalidate(docRevisionsProvider(docId));
  }

  /// The doc as the server says after something that is not a body save.
  void adopt(DocPage page) {
    state = state.copyWith(
      page: DocPage(
        node: page.node,
        version: state.version,
        blocks: state.blocks,
        updatedBy: page.updatedBy,
        editing: state.editing,
        cards: state.page?.cards ?? const [],
        canEdit: page.canEdit,
        canManage: page.canManage,
        accessUserIds: page.accessUserIds,
      ),
    );
  }

  void setEditing(List<DocEditor> editing) =>
      state = state.copyWith(editing: editing);
}

/// What the tree and page menus do. Each reads the tree again afterwards,
/// even on failure: a call that timed out may have happened.
class DocsActions {
  DocsActions(this._ref);

  final Ref _ref;

  DocsClient get _client => _ref.read(docsClientProvider);
  String get _ws => _ref.read(workspaceScopeProvider) ?? '';

  Future<T> _then<T>(Future<T> call) async {
    try {
      return await call;
    } finally {
      _ref.invalidate(docTreeProvider);
    }
  }

  Future<DocPage> create({
    String projectId = '',
    String parentId = '',
    String title = '',
  }) => _then(
    _client.create(_ws, projectId: projectId, parentId: parentId, title: title),
  );

  Future<DocPage> move(
    String id, {
    required String parent,
    required int index,
  }) => _then(_client.move(_ws, id, parentId: parent, index: index));

  Future<DocPage> archive(String id) async {
    final r = await _then(_client.archive(_ws, id));
    _ref.invalidate(docSessionProvider(id));
    return r;
  }

  Future<DocPage> restore(String id) async {
    final r = await _then(_client.restore(_ws, id));
    _ref.invalidate(docSessionProvider(id));
    return r;
  }

  Future<DocPage> setAccess(
    String id, {
    required bool restricted,
    required List<String> userIds,
  }) async {
    final r = await _then(
      _client.setAccess(_ws, id, restricted: restricted, userIds: userIds),
    );
    // ignore: deprecated_member_use
    if (_ref.exists(docSessionProvider(id))) {
      _ref.read(docSessionProvider(id).notifier).adopt(r);
    }
    return r;
  }

  Future<List<RelatedDoc>> link(String project, String task, String doc) =>
      _client.linkTask(_ws, project, task, doc);

  Future<List<RelatedDoc>> unlink(String project, String task, String doc) =>
      _client.unlinkTask(_ws, project, task, doc);

  Future<({String title, String markdown})> export(String id) =>
      _client.exportMarkdown(_ws, id);

  Future<List<DocEditor>> presence(String id, String state) =>
      _client.presence(_ws, id, state);
}

final docsActionsProvider = Provider<DocsActions>(DocsActions.new);

/// Reads whatever shows pages again (a gap in the live feed).
void readDocsAgain(Ref ref) {
  ref.invalidate(docTreeProvider);
  ref.invalidate(docBacklinksProvider);
  ref.invalidate(relatedDocsProvider);
  ref.invalidate(docCardsProvider);
}

/// A merge of [mine] with the server's page, for the dialog.
MergeResult mergeFor(DocEditState s, {Set<String> takeTheirs = const {}}) =>
    mergeBlocks(
      s.base,
      s.blocks,
      s.conflict?.blocks ?? const [],
      takeTheirs: takeTheirs,
    );
