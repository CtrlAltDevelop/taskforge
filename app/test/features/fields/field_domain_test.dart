import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:grpc/grpc.dart' show GrpcError, StatusCode;
import 'package:taskforge/features/fields/data/fields_client.dart';
import 'package:taskforge/features/fields/domain/field.dart';
import 'package:taskforge/features/tasks/data/tasks_client.dart';
import 'package:taskforge/gen/infrastructure/customfields/grpc/customfields.pbgrpc.dart'
    as pb;
import 'package:taskforge/features/tasks/domain/tasks.dart';

import '../tasks/fakes.dart';
import 'fakes.dart';

GrpcError _error(int code, String message, [Map<String, String>? t]) =>
    GrpcError.custom(code, message, null, null, {
      for (final e in (t ?? const <String, String>{}).entries)
        e.key: base64.encode(utf8.encode(e.value)),
    });

void main() {
  mappingTests();
  group('validateFieldValue', () {
    test('accepts empty and valid values of every type', () {
      for (final (type, value) in [
        (FieldType.text, 'anything'),
        (FieldType.number, '-12.50'),
        (FieldType.money, '12.50 usd'),
        (FieldType.date, '2026-02-28'),
        (FieldType.url, 'https://a.example/x'),
        (FieldType.number, ''),
        (FieldType.checkbox, 'true'),
      ]) {
        expect(validateFieldValue(type, value), isNull, reason: '$type $value');
      }
    });

    test('names the problem for each bad value', () {
      expect(validateFieldValue(FieldType.number, 'abc'), 'Enter a number.');
      expect(validateFieldValue(FieldType.number, '1e5'), isNotNull);
      expect(validateFieldValue(FieldType.money, '12.50'), isNotNull);
      expect(validateFieldValue(FieldType.money, 'x USD'), 'Enter an amount.');
      expect(validateFieldValue(FieldType.url, 'ftp://x.example'), isNotNull);
      expect(validateFieldValue(FieldType.url, 'not a url'), isNotNull);
      expect(validateFieldValue(FieldType.date, '28/02/2026'), isNotNull);
    });
  });

  test('money splits and joins without touching the digits', () {
    expect(splitMoney('12.50 usd'), (amount: '12.50', currency: 'USD'));
    expect(splitMoney(''), (amount: '', currency: ''));
    expect(joinMoney(' 0.10 ', 'eur'), '0.10 EUR');
    expect(joinMoney('', 'eur'), '');
  });

  test('fieldDisplay shows labels, not ids', () {
    final kind = field('f1', 'Kind', FieldType.select, options: [bug, feature]);
    final tags = field(
      'f2',
      'Tags',
      FieldType.multiselect,
      options: [bug, feature],
    );

    expect(fieldDisplay(kind, 'o-bug'), 'Bug');
    expect(fieldDisplay(kind, 'gone'), '');
    expect(fieldDisplay(tags, 'o-bug,o-feat'), 'Bug, Feature');
    expect(
      fieldDisplay(field('f3', 'Done', FieldType.checkbox), 'true'),
      'Yes',
    );
    expect(
      fieldDisplay(
        field('f4', 'Who', FieldType.user),
        'u2',
        userLabel: (id) => 'Hank',
      ),
      'Hank',
    );
    expect(fieldDisplay(kind, ''), '');
  });

  test('a required field with no default must be given a value on create', () {
    expect(
      field('a', 'A', FieldType.text, required: true).needsValueOnCreate,
      isTrue,
    );
    expect(
      field(
        'a',
        'A',
        FieldType.text,
        required: true,
        defaultValue: 'x',
      ).needsValueOnCreate,
      isFalse,
    );
    expect(field('a', 'A', FieldType.text).needsValueOnCreate, isFalse);
  });

  test('a draft knows which options it removed', () {
    final saved = field('f', 'K', FieldType.select, options: [bug, feature]);

    final draft = FieldDraft(
      name: 'K',
      type: FieldType.select,
      options: [feature],
    );

    expect(draft.removedOptionsFrom(saved), {'o-bug'});
  });

  group('task values', () {
    test('a patch sets and clears values and names its fields', () {
      final base = task('t', 'T', fieldValues: const {'f1': 'a', 'f2': 'b'});

      final next = base.apply(
        const TaskPatch(fieldValues: {'f1': '', 'f3': 'c'}),
      );

      expect(next.fieldValues, {'f2': 'b', 'f3': 'c'});
      expect(const TaskPatch(fieldValues: {'f1': 'x'}).fields, ['field:f1']);
      expect(base.valueOf('field:f2'), 'b');
    });

    test('narrowing keeps only the named custom fields', () {
      const patch = TaskPatch(fieldValues: {'f1': 'x', 'f2': 'y'});

      expect(patch.only({'field:f2'}).fieldValues, {'f2': 'y'});
      expect(patch.only({'title'}).fieldValues, isEmpty);
    });
  });

  group('error mapping', () {
    test('a taken name, the limit and a stale version', () {
      expect(
        mapFieldError(_error(StatusCode.alreadyExists, 'FIELD_NAME_TAKEN: x'))
            .failure,
        FieldFailure.nameTaken,
      );
      expect(
        mapFieldError(_error(StatusCode.invalidArgument, 'FIELD_LIMIT: x'))
            .failure,
        FieldFailure.limit,
      );
      expect(
        mapFieldError(_error(StatusCode.aborted, 'VERSION_CONFLICT: x'))
            .failure,
        FieldFailure.conflict,
      );
    });

    test('a removed option in use carries the counts', () {
      final error = mapFieldError(
        _error(StatusCode.failedPrecondition, 'OPTION_NEEDS_REMAP: x', {
          'x-error-options-bin': '{"o-bug": 3}',
        }),
      );

      expect(error.failure, FieldFailure.needsRemap);
      expect(error.usage, {'o-bug': 3});
    });

    test('a missing required value on a task names the fields', () {
      final error = mapTaskError(
        _error(
          StatusCode.invalidArgument,
          'FIELD_REQUIRED: These fields need a value: Customer.',
          {'x-error-fields-bin': '["f1","f2"]'},
        ),
      );

      expect(error.failure, TaskFailure.fieldRequired);
      expect(error.fieldIds, ['f1', 'f2']);
      expect(taskErrorMessage(error), contains('Customer'));
    });

    test('an invalid value is shown as the server said it', () {
      final error = mapTaskError(
        _error(
          StatusCode.invalidArgument,
          'FIELD_INVALID: "x" is not a number.',
        ),
      );

      expect(error.failure, TaskFailure.invalid);
      expect(error.detail, '"x" is not a number.');
    });
  });
}

void mappingTests() {
  test('a server field maps to the domain field', () {
    final mapped = fieldFromPb(
      pb.Field(
        id: 'f1',
        projectId: 'p1',
        name: 'Kind',
        type: 'multiselect',
        options: [
          pb.FieldOptionResponse(id: 'o1', label: 'Bug', color: '#E5484D'),
        ],
        required: true,
        default_7: 'o1',
        hiddenViews: ['board'],
        position: 2,
        version: 3,
        archivedAt: '2026-11-10T00:00:00Z',
      ),
    );

    expect(mapped.type, FieldType.multiselect);
    expect(mapped.options.single.label, 'Bug');
    expect(mapped.required, isTrue);
    expect(mapped.defaultValue, 'o1');
    expect(mapped.hiddenViews, ['board']);
    expect((mapped.position, mapped.version), (2, 3));
    expect(mapped.isArchived, isTrue);
  });
}
