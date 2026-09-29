import 'dart:math' as math;

import 'package:adhan_dart/adhan_dart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/display_prefs.dart';
import '../calendar/prayer_cities.dart';

enum LocationSource { makkahDefault, gps, city }

class PrayerLocation {
  const PrayerLocation({
    required this.latitude,
    required this.longitude,
    required this.label,
    required this.source,
  });

  final double latitude;
  final double longitude;
  final String label;
  final LocationSource source;

  static const makkah = PrayerLocation(
    latitude: 21.4225,
    longitude: 39.8262,
    label: 'Makkah',
    source: LocationSource.makkahDefault,
  );

  Coordinates get coordinates => Coordinates(latitude, longitude);

  Map<String, dynamic> toMap() => {
        'lat': latitude,
        'lng': longitude,
        'label': label,
        'source': source.name,
      };

  factory PrayerLocation.fromMap(Map<dynamic, dynamic> map) {
    return PrayerLocation(
      latitude: (map['lat'] as num?)?.toDouble() ?? makkah.latitude,
      longitude: (map['lng'] as num?)?.toDouble() ?? makkah.longitude,
      label: map['label'] as String? ?? makkah.label,
      source: LocationSource.values.firstWhere(
        (s) => s.name == map['source'],
        orElse: () => LocationSource.makkahDefault,
      ),
    );
  }
}

class PrayerLocationController extends Notifier<PrayerLocation> {
  Box<dynamic> get _box => Hive.box(AppConstants.prefsBox);

  @override
  PrayerLocation build() {
    final raw = _box.get(AppConstants.prayerLocationKey);
    if (raw is Map) return PrayerLocation.fromMap(raw);
    return PrayerLocation.makkah;
  }

  Future<void> setLocation(PrayerLocation location) async {
    state = location;
    await _box.put(AppConstants.prayerLocationKey, location.toMap());
  }

  Future<void> setCity(PrayerCity city) {
    return setLocation(
      PrayerLocation(
        latitude: city.latitude,
        longitude: city.longitude,
        label: city.label,
        source: LocationSource.city,
      ),
    );
  }

  Future<void> setGps({
    required double latitude,
    required double longitude,
  }) {
    return setLocation(
      PrayerLocation(
        latitude: latitude,
        longitude: longitude,
        label: 'Current location',
        source: LocationSource.gps,
      ),
    );
  }
}

final prayerLocationProvider =
    NotifierProvider<PrayerLocationController, PrayerLocation>(
  PrayerLocationController.new,
);

class DayPrayers {
  const DayPrayers({
    required this.fajr,
    required this.sunrise,
    required this.duha,
    required this.dhuhr,
    required this.asr,
    required this.asrAlt,
    required this.maghrib,
    required this.isha,
    required this.middleOfNight,
    required this.lastThird,
    required this.next,
    required this.nextAt,
    required this.current,
    required this.qiblaDegrees,
    required this.makkahKm,
  });

  final DateTime fajr;
  final DateTime sunrise;
  final DateTime duha;
  final DateTime dhuhr;
  final DateTime asr;
  final DateTime asrAlt;
  final DateTime maghrib;
  final DateTime isha;
  final DateTime middleOfNight;
  final DateTime lastThird;
  final String next;
  final DateTime nextAt;
  final String? current;
  final double qiblaDegrees;
  final double makkahKm;

  List<(String, DateTime)> get primary => [
        ('Fajr', fajr),
        ('Sunrise', sunrise),
        ('Duha', duha),
        ('Dhuhr', dhuhr),
        ('Asr', asr),
        ('Maghrib', maghrib),
        ('Isha', isha),
      ];

  List<(String, DateTime)> get nightExtras => [
        ('Middle of the night', middleOfNight),
        ('Last third of the night', lastThird),
      ];

  /// Compact home row: the prayer in progress, and the one coming next.
  List<(String, DateTime, bool)> get summary {
    final now = DateTime.now();
    final rows = <(String, DateTime, bool)>[];
    if (current != null) {
      final match = primary.where((row) => row.$1 == current);
      if (match.isNotEmpty) {
        rows.add((match.first.$1, match.first.$2, true));
      }
    }
    rows.add((next, nextAt, false));
    if (rows.length == 1 && now.isBefore(fajr)) {
      return [('Fajr', fajr, false)];
    }
    return rows;
  }
}

