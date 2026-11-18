import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/core/ui/theme_extension.dart';
import 'package:taskforge/core/ui/tf/tf_button.dart';
import 'package:taskforge/core/ui/tf/tf_illustration.dart';
import 'package:taskforge/core/ui/tokens/spacing.dart';
import 'package:taskforge/features/system/application/system_providers.dart';

/// A designed full page for a state the app cannot go on from: a picture, a
/// plain title and sentence, and one action. The base of 404, no-access,
/// offline, maintenance and update-required.
class StatusPage extends StatelessWidget {
  const StatusPage({
    super.key,
    required this.kind,
    required this.title,
    required this.body,
    required this.actionLabel,
    required this.onAction,
  });

  final TfIllustrationKind kind;
  final String title;
  final String body;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final tf = context.tf;
    final c = tf.colors;
    return Scaffold(
      backgroundColor: c.canvas,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Padding(
                padding: const EdgeInsets.all(TfSpace.xl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TfIllustration(kind, height: 144),
                    const SizedBox(height: TfSpace.lg),
                    Semantics(
                      header: true,
                      child: Text(
                        title,
                        textAlign: TextAlign.center,
                        style: tf.typography.title.copyWith(color: c.text),
                      ),
                    ),
                    const SizedBox(height: TfSpace.sm),
                    Text(
                      body,
                      textAlign: TextAlign.center,
                      style: tf.typography.body.copyWith(color: c.textMuted),
                    ),
                    const SizedBox(height: TfSpace.xl),
                    TfButton(
                      key: const Key('status-action'),
                      label: actionLabel,
                      onPressed: onAction,
                      variant: TfButtonVariant.primary,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

void _home(BuildContext context) => context.go('/');

/// The router's `errorBuilder` page: no route matches.
class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    return StatusPage(
      kind: TfIllustrationKind.notFound,
      title: t.sysNotFoundTitle,
      body: t.sysNotFoundBody,
      actionLabel: t.sysGoHome,
      onAction: () => _home(context),
    );
  }
}

/// The signed-in user may not see this workspace, project or page.
class NoAccessScreen extends StatelessWidget {
  const NoAccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    return StatusPage(
      kind: TfIllustrationKind.noAccess,
      title: t.sysNoAccessTitle,
      body: t.sysNoAccessBody,
      actionLabel: t.sysGoHome,
      onAction: () => _home(context),
    );
  }
}

/// No connection and nothing cached to show.
class NoConnectionScreen extends StatelessWidget {
  const NoConnectionScreen({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    return StatusPage(
      kind: TfIllustrationKind.offline,
      title: t.sysOfflineTitle,
      body: t.sysOfflineBody,
      actionLabel: t.errRetry,
      onAction: onRetry,
    );
  }
}

/// The server is down for an update.
class MaintenanceScreen extends ConsumerWidget {
  const MaintenanceScreen({super.key, this.onRetry});

  /// Defaults to re-checking the server version.
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.l10n;
    return StatusPage(
      kind: TfIllustrationKind.maintenance,
      title: t.sysMaintenanceTitle,
      body: t.sysMaintenanceBody,
      actionLabel: t.errRetry,
      onAction: onRetry ?? () => ref.invalidate(serverVersionProvider),
    );
  }
}
