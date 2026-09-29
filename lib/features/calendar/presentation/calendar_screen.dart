import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/alamiyah_colors.dart';
import '../../../core/theme/display_prefs.dart';
import '../../../data/calendar/islamic_events.dart';
import '../../../data/calendar/prayer_cities.dart';
import '../../../data/services/fasting_reminder_service.dart';
import '../../../data/services/fasting_tracker.dart';
import '../../../data/services/hijri_service.dart';
import '../../../data/services/prayer_times_service.dart';
import '../../../shared/widgets/app_shell.dart';
import 'ramadan_companion.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  late HijriDate _cursor;
  late HijriDate _selected;

  @override
  void initState() {
    super.initState();
    final now = HijriDate.now();
    _cursor = now;
    _selected = now;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.alamiyahColors;
    final flags = ref.watch(calendarFlagsProvider);
    final location = ref.watch(prayerLocationProvider);
    final today = HijriDate.now();
    final ramadan = today.isRamadan || flags.preview;

    ref.listen(calendarFlagsProvider, (_, next) {
      FastingReminderService.instance.sync(
        enabled: next.reminders,
        ramadanActive: today.isRamadan || next.preview,
        location: ref.read(prayerLocationProvider),
      );
    });
    ref.listen(prayerLocationProvider, (_, next) {
      FastingReminderService.instance.sync(
        enabled: flags.reminders,
        ramadanActive: ramadan,
        location: next,
      );
    });

    final days = HijriDate.daysInMonth(_cursor.year, _cursor.month);
    final offset = HijriDate.saturdayOffset(_cursor.year, _cursor.month);
    final selectedEvents =
        eventsOn(month: _selected.month, day: _selected.day);

    return Scaffold(
      appBar: AlamiyahAppBar(
        title: 'Calendar',
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          Text(
            today.longLabel,
            style: GoogleFonts.dmSans(
              fontSize: context.contentSize(13),
              color: colors.brandSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Umm al-Qura civil dates · local sighting may differ by a day',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              IconButton(
                onPressed: () => setState(() {
                  _cursor = _cursor.copyWith(month: _cursor.month - 1, day: 1);
                }),
                icon: const Icon(Icons.chevron_left_rounded),
              ),
              Expanded(
                child: Text(
                  '${_cursor.monthName} ${_cursor.year}',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.dmSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: colors.brandPrimary,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => setState(() {
                  _cursor = _cursor.copyWith(month: _cursor.month + 1, day: 1);
                }),
                icon: const Icon(Icons.chevron_right_rounded),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: const [
              _Dow('Sat'),
              _Dow('Sun'),
              _Dow('Mon'),
              _Dow('Tue'),
              _Dow('Wed'),
              _Dow('Thu'),
              _Dow('Fri'),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.fromLTRB(8, 10, 8, 10),
            decoration: BoxDecoration(
              color: colors.cardBackground,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: colors.brandPrimary.withValues(alpha: 0.06),
              ),
              boxShadow: [
                BoxShadow(
                  color: colors.softShadow,
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: offset + days,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
            ),
            itemBuilder: (context, index) {
              if (index < offset) return const SizedBox.shrink();
              final day = index - offset + 1;
              final isToday = _cursor.year == today.year &&
                  _cursor.month == today.month &&
                  day == today.day;
              final isSelected = _cursor.year == _selected.year &&
                  _cursor.month == _selected.month &&
                  day == _selected.day;
              final hasEvent =
                  eventsOn(month: _cursor.month, day: day).isNotEmpty;
              return InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => setState(() {
                  _selected = _cursor.copyWith(day: day);
                }),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? colors.brandPrimary
                        : isToday
                            ? colors.chipBackground
                            : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$day',
                        style: GoogleFonts.dmSans(
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? Colors.white
                              : colors.brandPrimary,
                        ),
                      ),
                      if (hasEvent)
                        Container(
                          width: 5,
                          height: 5,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? colors.accentGold
                                : colors.brandSecondary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
          ),
          const SizedBox(height: 16),
          if (selectedEvents.isEmpty)
            Text(
              'No listed observances on ${_selected.day} ${_selected.monthName}.',
              style: Theme.of(context).textTheme.bodyMedium,
            )
          else
            ...selectedEvents.map(
              (e) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: colors.cardBackground,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      e.title,
                      style: GoogleFonts.dmSans(
                        fontWeight: FontWeight.w600,
                        color: colors.brandPrimary,
                      ),
                    ),
                    if (e.note != null)
                      Text(
                        e.note!,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 20),
          _LocationCard(
            location: location,
            onPickCity: () => _pickCity(context),
            onUseGps: () => _useGps(context),
          ),
          const SizedBox(height: 10),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              'Preview Ramadan companion',
              style: GoogleFonts.dmSans(fontWeight: FontWeight.w600),
            ),
            subtitle: const Text('Look ahead when it is not Ramadan'),
            value: flags.preview,
            onChanged: (v) =>
                ref.read(calendarFlagsProvider.notifier).setPreview(v),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              'Fasting reminders',
              style: GoogleFonts.dmSans(fontWeight: FontWeight.w600),
            ),
            subtitle: const Text(
              'Suhoor ~40 minutes before Fajr, iftar at Maghrib',
            ),
            value: flags.reminders,
            onChanged: (v) => _toggleReminders(context, v),
          ),
          if (ramadan) ...[
            const SizedBox(height: 12),
            RamadanCompanion(
              today: today,
              preview: flags.preview && !today.isRamadan,
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _toggleReminders(BuildContext context, bool enabled) async {
    if (enabled) {
      final allowed = await FastingReminderService.instance.requestPermission();
      if (!context.mounted) return;
      if (!allowed) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Notifications are blocked. Allow them in system settings to get suhoor/iftar reminders.',
            ),
          ),
        );
        return;
      }
    }
    await ref.read(calendarFlagsProvider.notifier).setReminders(enabled);
  }

  Future<void> _useGps(BuildContext context) async {
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location is off — pick a city instead.'),
            ),
          );
        }
        return;
      }
      final pos = await Geolocator.getCurrentPosition();
      await ref.read(prayerLocationProvider.notifier).setGps(
            latitude: pos.latitude,
            longitude: pos.longitude,
          );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not read location. $e')),
        );
      }
    }
  }

  Future<void> _pickCity(BuildContext context) async {
    final city = await showModalBottomSheet<PrayerCity>(
      context: context,
      isScrollControlled: true,
      builder: (context) => const _CitySheet(),
    );
    if (city != null) {
      await ref.read(prayerLocationProvider.notifier).setCity(city);
    }
  }
}

