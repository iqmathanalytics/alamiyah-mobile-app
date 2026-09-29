import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/alamiyah_colors.dart';
import '../../../data/services/fasting_tracker.dart';
import '../../../data/services/firebase_config.dart';
import '../../../data/services/hijri_service.dart';
import '../../../data/services/prayer_times_service.dart';
import '../../home/providers/feed_providers.dart';

final zakatUrlProvider = FutureProvider<String?>((ref) async {
  if (!FirebaseConfig.isConfigured) return null;
  try {
    final doc =
        await FirebaseFirestore.instance.collection('meta').doc('app').get();
    final url = doc.data()?['zakatUrl'] as String?;
    if (url != null && url.trim().isNotEmpty) return url.trim();
  } catch (_) {}
  return null;
});

class RamadanCompanion extends ConsumerWidget {
  const RamadanCompanion({
    super.key,
    required this.today,
    required this.preview,
  });

  final HijriDate today;
  final bool preview;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.alamiyahColors;
    final location = ref.watch(prayerLocationProvider);
    final fasted = ref.watch(fastingTrackerProvider);
    final tracker = ref.read(fastingTrackerProvider.notifier);
    final year = today.month <= 9 ? today.year : today.year + 1;
    final streakToday = today.isRamadan
        ? today
        : HijriDate.fromGregorian(
            HijriDate(
              year: year,
              month: 9,
              day: 1,
              monthName: 'Ramadan',
              weekday: 1,
            ).toGregorian(),
          );
    final streak = tracker.streakInRamadan(
      today.isRamadan ? today : streakToday,
    );
    final days = HijriDate.daysInMonth(year, 9);
    final ramadanToday = today.isRamadan ? today.day : 1;
    final dua = ramadanDuas[(ramadanToday - 1) % ramadanDuas.length];
    final inLastTen = today.isRamadan && today.day >= 21;
    final untilTwentySeven = today.isRamadan ? (27 - today.day) : null;
    final zakatAsync = ref.watch(zakatUrlProvider);
    final featured = ref.watch(featuredContentProvider).asData?.value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          preview ? 'Ramadan companion (preview)' : 'Ramadan companion',
          style: GoogleFonts.dmSans(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: colors.brandPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          streak == 0
              ? 'Mark a day when you fasted — a quiet record on this device.'
              : '$streak ${streak == 1 ? 'day' : 'days'} marked this Ramadan.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 12),
        ...List.generate(days, (i) {
          final day = i + 1;
          final hijriDay = HijriDate.hijri(year, 9, day);
          final prayers = calculatePrayers(location, hijriDay.toGregorian());
          final marked = fasted.contains(tracker.keyFor(hijriDay));
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Material(
              color: colors.cardBackground,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => tracker.toggle(hijriDay),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        marked
                            ? Icons.check_circle_rounded
                            : Icons.circle_outlined,
                        color: marked
                            ? colors.brandPrimary
                            : colors.brandSecondary,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Day $day',
                              style: GoogleFonts.dmSans(
                                fontWeight: FontWeight.w600,
                                color: colors.brandPrimary,
                              ),
                            ),
                            Text(
                              'Suhoor ends ${_fmt(prayers.fajr)} · Iftar ${_fmt(prayers.maghrib)}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
        const SizedBox(height: 8),
        Text(
          'Ramadan extras',
          style: GoogleFonts.dmSans(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: colors.brandPrimary,
          ),
        ),
        const SizedBox(height: 8),
        _ExtraCard(
          title: 'Today’s dua',
          body: featured?.title != null
              ? '${featured!.title}\n${featured.translation ?? dua}'
              : dua,
        ),
        if (inLastTen)
          _ExtraCard(
            title: 'Last ten nights',
            body: untilTwentySeven == null
                ? 'Seek Laylatul Qadr in the odd nights.'
                : untilTwentySeven > 0
                    ? '$untilTwentySeven nights until the 27th — keep seeking the odd nights.'
                    : 'You are in the heart of the last ten nights.',
          ),
        zakatAsync.when(
          data: (url) => _ExtraCard(
            title: 'Zakat and charity',
            body: url == null
                ? 'When an admin adds a charity link, it will open from here.'
                : 'Open the charity link your community set.',
            action: url == null
                ? null
                : () => launchUrl(
                      Uri.parse(url),
                      mode: LaunchMode.externalApplication,
                    ),
            actionLabel: url == null ? null : 'Open link',
          ),
          loading: () => const SizedBox.shrink(),
          error: (_, _) => const SizedBox.shrink(),
        ),
      ],
    );
  }

  String _fmt(DateTime t) {
    final h = t.hour % 12 == 0 ? 12 : t.hour % 12;
    final m = t.minute.toString().padLeft(2, '0');
    final ap = t.hour >= 12 ? 'pm' : 'am';
    return '$h:$m $ap';
  }
}

class _ExtraCard extends StatelessWidget {
  const _ExtraCard({
    required this.title,
    required this.body,
    this.action,
    this.actionLabel,
  });

  final String title;
  final String body;
  final VoidCallback? action;
  final String? actionLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.alamiyahColors;
    return Container(
      width: double.infinity,
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
            title,
            style: GoogleFonts.dmSans(
              fontWeight: FontWeight.w600,
              color: colors.brandPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(body, style: Theme.of(context).textTheme.bodyMedium),
          if (action != null && actionLabel != null)
            TextButton(onPressed: action, child: Text(actionLabel!)),
        ],
      ),
    );
  }
}
