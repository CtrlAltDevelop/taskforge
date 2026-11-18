import 'package:taskforge/core/ui/tf/tf_row.dart';
import 'package:taskforge/core/ui/tf/tf_button.dart';
import 'package:taskforge/core/ui/tf_icons.dart';
import 'package:taskforge/core/ui/tf_app_bar.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/core/version.dart';
import 'package:taskforge/core/ui/tf/tf_illustration.dart';
import 'package:taskforge/features/system/application/system_providers.dart';
import 'package:taskforge/features/system/presentation/status_screens.dart';

/// Server and client version, and a way to re-check against the server.
class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.l10n;
    final server = ref.watch(serverVersionProvider);
    return Scaffold(
      appBar: TfAppBar(
        title: Text(t.sysAboutTitle),
        leading: TfIconButton(
          icon: TfIcons.arrowStart,
          tooltip: t.grpBClose,
          onPressed: () => context.canPop() ? context.pop() : context.go('/'),
        ),
      ),
      body: ListView(
        children: [
          TfRow(
            key: const Key('about-client-version'),
            title: t.sysClientVersion,
            subtitle: clientVersion,
            leading: const TfIcon(TfIcons.smartphone),
          ),
          TfRow(
            key: const Key('about-server-version'),
            title: t.sysServerVersion,
            subtitle: server.when(
              data: (s) => s.version,
              loading: () => '…',
              error: (_, _) => t.sysUnknown,
            ),
            leading: const TfIcon(TfIcons.server),
          ),
          if (server.value case final s? when s.isNewerThan(clientVersion))
            TfRow(
              title: t.sysUpdateAvailable(s.version),
              leading: const TfIcon(TfIcons.download),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: TfButton(
                key: const Key('about-check'),
                label: t.sysCheckAgain,
                icon: TfIcons.refresh,
                onPressed: () => ref.invalidate(serverVersionProvider),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Blocks the app when it is older than the server's minimum supported client.
class UpdateRequiredScreen extends ConsumerWidget {
  const UpdateRequiredScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.l10n;
    final server = ref.watch(serverVersionProvider).value;
    return PopScope(
      canPop: false,
      child: StatusPage(
        kind: TfIllustrationKind.maintenance,
        title: t.sysUpdateRequiredTitle,
        body: t.sysUpdateRequiredBody(
          clientVersion,
          server?.minClientVersion ?? '',
        ),
        actionLabel: t.sysCheckAgain,
        onAction: () => ref.invalidate(serverVersionProvider),
      ),
    );
  }
}

/// A one-line notice on desktop: the server runs a newer release than this app.
class DesktopUpdateNotice extends ConsumerWidget {
  const DesktopUpdateNotice({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notice = ref.watch(desktopUpdateNoticeProvider);
    if (notice == null) return const SizedBox.shrink();
    final t = context.l10n;
    return MaterialBanner(
      key: const Key('desktop-update-notice'),
      leading: const TfIcon(TfIcons.download),
      content: Text(t.updNoticeText(notice.version)),
      actions: [
        if (notice.downloadUrl.isNotEmpty)
          TfButton(
            key: const Key('update-notice-get'),
            label: t.updNoticeGet,
            variant: TfButtonVariant.ghost,
            onPressed: () => launchUrl(
              Uri.parse(notice.downloadUrl),
              mode: LaunchMode.externalApplication,
            ),
          ),
        TfButton(
          key: const Key('update-notice-dismiss'),
          label: t.updNoticeDismiss,
          variant: TfButtonVariant.ghost,
          onPressed: () => ref
              .read(dismissedUpdateProvider.notifier)
              .dismiss(notice.version),
        ),
      ],
    );
  }
}
