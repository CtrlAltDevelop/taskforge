import 'package:material_ui/material_ui.dart';

import 'package:taskforge/core/ui/theme_extension.dart';
import 'package:taskforge/core/ui/tf/tf_feedback.dart';
import 'package:taskforge/core/ui/tokens/spacing.dart';
import 'package:taskforge/features/tasks/presentation/detail/task_frame.dart';

/// What shows while the task loads: the same frame as the loaded screen
/// (header, title, description, details rows, tabs; conversation and
/// composer), so the data arrives without anything moving.
class TaskSkeleton extends StatelessWidget {
  const TaskSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final control = context.tf.density.controlHeight;
    Widget block(double height, [double? width]) =>
        TfSkeleton(height: height, width: width);
    return KeyedSubtree(
      key: const Key('task-skeleton'),
      child: TaskFrame(
        header: Padding(
          padding: const EdgeInsets.only(bottom: TfSpace.sm),
          child: SizedBox(
            height: control,
            child: Row(
              children: [
                block(14, 72),
                const Spacer(),
                for (var i = 0; i < 3; i++)
                  const Padding(
                    padding: EdgeInsets.only(left: TfSpace.sm),
                    child: TfSkeleton(width: 28, height: 28, circle: true),
                  ),
              ],
            ),
          ),
        ),
        body: [
          block(36, 320),
          block(96),
          Column(
            children: [
              for (var i = 0; i < 6; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: TfSpace.xs),
                  child: SizedBox(
                    height: control,
                    child: Row(
                      spacing: TfSpace.md,
                      children: [block(12, 90), block(16, 120)],
                    ),
                  ),
                ),
            ],
          ),
          block(control + TfSpace.xs, 360),
        ],
        activity: ({leading = const [], topBar}) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ?topBar,
            Expanded(
              child: CustomScrollView(
                physics: const NeverScrollableScrollPhysics(),
                slivers: [
                  ...leading,
                  SliverPadding(
                    padding: const EdgeInsets.all(TfSpace.md),
                    sliver: SliverList.list(
                      children: [
                        block(18, 80),
                        const SizedBox(height: TfSpace.md),
                        for (var i = 0; i < 3; i++)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: TfSpace.sm),
                            child: Row(
                              spacing: TfSpace.sm,
                              children: [
                                TfSkeleton(width: 28, height: 28, circle: true),
                                Expanded(child: TfSkeleton(height: 44)),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(TfSpace.md),
              child: block(96),
            ),
          ],
        ),
      ),
    );
  }
}
