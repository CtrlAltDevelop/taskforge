import 'package:taskforge/core/ui/tokens/spacing.dart';
import 'package:taskforge/core/ui/page/tf_page.dart';
import 'package:taskforge/core/ui/page/tf_tile.dart';
import 'package:taskforge/core/ui/tf/tf_row.dart';
import 'package:taskforge/core/ui/tf/tf_panel.dart';
import 'package:taskforge/core/ui/tf/tf_button.dart';
import 'package:taskforge/core/ui/tf_icons.dart';
import 'package:taskforge/core/ui/tf_app_bar.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/features/system/application/system_providers.dart';
import 'package:taskforge/features/system/domain/system.dart';
import 'package:taskforge/l10n/gen/app_localizations.dart';
import 'package:taskforge/core/ui/tf/tf_feedback.dart';
import 'package:taskforge/core/ui/theme_extension.dart';

/// Admin page: server version and the health of Redis, the Celery broker and workers, and the
/// due work waiting to be handled.
class SystemScreen extends ConsumerWidget {
  const SystemScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.l10n;
    final info = ref.watch(systemInfoProvider);
    return Scaffold(
      appBar: TfAppBar(
        title: Text(t.sysTitle),
        leading: TfIconButton(
          icon: TfIcons.arrowStart,
          tooltip: t.grpBClose,
          onPressed: () => context.canPop() ? context.pop() : context.go('/'),
        ),
        actions: [
          TfIconButton(
            key: const Key('system-refresh'),
            icon: TfIcons.refresh,
            tooltip: t.sysCheckAgain,
            onPressed: () => ref.invalidate(systemInfoProvider),
          ),
        ],
      ),
      body: info.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => TfError(
          message: e is SystemException && e.failure == SystemFailure.denied
              ? t.sysDenied
              : t.sysLoadFailed,
          details: '$e',
        ),
        data: (s) => _Body(info: s, t: t),
      ),
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body({required this.info, required this.t});

  final SystemInfo info;
  final AppLocalizations t;

  String _state(String value) => switch (value) {
    'ok' => t.sysOk,
    'unavailable' => t.sysUnavailable,
    'in_memory' => t.sysInMemory,
    _ => t.sysNotConfigured,
  };

  bool _good(String value) => value == 'ok' || value == 'in_memory';

  Future<void> _toggle(BuildContext context, WidgetRef ref, bool on) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(systemClientProvider).setCollectDeviceInfo(enabled: on);
    } on SystemException catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            e.failure == SystemFailure.pepperMissing
                ? t.devAdminPepperMissing
                : t.devAdminSaveFailed,
          ),
        ),
      );
    }
    ref.invalidate(systemInfoProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workers = info.eager
        ? t.sysInline
        : (info.workers > 0 ? '${info.workers}' : t.sysNoWorkers);
    return TfPage(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: TfSpace.xs),
          child: TfPanel(
            padding: EdgeInsets.zero,
            child: TfRow(
              title: t.sysServerVersion,
              subtitle: info.commit.isEmpty
                  ? info.version
                  : '${info.version} (${info.commit.substring(0, info.commit.length.clamp(0, 8))})',
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: TfSpace.xs),
          child: TfPanel(
            padding: EdgeInsets.zero,
            child: TfRow(
              title: t.sysMinClient,
              subtitle: info.minClientVersion,
            ),
          ),
        ),
        const Divider(),
        _StatusTile(
          label: t.sysRedis,
          text: _state(info.redis),
          good: _good(info.redis),
        ),
        _StatusTile(
          label: t.sysBroker,
          text: _state(info.broker),
          good: _good(info.broker),
        ),
        _StatusTile(
          label: t.sysWorkers,
          text: workers,
          good: info.eager || info.workers > 0,
        ),
        const Divider(),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: TfSpace.xs),
          child: TfPanel(
            padding: EdgeInsets.zero,
            child: TfRow(
              key: const Key('system-backlog'),
              title: t.sysBacklog,
              subtitle: info.backlogTotal == 0
                  ? t.sysBacklogNone
                  : info.backlog.entries
                        .where((e) => e.value > 0)
                        .map((e) => '${e.key}: ${e.value}')
                        .join('\n'),
            ),
          ),
        ),
        const Divider(),
        TfToggleTile(
          key: const Key('collect-device-info'),
          value: info.collectDeviceInfo,
          onChanged: info.devicePepperSet || info.collectDeviceInfo
              ? (on) => _toggle(context, ref, on)
              : null,
          title: t.devAdminCollectTitle,
          subtitle: info.devicePepperSet
              ? t.devAdminCollectSubtitle
              : t.devAdminPepperMissing,
        ),
      ],
    );
  }
}

class _StatusTile extends StatelessWidget {
  const _StatusTile({
    required this.label,
    required this.text,
    required this.good,
  });

  final String label;
  final String text;
  final bool good;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: TfSpace.xs),
    child: TfPanel(
      padding: EdgeInsets.zero,
      child: TfRow(
        title: label,
        subtitle: text,
        leading: Icon(
          good ? TfIcons.success.glyph : TfIcons.error.glyph,
          color: good
              ? context.tf.colors.success.fg
              : Theme.of(context).colorScheme.error,
        ),
      ),
    ),
  );
}
