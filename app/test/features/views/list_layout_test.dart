import 'package:flutter_test/flutter_test.dart';
import 'package:taskforge/features/views/domain/list_layout.dart';

void main() {
  group('sortedBy', () {
    test('cycles ascending, descending, none', () {
      var layout = const ListLayout();

      layout = layout.sortedBy('due_date');
      expect(layout.sort, [const SortKey('due_date')]);
      layout = layout.sortedBy('due_date');
      expect(layout.sort, [const SortKey('due_date', desc: true)]);
      layout = layout.sortedBy('due_date');
      expect(layout.sort, isEmpty);
    });

    test('a plain click replaces the other keys', () {
      final layout = const ListLayout(
        sort: [SortKey('title'), SortKey('priority')],
      ).sortedBy('due_date');

      expect(layout.sort, [const SortKey('due_date')]);
    });

    test('add keeps the other keys and flips only this one', () {
      var layout = const ListLayout(sort: [SortKey('title')])
          .sortedBy('priority', add: true);
      expect(layout.sort, [const SortKey('title'), const SortKey('priority')]);

      layout = layout.sortedBy('priority', add: true);
      expect(layout.sort, [
        const SortKey('title'),
        const SortKey('priority', desc: true),
      ]);

      layout = layout.sortedBy('priority', add: true);
      expect(layout.sort, [const SortKey('title')]);
    });

    test('never holds more than three keys', () {
      final layout = const ListLayout(
        sort: [SortKey('a'), SortKey('b'), SortKey('c')],
      ).sortedBy('d', add: true);

      expect(layout.sort.length, maxSortKeys);
    });
  });

  test('withWidth keeps a column readable and inside the limit', () {
    const layout = ListLayout();

    expect(layout.withWidth('status', 5).widthOf('status'), minColumnWidth);
    expect(layout.withWidth('status', 9000).widthOf('status'), maxColumnWidth);
    expect(layout.withWidth('status', 200).widthOf('status'), 200);
    expect(layout.widthOf('title'), titleDefaultWidth);
    expect(layout.widthOf('priority'), defaultColumnWidth);
  });

  test('withColumn adds and removes without duplicates', () {
    const layout = ListLayout(columns: ['status']);

    expect(layout.withColumn('status', shown: true), same(layout));
    expect(layout.withColumn('priority', shown: true).columns, [
      'status',
      'priority',
    ]);
    expect(layout.withColumn('status', shown: false).columns, isEmpty);
  });

  test('the layout is immutable: a change returns a new one', () {
    const layout = ListLayout();
    final changed = layout.groupedBy('status');

    expect(layout.groupBy, '');
    expect(changed.groupBy, 'status');
    expect(changed, isNot(layout));
    expect(layout.copyWith(), layout);
  });

  test('toJson is what the server stores', () {
    final json = const ListLayout(
      columns: ['status'],
      widths: {'title': 300.4},
      sort: [SortKey('due_date', desc: true)],
      groupBy: 'status',
    ).toJson();

    expect(json, {
      'columns': ['status'],
      'widths': {'title': 300},
      'sort': [
        {'key': 'due_date', 'desc': true},
      ],
      'group_by': 'status',
    });
  });

  test('only sort and grouping reach the query', () {
    const a = ListLayout(columns: ['status']);
    final b = a.withWidth('status', 200).withColumn('priority', shown: true);

    expect(a.query, b.query);
    expect(a.query.isDefault, isTrue);
    expect(a.sortedBy('title').query, isNot(a.query));
  });
}
