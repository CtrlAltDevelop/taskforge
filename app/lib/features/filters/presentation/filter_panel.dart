import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/features/fields/application/fields_providers.dart';
import 'package:taskforge/features/filters/application/filters_providers.dart';
import 'package:taskforge/features/filters/domain/filter_fields.dart';
import 'package:taskforge/features/filters/domain/filter_query.dart';
import 'package:taskforge/features/filters/domain/saved_filters.dart';
import 'package:taskforge/features/filters/presentation/filter_builder.dart';
import 'package:taskforge/features/filters/presentation/tfql_editor.dart';
import 'package:taskforge/features/members/application/members_providers.dart';
import 'package:taskforge/features/workflows/application/workflows_providers.dart';
import 'package:taskforge/features/workspaces/application/workspace_providers.dart';

/// How long after the last keystroke the text is checked by the server.
const checkDelay = Duration(milliseconds: 350);

enum _Mode { builder, text }

/// The filter editor: build it with rows, or write it as TFQL; the two stay in
/// sync through the server (which reads and writes the language). Apply puts it
/// on the project's list, board and calendar.
class FilterPanel extends ConsumerStatefulWidget {
  const FilterPanel({
    super.key,
    required this.projectId,
    required this.canShare,
  });

  final String projectId;

  /// May share filters with the whole project (`project.update`).
  final bool canShare;

  @override
  ConsumerState<FilterPanel> createState() => _FilterPanelState();
}

class _FilterPanelState extends ConsumerState<FilterPanel> {
  var _mode = _Mode.builder;
  late FilterQuery _draft = ref
      .read(activeFilterProvider(widget.projectId))
      .query;
  var _text = '';
  var _problems = const <QueryProblem>[];
  var _suggestions = const <QuerySuggestion>[];
  Timer? _timer;
  var _busy = false;
  String? _message;
  var _generation = 0;
  final _editor = GlobalKey<TfqlEditorState>();

  String get _project => widget.projectId;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String? get _workspace => ref.read(workspaceScopeProvider);

  Future<QueryChecked?> _check({String tfql = '', String astJson = ''}) async {
    final workspace = _workspace;
    if (workspace == null) return null;
    try {
      return await ref
          .read(filtersClientProvider)
          .validate(workspace, _project, tfql: tfql, astJson: astJson);
    } on FilterException catch (e) {
      if (mounted) {
        setState(() => _message = filterErrorMessage(e, context.l10n));
      }
      return null;
    }
  }

  Future<void> _switchTo(_Mode mode) async {
    if (mode == _mode) return;
    setState(() {
      _busy = true;
      _message = null;
    });
    if (mode == _Mode.text) {
      final checked = await _check(astJson: _draft.toJsonString());
      if (!mounted) return;
      if (checked == null || !checked.ok) {
        setState(() {
          _busy = false;
          _message =
              checked?.errors.firstOrNull?.message ??
              _message ??
              context.l10n.grpGFinishConditions;
        });
        return;
      }
      setState(() {
        _text = checked.tfql;
        _problems = const [];
        _suggestions = const [];
        _mode = mode;
        _busy = false;
      });
    } else {
      final checked = await _check(tfql: _text);
      if (!mounted) return;
      if (checked == null || !checked.ok) {
        setState(() {
          _busy = false;
          _problems = checked?.errors ?? const [];
        });
        return;
      }
      setState(() {
        _draft = checked.query!;
        _mode = mode;
        _busy = false;
      });
    }
  }

  void _typed(String text, int cursor) {
    _text = text;
    _timer?.cancel();
    _timer = Timer(checkDelay, () => _validateText(cursor));
  }

  Future<void> _validateText(int cursor) async {
    final generation = ++_generation;
    final text = _text;
    final workspace = _workspace;
    if (workspace == null) return;
    try {
      final client = ref.read(filtersClientProvider);
      final checked = await client.validate(workspace, _project, tfql: text);
      final suggestions = await client.suggest(
        workspace,
        _project,
        text,
        cursor < 0 ? text.length : cursor,
      );
      if (!mounted || generation != _generation) return;
      setState(() {
        _problems = checked.errors;
        _suggestions = suggestions;
        _message = null;
      });
    } on FilterException {
      // The next keystroke checks again.
    }
  }

  /// The query to apply: the server's reading of what is on screen.
  Future<QueryChecked?> _current() async {
    final checked = _mode == _Mode.text
        ? await _check(tfql: _text)
        : await _check(astJson: _draft.toJsonString());
    if (!mounted || checked == null) return null;
    if (!checked.ok) {
      setState(() {
        _problems = _mode == _Mode.text ? checked.errors : const [];
        _message = checked.errors.firstOrNull?.message;
      });
      return null;
    }
    return checked;
  }

  Future<void> _apply() async {
    setState(() => _busy = true);
    final checked = await _current();
    if (!mounted) return;
    setState(() => _busy = false);
    if (checked == null) return;
    ref
        .read(activeFilterProvider(_project).notifier)
        .apply(checked.query!, text: checked.tfql);
    Navigator.of(context).pop();
  }

