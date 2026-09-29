import 'package:hijri/hijri_calendar.dart';

import '../calendar/islamic_events.dart';

/// Hijri conversion via the `hijri` package (Umm al-Qura civil table).
/// Local crescent-sighting can differ by one day.
class HijriDate {
  const HijriDate({
    required this.year,
    required this.month,
    required this.day,
    required this.monthName,
    required this.weekday,
  });

  final int year;
  final int month;
  final int day;
  final String monthName;
  final int weekday; // DateTime weekday: Mon=1 … Sun=7

  bool get isRamadan => month == 9;

  String get longLabel => '$day $monthName $year AH';

  List<IslamicEvent> get events => eventsOn(month: month, day: day);

  static HijriDate fromGregorian(DateTime date) {
    final local = DateTime(date.year, date.month, date.day);
    final h = HijriCalendar.fromDate(local);
    return HijriDate(
      year: h.hYear,
      month: h.hMonth,
      day: h.hDay,
      monthName: h.longMonthName,
      weekday: local.weekday,
    );
  }

  static HijriDate now() => fromGregorian(DateTime.now());

  static HijriDate hijri(int year, int month, int day) {
    final g = HijriCalendar().hijriToGregorian(year, month, day);
    final local = DateTime(g.year, g.month, g.day);
    final h = HijriCalendar.fromDate(local);
    return HijriDate(
      year: h.hYear,
      month: h.hMonth,
      day: h.hDay,
      monthName: h.longMonthName,
      weekday: local.weekday,
    );
  }

  DateTime toGregorian() {
    final g = HijriCalendar().hijriToGregorian(year, month, day);
    return DateTime(g.year, g.month, g.day);
  }

  static int daysInMonth(int year, int month) {
    return HijriCalendar().getDaysInMonth(year, month);
  }

  /// Saturday = 0 … Friday = 6 (week start used on the calendar grid).
  static int saturdayOffset(int year, int month) {
    final g = HijriCalendar().hijriToGregorian(year, month, 1);
    return (g.weekday + 1) % 7;
  }

  HijriDate copyWith({int? year, int? month, int? day}) {
    final y = year ?? this.year;
    var m = month ?? this.month;
    var ye = y;
    while (m > 12) {
      m -= 12;
      ye += 1;
    }
    while (m < 1) {
      m += 12;
      ye -= 1;
    }
    final maxDay = daysInMonth(ye, m);
    final d = (day ?? this.day).clamp(1, maxDay);
    final g = HijriCalendar().hijriToGregorian(ye, m, d);
    final h = HijriCalendar.fromDate(g);
    return HijriDate(
      year: h.hYear,
      month: h.hMonth,
      day: h.hDay,
      monthName: h.longMonthName,
      weekday: DateTime(g.year, g.month, g.day).weekday,
    );
  }
}

const ramadanDuas = <String>[
  'Allahumma innaka ʿafuwwun tuhibbul-ʿafwa faʿfu ʿanni.',
  'Rabbana atina fid-dunya hasanah wa fil-akhirati hasanah.',
  'Hasbunallahu wa niʿmal wakeel.',
  'Rabbighfir li waliwalidayya wa lilmu’minina.',
  'Allahumma inni as’aluka al-jannah.',
  'Rabbi zidni ʿilma.',
  'Allahumma ajirni minan-nar.',
  'La ilaha illa anta subhanaka inni kuntu minaz-zalimin.',
  'Allahumma innaka ʿafuwwun tuhibbul-ʿafwa faʿfu ʿanni.',
  'Rabbana la tu’akhidhna in nasina aw akhta’na.',
];
