import 'package:taskforge/core/ui/content_width.dart';
import 'package:taskforge/core/ui/tf_app_bar.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:taskforge/core/i18n/context_dates.dart';
import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/features/account/device_privacy_note.dart';
import 'package:taskforge/features/roles/application/roles_providers.dart';
import 'package:taskforge/features/roles/domain/roles.dart';
import 'package:taskforge/features/security/application/security_providers.dart';
import 'package:taskforge/features/security/domain/security.dart';
import 'package:taskforge/features/security/presentation/code_dialogs.dart';
import 'package:taskforge/features/security/presentation/enroll_dialog.dart';
import 'package:taskforge/features/workspaces/application/workspace_providers.dart';

void _say(BuildContext context, String text) => ScaffoldMessenger.of(context)
  ..hideCurrentSnackBar()
  ..showSnackBar(SnackBar(content: Text(text)));

/// Your two-step verification (QR enrolment, recovery codes, trusted devices)
/// and, for those who may manage security, the workspace's requirement and
/// single sign-on. A member blocked by "require two-factor" is sent here.
class SecurityScreen extends ConsumerWidget {
  const SecurityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.l10n;
    final status = ref.watch(secondFactorStatusProvider);
    final policy = ref.watch(securityPolicyProvider).value;
    final canManage = ref.watch(permissionSetProvider).can(Perm.securityManage);
    return Scaffold(
      appBar: TfAppBar(
        title: Text(t.secTitle),
        leading: IconButton(
          tooltip: t.grpBClose,
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.canPop() ? context.pop() : context.go('/'),
        ),
      ),
      body: ContentWidth(
        child: ListView(
          children: [
            if (policy != null && policy.blocked)
              _Banner(text: t.secBlocked, error: true)
            else if (policy != null &&
                policy.inGrace &&
                !policy.enrolled &&
                policy.enforcedFrom != null)
              _Banner(
                text: t.secGraceUntil(
                  context.localDate(policy.enforcedFrom!.toLocal()),
                ),
              ),
            status.when(
              data: (s) => _TwoFactorSection(status: s),
              loading: () => const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => ListTile(
                leading: const Icon(Icons.error_outline),
                title: Text(securityErrorMessage(e, t)),
                trailing: TextButton(
                  onPressed: () => ref.invalidate(secondFactorStatusProvider),
                  child: Text(t.grpBRetry),
                ),
              ),
            ),
            if (canManage) ...[
              const Divider(),
              if (policy != null) _PolicySection(policy: policy),
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                clipBehavior: Clip.antiAlias,
                child: ListTile(
                  key: const Key('open-sso-setup'),
                  leading: const Icon(Icons.badge_outlined),
                  title: Text(t.ssoTitle),
                  subtitle: Text(t.ssoSub),
                  onTap: () => context.push('/settings/sso'),
                ),
              ),
            ],
            const Divider(),
            const DevicePrivacyNote(),
          ],
        ),
      ),
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({required this.text, this.error = false});

  final String text;
  final bool error;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return MaterialBanner(
      backgroundColor: error
          ? colors.errorContainer
          : colors.surfaceContainerHighest,
      leading: Icon(error ? Icons.lock_outline : Icons.info_outline),
      content: Text(text),
      actions: const [SizedBox.shrink()],
    );
  }
}

class _TwoFactorSection extends ConsumerWidget {
  const _TwoFactorSection({required this.status});

  final SecondFactorStatus status;

  Future<void> _disable(BuildContext context, WidgetRef ref) async {
    final t = context.l10n;
    final code = await askForCode(
      context,
      title: t.secDisableTitle,
      actionLabel: t.secDisable,
    );
    if (code == null || code.isEmpty) return;
    try {
      await ref.read(securityClientProvider).disable(code);
      ref.invalidate(secondFactorStatusProvider);
      ref.invalidate(securityPolicyProvider);
      if (context.mounted) _say(context, t.secDisabled);
    } on Object catch (e) {
      if (context.mounted) _say(context, securityErrorMessage(e, t));
    }
  }

  Future<void> _regenerate(BuildContext context, WidgetRef ref) async {
    final t = context.l10n;
    final code = await askForCode(
      context,
      title: t.secRegenerateTitle,
      actionLabel: t.secRegenerate,
    );
    if (code == null || code.isEmpty) return;
    try {
      final codes = await ref
          .read(securityClientProvider)
          .regenerateCodes(code);
      ref.invalidate(secondFactorStatusProvider);
      if (context.mounted) await showRecoveryCodes(context, codes);
    } on Object catch (e) {
      if (context.mounted) _say(context, securityErrorMessage(e, t));
    }
  }

