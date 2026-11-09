import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/core/config.dart';
import 'package:taskforge/features/auth/validators.dart';
import 'package:taskforge/features/members/application/members_providers.dart';
import 'package:taskforge/features/members/domain/members.dart';
import 'package:taskforge/features/members/presentation/pending_tab.dart';
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
              const TabBar(
                tabs: [
                  Tab(key: Key('invite-tab-email'), text: 'Email'),
                  Tab(key: Key('invite-tab-link'), text: 'Link'),
                ],
              ),
              const Flexible(
                child: TabBarView(
                  children: [EmailInviteTab(), LinkInviteTab()],
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  key: const Key('close-invite'),
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
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
        setState(() => _fieldError = '"$email" is not a valid email address.');
        return;
      }
      if (next.length >= maxInviteEmails) {
        setState(
          () => _fieldError =
              'You can invite at most $maxInviteEmails people at once.',
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
          .invite(workspaceId, _emails);
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
          _error = inviteErrorMessage(e);
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
            labelText: 'Email addresses',
            helperText: 'Separate several with commas. Up to $maxInviteEmails.',
            errorText: _fieldError,
            suffixIcon: IconButton(
              key: const Key('add-email'),
              tooltip: 'Add',
              icon: const Icon(Icons.add),
              onPressed: _add,
            ),
          ),
          onSubmitted: (_) => _add(),
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
            _emails.isEmpty ? 'Send invitations' : 'Send ${_emails.length}',
          ),
        ),
        if (result != null) ...[
          const SizedBox(height: 12),
          Text(
            'Invited ${result.invitations.length}.',
            key: const Key('invite-sent'),
          ),
          if (result.skippedEmails.isNotEmpty)
            Text(
              'Already members, skipped: ${result.skippedEmails.join(', ')}',
              key: const Key('invite-skipped'),
            ),
        ],
      ],
    );
  }
}

const _dayInSeconds = 86400;
const _expiryChoices = {'1 day': 1, '7 days': 7, '30 days': 30};

class LinkInviteTab extends ConsumerStatefulWidget {
  const LinkInviteTab({super.key});

  @override
  ConsumerState<LinkInviteTab> createState() => _LinkInviteTabState();
}

class _LinkInviteTabState extends ConsumerState<LinkInviteTab> {
  final _maxUses = TextEditingController();
  int _days = 7;
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
      setState(
        () => _usesError =
            'Enter a number from 1 to $maxLinkUses, or leave empty.',
      );
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
          _error = inviteErrorMessage(e);
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
          decoration: const InputDecoration(labelText: 'Expires after'),
          items: [
            for (final e in _expiryChoices.entries)
              DropdownMenuItem(value: e.value, child: Text(e.key)),
          ],
          onChanged: (v) => setState(() => _days = v ?? _days),
        ),
        const SizedBox(height: 12),
        TextField(
          key: const Key('link-max-uses'),
          controller: _maxUses,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Max uses',
            helperText: 'Leave empty for unlimited.',
            errorText: _usesError,
          ),
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
          child: const Text('Create link'),
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
              tooltip: 'Copy link',
              icon: const Icon(Icons.copy),
              onPressed: () => copyInviteLink(context, token),
            ),
          ),
      ],
    );
  }
}
