import 'package:flutter/material.dart';

/// Shared GlobalKeys so the guided tour can measure real widget bounds.
class TourTargets {
  TourTargets._();

  static final GlobalKey feed = GlobalKey(debugLabel: 'tour_feed');
  static final GlobalKey categories = GlobalKey(debugLabel: 'tour_categories');
  static final GlobalKey bottomNav = GlobalKey(debugLabel: 'tour_bottom_nav');
  static final GlobalKey display = GlobalKey(debugLabel: 'tour_display');

  /// Measure a key's global rect in logical pixels.
  static Rect? rectOf(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx == null) return null;
    final box = ctx.findRenderObject();
    if (box is! RenderBox || !box.hasSize) return null;
    final origin = box.localToGlobal(Offset.zero);
    return origin & box.size;
  }

  /// Approximate a NavigationBar destination slot (0-based).
  static Rect? navDestinationRect(int index, {int count = 5}) {
    final bar = rectOf(bottomNav);
    if (bar == null || count <= 0) return null;
    final slot = bar.width / count;
    // Icon sits in upper portion of the 70px bar.
    final left = bar.left + slot * index + slot * 0.18;
    final top = bar.top + 8;
    return Rect.fromLTWH(left, top, slot * 0.64, 40);
  }
}

enum TourFocusShape { circle, roundedRect }

enum TourCardSide { auto, above, below }
