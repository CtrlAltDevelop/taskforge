import 'package:taskforge/core/ui/tokens/shape.dart';
import 'package:taskforge/core/ui/tf_icons.dart';
import 'package:material_ui/material_ui.dart';

import 'package:taskforge/core/i18n/date_picker.dart';
import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/features/filters/domain/filter_fields.dart';
import 'package:taskforge/features/filters/domain/filter_query.dart';
import 'package:taskforge/l10n/gen/app_localizations.dart';

const _maxDepth = 3;

/// The visual builder: groups of conditions joined by AND / OR, each condition a
/// row of field, operator and value, then an ORDER BY. It edits a
/// [FilterQuery] and hands every change to [onChanged].
class FilterBuilder extends StatelessWidget {
  const FilterBuilder({
    super.key,
    required this.query,
    required this.fields,
    required this.onChanged,
  });

  final FilterQuery query;
  final List<FilterField> fields;
  final void Function(FilterQuery) onChanged;

  FilterField? _field(String ref) =>
      fields.where((f) => f.ref == ref).firstOrNull;

  void _edit(List<int> path, FilterNode? Function(FilterNode) change) =>
      onChanged(query.copyWith(root: updateAt(query.root, path, change)));

  FilterCondition _blank() {
    final field = fields.first;
    return FilterCondition(
      field: field.ref,
      cmp: field.operators.first,
      values: defaultValues(field, field.operators.first),
    );
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      _GroupView(
        key: const Key('filter-root'),
        group: query.root,
        path: const [],
        fields: fields,
        blank: _blank,
        edit: _edit,
        fieldOf: _field,
      ),
      const SizedBox(height: 12),
      _OrderView(
        order: query.order,
        fields: [
          for (final f in fields)
            if (f.sortable) f,
        ],
        onChanged: (order) => onChanged(query.copyWith(order: order)),
      ),
    ],
  );
}

/// The values a new [cmp] on [field] starts with.
List<FilterValue> defaultValues(FilterField field, String cmp) {
  if (takesNoValue(cmp)) return const [];
  switch (field.kind) {
    case FilterKind.bool:
      return const [FilterValue.flag(on: true)];
    case FilterKind.sprint:
      return const [FilterValue.sprint()];
    case FilterKind.user:
      return const [FilterValue.me()];
    case FilterKind.status ||
        FilterKind.category ||
        FilterKind.priority ||
        FilterKind.select ||
        FilterKind.multiselect:
      return field.choices.isEmpty
          ? const []
          : [FilterValue.id(field.choices.first.id)];
    case FilterKind.date || FilterKind.datetime:
      return const [FilterValue.relative(0, 'd')];
    case FilterKind.text || FilterKind.number || FilterKind.id:
      return const [];
  }
}

class _GroupView extends StatelessWidget {
  const _GroupView({
    super.key,
    required this.group,
    required this.path,
    required this.fields,
    required this.blank,
    required this.edit,
    required this.fieldOf,
  });

  final FilterGroup group;
  final List<int> path;
  final List<FilterField> fields;
  final FilterCondition Function() blank;
  final void Function(List<int>, FilterNode? Function(FilterNode)) edit;
  final FilterField? Function(String) fieldOf;

