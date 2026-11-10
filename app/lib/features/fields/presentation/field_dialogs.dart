import 'package:flutter/material.dart';

import 'package:taskforge/features/fields/domain/field.dart';
import 'package:taskforge/features/fields/presentation/field_input.dart';
import 'package:taskforge/features/members/domain/members.dart';

const optionPalette = [
  '#E5484D',
  '#F76B15',
  '#F5D90A',
  '#30A46C',
  '#0090FF',
  '#6E56CF',
  '#D6409F',
  '#8B8D98',
];

/// Create or edit a field: name, type, options with colours, required,
/// default and the views that show it. Pops a [FieldDraft].
class FieldEditorDialog extends StatefulWidget {
  const FieldEditorDialog({super.key, this.field, this.members = const []});

  /// The field being edited; null creates one.
  final CustomField? field;
  final List<Member> members;

  @override
  State<FieldEditorDialog> createState() => _FieldEditorDialogState();
}

class _EditableOption {
  _EditableOption(this.id, String label, this.color)
    : controller = TextEditingController(text: label);

  final String id;
  final TextEditingController controller;
  String color;
}

class _FieldEditorDialogState extends State<FieldEditorDialog> {
  late final _name = TextEditingController(text: widget.field?.name ?? '');
  late FieldType _type = widget.field?.type ?? FieldType.text;
  late final _options = [
    for (final o in widget.field?.options ?? const <FieldOption>[])
      _EditableOption(o.id, o.label, o.color),
  ];
  late var _required = widget.field?.required ?? false;
  late var _default = widget.field?.defaultValue ?? '';
  late final _hidden = {...?widget.field?.hiddenViews};
  String? _problem;

  bool get _editing => widget.field != null;

  /// Only text and URL fields convert; anything else needs a new field.
  List<FieldType> get _types {
    final current = widget.field?.type;
    if (current == null) return FieldType.values;
    return switch (current) {
      FieldType.text || FieldType.url => [FieldType.text, FieldType.url],
      _ => [current],
    };
  }

  @override
  void dispose() {
    _name.dispose();
    for (final o in _options) {
      o.controller.dispose();
    }
    super.dispose();
  }

  List<FieldOption> get _asOptions => [
    for (final o in _options)
      FieldOption(id: o.id, label: o.controller.text.trim(), color: o.color),
  ];

  CustomField get _preview => CustomField(
    id: widget.field?.id ?? 'new',
    projectId: widget.field?.projectId ?? '',
    name: _name.text,
    type: _type,
    options: [
      for (final o in _asOptions)
        if (o.id.isNotEmpty) o,
    ],
    required: _required,
  );

  void _setType(FieldType type) => setState(() {
    _type = type;
    _default = '';
    if (!type.hasOptions) {
      _options.clear();
    } else if (_options.isEmpty) {
      _options.add(_EditableOption('', 'Option 1', optionPalette.first));
    }
  });

  void _save() {
    final name = _name.text.trim();
    final labels = _asOptions.map((o) => o.label.toLowerCase()).toList();
    String? problem;
    if (name.isEmpty) {
      problem = 'Give the field a name.';
    } else if (_type.hasOptions && labels.isEmpty) {
      problem = 'Add at least one option.';
    } else if (labels.any((l) => l.isEmpty)) {
      problem = 'Every option needs a label.';
    } else if (labels.toSet().length != labels.length) {
      problem = 'Two options have the same label.';
    }
    if (problem != null) {
      setState(() => _problem = problem);
      return;
    }
    Navigator.pop(
      context,
      FieldDraft(
        name: name,
        type: _type,
        options: _asOptions,
        required: _required,
        defaultValue: _defaultValid ? _default : '',
        hiddenViews: [
          for (final v in hideableViews.keys)
            if (_hidden.contains(v)) v,
        ],
      ),
    );
  }

