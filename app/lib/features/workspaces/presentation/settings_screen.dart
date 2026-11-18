import 'package:taskforge/core/ui/tf_icons.dart';
import 'package:taskforge/core/ui/tf_app_bar.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/features/roles/application/roles_providers.dart';
import 'package:taskforge/features/roles/domain/roles.dart';
import 'package:taskforge/l10n/gen/app_localizations.dart';
import 'package:taskforge/core/ui/page/tf_form.dart';
import 'package:taskforge/core/ui/page/tf_page.dart';
import 'package:taskforge/core/ui/tf/tf_button.dart';
import 'package:taskforge/core/ui/tf/tf_field.dart';
import 'package:taskforge/core/ui/tf/tf_panel.dart';
import 'package:taskforge/core/ui/tf/tf_row.dart';
import 'package:taskforge/core/ui/tokens/spacing.dart';
import 'package:taskforge/features/roles/presentation/permission_gate.dart';
import 'package:taskforge/features/workspaces/application/workspace_providers.dart';
import 'package:taskforge/features/workspaces/domain/workspace.dart';
import 'package:taskforge/features/workspaces/presentation/danger_zone.dart';
import 'package:taskforge/features/workspaces/presentation/logo_picker.dart';
import 'package:taskforge/features/workspaces/presentation/recently_deleted.dart';
import 'package:taskforge/features/workspaces/presentation/workspace_logo.dart';
import 'package:taskforge/core/ui/tf/tf_banner.dart';
import 'package:taskforge/core/ui/tf/tf_feedback.dart';
import 'package:taskforge/core/ui/theme_extension.dart';

class WorkspaceSettingsScreen extends ConsumerWidget {
  const WorkspaceSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workspace = ref.watch(currentWorkspaceProvider);
    final failed = ref.watch(workspacesProvider).hasError;
    final l10n = context.l10n;
    return Scaffold(
      appBar: TfAppBar(
        leading: TfIconButton(
          key: const Key('back-home'),
          icon: TfIcons.arrowStart,
          tooltip: l10n.grpEBack,
          onPressed: () => context.go('/'),
        ),
        title: Text(l10n.grpEWorkspaceSettingsTitle),
      ),
      body: workspace == null
          ? failed
                ? TfError(
                    message: l10n.grpEWorkspacesLoadRetry,
                    retryKey: const Key('retry-workspaces'),
                    onRetry: () => ref.invalidate(workspacesProvider),
                  )
                : const Center(child: CircularProgressIndicator())
          : TfPage(
              children: [
                // Keyed so a save, a refresh or a switch starts the form afresh.
                GeneralSection(
                  key: ValueKey('${workspace.id}/${workspace.version}'),
                  workspace: workspace,
                ),
                PermissionGate(
                  permission: Perm.workspaceDelete,
                  child: DangerZone(workspace: workspace),
                ),
                const RecentlyDeleted(),
                const SizedBox(height: TfSpace.lg),
                _AdminLinks(
                  l10n: l10n,
                  perms: ref.watch(permissionSetProvider),
                ),
              ],
            ),
    );
  }
}

/// The admin areas reachable from workspace settings, one row each.
class _AdminLinks extends StatelessWidget {
  const _AdminLinks({required this.l10n, required this.perms});

  final AppLocalizations l10n;
  final Permissions perms;

  @override
  Widget build(BuildContext context) {
    final links = [
      (
        Perm.memberView,
        'open-members',
        TfIcons.users,
        l10n.grpEMembers,
        l10n.grpEMembersSub,
        '/members',
      ),
      (
        Perm.roleView,
        'open-roles',
        TfIcons.shield,
        l10n.grpERolesPerms,
        l10n.grpERolesPermsSub,
        '/workspaces/roles',
      ),
      (
        Perm.auditView,
        'open-audit',
        TfIcons.listChecks,
        l10n.grpEAuditLog,
        l10n.grpEAuditLogSub,
        '/audit',
      ),
      (
        Perm.dataManage,
        'open-import',
        TfIcons.sort,
        l10n.grpEImportExport,
        l10n.grpEImportExportSub,
        '/import',
      ),
      (
        Perm.formManage,
        'open-forms',
        TfIcons.form,
        l10n.formsTitle,
        l10n.formsSub,
        '/forms',
      ),
      (
        null,
        'open-developer',
        TfIcons.code,
        l10n.devTitle,
        l10n.devSub,
        '/developer',
      ),
    ];
    return Column(
      children: [
        for (final (perm, key, icon, title, sub, path) in links)
          if (perm == null || perms.can(perm))
            Padding(
              padding: const EdgeInsets.only(bottom: TfSpace.xs),
              child: TfPanel(
                padding: EdgeInsets.zero,
                child: TfRow(
                  key: Key(key),
                  leading: TfIcon(icon),
                  title: title,
                  subtitle: sub,
                  trailing: const TfIcon(TfIcons.chevronEnd),
                  onTap: () => context.push(path),
                ),
              ),
            ),
      ],
    );
  }
}

