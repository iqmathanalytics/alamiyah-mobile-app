/// Recurring Hijri observances. Edit this list to add or rename dates.
/// Months: 1 Muharram … 9 Ramadan … 12 Dhu al-Hijjah.
class IslamicEvent {
  const IslamicEvent({
    required this.month,
    required this.day,
    required this.title,
    this.note,
    this.kind = EventKind.observance,
  });

  final int month;
  final int day;
  final String title;
  final String? note;
  final EventKind kind;
}

enum EventKind { major, ramadan, estimated, observance }

/// Umm al-Qura civil calendar dates (astronomical). Local moon-sighting
/// may differ by a day.
const islamicEvents = <IslamicEvent>[
  IslamicEvent(
    month: 1,
    day: 1,
    title: 'Islamic New Year',
    kind: EventKind.major,
  ),
  IslamicEvent(
    month: 1,
    day: 10,
    title: 'Day of Ashura',
    note: 'The 10th of Muharram',
    kind: EventKind.major,
  ),
  IslamicEvent(
    month: 3,
    day: 12,
    title: 'Mawlid an-Nabi',
    note: 'Observed on 12 Rabiʿ al-Awwal in many communities',
  ),
  IslamicEvent(
    month: 7,
    day: 27,
    title: 'Isra and Miʿraj',
  ),
  IslamicEvent(
    month: 8,
    day: 15,
    title: 'Mid-Shaʿban',
  ),
  IslamicEvent(
    month: 9,
    day: 1,
    title: 'Ramadan begins',
    kind: EventKind.ramadan,
  ),
  IslamicEvent(
    month: 9,
    day: 21,
    title: 'Laylatul Qadr (estimated)',
    note: 'Sought in the last ten odd nights',
    kind: EventKind.estimated,
  ),
  IslamicEvent(
    month: 9,
    day: 23,
    title: 'Laylatul Qadr (estimated)',
    kind: EventKind.estimated,
  ),
  IslamicEvent(
    month: 9,
    day: 25,
    title: 'Laylatul Qadr (estimated)',
    kind: EventKind.estimated,
  ),
  IslamicEvent(
    month: 9,
    day: 27,
    title: 'Laylatul Qadr (most commonly observed)',
    kind: EventKind.estimated,
  ),
  IslamicEvent(
    month: 9,
    day: 29,
    title: 'Laylatul Qadr (estimated)',
    kind: EventKind.estimated,
  ),
  IslamicEvent(
    month: 10,
    day: 1,
    title: 'Eid al-Fitr',
    kind: EventKind.major,
  ),
  IslamicEvent(
    month: 12,
    day: 9,
    title: 'Day of ʿArafah',
    kind: EventKind.major,
  ),
  IslamicEvent(
    month: 12,
    day: 10,
    title: 'Eid al-Adha',
    kind: EventKind.major,
  ),
];

List<IslamicEvent> eventsOn({required int month, required int day}) {
  return islamicEvents.where((e) => e.month == month && e.day == day).toList();
}