CalculationParameters _parameters(AsrSchool school) {
  final params = CalculationMethodParameters.muslimWorldLeague();
  params.madhab = school == AsrSchool.later ? Madhab.hanafi : Madhab.shafi;
  return params;
}

DayPrayers calculatePrayers(
  PrayerLocation location,
  DateTime date, {
  AsrSchool school = AsrSchool.earlier,
}) {
  final local = DateTime(date.year, date.month, date.day, 12);
  final times = PrayerTimes(
    date: local,
    coordinates: location.coordinates,
    calculationParameters: _parameters(school),
  );
  final other = PrayerTimes(
    date: local,
    coordinates: location.coordinates,
    calculationParameters: _parameters(
      school == AsrSchool.later ? AsrSchool.earlier : AsrSchool.later,
    ),
  );
  final tomorrow = PrayerTimes(
    date: local.add(const Duration(days: 1)),
    coordinates: location.coordinates,
    calculationParameters: _parameters(school),
  );

  var next = times.nextPrayer(date: DateTime.now());
  if (next == Prayer.sunrise) next = Prayer.dhuhr;
  DateTime nextAt = times.timeForPrayer(next);
  var nextName = next.displayName;
  if (next == Prayer.fajrAfter) {
    nextName = 'Fajr';
    nextAt = times.fajrAfter;
  }

  final fajr = times.fajr.toLocal();
  final sunrise = times.sunrise.toLocal();
  final maghrib = times.maghrib.toLocal();
  final nextFajr = tomorrow.fajr.toLocal();
  final night = nextFajr.difference(maghrib);

  return DayPrayers(
    fajr: fajr,
    sunrise: sunrise,
    duha: sunrise.add(const Duration(minutes: 20)),
    dhuhr: times.dhuhr.toLocal(),
    asr: times.asr.toLocal(),
    asrAlt: other.asr.toLocal(),
    maghrib: maghrib,
    isha: times.isha.toLocal(),
    middleOfNight: maghrib.add(night ~/ 2),
    lastThird: maghrib.add(Duration(minutes: (night.inMinutes * 2) ~/ 3)),
    next: nextName,
    nextAt: nextAt.toLocal(),
    current: _current(times),
    qiblaDegrees: qiblaBearing(location.latitude, location.longitude),
    makkahKm: distanceToMakkahKm(location.latitude, location.longitude),
  );
}

String _current(PrayerTimes times) {
  final current = times.currentPrayer();
  if (current == Prayer.ishaBefore) return 'Isha';
  if (current == Prayer.sunrise) return 'Sunrise';
  if (current == Prayer.fajrAfter) return 'Fajr';
  return current.displayName;
}

double qiblaBearing(double latitude, double longitude) {
  const kaabaLat = 21.4225 * math.pi / 180;
  const kaabaLng = 39.8262 * math.pi / 180;
  final lat = latitude * math.pi / 180;
  final lng = longitude * math.pi / 180;
  final y = math.sin(kaabaLng - lng);
  final x = math.cos(lat) * math.tan(kaabaLat) -
      math.sin(lat) * math.cos(kaabaLng - lng);
  var degrees = math.atan2(y, x) * 180 / math.pi;
  if (degrees < 0) degrees += 360;
  return degrees;
}

double distanceToMakkahKm(double latitude, double longitude) {
  const earth = 6371.0;
  const kaabaLat = 21.4225 * math.pi / 180;
  const kaabaLng = 39.8262 * math.pi / 180;
  final lat = latitude * math.pi / 180;
  final lng = longitude * math.pi / 180;
  final dLat = kaabaLat - lat;
  final dLng = kaabaLng - lng;
  final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.cos(lat) *
          math.cos(kaabaLat) *
          math.sin(dLng / 2) *
          math.sin(dLng / 2);
  return earth * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
}

final todayPrayersProvider = Provider<DayPrayers>((ref) {
  final school = ref.watch(displayPrefsProvider).asrSchool;
  return calculatePrayers(
    ref.watch(prayerLocationProvider),
    DateTime.now(),
    school: school,
  );
});