  Future<void> _revoke(
    BuildContext context,
    WidgetRef ref,
    String deviceId,
  ) async {
    try {
      await ref.read(securityClientProvider).revokeDevice(deviceId);
      ref.invalidate(secondFactorStatusProvider);
    } on Object catch (e) {
      if (context.mounted) {
        _say(context, securityErrorMessage(e, context.l10n));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          clipBehavior: Clip.antiAlias,
          child: ListTile(
            leading: Icon(
              status.enabled ? Icons.verified_user : Icons.shield_outlined,
            ),
            title: Text(t.secTwoStep),
            subtitle: Text(status.enabled ? t.secOn : t.secOff),
            trailing: status.enabled
                ? OutlinedButton(
                    key: const Key('sec-disable'),
                    onPressed: () => _disable(context, ref),
                    child: Text(t.secDisable),
                  )
                : FilledButton(
                    key: const Key('sec-enable'),
                    onPressed: () async {
                      final done = await showEnrollDialog(context);
                      if (done == true) {
                        ref.invalidate(secondFactorStatusProvider);
                        ref.invalidate(securityPolicyProvider);
                      }
                    },
                    child: Text(t.secEnable),
                  ),
          ),
        ),
        if (status.enabled) ...[
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            clipBehavior: Clip.antiAlias,
            child: ListTile(
              leading: const Icon(Icons.password),
              title: Text(t.secRecoveryTitle),
              subtitle: Text(t.secCodesLeft(status.unusedRecoveryCodes)),
              trailing: TextButton(
                key: const Key('sec-regenerate'),
                onPressed: () => _regenerate(context, ref),
                child: Text(t.secRegenerate),
              ),
            ),
          ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            clipBehavior: Clip.antiAlias,
            child: ListTile(
              leading: const Icon(Icons.devices_other),
              title: Text(t.secDevices),
              subtitle: Text(
                status.devices.isEmpty ? t.secNoDevices : t.secDevicesSub,
              ),
              trailing: status.devices.isEmpty
                  ? null
                  : TextButton(
                      key: const Key('sec-forget-all'),
                      onPressed: () => _revoke(context, ref, ''),
                      child: Text(t.secForgetAll),
                    ),
            ),
          ),
          for (final d in status.devices)
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              clipBehavior: Clip.antiAlias,
              child: ListTile(
                contentPadding: const EdgeInsetsDirectional.only(
                  start: 72,
                  end: 16,
                ),
                title: Text(d.label.isEmpty ? t.secUnnamedDevice : d.label),
                subtitle: d.expiresAt == null
                    ? null
                    : Text(t.secDeviceUntil(context.localDate(d.expiresAt!))),
                trailing: IconButton(
                  tooltip: t.secForget,
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _revoke(context, ref, d.id),
                ),
              ),
            ),
        ],
      ],
    );
  }
}

class _PolicySection extends ConsumerStatefulWidget {
  const _PolicySection({required this.policy});

  final SecurityPolicy policy;

  @override
  ConsumerState<_PolicySection> createState() => _PolicySectionState();
}

class _PolicySectionState extends ConsumerState<_PolicySection> {
  late bool _require = widget.policy.require2fa;
  late final _grace = TextEditingController(
    text: widget.policy.graceDays.toString(),
  );
  bool _busy = false;

  @override
  void dispose() {
    _grace.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final t = context.l10n;
    final ws = ref.read(workspaceScopeProvider);
    final days = int.tryParse(_grace.text.trim());
    if (ws == null) return;
    if (days == null || days < 0 || days > 90) {
      _say(context, t.secGraceInvalid);
      return;
    }
    setState(() => _busy = true);
    try {
      await ref
          .read(securityClientProvider)
          .setPolicy(
            ws,
            require2fa: _require,
            graceDays: days,
            expectedVersion: widget.policy.version,
          );
      ref.invalidate(securityPolicyProvider);
      if (mounted) _say(context, t.secPolicySaved);
    } on Object catch (e) {
      if (mounted) _say(context, securityErrorMessage(e, t));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t.secPolicyTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SwitchListTile(
            key: const Key('sec-require'),
            contentPadding: EdgeInsets.zero,
            title: Text(t.secRequire),
            subtitle: Text(t.secRequireSub),
            value: _require,
            onChanged: _busy ? null : (v) => setState(() => _require = v),
          ),
          const SizedBox(height: 12),
          TextField(
            key: const Key('sec-grace'),
            controller: _grace,
            enabled: !_busy && _require,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: t.secGraceDays),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: FilledButton(
              key: const Key('sec-policy-save'),
              onPressed: _busy ? null : _save,
              child: Text(t.grpBSave),
            ),
          ),
        ],
      ),
    );
  }
}
