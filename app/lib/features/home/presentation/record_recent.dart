import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskforge/features/home/application/home_providers.dart';

/// Tells the server the person opened [taskId] (feeds Home's Recent card),
/// once per opening; a task opened after another one counts again.
class RecordRecentOnOpen extends ConsumerStatefulWidget {
  const RecordRecentOnOpen({
    super.key,
    required this.taskId,
    required this.child,
  });

  final String taskId;
  final Widget child;

  @override
  ConsumerState<RecordRecentOnOpen> createState() => _RecordRecentOnOpenState();
}

class _RecordRecentOnOpenState extends ConsumerState<RecordRecentOnOpen> {
  @override
  void initState() {
    super.initState();
    _record();
  }

  @override
  void didUpdateWidget(RecordRecentOnOpen old) {
    super.didUpdateWidget(old);
    if (old.taskId != widget.taskId) _record();
  }

  void _record() => Future.microtask(() {
    if (mounted) ref.read(recordRecentProvider)(widget.taskId);
  });

  @override
  Widget build(BuildContext context) => widget.child;
}
