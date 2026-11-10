import 'package:grpc/grpc.dart' show GrpcError, StatusCode;
import 'package:grpc/grpc_connection_interface.dart' show ClientChannelBase;
import 'package:http/http.dart' as http;

import 'package:taskforge/core/auth/auth_session.dart';
import 'package:taskforge/core/permissions/permission_denied.dart';
import 'package:taskforge/core/workspace/scoped_requests.dart';
import 'package:taskforge/features/views/domain/board_layout.dart';
import 'package:taskforge/features/views/domain/calendar_layout.dart';
import 'package:taskforge/features/views/domain/list_layout.dart';
import 'package:taskforge/features/workspaces/domain/workspace.dart'
    show stripErrorTitle;
import 'package:taskforge/gen/infrastructure/savedviews/grpc/savedviews.pbgrpc.dart'
    as pb;

abstract interface class ViewsClient {
  /// The project's shared layouts, then the caller's own.
  Future<List<SavedView>> list(String workspaceId, String projectId);

  /// Creates a layout (no [id]) or replaces [id] (then [expectedVersion] is
  /// the version this client last saw).
  Future<SavedView> save(
    String workspaceId,
    String projectId, {
    required String name,
    required ListLayout layout,
    String id = '',
    int expectedVersion = 0,
    bool shared = false,
  });

  Future<void> delete(String workspaceId, String projectId, String id);

  /// The same for the board: shared layouts, then the caller's own.
  Future<List<SavedBoard>> listBoards(String workspaceId, String projectId);

  Future<SavedBoard> saveBoard(
    String workspaceId,
    String projectId, {
    required String name,
    required BoardLayout layout,
    String id = '',
    int expectedVersion = 0,
    bool shared = false,
  });

  /// And for the calendar.
  Future<List<SavedCalendar>> listCalendars(
    String workspaceId,
    String projectId,
  );

  Future<SavedCalendar> saveCalendar(
    String workspaceId,
    String projectId, {
    required String name,
    required CalendarLayout layout,
    String id = '',
    int expectedVersion = 0,
    bool shared = false,
  });
}

ViewException mapViewError(Object error) {
  if (error is ViewException) return error;
  if (error is GrpcError) {
    final message = error.message ?? '';
    final title = RegExp(r'^([A-Z][A-Z0-9_]*): ').firstMatch(message)?.group(1);
    final denied = parsePermissionDenied(error);
    return switch (error.code) {
      StatusCode.permissionDenied when denied != null => ViewException(
        ViewFailure.denied,
        detail: denied.message,
      ),
      StatusCode.permissionDenied => const ViewException(ViewFailure.forbidden),
      StatusCode.alreadyExists when title == 'PROJECT_ARCHIVED' =>
        const ViewException(ViewFailure.archived),
      StatusCode.alreadyExists when title == 'VIEW_NAME_TAKEN' =>
        const ViewException(ViewFailure.nameTaken),
      StatusCode.invalidArgument when title == 'VIEW_LIMIT' =>
        const ViewException(ViewFailure.limit),
      StatusCode.invalidArgument => ViewException(
        ViewFailure.invalid,
        detail: stripErrorTitle(message),
      ),
      StatusCode.notFound => const ViewException(ViewFailure.notFound),
      StatusCode.aborted => ViewException(
        ViewFailure.conflict,
        version: int.tryParse(errorTrailer(error, 'x-error-version-bin')) ?? 0,
      ),
      StatusCode.unavailable ||
      StatusCode.deadlineExceeded => const ViewException(ViewFailure.network),
      _ => const ViewException(ViewFailure.other),
    };
  }
  if (error is http.ClientException) {
    return const ViewException(ViewFailure.network);
  }
  return const ViewException(ViewFailure.other);
}

ListLayout layoutFromPb(pb.LayoutResponse l) => ListLayout(
  columns: List.unmodifiable(l.columns),
  widths: Map.unmodifiable({
    for (final w in l.widths) w.column: w.width.toDouble(),
  }),
  sort: List.unmodifiable([
    for (final s in l.sort) SortKey(s.key, desc: s.desc),
  ]),
  groupBy: l.groupBy,
);

pb.Layout layoutToPb(ListLayout l) => pb.Layout(
  columns: l.columns,
  widths: [
    for (final e in l.widths.entries)
      pb.LayoutWidth(column: e.key, width: e.value.round()),
  ],
  sort: [for (final s in l.sort) pb.LayoutSort(key: s.key, desc: s.desc)],
  groupBy: l.groupBy,
);

BoardLayout boardFromPb(pb.BoardLayoutResponse b) => BoardLayout(
  groupBy: b.groupBy.isEmpty ? 'status' : b.groupBy,
  swimlane: b.swimlane,
  cardFields: List.unmodifiable(b.cardFields),
  limits: Map.unmodifiable({for (final l in b.limits) l.column: l.limit}),
);

pb.BoardLayout boardToPb(BoardLayout b) => pb.BoardLayout(
  groupBy: b.groupBy,
  swimlane: b.swimlane,
  cardFields: b.cardFields,
  limits: [
    for (final e in b.limits.entries)
      pb.BoardLimit(column: e.key, limit: e.value),
  ],
);