class GeneralSection extends ConsumerStatefulWidget {
  const GeneralSection({super.key, required this.workspace});

  final Workspace workspace;

  @override
  ConsumerState<GeneralSection> createState() => _GeneralSectionState();
}

class _GeneralSectionState extends ConsumerState<GeneralSection> {
  String? _nameError;
  String? _slugFieldError;
  bool _dirty = false;
  late final _name = TextEditingController(text: widget.workspace.name);
  late final _slug = TextEditingController(text: widget.workspace.slug);
  bool _busy = false;
  String? _error;
  String? _slugError;
  bool _stale = false;

  @override
  void dispose() {
    _name.dispose();
    _slug.dispose();
    super.dispose();
  }

  /// Runs [action], turning a [WorkspaceException] into on-screen feedback.
  Future<bool> _guard(Future<void> Function() action) async {
    setState(() {
      _busy = true;
      _error = null;
      _slugError = null;
      _stale = false;
    });
    try {
      await action();
      return true;
    } on WorkspaceException catch (e) {
      if (mounted) {
        setState(() {
          _busy = false;
          _stale = e.failure == WorkspaceFailure.stale;
          if (e.failure == WorkspaceFailure.slugTaken) {
            _slugError = workspaceErrorMessage(e, context.l10n);
          } else {
            _error = workspaceErrorMessage(e, context.l10n);
          }
        });
      }
      return false;
    }
  }

  Future<void> _save() async {
    final w = widget.workspace;
    final name = _name.text.trim();
    final nameError = validateWorkspaceName(_name.text);
    final slugError = validateSlug(_slug.text);
    setState(() {
      _nameError = nameError;
      _slugFieldError = slugError;
    });
    if (nameError != null || slugError != null) return;
    final saved = await _guard(
      () => ref
          .read(workspacesProvider.notifier)
          .saveChanges(
            w,
            name: name == w.name ? null : name,
            slug: _slug.text == w.slug ? null : _slug.text,
          )
          .then((_) {}),
    );
    if (saved && mounted) {
      showTfToast(
        context,
        context.l10n.grpEWorkspaceUpdated,
        kind: TfBannerKind.success,
      );
    }
  }

  Future<void> _changeLogo() async {
    final picked = await ref.read(logoPickerProvider)();
    if (picked == null) return;
    await _guard(
      () => ref
          .read(workspacesProvider.notifier)
          .uploadLogo(
            widget.workspace,
            bytes: picked.bytes,
            filename: picked.filename,
          )
          .then((_) {}),
    );
  }

  void _markDirty(String _) {
    final w = widget.workspace;
    final dirty = _name.text != w.name || _slug.text != w.slug;
    if (dirty != _dirty) setState(() => _dirty = dirty);
  }

  void _discard() {
    final w = widget.workspace;
    setState(() {
      _name.text = w.name;
      _slug.text = w.slug;
      _nameError = null;
      _slugFieldError = null;
      _dirty = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final w = widget.workspace;
    final l10n = context.l10n;
    final canEdit = ref.watch(permissionSetProvider).can(Perm.workspaceUpdate);
    final c = context.tf.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TfFormSection(
          title: l10n.grpEGeneral,
          children: [
            Row(
              children: [
                WorkspaceLogo(workspace: w, radius: 28),
                const SizedBox(width: TfSpace.lg),
                if (canEdit)
                  TfButton(
                    key: const Key('change-logo'),
                    label: l10n.grpEChangeLogo,
                    onPressed: _busy ? null : _changeLogo,
                  ),
              ],
            ),
            TfTextField(
              key: const Key('settings-name'),
              controller: _name,
              enabled: canEdit,
              label: l10n.grpEName,
              errorText: _nameError,
              onChanged: _markDirty,
            ),
            TfTextField(
              key: const Key('settings-slug'),
              controller: _slug,
              enabled: canEdit,
              label: l10n.grpEUrl,
              errorText: _slugError ?? _slugFieldError,
              onChanged: _markDirty,
            ),
            if (_error != null)
              Text(
                _error!,
                key: const Key('settings-error'),
                style: TextStyle(color: c.danger.fg),
              ),
            if (_stale)
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: TfButton(
                  key: const Key('refresh-workspace'),
                  label: l10n.grpERefresh,
                  onPressed: () =>
                      ref.read(workspacesProvider.notifier).refresh(),
                ),
              ),
          ],
        ),
        if (canEdit)
          TfStickySaveBar(
            saveKey: const Key('save-workspace'),
            dirty: _dirty,
            saving: _busy,
            onSave: _busy ? null : _save,
            saveLabel: l10n.grpESaveChanges,
            onDiscard: _discard,
            discardLabel: l10n.cancel,
          ),
      ],
    );
  }
}
