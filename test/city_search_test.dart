import 'package:alamiyah/data/calendar/city_search.dart';
import 'package:alamiyah/data/calendar/prayer_cities.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('empty search keeps the short city list', () {
    final shown = filterCities(prayerCities, const [], '  ');
    expect(shown, prayerCities);
  });

  test('typed letters return only matching Malaysian cities', () async {
    final malaysia = await loadMalaysiaCities();
    expect(malaysia.length, greaterThan(300));
    expect(malaysia.any((city) => city.name == 'Muar'), isTrue);
    expect(malaysia.any((city) => city.name == 'Sandakan'), isTrue);
    expect(malaysia.any((city) => city.name == 'Kemaman'), isTrue);

    final muar = filterCities(prayerCities, malaysia, 'muar');
    expect(muar, isNotEmpty);
    expect(muar.first.name, 'Muar');
    expect(muar.every((city) => city.label.toLowerCase().contains('muar')), isTrue);

    final letter = filterCities(prayerCities, malaysia, 'k');
    expect(letter.length, lessThanOrEqualTo(30));
    expect(letter.every((city) => city.name.toLowerCase().startsWith('k')), isTrue);

    final johor = filterCities(prayerCities, malaysia, 'johor');
    expect(johor.any((city) => city.country.startsWith('Johor')), isTrue);

    expect(filterCities(prayerCities, malaysia, 'qzxq'), isEmpty);
  });
}