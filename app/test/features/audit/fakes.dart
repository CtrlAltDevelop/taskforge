import 'package:taskforge/features/audit/data/audit_client.dart';
import 'package:taskforge/features/audit/domain/audit.dart';

AuditEntry entry(
  int id,
  String action, {
  String actor = 'u1',
  String actorName = 'Ali',
  String actorType = 'user',
  String targetType = 'task',
  String targetId = 'a',
  DateTime? at,
  Map<String, dynamic> changes = const {},
  String batchId = '',
}) => AuditEntry(
  id: id,
  at: at ?? DateTime.utc(2026, 11, 12, 10).subtract(Duration(hours: id)),
  actor: actor,
  actorName: actorName,
  actorType: actorType,
  action: action,
  targetType: targetType,
  targetId: targetId,
  changes: changes,
  batchId: batchId,
);

/// A log held in memory with the server's paging rule: newest first, `before`
/// is the last id of the previous page, `nextBefore` 0 at the end.
class FakeAuditClient implements AuditClient {
  FakeAuditClient(this.entries, {this.labels = const {}, this.pageSize = 50});

  List<AuditEntry> entries;
  Map<String, String> labels;
  int pageSize;

  final listCalls = <({AuditFilters filters, int before})>[];
  final taskCalls = <({String task, int before})>[];
  final exports = <AuditFilters>[];
  AuditException? failNext;

  /// Set to make the export return this text.
  String? bigExport;

  AuditPage _page(Iterable<AuditEntry> rows, int before) {
    final sorted = rows.where((e) => before == 0 || e.id < before).toList()
      ..sort((a, b) => b.id.compareTo(a.id));
    final page = sorted.take(pageSize).toList();
    return AuditPage(
      entries: page,
      labels: labels,
      nextBefore: sorted.length > pageSize ? page.last.id : 0,
    );
  }

  void _maybeFail() {
    final f = failNext;
    if (f != null) {
      failNext = null;
      throw f;
    }
  }

  @override
  Future<AuditPage> list(
    String workspaceId,
    AuditFilters filters, {
    int before = 0,
    int limit = 0,
  }) async {
    listCalls.add((filters: filters, before: before));
    _maybeFail();
    return _page(
      entries.where(
        (e) =>
            (filters.action.isEmpty || e.action.startsWith(filters.action)) &&
            (filters.actor.isEmpty || e.actor == filters.actor),
      ),
      before,
    );
  }

  @override
  Future<AuditPage> forTask(
    String workspaceId,
    String projectId,
    String taskId, {
    int before = 0,
    int limit = 0,
  }) async {
    taskCalls.add((task: taskId, before: before));
    _maybeFail();
    return _page(
      entries.where((e) => e.targetType == 'task' && e.targetId == taskId),
      before,
    );
  }

  @override
  Future<String> exportCsv(String workspaceId, AuditFilters filters) async {
    exports.add(filters);
    _maybeFail();
    return bigExport ?? 'id,at,action\n1,2026-11-12,task.created\n';
  }
}
