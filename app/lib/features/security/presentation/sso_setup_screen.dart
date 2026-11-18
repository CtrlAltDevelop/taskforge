import 'package:taskforge/core/ui/page/tf_tile.dart';
import 'package:taskforge/core/ui/page/tf_select_field.dart';
import 'package:taskforge/core/ui/page/tf_dialog_frame.dart';
import 'package:taskforge/core/ui/tf/tf_row.dart';
import 'package:taskforge/core/ui/tf/tf_field.dart';
import 'package:taskforge/core/ui/tf/tf_checkbox.dart';
import 'package:taskforge/core/ui/tf/tf_button.dart';
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
        leading: TfIconButton(
          icon: TfIcons.arrowStart,
          tooltip: t.grpBClose,
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
      builder: (_) => TfDialogFrame(
        title: t.ssoRemoveTitle,
        content: Text(t.ssoRemoveBody),
        actions: [
          TfButton(
            label: t.grpBCancel,
            variant: TfButtonVariant.ghost,
            onPressed: () => Navigator.pop(context, false),
          ),
          TfButton(
            key: const Key('sso-remove-confirm'),
            label: t.grpBDelete,
            variant: TfButtonVariant.primary,
            onPressed: () => Navigator.pop(context, true),
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
    return TfSelectField<String>(
      key: key,
      options: {
        '': context.l10n.ssoDefaultRoleAuto,
        for (final r in widget.roles) r.id: r.name,
      },
      value: ids.contains(value) ? value : '',
      onChanged: _busy ? null : (v) => onChanged(v),
      expand: true,
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
            TfToggle(
              key: const Key('sso-enabled'),
              value: _enabled,
              onChanged: _busy ? null : (v) => setState(() => _enabled = v),
              label: t.ssoEnabled,
            ),
            TfTextField(
              key: const Key('sso-name'),
              controller: _name,
              label: t.ssoName,
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
            TfTextField(
              key: const Key('sso-client-id'),
              controller: _clientId,
              label: t.ssoClientId,
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
            TfTextField(
              key: const Key('sso-scopes'),
              controller: _scopes,
              label: t.ssoScopes,
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
            TfToggleTile(
              key: const Key('sso-auto-create'),
              value: _autoCreate,
              onChanged: _busy ? null : (v) => setState(() => _autoCreate = v),
              title: t.ssoAutoCreate,
              subtitle: t.ssoAutoCreateSub,
            ),
            const SizedBox(height: 8),
            Text(t.ssoRoles, style: Theme.of(context).textTheme.titleSmall),
            TfTextField(
              key: const Key('sso-group-claim'),
              controller: _groupClaim,
              label: t.ssoGroupClaim,
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
                    child: TfTextField(
                      controller: _rows[i].group,
                      label: t.ssoGroup,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _roleMenu(
                      _rows[i].roleId,
                      (v) => setState(() => _rows[i].roleId = v),
                    ),
                  ),
                  TfIconButton(
                    icon: TfIcons.close,
                    tooltip: t.grpBDelete,
                    onPressed: () =>
                        setState(() => _rows.removeAt(i).group.dispose()),
                  ),
                ],
              ),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TfButton(
                key: const Key('sso-add-mapping'),
                label: t.ssoAddMapping,
                variant: TfButtonVariant.ghost,
                icon: TfIcons.plus,
                onPressed: () => setState(
                  () => _rows.add(_Row(TextEditingController(), '')),
                ),
              ),
            ),
            TfToggleTile(
              key: const Key('sso-enforce'),
              value: _enforce,
              onChanged: _busy ? null : (v) => setState(() => _enforce = v),
              title: t.ssoEnforce,
              subtitle: t.ssoEnforceSub,
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(_error!, style: TextStyle(color: colors.error)),
              ),
            if (_check case final check?)
              TfRow(
                key: const Key('sso-test-result'),
                title: check.ok ? t.ssoTestOk(check.keys) : t.ssoTestFailed,
                subtitle: check.message,
                leading: Icon(
                  check.ok ? TfIcons.success.glyph : TfIcons.error.glyph,
                  color: check.ok ? Colors.green : colors.error,
                ),
              ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                TfButton(
                  key: const Key('sso-save'),
                  label: t.grpBSave,
                  variant: TfButtonVariant.primary,
                  onPressed: _busy ? null : _save,
                ),
                TfButton(
                  key: const Key('sso-test'),
                  label: t.ssoTest,
                  onPressed: _busy || !widget.provider.configured
                      ? null
                      : _test,
                ),
                if (widget.provider.configured)
                  TfButton(
                    key: const Key('sso-remove'),
                    label: t.ssoRemove,
                    variant: TfButtonVariant.ghost,
                    onPressed: _busy ? null : _delete,
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
