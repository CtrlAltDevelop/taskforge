import 'package:taskforge/features/views/data/views_client.dart';
import 'package:taskforge/features/views/domain/board_layout.dart';
import 'package:taskforge/features/views/domain/list_layout.dart';

/// In-memory saved layouts: the person's own and the project's shared ones.
class FakeViewsClient implements ViewsClient {
  FakeViewsClient([List<SavedView> initial = const []]) : views = [...initial];

  final List<SavedView> views;
  final saves =
      <
        ({String name, ListLayout layout, String id, int version, bool shared})
      >[];
  ViewException? failSave;
  ViewException? failList;
  var _next = 1;

  /// When set, the next save answers with this conflict (the version is the
  /// one the server names), once.
  int? conflictWithVersion;

  @override
  Future<List<SavedView>> list(String workspaceId, String projectId) async {
    final failure = failList;
    if (failure != null) throw failure;
    return [...views];
  }

  @override
  Future<SavedView> save(
    String workspaceId,
    String projectId, {
    required String name,
    required ListLayout layout,
    String id = '',
    int expectedVersion = 0,
    bool shared = false,
  }) async {
    saves.add((
      name: name,
      layout: layout,
      id: id,
      version: expectedVersion,
      shared: shared,
    ));
    final failure = failSave;
    if (failure != null) throw failure;
    final conflict = conflictWithVersion;
    if (conflict != null) {
      conflictWithVersion = null;
      final i = views.indexWhere((v) => v.id == id);
      if (i >= 0) {
        views[i] = SavedView(
          id: id,
          name: views[i].name,
          layout: views[i].layout,
          isShared: views[i].isShared,
          version: conflict,
        );
      }
      throw ViewException(ViewFailure.conflict, version: conflict);
    }
    if (id.isEmpty &&
        views.any((v) => v.name == name && v.isShared == shared)) {
      throw const ViewException(ViewFailure.nameTaken);
    }
    final i = views.indexWhere((v) => v.id == id);
    final saved = SavedView(
      id: id.isEmpty ? 'v${_next++}' : id,
      name: name,
      layout: layout,
      isShared: shared,
      version: i < 0 ? 1 : views[i].version + 1,
    );
    if (i < 0) {
      views.add(saved);
    } else {
      views[i] = saved;
    }
    return saved;
  }

  /// The saved boards, and every save of one.
  final boards = <SavedBoard>[];
  final boardSaves = <({String name, BoardLayout layout, String id})>[];
  ViewException? failListBoards;

  @override
  Future<List<SavedBoard>> listBoards(
    String workspaceId,
    String projectId,
  ) async {
    final failure = failListBoards;
    if (failure != null) throw failure;
    return [...boards];
  }

  @override
  Future<SavedBoard> saveBoard(
    String workspaceId,
    String projectId, {
    required String name,
    required BoardLayout layout,
    String id = '',
    int expectedVersion = 0,
    bool shared = false,
  }) async {
    boardSaves.add((name: name, layout: layout, id: id));
    if (id.isEmpty && boards.any((b) => b.name == name)) {
      throw const ViewException(ViewFailure.nameTaken);
    }
    final i = boards.indexWhere((b) => b.id == id);
    final saved = SavedBoard(
      id: id.isEmpty ? 'b${boards.length + 1}' : id,
      name: name,
      layout: layout,
      isShared: shared,
      version: i < 0 ? 1 : boards[i].version + 1,
    );
    if (i < 0) {
      boards.add(saved);
    } else {
      boards[i] = saved;
    }
    return saved;
  }

  @override
  Future<void> delete(String workspaceId, String projectId, String id) async {
    views.removeWhere((v) => v.id == id);
  }
}
