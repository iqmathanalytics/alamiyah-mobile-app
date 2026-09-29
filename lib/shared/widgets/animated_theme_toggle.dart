import 'package:flutter/material.dart';

import '../../core/motion/app_motion.dart';

class AnimatedThemeToggle extends StatelessWidget {
  const AnimatedThemeToggle({
    super.key,
    required this.onPressed,
    required this.isDark,
    required this.color,
  });

  final VoidCallback onPressed;
  final bool isDark;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: isDark ? 'Light green theme' : 'Dark green theme',
      onPressed: onPressed,
      icon: AnimatedSwitcher(
        duration: AppMotion.micro,
        switchInCurve: AppMotion.curve,
        switchOutCurve: AppMotion.curve,
        transitionBuilder: (child, animation) {
          return RotationTransition(
            turns: Tween(begin: 0.75, end: 1.0).animate(animation),
            child: FadeTransition(opacity: animation, child: child),
          );
        },
        child: Icon(
          isDark ? Icons.wb_sunny_outlined : Icons.nights_stay_outlined,
          key: ValueKey(isDark),
          color: color,
        ),
      ),
    );
  }
}
