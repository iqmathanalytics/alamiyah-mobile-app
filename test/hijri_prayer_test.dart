import 'package:adhan_dart/adhan_dart.dart';
import 'package:alamiyah/data/services/hijri_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hijri/hijri_calendar.dart';

void main() {
  test('Umm al-Qura: 1 Muharram 1446 is 7 July 2024', () {
    final g = HijriCalendar().hijriToGregorian(1446, 1, 1);
    expect(DateTime(g.year, g.month, g.day), DateTime(2024, 7, 7));
  });

  test('Gregorian 7 July 2024 converts back to 1 Muharram 1446', () {
    final h = HijriDate.fromGregorian(DateTime(2024, 7, 7));
    expect(h.year, 1446);
    expect(h.month, 1);
    expect(h.day, 1);
  });

  test('Eid al-Fitr 1446 (1 Shawwal) is 30 March 2025 in Umm al-Qura', () {
    final g = HijriCalendar().hijriToGregorian(1446, 10, 1);
    expect(DateTime(g.year, g.month, g.day), DateTime(2025, 3, 30));
  });

  test('Ramadan month has 29 or 30 days', () {
    final days = HijriDate.daysInMonth(1446, 9);
    expect(days, anyOf(29, 30));
  });

  test('Makkah prayer times stay in chronological order', () {
    final times = PrayerTimes(
      date: DateTime(2024, 1, 1, 12),
      coordinates: const Coordinates(21.4225, 39.8262),
      calculationParameters: CalculationMethodParameters.ummAlQura(),
    );
    expect(times.fajr.isBefore(times.sunrise), isTrue);
    expect(times.sunrise.isBefore(times.dhuhr), isTrue);
    expect(times.dhuhr.isBefore(times.asr), isTrue);
    expect(times.asr.isBefore(times.maghrib), isTrue);
    expect(times.maghrib.isBefore(times.isha), isTrue);
  });
}
