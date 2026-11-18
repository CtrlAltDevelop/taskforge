import 'package:taskforge/core/ui/tf_icons.dart';
import 'package:taskforge/core/ui/tf_app_bar.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/features/roles/application/roles_providers.dart';
import 'package:taskforge/features/roles/domain/roles.dart';
import 'package:taskforge/features/security/application/security_providers.dart';
import 'package:taskforge/features/security/data/security_client.dart';
import 'package:taskforge/features/security/domain/security.dart';
import 'package:taskforge/features/security/presentation/code_dialogs.dart';
import 'package:taskforge/features/workspaces/application/workspace_providers.dart';
import 'package:taskforge/core/ui/tf/tf_feedback.dart';

/// Admin page: the workspace's OpenID Connect provider (issuer, client id and
/// secret, allowed domains, group-to-role mapping, "SSO only") with a Test
/// button that checks discovery and signing keys without signing anyone in.
class SsoSetupScreen extends ConsumerWidget {
  const SsoSetupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.l10n;
    final provider = ref.watch(ssoProviderProvider);
    final roles = ref.watch(rolesProvider);
    return Scaffold(
      appBar: TfAppBar(
        title: Text(t.ssoTitle),
        leading: IconButton(
          tooltip: t.grpBClose,
          icon: const TfIcon(TfIcons.arrowStart),
          onPressed: () => context.canPop()
              ? context.pop()
              : context.go('/settings/security'),
        ),
      ),
      body: provider.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) =>
            TfError(message: securityErrorMessage(e, t), details: '$e'),
        data: (p) => _SsoForm(
          key: ValueKey('${p.version}-${p.configured}'),
          provider: p,
          roles: roles.value?.roles ?? const [],
        ),
      ),
    );
  }
}

class _SsoForm extends ConsumerStatefulWidget {
  const _SsoForm({super.key, required this.provider, required this.roles});

  final SsoProvider provider;
  final List<Role> roles;

  @override
  ConsumerState<_SsoForm> createState() => _SsoFormState();
}

class _SsoFormState extends ConsumerState<_SsoForm> {
  late final _name = TextEditingController(text: widget.provider.name);
  late final _issuer = TextEditingController(text: widget.provider.issuer);
  late final _clientId = TextEditingController(text: widget.provider.clientId);
  final _secret = TextEditingController();
  late final _scopes = TextEditingController(text: widget.provider.scopes);
  late final _domains = TextEditingController(
    text: widget.provider.allowedDomains.join(', '),
  );
  late final _groupClaim = TextEditingController(
    text: widget.provider.groupClaim,
  );
  late final List<_Row> _rows = [
    for (final m in widget.provider.groupRoles)
      _Row(TextEditingController(text: m.group), m.roleId),
  ];
  late String _defaultRole = widget.provider.defaultRoleId;
  late bool _autoCreate = widget.provider.autoCreateUsers;
  late bool _enabled = widget.provider.enabled;
  late bool _enforce = widget.provider.enforceSso;
  bool _busy = false;
  String? _error;
  SsoCheck? _check;

  @override
  void dispose() {
    for (final c in [_name, _issuer, _clientId, _secret, _scopes, _domains]) {
      c.dispose();
    }
    _groupClaim.dispose();
    for (final r in _rows) {
      r.group.dispose();
    }
    super.dispose();
  }

  SsoDraft _draft() => SsoDraft(
    name: _name.text.trim(),
    issuer: _issuer.text.trim(),
    clientId: _clientId.text.trim(),
    clientSecret: _secret.text,
    scopes: _scopes.text.trim(),
    allowedDomains: [
      for (final d in _domains.text.split(RegExp(r'[,\s]+')))
        if (d.trim().isNotEmpty) d.trim(),
    ],
    groupClaim: _groupClaim.text.trim(),
    groupRoles: [
      for (final r in _rows)
        if (r.group.text.trim().isNotEmpty && r.roleId.isNotEmpty)
          RoleMapping(group: r.group.text.trim(), roleId: r.roleId),
    ],
    defaultRoleId: _defaultRole,
    autoCreateUsers: _autoCreate,
    enabled: _enabled,
    enforceSso: _enforce,
    expectedVersion: widget.provider.version,
  );

  Future<void> _save() async {
    final ws = ref.read(workspaceScopeProvider);
    if (ws == null) return;
    final t = context.l10n;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(securityClientProvider).saveProvider(ws, _draft());
      ref.invalidate(ssoProviderProvider);
      if (mounted) _say(t.ssoSaved);
    } on Object catch (e) {
      if (mounted) setState(() => _error = securityErrorMessage(e, t));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _test() async {
    final ws = ref.read(workspaceScopeProvider);
    if (ws == null) return;
    final t = context.l10n;
    setState(() {
      _busy = true;
      _check = null;
    });
    try {
      final check = await ref.read(securityClientProvider).testProvider(ws);
      if (mounted) setState(() => _check = check);
    } on Object catch (e) {
      if (mounted) setState(() => _error = securityErrorMessage(e, t));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _delete() async {
    final ws = ref.read(workspaceScopeProvider);
    if (ws == null) return;
    final t = context.l10n;
    final sure = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(t.ssoRemoveTitle),
        content: Text(t.ssoRemoveBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(t.grpBCancel),
          ),
          FilledButton(
            key: const Key('sso-remove-confirm'),
            onPressed: () => Navigator.pop(context, true),
            child: Text(t.grpBDelete),
          ),
        ],
      ),
    );
    if (sure != true) return;
    try {
      await ref.read(securityClientProvider).deleteProvider(ws);
      ref.invalidate(ssoProviderProvider);
    } on Object catch (e) {
      if (mounted) setState(() => _error = securityErrorMessage(e, t));
    }
  }

