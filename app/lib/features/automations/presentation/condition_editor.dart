import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/features/automations/domain/automations.dart';
import 'package:taskforge/features/filters/application/filters_providers.dart';
import 'package:taskforge/features/filters/domain/saved_filters.dart';
import 'package:taskforge/features/filters/presentation/tfql_editor.dart';
import 'package:taskforge/features/workspaces/application/workspace_providers.dart';

/// How long after the last keystroke the condition is checked by the server.
const conditionCheckDelay = Duration(milliseconds: 350);

/// A rule's "If": the project's TFQL editor (highlighting, suggestions, and the
/// server's problems with their positions) on one text. [ConditionEditorState.check]
/// asks the server right now, for the moment before saving.
class ConditionEditor extends ConsumerStatefulWidget {
  const ConditionEditor({
    super.key,
    required this.projectId,
    required this.initial,
    required this.onChanged,
    this.readOnly = false,
  });

  final String projectId;
  final String initial;
  final bool readOnly;
  final ValueChanged<String> onChanged;

  @override
  ConsumerState<ConditionEditor> createState() => ConditionEditorState();
}

class ConditionEditorState extends ConsumerState<ConditionEditor> {
  final _editor = GlobalKey<TfqlEditorState>();
  var _problems = const <QueryProblem>[];
  var _suggestions = const <QuerySuggestion>[];
  Timer? _timer;
  var _generation = 0;
  late var _text = widget.initial;

  /// The text as typed.
  String get text => _text;

  /// Replaces the text (the form was reloaded).
  void setText(String next) {
    _text = next;
    _timer?.cancel();
    _editor.currentState?.controller.text = next;
    setState(() {
      _problems = const [];
      _suggestions = const [];
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _typed(String text, int cursor) {
    _text = text;
    widget.onChanged(text);
    _timer?.cancel();
    _timer = Timer(conditionCheckDelay, () => _validate(cursor));
  }

  Future<void> _validate(int cursor) async {
    final generation = ++_generation;
    final text = _text;
    final workspace = ref.read(workspaceScopeProvider);
    if (workspace == null) return;
    try {
      final client = ref.read(filtersClientProvider);
      final checked = await client.validate(
        workspace,
        widget.projectId,
        tfql: text,
      );
      final suggestions = await client.suggest(
        workspace,
        widget.projectId,
        text,
        cursor < 0 ? text.length : cursor,
      );
      if (!mounted || generation != _generation) return;
      setState(() {
        _problems = checked.errors;
        _suggestions = suggestions;
      });
    } on FilterException {
      // The next keystroke checks again; saving checks too.
    }
  }

  /// Asks the server about the text now. True when it is empty or valid; a
  /// problem is shown under the field. A server that cannot be reached does not
  /// block (saving checks the rule again).
  Future<bool> check() async {
    _timer?.cancel();
    if (_text.trim().isEmpty) return true;
    final workspace = ref.read(workspaceScopeProvider);
    if (workspace == null) return true;
    final generation = ++_generation;
    try {
      final checked = await ref
          .read(filtersClientProvider)
          .validate(workspace, widget.projectId, tfql: _text);
      if (!mounted || generation != _generation) return checked.ok;
      setState(() => _problems = checked.errors);
      return checked.ok;
    } on FilterException {
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final local = _problems.isEmpty ? conditionProblem(_text) : null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TfqlEditor(
          key: _editor,
          initial: widget.initial,
          problems: _problems,
          suggestions: _suggestions,
          fieldKey: const Key('rule-condition'),
          minLines: 1,
          maxLines: 4,
          hint: 'priority = high AND assignee = me',
          helper: 'A TFQL filter on the task. Empty means always.',
          readOnly: widget.readOnly,
          onChanged: _typed,
          onCursor: (text, cursor) => _validate(cursor),
        ),
        if (local != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              local,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
      ],
    );
  }
}
