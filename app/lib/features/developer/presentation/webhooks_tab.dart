import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:taskforge/core/i18n/bidi.dart';
import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/features/developer/application/developer_providers.dart';
import 'package:taskforge/features/developer/domain/developer.dart';
import 'package:taskforge/features/developer/presentation/developer_screen.dart';
import 'package:taskforge/features/projects/application/projects_providers.dart';
import 'package:taskforge/features/projects/domain/projects.dart';
import 'package:taskforge/features/workspaces/application/workspace_providers.dart';
import 'package:taskforge/core/ui/tf/tf_feedback.dart';

class WebhooksTab extends ConsumerWidget {
  const WebhooksTab({super.key});

  Future<void> _run(
    BuildContext context,
    WidgetRef ref,
    Future<String?> Function(String ws) call,
  ) async {
    final ws = ref.read(workspaceScopeProvider);
    if (ws == null) return;
    try {
      final note = await call(ws);
      if (note != null && context.mounted) sayDeveloper(context, note);
    } on DeveloperException catch (e) {
      if (context.mounted) {
        sayDeveloper(context, developerErrorMessage(e, context.l10n));
      }
    }
    ref.invalidate(webhooksProvider);
  }

  Future<void> _edit(BuildContext context, WidgetRef ref, Webhook? hook) async {
    final draft = await showDialog<WebhookDraft>(
      context: context,
      builder: (_) => WebhookEditor(hook: hook),
    );
    if (draft == null || !context.mounted) return;
    await _run(context, ref, (ws) async {
      final client = ref.read(developerClientProvider);
      if (hook == null) {
        await client.createWebhook(ws, draft);
      } else {
        await client.updateWebhook(ws, hook, draft);
      }
      return null;
    });
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, Webhook h) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(c.l10n.devWebhookDeleteTitle(h.title)),
        content: Text(c.l10n.devWebhookDeleteBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(c).pop(false),
            child: Text(c.l10n.grpCCancel),
          ),
          FilledButton(
            key: const Key('confirm-delete-webhook'),
            onPressed: () => Navigator.of(c).pop(true),
            child: Text(c.l10n.devWebhookDelete),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    await _run(context, ref, (ws) async {
      await ref.read(developerClientProvider).deleteWebhook(ws, h.id);
      return null;
    });
  }

