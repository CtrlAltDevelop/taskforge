import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import '../tasks/detail_tabs.dart';

import 'package:taskforge/features/fields/domain/field.dart';
import 'package:taskforge/features/tasks/domain/tasks.dart';

import '../projects/fakes.dart';
import '../projects/projects_test_support.dart';
import '../tasks/fakes.dart';
import 'fakes.dart';

Future<(FakeFieldsClient, FakeTasksClient)> _open(
  WidgetTester tester, {
  List<CustomField> fields = const [],
  List<Task> tasks = const [],
  String role = 'Owner',
}) async {
  final server = FakeFieldsClient(fields);
  final fake = FakeTasksClient(tasks);
  final pumped = await pumpProjects(
    tester,
    role: role,
    projects: [project('p1', 'Web')],
    tasks: fake,
    fields: server,
  );
  await pumped.go(tester, '/projects/p1');
  return (server, fake);
}

Finder _input(String id) => find.descendant(
  of: find.byKey(Key('field-$id')),
  matching: find.byType(EditableText),
);

Future<void> _openTask(WidgetTester tester, String title) async {
  await tester.tap(find.text(title));
  await tester.pumpAndSettle();
  await openTab(tester, 'Fields');
}

Map<String, String> _lastValues(FakeTasksClient tasks) =>
    tasks.updates.last.patch.fieldValues!;

