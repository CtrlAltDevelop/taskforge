import 'package:flutter/material.dart';

import 'package:taskforge/features/fields/domain/field.dart';
import 'package:taskforge/features/members/domain/members.dart';

Color? optionColor(FieldOption option) {
  final hex = option.color;
  if (hex.length != 7 || !hex.startsWith('#')) return null;
  final value = int.tryParse(hex.substring(1), radix: 16);
  return value == null ? null : Color(0xFF000000 | value);
}

/// The input for one custom field, by type. [onChanged] gets the new value in
/// its wire form (empty clears it). Typed text is checked first and only a
/// valid (or empty, when allowed) value is sent. [errorText] highlights a
/// missing required value.
class FieldInput extends StatelessWidget {
  const FieldInput({
    super.key,
    required this.field,
    required this.value,
    required this.onChanged,
    this.enabled = true,
    this.members = const [],
    this.errorText,
  });

  final CustomField field;
  final String value;
  final ValueChanged<String> onChanged;
  final bool enabled;
  final List<Member> members;
  final String? errorText;

  Key get _key => Key('field-${field.id}');

  String get _label => field.required ? '${field.name} *' : field.name;

  @override
  Widget build(BuildContext context) => switch (field.type) {
    FieldType.text || FieldType.url || FieldType.number => _CommitText(
      key: _key,
      field: field,
      value: value,
      enabled: enabled,
      errorText: errorText,
      onChanged: onChanged,
      label: _label,
      keyboard: field.type == FieldType.number
          ? const TextInputType.numberWithOptions(decimal: true, signed: true)
          : field.type == FieldType.url
          ? TextInputType.url
          : TextInputType.text,
    ),
    FieldType.money => _MoneyInput(
      key: _key,
      field: field,
      value: value,
      enabled: enabled,
      errorText: errorText,
      onChanged: onChanged,
      label: _label,
    ),
    FieldType.date => _DateInput(
      key: _key,
      value: value,
      enabled: enabled,
      errorText: errorText,
      onChanged: onChanged,
      label: _label,
      clearable: !field.required,
    ),
    FieldType.checkbox => SwitchListTile(
      key: _key,
      contentPadding: EdgeInsets.zero,
      title: Text(_label),
      value: value == 'true',
      onChanged: enabled ? (on) => onChanged(on ? 'true' : 'false') : null,
    ),
    FieldType.select => _Choice<String>(
      key: _key,
      label: _label,
      value: field.option(value) == null ? null : value,
      enabled: enabled,
      errorText: errorText,
      allowNone: !field.required,
      items: [
        for (final o in field.options)
          (value: o.id, label: o.label, color: optionColor(o)),
      ],
      onChanged: (v) => onChanged(v ?? ''),
    ),
    FieldType.user => _Choice<String>(
      key: _key,
      label: _label,
      value: members.any((m) => m.userId == value) ? value : null,
      enabled: enabled,
      errorText: errorText,
      allowNone: !field.required,
      items: [
        for (final m in members) (value: m.userId, label: m.label, color: null),
      ],
      onChanged: (v) => onChanged(v ?? ''),
    ),
    FieldType.multiselect => _MultiChoice(
      key: _key,
      field: field,
      selected: splitIds(value).toSet(),
      enabled: enabled,
      errorText: errorText,
      label: _label,
      onChanged: (ids) => onChanged(
        [
          for (final o in field.options)
            if (ids.contains(o.id)) o.id,
        ].join(','),
      ),
    ),
  };
}

class _CommitText extends StatefulWidget {
  const _CommitText({
    super.key,
    required this.field,
    required this.value,
    required this.enabled,
    required this.onChanged,
    required this.label,
    required this.keyboard,
    this.errorText,
  });

  final CustomField field;
  final String value;
  final bool enabled;
  final ValueChanged<String> onChanged;
  final String label;
  final TextInputType keyboard;
  final String? errorText;

  @override
  State<_CommitText> createState() => _CommitTextState();
}

class _CommitTextState extends State<_CommitText> {
  late final _controller = TextEditingController(text: widget.value);
  final _focus = FocusNode();
  late var _saved = widget.value;
  String? _problem;

  /// Saves once per change (Enter and then losing focus must not send twice);
  /// a value that is not valid, or an empty required one, is not sent.
  void _commit(String text) {
    final trimmed = text.trim();
    final problem = trimmed.isEmpty && widget.field.required
        ? 'Required'
        : validateFieldValue(widget.field.type, trimmed);
    setState(() => _problem = problem);
    if (problem != null || trimmed == _saved) return;
    _saved = trimmed;
    widget.onChanged(trimmed);
  }

  @override
  void initState() {
    super.initState();
    _focus.addListener(() {
      if (!_focus.hasFocus) _commit(_controller.text);
    });
  }

