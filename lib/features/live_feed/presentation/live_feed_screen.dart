import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/motion/app_motion.dart';
import '../../../core/theme/alamiyah_colors.dart';
import '../../../core/theme/display_prefs.dart';
import '../../../core/utils/youtube.dart';
import '../../../data/models/models.dart';
import '../../../shared/widgets/app_shell.dart';
import '../../../shared/widgets/section_label.dart';
import '../../home/providers/feed_providers.dart';

class LiveFeedScreen extends ConsumerWidget {
  const LiveFeedScreen({super.key});

  Future<void> _open(BuildContext context, LiveFeedLink item) async {
    HapticFeedback.lightImpact();
    final ok = await Youtube.open(item.youtubeUrl);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open YouTube right now.')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final liveAsync = ref.watch(liveFeedProvider);
    final colors = context.alamiyahColors;

    return Scaffold(
      appBar: const AlamiyahAppBar(title: 'Live Feed'),
      body: liveAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => SoftEmptyState(
          icon: Icons.wifi_off_rounded,
          title: 'Could not load live feed',
          body: 'Check your connection, then try again.',
          actionLabel: 'Retry',
          onAction: () => ref.invalidate(liveFeedProvider),
        ),
        data: (items) {
          if (items.isEmpty) {
            return const SoftEmptyState(
              icon: Icons.videocam_outlined,
              title: 'No live content yet',
              body:
                  'When an admin adds a YouTube livestream or reminder, it will appear here.',
            );
          }

          final featured = items.where((e) => e.isFeatured).toList();
          final hero = featured.isNotEmpty
              ? featured.first
              : items.firstWhere((e) => e.isLiveNow, orElse: () => items.first);
          final rest = items.where((e) => e.id != hero.id).toList();

          return RefreshIndicator(
            color: colors.brandPrimary,
            onRefresh: () async => ref.invalidate(liveFeedProvider),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
              children: [
                _HeroCard(
                  item: hero,
                  onTap: () => _open(context, hero),
                ),
                if (rest.isNotEmpty) ...[
                  const SizedBox(height: 22),
                  const SectionLabel('More to watch'),
                  const SizedBox(height: 12),
                  for (var i = 0; i < rest.length; i++) ...[
                    if (i > 0) const SizedBox(height: 12),
                    _WatchCard(
                      item: rest[i],
                      onTap: () => _open(context, rest[i]),
                    ),
                  ],
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.item, required this.onTap});

  final LiveFeedLink item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.alamiyahColors;
    final thumb =
        Youtube.resolvedThumbnail(item.youtubeUrl, item.thumbnailUrl);

    return Material(
      color: colors.cardBackground,
      borderRadius: BorderRadius.circular(24),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (thumb != null)
                    Image.network(
                      thumb,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) =>
                          ColoredBox(color: colors.chipBackground),
                    )
                  else
                    ColoredBox(color: colors.chipBackground),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Color(0x99000000)],
                      ),
                    ),
                  ),
                  Center(
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.4),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 36,
                      ),
                    ),
                  ),
                  if (item.isLiveNow)
                    const Positioned(
                      top: 12,
                      left: 12,
                      child: LiveNowBadge(),
                    )
                  else if (item.isFeatured)
                    Positioned(
                      top: 12,
                      left: 12,
                      child: _OverlayChip(
                        label: 'Featured',
                        color: colors.accentGold,
                        textColor: colors.onAccent,
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: GoogleFonts.dmSans(
                      fontSize: context.contentSize(18),
                      fontWeight: FontWeight.w700,
                      color: colors.brandPrimary,
                    ),
                  ),
                  if (item.description?.isNotEmpty ?? false) ...[
                    const SizedBox(height: 6),
                    Text(
                      item.description!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontSize: context.contentSize(14),
                          ),
                    ),
                  ],
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(
                        Icons.smart_display_outlined,
                        size: 16,
                        color: colors.brandSecondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Watch on YouTube',
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: colors.brandSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WatchCard extends StatelessWidget {
  const _WatchCard({required this.item, required this.onTap});

  final LiveFeedLink item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.alamiyahColors;
    final thumb =
        Youtube.resolvedThumbnail(item.youtubeUrl, item.thumbnailUrl);

    return Material(
      color: colors.cardBackground,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (thumb != null)
                    Image.network(
                      thumb,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) =>
                          ColoredBox(color: colors.chipBackground),
                    )
                  else
                    ColoredBox(color: colors.chipBackground),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.35),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                  if (item.isLiveNow)
                    const Positioned(
                      top: 10,
                      left: 10,
                      child: LiveNowBadge(),
                    )
                  else if (item.isFeatured)
                    Positioned(
                      top: 10,
                      left: 10,
                      child: _OverlayChip(
                        label: 'Featured',
                        color: colors.accentGold,
                        textColor: colors.onAccent,
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: GoogleFonts.dmSans(
                      fontSize: context.contentSize(16),
                      fontWeight: FontWeight.w600,
                      color: colors.brandPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.smart_display_outlined,
                        size: 15,
                        color: colors.brandSecondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Watch on YouTube',
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          color: colors.brandSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OverlayChip extends StatelessWidget {
  const _OverlayChip({
    required this.label,
    required this.color,
    required this.textColor,
  });

  final String label;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: GoogleFonts.dmSans(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}

class LiveNowBadge extends StatefulWidget {
  const LiveNowBadge({super.key});

  @override
  State<LiveNowBadge> createState() => _LiveNowBadgeState();
}

class _LiveNowBadgeState extends State<LiveNowBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduce = context.alamiyahDisplay.reduceMotion;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xE61E3D32),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FadeTransition(
            opacity: reduce
                ? const AlwaysStoppedAnimation(1)
                : Tween(begin: 0.35, end: 1.0).animate(
                    CurvedAnimation(parent: _pulse, curve: AppMotion.curve),
                  ),
            child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Color(0xFFE8C56B),
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            'Live',
            style: GoogleFonts.dmSans(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
