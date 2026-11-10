import 'dart:async';

import 'package:flutter/material.dart';

/// How close to an edge (in pixels) a dragged card starts scrolling, and how
/// far it scrolls every frame.
const edgeZone = 40.0;
const edgeStep = 14.0;

/// Scrolls [controller] while a dragged card is held within [edgeZone] of the
/// start or the end of [axis] of the area [area] marks. The drop targets under
/// the pointer feed it the pointer ([follow]) on every move and tell it when
/// the card leaves ([stop]).
class EdgeScroller {
  EdgeScroller({
    required this.controller,
    required this.axis,
    required this.area,
    required this.direction,
  });

  final ScrollController controller;
  final Axis axis;

  /// A key on the widget whose edges count.
  final GlobalKey area;

  /// The reading direction there: a sideways scroll starts at the right edge in
  /// right-to-left, so the pointer near the left edge means "further".
  final TextDirection Function() direction;
  Timer? _timer;

  /// [pointer] is global.
  void follow(Offset pointer) {
    final box = area.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;
    final local = box.globalToLocal(pointer);
    final (at, length) = axis == Axis.vertical
        ? (local.dy, box.size.height)
        : (local.dx, box.size.width);
    final flip = axis == Axis.horizontal && direction() == TextDirection.rtl;
    if (at < edgeZone) {
      _start(flip ? 1 : -1);
    } else if (at > length - edgeZone) {
      _start(flip ? -1 : 1);
    } else {
      stop();
    }
  }

  void _start(double direction) {
    stop();
    _timer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      if (!controller.hasClients) return;
      controller.jumpTo(
        (controller.offset + direction * edgeStep).clamp(
          controller.position.minScrollExtent,
          controller.position.maxScrollExtent,
        ),
      );
    });
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }
}
