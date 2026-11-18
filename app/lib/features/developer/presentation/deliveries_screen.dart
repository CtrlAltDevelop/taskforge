import 'package:taskforge/core/ui/tf/tf_button.dart';
import 'package:taskforge/core/ui/tf_icons.dart';
import 'package:taskforge/core/ui/tf_app_bar.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/features/developer/application/developer_providers.dart';
import 'package:taskforge/features/developer/domain/developer.dart';
import 'package:taskforge/features/developer/presentation/developer_screen.dart';
import 'package:taskforge/features/workspaces/application/workspace_providers.dart';
import 'package:taskforge/core/ui/tf/tf_feedback.dart';

/// A webhook's delivery log: what was sent, what came back, and Resend.
class DeliveriesScreen extends ConsumerStatefulWidget {
  const DeliveriesScreen({super.key, required this.webhookId});

  final String webhookId;

  @override
  ConsumerState<DeliveriesScreen> createState() => _DeliveriesScreenState();
}

class _DeliveriesScreenState extends ConsumerState<DeliveriesScreen> {
  final _more = <Delivery>[];
  String? _cursor;
  var _loading = false;

  Future<void> _loadMore(String cursor) async {
    final ws = ref.read(workspaceScopeProvider);
    if (ws == null) return;
    setState(() => _loading = true);
    try {
      final page = await ref
          .read(developerClientProvider)
          .deliveries(ws, widget.webhookId, before: cursor);
      if (!mounted) return;
      setState(() {
        _more.addAll(page.deliveries);
        _cursor = page.cursor;
      });
    } on DeveloperException catch (e) {
      if (mounted) {
        sayDeveloper(context, developerErrorMessage(e, context.l10n));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resend(Delivery d) async {
    final ws = ref.read(workspaceScopeProvider);
    if (ws == null) return;
    try {
      final sent = await ref
          .read(developerClientProvider)
          .redeliver(ws, widget.webhookId, d.id);
      if (!mounted) return;
      sayDeveloper(
        context,
        context.l10n.devResent(
          sent.statusCode == 0
              ? deliveryStatusLabel(context.l10n, sent.status)
              : '${sent.statusCode}',
        ),
      );
      _more.clear();
      _cursor = null;
      ref.invalidate(deliveriesProvider(widget.webhookId));
    } on DeveloperException catch (e) {
      if (mounted) {
        sayDeveloper(context, developerErrorMessage(e, context.l10n));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final first = ref.watch(deliveriesProvider(widget.webhookId));
    return Scaffold(
      appBar: TfAppBar(
        leading: TfIconButton(
          key: const Key('back-developer'),
          icon: TfIcons.arrowStart,
          tooltip: context.l10n.grpEBack,
          onPressed: () => context.go('/developer'),
        ),
        title: Text(context.l10n.devDeliveriesTitle),
      ),
      body: first.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => TfError(
          details: '$e',
          retryKey: const Key('retry-deliveries'),
          onRetry: () => ref.invalidate(deliveriesProvider(widget.webhookId)),
        ),
        data: (page) {
          final rows = [...page.deliveries, ..._more];
          final cursor = _cursor ?? page.cursor;
          if (rows.isEmpty) {
            return TfEmpty(title: context.l10n.devDeliveriesEmpty);
          }
          return ListView(
            children: [
              for (final d in rows)
                _DeliveryTile(delivery: d, onResend: () => _resend(d)),
              if (cursor.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Center(
                    child: TfButton(
                      key: const Key('load-more-deliveries'),
                      label: context.l10n.devLoadMore,
                      onPressed: _loading ? null : () => _loadMore(cursor),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _DeliveryTile extends StatelessWidget {
  const _DeliveryTile({required this.delivery, required this.onResend});

  final Delivery delivery;
  final VoidCallback onResend;

  @override
  Widget build(BuildContext context) {
    final d = delivery;
    final t = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final color = switch (d.status) {
      DeliveryStatus.delivered => Colors.green,
      DeliveryStatus.pending => scheme.outline,
      _ => scheme.error,
    };
    return ExpansionTile(
      key: Key('delivery-${d.id}'),
      leading: TfIcon(
        d.status == DeliveryStatus.delivered ? TfIcons.success : TfIcons.error,
        color: color,
      ),
      title: Text(eventLabel(t, d.event)),
      subtitle: Text(
        [
          deliveryStatusLabel(t, d.status),
          if (d.statusCode != 0) '${d.statusCode}',
          t.devAttempt(d.attempt),
          whenText(context, d.at.isEmpty ? d.createdAt : d.at),
        ].where((s) => s.isNotEmpty).join(' · '),
      ),
      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      expandedCrossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (d.error.isNotEmpty) Text(d.error),
        if (d.nextRetryAt.isNotEmpty)
          Text(t.devNextTry(whenText(context, d.nextRetryAt))),
        _Block(
          title: t.devRequest,
          subtitle: t.devHeaders,
          text: d.requestHeaders,
        ),
        _Block(title: t.devRequest, subtitle: t.devBody, text: d.payload),
        _Block(
          title: t.devResponse,
          subtitle: d.statusCode == 0 ? '' : '${d.statusCode}',
          text: d.responseSnippet,
        ),
        const SizedBox(height: 8),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: TfButton(
            key: Key('resend-${d.id}'),
            label: t.devResend,
            icon: TfIcons.undo,
            onPressed: onResend,
          ),
        ),
      ],
    );
  }
}

class _Block extends StatelessWidget {
  const _Block({
    required this.title,
    required this.subtitle,
    required this.text,
  });

  final String title;
  final String subtitle;
  final String text;

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            [title, subtitle].where((s) => s.isNotEmpty).join(' · '),
            style: Theme.of(context).textTheme.labelMedium,
          ),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: SelectableText(
              text,
              textDirection: TextDirection.ltr,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
