import 'package:flutter/material.dart';

import 'package:taskforge/features/filters/domain/saved_filters.dart';

final _token = RegExp(
  r'''("(?:[^"\\]|\\.)*"?)|(\d{4}-\d{2}-\d{2}|[+-]\d+[dwmy]\b|-?\d+(?:\.\d+)?)|([A-Za-z_][A-Za-z0-9_]*)|(<=|>=|!=|!~|[=~<>(),])''',
);
const _keywords = {
  'and',
  'or',
  'not',
  'in',
  'is',
  'empty',
  'order',
  'by',
  'asc',
  'desc',
};

/// A text controller that paints TFQL: keywords, strings, numbers and dates in
/// their own colours, and the parts the server found wrong underlined in red.
class TfqlController extends TextEditingController {
  TfqlController({super.text});

  List<QueryProblem> problems = const [];

  /// Shows [next] as underlines.
  void showProblems(List<QueryProblem> next) {
    problems = next;
    notifyListeners();
  }

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final base = style ?? const TextStyle();
    final source = text;
    TextStyle colored(Color color, {bool bold = false}) =>
        base.copyWith(color: color, fontWeight: bold ? FontWeight.bold : null);
    final spans = <InlineSpan>[];
    var at = 0;
    for (final m in _token.allMatches(source)) {
      if (m.start > at) {
        spans.add(TextSpan(text: source.substring(at, m.start)));
      }
      final piece = m[0]!;
      final TextStyle tone;
      if (m[1] != null) {
        tone = colored(Colors.green.shade700);
      } else if (m[2] != null) {
        tone = colored(Colors.orange.shade800);
      } else if (m[3] != null) {
        tone = _keywords.contains(piece.toLowerCase())
            ? colored(scheme.primary, bold: true)
            : base;
      } else {
        tone = colored(scheme.outline);
      }
      spans.add(TextSpan(text: piece, style: tone));
      at = m.end;
    }
    if (at < source.length) spans.add(TextSpan(text: source.substring(at)));
    return _underlined(TextSpan(style: base, children: spans), scheme.error);
  }

  /// [root] with the problem ranges underlined.
  TextSpan _underlined(TextSpan root, Color color) {
    if (problems.isEmpty) return root;
    final out = <InlineSpan>[];
    var offset = 0;
    for (final span in root.children!.cast<TextSpan>()) {
      final piece = span.text ?? '';
      var from = 0;
      while (from < piece.length) {
        final bad = problems.any(
          (p) =>
              offset + from >= p.position &&
              offset + from < p.position + (p.length < 1 ? 1 : p.length),
        );
        var to = from + 1;
        while (to < piece.length &&
            problems.any(
                  (p) =>
                      offset + to >= p.position &&
                      offset + to < p.position + (p.length < 1 ? 1 : p.length),
                ) ==
                bad) {
          to++;
        }
        out.add(
          TextSpan(
            text: piece.substring(from, to),
            style: (span.style ?? const TextStyle()).merge(
              bad
                  ? TextStyle(
                      decoration: TextDecoration.underline,
                      decorationColor: color,
                      decorationStyle: TextDecorationStyle.wavy,
                    )
                  : null,
            ),
          ),
        );
        from = to;
      }
      offset += piece.length;
    }
    // A problem at the very end (nothing there to underline): a red bar.
    return TextSpan(style: root.style, children: out);
  }
}

/// The advanced editor: the query as text with highlighting, the server's
/// problems shown where they are, and suggestions to tap.
class TfqlEditor extends StatefulWidget {
  const TfqlEditor({
    super.key,
    required this.initial,
    required this.problems,
    required this.suggestions,
    required this.onChanged,
    required this.onCursor,
  });

  final String initial;
  final List<QueryProblem> problems;
  final List<QuerySuggestion> suggestions;

  /// The text changed (the cursor is where the person is typing).
  final void Function(String text, int cursor) onChanged;
  final void Function(String text, int cursor) onCursor;

  @override
  State<TfqlEditor> createState() => TfqlEditorState();
}

class TfqlEditorState extends State<TfqlEditor> {
  late final TfqlController controller = TfqlController(text: widget.initial);

  @override
  void initState() {
    super.initState();
    controller.problems = widget.problems;
  }

  @override
  void didUpdateWidget(TfqlEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.problems != widget.problems) {
      controller.showProblems(widget.problems);
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _accept(QuerySuggestion s) {
    final text = controller.text;
    final cursor = controller.selection.isValid
        ? controller.selection.baseOffset.clamp(0, text.length)
        : text.length;
    final start = s.start.clamp(0, cursor);
    final inserted = '${s.text} ';
    final next = text.replaceRange(start, cursor, inserted);
    controller.value = TextEditingValue(
      text: next,
      selection: TextSelection.collapsed(offset: start + inserted.length),
    );
    widget.onChanged(next, start + inserted.length);
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      TextField(
        key: const Key('tfql-text'),
        controller: controller,
        minLines: 3,
        maxLines: 8,
        style: const TextStyle(fontFamily: 'monospace'),
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          hintText: 'status = "In progress" AND assignee = me AND due < +7d',
        ),
        onChanged: (t) => widget.onChanged(
          t,
          controller.selection.isValid
              ? controller.selection.baseOffset
              : t.length,
        ),
        onTap: () =>
            widget.onCursor(controller.text, controller.selection.baseOffset),
      ),
      if (widget.problems.isNotEmpty)
        Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(
            key: const Key('tfql-error'),
            '${widget.problems.first.message} '
            '(at character ${widget.problems.first.position + 1})',
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ),
      if (widget.suggestions.isNotEmpty)
        Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Wrap(
            key: const Key('tfql-suggestions'),
            spacing: 6,
            runSpacing: 4,
            children: [
              for (final s in widget.suggestions)
                ActionChip(
                  key: Key('suggest-${s.text}'),
                  label: Text(s.text),
                  tooltip: s.label.isEmpty ? s.kind : '${s.kind}: ${s.label}',
                  onPressed: () => _accept(s),
                ),
            ],
          ),
        ),
    ],
  );
}
