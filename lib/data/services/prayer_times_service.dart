import 'package:adhan_dart/adhan_dart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../core/constants/app_constants.dart';
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
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
    required this.next,
    required this.nextAt,
  });

  final DateTime fajr;
  final DateTime dhuhr;
  final DateTime asr;
  final DateTime maghrib;
  final DateTime isha;
  final String next;
  final DateTime nextAt;

  List<(String, DateTime)> get all => [
        ('Fajr', fajr),
        ('Dhuhr', dhuhr),
        ('Asr', asr),
        ('Maghrib', maghrib),
        ('Isha', isha),
      ];
}

DayPrayers calculatePrayers(PrayerLocation location, DateTime date) {
  final local = DateTime(date.year, date.month, date.day, 12);
  final times = PrayerTimes(
    date: local,
    coordinates: location.coordinates,
    calculationParameters: CalculationMethodParameters.muslimWorldLeague(),
  );

  var next = times.nextPrayer(date: DateTime.now());
  if (next == Prayer.sunrise) next = Prayer.dhuhr;
  DateTime nextAt = times.timeForPrayer(next);
  var nextName = next.displayName;
  if (next == Prayer.fajrAfter) {
    nextName = 'Fajr';
    nextAt = times.fajrAfter;
  }

  return DayPrayers(
    fajr: times.fajr.toLocal(),
    dhuhr: times.dhuhr.toLocal(),
    asr: times.asr.toLocal(),
    maghrib: times.maghrib.toLocal(),
    isha: times.isha.toLocal(),
    next: nextName,
    nextAt: nextAt.toLocal(),
  );
}

final todayPrayersProvider = Provider<DayPrayers>((ref) {
  return calculatePrayers(ref.watch(prayerLocationProvider), DateTime.now());
});
