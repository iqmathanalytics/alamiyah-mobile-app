import 'dart:math' as math;
import 'dart:ui' show ImageFilter, lerpDouble;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/l10n/app_strings.dart';
import '../../core/motion/app_motion.dart';
import '../../core/sound/sound_service.dart';
import '../../core/theme/alamiyah_colors.dart';
import '../../core/theme/display_prefs.dart';
import '../../features/onboarding/onboarding_controller.dart';
import 'guided_tour_controller.dart';
import 'tour_targets.dart';

class _TourStep {
  const _TourStep({
    required this.icon,
    required this.title,
    required this.body,
    required this.resolve,
    this.target,
    required this.shape,
    this.padding = 10,
    this.cardSide = TourCardSide.auto,
    this.fallback = const Offset(0.5, 0.4),
  });

  final IconData icon;
  final String title;
  final String body;
  final Rect? Function() resolve;
  final GlobalKey? target;
  final TourFocusShape shape;
  final double padding;
  final TourCardSide cardSide;
  final Offset fallback;
}

final _steps = <_TourStep>[
  _TourStep(
    icon: Icons.spa_outlined,
    title: 'Your calm feed',
    body: 'Featured duas and gentle reminders live right here.',
    resolve: () => TourTargets.rectOf(TourTargets.feed),
    target: TourTargets.feed,
    shape: TourFocusShape.roundedRect,
    padding: 10,
    cardSide: TourCardSide.below,
    fallback: const Offset(0.5, 0.22),
  ),
  _TourStep(
    icon: Icons.filter_vintage_outlined,
    title: 'Browse by mood',
    body: 'Open Qur’an, invocations, salawat, and the rest of the library.',
    resolve: () => TourTargets.rectOf(TourTargets.categories),
    target: TourTargets.categories,
    shape: TourFocusShape.roundedRect,
    padding: 8,
    cardSide: TourCardSide.below,
    fallback: const Offset(0.5, 0.48),
  ),
  _TourStep(
    icon: Icons.calendar_month_outlined,
    title: 'Hijri & prayer',
    body: 'Calendar holds Hijri days, prayer times, and Ramadan tools.',
    resolve: () => TourTargets.navDestinationRect(2),
    shape: TourFocusShape.circle,
    padding: 12,
    cardSide: TourCardSide.above,
    fallback: const Offset(0.5, 0.92),
  ),
  _TourStep(
    icon: Icons.videocam_outlined,
    title: 'Live moments',
    body: 'Curated gatherings and live reminders from your admins.',
    resolve: () => TourTargets.navDestinationRect(3),
    shape: TourFocusShape.circle,
    padding: 12,
    cardSide: TourCardSide.above,
    fallback: const Offset(0.7, 0.92),
  ),
  _TourStep(
    icon: Icons.palette_outlined,
    title: 'Make it yours',
    body: 'Theme, Arabic type, text size, and soft sounds.',
    resolve: () => TourTargets.rectOf(TourTargets.display),
    target: TourTargets.display,
    shape: TourFocusShape.circle,
    padding: 14,
    cardSide: TourCardSide.below,
    fallback: const Offset(0.88, 0.08),
  ),
];

/// First-launch coachmarks over the user shell. Skippable, animated.
class GuidedTourHost extends ConsumerStatefulWidget {
  const GuidedTourHost({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<GuidedTourHost> createState() => _GuidedTourHostState();
}

class _GuidedTourHostState extends ConsumerState<GuidedTourHost>
    with TickerProviderStateMixin {
  static const _moveDuration = Duration(milliseconds: 420);

  var _step = 0;
  var _active = false;
  var _celebrating = false;
  var _cancelled = false;
  var _busy = false;

  late final AnimationController _overlay;
  late final AnimationController _pulse;
  late final AnimationController _move;
  late final AnimationController _celebrate;
  late final AnimationController _celebrateFade;

  late final Animation<double> _overlayFade;

  Rect _fromRect = Rect.zero;
  Rect _toRect = Rect.zero;
  TourFocusShape _fromShape = TourFocusShape.roundedRect;
  TourFocusShape _toShape = TourFocusShape.roundedRect;

  @override
  void initState() {
    super.initState();
    _overlay = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 480),
    );
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
    _move = AnimationController(
      vsync: this,
      duration: _moveDuration,
    )..value = 1;
    _celebrate = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _celebrateFade = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    );

