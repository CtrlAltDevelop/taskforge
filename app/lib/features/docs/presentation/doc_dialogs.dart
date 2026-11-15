import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/features/docs/application/docs_providers.dart';
import 'package:taskforge/features/docs/domain/doc_blocks.dart';
import 'package:taskforge/features/docs/domain/doc_ops.dart';
import 'package:taskforge/features/docs/domain/docs.dart';
import 'package:taskforge/features/members/application/members_providers.dart';
import 'package:taskforge/features/search/application/search_providers.dart';
import 'package:taskforge/features/search/domain/search.dart';
import 'package:taskforge/features/workspaces/application/workspace_providers.dart';

bool _okAddress(String v, {bool mail = true}) {
  final u = Uri.tryParse(v);
  if (u == null) return false;
  if (u.scheme == 'http' || u.scheme == 'https') return u.host.isNotEmpty;
  return mail && u.scheme == 'mailto' && u.path.isNotEmpty;
}

/// Asks for a link address. An empty answer takes the link off; null cancels.
Future<String?> askLink(BuildContext context, String current) =>
    showDialog<String>(
      context: context,
      builder: (ctx) => _TextDialog(
        title: ctx.l10n.grpBLinkTitle,
        label: ctx.l10n.grpBLinkAddressLabel,
        fieldKey: 'link-field',
        okKey: 'link-ok',
        initial: current,
        allowEmpty: true,
        valid: (v) => v.isEmpty || _okAddress(v),
        invalid: ctx.l10n.grpBLinkInvalid,
      ),
    );

/// Asks for a page icon (one emoji or a few characters). An empty answer
/// clears it; null cancels.
Future<String?> askIcon(BuildContext context, String current) =>
    showDialog<String>(
      context: context,
      builder: (ctx) => _TextDialog(
        title: ctx.l10n.grpBIconTitle,
        label: ctx.l10n.grpBIconLabel,
        fieldKey: 'icon-field',
        okKey: 'icon-ok',
        initial: current,
        allowEmpty: true,
        valid: (v) => v.characters.length <= 4,
        invalid: ctx.l10n.grpBIconInvalid,
      ),
    );

/// Asks for an image address and a description (`src`, `alt`).
Future<Map<String, Object?>?> editImage(
  BuildContext context,
  DocBlock? block,
) => showDialog<Map<String, Object?>>(
  context: context,
  builder: (_) => _ImageDialog(block: block),
);

class _TextDialog extends StatefulWidget {
  const _TextDialog({
    required this.title,
    required this.label,
    required this.fieldKey,
    required this.okKey,
    required this.initial,
    required this.valid,
    required this.invalid,
    this.allowEmpty = false,
  });

  final String title;
  final String label;
  final String fieldKey;
  final String okKey;
  final String initial;
  final bool allowEmpty;
  final bool Function(String) valid;
  final String invalid;

  @override
  State<_TextDialog> createState() => _TextDialogState();
}

class _TextDialogState extends State<_TextDialog> {
  late final _c = TextEditingController(text: widget.initial);
  String? _error;

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _ok() {
    final v = _c.text.trim();
    if (!widget.valid(v)) {
      setState(() => _error = widget.invalid);
      return;
    }
    Navigator.pop(context, v);
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.title),
    content: TextField(
      key: Key(widget.fieldKey),
      controller: _c,
      autofocus: true,
      decoration: InputDecoration(labelText: widget.label, errorText: _error),
      onSubmitted: (_) => _ok(),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: Text(context.l10n.grpBCancel),
      ),
      FilledButton(
        key: Key(widget.okKey),
        onPressed: _ok,
        child: Text(context.l10n.grpBOk),
      ),
    ],
  );
}

class _ImageDialog extends StatefulWidget {
  const _ImageDialog({this.block});

  final DocBlock? block;

  @override
  State<_ImageDialog> createState() => _ImageDialogState();
}

class _ImageDialogState extends State<_ImageDialog> {
  late final _src = TextEditingController(text: widget.block?.src ?? '');
  late final _alt = TextEditingController(text: widget.block?.alt ?? '');
  String? _error;

