import 'dart:convert';

import 'package:flutter/services.dart';

import 'prayer_cities.dart';

const _resultLimit = 30;

List<PrayerCity>? _malaysiaCities;

/// Cities in Malaysia, read the first time someone searches.
Future<List<PrayerCity>> loadMalaysiaCities() async {
  final cached = _malaysiaCities;
  if (cached != null) return cached;
  final raw = await rootBundle.loadString('assets/data/malaysia_cities.json');
  final decoded = jsonDecode(raw) as List<dynamic>;
  final cities = decoded.map((entry) {
    final city = entry as Map<String, dynamic>;
    final state = city['state'] as String;
    return PrayerCity(
      name: city['name'] as String,
      country: '$state, Malaysia',
      latitude: (city['lat'] as num).toDouble(),
      longitude: (city['lng'] as num).toDouble(),
    );
  }).toList();
  _malaysiaCities = cities;
  return cities;
}

/// [base] is shown as-is when [query] is empty. A typed query searches
/// [base] and [extra] and returns only the matches, starting with names
/// that begin with those letters.
List<PrayerCity> filterCities(
  List<PrayerCity> base,
  List<PrayerCity> extra,
  String query, {
  int limit = _resultLimit,
}) {
  final q = query.trim().toLowerCase();
  if (q.isEmpty) return base;

  final seen = <String>{};
  final cities = <PrayerCity>[];
  for (final city in [...base, ...extra]) {
    if (seen.add(city.label.toLowerCase())) cities.add(city);
  }

  bool starts(PrayerCity city) => city.name.toLowerCase().startsWith(q);
  bool contains(PrayerCity city) {
    final name = city.name.toLowerCase();
    final state = city.country.toLowerCase();
    // State matches only from a few letters, so "a" does not match every
    // city whose state name happens to contain that letter.
    return name.contains(q) || (q.length >= 3 && state.startsWith(q));
  }

  int byName(PrayerCity a, PrayerCity b) =>
      a.name.toLowerCase().compareTo(b.name.toLowerCase());

  final leading = cities.where(starts).toList()..sort(byName);
  final rest = cities.where((city) => !starts(city) && contains(city)).toList()
    ..sort(byName);
  return [...leading, ...rest].take(limit).toList();
}

/// Short world list until the user types; Malaysian cities are loaded then.
Future<List<PrayerCity>> searchCities(String query) async {
  if (query.trim().isEmpty) return prayerCities;
  final malaysia = await loadMalaysiaCities();
  return filterCities(prayerCities, malaysia, query);
}
