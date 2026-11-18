import 'package:taskforge/core/ui/tf_icons.dart';
import 'package:taskforge/core/ui/content_width.dart';
import 'package:taskforge/core/ui/tf_app_bar.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/features/roles/application/roles_providers.dart';
import 'package:taskforge/features/roles/domain/roles.dart';
import 'package:taskforge/features/roles/presentation/permission_gate.dart';
import 'package:taskforge/features/workspaces/application/workspace_providers.dart';
import 'package:taskforge/features/workspaces/domain/workspace.dart';
import 'package:taskforge/features/workspaces/presentation/danger_zone.dart';
import 'package:taskforge/features/workspaces/presentation/logo_picker.dart';
import 'package:taskforge/features/workspaces/presentation/recently_deleted.dart';
import 'package:taskforge/features/workspaces/presentation/workspace_logo.dart';
import 'package:taskforge/core/ui/tf/tf_feedback.dart';

class WorkspaceSettingsScreen extends ConsumerWidget {
  const WorkspaceSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workspace = ref.watch(currentWorkspaceProvider);
    final failed = ref.watch(workspacesProvider).hasError;
    return Scaffold(
      appBar: TfAppBar(
        leading: IconButton(
          key: const Key('back-home'),
          tooltip: context.l10n.grpEBack,
          icon: const BackButtonIcon(),
          onPressed: () => context.go('/'),
        ),
        title: Text(context.l10n.grpEWorkspaceSettingsTitle),
      ),
      body: workspace == null
          ? failed
                ? TfError(
                    message: context.l10n.grpEWorkspacesLoadRetry,
                    retryKey: const Key('retry-workspaces'),
                    onRetry: () => ref.invalidate(workspacesProvider),
                  )
                : const Center(child: CircularProgressIndicator())
          : ContentWidth(
              child: ListView(
                padding: const EdgeInsets.all(16),
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
                  PermissionGate(
                    permission: Perm.memberView,
                    child: ListTile(
                      key: const Key('open-members'),
                      leading: const TfIcon(TfIcons.users),
                      title: Text(context.l10n.grpEMembers),
                      subtitle: Text(context.l10n.grpEMembersSub),
                      onTap: () => context.push('/members'),
                    ),
                  ),
                  PermissionGate(
                    permission: Perm.roleView,
                    child: ListTile(
                      key: const Key('open-roles'),
                      leading: const TfIcon(TfIcons.shield),
                      title: Text(context.l10n.grpERolesPerms),
                      subtitle: Text(context.l10n.grpERolesPermsSub),
                      onTap: () => context.push('/workspaces/roles'),
                    ),
                  ),
                  PermissionGate(
                    permission: Perm.auditView,
                    child: ListTile(
                      key: const Key('open-audit'),
                      leading: const TfIcon(TfIcons.listChecks),
                      title: Text(context.l10n.grpEAuditLog),
                      subtitle: Text(context.l10n.grpEAuditLogSub),
                      onTap: () => context.push('/audit'),
                    ),
                  ),
                  PermissionGate(
                    permission: Perm.dataManage,
                    child: ListTile(
                      key: const Key('open-import'),
                      leading: const TfIcon(TfIcons.sort),
                      title: Text(context.l10n.grpEImportExport),
                      subtitle: Text(context.l10n.grpEImportExportSub),
                      onTap: () => context.push('/import'),
                    ),
                  ),
                  if (ref.watch(permissionSetProvider).can(Perm.formManage))
                    Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: ListTile(
                        key: const Key('open-forms'),
                        leading: const TfIcon(TfIcons.form),
                        title: Text(context.l10n.formsTitle),
                        subtitle: Text(context.l10n.formsSub),
                        onTap: () => context.push('/forms'),
                      ),
                    ),
                  Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: ListTile(
                      key: const Key('open-developer'),
                      leading: const TfIcon(TfIcons.code),
                      title: Text(context.l10n.devTitle),
                      subtitle: Text(context.l10n.devSub),
                      onTap: () => context.push('/developer'),
                    ),
                  ),
                ],
              ),
            ),
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
  final _form = GlobalKey<FormState>();
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
    if (!_form.currentState!.validate()) return;
    final w = widget.workspace;
    final name = _name.text.trim();
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.grpEWorkspaceUpdated)),
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

  @override
  Widget build(BuildContext context) {
    final w = widget.workspace;
    final canEdit = ref.watch(permissionSetProvider).can(Perm.workspaceUpdate);
    return Form(
      key: _form,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.grpEGeneral,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              WorkspaceLogo(workspace: w, radius: 28),
              const SizedBox(width: 16),
              if (canEdit)
                OutlinedButton(
                  key: const Key('change-logo'),
                  onPressed: _busy ? null : _changeLogo,
                  child: Text(context.l10n.grpEChangeLogo),
                ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            key: const Key('settings-name'),
            controller: _name,
            enabled: canEdit,
            decoration: InputDecoration(labelText: context.l10n.grpEName),
            validator: validateWorkspaceName,
          ),
          const SizedBox(height: 16),
          TextFormField(
            key: const Key('settings-slug'),
            controller: _slug,
            enabled: canEdit,
            decoration: InputDecoration(
              labelText: context.l10n.grpEUrl,
              errorText: _slugError,
            ),
            validator: validateSlug,
          ),
          const SizedBox(height: 12),
          if (_error != null) ...[
            const SizedBox(height: 16),
            Text(
              _error!,
              key: const Key('settings-error'),
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
          if (_stale)
            TextButton(
              key: const Key('refresh-workspace'),
              onPressed: () => ref.read(workspacesProvider.notifier).refresh(),
              child: Text(context.l10n.grpERefresh),
            ),
          if (canEdit) ...[
            const SizedBox(height: 16),
            FilledButton(
              key: const Key('save-workspace'),
              onPressed: _busy ? null : _save,
              child: Text(context.l10n.grpESaveChanges),
            ),
          ],
        ],
      ),
    );
  }
}
