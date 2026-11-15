import 'package:taskforge/core/ui/content_width.dart';
import 'package:taskforge/core/ui/tf_app_bar.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:taskforge/core/auth/auth_api.dart';
import 'package:taskforge/core/auth/auth_providers.dart';
import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/features/account/account_client.dart';
import 'package:taskforge/features/account/account_providers.dart';
import 'package:taskforge/features/account/device_privacy_note.dart';
import 'package:taskforge/features/auth/validators.dart';

class SessionsScreen extends ConsumerWidget {
  const SessionsScreen({super.key});

  /// Ends [ids] on the server, then refreshes the list. Failures are shown, not thrown.
  Future<void> _revoke(
    BuildContext context,
    WidgetRef ref,
    List<String> ids,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    try {
      for (final id in ids) {
        await ref.read(authSessionProvider).revokeSession(id);
      }
    } on AuthApiException catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text(authErrorMessage(e, l10n))),
      );
    } on NetworkUnavailable catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text(authErrorMessage(e, l10n))),
      );
    }
    ref.invalidate(sessionsProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessions = ref.watch(sessionsProvider);
    final others =
        sessions.value?.where((s) => !s.current).toList() ??
        const <SessionInfo>[];
    return Scaffold(
      appBar: TfAppBar(
        leading: IconButton(
          key: const Key('back-home'),
          tooltip: context.l10n.grpIBack,
          icon: const BackButtonIcon(),
          onPressed: () => context.go('/'),
        ),
        title: Text(context.l10n.grpISessions),
        actions: [
          if (others.isNotEmpty)
            TextButton(
              key: const Key('revoke-others'),
              onPressed: () =>
                  _revoke(context, ref, [for (final s in others) s.id]),
              child: Text(context.l10n.grpISignOutOthers),
            ),
        ],
      ),
      body: sessions.when(
        data: (items) => ContentWidth(
          child: ListView(
            children: [
              for (final s in items)
                _SessionTile(session: s, onRevoke: _revoke),
              const Divider(),
              const DevicePrivacyNote(),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: TextButton(
            onPressed: () => ref.invalidate(sessionsProvider),
            child: Text(context.l10n.grpIRetry),
          ),
        ),
      ),
    );
  }
}

/// One session: its name (renameable), chips, last use and place, and the revoke action.
class _SessionTile extends ConsumerWidget {
  const _SessionTile({required this.session, required this.onRevoke});

  final SessionInfo session;
  final Future<void> Function(BuildContext, WidgetRef, List<String>) onRevoke;

  /// The device icon, with a lock when the session's tokens are tied to its key (DPoP).
  Widget _device(BuildContext context) => session.dpopBound
      ? Tooltip(
          message: context.l10n.dpopSessionBound,
          child: const Icon(Icons.lock_outline, key: Key('session-bound')),
        )
      : const Icon(Icons.devices);

  String _title(BuildContext context) {
    if (session.name.isNotEmpty) return session.name;
    return session.userAgent.isEmpty
        ? context.l10n.grpIUnknownDevice
        : session.userAgent;
  }

  String _lastUsed(BuildContext context) {
    final at = DateTime.tryParse(session.lastUsedAt)?.toLocal();
    if (at == null) return '';
    final material = MaterialLocalizations.of(context);
    return context.l10n.devSessionLastUsed(
      '${material.formatShortDate(at)} ${material.formatTimeOfDay(TimeOfDay.fromDateTime(at))}',
    );
  }

  Future<void> _rename(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    final name = await showDialog<String>(
      context: context,
      builder: (_) => _RenameDialog(initial: _title(context)),
    );
    if (name == null) return;
    try {
      await ref.read(sessionsApiProvider).rename(session.id, name);
    } on AuthApiException {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.devSessionRenameFailed)),
      );
    } on NetworkUnavailable {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.devSessionRenameFailed)),
      );
    }
    ref.invalidate(sessionsProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final lastUsed = _lastUsed(context);
    final details = [
      if (lastUsed.isNotEmpty) lastUsed,
      if (session.ipAddress.isNotEmpty) session.ipAddress,
      if (session.fingerprintShort.isNotEmpty) '#${session.fingerprintShort}',
    ].join(' · ');
    return ListTile(
      key: Key('session-${session.id}'),
      leading: _device(context),
      title: Row(
        children: [
          Flexible(
            child: Text(_title(context), overflow: TextOverflow.ellipsis),
          ),
          IconButton(
            key: Key('rename-${session.id}'),
            tooltip: l10n.devSessionRename,
            icon: const Icon(Icons.edit_outlined, size: 18),
            onPressed: () => _rename(context, ref),
          ),
        ],
      ),
      subtitle: Wrap(
        spacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          if (session.current)
            Chip(
              key: const Key('chip-current'),
              label: Text(l10n.grpIThisDevice),
              visualDensity: VisualDensity.compact,
            ),
          if (session.newDevice)
            Chip(
              key: const Key('chip-new'),
              label: Text(l10n.devSessionNew),
              visualDensity: VisualDensity.compact,
            ),
          if (session.keyChanged)
            Chip(
              key: const Key('chip-key-changed'),
              label: Text(l10n.devSessionKeyChanged),
              visualDensity: VisualDensity.compact,
            ),
          if (details.isNotEmpty) Text(details),
        ],
      ),
      trailing: session.current
          ? null
          : IconButton(
              key: Key('revoke-${session.id}'),
              tooltip: l10n.grpISignOutThis,
              icon: const Icon(Icons.close),
              onPressed: () => onRevoke(context, ref, [session.id]),
            ),
    );
  }
}

class _RenameDialog extends StatefulWidget {
  const _RenameDialog({required this.initial});

  final String initial;

  @override
  State<_RenameDialog> createState() => _RenameDialogState();
}

class _RenameDialogState extends State<_RenameDialog> {
  late final _controller = TextEditingController(text: widget.initial);
  bool _invalid = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    final name = _controller.text.trim();
    if (name.isEmpty || name.length > 80) {
      setState(() => _invalid = true);
      return;
    }
    Navigator.of(context).pop(name);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.devSessionRenameTitle),
      content: TextField(
        key: const Key('rename-field'),
        controller: _controller,
        autofocus: true,
        maxLength: 80,
        decoration: InputDecoration(
          labelText: l10n.devSessionNameLabel,
          errorText: _invalid ? l10n.devSessionNameInvalid : null,
        ),
        onSubmitted: (_) => _save(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        TextButton(
          key: const Key('rename-save'),
          onPressed: _save,
          child: Text(l10n.save),
        ),
      ],
    );
  }
}
