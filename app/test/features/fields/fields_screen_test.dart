import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskforge/features/fields/domain/field.dart';

import '../projects/fakes.dart';
import '../projects/projects_test_support.dart';
import '../tasks/fakes.dart';
import 'fakes.dart';

Future<(Pumped, FakeFieldsClient, FakeTasksClient)> _open(
  WidgetTester tester, {
  List<CustomField> fields = const [],
  String role = 'Owner',
  bool archived = false,
}) async {
  final server = FakeFieldsClient(fields);
  final tasks = FakeTasksClient();
  final pumped = await pumpProjects(
    tester,
    role: role,
    projects: [project('p1', 'Web', archived: archived)],
    tasks: tasks,
    fields: server,
  );
  await pumped.go(tester, '/projects/p1/fields');
  return (pumped, server, tasks);
}

void main() {
  testWidgets('project settings link to the fields screen', (tester) async {
    final (pumped, _, _) = await _open(tester);
    await pumped.go(tester, '/projects/p1/settings');

    await tester.tap(find.byKey(const Key('open-fields')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('fields-empty')), findsOneWidget);
  });

  testWidgets('adds a select field with coloured options', (tester) async {
    final (_, server, _) = await _open(tester);

    await tester.tap(find.byKey(const Key('add-field')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('field-name')), ' Kind ');
    await tester.tap(find.byKey(const Key('field-type')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Select').last);
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('option-label-0')), 'Bug');
    await tester.tap(find.byKey(const Key('option-add')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('option-label-1')), 'Feature');
    await tester.tap(find.byKey(const Key('option-color-1')));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(PopupMenuItem<String>).at(3));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('field-required')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('field-save')));
    await tester.pumpAndSettle();

    final draft = server.created.single;
    expect(draft.name, 'Kind');
    expect(draft.type, FieldType.select);
    expect(draft.required, isTrue);
    expect([for (final o in draft.options) o.label], ['Bug', 'Feature']);
    expect(draft.options[1].color, '#30A46C');
    expect(find.text('Kind'), findsOneWidget);
    expect(find.text('Select · Required · 2 options'), findsOneWidget);
  });

  for (final type in FieldType.values) {
    testWidgets('a ${type.label} field can be picked and saved', (
      tester,
    ) async {
      final (_, server, _) = await _open(tester);
      await tester.tap(find.byKey(const Key('add-field')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('field-name')), type.label);
      await tester.tap(find.byKey(const Key('field-type')));
      await tester.pumpAndSettle();
      await tester.tap(find.text(type.label).last);
      await tester.pumpAndSettle();
      if (type.hasOptions) {
        await tester.enterText(find.byKey(const Key('option-label-0')), 'One');
      }
      await tester.tap(find.byKey(const Key('field-save')));
      await tester.pumpAndSettle();

      expect(server.created.single.type, type);
    });
  }

  testWidgets('a name is required and options must differ', (tester) async {
    final (_, server, _) = await _open(tester);
    await tester.tap(find.byKey(const Key('add-field')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('field-save')));
    await tester.pumpAndSettle();
    expect(find.text('Give the field a name.'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('field-name')), 'K');
    await tester.tap(find.byKey(const Key('field-type')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Multi-select').last);
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('option-label-0')), 'A');
    await tester.tap(find.byKey(const Key('option-add')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('option-label-1')), 'a');
    await tester.tap(find.byKey(const Key('field-save')));
    await tester.pumpAndSettle();

    expect(find.text('Two options have the same label.'), findsOneWidget);
    expect(server.created, isEmpty);
  });

  testWidgets('a refused create shows the reason and keeps the list', (
    tester,
  ) async {
    final (_, server, _) = await _open(tester);
    server.failNext = const FieldException(FieldFailure.nameTaken);
    await tester.tap(find.byKey(const Key('add-field')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('field-name')), 'Env');
    await tester.tap(find.byKey(const Key('field-save')));
    await tester.pumpAndSettle();

    expect(find.text('A field with that name already exists.'), findsOneWidget);
  });

  testWidgets('removing a used option asks what its values become', (
    tester,
  ) async {
    final kind = field('f1', 'Kind', FieldType.select, options: [bug, feature]);
    final (_, server, _) = await _open(tester, fields: [kind]);
    server.usage = {'o-bug': 2};

    await tester.tap(find.byKey(const Key('edit-f1')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('option-remove-0')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('field-save')));
    await tester.pumpAndSettle();

    expect(find.text('Options are in use'), findsOneWidget);
    expect(find.textContaining('Bug (2 values) becomes'), findsOneWidget);

    await tester.tap(find.byKey(const Key('remap-o-bug')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Feature').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('remap-apply')));
    await tester.pumpAndSettle();

    expect(server.remaps.single, {'o-bug': 'o-feat'});
    expect(
      [for (final o in server.fields.single.options) o.label],
      ['Feature'],
    );
  });

  testWidgets('cancelling the remap saves nothing', (tester) async {
    final kind = field('f1', 'Kind', FieldType.select, options: [bug, feature]);
    final (_, server, _) = await _open(tester, fields: [kind]);
    server.usage = {'o-bug': 1};
    await tester.tap(find.byKey(const Key('edit-f1')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('option-remove-0')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('field-save')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('remap-cancel')));
    await tester.pumpAndSettle();

    expect(server.remaps, isEmpty);
    expect(server.fields.single.options.length, 2);
  });

  testWidgets('text and url convert but other types are locked', (
    tester,
  ) async {
    final (_, _, _) = await _open(
      tester,
      fields: [
        field('f1', 'Link', FieldType.text),
        field('f2', 'Points', FieldType.number),
      ],
    );

    await tester.tap(find.byKey(const Key('edit-f2')));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<DropdownButtonFormField<FieldType>>(
            find.byKey(const Key('field-type')),
          )
          .onChanged,
      isNull,
    );
    await tester.tap(find.byKey(const Key('field-cancel')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('edit-f1')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('field-type')));
    await tester.pumpAndSettle();
    expect(find.text('URL'), findsWidgets);
    expect(find.text('Money'), findsNothing);
  });

  testWidgets('archiving offers undo, and the archived list can restore', (
    tester,
  ) async {
    final (_, server, _) = await _open(
      tester,
      fields: [field('f1', 'Env', FieldType.text)],
    );

    await tester.tap(find.byKey(const Key('archive-f1')));
    await tester.pumpAndSettle();
    expect(server.archivedIds, ['f1']);
    expect(find.byKey(const Key('field-tile-f1')), findsNothing);
    expect(find.byKey(const Key('archived-f1')), findsOneWidget);

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(server.restoredIds, ['f1']);
    expect(find.byKey(const Key('field-tile-f1')), findsOneWidget);

    await tester.tap(find.byKey(const Key('archive-f1')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('restore-f1')));
    await tester.pumpAndSettle();
    expect(server.restoredIds, ['f1', 'f1']);
  });

  testWidgets('dragging reorders and saves the new order', (tester) async {
    final (_, server, _) = await _open(
      tester,
      fields: [
        field('a', 'Alpha', FieldType.text),
        field('b', 'Beta', FieldType.text, position: 1),
      ],
    );

    final gesture = await tester.startGesture(
      tester.getCenter(find.byKey(const Key('field-tile-a'))),
    );
    await tester.pump(const Duration(milliseconds: 600));
    for (var i = 0; i < 12; i++) {
      await gesture.moveBy(const Offset(0, 14));
      await tester.pump(const Duration(milliseconds: 50));
    }
    await gesture.up();
    await tester.pumpAndSettle();

    expect(server.orders.single, ['b', 'a']);
  });

  testWidgets('a viewer sees the fields but cannot change them', (
    tester,
  ) async {
    await _open(
      tester,
      role: 'Viewer',
      fields: [field('f1', 'Env', FieldType.text)],
    );

    expect(find.text('Env'), findsOneWidget);
    expect(find.byKey(const Key('add-field')), findsNothing);
    expect(find.byKey(const Key('edit-f1')), findsNothing);
    expect(find.byKey(const Key('archive-f1')), findsNothing);
  });

  testWidgets('an archived project is read-only', (tester) async {
    await _open(
      tester,
      archived: true,
      fields: [field('f1', 'Env', FieldType.text)],
    );

    expect(find.byKey(const Key('add-field')), findsNothing);
  });
}
