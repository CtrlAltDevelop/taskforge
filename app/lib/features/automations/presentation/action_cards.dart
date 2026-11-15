import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/features/automations/domain/automations.dart';
import 'package:taskforge/features/fields/application/fields_providers.dart';
import 'package:taskforge/features/fields/domain/field.dart';
import 'package:taskforge/features/members/application/members_providers.dart';
import 'package:taskforge/features/tasks/domain/tasks.dart';
import 'package:taskforge/features/workflows/application/workflows_providers.dart';
import 'package:taskforge/l10n/gen/app_localizations.dart';

/// Names for the ids a rule holds: statuses, custom fields and people.
class Lookups {
  const Lookups({
    this.statuses = const {},
    this.fields = const {},
    this.dateFields = const {},
    this.users = const {},
  });

  final Map<String, String> statuses;

  /// `field:<id>` to name.
  final Map<String, String> fields;
  final Set<String> dateFields;
  final Map<String, String> users;

  /// The name of status [id]; [loc] is the language for a missing one
  /// (English when left out).
  String status(String id, [AppLocalizations? loc]) =>
      statuses[id] ??
      (loc ?? lookupAppLocalizations(const Locale('en'))).grpCAutoDeletedStatus;

  String user(String id, [AppLocalizations? loc]) =>
      users[id] ??
      (loc ?? lookupAppLocalizations(const Locale('en'))).grpCAutoUnknownPerson;
}

/// Statuses, custom fields and members of one project, from the existing
/// providers; empty until they load.
final lookupsProvider = Provider.autoDispose.family<Lookups, String>((
  ref,
  project,
) {
  final workflow = ref.watch(workflowProvider(project)).value;
  final fields = ref.watch(fieldsProvider(project)).value ?? const [];
  final members = ref.watch(membersProvider).value ?? const [];
  return Lookups(
    statuses: {for (final s in workflow?.statuses ?? []) s.id: s.name},
    fields: {for (final f in fields) '$customFieldPrefix${f.id}': f.name},
    dateFields: {
      for (final f in fields)
        if (f.type == FieldType.date) '$customFieldPrefix${f.id}',
    },
    users: {for (final m in members) m.userId: m.displayName},
  );
});

/// A labelled dropdown over [items]; a value that is not offered (a deleted
/// status) shows as empty.
class Choice extends StatelessWidget {
  const Choice({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.enabled = true,
    this.emptyLabel,
  });

  final String label;
  final String value;
  final Map<String, String> items;
  final ValueChanged<String> onChanged;
  final bool enabled;

  /// When set, an entry with the empty value (for "any").
  final String? emptyLabel;

  @override
  Widget build(BuildContext context) {
    final offered = {'': ?emptyLabel, ...items};
    return DropdownButtonFormField<String>(
      initialValue: offered.containsKey(value) ? value : null,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items: [
        for (final e in offered.entries)
          DropdownMenuItem(
            value: e.key,
            child: Text(e.value, overflow: TextOverflow.ellipsis),
          ),
      ],
      onChanged: enabled ? (v) => onChanged(v ?? '') : null,
    );
  }
}

/// The "When" card body.
class TriggerEditor extends StatelessWidget {
  const TriggerEditor({
    super.key,
    required this.trigger,
    required this.lookups,
    required this.onChanged,
    this.enabled = true,
  });

  final Trigger trigger;
  final Lookups lookups;
  final ValueChanged<Trigger> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Choice(
        key: const Key('trigger-type'),
        label: context.l10n.grpCAutoEvent,
        value: trigger.type.wire,
        items: {
          for (final t in TriggerType.values) t.wire: t.labelIn(context.l10n),
        },
        enabled: enabled,
        onChanged: (v) =>
            onChanged(Trigger(type: TriggerType.tryParse(v) ?? trigger.type)),
      ),
      const SizedBox(height: 8),
      ...switch (trigger.type) {
        TriggerType.statusChanged => [
          Choice(
            key: const Key('trigger-status'),
            label: context.l10n.grpCAutoMovesToLabel,
            value: trigger.toStatus,
            items: lookups.statuses,
            emptyLabel: context.l10n.grpCAutoAnyStatus,
            enabled: enabled,
            onChanged: (v) => onChanged(trigger.copyWith(toStatus: v)),
          ),
        ],
        TriggerType.fieldChanged => [
          Choice(
            key: const Key('trigger-field'),
            label: context.l10n.grpCField,
            value: trigger.field,
            items: {...watchableFields, ...lookups.fields},
            enabled: enabled,
            onChanged: (v) => onChanged(trigger.copyWith(field: v)),
          ),
        ],
        TriggerType.assigned => [
          Choice(
            key: const Key('trigger-user'),
            label: context.l10n.grpCAutoAssignedPerson,
            value: trigger.userId,
            items: lookups.users,
            emptyLabel: context.l10n.grpCAutoAnyone,
            enabled: enabled,
            onChanged: (v) => onChanged(trigger.copyWith(userId: v)),
          ),
        ],
        TriggerType.dueDateReached => [
          TextFormField(
            key: const Key('trigger-days'),
            initialValue: '${trigger.daysBefore}',
            enabled: enabled,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: context.l10n.grpCAutoDaysLabel(maxDaysBefore),
              border: const OutlineInputBorder(),
            ),
            onChanged: (v) =>
                onChanged(trigger.copyWith(daysBefore: int.tryParse(v) ?? -1)),
          ),
        ],
        _ => const <Widget>[],
      },
    ],
  );
}

