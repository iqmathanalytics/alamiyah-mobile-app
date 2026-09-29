import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/alamiyah_colors.dart';
import '../../core/theme/display_prefs.dart';

/// Session splash: logo parts assemble (crescent, spark, wordmark).
class BrandIntroOverlay extends StatefulWidget {
  const BrandIntroOverlay({super.key, required this.child});

  final Widget child;

  @override
  State<BrandIntroOverlay> createState() => _BrandIntroOverlayState();
}

class _BrandIntroOverlayState extends State<BrandIntroOverlay>
    with TickerProviderStateMixin {
  static var _shownThisSession = false;

  late final AnimationController _assemble;
  late final AnimationController _fade;

  late final Animation<double> _crescentIn;
  late final Animation<double> _cutIn;
  late final Animation<double> _sparkIn;
  late final Animation<double> _wordIn;
  late final Animation<double> _tagIn;

  var _visible = !_shownThisSession;

  /// Mount the real app only as the splash fades — avoids assemble jank.
  var _mountApp = _shownThisSession;

  @override
  void initState() {
    super.initState();
    _assemble = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _fade = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 480),
    );

    _crescentIn = CurvedAnimation(
      parent: _assemble,
      curve: const Interval(0.0, 0.42, curve: Curves.easeOutCubic),
    );
    _cutIn = CurvedAnimation(
      parent: _assemble,
      curve: const Interval(0.18, 0.55, curve: Curves.easeOutCubic),
    );
    _sparkIn = CurvedAnimation(
      parent: _assemble,
      curve: const Interval(0.40, 0.72, curve: Curves.easeOutCubic),
    );
    _wordIn = CurvedAnimation(
      parent: _assemble,
      curve: const Interval(0.55, 0.85, curve: Curves.easeOutCubic),
    );
    _tagIn = CurvedAnimation(
      parent: _assemble,
      curve: const Interval(0.70, 1.0, curve: Curves.easeOutCubic),
    );

    if (_visible) {
      _fade.value = 1;
      // Kick font load early (no underline flash from pending download).
      GoogleFonts.dmSans();
      WidgetsBinding.instance.addPostFrameCallback((_) => _play());
    }
  }

  Future<void> _play() async {
    try {
      await GoogleFonts.pendingFonts();
    } catch (_) {}
    if (!mounted) return;

    final reduce = context.alamiyahDisplay.reduceMotion;
    if (reduce) {
      _assemble.value = 1;
    } else {
      await _assemble.forward();
    }
    if (!mounted) return;

    setState(() => _mountApp = true);
    await WidgetsBinding.instance.endOfFrame;
    if (!mounted) return;

    await _fade.reverse();
    if (!mounted) return;
    setState(() {
      _visible = false;
      _shownThisSession = true;
    });
  }

  @override
  void dispose() {
    _assemble.dispose();
    _fade.dispose();
    super.dispose();
  }

  static TextStyle _wordStyle(Color color) {
    return GoogleFonts.dmSans(
      fontSize: 30,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.6,
      height: 1.1,
      color: color,
      decoration: TextDecoration.none,
      decorationColor: Colors.transparent,
      decorationThickness: 0.01,
    );
  }

  static TextStyle _tagStyle(Color color) {
    return GoogleFonts.dmSans(
      fontSize: 13,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.3,
      height: 1.2,
      color: color,
      decoration: TextDecoration.none,
      decorationColor: Colors.transparent,
      decorationThickness: 0.01,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_visible) return widget.child;

    final colors = context.alamiyahColors;
    final bg = Theme.of(context).scaffoldBackgroundColor;
    final wordStyle = _wordStyle(colors.brandPrimary);
    final tagStyle = _tagStyle(colors.brandSecondary);

    return Stack(
      fit: StackFit.expand,
      children: [
        if (_mountApp) widget.child else ColoredBox(color: bg),
        IgnorePointer(
          child: FadeTransition(
            opacity: _fade,
            child: ColoredBox(
              color: bg,
              child: DefaultTextStyle.merge(
                style: const TextStyle(
                  decoration: TextDecoration.none,
                  decorationColor: Colors.transparent,
                  decorationThickness: 0.01,
                ),
                child: Center(
                  child: AnimatedBuilder(
                    animation: _assemble,
                    builder: (context, _) {
                      final wordT = _wordIn.value.clamp(0.0, 1.0);
                      final tagT = _tagIn.value.clamp(0.0, 1.0);
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          RepaintBoundary(
                            child: SizedBox(
                              width: 88,
                              height: 88,
                              child: CustomPaint(
                                painter: _AssemblingLogoPainter(
                                  color: colors.brandPrimary,
                                  accent: colors.accentGold,
                                  crescentT: _crescentIn.value,
                                  cutT: _cutIn.value,
                                  sparkT: _sparkIn.value,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Opacity(
                            opacity: wordT,
                            child: Transform.translate(
                              offset: Offset(0, 18 * (1 - wordT)),
                              child: Text(
                                AppConstants.appName,
                                style: wordStyle,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Opacity(
                            opacity: tagT,
                            child: Transform.translate(
                              offset: Offset(0, 12 * (1 - tagT)),
                              child: Text(
                                'Dhikr · Dua · Calm',
                                style: tagStyle,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Crescent body, cutaway, and spark arrive from different directions.
class _AssemblingLogoPainter extends CustomPainter {
  _AssemblingLogoPainter({
    required this.color,
    required this.accent,
    required this.crescentT,
    required this.cutT,
    required this.sparkT,
  });

  final Color color;
  final Color accent;
  final double crescentT;
  final double cutT;
  final double sparkT;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width * 0.46;
    final cy = size.height * 0.52;
    final radius = size.width * 0.34;

    final moonCenter = Offset(
      cx - (1 - crescentT) * size.width * 0.55,
      cy + (1 - crescentT) * size.height * 0.08,
    );
    final cutCenter = Offset(
      size.width * 0.62 + (1 - cutT) * size.width * 0.4,
      size.height * 0.40 - (1 - cutT) * size.height * 0.35,
    );

    if (crescentT > 0.02) {
      final moon = Path()
        ..addOval(Rect.fromCircle(center: moonCenter, radius: radius));
      final cut = Path()
        ..addOval(
          Rect.fromCircle(center: cutCenter, radius: size.width * 0.28),
        );
      final crescent = Path.combine(PathOperation.difference, moon, cut);
      canvas.drawPath(
        crescent,
        Paint()
          ..isAntiAlias = true
          ..color = color.withValues(alpha: 0.25 + 0.75 * crescentT)
          ..style = PaintingStyle.fill,
      );
    }

    if (sparkT > 0.01) {
      final sparkY = size.height * 0.22 - (1 - sparkT) * size.height * 0.55;
      final sparkX = size.width * 0.78;
      final settle = Curves.easeOut.transform(sparkT.clamp(0.0, 1.0));
      canvas.drawCircle(
        Offset(sparkX, sparkY),
        2.4 + 2.2 * settle,
        Paint()
          ..isAntiAlias = true
          ..color = accent.withValues(alpha: (0.25 + 0.75 * settle).clamp(0, 1))
          ..style = PaintingStyle.fill,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _AssemblingLogoPainter oldDelegate) =>
      oldDelegate.crescentT != crescentT ||
      oldDelegate.cutT != cutT ||
      oldDelegate.sparkT != sparkT ||
      oldDelegate.color != color ||
      oldDelegate.accent != accent;
}
