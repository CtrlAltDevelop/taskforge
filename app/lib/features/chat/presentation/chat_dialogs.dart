import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/features/chat/application/chat_providers.dart';
import 'package:taskforge/features/chat/domain/chat.dart';
import 'package:taskforge/features/chat/presentation/chat_labels.dart';
import 'package:taskforge/features/comments/application/chat_prefs.dart';
import 'package:taskforge/features/members/application/members_providers.dart';

/// Asks whether a message that notifies [count] people should go out.
Future<bool> confirmBroadcast(BuildContext context, int count) async {
  final l10n = context.l10n;
  final ok = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      key: const Key('broadcast-dialog'),
      title: Text(l10n.chatBroadcastTitle),
      content: Text(l10n.chatBroadcastBody(count)),
      actions: [
        TextButton(
          key: const Key('broadcast-cancel'),
          onPressed: () => Navigator.pop(context, false),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          key: const Key('broadcast-send'),
          onPressed: () => Navigator.pop(context, true),
          child: Text(l10n.chatBroadcastSend),
        ),
      ],
    ),
  );
  return ok ?? false;
}

/// Somebody mentioned cannot see the space. Those who manage it can add them
/// and send; for everyone else it is a refusal. True means "add and send".
Future<bool> askGrantMentioned(
  BuildContext context, {
  required String names,
  required bool canGrant,
}) async {
  final l10n = context.l10n;
  final ok = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      key: const Key('chat-grant-dialog'),
      title: Text(l10n.grpLCannotSeeSpace),
      content: Text(
        canGrant
            ? l10n.grpLCannotSeeGrant(names)
            : l10n.grpLCannotSeeRefuse(names),
      ),
      actions: [
        TextButton(
          key: const Key('chat-grant-cancel'),
          onPressed: () => Navigator.pop(context, false),
          child: Text(canGrant ? l10n.grpICancel : l10n.grpIOk),
        ),
        if (canGrant)
          FilledButton(
            key: const Key('chat-grant-add'),
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.grpIAddThemAndSend),
          ),
      ],
    ),
  );
  return ok ?? false;
}

enum NewKind { channel, group, message }

/// The New dialog: a channel (a name), a group (a name and people) or a
/// direct message (one person). Returns the space it made or opened.
Future<Space?> showNewChatDialog(BuildContext context) =>
    showDialog<Space>(context: context, builder: (_) => const _NewChatDialog());

class _NewChatDialog extends ConsumerStatefulWidget {
  const _NewChatDialog();

  @override
  ConsumerState<_NewChatDialog> createState() => _NewChatDialogState();
}

