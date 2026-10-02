import 'dart:math' as math;

/// Direction the top of the phone points, clockwise from magnetic north.
///
/// This is Android's compass azimuth for the phone's top edge, which is the
/// same edge as the gold arrow. Hold the phone fairly flat.
double? headingFromSensors({
  required double ax,
  required double ay,
  required double az,
  required double mx,
  required double my,
  required double mz,
}) {
  final normsqA = ax * ax + ay * ay + az * az;
  if (normsqA < 0.96) return null;

  var hx = my * az - mz * ay;
  var hy = mz * ax - mx * az;
  var hz = mx * ay - my * ax;
  final normH = math.sqrt(hx * hx + hy * hy + hz * hz);
  if (normH < 0.1) return null;
  final invH = 1 / normH;
  hx *= invH;
  hy *= invH;
  hz *= invH;

  final invA = 1 / math.sqrt(normsqA);
  final nax = ax * invA;
  final naz = az * invA;
  final ny = naz * hx - nax * hz;

  final east = hy;
  final north = ny;
  if (east * east + north * north < 0.08) return null;

  var degrees = math.atan2(east, north) * 180 / math.pi;
  if (degrees < 0) degrees += 360;
  return degrees;
}

/// Shortest signed difference, in degrees, from [from] to [to].
double headingDelta(double from, double to) {
  var delta = (to - from) % 360;
  if (delta > 180) delta -= 360;
  if (delta < -180) delta += 360;
  return delta;
}

double _wrap360(double degrees) {
  var value = degrees % 360;
  if (value < 0) value += 360;
  return value;
}

/// Degrees east of true north where a compass needle points.
///
/// The needle follows the 2025 World Magnetic Model geomagnetic pole
/// (80.85°N, 72.76°W). The qibla bearing is measured from true north.
double magneticDeclination(double latitude, double longitude) {
  const poleLat = 80.85 * math.pi / 180;
  const poleLng = -72.76 * math.pi / 180;
  final lat = latitude * math.pi / 180;
  final lng = longitude * math.pi / 180;
  final y = math.sin(poleLng - lng);
  final x = math.cos(lat) * math.tan(poleLat) -
      math.sin(lat) * math.cos(poleLng - lng);
  return math.atan2(y, x) * 180 / math.pi;
}

class _Vec3 {
  double x = 0;
  double y = 0;
  double z = 0;

  void set(double sx, double sy, double sz) {
    x = sx;
    y = sy;
    z = sz;
  }

  void follow(double sx, double sy, double sz, double alpha) {
    x += alpha * (sx - x);
    y += alpha * (sy - y);
    z += alpha * (sz - z);
  }

  double get length => math.sqrt(x * x + y * y + z * z);
}

/// Smooth true heading, clockwise from true north.
///
/// The gyroscope carries a turn one-for-one, so the dial moves with the phone
/// and does not copy magnetometer noise. The magnetometer is only allowed to
/// pull the heading when its error keeps the same sign for a while, which is
/// drift, not a twitch.
class HeadingTracker {
  final _accel = _Vec3();
  final _mag = _Vec3();
  var _ready = false;
  double? _heading;
  double _error = 0;
  DateTime? _last;

  double? update({
    required double ax,
    required double ay,
    required double az,
    required double mx,
    required double my,
    required double mz,
    double gx = 0,
    double gy = 0,
    double gz = 0,
    required double declination,
    DateTime? now,
  }) {
    final time = now ?? DateTime.now();
    var dt = 0.0;
    final last = _last;
    if (last != null) {
      dt = time.difference(last).inMicroseconds / 1000000;
      if (dt < 0 || dt > 0.25) dt = 0;
    }
    _last = time;

    final magNorm = math.sqrt(mx * mx + my * my + mz * mz);
    final magTrustworthy = magNorm >= 8 && magNorm <= 100;

    if (!_ready) {
      _accel.set(ax, ay, az);
      if (magTrustworthy) _mag.set(mx, my, mz);
      _ready = true;
    } else if (dt > 0) {
      _accel.follow(ax, ay, az, 1 - math.exp(-dt / 0.5));
      if (magTrustworthy) {
        _mag.follow(mx, my, mz, 1 - math.exp(-dt / 0.35));
      }
    }

    final magnetic = _mag.length < 1
        ? null
        : headingFromSensors(
            ax: _accel.x,
            ay: _accel.y,
            az: _accel.z,
            mx: _mag.x,
            my: _mag.y,
            mz: _mag.z,
          );

    if (_heading == null) {
      _heading = magnetic;
    } else if (dt > 0) {
      final gravity = _accel.length;
      var yaw = 0.0;
      if (gravity > 4) {
        // Positive gyro about the upward axis is counter-clockwise when
        // looking at the screen, so it decreases the clockwise heading.
        yaw = (gx * _accel.x + gy * _accel.y + gz * _accel.z) / gravity;
        if (yaw.abs() > 8) yaw = yaw.sign * 8;
        _heading = _wrap360(_heading! - yaw * dt * 180 / math.pi);
      }

      if (magnetic != null && yaw.abs() < 0.08) {
        final error = headingDelta(_heading!, magnetic);
        final sameDirection = error * _error > 0;
        _error = error;
        if (sameDirection && error.abs() > 2.5) {
          final step = (error * dt / 1.5).clamp(-18 * dt, 18 * dt);
          _heading = _wrap360(_heading! + step);
        }
      }
    }

    final heading = _heading;
    if (heading == null) return null;
    return _wrap360(heading + declination);
  }
}
