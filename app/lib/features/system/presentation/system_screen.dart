import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/features/system/application/system_providers.dart';
import 'package:taskforge/features/system/domain/system.dart';
import 'package:taskforge/l10n/gen/app_localizations.dart';

/// Admin page: server version and the health of Redis, the Celery broker and workers, and the
/// due work waiting to be handled.
class SystemScreen extends ConsumerWidget {
  const SystemScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.l10n;
    final info = ref.watch(systemInfoProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(t.sysTitle),
        leading: IconButton(
          tooltip: t.grpBClose,
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.canPop() ? context.pop() : context.go('/'),
        ),
        actions: [
          IconButton(
            key: const Key('system-refresh'),
            tooltip: t.sysCheckAgain,
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(systemInfoProvider),
          ),
        ],
      ),
      body: info.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text(
            e is SystemException && e.failure == SystemFailure.denied
                ? t.sysDenied
                : t.sysLoadFailed,
          ),
        ),
        data: (s) => _Body(info: s, t: t),
      ),
    );
  }
}

class _Body extends StatelessWidget {
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

  @override
  Widget build(BuildContext context) {
    final workers = info.eager
        ? t.sysInline
        : (info.workers > 0 ? '${info.workers}' : t.sysNoWorkers);
    return ListView(
      children: [
        ListTile(
          title: Text(t.sysServerVersion),
          subtitle: Text(
            info.commit.isEmpty
                ? info.version
                : '${info.version} (${info.commit.substring(0, info.commit.length.clamp(0, 8))})',
          ),
        ),
        ListTile(
          title: Text(t.sysMinClient),
          subtitle: Text(info.minClientVersion),
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
        ListTile(
          key: const Key('system-backlog'),
          title: Text(t.sysBacklog),
          subtitle: Text(
            info.backlogTotal == 0
                ? t.sysBacklogNone
                : info.backlog.entries
                      .where((e) => e.value > 0)
                      .map((e) => '${e.key}: ${e.value}')
                      .join('\n'),
          ),
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
  Widget build(BuildContext context) => ListTile(
    leading: Icon(
      good ? Icons.check_circle_outline : Icons.error_outline,
      color: good ? Colors.green : Theme.of(context).colorScheme.error,
    ),
    title: Text(label),
    subtitle: Text(text),
  );
}
