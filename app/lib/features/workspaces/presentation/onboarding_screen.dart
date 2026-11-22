import 'package:taskforge/core/ui/tf_app_bar.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:taskforge/core/auth/auth_providers.dart';
import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/features/workspaces/application/workspace_providers.dart';
import 'package:taskforge/features/workspaces/domain/workspace.dart';
import 'package:taskforge/features/workspaces/presentation/recently_deleted.dart';
import 'package:taskforge/core/ui/tokens/spacing.dart';

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
      // First workspace: pick a starter next; adding another goes home.
      if (mounted) {
        context.go(widget.firstWorkspace ? '/welcome/starter' : '/');
      }
    } on WorkspaceException catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        if (e.failure == WorkspaceFailure.slugTaken) {
          _slugError = workspaceErrorMessage(e, context.l10n);
        } else {
          _error = workspaceErrorMessage(e, context.l10n);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.firstWorkspace
          ? null
          : TfAppBar(title: Text(context.l10n.grpJNewWorkspace)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Form(
            key: _form,
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.all(TfSpace.xl),
              children: [
                Text(
                  context.l10n.grpJCreateYourWorkspace,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: TfSpace.sm),
                Text(context.l10n.grpJWorkspaceHolds),
                const SizedBox(height: TfSpace.xl),
                TextFormField(
                  key: const Key('workspace-name'),
                  controller: _name,
                  decoration: InputDecoration(labelText: context.l10n.grpJName),
                  validator: validateWorkspaceName,
                  onChanged: (v) {
                    if (!_slugEdited) _slug.text = slugify(v);
                  },
                ),
                const SizedBox(height: TfSpace.lg),
                TextFormField(
                  key: const Key('workspace-slug'),
                  controller: _slug,
                  decoration: InputDecoration(
                    labelText: context.l10n.grpJUrl,
                    errorText: _slugError,
                  ),
                  validator: validateSlug,
                  onChanged: (_) {
                    _slugEdited = true;
                    if (_slugError != null) setState(() => _slugError = null);
                  },
                ),
                if (_error != null) ...[
                  const SizedBox(height: TfSpace.lg),
                  Text(
                    _error!,
                    key: const Key('workspace-error'),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
                const SizedBox(height: TfSpace.xl),
                FilledButton(
                  key: const Key('create-workspace'),
                  onPressed: _busy ? null : _submit,
                  child: Text(context.l10n.grpJCreateWorkspace),
                ),
                if (widget.firstWorkspace) ...[
                  const RecentlyDeleted(),
                  const SizedBox(height: TfSpace.lg),
                  TextButton(
                    key: const Key('onboarding-sign-out'),
                    onPressed: ref.read(authSessionProvider).signOut,
                    child: Text(context.l10n.signOut),
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
