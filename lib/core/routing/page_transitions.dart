import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../shared/widgets/swoosh_on_push.dart';
import '../motion/app_motion.dart';

/// Soft transition for pushed screens (detail, admin gate, forms).
CustomTransitionPage<T> fadeSlidePage<T>({
  required LocalKey key,
  required Widget child,
  Duration? duration,
  bool playSwoosh = false,
}) {
  return CustomTransitionPage<T>(
    key: key,
    child: playSwoosh ? SwooshOnPush(child: child) : child,
    transitionDuration: duration ?? AppMotion.screenNow,
    reverseTransitionDuration: duration ?? AppMotion.screenNow,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(parent: animation, curve: AppMotion.curve);
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.03, 0.01),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );
}

/// Instant page — use for bottom-nav / admin shell tab switches (no glitch).
NoTransitionPage<T> noAnimPage<T>({
  required LocalKey key,
  required Widget child,
}) {
  return NoTransitionPage<T>(key: key, child: child);
}