  @override
  void dispose() {
    _src.dispose();
    _alt.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(context.l10n.grpBImageTitle),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          key: const Key('image-src'),
          controller: _src,
          autofocus: true,
          decoration: InputDecoration(
            labelText: context.l10n.grpBImageAddressLabel,
            errorText: _error,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          key: const Key('image-alt'),
          controller: _alt,
          decoration: InputDecoration(labelText: context.l10n.grpBDescription),
        ),
      ],
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: Text(context.l10n.grpBCancel),
      ),
      FilledButton(
        key: const Key('image-ok'),
        onPressed: () {
          final src = _src.text.trim();
          if (!_okAddress(src, mail: false)) {
            setState(() => _error = context.l10n.grpBImageInvalid);
            return;
          }
          Navigator.pop(context, {'src': src, 'alt': _alt.text.trim()});
        },
        child: Text(context.l10n.grpBOk),
      ),
    ],
  );
}

/// Picks a task for a card: search by words, or paste a task link or id.
/// Answers the task id.
Future<String?> pickTask(BuildContext context) =>
    showDialog<String>(context: context, builder: (_) => const _TaskPicker());

class _TaskPicker extends ConsumerStatefulWidget {
  const _TaskPicker();

  @override
  ConsumerState<_TaskPicker> createState() => _TaskPickerState();
}

class _TaskPickerState extends ConsumerState<_TaskPicker> {
  final _c = TextEditingController();
  List<SearchHit> _hits = const [];
  var _asked = 0;

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  Future<void> _search(String text) async {
    final ws = ref.read(workspaceScopeProvider);
    final n = ++_asked;
    if (ws == null || text.trim().isEmpty) {
      setState(() => _hits = const []);
      return;
    }
    try {
      final r = await ref
          .read(searchClientProvider)
          .query(ws, text.trim(), types: const [SearchKind.task]);
      if (mounted && n == _asked) setState(() => _hits = r.of(SearchKind.task));
    } on Object {
      if (mounted && n == _asked) setState(() => _hits = const []);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pasted = taskIdFromText(_c.text);
    return AlertDialog(
      title: Text(context.l10n.grpBEmbedTaskTitle),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              key: const Key('task-picker-field'),
              controller: _c,
              autofocus: true,
              decoration: InputDecoration(
                labelText: context.l10n.grpBTaskSearchLabel,
              ),
              onChanged: (v) {
                setState(() {});
                _search(v);
              },
            ),
            if (pasted != null)
              ListTile(
                key: const Key('task-use-pasted'),
                dense: true,
                leading: const Icon(Icons.link),
                title: Text(context.l10n.grpBUsePastedTask),
                onTap: () => Navigator.pop(context, pasted),
              ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final h in _hits)
                    ListTile(
                      key: Key('task-hit-${h.taskId}'),
                      dense: true,
                      title: Text('${h.key}  ${h.title}'),
                      subtitle: h.status.isEmpty ? null : Text(h.status),
                      onTap: () => Navigator.pop(context, h.taskId),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(context.l10n.grpBCancel),
        ),
      ],
    );
  }
}

String snippetOf(DocBlock? b, {String removed = '(removed)'}) {
  if (b == null) return removed;
  final t = b.plain.trim();
  if (t.isEmpty) return '(${b.type})';
  return t.length > 80 ? '${t.substring(0, 80)}...' : t;
}

/// Shown when a save met a newer version: the blocks both sides changed are
/// listed and each can be kept as mine or taken as theirs; everything else
/// merges by itself.
class ConflictDialog extends ConsumerStatefulWidget {
  const ConflictDialog({super.key, required this.docId});

  final String docId;

  @override
  ConsumerState<ConflictDialog> createState() => _ConflictDialogState();
}