  bool get _root => path.isEmpty;
  String get _id => path.isEmpty ? 'root' : path.join('-');

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: scheme.outlineVariant),
        borderRadius: TfRadius.panel,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SegmentedButton<String>(
                key: Key('group-op-$_id'),
                showSelectedIcon: false,
                segments: [
                  ButtonSegment(
                    value: 'and',
                    label: Text(context.l10n.grpDAllOf),
                  ),
                  ButtonSegment(
                    value: 'or',
                    label: Text(context.l10n.grpDAnyOf),
                  ),
                ],
                selected: {group.op},
                onSelectionChanged: (v) =>
                    edit(path, (n) => (n as FilterGroup).copyWith(op: v.first)),
              ),
              FilterChip(
                key: Key('group-not-$_id'),
                label: Text(context.l10n.grpDNot),
                selected: group.negated,
                onSelected: (v) =>
                    edit(path, (n) => (n as FilterGroup).copyWith(negated: v)),
              ),
              if (!_root)
                IconButton(
                  key: Key('remove-group-$_id'),
                  tooltip: context.l10n.grpDRemoveGroup,
                  icon: const TfIcon(TfIcons.close),
                  onPressed: () => edit(path, (_) => null),
                ),
            ],
          ),
          const SizedBox(height: 8),
          for (var i = 0; i < group.children.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: switch (group.children[i]) {
                final FilterGroup g => _GroupView(
                  key: Key('group-${[...path, i].join('-')}'),
                  group: g,
                  path: [...path, i],
                  fields: fields,
                  blank: blank,
                  edit: edit,
                  fieldOf: fieldOf,
                ),
                final FilterCondition c => _ConditionRow(
                  key: Key('row-${[...path, i].join('-')}'),
                  id: [...path, i].join('-'),
                  condition: c,
                  fields: fields,
                  field: fieldOf(c.field),
                  onChanged: (next) => edit([...path, i], (_) => next),
                  onRemove: () => edit([...path, i], (_) => null),
                ),
              },
            ),
          Wrap(
            spacing: 8,
            children: [
              TextButton.icon(
                key: Key('add-condition-$_id'),
                icon: const TfIcon(TfIcons.plus),
                label: Text(context.l10n.grpDCondition),
                onPressed: () => edit(
                  path,
                  (n) => (n as FilterGroup).copyWith(
                    children: [...n.children, blank()],
                  ),
                ),
              ),
              if (path.length < _maxDepth - 1)
                TextButton.icon(
                  key: Key('add-group-$_id'),
                  icon: const TfIcon(TfIcons.workflow),
                  label: Text(context.l10n.grpDGroup),
                  onPressed: () => edit(
                    path,
                    (n) => (n as FilterGroup).copyWith(
                      children: [
                        ...n.children,
                        FilterGroup(op: 'or', children: [blank()]),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ConditionRow extends StatelessWidget {
  const _ConditionRow({
    super.key,
    required this.id,
    required this.condition,
    required this.fields,
    required this.field,
    required this.onChanged,
    required this.onRemove,
  });

  final String id;
  final FilterCondition condition;
  final List<FilterField> fields;
  final FilterField? field;
  final void Function(FilterCondition) onChanged;
  final VoidCallback onRemove;

  void _pickField(String ref) {
    final next = fields.firstWhere((f) => f.ref == ref);
    final cmp = next.operators.contains(condition.cmp)
        ? condition.cmp
        : next.operators.first;
    onChanged(
      FilterCondition(field: ref, cmp: cmp, values: defaultValues(next, cmp)),
    );
  }

  void _pickOperator(String cmp) {
    final spec = field;
    if (spec == null) return;
    final wasList = takesList(condition.cmp);
    final nowList = takesList(cmp);
    final keep =
        takesNoValue(cmp) ||
            takesNoValue(condition.cmp) ||
            wasList != nowList && spec.hasChoices == false
        ? defaultValues(spec, cmp)
        : (nowList ? condition.values : condition.values.take(1).toList());
    onChanged(condition.copyWith(cmp: cmp, values: keep));
  }

  @override
  Widget build(BuildContext context) {
    final spec = field;
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        DropdownButton<String>(
          key: Key('field-$id'),
          value: spec?.ref,
          hint: Text(context.l10n.grpDFieldRemoved),
          items: [
            for (final f in fields)
              DropdownMenuItem(value: f.ref, child: Text(f.label)),
          ],
          onChanged: (v) => v == null ? null : _pickField(v),
        ),
        if (spec != null)
          DropdownButton<String>(
            key: Key('op-$id'),
            value: spec.operators.contains(condition.cmp)
                ? condition.cmp
                : spec.operators.first,
            items: [
              for (final op in spec.operators)
                DropdownMenuItem(
                  value: op,
                  child: Text(_label(context.l10n, spec, op)),
                ),
            ],
            onChanged: (v) => v == null ? null : _pickOperator(v),
          ),
        if (spec != null && !takesNoValue(condition.cmp))
          ConditionValue(
            id: id,
            field: spec,
            condition: condition,
            onChanged: onChanged,
          ),
        IconButton(
          key: Key('remove-row-$id'),
          tooltip: context.l10n.grpDRemoveCondition,
          icon: const TfIcon(TfIcons.trash),
          onPressed: onRemove,
        ),
      ],
    );
  }

  static String _label(AppLocalizations l10n, FilterField field, String op) {
    final dated =
        field.kind == FilterKind.date || field.kind == FilterKind.datetime;
    return switch (op) {
      'lt' when dated => l10n.grpDOpBefore,
      'lte' when dated => l10n.grpDOpOnOrBefore,
      'gt' when dated => l10n.grpDOpAfter,
      'gte' when dated => l10n.grpDOpOnOrAfter,
      'lt' => l10n.grpDOpLessThan,
      'lte' => l10n.grpDOpAtMost,
      'gt' => l10n.grpDOpMoreThan,
      'gte' => l10n.grpDOpAtLeast,
      _ => operatorLabelIn(l10n, op) ?? operatorLabels[op]!,
    };
  }
}

/// The value part of a condition row, by the field's kind.
class ConditionValue extends StatelessWidget {
  const ConditionValue({
    super.key,
    required this.id,
    required this.field,
    required this.condition,
    required this.onChanged,
  });

  final String id;
  final FilterField field;
  final FilterCondition condition;
  final void Function(FilterCondition) onChanged;

  void _set(List<FilterValue> values) =>
      onChanged(condition.copyWith(values: values));

  @override
  Widget build(BuildContext context) {
    final list = takesList(condition.cmp);
    switch (field.kind) {
      case FilterKind.bool:
        return DropdownButton<bool>(
          key: Key('value-$id'),
          value: condition.values.firstOrNull?.value == false ? false : true,
          items: [
            DropdownMenuItem(value: true, child: Text(context.l10n.grpDYes)),
            DropdownMenuItem(value: false, child: Text(context.l10n.grpDNo)),
          ],
          onChanged: (v) => _set([FilterValue.flag(on: v ?? true)]),
        );
      case FilterKind.sprint:
        return Text(context.l10n.grpDCurrentSprint);
      case FilterKind.status ||
          FilterKind.category ||
          FilterKind.priority ||
          FilterKind.select ||
          FilterKind.multiselect ||
          FilterKind.user:
        return list ? _choiceChips(context) : _choiceDropdown(context);
      case FilterKind.date || FilterKind.datetime:
        return _DateValue(
          key: Key('value-$id'),
          value: condition.values.firstOrNull,
          onChanged: (v) => _set([v]),
        );
      case FilterKind.text || FilterKind.number || FilterKind.id:
        return list ? _listText() : _text();
    }
  }

  List<FilterChoice> _choicesFor(BuildContext context) => [
    if (field.kind == FilterKind.user) FilterChoice('me', context.l10n.grpDMe),
    ...field.choices,
  ];

  FilterValue _asValue(FilterChoice c) =>
      c.id == 'me' && field.kind == FilterKind.user
      ? const FilterValue.me()
      : FilterValue.id(c.id);

  String _idOf(FilterValue v) => v.kind == 'me' ? 'me' : '${v.value}';

  Widget _choiceDropdown(BuildContext context) {
    final choices = _choicesFor(context);
    final current = condition.values.firstOrNull;
    final ids = choices.map((c) => c.id).toSet();
    return DropdownButton<String>(
      key: Key('value-$id'),
      value: current != null && ids.contains(_idOf(current))
          ? _idOf(current)
          : null,
      hint: Text(context.l10n.grpDChoose),
      items: [
        for (final c in choices)
          DropdownMenuItem(value: c.id, child: Text(c.label)),
      ],
      onChanged: (v) => v == null
          ? null
          : _set([_asValue(choices.firstWhere((c) => c.id == v))]),
    );
  }

  Widget _choiceChips(BuildContext context) {
    final chosen = {for (final v in condition.values) _idOf(v)};
    final choices = _choicesFor(context);
    return Wrap(
      key: Key('value-$id'),
      spacing: 4,
      children: [
        for (final c in choices)
          FilterChip(
            key: Key('choice-$id-${c.id}'),
            label: Text(c.label),
            selected: chosen.contains(c.id),
            onSelected: (on) => _set([
              for (final other in choices)
                if (other.id == c.id ? on : chosen.contains(other.id))
                  _asValue(other),
            ]),
          ),
      ],
    );
  }

  Widget _text() => _TextValue(
    key: Key('value-$id'),
    initial: condition.values.firstOrNull?.asText ?? '',
    numeric: field.kind != FilterKind.text,
    onChanged: (t) => _set([_scalar(t)]),
  );

  Widget _listText() => _TextValue(
    key: Key('value-$id'),
    initial: condition.values.map((v) => v.asText).join(', '),
    hint: 'a, b, c',
    onChanged: (t) => _set([
      for (final part in t.split(','))
        if (part.trim().isNotEmpty) _scalar(part.trim()),
    ]),
  );

  FilterValue _scalar(String text) => field.kind == FilterKind.text
      ? FilterValue.text(text)
      : FilterValue.number(text);
}

class _TextValue extends StatefulWidget {
  const _TextValue({
    super.key,
    required this.initial,
    required this.onChanged,
    this.numeric = false,
    this.hint,
  });

  final String initial;
  final bool numeric;
  final String? hint;
  final void Function(String) onChanged;

  @override
  State<_TextValue> createState() => _TextValueState();
}

class _TextValueState extends State<_TextValue> {
  late final _controller = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 180,
    child: TextField(
      controller: _controller,
      keyboardType: widget.numeric ? TextInputType.number : null,
      decoration: InputDecoration(
        isDense: true,
        hintText: widget.hint ?? context.l10n.grpDValue,
      ),
      onChanged: widget.onChanged,
    ),
  );
}

/// A date: typed as `2026-11-05`, `+7d` / `-2w` / `+1m` / `+1y` or `today`, or
/// picked.
class _DateValue extends StatefulWidget {
  const _DateValue({super.key, required this.value, required this.onChanged});

  final FilterValue? value;
  final void Function(FilterValue) onChanged;

  @override
  State<_DateValue> createState() => _DateValueState();
}

class _DateValueState extends State<_DateValue> {
  late final _controller = TextEditingController(
    text: widget.value?.asText ?? 'today',
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  static FilterValue? parse(String text) {
    final t = text.trim().toLowerCase();
    if (t == 'today') return const FilterValue.relative(0, 'd');
    final rel = RegExp(r'^([+-]\d+)([dwmy])$').firstMatch(t);
    if (rel != null) {
      return FilterValue.relative(int.parse(rel[1]!), rel[2]!);
    }
    if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(t)) return FilterValue.date(t);
    return null;
  }

  Future<void> _pick() async {
    final picked = await showAppDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    final iso = picked.toIso8601String().substring(0, 10);
    _controller.text = iso;
    widget.onChanged(FilterValue.date(iso));
  }

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 200,
    child: TextField(
      controller: _controller,
      decoration: InputDecoration(
        isDense: true,
        hintText: 'today, +7d, 2026-11-05',
        suffixIcon: IconButton(
          tooltip: context.l10n.grpDPickDate,
          icon: const TfIcon(TfIcons.calendar, size: 16),
          onPressed: _pick,
        ),
      ),
      onChanged: (t) {
        final v = parse(t);
        if (v != null) widget.onChanged(v);
      },
    ),
  );
}

class _OrderView extends StatelessWidget {
  const _OrderView({
    required this.order,
    required this.fields,
    required this.onChanged,
  });

  final List<FilterOrder> order;
  final List<FilterField> fields;
  final void Function(List<FilterOrder>) onChanged;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      for (var i = 0; i < order.length; i++)
        Row(
          children: [
            Text(context.l10n.grpDOrderByLabel),
            DropdownButton<String>(
              key: Key('order-field-$i'),
              value: fields.any((f) => f.ref == order[i].field)
                  ? order[i].field
                  : null,
              items: [
                for (final f in fields)
                  DropdownMenuItem(value: f.ref, child: Text(f.label)),
              ],
              onChanged: (v) => v == null
                  ? null
                  : onChanged([
                      for (var k = 0; k < order.length; k++)
                        k == i ? FilterOrder(v, desc: order[k].desc) : order[k],
                    ]),
            ),
            const SizedBox(width: 8),
            SegmentedButton<bool>(
              key: Key('order-dir-$i'),
              showSelectedIcon: false,
              segments: [
                ButtonSegment(
                  value: false,
                  label: Text(context.l10n.grpDAscending),
                ),
                ButtonSegment(
                  value: true,
                  label: Text(context.l10n.grpDDescending),
                ),
              ],
              selected: {order[i].desc},
              onSelectionChanged: (v) => onChanged([
                for (var k = 0; k < order.length; k++)
                  k == i
                      ? FilterOrder(order[k].field, desc: v.first)
                      : order[k],
              ]),
            ),
            IconButton(
              key: Key('remove-order-$i'),
              tooltip: context.l10n.grpDRemoveOrdering,
              icon: const TfIcon(TfIcons.close),
              onPressed: () => onChanged([
                for (var k = 0; k < order.length; k++)
                  if (k != i) order[k],
              ]),
            ),
          ],
        ),
      if (fields.isNotEmpty)
        TextButton.icon(
          key: const Key('add-order'),
          icon: const TfIcon(TfIcons.sort),
          label: Text(context.l10n.grpDOrderBy),
          onPressed: () => onChanged([...order, FilterOrder(fields.first.ref)]),
        ),
    ],
  );
}
