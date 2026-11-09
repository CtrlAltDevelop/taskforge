import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:taskforge/core/ping/ping_client.dart';
import 'package:taskforge/features/debug/ping_providers.dart';

/// Phase 00: three buttons prove REST, gRPC and WebSocket reach the server.
class DebugScreen extends ConsumerWidget {
  const DebugScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clients = ref.watch(pingClientsProvider);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
        title: const Text('TaskForge — connectivity'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [for (final client in clients) PingTile(client: client)],
      ),
    );
  }
}

/// A button plus its latest result.
class PingTile extends StatefulWidget {
  const PingTile({super.key, required this.client});

  final PingClient client;

  @override
  State<PingTile> createState() => _PingTileState();
}

class _PingTileState extends State<PingTile> {
  bool _loading = false;
  String? _reply;
  String? _error;

  Future<void> _run() async {
    setState(() {
      _loading = true;
      _reply = null;
      _error = null;
    });
    String? reply;
    String? error;
    try {
      reply = await widget.client.ping();
    } on Exception catch (e) {
      error = e.toString();
    }
    if (!mounted) return;
    setState(() {
      _loading = false;
      _reply = reply;
      _error = error;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      child: ListTile(
        title: FilledButton(
          onPressed: _loading ? null : _run,
          child: Text('${widget.client.label} ping'),
        ),
        subtitle: switch ((_loading, _reply, _error)) {
          (true, _, _) => const LinearProgressIndicator(),
          (_, final reply?, _) => Text(reply),
          (_, _, final error?) => Text(
            'error: $error',
            style: TextStyle(color: colors.error),
          ),
          _ => null,
        },
      ),
    );
  }
}
