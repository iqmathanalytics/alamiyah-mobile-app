import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/alamiyah_colors.dart';
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
    final hijri = HijriDate.now();
    final prayers = ref.watch(todayPrayersProvider);
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
      shadowColor: colors.softShadow,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () => context.go('/calendar'),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
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
            padding: const EdgeInsets.fromLTRB(16, 15, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        hijri.longLabel,
                        style: GoogleFonts.dmSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: colors.brandPrimary,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: colors.brandSecondary,
                      size: 20,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  location.label,
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: colors.brandSecondary,
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
                    'Next · ${prayers.next} in $wait',
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: colors.brandPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: prayers.all.map((e) {
                    final isNext = e.$1 == prayers.next;
                    return Expanded(
                      child: Column(
                        children: [
                          Text(
                            e.$1,
                            style: GoogleFonts.dmSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: isNext
                                  ? colors.accentGold
                                  : colors.brandSecondary,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            _fmt(e.$2),
                            style: GoogleFonts.dmSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: colors.brandPrimary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _fmt(DateTime t) {
    final h = t.hour % 12 == 0 ? 12 : t.hour % 12;
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}
