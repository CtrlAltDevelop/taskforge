import 'package:taskforge/core/ui/page/tf_tile.dart';
import 'package:taskforge/core/ui/page/tf_select_field.dart';
import 'package:taskforge/core/ui/page/tf_dialog_frame.dart';
import 'package:taskforge/core/ui/tf/tf_field.dart';
import 'package:taskforge/core/ui/tf/tf_button.dart';
import 'package:taskforge/core/ui/tf_icons.dart';
import 'package:material_ui/material_ui.dart';

import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/features/fields/domain/field.dart';
import 'package:taskforge/features/fields/presentation/field_input.dart';
import 'package:taskforge/features/members/domain/members.dart';
import 'package:taskforge/core/ui/tokens/spacing.dart';

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
      _options.add(
        _EditableOption('', context.l10n.grpEOptionN, optionPalette.first),
      );
    }
  });

  void _save() {
    final name = _name.text.trim();
    final labels = _asOptions.map((o) => o.label.toLowerCase()).toList();
    String? problem;
    if (name.isEmpty) {
      problem = context.l10n.grpEProblemName;
    } else if (_type.hasOptions && labels.isEmpty) {
      problem = context.l10n.grpEProblemOne;
    } else if (labels.any((l) => l.isEmpty)) {
      problem = context.l10n.grpEProblemLabel;
    } else if (labels.toSet().length != labels.length) {
      problem = context.l10n.grpEProblemDup;
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
  Widget build(BuildContext context) => TfDialogFrame(
    title: _editing ? context.l10n.grpEEditField : context.l10n.grpENewField,
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
              decoration: InputDecoration(
                labelText: context.l10n.grpEName,
                counterText: '',
              ),
            ),
            const SizedBox(height: TfSpace.md),
            TfSelectField<FieldType>(
              key: const Key('field-type'),
              options: {for (final t in _types) t: t.labelIn(context.l10n)},
              value: _type,
              onChanged: _types.length == 1 ? null : (t) => _setType(t),
              label: context.l10n.grpEType,
              expand: true,
            ),
            const SizedBox(height: TfSpace.md),
            if (_type.hasOptions) ...[
              const SizedBox(height: TfSpace.lg),
              Text(
                context.l10n.grpEOptions,
                style: Theme.of(context).textTheme.labelLarge,
              ),
              for (final (i, o) in _options.indexed)
                Row(
                  key: Key('option-row-$i'),
                  children: [
                    PopupMenuButton<String>(
                      key: Key('option-color-$i'),
                      tooltip: context.l10n.grpEColour,
                      icon: TfIcon(
                        TfIcons.circle,
                        color: optionColor(
                          FieldOption(id: '', label: '', color: o.color),
                        ),
                      ),
                      onSelected: (c) => setState(() => o.color = c),
                      itemBuilder: (_) => [
                        for (final c in optionPalette)
                          PopupMenuItem(
                            value: c,
                            child: TfIcon(
                              TfIcons.circle,
                              color: optionColor(
                                FieldOption(id: '', label: '', color: c),
                              ),
                            ),
                          ),
                      ],
                    ),
                    Expanded(
                      child: TfTextField(
                        key: Key('option-label-$i'),
                        controller: o.controller,
                        hint: context.l10n.grpELabel,
                      ),
                    ),
                    TfIconButton(
                      key: Key('option-remove-$i'),
                      icon: TfIcons.close,
                      tooltip: context.l10n.grpERemoveOption,
                      onPressed: () => setState(() {
                        _options.removeAt(i).controller.dispose();
                        if (_default == o.id) _default = '';
                      }),
                    ),
                  ],
                ),
              TfButton(
                key: const Key('option-add'),
                label: context.l10n.grpEAddOption,
                variant: TfButtonVariant.ghost,
                icon: TfIcons.plus,
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
            TfToggleTile(
              key: const Key('field-required'),
              value: _required,
              onChanged: (v) => setState(() => _required = v),
              title: context.l10n.grpERequired,
              subtitle: context.l10n.grpERequiredSub,
            ),
            if (!_type.hasOptions || _options.every((o) => o.id.isNotEmpty))
              FieldInput(
                key: ValueKey('default-$_type-${_options.length}'),
                field: CustomField(
                  id: 'default',
                  projectId: '',
                  name: context.l10n.grpEDefaultValue,
                  type: _type,
                  options: _preview.options,
                ),
                value: _default,
                members: widget.members,
                onChanged: (v) => setState(() => _default = v),
              ),
            const SizedBox(height: TfSpace.md),
            Text(
              context.l10n.grpEShowIn,
              style: Theme.of(context).textTheme.labelLarge,
            ),
            Wrap(
              spacing: 8,
              children: [
                for (final e in hideableViews.entries)
                  FilterChip(
                    key: Key('show-in-${e.key}'),
                    label: Text(
                      hideableViewLabelIn(context.l10n, e.key) ?? e.value,
                    ),
                    selected: !_hidden.contains(e.key),
                    onSelected: (on) => setState(
                      () => on ? _hidden.remove(e.key) : _hidden.add(e.key),
                    ),
                  ),
              ],
            ),
            if (_problem != null)
              Padding(
                padding: const EdgeInsets.only(top: TfSpace.md),
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
      TfButton(
        key: const Key('field-cancel'),
        label: context.l10n.grpECancel,
        variant: TfButtonVariant.ghost,
        onPressed: () => Navigator.pop(context),
      ),
      TfButton(
        key: const Key('field-save'),
        label: _editing ? context.l10n.grpESave : context.l10n.grpEAddField,
        variant: TfButtonVariant.primary,
        onPressed: _save,
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
  Widget build(BuildContext context) => TfDialogFrame(
    title: context.l10n.grpEOptionsInUse,
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final e in widget.usage.entries)
          Padding(
            padding: const EdgeInsets.only(bottom: TfSpace.md),
            child: TfSelectField(
              key: Key('remap-${e.key}'),
              options: {
                '': context.l10n.grpENothingClear,
                for (final o in widget.kept)
                  if (o.id.isNotEmpty) o.id: o.label,
              },
              value: _choice[e.key],
              onChanged: (v) => setState(() => _choice[e.key] = v),
              label: context.l10n.grpERemapLabel(
                widget.field.option(e.key)?.label ??
                    context.l10n.grpERemovedOption,
                e.value,
              ),
              expand: true,
            ),
          ),
      ],
    ),
    actions: [
      TfButton(
        key: const Key('remap-cancel'),
        label: context.l10n.grpECancel,
        variant: TfButtonVariant.ghost,
        onPressed: () => Navigator.pop(context),
      ),
      TfButton(
        key: const Key('remap-apply'),
        label: context.l10n.grpEApply,
        variant: TfButtonVariant.primary,
        onPressed: () =>
            Navigator.pop(context, Map<String, String>.of(_choice)),
      ),
    ],
  );
}