    _overlayFade = CurvedAnimation(parent: _overlay, curve: Curves.easeOutCubic);

    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeStart());
  }

  Rect _inHost(Rect global) {
    final box = context.findRenderObject();
    if (box is! RenderBox || !box.hasSize || !box.attached) return global;
    final origin = box.localToGlobal(Offset.zero);
    return global.shift(Offset(-origin.dx, -origin.dy));
  }

  Rect _measure(int index, Size size) {
    final step = _steps[index];
    final measured = step.resolve();
    if (measured != null && measured.width > 4 && measured.height > 4) {
      return _inHost(measured).inflate(step.padding);
    }
    final c = Offset(
      size.width * step.fallback.dx,
      size.height * step.fallback.dy,
    );
    final r = step.shape == TourFocusShape.circle ? 36.0 : 56.0;
    return Rect.fromCenter(
      center: c,
      width: r * 2.2,
      height: step.shape == TourFocusShape.circle ? r * 2.2 : r * 1.4,
    );
  }

  Future<void> _revealTarget(int index) async {
    final targetContext = _steps[index].target?.currentContext;
    if (targetContext == null || !targetContext.mounted) return;
    await Scrollable.ensureVisible(
      targetContext,
      alignment: 0.32,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
    );
    await WidgetsBinding.instance.endOfFrame;
  }

  Future<void> _maybeStart() async {
    final onboarded = ref.read(onboardingCompleteProvider);
    final tourDone = ref.read(guidedTourCompleteProvider);
    if (!onboarded || tourDone) return;

    await Future<void>.delayed(const Duration(milliseconds: 2400));
    if (!mounted || _cancelled) return;
    if (ref.read(guidedTourCompleteProvider)) return;

    await WidgetsBinding.instance.endOfFrame;
    if (!mounted || _cancelled) return;

    await _revealTarget(0);
    if (!mounted || _cancelled) return;

    final size = MediaQuery.sizeOf(context);
    final first = _measure(0, size);
    setState(() {
      _active = true;
      _fromRect = first;
      _toRect = first;
      _fromShape = _steps.first.shape;
      _toShape = _steps.first.shape;
    });
    _move.value = 1;
    await _overlay.forward(from: 0);
    SoundService.instance?.settle();
  }

  Future<void> _goNext() async {
    if (_busy) return;
    _busy = true;
    HapticFeedback.selectionClick();
    await SoundService.instance?.tick();
    if (!mounted) {
      _busy = false;
      return;
    }

    if (_step >= _steps.length - 1) {
      await _finishWithCelebration();
      _busy = false;
      return;
    }

    final size = MediaQuery.sizeOf(context);
    final next = _step + 1;
    await _revealTarget(next);
    if (!mounted) {
      _busy = false;
      return;
    }
    final current = _focusRect(size);
    final nextRect = _measure(next, size);

    setState(() {
      _fromRect = current;
      _toRect = nextRect;
      _fromShape = _toShape;
      _toShape = _steps[next].shape;
      _step = next;
    });

    await _move.forward(from: 0);
    if (mounted) {
      // Lock end rect to live layout so we don't snap later.
      final live = _measure(_step, size);
      setState(() {
        _fromRect = live;
        _toRect = live;
      });
      _move.value = 1;
    }
    _busy = false;
  }

  Future<void> _finishWithCelebration() async {
    HapticFeedback.mediumImpact();
    await SoundService.instance?.confirm();
    if (!mounted) return;

    // Softly dismiss coachmarks, then reveal celebration.
    await _overlay.reverse();
    if (!mounted) return;

    setState(() {
      _celebrating = true;
      _active = false;
    });
    _celebrateFade.value = 0;
    _celebrate.value = 0;
    await Future.wait([
      _celebrateFade.forward(from: 0),
      _celebrate.forward(from: 0),
    ]);
    if (!mounted) return;
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    await _celebrateFade.reverse();
    await ref.read(guidedTourCompleteProvider.notifier).complete();
    if (!mounted) return;
    setState(() => _celebrating = false);
  }

  Future<void> _skip() async {
    if (_busy) return;
    _busy = true;
    HapticFeedback.lightImpact();
    await _overlay.reverse();
    await ref.read(guidedTourCompleteProvider.notifier).complete();
    if (!mounted) return;
    setState(() {
      _active = false;
      _celebrating = false;
    });
    _busy = false;
  }

  @override
  void dispose() {
    _cancelled = true;
    _overlay.dispose();
    _pulse.dispose();
    _move.dispose();
    _celebrate.dispose();
    _celebrateFade.dispose();
    super.dispose();
  }

  Rect _focusRect(Size size) {
    if (_move.isAnimating) {
      final t = Curves.easeInOutCubic.transform(_move.value);
      return Rect.lerp(_fromRect, _toRect, t)!;
    }
    return _measure(_step, size);
  }

  TourFocusShape get _focusShape {
    // Keep destination shape once morph is mostly done to avoid mid-glitch flips.
    return _move.value < 0.45 ? _fromShape : _toShape;
  }

  bool _placeCardAbove(Size size, Rect focus) {
    final step = _steps[_step];
    if (step.cardSide == TourCardSide.above) return true;
    if (step.cardSide == TourCardSide.below) return false;
    return focus.center.dy > size.height * 0.52;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        widget.child,
        if (_active) _buildTour(context),
        if (_celebrating) _buildCelebration(context),
      ],
    );
  }

  Widget _buildTour(BuildContext context) {
    final colors = context.alamiyahColors;
    final size = MediaQuery.sizeOf(context);
    final step = _steps[_step];
    final reduce = context.alamiyahDisplay.reduceMotion;
    final isLast = _step == _steps.length - 1;

    return AnimatedBuilder(
      animation: Listenable.merge([_overlay, _pulse, _move]),
      builder: (context, _) {
        final focus = _focusRect(size);
        final shape = _focusShape;
        final pulse = reduce ? 1.0 : 0.98 + 0.02 * _pulse.value;
        final above = _placeCardAbove(size, focus);
        final safeTop = MediaQuery.paddingOf(context).top;
        final safeBottom = MediaQuery.paddingOf(context).bottom;
        // Always drive `top` so AnimatedPositioned never swaps null top/bottom.
        const cardReserve = 128.0;
        final desiredTop = above
            ? focus.top - cardReserve - 10
            : focus.bottom + 10;
        final cardTop = desiredTop.clamp(
          safeTop + 8,
          size.height - safeBottom - cardReserve - 8,
        );

        return IgnorePointer(
          ignoring: _overlay.value < 0.05,
          child: Opacity(
            opacity: _overlayFade.value,
            child: Material(
              type: MaterialType.transparency,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CustomPaint(
                    painter: _SpotlightPainter(
                      rect: focus,
                      shape: shape,
                      progress: 1,
                      pulse: pulse,
                      dimColor: colors.brandPrimary.withValues(alpha: 0.52),
                      rimColor: colors.accentGold,
                    ),
                    child: const SizedBox.expand(),
                  ),

                  if (shape == TourFocusShape.circle)
                    Positioned(
                      left: focus.center.dx - focus.shortestSide / 2 * pulse,
                      top: focus.center.dy - focus.shortestSide / 2 * pulse,
                      child: Container(
                        width: focus.shortestSide * pulse,
                        height: focus.shortestSide * pulse,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: colors.accentGold.withValues(alpha: 0.9),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: colors.accentGold.withValues(alpha: 0.28),
                              blurRadius: 14,
                            ),
                          ],
                        ),
                      ),
                    ),

                  AnimatedPositioned(
                    duration: reduce ? Duration.zero : _moveDuration,
                    curve: Curves.easeInOutCubic,
                    left: 28,
                    right: 28,
                    top: cardTop,
                    child: Align(
                      alignment: Alignment.center,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 300),
                        child: AnimatedSwitcher(
                          duration: reduce
                              ? Duration.zero
                              : const Duration(milliseconds: 280),
                          switchInCurve: Curves.easeOutCubic,
                          switchOutCurve: Curves.easeInCubic,
                          transitionBuilder: (child, anim) {
                            final offset = Tween<Offset>(
                              begin: const Offset(0.04, 0.08),
                              end: Offset.zero,
                            ).animate(anim);
                            return FadeTransition(
                              opacity: anim,
                              child: SlideTransition(
                                position: offset,
                                child: child,
                              ),
                            );
                          },
                          child: _TourCard(
                            key: ValueKey(_step),
                            step: step,
                            index: _step,
                            total: _steps.length,
                            onNext: _goNext,
                            onSkip: _skip,
                            isLast: isLast,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCelebration(BuildContext context) {
    final colors = context.alamiyahColors;
    final reduce = context.alamiyahDisplay.reduceMotion;

    return AnimatedBuilder(
      animation: Listenable.merge([_celebrate, _celebrateFade]),
      builder: (context, _) {
        final t = _celebrate.value;
        final contentT = Curves.easeOutCubic.transform(
          ((t - 0.12) / 0.55).clamp(0.0, 1.0),
        );

        return Opacity(
          opacity: _celebrateFade.value,
          child: Material(
            type: MaterialType.transparency,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Blur + tint so celebration reads clearly over the app.
                BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: reduce ? 0 : 16,
                    sigmaY: reduce ? 0 : 16,
                  ),
                  child: ColoredBox(
                    color: colors.brandPrimary.withValues(alpha: 0.58),
                  ),
                ),
                CustomPaint(
                  painter: _BurstPainter(
                    progress: t,
                    gold: colors.accentGold,
                    green: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
                Center(
                  child: Opacity(
                    opacity: contentT,
                    child: Transform.scale(
                      scale: 0.92 + 0.08 * contentT,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.auto_awesome,
                              size: 40,
                              color: colors.accentGold,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withValues(alpha: 0.35),
                                  blurRadius: 16,
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),
                            Text(
                              'You are ready',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.dmSans(
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.4,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withValues(alpha: 0.45),
                                    blurRadius: 18,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'May your days be soft with dhikr.\nBegin whenever you like.',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.dmSans(
                                fontSize: 15,
                                height: 1.45,
                                color: Colors.white.withValues(alpha: 0.92),
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withValues(alpha: 0.4),
                                    blurRadius: 14,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TourCard extends StatelessWidget {
  const _TourCard({
    super.key,
    required this.step,
    required this.index,
    required this.total,
    required this.onNext,
    required this.onSkip,
    required this.isLast,
  });

  final _TourStep step;
  final int index;
  final int total;
  final VoidCallback onNext;
  final VoidCallback onSkip;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final colors = context.alamiyahColors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colors.softShadow,
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: colors.accentGold.withValues(alpha: 0.22),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: colors.chipBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  step.icon,
                  size: 18,
                  color: colors.brandPrimary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.s.call('tour${index + 1}Title'),
                      style: GoogleFonts.dmSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                        color: colors.brandPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      context.s.call('tour${index + 1}Body'),
                      style: GoogleFonts.dmSans(
                        fontSize: 12.5,
                        height: 1.35,
                        color: colors.brandSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: onSkip,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.fromLTRB(6, 0, 0, 0),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Skip',
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: colors.brandSecondary.withValues(alpha: 0.75),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              for (var i = 0; i < total; i++)
                AnimatedContainer(
                  duration: AppMotion.of(context, AppMotion.micro),
                  curve: AppMotion.curve,
                  margin: const EdgeInsets.only(right: 4),
                  width: i == index ? 14 : 5,
                  height: 5,
                  decoration: BoxDecoration(
                    color: i == index
                        ? colors.brandPrimary
                        : i < index
                            ? colors.accentGold.withValues(alpha: 0.75)
                            : colors.brandSecondary.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              const Spacer(),
              FilledButton(
                onPressed: onNext,
                style: FilledButton.styleFrom(
                  minimumSize: const Size(0, 32),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 0,
                  ),
                  visualDensity: VisualDensity.compact,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  isLast ? 'Begin' : 'Next',
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SpotlightPainter extends CustomPainter {
  _SpotlightPainter({
    required this.rect,
    required this.shape,
    required this.progress,
    required this.pulse,
    required this.dimColor,
    required this.rimColor,
  });

  final Rect rect;
  final TourFocusShape shape;
  final double progress;
  final double pulse;
  final Color dimColor;
  final Color rimColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    final focus = Rect.fromCenter(
      center: rect.center,
      width: rect.width * pulse,
      height: rect.height * pulse,
    );

    final overlay = Path()..addRect(Offset.zero & size);
    late final Path hole;
    if (shape == TourFocusShape.circle) {
      final r = focus.shortestSide / 2;
      hole = Path()..addOval(Rect.fromCircle(center: focus.center, radius: r));
    } else {
      hole = Path()
        ..addRRect(
          RRect.fromRectAndRadius(focus, const Radius.circular(18)),
        );
    }

    final cut = Path.combine(PathOperation.difference, overlay, hole);
    canvas.drawPath(
      cut,
      Paint()..color = dimColor.withValues(alpha: 0.58 * progress),
    );

    final rim = Paint()
      ..color = rimColor.withValues(alpha: 0.55 * progress)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    if (shape == TourFocusShape.circle) {
      canvas.drawCircle(focus.center, focus.shortestSide / 2, rim);
    } else {
      canvas.drawRRect(
        RRect.fromRectAndRadius(focus, const Radius.circular(18)),
        rim,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SpotlightPainter oldDelegate) =>
      oldDelegate.rect != rect ||
      oldDelegate.shape != shape ||
      oldDelegate.progress != progress ||
      oldDelegate.pulse != pulse;
}

class _BurstPainter extends CustomPainter {
  _BurstPainter({
    required this.progress,
    required this.gold,
    required this.green,
  });

  final double progress;
  final Color gold;
  final Color green;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height * 0.38);
    final t = progress.clamp(0.0, 1.0);

    for (var i = 0; i < 20; i++) {
      final angle = i * (math.pi * 2 / 20) + t * 0.35;
      final dist = lerpDouble(
        10,
        size.shortestSide * 0.4,
        Curves.easeOut.transform(t),
      )!;
      final p = Offset(
        c.dx + math.cos(angle) * dist,
        c.dy + math.sin(angle) * dist,
      );
      final alpha = (1 - t * 0.45).clamp(0.0, 1.0);
      canvas.drawCircle(
        p,
        2.4 + (i.isEven ? 1.6 : 0),
        Paint()
          ..color = (i.isEven ? gold : green).withValues(alpha: 0.85 * alpha),
      );
    }

    canvas.drawCircle(
      c,
      lerpDouble(8, size.shortestSide * 0.32, Curves.easeOutCubic.transform(t))!,
      Paint()
        ..color = gold.withValues(alpha: 0.4 * (1 - t))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );
  }

  @override
  bool shouldRepaint(covariant _BurstPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
