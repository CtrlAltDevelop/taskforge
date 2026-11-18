import 'package:material_ui/material_ui.dart';

import 'package:taskforge/core/ui/breakpoints.dart';
import 'package:taskforge/core/ui/theme_extension.dart';
import 'package:taskforge/core/ui/tf/tf_button.dart';
import 'package:taskforge/core/ui/tf_icons.dart';
import 'package:taskforge/core/ui/tokens/spacing.dart';

/// Widths a page body grows to before it is centred instead of stretched.
abstract final class TfPageWidth {
  /// Settings, forms and detail pages.
  static const double reading = 760;

  /// Lists and tables (members, audit, timesheet).
  static const double wide = 1120;

  /// Editors that use the whole window.
  static const double full = double.infinity;
}

/// The page-level container every settings and admin screen shares: a column
/// capped at [maxWidth], centred on wide windows, with the gutter of the
/// current [ScreenSize]. [children] scroll as one list; use [child] for a
/// body that scrolls on its own (editors, boards).
class TfPage extends StatelessWidget {
  const TfPage({
    super.key,
    this.children = const [],
    this.child,
    this.maxWidth = TfPageWidth.reading,
    this.bottom,
    this.lazy = false,
  }) : assert(
         child == null || children.length == 0,
         'Give children or child, not both',
       ),
       itemCount = null,
       itemBuilder = null,
       pinned = null;

  /// A long list: [itemBuilder] runs only for rows near the screen, and
  /// [pinned] (a search field, filters) stays above the list, so what is
  /// typed there survives scrolling.
  const TfPage.builder({
    super.key,
    required int this.itemCount,
    required IndexedWidgetBuilder this.itemBuilder,
    this.pinned,
    this.maxWidth = TfPageWidth.reading,
    this.bottom,
  }) : children = const [],
       child = null,
       lazy = true;

  final int? itemCount;
  final IndexedWidgetBuilder? itemBuilder;

  /// Above the scrolling rows of [TfPage.builder]; never scrolls away.
  final Widget? pinned;

  final List<Widget> children;
  final Widget? child;
  final double maxWidth;

  /// Pinned under the scrolling body, e.g. a [TfStickySaveBar].
  final Widget? bottom;

  /// Build [children] as they scroll into view (long lists). Settings pages
  /// keep the default: every child is built, so they can be found and focused.
  final bool lazy;

  @override
  Widget build(BuildContext context) {
    final gutter = pageGutter(ScreenSize.of(context));
    final padding = EdgeInsetsDirectional.fromSTEB(
      gutter,
      TfSpace.lg,
      gutter,
      TfSpace.xl,
    );
    final builder = itemBuilder;
    final body = builder != null
        ? Column(
            children: [
              if (pinned != null)
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(
                    gutter,
                    TfSpace.lg,
                    gutter,
                    TfSpace.sm,
                  ),
                  // Tall pinned content (wrapped filters on a small phone) scrolls
                  // within a share of the window instead of overflowing it.
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.sizeOf(context).height * 0.4,
                    ),
                    child: SingleChildScrollView(child: pinned),
                  ),
                ),
              Expanded(
                child: ListView.builder(
                  padding: padding.copyWith(top: TfSpace.sm),
                  itemCount: itemCount,
                  itemBuilder: builder,
                ),
              ),
            ],
          )
        : child != null
        ? Padding(padding: padding, child: child)
        : lazy
        ? ListView(padding: padding, children: children)
        : SingleChildScrollView(
            padding: padding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: children,
            ),
          );
    return ColoredBox(
      color: context.tf.colors.canvas,
      child: Column(
        children: [
          Expanded(
            child: Align(
              alignment: AlignmentDirectional.topCenter,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: body,
              ),
            ),
          ),
          ?bottom,
        ],
      ),
    );
  }
}

/// Title, optional description, optional back button and actions of a page.
/// Actions wrap under the title on a narrow window instead of overflowing.
class TfPageHeader extends StatelessWidget {
  const TfPageHeader({
    super.key,
    required this.title,
    this.description,
    this.actions = const [],
    this.onBack,
    this.backTooltip,
  }) : assert(
         onBack == null || backTooltip != null,
         'A back button needs a tooltip (its label)',
       );

  final String title;
  final String? description;
  final List<Widget> actions;
  final VoidCallback? onBack;
  final String? backTooltip;

  @override
  Widget build(BuildContext context) {
    final tf = context.tf;
    final c = tf.colors;
    final heading = Row(
      children: [
        if (onBack != null) ...[
          TfIconButton(
            key: const Key('page-back'),
            icon: TfIcons.arrowStart,
            tooltip: backTooltip!,
            onPressed: onBack,
          ),
          const SizedBox(width: TfSpace.sm),
        ],
        Expanded(
          child: Semantics(
            header: true,
            child: Text(
              title,
              style: tf.typography.title.copyWith(color: c.text),
            ),
          ),
        ),
      ],
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: TfSpace.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, box) {
              final stacked = box.maxWidth < 520 || actions.length > 2;
              final bar = Wrap(
                spacing: TfSpace.sm,
                runSpacing: TfSpace.sm,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: actions,
              );
              if (actions.isEmpty) return heading;
              if (stacked) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    heading,
                    const SizedBox(height: TfSpace.sm),
                    bar,
                  ],
                );
              }
              return Row(
                children: [
                  Expanded(child: heading),
                  const SizedBox(width: TfSpace.md),
                  bar,
                ],
              );
            },
          ),
          if (description != null) ...[
            const SizedBox(height: TfSpace.xs),
            Text(
              description!,
              style: tf.typography.body.copyWith(color: c.textMuted),
            ),
          ],
        ],
      ),
    );
  }
}
