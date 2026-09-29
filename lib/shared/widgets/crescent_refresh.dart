import 'package:flutter/cupertino.dart';

import '../../core/theme/alamiyah_colors.dart';

class CrescentRefreshControl extends StatelessWidget {
  const CrescentRefreshControl({super.key, required this.onRefresh});

  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final colors = context.alamiyahColors;
    return CupertinoSliverRefreshControl(
      refreshTriggerPullDistance: 72,
      refreshIndicatorExtent: 56,
      onRefresh: onRefresh,
      builder: (
        context,
        refreshState,
        pulledExtent,
        refreshTriggerPullDistance,
        refreshIndicatorExtent,
      ) {
        final t = (pulledExtent / refreshTriggerPullDistance).clamp(0.0, 1.0);
        return SizedBox(
          height: pulledExtent,
          child: Center(
            child: Opacity(
              opacity: t,
              child: Transform.rotate(
                angle: (t - 0.5) * 0.5,
                child: CustomPaint(
                  size: const Size(30, 30),
                  painter: CrescentPainter(
                    color: colors.brandPrimary,
                    accent: colors.accentGold,
                    progress: t,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Original crescent + lantern spark — not copied from another app.
class CrescentPainter extends CustomPainter {
  CrescentPainter({
    required this.color,
    required this.accent,
    required this.progress,
  });

  final Color color;
  final Color accent;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final moon = Path()
      ..addOval(Rect.fromCircle(
        center: Offset(size.width * 0.46, size.height * 0.52),
        radius: size.width * 0.34,
      ));
    final cut = Path()
      ..addOval(Rect.fromCircle(
        center: Offset(size.width * 0.62, size.height * 0.40),
        radius: size.width * 0.28,
      ));
    final crescent = Path.combine(PathOperation.difference, moon, cut);
    canvas.drawPath(crescent, Paint()..color = color);

    final spark = Paint()
      ..color = accent.withValues(alpha: 0.35 + 0.65 * progress)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(size.width * 0.78, size.height * 0.22),
      2.2 + 1.4 * progress,
      spark,
    );
  }

  @override
  bool shouldRepaint(CrescentPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}
