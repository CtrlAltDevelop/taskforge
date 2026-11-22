import 'package:flutter/widgets.dart';

/// The three layout classes every screen shares (Material window size classes).
enum ScreenSize {
  /// Phones: one column, bottom navigation, drawer.
  compact,

  /// Tablets and small windows: navigation rail, drawer for the full menu.
  medium,

  /// Desktops: persistent sidebar.
  expanded;

  static const mediumFrom = 600.0;
  static const expandedFrom = 1024.0;

  static ScreenSize ofWidth(double width) => width >= expandedFrom
      ? expanded
      : width >= mediumFrom
      ? medium
      : compact;

  static ScreenSize of(BuildContext context) =>
      ofWidth(MediaQuery.sizeOf(context).width);

  bool get isCompact => this == compact;
  bool get isExpanded => this == expanded;
}

/// Outer page gutter for the screen size: tighter on phones.
double pageGutter(ScreenSize size) => switch (size) {
  ScreenSize.compact => 12,
  ScreenSize.medium => 16,
  ScreenSize.expanded => 28,
};

/// Widest a reading column (forms, settings, detail) grows before it is
/// centered instead of stretched across a wide window.
const contentMaxWidth = 960.0;
