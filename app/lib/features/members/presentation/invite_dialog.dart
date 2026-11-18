import 'package:taskforge/core/ui/tf_icons.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/core/config.dart';
import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/features/auth/validators.dart';
import 'package:taskforge/features/members/application/members_providers.dart';
import 'package:taskforge/features/members/domain/members.dart';
import 'package:taskforge/features/members/presentation/pending_tab.dart';
import 'package:taskforge/features/roles/application/roles_providers.dart';
import 'package:taskforge/features/roles/domain/roles.dart';
import 'package:taskforge/features/workspaces/application/workspace_providers.dart';

class InviteDialog extends StatelessWidget {
  const InviteDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480, maxHeight: 560),
        child: DefaultTabController(
          length: 2,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TabBar(
                tabs: [
                  Tab(
                    key: const Key('invite-tab-email'),
                    text: context.l10n.email,
                  ),
                  Tab(
                    key: const Key('invite-tab-link'),
                    text: context.l10n.grpJLink,
                  ),
                ],
              ),
              const Flexible(
                child: TabBarView(
                  children: [EmailInviteTab(), LinkInviteTab()],
                ),
              ),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: TextButton(
                  key: const Key('close-invite'),
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(context.l10n.close),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EmailInviteTab extends ConsumerStatefulWidget {
  const EmailInviteTab({super.key});

  @override
  ConsumerState<EmailInviteTab> createState() => _EmailInviteTabState();
}

class _EmailInviteTabState extends ConsumerState<EmailInviteTab> {
  final _input = TextEditingController();
  List<String> _emails = const [];
  String _roleId = '';
  String? _fieldError;
  String? _error;
  InviteResult? _result;
  bool _busy = false;

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  /// Turns the typed text (one or several, comma/space separated) into chips.
  void _add() {
    final parts = _input.text
        .split(RegExp(r'[,;\s]+'))
        .where((p) => p.isNotEmpty)
        .map((p) => p.toLowerCase());
    var next = [..._emails];
    for (final email in parts) {
      final problem = validateEmail(email);
      if (problem != null) {
        setState(
          () => _fieldError = context.l10n.grpJInviteInvalidEmail(email),
        );
        return;
      }
      if (next.length >= maxInviteEmails) {
        setState(
          () => _fieldError = context.l10n.grpJInviteTooMany(maxInviteEmails),
        );
        return;
      }
      if (!next.contains(email)) next = [...next, email];
    }
    setState(() {
      _emails = next;
      _fieldError = null;
      _input.clear();
    });
  }

  Future<void> _send() async {
    final workspaceId = ref.read(workspaceScopeProvider);
    if (workspaceId == null) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final result = await ref
          .read(membersClientProvider)
          .invite(workspaceId, _emails, roleId: _roleId);
      final tokens = ref.read(knownTokensProvider.notifier);
      for (final i in result.invitations) {
        tokens.remember(i);
      }
      ref.invalidate(invitationsProvider);
      if (mounted) {
        setState(() {
          _busy = false;
          _result = result;
          _emails = const [];
        });
      }
    } on InviteException catch (e) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = inviteErrorMessage(e, context.l10n);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final result = _result;
    return ListView(
      padding: const EdgeInsets.all(16),
      shrinkWrap: true,
      children: [
        TextField(
          key: const Key('invite-email-input'),
          controller: _input,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: context.l10n.grpJInviteEmails,
            helperText: context.l10n.grpJInviteEmailsHelp(maxInviteEmails),
            errorText: _fieldError,
            suffixIcon: IconButton(
              key: const Key('add-email'),
              tooltip: context.l10n.grpJAdd,
              icon: const TfIcon(TfIcons.plus),
              onPressed: _add,
            ),
          ),
          onSubmitted: (_) => _add(),
        ),
        InviteRoleField(
          name: 'invite-role',
          roleId: _roleId,
          onChanged: (id) => setState(() => _roleId = id),
        ),
        Wrap(
          spacing: 8,
          children: [
            for (final email in _emails)
              InputChip(
                key: Key('chip-$email'),
                label: Text(email),
                onDeleted: () => setState(
                  () => _emails = [
                    for (final e in _emails)
                      if (e != email) e,
                  ],
                ),
              ),
          ],
        ),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              _error!,
              key: const Key('invite-error'),
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        const SizedBox(height: 8),
        FilledButton(
          key: const Key('send-invites'),
          onPressed: _busy || _emails.isEmpty ? null : _send,
          child: Text(
            _emails.isEmpty
                ? context.l10n.grpJInviteSendAll
                : context.l10n.grpJInviteSendCount(_emails.length),
          ),
        ),
        if (result != null) ...[
          const SizedBox(height: 12),
          Text(
            context.l10n.grpJInvited(result.invitations.length),
            key: const Key('invite-sent'),
          ),
          if (result.skippedEmails.isNotEmpty)
            Text(
              context.l10n.grpJInviteSkipped(result.skippedEmails.join(', ')),
              key: const Key('invite-skipped'),
            ),
        ],
      ],
    );
  }
}

