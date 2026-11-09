import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:taskforge/features/workspaces/application/workspace_providers.dart';
import 'package:taskforge/features/workspaces/domain/workspace.dart';
import 'package:taskforge/features/workspaces/presentation/danger_zone.dart';
import 'package:taskforge/features/workspaces/presentation/logo_picker.dart';
import 'package:taskforge/features/workspaces/presentation/recently_deleted.dart';
import 'package:taskforge/features/workspaces/presentation/workspace_logo.dart';

class WorkspaceSettingsScreen extends ConsumerWidget {
  const WorkspaceSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workspace = ref.watch(currentWorkspaceProvider);
    final failed = ref.watch(workspacesProvider).hasError;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          key: const Key('back-home'),
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
        title: const Text('Workspace settings'),
      ),
      body: workspace == null
          ? Center(
              child: failed
                  ? TextButton(
                      key: const Key('retry-workspaces'),
                      onPressed: () => ref.invalidate(workspacesProvider),
                      child: const Text(
                        'Could not load your workspaces. Retry',
                      ),
                    )
                  : const CircularProgressIndicator(),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Keyed so a save, a refresh or a switch starts the form afresh.
                GeneralSection(
                  key: ValueKey('${workspace.id}/${workspace.version}'),
                  workspace: workspace,
                ),
                if (workspace.isOwner) DangerZone(workspace: workspace),
                const RecentlyDeleted(),
              ],
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
            _slugError = workspaceErrorMessage(e);
          } else {
            _error = workspaceErrorMessage(e);
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
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Workspace updated.')));
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
    final canEdit = w.isOwner;
    return Form(
      key: _form,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('General', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          Row(
            children: [
              WorkspaceLogo(workspace: w, radius: 28),
              const SizedBox(width: 16),
              if (canEdit)
                OutlinedButton(
                  key: const Key('change-logo'),
                  onPressed: _busy ? null : _changeLogo,
                  child: const Text('Change logo'),
                ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            key: const Key('settings-name'),
            controller: _name,
            enabled: canEdit,
            decoration: const InputDecoration(labelText: 'Name'),
            validator: validateWorkspaceName,
          ),
          const SizedBox(height: 16),
          TextFormField(
            key: const Key('settings-slug'),
            controller: _slug,
            enabled: canEdit,
            decoration: InputDecoration(
              labelText: 'URL',
              errorText: _slugError,
            ),
            validator: validateSlug,
          ),
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
              child: const Text('Refresh'),
            ),
          if (canEdit) ...[
            const SizedBox(height: 16),
            FilledButton(
              key: const Key('save-workspace'),
              onPressed: _busy ? null : _save,
              child: const Text('Save changes'),
            ),
          ],
        ],
      ),
    );
  }
}