class _Dow extends StatelessWidget {
  const _Dow(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: GoogleFonts.dmSans(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: context.alamiyahColors.brandSecondary,
        ),
      ),
    );
  }
}

class _LocationCard extends StatelessWidget {
  const _LocationCard({
    required this.location,
    required this.onPickCity,
    required this.onUseGps,
  });

  final PrayerLocation location;
  final VoidCallback onPickCity;
  final VoidCallback onUseGps;

  @override
  Widget build(BuildContext context) {
    final colors = context.alamiyahColors;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Prayer times for ${location.label}',
            style: GoogleFonts.dmSans(
              fontWeight: FontWeight.w600,
              color: colors.brandPrimary,
            ),
          ),
          if (location.source == LocationSource.makkahDefault)
            Text(
              'Using Makkah until you set a city or allow location.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          const SizedBox(height: 8),
          Row(
            children: [
              TextButton(onPressed: onUseGps, child: const Text('Use location')),
              TextButton(onPressed: onPickCity, child: const Text('Choose city')),
            ],
          ),
        ],
      ),
    );
  }
}

class _CitySheet extends StatefulWidget {
  const _CitySheet();

  @override
  State<_CitySheet> createState() => _CitySheetState();
}

class _CitySheetState extends State<_CitySheet> {
  var _query = '';

  @override
  Widget build(BuildContext context) {
    final filtered = prayerCities
        .where((c) =>
            c.label.toLowerCase().contains(_query.toLowerCase()))
        .toList();
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 20,
      ),
      child: SizedBox(
        height: 420,
        child: Column(
          children: [
            TextField(
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Search a city',
                prefixIcon: Icon(Icons.search_rounded),
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final city = filtered[index];
                  return ListTile(
                    title: Text(city.name),
                    subtitle: Text(city.country),
                    onTap: () => Navigator.pop(context, city),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
