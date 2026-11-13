import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/features/automations/application/automations_providers.dart';
import 'package:taskforge/features/automations/domain/automations.dart';
import 'package:taskforge/features/automations/presentation/action_cards.dart';
import 'package:taskforge/features/automations/presentation/condition_editor.dart';

/// Opens the builder; returns true when a rule was saved.
Future<bool?> showRuleBuilder(
  BuildContext context, {
  required String projectId,
  Automation? rule,
  bool readOnly = false,
}) => showDialog<bool>(
  context: context,
  builder: (_) => Dialog(
    insetPadding: MediaQuery.sizeOf(context).width < 600
        ? EdgeInsets.zero
        : const EdgeInsets.all(24),
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 680),
      child: RuleBuilder(projectId: projectId, rule: rule, readOnly: readOnly),
    ),
  ),
);

/// The rule as a vertical When, If, Then stack of cards.
class RuleBuilder extends ConsumerStatefulWidget {
  const RuleBuilder({
    super.key,
    required this.projectId,
    this.rule,
    this.readOnly = false,
  });

  final String projectId;
  final Automation? rule;
  final bool readOnly;

  @override
  ConsumerState<RuleBuilder> createState() => _RuleBuilderState();
}

class _RuleBuilderState extends ConsumerState<RuleBuilder> {
  late final _name = TextEditingController();
  final _conditionEditor = GlobalKey<ConditionEditorState>();
  var _condition = '';
  var _trigger = const Trigger();
  var _actions = <RuleAction>[];
  var _ids = <int>[];
  var _next = 0;
  var _generation = 0;
  Automation? _rule;
  String? _error;
  var _conflict = false;
  var _busy = false;

  bool get _ro => widget.readOnly;

  @override
  void initState() {
    super.initState();
    _load(widget.rule);
  }

