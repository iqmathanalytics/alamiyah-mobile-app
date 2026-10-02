import 'package:flutter/widgets.dart';

import '../theme/display_prefs.dart';

/// Shared motion language for Alamiyah.
class AppMotion {
  AppMotion._();

  static const Curve curve = Curves.easeInOutCubic;

  static const Duration micro = Duration(milliseconds: 120);
  static const Duration screen = Duration(milliseconds: 220);
  static const Duration theme = Duration(milliseconds: 180);

  /// Updated by [DisplayPrefsController] so page routes can scale duration.
  static bool reduceMotion = false;

  static Duration scaled(Duration base, {required bool reduceMotion}) {
    if (!reduceMotion) return base;
    return Duration(milliseconds: (base.inMilliseconds * 0.45).round());
  }

  static Duration of(BuildContext context, Duration base) {
    return scaled(base, reduceMotion: context.alamiyahDisplay.reduceMotion);
  }

  static Duration get screenNow =>
      scaled(screen, reduceMotion: reduceMotion);

  static Duration get themeNow =>
      scaled(theme, reduceMotion: reduceMotion);

  static Duration get microNow =>
      scaled(micro, reduceMotion: reduceMotion);
}
