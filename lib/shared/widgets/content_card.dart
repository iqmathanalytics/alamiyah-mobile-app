import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/alamiyah_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/display_prefs.dart';
import '../../data/models/models.dart';
import 'bookmark_bounce_button.dart';

String contentHeroTag(String id) => 'content-$id';

class ContentCard extends StatelessWidget {
  const ContentCard({
    super.key,
    required this.item,
    required this.onTap,
    this.isBookmarked = false,
    this.onBookmark,
    this.compact = false,
    this.enableHero = true,
  });

  final ContentItem item;
  final VoidCallback onTap;
  final bool isBookmarked;
  final VoidCallback? onBookmark;
  final bool compact;
  final bool enableHero;

  @override
  Widget build(BuildContext context) {
    final colors = context.alamiyahColors;

    final card = Material(
      color: colors.cardBackground,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: colors.softShadow,
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(compact ? 12 : 16),
            child: switch (item.type) {
              ContentType.text => _TextBody(
                  item: item,
                  isBookmarked: isBookmarked,
                  onBookmark: onBookmark,
                  compact: compact,
                ),
              ContentType.image => _MediaBody(
                  item: item,
                  isBookmarked: isBookmarked,
                  onBookmark: onBookmark,
                  showPlay: false,
                  compact: compact,
                ),
              ContentType.video => _MediaBody(
                  item: item,
                  isBookmarked: isBookmarked,
                  onBookmark: onBookmark,
                  showPlay: true,
                  compact: compact,
                ),
            },
          ),
        ),
      ),
    );

    if (!enableHero) return card;
    return Hero(
      tag: contentHeroTag(item.id),
      flightShuttleBuilder: _heroShuttle,
      placeholderBuilder: (context, size, child) => child,
      child: card,
    );
  }
}

class FeaturedHeroCard extends StatelessWidget {
  const FeaturedHeroCard({
    super.key,
    required this.item,
    required this.onTap,
  });

  final ContentItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.alamiyahColors;

