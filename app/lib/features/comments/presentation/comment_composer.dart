import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/features/attachments/domain/attachments.dart';
import 'package:taskforge/features/attachments/presentation/attach_buttons.dart';
import 'package:taskforge/features/comments/application/comments_providers.dart';
import 'package:taskforge/features/comments/domain/comment_text.dart';
import 'package:taskforge/features/comments/domain/comments.dart';

/// The `@query` being typed at [caret] in [text]: the characters after the
/// last `@` that starts a word, with no space yet; null when none is open.
({int start, String query})? openMention(String text, int caret) {
  if (caret < 0 || caret > text.length) return null;
  final before = text.substring(0, caret);
  final at = before.lastIndexOf('@');
  if (at < 0) return null;
  if (at > 0 && !RegExp(r'\s').hasMatch(before[at - 1])) return null;
  final query = before.substring(at + 1);
  if (query.contains(RegExp(r'\s'))) return null;
  return (start: at, query: query);
}

/// What a composer hands over: the document (JSON), the people mentioned and
/// the files chosen to go with it.
typedef ComposerSend = Future<void> Function(
  String body,
  List<MentionPick> picks,
  List<UploadSource> files,
);

/// Where comments are written: a box that grows, `@` opens a list of people
/// who can see the task, Ctrl/Cmd + Enter sends, and (with [allowFiles])
/// files can be attached and show as chips until they are sent. [onSend] may
/// throw (the box keeps the text and the files).
class CommentComposer extends ConsumerStatefulWidget {
  const CommentComposer({
    super.key,
    this.task,
    required this.onSend,
    this.mentionLookup,
    this.broadcastNames = const [],
    this.initialText = '',
    this.initialPicks = const [],
    this.hint,
    this.sendLabel,
    this.onCancel,
    this.autofocus = false,
    this.allowFiles = false,
  });

  /// The task whose people can be mentioned (unless [mentionLookup] says).
  final TaskRef? task;
  final ComposerSend onSend;

  /// Where the people to mention come from when it is not a task (a chat
  /// space); called while building, so it may watch providers.
  final List<Person> Function(WidgetRef ref, String query)? mentionLookup;

  /// Extra everyone-mentions offered by `@` (a space's `channel`, `here`):
  /// the person's id is the name.
  final List<String> broadcastNames;
  final String initialText;
  final List<MentionPick> initialPicks;

  /// Null for the usual "Write a comment…" prompt.
  final String? hint;

  /// Null for the usual "Comment" button text.
  final String? sendLabel;
  final VoidCallback? onCancel;
  final bool autofocus;

  /// Whether files can be attached (a new comment or reply; not an edit).
  final bool allowFiles;

  @override
  ConsumerState<CommentComposer> createState() => _CommentComposerState();
}