class _NewChatDialogState extends ConsumerState<_NewChatDialog> {
  var _kind = NewKind.channel;
  final _name = TextEditingController();
  final _picked = <String>{};
  var _busy = false;
  String? _problem;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    final l10n = context.l10n;
    final name = _name.text.trim();
    if (_kind != NewKind.message && name.isEmpty) {
      setState(() => _problem = l10n.chatNameRequired);
      return;
    }
    if (_kind == NewKind.group && _picked.isEmpty) {
      setState(() => _problem = l10n.chatGroupNeedsMembers);
      return;
    }
    setState(() {
      _busy = true;
      _problem = null;
    });
    final spaces = ref.read(spacesProvider.notifier);
    try {
      final space = switch (_kind) {
        NewKind.channel => await spaces.create(SpaceKind.channel, name, []),
        NewKind.group => await spaces.create(SpaceKind.group, name, [
          ..._picked,
        ]),
        NewKind.message => await spaces.openDm(_picked.first),
      };
      if (mounted) Navigator.pop(context, space);
    } on ChatException catch (e) {
      if (mounted) {
        setState(() {
          _busy = false;
          _problem = chatErrorMessage(e, l10n);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final me = ref.watch(chatMeProvider);
    final people = [
      for (final m in ref.watch(membersProvider).value ?? const [])
        if (m.userId != me) m,
    ];
    final needsPeople = _kind != NewKind.channel;
    return AlertDialog(
      key: const Key('new-chat-dialog'),
      title: Text(l10n.chatNew),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SegmentedButton<NewKind>(
                key: const Key('new-chat-kind'),
                segments: [
                  ButtonSegment(
                    value: NewKind.channel,
                    label: Text(l10n.chatNewChannel),
                  ),
                  ButtonSegment(
                    value: NewKind.group,
                    label: Text(l10n.chatNewGroup),
                  ),
                  ButtonSegment(
                    value: NewKind.message,
                    label: Text(l10n.chatNewMessage),
                  ),
                ],
                selected: {_kind},
                onSelectionChanged: (s) => setState(() {
                  _kind = s.first;
                  _picked.clear();
                  _problem = null;
                }),
              ),
              if (_kind != NewKind.message)
                Padding(
                  padding: const EdgeInsetsDirectional.only(top: 12),
                  child: TextField(
                    key: const Key('new-chat-name'),
                    controller: _name,
                    autofocus: true,
                    decoration: InputDecoration(labelText: l10n.chatNameLabel),
                  ),
                ),
              if (needsPeople) ...[
                Padding(
                  padding: const EdgeInsetsDirectional.only(top: 12),
                  child: Text(
                    _kind == NewKind.group
                        ? l10n.chatMembersLabel
                        : l10n.chatPickPerson,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
                for (final p in people)
                  if (_kind == NewKind.group)
                    CheckboxListTile(
                      key: Key('pick-${p.userId}'),
                      dense: true,
                      value: _picked.contains(p.userId),
                      title: Text(p.label),
                      onChanged: (on) => setState(
                        () => on == true
                            ? _picked.add(p.userId)
                            : _picked.remove(p.userId),
                      ),
                    )
                  else
                    ListTile(
                      key: Key('pick-${p.userId}'),
                      dense: true,
                      selected: _picked.contains(p.userId),
                      leading: Icon(
                        _picked.contains(p.userId)
                            ? Icons.radio_button_checked
                            : Icons.radio_button_unchecked,
                      ),
                      title: Text(p.label),
                      onTap: () => setState(() {
                        _picked
                          ..clear()
                          ..add(p.userId);
                      }),
                    ),
              ],
              if (_problem != null)
                Padding(
                  padding: const EdgeInsetsDirectional.only(top: 8),
                  child: Text(
                    _problem!,
                    key: const Key('new-chat-problem'),
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
          onPressed: _busy ? null : () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          key: const Key('chat-create'),
          onPressed: _busy || (_kind == NewKind.message && _picked.isEmpty)
              ? null
              : _create,
          child: Text(l10n.chatCreate),
        ),
      ],
    );
  }
}

/// The mute / notify / leave sheet of a space.
Future<void> showSpaceSettings(BuildContext context, String spaceId) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _SettingsSheet(spaceId: spaceId),
    );

class _SettingsSheet extends ConsumerWidget {
  const _SettingsSheet({required this.spaceId});

  final String spaceId;

  Future<void> _run(
    BuildContext context,
    Future<void> Function() action,
  ) async {
    final l10n = context.l10n;
    try {
      await action();
    } on ChatException catch (e) {
      if (context.mounted) chatSay(context, chatErrorMessage(e, l10n));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final space = ref.watch(spacesProvider).list.byId(spaceId);
    if (space == null) return const SizedBox.shrink();
    final notifier = ref.read(spacesProvider.notifier);
    final now = ref.watch(chatNowProvider)();
    final muted = space.isMuted(now);
    Widget option(String key, String label, Future<void> Function() action) =>
        ListTile(
          key: Key(key),
          dense: true,
          title: Text(label),
          onTap: () => _run(context, action),
        );
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 4),
              child: Text(
                l10n.chatSettings,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            if (muted)
              option('mute-off', l10n.chatUnmute, () => notifier.mute(spaceId)),
            option(
              'mute-1h',
              l10n.chatMute1h,
              () => notifier.mute(
                spaceId,
                until: now.add(const Duration(hours: 1)),
              ),
            ),
            option(
              'mute-8h',
              l10n.chatMute8h,
              () => notifier.mute(
                spaceId,
                until: now.add(const Duration(hours: 8)),
              ),
            ),
            option(
              'mute-week',
              l10n.chatMuteWeek,
              () => notifier.mute(
                spaceId,
                until: now.add(const Duration(days: 7)),
              ),
            ),
            option(
              'mute-forever',
              l10n.chatMuteForever,
              () => notifier.mute(spaceId, forever: true),
            ),
            option(
              'mute-completely',
              l10n.chatMuteCompletely,
              () => notifier.mute(spaceId, forever: true, completely: true),
            ),
            SwitchListTile(
              key: const Key('notify-all'),
              dense: true,
              title: Text(l10n.chatNotifyAll),
              value: space.notifyAll,
              onChanged: (on) => _run(
                context,
                () => notifier.notify(spaceId, allMessages: on),
              ),
            ),
            if (space.joined && space.kind != SpaceKind.dm && !space.isDefault)
              option('leave-space', l10n.chatLeave, () async {
                await notifier.leave(spaceId);
                if (context.mounted) Navigator.pop(context);
              }),
          ],
        ),
      ),
    );
  }
}
