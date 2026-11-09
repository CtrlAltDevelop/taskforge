import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:taskforge/core/auth/auth_providers.dart';
import 'package:taskforge/features/workspaces/application/workspace_providers.dart';
import 'package:taskforge/features/workspaces/domain/workspace.dart';
import 'package:taskforge/features/workspaces/presentation/recently_deleted.dart';

/// "Create your workspace": also used (at /workspaces/new) to add another one.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key, this.firstWorkspace = true});

  final bool firstWorkspace;

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _slug = TextEditingController();
  bool _slugEdited = false;
  bool _busy = false;
  String? _error;
  String? _slugError;

  @override
  void dispose() {
    _name.dispose();
    _slug.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
      _slugError = null;
    });
    try {
      await ref
          .read(workspacesProvider.notifier)
          .create(name: _name.text.trim(), slug: _slug.text);
      if (mounted) context.go('/');
    } on WorkspaceException catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        if (e.failure == WorkspaceFailure.slugTaken) {
          _slugError = workspaceErrorMessage(e);
        } else {
          _error = workspaceErrorMessage(e);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.firstWorkspace
          ? null
          : AppBar(title: const Text('New workspace')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Form(
            key: _form,
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.all(24),
              children: [
                Text(
                  'Create your workspace',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                const Text(
                  'A workspace holds your team\'s projects and tasks.',
                ),
                const SizedBox(height: 24),
                TextFormField(
                  key: const Key('workspace-name'),
                  controller: _name,
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: validateWorkspaceName,
                  onChanged: (v) {
                    if (!_slugEdited) _slug.text = slugify(v);
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  key: const Key('workspace-slug'),
                  controller: _slug,
                  decoration: InputDecoration(
                    labelText: 'URL',
                    errorText: _slugError,
                  ),
                  validator: validateSlug,
                  onChanged: (_) {
                    _slugEdited = true;
                    if (_slugError != null) setState(() => _slugError = null);
                  },
                ),
                if (_error != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    _error!,
                    key: const Key('workspace-error'),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                FilledButton(
                  key: const Key('create-workspace'),
                  onPressed: _busy ? null : _submit,
                  child: const Text('Create workspace'),
                ),
                if (widget.firstWorkspace) ...[
                  const RecentlyDeleted(),
                  const SizedBox(height: 16),
                  TextButton(
                    key: const Key('onboarding-sign-out'),
                    onPressed: ref.read(authSessionProvider).signOut,
                    child: const Text('Sign out'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
