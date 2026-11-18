import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:taskforge/features/tasks/domain/tasks.dart';
import 'package:taskforge/features/tasks/presentation/task_actions.dart';

/// The title edited in place: Enter saves, Esc or leaving the field cancels.
class RenameField extends ConsumerStatefulWidget {
  const RenameField({super.key, required this.task, required this.onDone});

  final Task task;
  final VoidCallback onDone;

  @override
  ConsumerState<RenameField> createState() => _RenameFieldState();
}

class _RenameFieldState extends ConsumerState<RenameField> {
  late final _controller = TextEditingController(text: widget.task.title);
  final _node = FocusNode();
  var _finished = false;

  @override
  void initState() {
    super.initState();
    _controller.selection = TextSelection(
      baseOffset: 0,
      extentOffset: _controller.text.length,
    );
    _node.addListener(() {
      if (!_node.hasFocus) _finish(save: false);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _node.dispose();
    super.dispose();
  }

  void _finish({required bool save}) {
    if (_finished) return;
    _finished = true;
    final title = _controller.text.trim();
    if (save && title.isNotEmpty && title != widget.task.title) {
      saveTask(context, ref, widget.task, TaskPatch(title: title));
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.onDone();
    });
  }

  @override
  Widget build(BuildContext context) => Focus(
    onKeyEvent: (_, event) {
      if (event is KeyDownEvent &&
          event.logicalKey == LogicalKeyboardKey.escape) {
        _finish(save: false);
        return KeyEventResult.handled;
      }
      return KeyEventResult.ignored;
    },
    child: TextField(
      key: Key('rename-${widget.task.id}'),
      controller: _controller,
      focusNode: _node,
      autofocus: true,
      maxLength: maxTitleLength,
      decoration: const InputDecoration(
        isDense: true,
        counterText: '',
        border: OutlineInputBorder(),
      ),
      onSubmitted: (_) => _finish(save: true),
    ),
  );
}
