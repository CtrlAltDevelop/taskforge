import 'package:flutter_test/flutter_test.dart';
import 'package:taskforge/core/offline/outbox.dart';

final _t0 = DateTime.utc(2026, 11, 12);

OutboxEntry entry(
  int id,
  OutboxOp op, {
  String entityId = 't1',
  OutboxEntity entity = OutboxEntity.task,
  Map<String, dynamic> payload = const {},
  OutboxState state = OutboxState.pending,
  int expected = 0,
}) => OutboxEntry(
  id: id,
  workspaceId: 'w1',
  entity: entity,
  entityId: entityId,
  op: op,
  payload: payload,
  mutationId: 'm$id',
  createdAt: _t0,
  state: state,
  expectedVersion: expected,
);

void main() {
  test('an update after a create becomes part of the create', () {
    final queue = [
      entry(1, OutboxOp.create, payload: {'title': 'A'}),
    ];
    final change = foldIntoQueue(
      queue,
      entry(2, OutboxOp.update, payload: {'title': 'B', 'priority': 'high'}),
    );
    expect(change.add, isNull);
    expect(change.replace[1]!.payload, {'title': 'B', 'priority': 'high'});
    expect(change.replace[1]!.op, OutboxOp.create);
  });

  test('two updates of one task are one update, keeping the first version', () {
    final queue = [
      entry(
        1,
        OutboxOp.update,
        payload: {'title': 'A', 'dueDate': 'x'},
        expected: 4,
      ),
    ];
    final change = foldIntoQueue(
      queue,
      entry(2, OutboxOp.update, payload: {'title': 'B'}, expected: 5),
    );
    expect(change.replace[1]!.payload, {'title': 'B', 'dueDate': 'x'});
    expect(change.replace[1]!.expectedVersion, 4);
    expect(change.add, isNull);
  });

  test('an update of something not queued is appended', () {
    final change = foldIntoQueue([
      entry(1, OutboxOp.update, entityId: 'other'),
    ], entry(2, OutboxOp.update, payload: {'title': 'B'}));
    expect(change.add?.id, 2);
    expect(change.replace, isEmpty);
  });

  test('a delete after a create cancels it and what hung on it', () {
    final queue = [
      entry(1, OutboxOp.create),
      entry(2, OutboxOp.update),
      entry(
        3,
        OutboxOp.create,
        entity: OutboxEntity.comment,
        entityId: 'c1',
        payload: {'taskId': 't1'},
      ),
      entry(4, OutboxOp.create, entityId: 'other'),
    ];
    final change = foldIntoQueue(queue, entry(5, OutboxOp.delete));
    expect(change.drop, [1, 2, 3]);
    expect(change.add, isNull); // it never existed on the server
  });

  test('a delete after an update drops the update and is sent', () {
    final change = foldIntoQueue([
      entry(1, OutboxOp.update, payload: {'title': 'A'}),
    ], entry(2, OutboxOp.delete));
    expect(change.drop, [1]);
    expect(change.add?.op, OutboxOp.delete);
  });

  test('a delete of a task the server has is just sent', () {
    final change = foldIntoQueue([], entry(1, OutboxOp.delete));
    expect(change.add?.op, OutboxOp.delete);
    expect(change.drop, isEmpty);
  });

  test(
    'an entry that is being sent or waits for a decision is never folded',
    () {
      for (final state in [
        OutboxState.sending,
        OutboxState.conflict,
        OutboxState.rejected,
      ]) {
        final change = foldIntoQueue([
          entry(1, OutboxOp.update, state: state),
        ], entry(2, OutboxOp.update, payload: {'title': 'B'}));
        expect(change.add?.id, 2, reason: '$state');
        expect(change.replace, isEmpty);
      }
    },
  );

  test('comments are never folded into each other', () {
    final c = entry(
      1,
      OutboxOp.create,
      entity: OutboxEntity.comment,
      entityId: 'c1',
    );
    final change = foldIntoQueue([
      c,
    ], entry(2, OutboxOp.create, entity: OutboxEntity.comment, entityId: 'c2'));
    expect(change.add?.id, 2);
  });

  test('states say what needs a person', () {
    expect(OutboxState.conflict.needsAttention, isTrue);
    expect(OutboxState.rejected.needsAttention, isTrue);
    expect(OutboxState.pending.needsAttention, isFalse);
    expect(OutboxState.sending.needsAttention, isFalse);
  });

  test('a payload survives the trip through JSON', () {
    final e = entry(
      1,
      OutboxOp.update,
      payload: {
        'a': 1,
        'b': ['x'],
      },
    );
    expect(OutboxEntry.payloadOf(e.payloadJson), {
      'a': 1,
      'b': ['x'],
    });
  });
}
