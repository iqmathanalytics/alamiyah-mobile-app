import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/l10n/app_strings.dart';
import '../../../core/theme/alamiyah_colors.dart';
import '../../../core/theme/display_prefs.dart';
import '../../../data/services/hijri_service.dart';
import '../../../data/services/prayer_times_service.dart';

class HomeHijriPrayerCard extends ConsumerStatefulWidget {
  const HomeHijriPrayerCard({super.key});

  @override
  ConsumerState<HomeHijriPrayerCard> createState() =>
      _HomeHijriPrayerCardState();
}

class _HomeHijriPrayerCardState extends ConsumerState<HomeHijriPrayerCard> {
  late final StreamSubscription<dynamic> _tick;
  var _expanded = false;

  @override
  void initState() {
    super.initState();
    _tick = Stream.periodic(const Duration(seconds: 30)).listen((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tick.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.alamiyahColors;
    final strings = context.s;
    final hijri = HijriDate.now();
    final prayers = ref.watch(todayPrayersProvider);
    final showBoth = ref.watch(displayPrefsProvider).showBothAsr;
    final location = ref.watch(prayerLocationProvider);
    final remaining = prayers.nextAt.difference(DateTime.now());
    final wait = remaining.isNegative
        ? 'now'
        : remaining.inHours > 0
            ? '${remaining.inHours}h ${remaining.inMinutes % 60}m'
            : '${remaining.inMinutes}m';

    return Material(
      color: colors.cardBackground,
      borderRadius: BorderRadius.circular(22),
      elevation: 0,
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          color: colors.cardBackground,
          border: Border.all(
            color: colors.brandPrimary.withValues(alpha: 0.08),
          ),
          boxShadow: [
            BoxShadow(
              color: colors.softShadow,
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 15, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => context.go('/calendar'),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            hijri.longLabel,
                            style: GoogleFonts.dmSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: colors.brandPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            location.label,
                            style: GoogleFonts.dmSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: colors.brandSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: colors.brandSecondary,
                      size: 20,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: colors.chipBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${strings.next} · ${strings.prayer(prayers.next)} in $wait',
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: colors.brandPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              ..._rows(prayers, showBoth).map((row) => _line(colors, row)),
              TextButton(
                onPressed: () => setState(() => _expanded = !_expanded),
                style: TextButton.styleFrom(
                  foregroundColor: colors.brandPrimary,
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                ),
                child: Text(
                  _expanded ? strings.showLess : strings.showMore,
                  style: GoogleFonts.dmSans(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => context.push('/qibla'),
                  style: TextButton.styleFrom(
                    foregroundColor: colors.brandPrimary,
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  ),
                  icon: Icon(
                    Icons.explore_outlined,
                    size: 16,
                    color: colors.accentGold,
                  ),
                  label: Text(
                    '${strings.qibla} ${prayers.qiblaDegrees.round()}° · ${prayers.makkahKm.round()} km',
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: colors.brandSecondary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
            ],
          ),
        ),
      ),
    );
  }

  List<(String, DateTime, bool, String?)> _rows(
    DayPrayers prayers,
    bool showBoth,
  ) {
    if (!_expanded) {
      return [
        for (final row in prayers.summary)
          (row.$1, row.$2, row.$3, null),
      ];
    }
    return _fullRows(prayers, showBoth);
  }

  List<(String, DateTime, bool, String?)> _fullRows(
    DayPrayers prayers,
    bool showBoth,
  ) {
    return [
      for (final row in prayers.primary)
        (
          row.$1,
          row.$2,
          row.$1 == prayers.current,
          showBoth && row.$1 == 'Asr' ? _fmt(prayers.asrAlt) : null,
        ),
      for (final row in prayers.nightExtras)
        (row.$1, row.$2, false, null),
    ];
  }

  Widget _line(
    AlamiyahColors colors,
    (String, DateTime, bool, String?) row,
  ) {
    final current = row.$3;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(
            child: Text(
              context.s.prayer(row.$1),
              style: GoogleFonts.dmSans(
                fontSize: 13,
                fontWeight: current ? FontWeight.w700 : FontWeight.w500,
                color: current ? colors.accentGold : colors.brandPrimary,
              ),
            ),
          ),
          if (row.$4 != null)
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Text(
                row.$4!,
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  color: colors.brandSecondary,
                ),
              ),
            ),
          Text(
            _fmt(row.$2),
            style: GoogleFonts.dmSans(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: colors.brandPrimary,
            ),
          ),
        ],
      ),
    );
  }

  String _fmt(DateTime t) {
    final h = t.hour % 12 == 0 ? 12 : t.hour % 12;
    final m = t.minute.toString().padLeft(2, '0');
    final suffix = t.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $suffix';
  }
}
