import 'package:taskforge/core/ui/tokens/spacing.dart';
import 'package:taskforge/core/ui/page/tf_page.dart';
import 'package:taskforge/core/ui/page/tf_tile.dart';
import 'package:taskforge/core/ui/page/tf_dialog_frame.dart';
import 'package:taskforge/core/ui/tf/tf_panel.dart';
import 'package:taskforge/core/ui/tf/tf_button.dart';
import 'package:taskforge/core/ui/tf/tf_chip.dart';
import 'package:taskforge/core/ui/tf_icons.dart';
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
import 'package:taskforge/core/ui/tf/tf_feedback.dart';

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
        leading: TfIconButton(
          key: const Key('back-home'),
          icon: TfIcons.arrowStart,
          tooltip: context.l10n.grpIBack,
          onPressed: () => context.go('/'),
        ),
        title: Text(context.l10n.grpISessions),
        actions: [
          if (others.isNotEmpty)
            TfButton(
              key: const Key('revoke-others'),
              label: context.l10n.grpISignOutOthers,
              variant: TfButtonVariant.ghost,
              onPressed: () =>
                  _revoke(context, ref, [for (final s in others) s.id]),
            ),
        ],
      ),
      body: sessions.when(
        data: (items) => TfPage(
          children: [
            for (final s in items) _SessionTile(session: s, onRevoke: _revoke),
            const SizedBox(height: TfSpace.md),
            const DevicePrivacyNote(),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => TfError(
          details: '$e',
          onRetry: () => ref.invalidate(sessionsProvider),
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
          child: const TfIcon(TfIcons.lock, key: Key('session-bound')),
        )
      : const TfIcon(TfIcons.devices);

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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: TfSpace.xs),
      child: TfPanel(
        padding: EdgeInsets.zero,
        child: TfTile(
          key: Key('session-${session.id}'),
          title: Row(
            children: [
              Flexible(
                child: Text(_title(context), overflow: TextOverflow.ellipsis),
              ),
              TfIconButton(
                key: Key('rename-${session.id}'),
                icon: TfIcons.edit,
                tooltip: l10n.devSessionRename,
                onPressed: () => _rename(context, ref),
              ),
            ],
          ),
          subtitle: Wrap(
            spacing: TfSpace.sm,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              if (session.current)
                TfChip(
                  key: const Key('chip-current'),
                  label: l10n.grpIThisDevice,
                ),
              if (session.newDevice)
                TfChip(
                  key: const Key('chip-new'),
                  label: l10n.devSessionNew,
                ),
              if (session.keyChanged)
                TfChip(
                  key: const Key('chip-key-changed'),
                  label: l10n.devSessionKeyChanged,
                ),
              if (details.isNotEmpty) Text(details),
            ],
          ),
          leading: _device(context),
          trailing: session.current
              ? null
              : TfIconButton(
                  key: Key('revoke-${session.id}'),
                  icon: TfIcons.close,
                  tooltip: l10n.grpISignOutThis,
                  onPressed: () => onRevoke(context, ref, [session.id]),
                ),
        ),
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
    return TfDialogFrame(
      title: l10n.devSessionRenameTitle,
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
        TfButton(
          label: l10n.cancel,
          variant: TfButtonVariant.ghost,
          onPressed: () => Navigator.of(context).pop(),
        ),
        TfButton(
          key: const Key('rename-save'),
          label: l10n.save,
          variant: TfButtonVariant.ghost,
          onPressed: _save,
        ),
      ],
    );
  }
}
