import 'package:material_ui/material_ui.dart';

import 'package:taskforge/core/ui/theme_extension.dart';
import 'package:taskforge/core/ui/tokens/spacing.dart';

/// From this width the task shows its fields and its conversation side by
/// side; below it, one column.
const twoColumnFrom = 900.0;

/// Where the details end and the phone's card layout begins.
const phoneBelow = 600.0;

const _activityMin = 340.0;
const _activityMax = 460.0;

/// The activity column's width for a frame [width] wide.
double activityWidth(double width) =>
    (width * 0.36).clamp(_activityMin, _activityMax);

/// Builds the conversation (a real feed or its skeleton): [leading] slivers
/// go above it in the same scroll (the phone), [topBar] stays above it.
typedef ActivityBuilder = Widget Function({
  List<Widget> leading,
  Widget? topBar,
});

/// The two-column geometry of a task, shared by the loaded screen and its
/// skeleton so nothing jumps when the data arrives. Wide: the fields on the
/// left (header fixed, the rest scrolls) and the whole conversation on the
/// right with its composer pinned; neither scrolls the other away. Narrow:
/// one scroll (fields, then conversation) with the composer pinned.
class TaskFrame extends StatelessWidget {
  const TaskFrame({
    super.key,
    required this.header,
    required this.body,
    required this.activity,
  });

  final Widget header;

  /// Title, description, details and tabs.
  final List<Widget> body;
  final ActivityBuilder activity;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, box) {
      final c = context.tf.colors;
      if (box.maxWidth < twoColumnFrom) {
        final gutter = box.maxWidth < phoneBelow ? TfSpace.md : TfSpace.xl;
        return activity(
          topBar: Padding(
            padding: EdgeInsets.fromLTRB(gutter, TfSpace.sm, gutter, 0),
            child: header,
          ),
          leading: [
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: gutter),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: TfSpace.lg,
                  children: body,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: TfSpace.lg)),
          ],
        );
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    TfSpace.xl,
                    TfSpace.md,
                    TfSpace.xl,
                    0,
                  ),
                  child: header,
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(
                      TfSpace.xl,
                      0,
                      TfSpace.xl,
                      TfSpace.xl,
                    ),
                    children: [
                      for (final w in body)
                        Padding(
                          padding: const EdgeInsets.only(bottom: TfSpace.lg),
                          child: w,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          VerticalDivider(width: 1, color: c.border),
          SizedBox(width: activityWidth(box.maxWidth), child: activity()),
        ],
      );
    },
  );
}