  void _load(Automation? rule) {
    _rule = rule;
    final d = rule?.toDraft() ?? const RuleDraft();
    _name.text = d.name;
    _condition = d.condition;
    _conditionEditor.currentState?.setText(d.condition);
    _trigger = d.trigger;
    _actions = [...d.actions];
    _ids = [for (final _ in _actions) _next++];
    _generation++;
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  RuleDraft get _draft => RuleDraft(
    name: _name.text,
    trigger: _trigger,
    condition: _condition,
    actions: _actions,
  );

  void _setAction(int index, RuleAction a) => setState(
    () =>
        _actions = [for (final (i, x) in _actions.indexed) i == index ? a : x],
  );

  void _removeAction(int index) => setState(() {
    _actions = [..._actions]..removeAt(index);
    _ids = [..._ids]..removeAt(index);
  });

  void _addAction() => setState(() {
    _actions = [..._actions, const RuleAction()];
    _ids = [..._ids, _next++];
  });

  void _move(int index, int by) {
    final to = index + by;
    if (to < 0 || to >= _actions.length) return;
    setState(() {
      final a = [..._actions];
      final i = [..._ids];
      a.insert(to, a.removeAt(index));
      i.insert(to, i.removeAt(index));
      _actions = a;
      _ids = i;
    });
  }

  Future<void> _save() async {
    final problem = draftProblem(_draft);
    if (problem != null) {
      setState(() => _error = problem);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
      _conflict = false;
    });
    if (!await (_conditionEditor.currentState?.check() ?? Future.value(true))) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = context.l10n.grpGConditionProblem;
      });
      return;
    }
    final actions = ref.read(automationActionsProvider);
    try {
      final rule = _rule;
      if (rule == null) {
        await actions.create(widget.projectId, _draft);
      } else {
        await actions.save(rule, _draft);
      }
      if (mounted) Navigator.of(context).pop(true);
    } on AutomationException catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = automationErrorMessage(e);
        _conflict = e.failure == AutomationFailure.conflict;
      });
    }
  }

  /// Replaces the form with the server's version of the rule.
  Future<void> _reload() async {
    final id = _rule?.id;
    final list = await ref.read(automationsProvider(widget.projectId).future);
    if (!mounted) return;
    final fresh = list.where((r) => r.id == id).firstOrNull;
    setState(() {
      if (fresh == null) {
        _error = context.l10n.grpGRuleGone;
        _conflict = false;
      } else {
        _load(fresh);
        _error = null;
        _conflict = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final lookups = ref.watch(lookupsProvider(widget.projectId));
    final theme = Theme.of(context);
    final title = _ro
        ? context.l10n.grpGRule
        : (_rule == null
              ? context.l10n.grpGNewAutomation
              : context.l10n.grpGEditAutomation);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(20, 16, 8, 0),
          child: Row(
            children: [
              Expanded(child: Text(title, style: theme.textTheme.titleLarge)),
              IconButton(
                key: const Key('rule-close'),
                tooltip: context.l10n.grpGClose,
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(false),
              ),
            ],
          ),
        ),
        Flexible(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              key: ValueKey(_generation),
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_rule?.wasSwitchedOffByServer ?? false)
                  DisabledBanner(reason: _rule!.disabledReason),
                TextField(
                  key: const Key('rule-name'),
                  controller: _name,
                  readOnly: _ro,
                  maxLength: maxAutomationName,
                  decoration: InputDecoration(
                    labelText: context.l10n.grpGName,
                    border: const OutlineInputBorder(),
                  ),
                ),
                _Section(
                  keyName: 'when',
                  label: context.l10n.grpGWhen,
                  child: TriggerEditor(
                    trigger: _trigger,
                    lookups: lookups,
                    enabled: !_ro,
                    onChanged: (t) => setState(() => _trigger = t),
                  ),
                ),
                const _Arrow(),
                _Section(
                  keyName: 'if',
                  label: context.l10n.grpGIfOptional,
                  child: ConditionEditor(
                    key: _conditionEditor,
                    projectId: widget.projectId,
                    initial: _condition,
                    readOnly: _ro,
                    onChanged: (t) => setState(() => _condition = t),
                  ),
                ),
                const _Arrow(),
                for (final (i, a) in _actions.indexed) ...[
                  _Section(
                    key: ValueKey('card-${_ids[i]}'),
                    keyName: 'then-$i',
                    label: i == 0
                        ? context.l10n.grpGThen
                        : context.l10n.grpGAndThen,
                    trailing: _ro
                        ? null
                        : _CardTools(
                            index: i,
                            count: _actions.length,
                            onMove: (by) => _move(i, by),
                            onRemove: () => _removeAction(i),
                          ),
                    child: ActionEditor(
                      action: a,
                      lookups: lookups,
                      enabled: !_ro,
                      onChanged: (x) => _setAction(i, x),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                if (!_ro)
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: OutlinedButton.icon(
                      key: const Key('add-action'),
                      icon: const Icon(Icons.add),
                      label: Text(
                        _actions.length >= maxActionsPerRule
                            ? context.l10n.grpGActionLimit(maxActionsPerRule)
                            : context.l10n.grpGAddAction,
                      ),
                      onPressed: _actions.length >= maxActionsPerRule
                          ? null
                          : _addAction,
                    ),
                  ),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      _error!,
                      key: const Key('rule-error'),
                      style: TextStyle(color: theme.colorScheme.error),
                    ),
                  ),
                if (_conflict)
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: TextButton(
                      key: const Key('rule-reload'),
                      onPressed: _reload,
                      child: Text(context.l10n.grpGLoadLatest),
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (!_ro)
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _busy
                      ? null
                      : () => Navigator.of(context).pop(false),
                  child: Text(context.l10n.grpGCancel),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  key: const Key('rule-save'),
                  onPressed: _busy ? null : _save,
                  child: Text(
                    _rule == null
                        ? context.l10n.grpGCreate
                        : context.l10n.grpGSave,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    super.key,
    required this.keyName,
    required this.label,
    required this.child,
    this.trailing,
  });

  final String keyName;
  final String label;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      key: Key('card-$keyName'),
      margin: const EdgeInsets.only(top: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    label.toUpperCase(),
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
                ?trailing,
              ],
            ),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }
}

class _CardTools extends StatelessWidget {
  const _CardTools({
    required this.index,
    required this.count,
    required this.onMove,
    required this.onRemove,
  });

  final int index;
  final int count;
  final void Function(int by) onMove;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      IconButton(
        key: Key('action-up-$index'),
        tooltip: context.l10n.grpGMoveUp,
        icon: const Icon(Icons.arrow_upward, size: 18),
        onPressed: index == 0 ? null : () => onMove(-1),
      ),
      IconButton(
        key: Key('action-down-$index'),
        tooltip: context.l10n.grpGMoveDown,
        icon: const Icon(Icons.arrow_downward, size: 18),
        onPressed: index >= count - 1 ? null : () => onMove(1),
      ),
      IconButton(
        key: Key('action-remove-$index'),
        tooltip: context.l10n.grpGRemoveAction,
        icon: const Icon(Icons.delete_outline, size: 18),
        onPressed: onRemove,
      ),
    ],
  );
}

class _Arrow extends StatelessWidget {
  const _Arrow();

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.only(top: 4),
    child: Icon(Icons.arrow_downward, size: 20),
  );
}

/// Why the server switched a rule off, and how to fix it.
class DisabledBanner extends StatelessWidget {
  const DisabledBanner({super.key, required this.reason});

  final String reason;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      key: const Key('disabled-banner'),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        context.l10n.grpGSwitchedOff(reason),
        style: TextStyle(color: scheme.onErrorContainer),
      ),
    );
  }
}
