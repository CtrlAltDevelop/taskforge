import 'package:flutter_test/flutter_test.dart';
import 'package:taskforge/features/tasks/domain/rich_text.dart';
import 'package:taskforge/features/tasks/domain/tasks.dart';

import 'fakes.dart';

void main() {
  test('apply changes only the patched fields and keeps the version', () {
    final base = task('t1', 'Old', priority: TaskPriority.low, version: 3);

    final next = base.apply(
      const TaskPatch(title: 'New', status: TaskStatus.done),
    );

    expect(next.title, 'New');
    expect(next.status, TaskStatus.done);
    expect(next.priority, TaskPriority.low);
    expect(next.version, 3);
  });

  test('an empty date in a patch clears the date', () {
    final base = task('t1', 'T', dueDate: '2026-03-05');
    expect(base.apply(const TaskPatch(dueDate: '')).dueDate, '');
    expect(base.apply(const TaskPatch(title: 'x')).dueDate, '2026-03-05');
  });

  test('a patch names the server fields it changes and can be narrowed', () {
    const patch = TaskPatch(
      title: 'x',
      dueDate: '',
      assigneeIds: ['u1'],
      priority: TaskPriority.high,
    );

    expect(patch.fields, ['title', 'priority', 'due_date', 'assignee_ids']);
    expect(patch.only({'due_date'}).fields, ['due_date']);
    expect(const TaskPatch().isEmpty, isTrue);
    expect(patch.isEmpty, isFalse);
  });

  test('status and priority parse the wire names, unknown ones fall back', () {
    expect(TaskStatus.parse('in_progress'), TaskStatus.inProgress);
    expect(TaskStatus.parse('???'), TaskStatus.todo);
    expect(TaskPriority.parse('urgent'), TaskPriority.urgent);
    expect(TaskPriority.parse('???'), TaskPriority.none);
  });

  test('a description round-trips between plain text and the document', () {
    final json = markdownToDoc('First\n\nThird');

    expect(docToMarkdown(json), 'First\n\nThird');
    expect(markdownToDoc('   '), '');
    expect(docToMarkdown(''), '');
    expect(docToMarkdown('not json'), '');
  });

  test('conflict values are shown the way people read them', () {
    final theirs = task('t1', 'Theirs', priority: TaskPriority.urgent);
    expect(theirs.valueOf('title'), 'Theirs');
    expect(theirs.valueOf('priority'), 'Urgent');
    expect(theirs.valueOf('nope'), '');
  });

  test('error messages are friendly', () {
    expect(
      taskErrorMessage(const TaskException(TaskFailure.network)),
      contains('Cannot reach'),
    );
    expect(
      taskErrorMessage(
        const TaskException(TaskFailure.denied, detail: 'You need x'),
      ),
      'You need x',
    );
    expect(taskErrorMessage(StateError('x')), contains('Something went wrong'));
  });
}