/// One "Then" card body.
class ActionEditor extends StatefulWidget {
  const ActionEditor({
    super.key,
    required this.action,
    required this.lookups,
    required this.onChanged,
    this.enabled = true,
  });

  final RuleAction action;
  final Lookups lookups;
  final ValueChanged<RuleAction> onChanged;
  final bool enabled;

  @override
  State<ActionEditor> createState() => _ActionEditorState();
}

class _ActionEditorState extends State<ActionEditor> {
  late final _text = TextEditingController(text: widget.action.text);
  late final _value = TextEditingController(text: widget.action.value);
  late final _url = TextEditingController(text: widget.action.url);

  RuleAction get _a => widget.action;

  @override
  void dispose() {
    _text.dispose();
    _value.dispose();
    _url.dispose();
    super.dispose();
  }

  void _set(RuleAction a) => widget.onChanged(a);

  void _insert(TextEditingController c, String token, void Function() sync) {
    c.text = '${c.text}$token';
    c.selection = TextSelection.collapsed(offset: c.text.length);
    sync();
  }

  Widget _hints(TextEditingController c, void Function() sync) => Padding(
    padding: const EdgeInsets.only(top: 6),
    child: Wrap(
      spacing: 6,
      runSpacing: 4,
      children: [
        for (final p in placeholders)
          ActionChip(
            key: Key('placeholder-$p'),
            label: Text(p),
            visualDensity: VisualDensity.compact,
            onPressed: widget.enabled ? () => _insert(c, p, sync) : null,
          ),
      ],
    ),
  );

  Widget _textBox(String label, int max, {int lines = 3}) => TextField(
    key: const Key('action-text'),
    controller: _text,
    readOnly: !widget.enabled,
    minLines: 1,
    maxLines: lines,
    maxLength: max,
    onChanged: (v) => _set(_a.copyWith(text: v)),
    decoration: InputDecoration(
      labelText: label,
      border: const OutlineInputBorder(),
      helperText: context.l10n.grpCAutoTokensHelp(
        '{title} {key} {status} {today} {automation}',
      ),
    ),
  );

  void _toggle(List<String> list, String id, bool on, bool recipients) {
    final next = [
      for (final x in list)
        if (x != id) x,
      if (on) id,
    ];
    _set(recipients ? _a.copyWith(to: next) : _a.copyWith(userIds: next));
  }

  Widget _people(List<String> chosen, {required bool recipients}) => Wrap(
    spacing: 6,
    runSpacing: 4,
    children: [
      if (recipients)
        for (final w in recipientWords)
          FilterChip(
            key: Key('to-$w'),
            label: Text(w),
            selected: chosen.contains(w),
            onSelected: widget.enabled
                ? (on) => _toggle(chosen, w, on, true)
                : null,
          ),
      for (final e in widget.lookups.users.entries)
        FilterChip(
          key: Key('${recipients ? 'to' : 'user'}-${e.key}'),
          label: Text(e.value),
          selected: chosen.contains(e.key),
          onSelected: widget.enabled
              ? (on) => _toggle(chosen, e.key, on, recipients)
              : null,
        ),
    ],
  );