  bool get _defaultValid =>
      validateFieldValue(_type, _default) == null &&
      (_type != FieldType.select || _preview.option(_default) != null);

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(_editing ? 'Edit field' : 'New field'),
    content: SizedBox(
      width: 460,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              key: const Key('field-name'),
              controller: _name,
              maxLength: maxFieldNameLength,
              decoration: const InputDecoration(
                labelText: 'Name',
                counterText: '',
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<FieldType>(
              key: const Key('field-type'),
              initialValue: _type,
              decoration: const InputDecoration(labelText: 'Type'),
              items: [
                for (final t in _types)
                  DropdownMenuItem(value: t, child: Text(t.label)),
              ],
              onChanged: _types.length == 1
                  ? null
                  : (t) => t == null ? null : _setType(t),
            ),
            if (_type.hasOptions) ...[
              const SizedBox(height: 16),
              Text('Options', style: Theme.of(context).textTheme.labelLarge),
              for (final (i, o) in _options.indexed)
                Row(
                  key: Key('option-row-$i'),
                  children: [
                    PopupMenuButton<String>(
                      key: Key('option-color-$i'),
                      tooltip: 'Colour',
                      icon: Icon(
                        Icons.circle,
                        color: optionColor(
                          FieldOption(id: '', label: '', color: o.color),
                        ),
                      ),
                      onSelected: (c) => setState(() => o.color = c),
                      itemBuilder: (_) => [
                        for (final c in optionPalette)
                          PopupMenuItem(
                            value: c,
                            child: Icon(
                              Icons.circle,
                              color: optionColor(
                                FieldOption(id: '', label: '', color: c),
                              ),
                            ),
                          ),
                      ],
                    ),
                    Expanded(
                      child: TextField(
                        key: Key('option-label-$i'),
                        controller: o.controller,
                        decoration: const InputDecoration(hintText: 'Label'),
                      ),
                    ),
                    IconButton(
                      key: Key('option-remove-$i'),
                      tooltip: 'Remove option',
                      icon: const Icon(Icons.close),
                      onPressed: () => setState(() {
                        _options.removeAt(i).controller.dispose();
                        if (_default == o.id) _default = '';
                      }),
                    ),
                  ],
                ),
              TextButton.icon(
                key: const Key('option-add'),
                icon: const Icon(Icons.add),
                label: const Text('Add option'),
                onPressed: () => setState(
                  () => _options.add(
                    _EditableOption(
                      '',
                      '',
                      optionPalette[_options.length % optionPalette.length],
                    ),
                  ),
                ),
              ),
            ],
            SwitchListTile(
              key: const Key('field-required'),
              contentPadding: EdgeInsets.zero,
              title: const Text('Required'),
              subtitle: const Text('New tasks must have a value.'),
              value: _required,
              onChanged: (v) => setState(() => _required = v),
            ),
            if (!_type.hasOptions || _options.every((o) => o.id.isNotEmpty))
              FieldInput(
                key: ValueKey('default-$_type-${_options.length}'),
                field: CustomField(
                  id: 'default',
                  projectId: '',
                  name: 'Default value',
                  type: _type,
                  options: _preview.options,
                ),
                value: _default,
                members: widget.members,
                onChanged: (v) => setState(() => _default = v),
              ),
            const SizedBox(height: 12),
            Text('Show in', style: Theme.of(context).textTheme.labelLarge),
            Wrap(
              spacing: 8,
              children: [
                for (final e in hideableViews.entries)
                  FilterChip(
                    key: Key('show-in-${e.key}'),
                    label: Text(e.value),
                    selected: !_hidden.contains(e.key),
                    onSelected: (on) => setState(
                      () => on ? _hidden.remove(e.key) : _hidden.add(e.key),
                    ),
                  ),
              ],
            ),
            if (_problem != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  _problem!,
                  key: const Key('field-problem'),
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
          ],
        ),
      ),
    ),
    actions: [
      TextButton(
        key: const Key('field-cancel'),
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      FilledButton(
        key: const Key('field-save'),
        onPressed: _save,
        child: Text(_editing ? 'Save' : 'Add field'),
      ),
    ],
  );
}

/// Options were removed that values still use: pick what each becomes. Pops
/// the remap (removed option id -> kept option id, or empty to clear).
class RemapDialog extends StatefulWidget {
  const RemapDialog({
    super.key,
    required this.field,
    required this.usage,
    required this.kept,
  });

  final CustomField field;

  /// Removed option id -> how many values hold it.
  final Map<String, int> usage;
  final List<FieldOption> kept;

  @override
  State<RemapDialog> createState() => _RemapDialogState();
}

class _RemapDialogState extends State<RemapDialog> {
  late final _choice = {for (final id in widget.usage.keys) id: ''};

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Options are in use'),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final e in widget.usage.entries)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: DropdownButtonFormField<String>(
              key: Key('remap-${e.key}'),
              initialValue: _choice[e.key],
              decoration: InputDecoration(
                labelText:
                    '${widget.field.option(e.key)?.label ?? 'Removed option'}'
                    ' (${e.value} ${e.value == 1 ? 'value' : 'values'}) becomes',
              ),
              items: [
                const DropdownMenuItem(
                  value: '',
                  child: Text('Nothing (clear)'),
                ),
                for (final o in widget.kept)
                  if (o.id.isNotEmpty)
                    DropdownMenuItem(value: o.id, child: Text(o.label)),
              ],
              onChanged: (v) => setState(() => _choice[e.key] = v ?? ''),
            ),
          ),
      ],
    ),
    actions: [
      TextButton(
        key: const Key('remap-cancel'),
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      FilledButton(
        key: const Key('remap-apply'),
        onPressed: () =>
            Navigator.pop(context, Map<String, String>.of(_choice)),
        child: const Text('Apply'),
      ),
    ],
  );
}
