import 'dart:convert';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskforge/features/filters/domain/filter_fields.dart';
import 'package:taskforge/features/filters/domain/filter_query.dart';
import 'package:taskforge/features/filters/domain/saved_filters.dart';
import 'package:taskforge/features/filters/presentation/tfql_editor.dart';

FilterCondition _c(
  String field,
  String cmp, [
  List<FilterValue> v = const [],
]) => FilterCondition(field: field, cmp: cmp, values: v);

void main() {
  group('the AST', () {
    test('a query round-trips through the server\'s JSON', () {
      final query = FilterQuery(
        root: FilterGroup(
          children: [
            _c('status', 'in', const [
              FilterValue.id('s1'),
              FilterValue.id('s2'),
            ]),
            FilterGroup(
              op: 'or',
              children: [
                _c('assignee', 'eq', const [FilterValue.me()]),
                _c('due', 'lt', const [FilterValue.relative(7, 'd')]),
                _c('due', 'gte', const [FilterValue.date('2026-11-05')]),
              ],
            ),
            _c('title', 'contains', const [FilterValue.text('fix "this"')]),
            _c('cf:abc', 'gt', const [FilterValue.number('3.5')]),
            _c('blocked', 'eq', const [FilterValue.flag(on: true)]),
            _c('sprint', 'eq', const [FilterValue.sprint()]),
            _c('assignee', 'empty'),
          ],
        ),
        order: const [FilterOrder('priority', desc: true), FilterOrder('due')],
      );

      final again = FilterQuery.fromJsonString(query.toJsonString());

      expect(again, query);
      expect(
        jsonDecode(again.toJsonString()),
        jsonDecode(query.toJsonString()),
      );
    });

    test('an empty filter is an empty string and none', () {
      expect(FilterQuery.none.isEmpty, isTrue);
      expect(FilterQuery.none.toJsonString(), '');
      expect(FilterQuery.fromJsonString(''), FilterQuery.none);
      expect(
        FilterQuery.fromJson({'where': null, 'order': []}).isEmpty,
        isTrue,
      );
    });

    test(
      'a single condition is not wrapped and a negated one keeps its NOT',
      () {
        final one = FilterQuery(
          root: FilterGroup(
            children: [
              _c('title', 'eq', const [FilterValue.text('a')]),
            ],
          ),
        );
        final not = FilterQuery(
          root: FilterGroup(
            children: [
              FilterGroup(
                negated: true,
                children: [
                  _c('title', 'eq', const [FilterValue.text('a')]),
                ],
              ),
            ],
          ),
        );

        expect(one.toJson()['where'], {
          'op': 'cmp',
          'field': 'title',
          'cmp': 'eq',
          'values': [
            {'k': 'text', 'v': 'a'},
          ],
        });
        expect((not.toJson()['where']! as Map)['op'], 'not');
        expect(FilterQuery.fromJson(not.toJson()), not);
      },
    );

    test('NOT over a group reads back as a negated group', () {
      final ast = {
        'where': {
          'op': 'not',
          'arg': {
            'op': 'or',
            'args': [
              {
                'op': 'cmp',
                'field': 'priority',
                'cmp': 'eq',
                'values': [
                  {'k': 'id', 'v': 'high'},
                ],
              },
              {
                'op': 'cmp',
                'field': 'priority',
                'cmp': 'eq',
                'values': [
                  {'k': 'id', 'v': 'low'},
                ],
              },
            ],
          },
        },
        'order': [],
      };

      final query = FilterQuery.fromJson(ast);

      final group = query.root.children.single as FilterGroup;
      expect((group.negated, group.op, group.children.length), (true, 'or', 2));
      expect(jsonDecode(query.toJsonString()), ast);
    });

    test('counts conditions anywhere in the tree', () {
      final q = FilterQuery(
        root: FilterGroup(
          children: [
            _c('title', 'empty'),
            FilterGroup(children: [_c('due', 'empty'), _c('start', 'empty')]),
          ],
        ),
      );

      expect(q.conditionCount, 3);
    });

    test('updateAt edits, removes and adds without touching the original', () {
      final root = FilterGroup(
        children: [
          _c('title', 'empty'),
          FilterGroup(children: [_c('due', 'empty')]),
        ],
      );

      final edited = updateAt(root, [
        1,
        0,
      ], (n) => (n as FilterCondition).copyWith(cmp: 'not_empty'));
      final removed = updateAt(root, [0], (_) => null);
      final added = updateAt(
        root,
        [1],
        (n) => (n as FilterGroup).copyWith(
          children: [...n.children, _c('start', 'empty')],
        ),
      );

      expect(
        ((edited.children[1] as FilterGroup).children.single as FilterCondition)
            .cmp,
        'not_empty',
      );
      expect(removed.children.length, 1);
      expect((added.children[1] as FilterGroup).children.length, 2);
      expect(root.children.length, 2);
      expect(
        ((root.children[1] as FilterGroup).children.single as FilterCondition)
            .cmp,
        'empty',
      );
      expect(updateAt(root, [9], (_) => null), root); // nothing there
    });

    test('a relative date reads like the language', () {
      expect(const FilterValue.relative(7, 'd').asText, '+7d');
      expect(const FilterValue.relative(-2, 'w').asText, '-2w');
      expect(const FilterValue.relative(0, 'd').asText, 'today');
    });

    test('today is a plain date in the viewer\'s zone', () {
      expect(localToday(), matches(RegExp(r'^\d{4}-\d{2}-\d{2}$')));
    });
  });

  group('the fields', () {
    test('every kind has operators and the same table as the server', () {
      for (final kind in FilterKind.values) {
        expect(operatorsOf[kind], isNotEmpty, reason: '$kind');
      }
      expect(operatorsOf[FilterKind.text], contains('contains'));
      expect(operatorsOf[FilterKind.status], isNot(contains('contains')));
      expect(operatorsOf[FilterKind.date], containsAll(['lt', 'gte', 'empty']));
      expect(operatorsOf[FilterKind.bool], ['eq', 'ne']);
    });

    test('built-ins come first, with the statuses and people as choices', () {
      final fields = filterFields();

      expect(fields.take(3).map((f) => f.ref), ['title', 'status', 'category']);
      expect(
        fields.firstWhere((f) => f.ref == 'priority').choices,
        hasLength(5),
      );
      expect(fields.firstWhere((f) => f.ref == 'due').sortable, isTrue);
      expect(fields.firstWhere((f) => f.ref == 'blocked').sortable, isFalse);
    });

    test('operators that take a list or no value', () {
      expect(takesList('in'), isTrue);
      expect(takesList('eq'), isFalse);
      expect(takesNoValue('not_empty'), isTrue);
      expect(operatorLabels.keys, containsAll(operatorsOf[FilterKind.text]!));
    });
  });

  group('the TFQL controller', () {
    testWidgets('paints keywords, strings and dates and underlines a problem', (
      tester,
    ) async {
      final controller = TfqlController(
        text: 'status = "In review" AND due < +7d',
      )..problems = const [QueryProblem(9, 11, 'bad')];
      late TextSpan span;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              span = controller.buildTextSpan(
                context: context,
                withComposing: false,
              );
              return const SizedBox();
            },
          ),
        ),
      );

      final pieces = [for (final c in span.children!) c as TextSpan];
      final and = pieces.firstWhere((p) => p.text == 'AND');
      final string = pieces.firstWhere(
        (p) => (p.text ?? '').contains('"In review"'),
      );
      final rel = pieces.firstWhere((p) => p.text == '+7d');

      expect(and.style!.fontWeight, FontWeight.bold);
      expect(string.style!.color, Colors.green.shade700);
      expect(rel.style!.color, Colors.orange.shade800);
      expect(
        pieces.any((p) => p.style?.decoration == TextDecoration.underline),
        isTrue,
      );
      expect(span.toPlainText(), 'status = "In review" AND due < +7d');
      controller.dispose();
    });
  });
}
