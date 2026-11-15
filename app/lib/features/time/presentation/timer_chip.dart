import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:taskforge/core/i18n/l10n_context.dart';
import 'package:taskforge/features/time/application/time_providers.dart';
import 'package:taskforge/features/time/domain/time.dart';
import 'package:taskforge/features/shortcuts/presentation/shortcut_hint.dart';

/// The running timer, on every screen with the sidebar: the task, the time so
/// far (ticking), and a stop button. Nothing while no timer runs. Tapping the
/// task opens it.
class TimerChip extends ConsumerStatefulWidget {
  const TimerChip({super.key});

  @override
  ConsumerState<TimerChip> createState() => _TimerChipState();
}

class _TimerChipState extends ConsumerState<TimerChip> {
  Timer? _tick;
  var _busy = false;

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  void _ensureTicking(bool running) {
    if (running && _tick == null) {
      _tick = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() {});
      });
    } else if (!running) {
      _tick?.cancel();
      _tick = null;
    }
  }

  Future<void> _stop() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await ref.read(timeActionsProvider).stop();
    } on Object catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(content: Text(timeErrorMessage(e, context.l10n))),
          );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(currentTimerProvider).value;
    final entry = state?.entry;
    _ensureTicking(entry != null);
    if (state == null || entry == null) return const SizedBox.shrink();
    final theme = Theme.of(context);
    return Material(
      key: const Key('timer-chip'),
      color: theme.colorScheme.inverseSurface,
      elevation: 4,
      borderRadius: BorderRadius.circular(32),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(16, 4, 4, 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.fiber_manual_record,
              size: 12,
              color: Colors.redAccent,
              semanticLabel: context.l10n.grpJTimerRunning,
            ),
            const SizedBox(width: 8),
            InkWell(
              key: const Key('timer-open-task'),
              onTap: () => context.go(
                '/projects/${entry.projectId}?task=${entry.taskId}',
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Text(
                  entry.key,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: theme.colorScheme.onInverseSurface),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              clockText(state.elapsedAt(ref.read(timeNowProvider)())),
              key: const Key('timer-elapsed'),
              style: TextStyle(
                color: theme.colorScheme.onInverseSurface,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            IconButton(
              key: const Key('timer-stop'),
              tooltip: withShortcut(
                ref,
                context.l10n.grpJStopTheTimer,
                'timer.stop',
                l10n: context.l10n,
              ),
              color: theme.colorScheme.onInverseSurface,
              icon: const Icon(Icons.stop_circle_outlined),
              onPressed: _busy ? null : _stop,
            ),
          ],
        ),
      ),
    );
  }
}