class _ConflictDialogState extends ConsumerState<ConflictDialog> {
  final _theirs = <String>{};

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(docSessionProvider(widget.docId));
    final notifier = ref.read(docSessionProvider(widget.docId).notifier);
    if (s.conflict == null) return const SizedBox.shrink();
    final merge = mergeFor(s, takeTheirs: _theirs);
    return AlertDialog(
      key: const Key('conflict-dialog'),
      title: Text(context.l10n.grpBConflictTitle),
      content: SizedBox(
        width: 480,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                merge.clean
                    ? context.l10n.grpBConflictClean
                    : context.l10n.grpBConflictOverlap,
              ),
              for (final c in merge.conflicts) ...[
                const Divider(),
                Text(
                  context.l10n.grpBConflictBlock(
                    snippetOf(
                      c.mine ?? c.theirs,
                      removed: context.l10n.grpBSnippetRemoved,
                    ),
                  ),
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                RadioGroup<bool>(
                  groupValue: _theirs.contains(c.id),
                  onChanged: (v) => setState(() {
                    if (v ?? false) {
                      _theirs.add(c.id);
                    } else {
                      _theirs.remove(c.id);
                    }
                  }),
                  child: Column(
                    children: [
                      RadioListTile<bool>(
                        key: Key('conflict-mine-${c.id}'),
                        dense: true,
                        value: false,
                        title: Text(
                          context.l10n.grpBConflictMine(
                            snippetOf(
                              c.mine,
                              removed: context.l10n.grpBSnippetRemoved,
                            ),
                          ),
                        ),
                      ),
                      RadioListTile<bool>(
                        key: Key('conflict-theirs-${c.id}'),
                        dense: true,
                        value: true,
                        title: Text(
                          context.l10n.grpBConflictTheirs(
                            snippetOf(
                              c.theirs,
                              removed: context.l10n.grpBSnippetRemoved,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          key: const Key('conflict-later'),
          onPressed: () => Navigator.pop(context),
          child: Text(context.l10n.grpBDecideLater),
        ),
        TextButton(
          key: const Key('conflict-take-theirs'),
          onPressed: () {
            notifier.takeTheirs();
            Navigator.pop(context);
          },
          child: Text(context.l10n.grpBDiscardMine),
        ),
        FilledButton(
          key: const Key('conflict-apply'),
          onPressed: () {
            Navigator.pop(context);
            notifier.resolveConflict(merge.blocks);
          },
          child: Text(context.l10n.grpBApplyAndSave),
        ),
      ],
    );
  }
}

/// Who may open a page: everyone who can open its parent, or only the people
/// picked here (and its creator and page managers).
class ShareDialog extends ConsumerStatefulWidget {
  const ShareDialog({super.key, required this.docId});

  final String docId;

  @override
  ConsumerState<ShareDialog> createState() => _ShareDialogState();
}

class _ShareDialogState extends ConsumerState<ShareDialog> {
  late bool _restricted;
  late Set<String> _people;
  String? _error;
  var _busy = false;

  @override
  void initState() {
    super.initState();
    final page = ref.read(docSessionProvider(widget.docId)).page;
    _restricted = page?.node.restricted ?? false;
    _people = {...?page?.accessUserIds};
  }

  Future<void> _save() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref
          .read(docsActionsProvider)
          .setAccess(
            widget.docId,
            restricted: _restricted,
            userIds: _people.toList(),
          );
      if (mounted) Navigator.pop(context);
    } on DocException catch (e) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = docErrorMessage(e, context.l10n);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(docSessionProvider(widget.docId));
    final members = ref.watch(membersProvider).value ?? const [];
    final canManage = s.canManage;
    return AlertDialog(
      key: const Key('share-dialog'),
      title: Text(context.l10n.grpBShareTitle),
      content: SizedBox(
        width: 400,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SwitchListTile(
                key: const Key('share-restricted'),
                title: Text(context.l10n.grpBShareRestrict),
                subtitle: Text(
                  _restricted
                      ? context.l10n.grpBShareRestrictedHint
                      : context.l10n.grpBShareOpenHint,
                ),
                value: _restricted,
                onChanged: canManage && !_busy
                    ? (v) => setState(() => _restricted = v)
                    : null,
              ),
              if (_restricted)
                for (final m in members)
                  CheckboxListTile(
                    key: Key('share-member-${m.userId}'),
                    dense: true,
                    title: Text(m.label),
                    value: _people.contains(m.userId),
                    onChanged: canManage && !_busy
                        ? (v) => setState(() {
                            if (v ?? false) {
                              _people.add(m.userId);
                            } else {
                              _people.remove(m.userId);
                            }
                          })
                        : null,
                  ),
              if (!canManage)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(context.l10n.grpBShareNeedPermission),
                ),
              if (_error != null)
                Text(
                  _error!,
                  key: const Key('share-error'),
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(context.l10n.grpBClose),
        ),
        if (canManage)
          FilledButton(
            key: const Key('share-save'),
            onPressed: _busy ? null : _save,
            child: Text(context.l10n.grpBSave),
          ),
      ],
    );
  }
}