    return Hero(
      tag: contentHeroTag(item.id),
      flightShuttleBuilder: _heroShuttle,
      placeholderBuilder: (context, size, child) => child,
      child: Material(
        color: Colors.transparent,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colors.brandPrimary,
                  colors.brandSecondary,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: colors.softShadow,
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dua of the Day',
                  style: GoogleFonts.dmSans(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  item.title,
                  style: GoogleFonts.dmSans(
                    color: Colors.white,
                    fontSize: context.contentSize(22),
                    fontWeight: FontWeight.w600,
                    height: 1.25,
                  ),
                ),
                if (item.arabicText != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    item.arabicText!,
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.arabicStyle(
                      context,
                      fontSize: 28,
                      color: Colors.white,
                    ),
                  ),
                ],
                if (item.translation != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    item.translation!,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.dmSans(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: context.contentSize(14),
                      height: 1.45,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class QuoteCard extends StatelessWidget {
  const QuoteCard({
    super.key,
    required this.item,
    required this.onTap,
    this.isBookmarked = false,
    this.onBookmark,
  });

  final ContentItem item;
  final VoidCallback onTap;
  final bool isBookmarked;
  final VoidCallback? onBookmark;

  @override
  Widget build(BuildContext context) {
    final colors = context.alamiyahColors;
    return Hero(
      tag: contentHeroTag(item.id),
      flightShuttleBuilder: _heroShuttle,
      placeholderBuilder: (context, size, child) => child,
      child: Material(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      'A quiet line',
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        letterSpacing: 0.6,
                        fontWeight: FontWeight.w600,
                        color: colors.accentGold,
                      ),
                    ),
                    const Spacer(),
                    if (onBookmark != null)
                      BookmarkBounceButton(
                        bookmarked: isBookmarked,
                        onPressed: onBookmark!,
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  height: 1,
                  width: 48,
                  color: colors.accentGold.withValues(alpha: 0.45),
                ),
                if (item.arabicText != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    item.arabicText!,
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.arabicStyle(context, fontSize: 26),
                  ),
                ],
                const SizedBox(height: 12),
                Text(
                  item.title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.dmSans(
                    fontWeight: FontWeight.w600,
                    fontSize: context.contentSize(15),
                    color: colors.brandPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DailyDhikrCard extends StatelessWidget {
  const DailyDhikrCard({
    super.key,
    required this.item,
    required this.onTap,
    this.isBookmarked = false,
    this.onBookmark,
  });

  final ContentItem item;
  final VoidCallback onTap;
  final bool isBookmarked;
  final VoidCallback? onBookmark;

  @override
  Widget build(BuildContext context) {
    final colors = context.alamiyahColors;
    return Hero(
      tag: contentHeroTag(item.id),
      flightShuttleBuilder: _heroShuttle,
      placeholderBuilder: (context, size, child) => child,
      child: Material(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: colors.accentGold.withValues(alpha: 0.35),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.wb_twilight_outlined,
                        size: 18, color: colors.accentGold),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Daily dhikr',
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                          color: colors.accentGold,
                        ),
                      ),
                    ),
                    if (onBookmark != null)
                      BookmarkBounceButton(
                        bookmarked: isBookmarked,
                        onPressed: onBookmark!,
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  item.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.dmSans(
                    fontWeight: FontWeight.w700,
                    fontSize: context.contentSize(18),
                    color: colors.brandPrimary,
                  ),
                ),
                if (item.arabicText != null) ...[
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      item.arabicText!,
                      textDirection: TextDirection.rtl,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: AppTheme.arabicStyle(context, fontSize: 24),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget contentHeroShuttle(
  BuildContext flightContext,
  Animation<double> animation,
  HeroFlightDirection flightDirection,
  BuildContext fromHeroContext,
  BuildContext toHeroContext,
) {
  // Never mount the real card/detail tree mid-flight — those Columns overflow
  // when squeezed between sizes (yellow/black debug stripes). Soft card shell only.
  Color shellColor;
  Color gold;
  try {
    final brand = flightContext.alamiyahColors;
    shellColor = brand.cardBackground;
    gold = brand.accentGold;
  } catch (_) {
    shellColor = Theme.of(flightContext).brightness == Brightness.dark
        ? const Color(0xFF1A2A24)
        : const Color(0xFFFFFBF5);
    gold = const Color(0xFFC9A96E);
  }

  return AnimatedBuilder(
    animation: animation,
    builder: (context, _) {
      final t = Curves.easeInOutCubic.transform(animation.value);
      final radius = 20.0 + 4.0 * t;
      return Material(
        color: Colors.transparent,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: shellColor,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              color: gold.withValues(alpha: 0.22 + 0.1 * t),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08 + 0.06 * t),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const SizedBox.expand(),
        ),
      );
    },
  );
}

Widget _heroShuttle(
  BuildContext flightContext,
  Animation<double> animation,
  HeroFlightDirection flightDirection,
  BuildContext fromHeroContext,
  BuildContext toHeroContext,
) =>
    contentHeroShuttle(
      flightContext,
      animation,
      flightDirection,
      fromHeroContext,
      toHeroContext,
    );

class _TextBody extends StatelessWidget {
  const _TextBody({
    required this.item,
    required this.isBookmarked,
    this.onBookmark,
    this.compact = false,
  });

  final ContentItem item;
  final bool isBookmarked;
  final VoidCallback? onBookmark;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colors = context.alamiyahColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                item.title,
                maxLines: compact ? 2 : 3,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.dmSans(
                  fontWeight: FontWeight.w600,
                  fontSize: context.contentSize(compact ? 14 : 16),
                  color: colors.brandPrimary,
                ),
              ),
            ),
            if (onBookmark != null)
              BookmarkBounceButton(
                bookmarked: isBookmarked,
                onPressed: onBookmark!,
              ),
          ],
        ),
        if (!compact && item.arabicText != null) ...[
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              item.arabicText!,
              textDirection: TextDirection.rtl,
              style: AppTheme.arabicStyle(context, fontSize: 22),
            ),
          ),
        ],
        if (!compact && item.translation != null) ...[
          const SizedBox(height: 8),
          Text(
            item.translation!,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: context.contentSize(14),
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.75),
                ),
          ),
        ],
      ],
    );
  }
}

class _MediaBody extends StatelessWidget {
  const _MediaBody({
    required this.item,
    required this.isBookmarked,
    required this.showPlay,
    this.onBookmark,
    this.compact = false,
  });

  final ContentItem item;
  final bool isBookmarked;
  final bool showPlay;
  final VoidCallback? onBookmark;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colors = context.alamiyahColors;
    final thumb = item.thumbnailUrl ?? item.mediaUrl;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: AspectRatio(
            aspectRatio: compact ? 4 / 3 : 16 / 9,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (thumb != null)
                  Image.network(
                    thumb,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      color: colors.chipBackground,
                      alignment: Alignment.center,
                      child: Icon(Icons.image_outlined,
                          color: colors.brandSecondary),
                    ),
                  )
                else
                  Container(color: colors.chipBackground),
                if (showPlay)
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.35),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.play_arrow_rounded,
                          color: Colors.white, size: 32),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Text(
                item.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.dmSans(
                  fontWeight: FontWeight.w600,
                  fontSize: context.contentSize(compact ? 13 : 16),
                  color: colors.brandPrimary,
                ),
              ),
            ),
            if (onBookmark != null && !compact)
              BookmarkBounceButton(
                bookmarked: isBookmarked,
                onPressed: onBookmark!,
              ),
          ],
        ),
      ],
    );
  }
}
