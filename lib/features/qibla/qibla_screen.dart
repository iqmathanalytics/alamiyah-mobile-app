import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../../core/l10n/app_strings.dart';
import '../../core/theme/alamiyah_colors.dart';
import '../../data/services/device_location.dart';
import '../../data/services/prayer_times_service.dart';
import 'device_heading.dart';

class QiblaScreen extends ConsumerStatefulWidget {
  const QiblaScreen({super.key});

  @override
  ConsumerState<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends ConsumerState<QiblaScreen> {
  StreamSubscription<AccelerometerEvent>? _accelSub;
  StreamSubscription<MagnetometerEvent>? _magSub;
  StreamSubscription<GyroscopeEvent>? _gyroSub;
  AccelerometerEvent? _accel;
  MagnetometerEvent? _mag;
  GyroscopeEvent? _gyro;
  final _tracker = HeadingTracker();
  double? _heading;
  var _locating = false;

  @override
  void initState() {
    super.initState();
    const period = Duration(milliseconds: 20);
    _accelSub = accelerometerEventStream(samplingPeriod: period).listen((event) {
      _accel = event;
      _updateHeading();
    });
    _magSub = magnetometerEventStream(samplingPeriod: period).listen((event) {
      _mag = event;
      _updateHeading();
    });
    _gyroSub = gyroscopeEventStream(samplingPeriod: period).listen((event) {
      _gyro = event;
      _updateHeading();
    });
  }

  DateTime _lastPaint = DateTime.fromMillisecondsSinceEpoch(0);

  void _updateHeading() {
    final accel = _accel;
    final mag = _mag;
    if (accel == null || mag == null || !mounted) return;
    final gyro = _gyro;
    final now = DateTime.now();
    final location = ref.read(prayerLocationProvider);
    final next = _tracker.update(
      ax: accel.x,
      ay: accel.y,
      az: accel.z,
      mx: mag.x,
      my: mag.y,
      mz: mag.z,
      gx: gyro?.x ?? 0,
      gy: gyro?.y ?? 0,
      gz: gyro?.z ?? 0,
      declination: magneticDeclination(location.latitude, location.longitude),
      now: now,
    );
    if (next == null) return;
    final current = _heading;
    if (current != null &&
        (now.difference(_lastPaint) < const Duration(milliseconds: 40) ||
            headingDelta(current, next).abs() < 0.6)) {
      return;
    }
    _lastPaint = now;
    setState(() => _heading = next);
  }

  @override
  void dispose() {
    _accelSub?.cancel();
    _magSub?.cancel();
    _gyroSub?.cancel();
    super.dispose();
  }

  Future<void> _useGps() async {
    setState(() => _locating = true);
    try {
      final fix = await readCurrentCoordinates();
      await ref.read(prayerLocationProvider.notifier).setGps(
            latitude: fix.latitude,
            longitude: fix.longitude,
          );
    } on DeviceLocationException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not read location. Try again, or choose a city.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.alamiyahColors;
    final strings = context.s;
    final prayers = ref.watch(todayPrayersProvider);
    final location = ref.watch(prayerLocationProvider);
    final heading = _heading;
    final qibla = prayers.qiblaDegrees;
    final offset = heading == null ? 0.0 : headingDelta(heading, qibla);
    final aligned = heading != null && offset.abs() <= 5;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: colors.brandPrimary,
        title: Text(
          strings.qibla,
          style: GoogleFonts.dmSans(
            fontWeight: FontWeight.w700,
            color: colors.brandPrimary,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        children: [
          Text(
            location.label,
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(
              color: colors.brandSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 18),
          Center(
            child: _QiblaDial(
              colors: colors,
              heading: heading,
              qibla: qibla,
              aligned: aligned,
              youFace: strings.youFace,
              kaabaLabel: strings.kaaba,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            heading == null
                ? strings.holdFlat
                : aligned
                    ? strings.facingKaaba
                    : strings.needle,
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(
              color: aligned ? colors.accentGold : colors.brandSecondary,
              fontWeight: aligned ? FontWeight.w700 : FontWeight.w500,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            decoration: BoxDecoration(
              color: colors.cardBackground,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: colors.brandPrimary.withValues(alpha: 0.08),
              ),
            ),
            child: Column(
              children: [
                _Stat(
                  label: strings.bearing,
                  value: '${qibla.round()}°',
                  hint: strings.bearingHint,
                ),
                const SizedBox(height: 14),
                _Stat(
                  label: strings.distance,
                  value: '${prayers.makkahKm.round()} km',
                  hint: strings.distanceHint,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _locating ? null : _useGps,
            child: Text(_locating ? strings.finding : strings.useLocation),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.label,
    required this.value,
    required this.hint,
  });

  final String label;
  final String value;
  final String hint;

  @override
  Widget build(BuildContext context) {
    final colors = context.alamiyahColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: GoogleFonts.dmSans(
                fontSize: 12,
                color: colors.brandSecondary,
              ),
            ),
            const Spacer(),
            Text(
              value,
              style: GoogleFonts.dmSans(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: colors.brandPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          hint,
          style: GoogleFonts.dmSans(
            fontSize: 13,
            height: 1.4,
            color: colors.brandSecondary,
          ),
        ),
      ],
    );
  }
}

class _QiblaDial extends StatelessWidget {
  const _QiblaDial({
    required this.colors,
    required this.heading,
    required this.qibla,
    required this.aligned,
    required this.youFace,
    required this.kaabaLabel,
  });

  final AlamiyahColors colors;
  final double? heading;
  final double qibla;
  final bool aligned;
  final String youFace;
  final String kaabaLabel;

  @override
  Widget build(BuildContext context) {
    final degree = heading == null ? '—' : '${heading!.round()}°';
    return SizedBox(
      width: 300,
      height: 300,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.cardBackground,
              border: Border.all(
                color: aligned
                    ? colors.accentGold
                    : colors.brandPrimary.withValues(alpha: 0.16),
                width: aligned ? 2.5 : 1.2,
              ),
            ),
          ),
          CustomPaint(
            size: const Size(280, 280),
            painter: _WorldDialPainter(
              colors: colors,
              heading: heading ?? 0,
              qibla: qibla,
              kaabaLabel: kaabaLabel,
              aligned: aligned,
            ),
          ),
          CustomPaint(
            size: const Size(280, 280),
            painter: _YouArrowPainter(
              color: aligned ? colors.accentGold : colors.brandPrimary,
            ),
          ),
          Container(
            width: 86,
            height: 86,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.surfaceElevated,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  degree,
                  style: GoogleFonts.dmSans(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    height: 1,
                    color: colors.brandPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  youFace,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.dmSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: colors.brandSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// North and the Kaaba, rotated so they stay fixed in the real world.
class _WorldDialPainter extends CustomPainter {
  _WorldDialPainter({
    required this.colors,
    required this.heading,
    required this.qibla,
    required this.kaabaLabel,
    required this.aligned,
  });

  final AlamiyahColors colors;
  final double heading;
  final double qibla;
  final String kaabaLabel;
  final bool aligned;

  Offset _at(double degrees, double radius) {
    final rad = degrees * math.pi / 180;
    return Offset(math.sin(rad), -math.cos(rad)) * radius;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-heading * math.pi / 180);

    final tick = Paint()
      ..color = colors.brandSecondary.withValues(alpha: 0.4)
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 36; i++) {
      final major = i % 9 == 0;
      canvas.drawLine(
        _at(i * 10, radius - (major ? 14 : 8)),
        _at(i * 10, radius),
        tick,
      );
    }

    final north = TextPainter(
      text: TextSpan(
        text: 'N',
        style: GoogleFonts.dmSans(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: colors.accentGold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final northAt = _at(0, radius - 28);
    north.paint(canvas, northAt - Offset(north.width / 2, north.height / 2));

    final kaabaAt = _at(qibla, radius - 46);
    canvas.save();
    canvas.translate(kaabaAt.dx, kaabaAt.dy);
    canvas.rotate(heading * math.pi / 180);
    final body = RRect.fromRectAndRadius(
      const Rect.fromLTWH(-11, -13, 22, 26),
      const Radius.circular(3),
    );
    canvas.drawRRect(
      body,
      Paint()..color = const Color(0xFF1A332C),
    );
    canvas.drawRRect(
      body,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = aligned ? 2 : 1.2
        ..color = colors.accentGold,
    );
    canvas.drawLine(
      const Offset(-11, -4),
      const Offset(11, -4),
      Paint()
        ..color = colors.accentGold
        ..strokeWidth = 2,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-3, 2, 6, 8),
        const Radius.circular(1),
      ),
      Paint()..color = colors.accentGold,
    );
    final rtl = RegExp(r'[\u0600-\u06FF]').hasMatch(kaabaLabel);
    final label = TextPainter(
      text: TextSpan(
        text: kaabaLabel,
        style: GoogleFonts.dmSans(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: colors.accentGold,
        ),
      ),
      textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
    )..layout();
    label.paint(canvas, Offset(-label.width / 2, 16));
    canvas.restore();
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _WorldDialPainter oldDelegate) {
    return oldDelegate.heading != heading ||
        oldDelegate.qibla != qibla ||
        oldDelegate.aligned != aligned ||
        oldDelegate.kaabaLabel != kaabaLabel ||
        oldDelegate.colors != colors;
  }
}

/// Fixed to the top of the phone: the way you are facing.
class _YouArrowPainter extends CustomPainter {
  _YouArrowPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final tip = center + const Offset(0, -92);
    canvas.drawLine(
      center + const Offset(0, -36),
      tip + const Offset(0, 14),
      Paint()
        ..color = color
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawPath(
      Path()
        ..moveTo(tip.dx, tip.dy)
        ..lineTo(tip.dx - 8, tip.dy + 16)
        ..lineTo(tip.dx + 8, tip.dy + 16)
        ..close(),
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(covariant _YouArrowPainter oldDelegate) =>
      oldDelegate.color != color;
}

