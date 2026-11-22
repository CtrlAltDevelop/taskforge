import 'package:taskforge/core/ui/tokens/spacing.dart';
import 'package:taskforge/core/ui/page/tf_page.dart';
import 'package:taskforge/core/ui/page/tf_tile.dart';
import 'package:taskforge/core/ui/tf/tf_row.dart';
import 'package:taskforge/core/ui/tf/tf_banner.dart';
import 'package:taskforge/core/ui/tf/tf_panel.dart';
import 'package:taskforge/core/ui/theme_extension.dart';
import 'package:taskforge/core/ui/tf/tf_button.dart';
import 'package:taskforge/core/ui/tf_icons.dart';
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
        leading: TfIconButton(
          icon: TfIcons.arrowStart,
          tooltip: t.grpBClose,
          onPressed: () => context.canPop() ? context.pop() : context.go('/'),
        ),
      ),
      body: TfPage(
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
              padding: EdgeInsets.all(TfSpace.xl),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => TfBanner(
              message: securityErrorMessage(e, t),
              kind: TfBannerKind.danger,
              actionLabel: t.grpBRetry,
              onAction: () => ref.invalidate(secondFactorStatusProvider),
            ),
          ),
          if (canManage) ...[
            const SizedBox(height: TfSpace.lg),
            if (policy != null) _PolicySection(policy: policy),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: TfSpace.xs),
              child: TfPanel(
                padding: EdgeInsets.zero,
                child: TfTile(
                  key: const Key('open-sso-setup'),
                  title: Text(t.ssoTitle),
                  subtitle: Text(t.ssoSub),
                  leading: const TfIcon(TfIcons.idCard),
                  onTap: () => context.push('/settings/sso'),
                ),
              ),
            ),
          ],
          const SizedBox(height: TfSpace.lg),
          const DevicePrivacyNote(),
        ],
      ),
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({required this.text, this.error = false});

  final String text;
  final bool error;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: TfSpace.lg),
    child: TfBanner(
      message: text,
      kind: error ? TfBannerKind.danger : TfBannerKind.info,
    ),
  );
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
        Padding(
          padding: const EdgeInsets.symmetric(vertical: TfSpace.xs),
          child: TfPanel(
            padding: EdgeInsets.zero,
            child: TfRow(
              title: t.secTwoStep,
              subtitle: status.enabled ? t.secOn : t.secOff,
              leading: Icon(
                status.enabled ? TfIcons.shield.glyph : TfIcons.shield.glyph,
              ),
              trailing: status.enabled
                  ? TfButton(
                      key: const Key('sec-disable'),
                      label: t.secDisable,
                      onPressed: () => _disable(context, ref),
                    )
                  : TfButton(
                      key: const Key('sec-enable'),
                      label: t.secEnable,
                      variant: TfButtonVariant.primary,
                      onPressed: () async {
                        final done = await showEnrollDialog(context);
                        if (done == true) {
                          ref.invalidate(secondFactorStatusProvider);
                          ref.invalidate(securityPolicyProvider);
                        }
                      },
                    ),
            ),
          ),
        ),
        if (status.enabled) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: TfSpace.xs),
            child: TfPanel(
              padding: EdgeInsets.zero,
              child: TfRow(
                title: t.secRecoveryTitle,
                subtitle: t.secCodesLeft(status.unusedRecoveryCodes),
                leading: const TfIcon(TfIcons.key),
                trailing: TfButton(
                  key: const Key('sec-regenerate'),
                  label: t.secRegenerate,
                  variant: TfButtonVariant.ghost,
                  onPressed: () => _regenerate(context, ref),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: TfSpace.xs),
            child: TfPanel(
              padding: EdgeInsets.zero,
              child: TfRow(
                title: t.secDevices,
                subtitle: status.devices.isEmpty
                    ? t.secNoDevices
                    : t.secDevicesSub,
                leading: const TfIcon(TfIcons.devices),
                trailing: status.devices.isEmpty
                    ? null
                    : TfButton(
                        key: const Key('sec-forget-all'),
                        label: t.secForgetAll,
                        variant: TfButtonVariant.ghost,
                        onPressed: () => _revoke(context, ref, ''),
                      ),
              ),
            ),
          ),
          for (final d in status.devices)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: TfSpace.xs),
              child: TfPanel(
                padding: EdgeInsets.zero,
                child: TfTile(
                  title: Text(d.label.isEmpty ? t.secUnnamedDevice : d.label),
                  subtitle: d.expiresAt == null
                      ? null
                      : Text(t.secDeviceUntil(context.localDate(d.expiresAt!))),
                  trailing: TfIconButton(
                    icon: TfIcons.trash,
                    tooltip: t.secForget,
                    onPressed: () => _revoke(context, ref, d.id),
                  ),
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
      padding: const EdgeInsets.only(bottom: TfSpace.sm),
      child: TfPanel(
        padding: const EdgeInsets.all(TfSpace.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t.secPolicyTitle,
              style: context.tf.typography.lead.copyWith(
                color: context.tf.colors.text,
              ),
            ),
            const SizedBox(height: TfSpace.xs),
            TfToggleTile(
              key: const Key('sec-require'),
              value: _require,
              onChanged: _busy ? null : (v) => setState(() => _require = v),
              title: t.secRequire,
              subtitle: t.secRequireSub,
            ),
            const SizedBox(height: TfSpace.md),
            TextField(
              key: const Key('sec-grace'),
              controller: _grace,
              enabled: !_busy && _require,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: t.secGraceDays),
            ),
            const SizedBox(height: TfSpace.md),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TfButton(
                key: const Key('sec-policy-save'),
                label: t.grpBSave,
                variant: TfButtonVariant.primary,
                onPressed: _busy ? null : _save,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