const _dayInSeconds = 86400;
const _expiryDays = [1, 7, 30];

class LinkInviteTab extends ConsumerStatefulWidget {
  const LinkInviteTab({super.key});

  @override
  ConsumerState<LinkInviteTab> createState() => _LinkInviteTabState();
}

class _LinkInviteTabState extends ConsumerState<LinkInviteTab> {
  final _maxUses = TextEditingController();
  int _days = 7;
  String _roleId = '';
  String? _usesError;
  String? _error;
  String? _token;
  bool _busy = false;

  @override
  void dispose() {
    _maxUses.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    final workspaceId = ref.read(workspaceScopeProvider);
    if (workspaceId == null) return;
    final text = _maxUses.text.trim();
    final uses = text.isEmpty ? 0 : int.tryParse(text);
    if (uses == null || uses < 0 || uses > maxLinkUses) {
      setState(() => _usesError = context.l10n.grpJMaxUsesInvalid(maxLinkUses));
      return;
    }
    setState(() {
      _busy = true;
      _usesError = null;
      _error = null;
    });
    try {
      final link = await ref
          .read(membersClientProvider)
          .createLink(
            workspaceId,
            expiresIn: _days * _dayInSeconds,
            maxUses: uses,
            roleId: _roleId,
          );
      ref.read(knownTokensProvider.notifier).remember(link);
      ref.invalidate(invitationsProvider);
      if (mounted) {
        setState(() {
          _busy = false;
          _token = link.token;
        });
      }
    } on InviteException catch (e) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = inviteErrorMessage(e, context.l10n);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final token = _token;
    return ListView(
      padding: const EdgeInsets.all(16),
      shrinkWrap: true,
      children: [
        DropdownButtonFormField<int>(
          key: const Key('link-expiry'),
          initialValue: _days,
          decoration: InputDecoration(labelText: context.l10n.grpJExpiresAfter),
          items: [
            for (final d in _expiryDays)
              DropdownMenuItem(value: d, child: Text(context.l10n.grpJDays(d))),
          ],
          onChanged: (v) => setState(() => _days = v ?? _days),
        ),
        const SizedBox(height: 12),
        TextField(
          key: const Key('link-max-uses'),
          controller: _maxUses,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: context.l10n.grpJMaxUses,
            helperText: context.l10n.grpJMaxUsesHelp,
            errorText: _usesError,
          ),
        ),
        InviteRoleField(
          name: 'link-role',
          roleId: _roleId,
          onChanged: (id) => setState(() => _roleId = id),
        ),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              _error!,
              key: const Key('link-error'),
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        const SizedBox(height: 12),
        FilledButton(
          key: const Key('create-link'),
          onPressed: _busy ? null : _create,
          child: Text(context.l10n.grpJCreateLink),
        ),
        if (token != null && token.isNotEmpty)
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: SelectableText(
              AppConfig.inviteUrl(token),
              key: const Key('invite-link'),
            ),
            trailing: IconButton(
              key: const Key('copy-link'),
              tooltip: context.l10n.grpJCopyLink,
              icon: const TfIcon(TfIcons.copy),
              onPressed: () => copyInviteLink(context, token),
            ),
          ),
      ],
    );
  }
}

/// Role the joiner gets. '' = the server default (Member). Hidden without
/// `role.view`; roles the caller may not grant are refused by the server.
class InviteRoleField extends ConsumerWidget {
  const InviteRoleField({
    super.key,
    required this.name,
    required this.roleId,
    required this.onChanged,
  });

  /// Key prefix: the field is `name`, its options `name-option-<role id>`.
  final String name;
  final String roleId;
  final ValueChanged<String> onChanged;

  /// Member is sent as '' so the server applies its own default.
  static String _valueOf(Role r) =>
      r.isBuiltin && r.name == 'Member' ? '' : r.id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canView = ref.watch(permissionSetProvider).can(Perm.roleView);
    final roles = ref.watch(rolesProvider).value?.roles;
    if (!canView || roles == null) return const SizedBox.shrink();
    final values = {for (final r in roles) _valueOf(r)};
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: DropdownButtonFormField<String>(
        key: Key(name),
        initialValue: values.contains(roleId) ? roleId : null,
        decoration: InputDecoration(labelText: context.l10n.grpJRole),
        items: [
          for (final r in roles)
            DropdownMenuItem(
              key: Key('$name-option-${r.id}'),
              value: _valueOf(r),
              child: Text(r.name),
            ),
        ],
        onChanged: (v) => onChanged(v ?? ''),
      ),
    );
  }
}