  Future<void> _test(BuildContext context, WidgetRef ref, Webhook h) =>
      _run(context, ref, (ws) async {
        final d = await ref.read(developerClientProvider).sendTest(ws, h.id);
        return context.mounted
            ? context.l10n.devWebhookTestDone(
                d.statusCode == 0
                    ? deliveryStatusLabel(context.l10n, d.status)
                    : '${d.statusCode}',
              )
            : null;
      });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hooks = ref.watch(webhooksProvider);
    return hooks.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => TfError(
        message: e is DeveloperException && e.failure == DeveloperFailure.denied
            ? context.l10n.devWebhooksDenied
            : developerErrorMessage(e, context.l10n),
        details: '$e',
        retryKey: const Key('retry-webhooks'),
        onRetry: () => ref.invalidate(webhooksProvider),
      ),
      data: (rows) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(context.l10n.devWebhookHint),
          const SizedBox(height: 12),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: FilledButton.icon(
              key: const Key('new-webhook'),
              onPressed: () => _edit(context, ref, null),
              icon: const Icon(Icons.add),
              label: Text(context.l10n.devWebhookNew),
            ),
          ),
          if (rows.isEmpty)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text(context.l10n.devWebhooksEmpty),
            ),
          for (final h in rows)
            Card(
              key: Key('webhook-${h.id}'),
              child: ListTile(
                leading: Icon(
                  h.active ? Icons.webhook : Icons.link_off,
                  color: h.active ? null : Theme.of(context).disabledColor,
                ),
                title: Text(h.title),
                subtitle: Text(
                  [
                    isolateLtr(h.url),
                    if (h.disabledReason.isNotEmpty)
                      context.l10n.devWebhookOff(h.disabledReason),
                  ].join('\n'),
                ),
                isThreeLine: h.disabledReason.isNotEmpty,
                onTap: () => context.push('/developer/webhooks/${h.id}'),
                trailing: PopupMenuButton<String>(
                  key: Key('webhook-menu-${h.id}'),
                  onSelected: (v) => switch (v) {
                    'edit' => _edit(context, ref, h),
                    'test' => _test(context, ref, h),
                    'secret' =>
                      Clipboard.setData(ClipboardData(text: h.secret)).then(
                        (_) => context.mounted
                            ? sayDeveloper(context, context.l10n.devCopied)
                            : null,
                      ),
                    'toggle' => _run(context, ref, (ws) async {
                      await ref
                          .read(developerClientProvider)
                          .updateWebhook(
                            ws,
                            h,
                            WebhookDraft(
                              name: h.name,
                              url: h.url,
                              events: h.events,
                              projectId: h.projectId,
                            ),
                            active: !h.active,
                          );
                      return null;
                    }),
                    'deliveries' => context.push('/developer/webhooks/${h.id}'),
                    _ => _delete(context, ref, h),
                  },
                  itemBuilder: (c) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Text(c.l10n.devWebhookEdit),
                    ),
                    PopupMenuItem(
                      value: 'test',
                      child: Text(c.l10n.devWebhookTest),
                    ),
                    PopupMenuItem(
                      value: 'deliveries',
                      child: Text(c.l10n.devWebhookDeliveries),
                    ),
                    PopupMenuItem(
                      value: 'secret',
                      child: Text(
                        '${c.l10n.devWebhookSecret} · ${c.l10n.devCopy}',
                      ),
                    ),
                    PopupMenuItem(
                      value: 'toggle',
                      child: Text(c.l10n.devWebhookActive),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Text(c.l10n.devWebhookDelete),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Edits (or starts) a webhook: its address and the events it wants.
class WebhookEditor extends ConsumerStatefulWidget {
  const WebhookEditor({super.key, this.hook});

  final Webhook? hook;

  @override
  ConsumerState<WebhookEditor> createState() => _WebhookEditorState();
}

class _WebhookEditorState extends ConsumerState<WebhookEditor> {
  late final _name = TextEditingController(text: widget.hook?.name ?? '');
  late final _url = TextEditingController(text: widget.hook?.url ?? '');
  late final _events = <String>{...?widget.hook?.events};
  late String _projectId = widget.hook?.projectId ?? '';

  @override
  void dispose() {
    _name.dispose();
    _url.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final catalog = ref.watch(developerCatalogProvider);
    final projects =
        ref.watch(projectCatalogProvider(false)).value?.projects ??
        const <Project>[];
    final projectIds = {'', ...projects.map((p) => p.id)};
    final ready = _url.text.trim().isNotEmpty && _events.isNotEmpty;
    return AlertDialog(
      title: Text(
        widget.hook == null
            ? context.l10n.devWebhookNew
            : context.l10n.devWebhookEdit,
      ),
      content: SizedBox(
        width: 440,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                key: const Key('webhook-name'),
                controller: _name,
                maxLength: 80,
                decoration: InputDecoration(
                  labelText: context.l10n.devWebhookName,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                key: const Key('webhook-url'),
                controller: _url,
                keyboardType: TextInputType.url,
                textDirection: TextDirection.ltr,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  labelText: context.l10n.devWebhookUrl,
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                key: const Key('webhook-project'),
                initialValue: projectIds.contains(_projectId) ? _projectId : '',
                decoration: InputDecoration(
                  labelText: context.l10n.devWebhookProject,
                ),
                items: [
                  DropdownMenuItem(
                    value: '',
                    child: Text(context.l10n.devWebhookWholeWorkspace),
                  ),
                  for (final p in projects)
                    DropdownMenuItem(value: p.id, child: Text(p.name)),
                ],
                onChanged: (v) => setState(() => _projectId = v ?? ''),
              ),
              const SizedBox(height: 12),
              Text(
                context.l10n.devWebhookEvents,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              ...catalog.maybeWhen(
                data: (c) => [
                  for (final e in c.events)
                    CheckboxListTile(
                      key: Key('event-${e.key}'),
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      value: _events.contains(e.key),
                      title: Text(eventLabel(context.l10n, e.key, e.label)),
                      subtitle: Text(isolateLtr(e.key)),
                      onChanged: (on) => setState(
                        () => on == true
                            ? _events.add(e.key)
                            : _events.remove(e.key),
                      ),
                    ),
                ],
                orElse: () => const [LinearProgressIndicator()],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(context.l10n.grpCCancel),
        ),
        FilledButton(
          key: const Key('save-webhook'),
          onPressed: ready
              ? () => Navigator.of(context).pop(
                  WebhookDraft(
                    name: _name.text,
                    url: _url.text,
                    events: _events.toList(),
                    projectId: _projectId,
                  ),
                )
              : null,
          child: Text(context.l10n.devWebhookSave),
        ),
      ],
    );
  }
}
