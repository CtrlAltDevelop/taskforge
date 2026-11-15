import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/core/i18n/bidi.dart';
import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/features/developer/application/developer_providers.dart';
import 'package:taskforge/features/developer/domain/developer.dart';

/// Days a token lasts for each choice in the dialog; 0 is never.
const _expiryChoices = [0, 30, 90, 365];

Future<IssuedToken?> showCreateTokenDialog(
  BuildContext context,
  WidgetRef ref,
  String workspaceId,
) => showDialog<IssuedToken>(
  context: context,
  builder: (_) => _CreateTokenDialog(workspaceId: workspaceId),
);

/// Shows the secret once, with a copy button. It cannot be shown again.
Future<void> showSecretDialog(BuildContext context, IssuedToken issued) =>
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _SecretDialog(issued: issued),
    );

class _CreateTokenDialog extends ConsumerStatefulWidget {
  const _CreateTokenDialog({required this.workspaceId});

  final String workspaceId;

  @override
  ConsumerState<_CreateTokenDialog> createState() => _CreateTokenState();
}

class _CreateTokenState extends ConsumerState<_CreateTokenDialog> {
  final _name = TextEditingController();
  final _scopes = <String>{};
  var _days = 0;
  var _busy = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  String _expiryText(int days) {
    final t = context.l10n;
    return switch (days) {
      30 => t.devExpiry30,
      90 => t.devExpiry90,
      365 => t.devExpiry365,
      _ => t.devExpiryNever,
    };
  }

  Future<void> _submit() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final issued = await ref
          .read(developerClientProvider)
          .createToken(
            widget.workspaceId,
            name: _name.text,
            scopes: _scopes.toList(),
            expiresInDays: _days,
          );
      if (mounted) Navigator.of(context).pop(issued);
    } on DeveloperException catch (e) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = developerErrorMessage(e, context.l10n);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final catalog = ref.watch(developerCatalogProvider);
    return AlertDialog(
      title: Text(context.l10n.devTokenNew),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                key: const Key('token-name'),
                controller: _name,
                maxLength: 80,
                decoration: InputDecoration(
                  labelText: context.l10n.devTokenName,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                context.l10n.devTokenScopes,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              ...catalog.maybeWhen(
                data: (c) => [
                  for (final s in c.scopes)
                    CheckboxListTile(
                      key: Key('scope-${s.key}'),
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      value: _scopes.contains(s.key),
                      title: Text(scopeLabel(context.l10n, s)),
                      subtitle: Text(isolateLtr(s.key)),
                      onChanged: (on) => setState(
                        () => on == true
                            ? _scopes.add(s.key)
                            : _scopes.remove(s.key),
                      ),
                    ),
                ],
                orElse: () => const [LinearProgressIndicator()],
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<int>(
                key: const Key('token-expiry'),
                initialValue: _days,
                decoration: InputDecoration(
                  labelText: context.l10n.devTokenExpiry,
                ),
                items: [
                  for (final d in _expiryChoices)
                    DropdownMenuItem(value: d, child: Text(_expiryText(d))),
                ],
                onChanged: (v) => setState(() => _days = v ?? 0),
              ),
              const SizedBox(height: 12),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    _error!,
                    key: const Key('token-error'),
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
          onPressed: _busy ? null : () => Navigator.of(context).pop(),
          child: Text(context.l10n.grpCCancel),
        ),
        FilledButton(
          key: const Key('create-token'),
          onPressed: _busy || _scopes.isEmpty || _name.text.trim().isEmpty
              ? null
              : _submit,
          child: Text(context.l10n.devTokenCreate),
        ),
      ],
    );
  }
}

class _SecretDialog extends StatefulWidget {
  const _SecretDialog({required this.issued});

  final IssuedToken issued;

  @override
  State<_SecretDialog> createState() => _SecretDialogState();
}

class _SecretDialogState extends State<_SecretDialog> {
  var _copied = false;

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: widget.issued.secret));
    if (mounted) setState(() => _copied = true);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.l10n.devTokenCreatedTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.l10n.devTokenCreatedBody),
          const SizedBox(height: 12),
          SelectableText(
            widget.issued.secret,
            key: const Key('token-secret'),
            textDirection: TextDirection.ltr,
            style: const TextStyle(fontFamily: 'monospace'),
          ),
        ],
      ),
      actions: [
        TextButton.icon(
          key: const Key('copy-secret'),
          onPressed: _copy,
          icon: Icon(_copied ? Icons.check : Icons.copy),
          label: Text(_copied ? context.l10n.devCopied : context.l10n.devCopy),
        ),
        FilledButton(
          key: const Key('secret-done'),
          onPressed: () => Navigator.of(context).pop(),
          child: Text(context.l10n.devDone),
        ),
      ],
    );
  }
}