  @override
  void didUpdateWidget(_CommitText old) {
    super.didUpdateWidget(old);
    if (widget.value != old.value) _saved = widget.value;
    if (!_focus.hasFocus && widget.value != _controller.text) {
      _controller.text = widget.value;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => TextField(
    controller: _controller,
    focusNode: _focus,
    enabled: widget.enabled,
    keyboardType: widget.keyboard,
    decoration: InputDecoration(
      labelText: widget.label,
      errorText: _problem ?? widget.errorText,
      border: const OutlineInputBorder(),
    ),
    onSubmitted: _commit,
  );
}

class _MoneyInput extends StatefulWidget {
  const _MoneyInput({
    super.key,
    required this.field,
    required this.value,
    required this.enabled,
    required this.onChanged,
    required this.label,
    this.errorText,
  });

  final CustomField field;
  final String value;
  final bool enabled;
  final ValueChanged<String> onChanged;
  final String label;
  final String? errorText;

  @override
  State<_MoneyInput> createState() => _MoneyInputState();
}

class _MoneyInputState extends State<_MoneyInput> {
  late final _amount = TextEditingController(
    text: splitMoney(widget.value).amount,
  );
  late final _currency = TextEditingController(
    text: splitMoney(widget.value).currency,
  );
  final _focusAmount = FocusNode();
  final _focusCurrency = FocusNode();
  late var _saved = widget.value;
  String? _problem;

  void _commit() {
    final joined = joinMoney(_amount.text, _currency.text);
    final problem = joined.isEmpty && widget.field.required
        ? 'Required'
        : validateFieldValue(FieldType.money, joined);
    setState(() => _problem = problem);
    if (problem != null || joined == _saved) return;
    _saved = joined;
    widget.onChanged(joined);
  }

  @override
  void initState() {
    super.initState();
    for (final f in [_focusAmount, _focusCurrency]) {
      f.addListener(() {
        // Commit when focus leaves both boxes.
        if (!_focusAmount.hasFocus && !_focusCurrency.hasFocus) _commit();
      });
    }
  }

  @override
  void dispose() {
    _amount.dispose();
    _currency.dispose();
    _focusAmount.dispose();
    _focusCurrency.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(
        flex: 3,
        child: TextField(
          key: Key('money-amount-${widget.field.id}'),
          controller: _amount,
          focusNode: _focusAmount,
          enabled: widget.enabled,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: widget.label,
            errorText: _problem ?? widget.errorText,
            border: const OutlineInputBorder(),
          ),
          onSubmitted: (_) => _commit(),
        ),
      ),
      const SizedBox(width: 8),
      Expanded(
        flex: 2,
        child: TextField(
          key: Key('money-currency-${widget.field.id}'),
          controller: _currency,
          focusNode: _focusCurrency,
          enabled: widget.enabled,
          maxLength: 3,
          textCapitalization: TextCapitalization.characters,
          decoration: const InputDecoration(
            labelText: 'Currency',
            counterText: '',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (_) => _commit(),
        ),
      ),
    ],
  );
}

class _DateInput extends StatelessWidget {
  const _DateInput({
    super.key,
    required this.value,
    required this.enabled,
    required this.onChanged,
    required this.label,
    required this.clearable,
    this.errorText,
  });

  final String value;
  final bool enabled;
  final ValueChanged<String> onChanged;
  final String label;
  final bool clearable;
  final String? errorText;

  String _format(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: enabled
        ? () async {
            final now = DateTime.now();
            final picked = await showDatePicker(
              context: context,
              initialDate: DateTime.tryParse(value) ?? now,
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (picked != null) onChanged(_format(picked));
          }
        : null,
    child: InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        errorText: errorText,
        border: const OutlineInputBorder(),
        suffixIcon: clearable && value.isNotEmpty && enabled
            ? IconButton(
                tooltip: 'Clear',
                icon: const Icon(Icons.clear),
                onPressed: () => onChanged(''),
              )
            : const Icon(Icons.calendar_today, size: 18),
      ),
      child: Text(value.isEmpty ? ' ' : value),
    ),
  );
}

typedef _Item<T> = ({T value, String label, Color? color});

class _Choice<T> extends StatelessWidget {
  const _Choice({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.enabled,
    required this.onChanged,
    required this.allowNone,
    this.errorText,
  });

  final String label;
  final T? value;
  final List<_Item<T>> items;
  final bool enabled;
  final bool allowNone;
  final String? errorText;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) => DropdownButtonFormField<T>(
    isExpanded: true,
    initialValue: value,
    decoration: InputDecoration(
      labelText: label,
      errorText: errorText,
      border: const OutlineInputBorder(),
    ),
    items: [
      if (allowNone)
        DropdownMenuItem<T>(
          child: Text(
            'None',
            style: TextStyle(color: Theme.of(context).hintColor),
          ),
        ),
      for (final i in items)
        DropdownMenuItem<T>(
          value: i.value,
          child: Row(
            children: [
              if (i.color != null) ...[
                Icon(Icons.circle, size: 12, color: i.color),
                const SizedBox(width: 8),
              ],
              Flexible(child: Text(i.label, overflow: TextOverflow.ellipsis)),
            ],
          ),
        ),
    ],
    onChanged: enabled ? onChanged : null,
  );
}

class _MultiChoice extends StatelessWidget {
  const _MultiChoice({
    super.key,
    required this.field,
    required this.selected,
    required this.enabled,
    required this.onChanged,
    required this.label,
    this.errorText,
  });

  final CustomField field;
  final Set<String> selected;
  final bool enabled;
  final ValueChanged<Set<String>> onChanged;
  final String label;
  final String? errorText;

  @override
  Widget build(BuildContext context) => InputDecorator(
    decoration: InputDecoration(
      labelText: label,
      errorText: errorText,
      border: const OutlineInputBorder(),
    ),
    child: Wrap(
      spacing: 8,
      children: [
        for (final o in field.options)
          FilterChip(
            key: Key('option-${o.id}'),
            avatar: optionColor(o) == null
                ? null
                : Icon(Icons.circle, size: 12, color: optionColor(o)),
            label: Text(o.label),
            selected: selected.contains(o.id),
            onSelected: enabled
                ? (on) => onChanged(
                    on ? {...selected, o.id} : ({...selected}..remove(o.id)),
                  )
                : null,
          ),
      ],
    ),
  );
}