class _CommentComposerState extends ConsumerState<CommentComposer> {
  late final _controller = TextEditingController(text: widget.initialText);
  final _focus = FocusNode();
  late final _picks = [...widget.initialPicks];
  var _sending = false;
  final _files = <UploadSource>[];
  ({int start, String query})? _open;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_watchCaret);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _watchCaret() {
    final next = openMention(
      _controller.text,
      _controller.selection.baseOffset,
    );
    if (next?.query != _open?.query || next?.start != _open?.start) {
      setState(() => _open = next);
    }
  }

  void _pick(Person person) {
    final open = _open;
    if (open == null) return;
    final label = person.displayName;
    final text = _controller.text;
    final caret = _controller.selection.baseOffset;
    final inserted = '@$label ';
    _controller.value = TextEditingValue(
      text: text.replaceRange(open.start, caret, inserted),
      selection: TextSelection.collapsed(offset: open.start + inserted.length),
    );
    if (!_picks.any((p) => p.userId == person.userId && p.label == label)) {
      _picks.add(MentionPick(person.userId, label));
    }
    setState(() => _open = null);
    _focus.requestFocus();
  }

  /// Puts [before] at the start of the caret's line (a bullet, a quote).
  void _linePrefix(String before) {
    final text = _controller.text;
    final caret = _controller.selection.baseOffset.clamp(0, text.length);
    final start = text.lastIndexOf('\n', caret == 0 ? 0 : caret - 1) + 1;
    _controller.value = TextEditingValue(
      text: text.replaceRange(start, start, before),
      selection: TextSelection.collapsed(offset: caret + before.length),
    );
    _focus.requestFocus();
  }

  /// Wraps the selection in [open]/[close]; with none, leaves the caret inside.
  void _wrapSelection(String open, String close) {
    final text = _controller.text;
    final sel = _controller.selection;
    final a = sel.start < 0 ? text.length : sel.start;
    final b = sel.end < 0 ? text.length : sel.end;
    final inner = text.substring(a, b);
    _controller.value = TextEditingValue(
      text: text.replaceRange(a, b, '$open$inner$close'),
      selection: TextSelection.collapsed(
        offset: a + open.length + inner.length,
      ),
    );
    _focus.requestFocus();
  }

  Widget _toolbar() => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      for (final (key, icon, tip, action)
          in <(String, IconData, String, VoidCallback)>[
            (
              'bullet',
              Icons.format_list_bulleted,
              context.l10n.grpIBulletList,
              () => _linePrefix('- '),
            ),
            (
              'quote',
              Icons.format_quote,
              context.l10n.grpIQuote,
              () => _linePrefix('> '),
            ),
            (
              'code',
              Icons.code,
              context.l10n.grpICodeBlock,
              () => _wrapSelection('```\n', '\n```'),
            ),
            (
              'link',
              Icons.link,
              context.l10n.grpILink,
              () => _wrapSelection('[', '](https://)'),
            ),
          ])
        IconButton(
          key: Key('format-$key'),
          icon: Icon(icon, size: 18),
          tooltip: tip,
          visualDensity: VisualDensity.compact,
          onPressed: action,
        ),
    ],
  );

  Future<void> _send() async {
    final text = _controller.text;
    final body = bodyFromComposer(text, _picks);
    if (body.isEmpty || _sending) return;
    setState(() => _sending = true);
    try {
      await widget.onSend(body, [
        for (final p in _picks)
          if (text.contains(p.token)) p,
      ], List.unmodifiable(_files));
      if (!mounted) return;
      _controller.clear();
      _picks.clear();
      setState(_files.clear);
    } on Object {
      // The owner of onSend says what went wrong; the text stays for another go.
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final open = _open;
    final lookup = widget.mentionLookup;
    final task = widget.task;
    final found = open == null
        ? const <Person>[]
        : lookup != null
        ? lookup(ref, open.query)
        : task == null
        ? const <Person>[]
        : ref
                  .watch(mentionableProvider((task: task, query: open.query)))
                  .value ??
              const <Person>[];
    final people = open == null
        ? const <Person>[]
        : [
            for (final n in widget.broadcastNames)
              if (n.startsWith(open.query.toLowerCase())) Person(n, n),
            ...found,
          ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (open != null && people.isNotEmpty)
          Material(
            key: const Key('mention-picker'),
            elevation: 2,
            borderRadius: BorderRadius.circular(8),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 180),
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final p in people)
                    ListTile(
                      key: Key('mention-${p.userId}'),
                      dense: true,
                      leading: CircleAvatar(
                        radius: 12,
                        child: Text(
                          p.displayName.isEmpty
                              ? '?'
                              : p.displayName[0].toUpperCase(),
                          style: const TextStyle(fontSize: 11),
                        ),
                      ),
                      title: Text(p.displayName),
                      onTap: () => _pick(p),
                    ),
                ],
              ),
            ),
          ),
        CallbackShortcuts(
          bindings: {
            const SingleActivator(LogicalKeyboardKey.enter, control: true):
                _send,
            const SingleActivator(LogicalKeyboardKey.enter, meta: true): _send,
          },
          child: TextField(
            key: const Key('comment-input'),
            controller: _controller,
            focusNode: _focus,
            autofocus: widget.autofocus,
            minLines: 2,
            maxLines: 8,
            textInputAction: TextInputAction.newline,
            decoration: InputDecoration(
              hintText: widget.hint ?? context.l10n.grpIWriteComment,
              border: const OutlineInputBorder(),
            ),
          ),
        ),
        if (_files.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Wrap(
              key: const Key('chosen-files'),
              spacing: 6,
              runSpacing: 6,
              children: [
                for (var i = 0; i < _files.length; i++)
                  InputChip(
                    key: Key('chosen-file-$i'),
                    avatar: const Icon(Icons.attach_file, size: 16),
                    label: Text(
                      _files[i].name,
                      overflow: TextOverflow.ellipsis,
                    ),
                    deleteButtonTooltipMessage: context.l10n.grpJRemoveMember(
                      _files[i].name,
                    ),
                    onDeleted: _sending
                        ? null
                        : () => setState(() => _files.removeAt(i)),
                  ),
              ],
            ),
          ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _toolbar(),
                    if (widget.allowFiles)
                      AttachButtons(
                        keyPrefix: 'comment-attach',
                        labelled: false,
                        onPicked: (sources) async =>
                            setState(() => _files.addAll(sources)),
                        onError: () => ScaffoldMessenger.of(context)
                          ..hideCurrentSnackBar()
                          ..showSnackBar(
                            SnackBar(
                              content: Text(context.l10n.grpICouldNotReadFile),
                            ),
                          ),
                      ),
                  ],
                ),
              ),
            ),
            if (widget.onCancel != null)
              TextButton(
                key: const Key('comment-cancel'),
                onPressed: widget.onCancel,
                child: Text(context.l10n.grpICancel),
              ),
            Tooltip(
              message: context.l10n.grpICtrlEnterToSend,
              child: FilledButton(
                key: const Key('comment-send'),
                onPressed: _sending ? null : _send,
                child: Text(widget.sendLabel ?? context.l10n.grpIComment),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