  void _say(String text) => ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(text)));

  Widget _roleMenu(String value, ValueChanged<String> onChanged, {Key? key}) {
    final ids = {for (final r in widget.roles) r.id};
    return DropdownButtonFormField<String>(
      key: key,
      initialValue: ids.contains(value) ? value : '',
      isExpanded: true,
      items: [
        DropdownMenuItem(
          value: '',
          child: Text(context.l10n.ssoDefaultRoleAuto),
        ),
        for (final r in widget.roles)
          DropdownMenuItem(value: r.id, child: Text(r.name)),
      ],
      onChanged: _busy ? null : (v) => onChanged(v ?? ''),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final colors = Theme.of(context).colorScheme;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(t.ssoRedirectHelp),
            CopyableValue(
              value: widget.provider.redirectUri,
              copyKey: const Key('sso-redirect-copy'),
            ),
            SwitchListTile(
              key: const Key('sso-enabled'),
              contentPadding: EdgeInsets.zero,
              title: Text(t.ssoEnabled),
              value: _enabled,
              onChanged: _busy ? null : (v) => setState(() => _enabled = v),
            ),
            TextField(
              key: const Key('sso-name'),
              controller: _name,
              decoration: InputDecoration(labelText: t.ssoName),
            ),
            const SizedBox(height: 12),
            TextField(
              key: const Key('sso-issuer'),
              controller: _issuer,
              keyboardType: TextInputType.url,
              decoration: InputDecoration(
                labelText: t.ssoIssuer,
                helperText: t.ssoIssuerHelp,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              key: const Key('sso-client-id'),
              controller: _clientId,
              decoration: InputDecoration(labelText: t.ssoClientId),
            ),
            const SizedBox(height: 12),
            TextField(
              key: const Key('sso-client-secret'),
              controller: _secret,
              obscureText: true,
              decoration: InputDecoration(
                labelText: t.ssoClientSecret,
                helperText: widget.provider.hasSecret
                    ? t.ssoSecretKept
                    : t.ssoSecretNeeded,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              key: const Key('sso-scopes'),
              controller: _scopes,
              decoration: InputDecoration(labelText: t.ssoScopes),
            ),
            const SizedBox(height: 12),
            TextField(
              key: const Key('sso-domains'),
              controller: _domains,
              decoration: InputDecoration(
                labelText: t.ssoDomains,
                helperText: t.ssoDomainsHelp,
              ),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              key: const Key('sso-auto-create'),
              contentPadding: EdgeInsets.zero,
              title: Text(t.ssoAutoCreate),
              subtitle: Text(t.ssoAutoCreateSub),
              value: _autoCreate,
              onChanged: _busy ? null : (v) => setState(() => _autoCreate = v),
            ),
            const SizedBox(height: 8),
            Text(t.ssoRoles, style: Theme.of(context).textTheme.titleSmall),
            TextField(
              key: const Key('sso-group-claim'),
              controller: _groupClaim,
              decoration: InputDecoration(labelText: t.ssoGroupClaim),
            ),
            const SizedBox(height: 8),
            _roleMenu(
              _defaultRole,
              (v) => setState(() => _defaultRole = v),
              key: const Key('sso-default-role'),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(t.ssoDefaultRole),
            ),
            for (var i = 0; i < _rows.length; i++)
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _rows[i].group,
                      decoration: InputDecoration(labelText: t.ssoGroup),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _roleMenu(
                      _rows[i].roleId,
                      (v) => setState(() => _rows[i].roleId = v),
                    ),
                  ),
                  IconButton(
                    tooltip: t.grpBDelete,
                    icon: const TfIcon(TfIcons.close),
                    onPressed: () =>
                        setState(() => _rows.removeAt(i).group.dispose()),
                  ),
                ],
              ),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton.icon(
                key: const Key('sso-add-mapping'),
                onPressed: () => setState(
                  () => _rows.add(_Row(TextEditingController(), '')),
                ),
                icon: const TfIcon(TfIcons.plus),
                label: Text(t.ssoAddMapping),
              ),
            ),
            SwitchListTile(
              key: const Key('sso-enforce'),
              contentPadding: EdgeInsets.zero,
              title: Text(t.ssoEnforce),
              subtitle: Text(t.ssoEnforceSub),
              value: _enforce,
              onChanged: _busy ? null : (v) => setState(() => _enforce = v),
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(_error!, style: TextStyle(color: colors.error)),
              ),
            if (_check case final check?)
              ListTile(
                key: const Key('sso-test-result'),
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  check.ok ? TfIcons.success.glyph : TfIcons.error.glyph,
                  color: check.ok ? Colors.green : colors.error,
                ),
                title: Text(
                  check.ok ? t.ssoTestOk(check.keys) : t.ssoTestFailed,
                ),
                subtitle: Text(check.message),
              ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                FilledButton(
                  key: const Key('sso-save'),
                  onPressed: _busy ? null : _save,
                  child: Text(t.grpBSave),
                ),
                OutlinedButton(
                  key: const Key('sso-test'),
                  onPressed: _busy || !widget.provider.configured
                      ? null
                      : _test,
                  child: Text(t.ssoTest),
                ),
                if (widget.provider.configured)
                  TextButton(
                    key: const Key('sso-remove'),
                    onPressed: _busy ? null : _delete,
                    child: Text(t.ssoRemove),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Row {
  _Row(this.group, this.roleId);

  final TextEditingController group;
  String roleId;
}