void main() {
  final fields = [
    field('t', 'Customer', FieldType.text),
    field('n', 'Points', FieldType.number, position: 1),
    field('k', 'Kind', FieldType.select, options: [bug, feature], position: 2),
    field(
      'm',
      'Tags',
      FieldType.multiselect,
      options: [bug, feature],
      position: 3,
    ),
    field('c', 'Reviewed', FieldType.checkbox, position: 4),
    field('u', 'Link', FieldType.url, position: 5),
    field('b', 'Budget', FieldType.money, position: 6),
    field('w', 'Reviewer', FieldType.user, position: 7),
    field('d', 'Ship', FieldType.date, position: 8),
  ];

  testWidgets('every field type is edited and saved from the task detail', (
    tester,
  ) async {
    final (_, tasks) = await _open(
      tester,
      fields: fields,
      tasks: [task('a', 'Fix login')],
    );
    tester.view.physicalSize = const Size(1400, 3200);
    await tester.pumpAndSettle();
    await _openTask(tester, 'Fix login');

    await tester.enterText(_input('t'), ' Acme ');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(_lastValues(tasks), {'t': 'Acme'});

    await tester.enterText(_input('n'), '8.5');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(_lastValues(tasks), {'n': '8.5'});

    await tester.tap(find.byKey(const Key('field-k')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Feature').last);
    await tester.pumpAndSettle();
    expect(_lastValues(tasks), {'k': 'o-feat'});

    await tester.tap(find.byKey(const Key('option-o-bug')));
    await tester.pumpAndSettle();
    expect(_lastValues(tasks), {'m': 'o-bug'});

    await tester.ensureVisible(find.byKey(const Key('field-c')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('field-c')));
    await tester.pumpAndSettle();
    expect(_lastValues(tasks), {'c': 'true'});

    await tester.enterText(_input('u'), 'https://a.example/x');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(_lastValues(tasks), {'u': 'https://a.example/x'});

    await tester.enterText(find.byKey(const Key('money-amount-b')), '12.50');
    await tester.enterText(find.byKey(const Key('money-currency-b')), 'usd');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(_lastValues(tasks), {'b': '12.50 USD'});

    await tester.tap(find.byKey(const Key('field-w')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Hank Hill').last);
    await tester.pumpAndSettle();
    expect(_lastValues(tasks), {'w': 'u2'});

    await tester.tap(find.byKey(const Key('field-d')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(_lastValues(tasks)['d'], matches(r'^\d{4}-\d{2}-\d{2}$'));

    final saved = tasks.tasks.single.fieldValues;
    expect(saved.keys.toSet(), {'t', 'n', 'k', 'm', 'c', 'u', 'b', 'w', 'd'});
  });

  testWidgets('an invalid value is flagged and never sent', (tester) async {
    final (_, tasks) = await _open(
      tester,
      fields: [field('n', 'Points', FieldType.number)],
      tasks: [task('a', 'Fix login')],
    );
    await _openTask(tester, 'Fix login');

    await tester.enterText(_input('n'), 'lots');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(find.text('Enter a number.'), findsOneWidget);
    expect(tasks.updates, isEmpty);
  });

  testWidgets('a required field shows as missing and cannot be blanked', (
    tester,
  ) async {
    final (_, tasks) = await _open(
      tester,
      fields: [field('t', 'Customer', FieldType.text, required: true)],
      tasks: [
        task('a', 'No value'),
        task('b', 'Has value', number: 2, fieldValues: const {'t': 'Acme'}),
      ],
    );

    await _openTask(tester, 'No value');
    expect(find.text('Required'), findsOneWidget);

    await tester.tap(
      find.byKey(const Key('close-detail')),
    ); // a window covers the list
    await tester.pumpAndSettle();
    await _openTask(tester, 'Has value');
    expect(find.text('Required'), findsNothing);
    await tester.enterText(_input('t'), '');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(find.text('Required'), findsOneWidget);
    expect(tasks.updates, isEmpty);
  });

  testWidgets('quick-add asks for required values and highlights the gaps', (
    tester,
  ) async {
    final (_, tasks) = await _open(
      tester,
      fields: [
        field('t', 'Customer', FieldType.text, required: true),
        field(
          'n',
          'Points',
          FieldType.number,
          required: true,
          defaultValue: '1',
        ),
        field('o', 'Notes', FieldType.text),
      ],
    );

    await tester.enterText(find.byKey(const Key('quick-add')), 'Fix login');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    // Only the required field with no default is asked for.
    expect(find.byKey(const Key('required-create')), findsOneWidget);
    expect(find.text('Points *'), findsNothing);
    await tester.tap(find.byKey(const Key('required-create')));
    await tester.pumpAndSettle();
    expect(find.text('Required'), findsOneWidget);
    expect(tasks.tasks, isEmpty);

    await tester.enterText(_input('t'), 'Acme');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('required-create')));
    await tester.pumpAndSettle();

    expect(tasks.createdWith.single, {'t': 'Acme'});
    expect(find.text('Fix login'), findsOneWidget);
  });

  testWidgets('cancelling the required-values dialog creates nothing', (
    tester,
  ) async {
    final (_, tasks) = await _open(
      tester,
      fields: [field('t', 'Customer', FieldType.text, required: true)],
    );
    await tester.enterText(find.byKey(const Key('quick-add')), 'Fix login');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('required-cancel')));
    await tester.pumpAndSettle();

    expect(tasks.tasks, isEmpty);
    expect(
      tester
          .widget<TextField>(find.byKey(const Key('quick-add')))
          .controller!
          .text,
      'Fix login',
    );
  });

  testWidgets('quick-add without required fields stays one step', (
    tester,
  ) async {
    final (_, tasks) = await _open(
      tester,
      fields: [field('o', 'Notes', FieldType.text)],
    );

    await tester.enterText(find.byKey(const Key('quick-add')), 'Plain');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(tasks.createdWith.single, isEmpty);
    expect(find.byKey(const Key('required-create')), findsNothing);
  });

  testWidgets('rows show values of fields the list shows', (tester) async {
    await _open(
      tester,
      fields: [
        field('t', 'Customer', FieldType.text),
        field('k', 'Kind', FieldType.select, options: [bug, feature]),
        field('h', 'Secret', FieldType.text, hidden: const ['list']),
      ],
      tasks: [
        task(
          'a',
          'Fix login',
          fieldValues: const {'t': 'Acme', 'k': 'o-bug', 'h': 'x'},
        ),
      ],
    );

    expect(find.byKey(const Key('header-field:t')), findsOneWidget);
    expect(find.byKey(const Key('header-field:k')), findsOneWidget);
    expect(find.text('Acme'), findsOneWidget);
    expect(find.text('Bug'), findsOneWidget);
    expect(find.byKey(const Key('header-field:h')), findsNothing);
    expect(find.text('Secret'), findsNothing);
  });

  testWidgets('a clash on a custom field names it and shows labels', (
    tester,
  ) async {
    final mine = task('a', 'Fix login');
    final (_, tasks) = await _open(
      tester,
      fields: [
        field('k', 'Kind', FieldType.select, options: [bug, feature]),
      ],
      tasks: [mine],
    );
    tasks.conflictNext = (
      field: 'field:k',
      theirs: task(
        'a',
        'Fix login',
        version: 2,
        fieldValues: const {'k': 'o-feat'},
      ),
    );
    await _openTask(tester, 'Fix login');

    await tester.tap(find.byKey(const Key('field-k')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Bug').last);
    await tester.pumpAndSettle();

    expect(find.text('Someone changed the Kind'), findsOneWidget);
    expect(
      tester.widget<Text>(find.byKey(const Key('theirs'))).data,
      'Feature',
    );
    expect(tester.widget<Text>(find.byKey(const Key('mine'))).data, 'Bug');

    await tester.tap(find.byKey(const Key('keep-mine')));
    await tester.pumpAndSettle();
    expect(tasks.updates.last.patch.fieldValues, {'k': 'o-bug'});
    expect(tasks.updates.last.expectedVersion, 2);
  });

  testWidgets('a failed save puts the old value back', (tester) async {
    final (_, tasks) = await _open(
      tester,
      fields: [field('t', 'Customer', FieldType.text)],
      tasks: [
        task('a', 'Fix login', fieldValues: const {'t': 'Old'}),
      ],
    );
    tasks.failNext = const TaskException(TaskFailure.invalid, detail: 'Nope');
    await _openTask(tester, 'Fix login');

    await tester.enterText(_input('t'), 'New');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(find.text('Nope'), findsOneWidget);
    expect(tester.widget<EditableText>(_input('t')).controller.text, 'Old');
  });

  testWidgets('a viewer sees the values but cannot edit them', (tester) async {
    await _open(
      tester,
      role: 'Viewer',
      fields: [field('t', 'Customer', FieldType.text)],
      tasks: [
        task('a', 'Read me', fieldValues: const {'t': 'Acme'}),
      ],
    );
    await _openTask(tester, 'Read me');

    expect(find.text('Acme'), findsWidgets);
    expect(
      tester
          .widget<TextField>(
            find.descendant(
              of: find.byKey(const Key('field-t')),
              matching: find.byType(TextField),
            ),
          )
          .enabled,
      isFalse,
    );
  });

  testWidgets('a required checkbox is created as off without extra taps', (
    tester,
  ) async {
    final (_, tasks) = await _open(
      tester,
      fields: [field('c', 'Reviewed', FieldType.checkbox, required: true)],
    );
    await tester.enterText(find.byKey(const Key('quick-add')), 'Fix login');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('required-create')));
    await tester.pumpAndSettle();

    expect(tasks.createdWith.single, {'c': 'false'});
  });
}