  void _clear() {
    ref.read(activeFilterProvider(_project).notifier).clear();
    Navigator.of(context).pop();
  }

  Future<void> _save() async {
    final checked = await _current();
    if (checked == null || !mounted) return;
    final choice = await showDialog<({String name, String visibility})>(
      context: context,
      builder: (_) => _SaveDialog(
        canShare: widget.canShare,
        sharedValue: _project.isEmpty ? 'workspace' : 'project',
        sharedLabel: _project.isEmpty
            ? context.l10n.grpGEveryoneWorkspace
            : context.l10n.grpGEveryoneProject,
      ),
    );
    final workspace = _workspace;
    if (choice == null || workspace == null || !mounted) return;
    try {
      final saved = await ref
          .read(filtersClientProvider)
          .save(
            workspace,
            _project,
            name: choice.name,
            query: checked.query!,
            visibility: choice.visibility,
          );
      ref.invalidate(savedFiltersProvider(_project));
      ref
          .read(activeFilterProvider(_project).notifier)
          .apply(saved.query, saved: saved.id, text: checked.tfql);
      if (mounted) Navigator.of(context).pop();
    } on FilterException catch (e) {
      if (mounted) {
        setState(() => _message = filterErrorMessage(e, context.l10n));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final wide = _project.isEmpty; // the calendar of every project
    final fields = filterFields(
      flow: wide ? null : ref.watch(workflowProvider(_project)).value,
      members: ref.watch(membersProvider).value ?? const [],
      fields: wide
          ? const []
          : ref.watch(fieldsProvider(_project)).value ?? const [],
      workspaceWide: wide,
    );
    return AlertDialog(
      key: const Key('filter-panel'),
      title: Row(
        children: [
          Expanded(child: Text(context.l10n.grpGFilter)),
          SegmentedButton<_Mode>(
            key: const Key('filter-mode'),
            showSelectedIcon: false,
            segments: [
              ButtonSegment(
                value: _Mode.builder,
                label: Text(context.l10n.grpGBuilder),
              ),
              ButtonSegment(
                value: _Mode.text,
                label: Text(context.l10n.grpGAdvanced),
              ),
            ],
            selected: {_mode},
            onSelectionChanged: _busy ? null : (v) => _switchTo(v.first),
          ),
        ],
      ),
      content: SizedBox(
        width: 720,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_mode == _Mode.builder)
                FilterBuilder(
                  query: _draft,
                  fields: fields,
                  onChanged: (q) => setState(() {
                    _draft = q;
                    _message = null;
                  }),
                )
              else
                TfqlEditor(
                  key: _editor,
                  initial: _text,
                  problems: _problems,
                  suggestions: _suggestions,
                  onChanged: _typed,
                  onCursor: (_, cursor) => _typed(_text, cursor),
                ),
              if (_message != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    _message!,
                    key: const Key('filter-message'),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          key: const Key('filter-clear'),
          onPressed: _clear,
          child: Text(context.l10n.grpGClearFilter),
        ),
        TextButton(
          key: const Key('filter-save'),
          onPressed: _busy ? null : _save,
          child: Text(context.l10n.grpGSaveAs),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(context.l10n.grpGCancel),
        ),
        FilledButton(
          key: const Key('filter-apply'),
          onPressed: _busy ? null : _apply,
          child: Text(context.l10n.grpGApply),
        ),
      ],
    );
  }
}

class _SaveDialog extends StatefulWidget {
  const _SaveDialog({
    required this.canShare,
    required this.sharedValue,
    required this.sharedLabel,
  });

  final bool canShare;

  /// The visibility "shared" means here, and how it reads.
  final String sharedValue;
  final String sharedLabel;

  @override
  State<_SaveDialog> createState() => _SaveDialogState();
}

class _SaveDialogState extends State<_SaveDialog> {
  final _name = TextEditingController();
  var _visibility = 'private';

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _done() {
    final name = _name.text.trim();
    if (name.isNotEmpty) {
      Navigator.pop(context, (name: name, visibility: _visibility));
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(context.l10n.grpGSaveThisFilter),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          key: const Key('filter-name'),
          controller: _name,
          autofocus: true,
          maxLength: 60,
          decoration: InputDecoration(labelText: context.l10n.grpGName),
          onSubmitted: (_) => _done(),
        ),
        if (widget.canShare)
          DropdownButton<String>(
            key: const Key('filter-visibility'),
            value: _visibility,
            items: [
              DropdownMenuItem(
                value: 'private',
                child: Text(context.l10n.grpGOnlyMe),
              ),
              DropdownMenuItem(
                value: widget.sharedValue,
                child: Text(widget.sharedLabel),
              ),
            ],
            onChanged: (v) => setState(() => _visibility = v ?? 'private'),
          ),
      ],
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: Text(context.l10n.grpGCancel),
      ),
      FilledButton(
        key: const Key('filter-save-confirm'),
        onPressed: _done,
        child: Text(context.l10n.grpGSave),
      ),
    ],
  );
}