  Widget _setField() {
    final custom = _a.field.startsWith(customFieldPrefix);
    final isDate =
        dateFields.contains(_a.field) ||
        widget.lookups.dateFields.contains(_a.field);
    void sync() => _set(_a.copyWith(value: _value.text));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Choice(
          key: const Key('action-field'),
          label: context.l10n.grpCField,
          value: _a.field,
          items: {...settableFields, ...widget.lookups.fields},
          enabled: widget.enabled,
          onChanged: (v) {
            _value.clear();
            _set(_a.copyWith(field: v, value: ''));
          },
        ),
        const SizedBox(height: 8),
        if (_a.field == 'priority')
          Choice(
            key: const Key('action-priority'),
            label: context.l10n.grpCValue,
            value: _a.value,
            items: {
              for (final p in TaskPriority.values)
                if (p != TaskPriority.none) p.wire: p.labelIn(context.l10n),
              'none': TaskPriority.none.labelIn(context.l10n),
            },
            enabled: widget.enabled,
            onChanged: (v) => _set(_a.copyWith(value: v)),
          )
        else
          TextField(
            key: const Key('action-value'),
            controller: _value,
            readOnly: !widget.enabled,
            onChanged: (_) => sync(),
            decoration: InputDecoration(
              labelText: context.l10n.grpCValue,
              hintText: isDate ? context.l10n.grpCAutoDateHint : null,
              border: const OutlineInputBorder(),
            ),
          ),
        if (isDate || custom)
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: ActionChip(
                key: const Key('use-today'),
                label: Text(context.l10n.grpCAutoUseToken(todayToken)),
                onPressed: widget.enabled && isDate
                    ? () {
                        _value.text = todayToken;
                        sync();
                      }
                    : null,
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final body = switch (_a.type) {
      ActionType.setField => _setField(),
      ActionType.setStatus => Choice(
        key: const Key('action-status'),
        label: context.l10n.grpCStatus,
        value: _a.status,
        items: widget.lookups.statuses,
        enabled: widget.enabled,
        onChanged: (v) => _set(_a.copyWith(status: v)),
      ),
      ActionType.setAssignee => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Choice(
            key: const Key('action-mode'),
            label: context.l10n.grpCAutoHow,
            value: _a.mode,
            items: {
              'set': context.l10n.grpCAutoReplaceAssignees,
              'add': context.l10n.grpCAutoAdd,
              'clear': context.l10n.grpCAutoRemoveEveryone,
            },
            enabled: widget.enabled,
            onChanged: (v) => _set(_a.copyWith(mode: v)),
          ),
          if (_a.mode != 'clear') ...[
            const SizedBox(height: 8),
            _people(_a.userIds, recipients: false),
          ],
        ],
      ),
      ActionType.addComment => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _textBox(context.l10n.grpCComment, maxCommentText),
          _hints(_text, () => _set(_a.copyWith(text: _text.text))),
        ],
      ),
      ActionType.createSubtask => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _textBox(context.l10n.grpCAutoSubtaskTitle, maxTitleText, lines: 2),
          _hints(_text, () => _set(_a.copyWith(text: _text.text))),
        ],
      ),
      ActionType.notify => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _people(_a.to, recipients: true),
          const SizedBox(height: 8),
          _textBox(context.l10n.grpCAutoMessage, maxTitleText, lines: 2),
          _hints(_text, () => _set(_a.copyWith(text: _text.text))),
        ],
      ),
      ActionType.webhook => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            key: const Key('action-url'),
            controller: _url,
            readOnly: !widget.enabled,
            onChanged: (v) => _set(_a.copyWith(url: v)),
            decoration: InputDecoration(
              labelText: context.l10n.grpCAutoAddress,
              hintText: 'https://example.com/hook',
              helperText: context.l10n.grpCAutoAddressHelp,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          Choice(
            key: const Key('action-method'),
            label: context.l10n.grpCAutoMethod,
            value: _a.method,
            items: const {'POST': 'POST', 'PUT': 'PUT'},
            enabled: widget.enabled,
            onChanged: (v) => _set(_a.copyWith(method: v)),
          ),
        ],
      ),
    };
    final problem = actionProblem(_a);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Choice(
          key: const Key('action-type'),
          label: context.l10n.grpCAutoDoThis,
          value: _a.type.wire,
          items: {
            for (final t in ActionType.values) t.wire: t.labelIn(context.l10n),
          },
          enabled: widget.enabled,
          onChanged: (v) {
            final type = ActionType.tryParse(v) ?? _a.type;
            _value.clear();
            _set(
              RuleAction(
                type: type,
                text: _a.text,
                method: _a.method,
                url: _a.url,
              ),
            );
          },
        ),
        const SizedBox(height: 8),
        body,
        if (problem != null && _touched)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              problem,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
      ],
    );
  }

  bool get _touched =>
      _a.text.isNotEmpty ||
      _a.value.isNotEmpty ||
      _a.url.isNotEmpty ||
      _a.field.isNotEmpty;
}
