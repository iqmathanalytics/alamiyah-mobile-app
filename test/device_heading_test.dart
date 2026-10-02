import 'dart:math' as math;

import 'package:alamiyah/features/library/library_catalog.dart';
import 'package:alamiyah/features/library/surah_catalog.dart';
import 'package:alamiyah/data/services/prayer_times_service.dart';
import 'package:alamiyah/features/qibla/device_heading.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('flat phone with its top toward north reads about 0', () {
    final heading = headingFromSensors(
      ax: 0,
      ay: 0,
      az: 9.8,
      mx: 0,
      my: 40,
      mz: 0,
    );
    expect(heading, isNotNull);
    expect(heading!, closeTo(0, 1));
  });

  test('flat phone with its top toward east reads about 90', () {
    final heading = headingFromSensors(
      ax: 0,
      ay: 0,
      az: 9.8,
      mx: -40,
      my: 0,
      mz: 0,
    );
    expect(heading, isNotNull);
    expect(heading!, closeTo(90, 1));
  });

  test('qibla bearing points at Makkah', () {
    expect(qiblaBearing(10, 39.8262), closeTo(0, 1));
    expect(qiblaBearing(30, 39.8262), closeTo(180, 1));
    expect(qiblaBearing(51.5074, -0.1278), closeTo(119, 1));
    expect(qiblaBearing(28.6139, 77.2090), closeTo(266.6, 1));
  });

  test('declination is zero on the geomagnetic meridian', () {
    final declination = magneticDeclination(20, -72.76);
    expect(declination.abs(), lessThan(0.2));
  });

  test('a modest tilt still reads the top of the phone', () {
    for (final pitch in [0.0, 30.0, 50.0]) {
      final p = pitch * math.pi / 180;
      final heading = headingFromSensors(
        ax: 0,
        ay: 9.8 * math.sin(p),
        az: 9.8 * math.cos(p),
        mx: 0,
        my: 30 * math.cos(p) + -25 * math.sin(p),
        mz: -30 * math.sin(p) + -25 * math.cos(p),
      );
      expect(heading, isNotNull, reason: 'pitch $pitch');
      expect(heading!, closeTo(0, 8), reason: 'pitch $pitch');
    }
  });

  test('magnetometer noise does not swing the heading', () {
    final tracker = HeadingTracker();
    final start = DateTime(2026);
    double? heading;
    for (var i = 0; i < 20; i++) {
      heading = tracker.update(
        ax: 0,
        ay: 0,
        az: 9.8,
        mx: 0,
        my: 40,
        mz: 0,
        declination: 0,
        now: start.add(Duration(milliseconds: 20 * i)),
      );
    }
    expect(heading, closeTo(0, 1));

    for (var i = 0; i < 40; i++) {
      heading = tracker.update(
        ax: 0,
        ay: 0.4,
        az: 9.8,
        mx: (i.isEven ? 3 : -3).toDouble(),
        my: 40,
        mz: 0,
        declination: 0,
        now: start.add(Duration(milliseconds: 400 + 20 * i)),
      );
    }
    expect(heading!.abs() < 180 ? heading : heading! - 360, closeTo(0, 3));
  });

  test('a clockwise turn moves the heading by the same amount', () {
    final tracker = HeadingTracker();
    final start = DateTime(2026, 1, 1, 0, 0, 1);
    for (var i = 0; i < 5; i++) {
      tracker.update(
        ax: 0,
        ay: 0,
        az: 9.8,
        mx: 0,
        my: 40,
        mz: 0,
        declination: 0,
        now: start.add(Duration(milliseconds: 20 * i)),
      );
    }

    // gz negative is clockwise when looking at the screen. One radian per
    // second for 1 second is about 57°.
    double? heading;
    for (var i = 0; i < 20; i++) {
      heading = tracker.update(
        ax: 0,
        ay: 0,
        az: 9.8,
        mx: 0,
        my: 40,
        mz: 0,
        gz: -1,
        declination: 0,
        now: start.add(Duration(milliseconds: 100 + 50 * i)),
      );
    }
    expect(heading!, closeTo(57, 4));
  });

  test('catalogs are complete', () {
    expect(surahCatalog, hasLength(114));
    expect(divineNames, hasLength(99));
    expect(libraryCollections, hasLength(7));
  });
}