CalendarLayout calendarFromPb(pb.CalendarLayoutResponse c) => CalendarLayout(
  mode: c.mode.isEmpty ? 'month' : c.mode,
  colorBy: c.colorBy.isEmpty ? 'status' : c.colorBy,
  weekStart: c.weekStart,
  hideDone: c.hideDone,
);

pb.CalendarLayout calendarToPb(CalendarLayout c) => pb.CalendarLayout(
  mode: c.mode,
  colorBy: c.colorBy,
  weekStart: c.weekStart,
  hideDone: c.hideDone,
);

SavedCalendar _calendar(pb.SavedView v) => SavedCalendar(
  id: v.id,
  name: v.name,
  layout: calendarFromPb(v.calendar),
  isShared: v.isShared,
  version: v.version,
);

SavedBoard _board(pb.SavedView v) => SavedBoard(
  id: v.id,
  name: v.name,
  layout: boardFromPb(v.board),
  isShared: v.isShared,
  version: v.version,
);

SavedView _view(pb.SavedView v) => SavedView(
  id: v.id,
  name: v.name,
  layout: layoutFromPb(v.layout),
  isShared: v.isShared,
  version: v.version,
);

class GrpcViewsClient implements ViewsClient {
  GrpcViewsClient(ClientChannelBase channel, this._session, {this.onRefusal})
    : _stub = pb.ViewControllerClient(channel);

  final pb.ViewControllerClient _stub;
  final AuthSession _session;

  /// Called when a mutating call is refused (permissions may be stale).
  final void Function()? onRefusal;

  late final _options = scopedCallOptions(_session, () => null);

  Future<T> _run<T>(Future<T> Function() call, {bool isRead = false}) async {
    try {
      try {
        return await call();
      } on GrpcError catch (e) {
        if (e.code != StatusCode.unauthenticated) rethrow;
        if (await _session.forceRefresh() == null) rethrow;
        return await call();
      }
    } on Object catch (e) {
      final mapped = mapViewError(e);
      if (!isRead &&
          (mapped.failure == ViewFailure.denied ||
              mapped.failure == ViewFailure.forbidden)) {
        onRefusal?.call();
      }
      throw mapped;
    }
  }

  @override
  Future<List<SavedView>> list(String workspaceId, String projectId) =>
      _run(() async {
        final reply = await _stub.list(
          pb.ViewListRequest(
            workspaceId: workspaceId,
            projectId: projectId,
            kind: 'list',
          ),
          options: _options,
        );
        return [for (final v in reply.views) _view(v)];
      }, isRead: true);

  @override
  Future<List<SavedBoard>> listBoards(String workspaceId, String projectId) =>
      _run(() async {
        final reply = await _stub.list(
          pb.ViewListRequest(
            workspaceId: workspaceId,
            projectId: projectId,
            kind: 'board',
          ),
          options: _options,
        );
        return [for (final v in reply.views) _board(v)];
      }, isRead: true);

  @override
  Future<List<SavedCalendar>> listCalendars(
    String workspaceId,
    String projectId,
  ) => _run(() async {
    final reply = await _stub.list(
      pb.ViewListRequest(
        workspaceId: workspaceId,
        projectId: projectId,
        kind: 'calendar',
      ),
      options: _options,
    );
    return [for (final v in reply.views) _calendar(v)];
  }, isRead: true);

  @override
  Future<SavedCalendar> saveCalendar(
    String workspaceId,
    String projectId, {
    required String name,
    required CalendarLayout layout,
    String id = '',
    int expectedVersion = 0,
    bool shared = false,
  }) => _run(
    () async => _calendar(
      await _stub.save(
        pb.ViewSaveRequest(
          workspaceId: workspaceId,
          projectId: projectId,
          id: id,
          expectedVersion: expectedVersion,
          name: name,
          kind: 'calendar',
          calendar: calendarToPb(layout),
          shared: shared,
        ),
        options: _options,
      ),
    ),
  );

  @override
  Future<SavedBoard> saveBoard(
    String workspaceId,
    String projectId, {
    required String name,
    required BoardLayout layout,
    String id = '',
    int expectedVersion = 0,
    bool shared = false,
  }) => _run(
    () async => _board(
      await _stub.save(
        pb.ViewSaveRequest(
          workspaceId: workspaceId,
          projectId: projectId,
          id: id,
          expectedVersion: expectedVersion,
          name: name,
          kind: 'board',
          board: boardToPb(layout),
          shared: shared,
        ),
        options: _options,
      ),
    ),
  );

  @override
  Future<SavedView> save(
    String workspaceId,
    String projectId, {
    required String name,
    required ListLayout layout,
    String id = '',
    int expectedVersion = 0,
    bool shared = false,
  }) => _run(
    () async => _view(
      await _stub.save(
        pb.ViewSaveRequest(
          workspaceId: workspaceId,
          projectId: projectId,
          id: id,
          expectedVersion: expectedVersion,
          name: name,
          kind: 'list',
          layout: layoutToPb(layout),
          shared: shared,
        ),
        options: _options,
      ),
    ),
  );

  @override
  Future<void> delete(String workspaceId, String projectId, String id) =>
      _run(() async {
        await _stub.delete(
          pb.ViewDeleteRequest(
            workspaceId: workspaceId,
            projectId: projectId,
            id: id,
          ),
          options: _options,
        );
      });
}
