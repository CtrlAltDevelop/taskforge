import 'package:fixnum/fixnum.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grpc/grpc.dart' show GrpcError;
import 'package:taskforge/features/audit/data/audit_client.dart';
import 'package:taskforge/features/audit/domain/audit.dart';
import 'package:taskforge/gen/infrastructure/audit/grpc/audit.pb.dart' as pb;

void main() {
  test('a page reads its entries, their changes and the label names', () {
    final page = pageFromPb(
      pb.AuditPage(
        entries: [
          pb.AuditEntry(
            id: Int64(9),
            at: '2026-11-12T10:00:00+00:00',
            actor: 'u1',
            actorName: 'Ali',
            actorType: 'user',
            action: 'task.updated',
            targetType: 'task',
            targetId: 't1',
            changesJson: '{"title": ["A", "B"]}',
            batchId: 'b1',
          ),
        ],
        labels: [pb.Label(id: 'u1', name: 'Ali')],
        nextBefore: Int64(9),
      ),
    );
    final e = page.entries.single;
    expect(e.id, 9);
    expect(e.at.isUtc, isTrue);
    expect(e.changes['title'], ['A', 'B']);
    expect(e.batchId, 'b1');
    expect(page.labels['u1'], 'Ali');
    expect(page.hasMore, isTrue);
  });

  test('bad JSON in changes becomes no changes, not a crash', () {
    expect(AuditEntry.decodeChanges('{nope'), isEmpty);
    expect(AuditEntry.decodeChanges('[1]'), isEmpty);
    expect(AuditEntry.decodeChanges(''), isEmpty);
  });

  test('gRPC statuses map to failures', () {
    AuditFailure of(GrpcError e) => mapAuditError(e).failure;
    expect(of(GrpcError.permissionDenied('x')), AuditFailure.denied);
    expect(of(GrpcError.notFound('x')), AuditFailure.notFound);
    expect(of(GrpcError.invalidArgument('INVALID: bad')), AuditFailure.invalid);
    expect(of(GrpcError.unavailable('x')), AuditFailure.network);
    expect(
      mapAuditError(GrpcError.invalidArgument('INVALID: bad')).detail,
      'bad',
    );
  });
}
