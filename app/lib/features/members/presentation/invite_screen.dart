import 'package:taskforge/core/ui/tf_app_bar.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/features/members/application/members_providers.dart';
import 'package:taskforge/features/members/domain/members.dart';
import 'package:taskforge/features/workspaces/application/workspace_providers.dart';
import 'package:taskforge/core/ui/tf/tf_feedback.dart';

/// `/invite/:token`. Signed-out visitors never get here: the router sends them
/// to sign-in with this page as the return path.
class InviteScreen extends ConsumerStatefulWidget {
  const InviteScreen({super.key, required this.token});

  final String token;

  @override
  ConsumerState<InviteScreen> createState() => _InviteScreenState();
}

class _InviteScreenState extends ConsumerState<InviteScreen> {
  bool _busy = false;

  /// Failure shown instead of the buttons (accept can still fail on a race or
  /// on an email mismatch).
  InviteException? _failure;

  Future<void> _accept() async {
    setState(() {
      _busy = true;
      _failure = null;
    });
    try {
      final workspace = await ref
          .read(membersClientProvider)
          .accept(widget.token);
      await ref.read(workspacesProvider.notifier).adopt(workspace);
      if (mounted) context.go('/');
    } on InviteException catch (e) {
      if (mounted) {
        setState(() {
          _busy = false;
          _failure = e;
        });
      }
    }
  }

  Future<void> _decline() async {
    setState(() => _busy = true);
    try {
      await ref.read(membersClientProvider).decline(widget.token);
      if (mounted) context.go('/');
    } on InviteException catch (e) {
      if (mounted) {
        setState(() {
          _busy = false;
          _failure = e;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final preview = ref.watch(invitePreviewProvider(widget.token));
    return Scaffold(
      appBar: TfAppBar(title: Text(context.l10n.grpJInvitationTitle)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: preview.when(
              loading: () => const CircularProgressIndicator(),
              error: (e, _) => TfError(
                compact: true,
                message: inviteErrorMessage(e, context.l10n),
                details: '$e',
                retryKey: const Key('retry-invite'),
                onRetry: () =>
                    ref.invalidate(invitePreviewProvider(widget.token)),
              ),
              data: (p) {
                if (p.state != InviteState.valid) {
                  return _Message(
                    text: inviteStateMessage(p.state, context.l10n),
                  );
                }
                final f = _failure;
                return f != null && _isTerminal(f.failure)
                    ? _Message(text: inviteErrorMessage(f, context.l10n))
                    : _offer(p);
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _offer(InvitePreview p) {
    final failure = _failure;
    final inviter = p.inviterName.isEmpty
        ? context.l10n.grpJInvitedToJoin
        : context.l10n.grpJInviterInvitedYou(p.inviterName);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(inviter, textAlign: TextAlign.center),
        const SizedBox(height: 8),
        Text(
          p.workspaceName,
          key: const Key('invite-workspace'),
          style: Theme.of(context).textTheme.headlineMedium,
          textAlign: TextAlign.center,
        ),
        if (failure != null) ...[
          const SizedBox(height: 16),
          Text(
            inviteErrorMessage(failure, context.l10n),
            key: const Key('invite-failure'),
            style: TextStyle(color: Theme.of(context).colorScheme.error),
            textAlign: TextAlign.center,
          ),
        ],
        const SizedBox(height: 24),
        FilledButton(
          key: const Key('join-workspace'),
          onPressed: _busy ? null : _accept,
          child: Text(context.l10n.grpJJoin),
        ),
        TextButton(
          key: const Key('decline-invite'),
          onPressed: _busy ? null : _decline,
          child: Text(context.l10n.grpJDecline),
        ),
      ],
    );
  }
}

bool _isTerminal(InviteFailure f) =>
    f == InviteFailure.expired ||
    f == InviteFailure.revoked ||
    f == InviteFailure.usedUp ||
    f == InviteFailure.notFound;

class _Message extends StatelessWidget {
  const _Message({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(text, key: const Key('invite-message'), textAlign: TextAlign.center),
      TextButton(
        key: const Key('invite-home'),
        onPressed: () => context.go('/'),
        child: Text(context.l10n.grpJGoToTaskForge),
      ),
    ],
  );
}
