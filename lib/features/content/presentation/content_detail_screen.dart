import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/alamiyah_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/display_prefs.dart';
import '../../../data/models/models.dart';
import '../../../shared/widgets/bookmark_bounce_button.dart';
import '../../../shared/widgets/content_card.dart';
import '../../../shared/widgets/content_video_player.dart';
import '../../bookmarks/providers/bookmark_controller.dart';
import '../../home/providers/feed_providers.dart';
import '../../library/library_catalog.dart';

class ContentDetailScreen extends ConsumerStatefulWidget {
  const ContentDetailScreen({super.key, required this.contentId});

  final String contentId;

  @override
  ConsumerState<ContentDetailScreen> createState() =>
      _ContentDetailScreenState();
}

class _ContentDetailScreenState extends ConsumerState<ContentDetailScreen> {
  var _sizeBump = 0.0;

  Future<void> _openExternal(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _share(ContentItem item) async {
    final buffer = StringBuffer(item.title);
    if (item.arabicText?.isNotEmpty ?? false) {
      buffer.write('\n\n${item.arabicText}');
    }
    if (item.translation?.isNotEmpty ?? false) {
      buffer.write('\n\n${item.translation}');
    }
    buffer.write('\n\nShared from Alamiyah');
    await SharePlus.instance.share(
      ShareParams(text: buffer.toString(), subject: item.title),
    );
  }

  void _nudgeFont(int dir) {
    setState(() {
      _sizeBump = (_sizeBump + dir * 0.12).clamp(-0.2, 0.4);
    });
  }

  @override
  Widget build(BuildContext context) {
    final contentId = widget.contentId;
    final async = ref.watch(contentByIdProvider(contentId));
    final bookmarks = ref.watch(bookmarkControllerProvider);
    final relatedAsync = ref.watch(relatedContentProvider(contentId));
    final colors = context.alamiyahColors;
    final bookmarked = bookmarks.contains(contentId);
    final scale = context.alamiyahDisplay.fontScale + _sizeBump;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(
          'Details',
          style: GoogleFonts.dmSans(
            fontWeight: FontWeight.w600,
            color: colors.brandPrimary,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Display settings',
            style: IconButton.styleFrom(
              backgroundColor: colors.chipBackground,
            ),
            onPressed: () => context.push('/display'),
            icon: Icon(Icons.palette_outlined, color: colors.brandPrimary),
          ),
          IconButton(
            tooltip: 'Smaller text',
            onPressed: () => _nudgeFont(-1),
            icon: Icon(Icons.text_decrease_rounded, color: colors.brandPrimary),
          ),
          IconButton(
            tooltip: 'Larger text',
            onPressed: () => _nudgeFont(1),
            icon: Icon(Icons.text_increase_rounded, color: colors.brandPrimary),
          ),
          BookmarkBounceButton(
            bookmarked: bookmarked,
            onPressed: () =>
                ref.read(bookmarkControllerProvider.notifier).toggle(contentId),
          ),
        ],
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('$e', textAlign: TextAlign.center),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () =>
                      ref.invalidate(contentByIdProvider(contentId)),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
        data: (item) {
          if (item == null) {
            return const Center(child: Text('Content not found'));
          }
          final collection = collectionById(item.category);
          final categoryName = collection == null
              ? item.category
              : item.section == null
                  ? collection.title
                  : '${collection.title} · ${item.section}';

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Hero(
                  tag: contentHeroTag(item.id),
                  flightShuttleBuilder: contentHeroShuttle,
                  placeholderBuilder: (context, size, child) => child,
                  child: Material(
                    color: Colors.transparent,
                    child: _DetailHero(
                      item: item,
                      scale: scale,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _MetaChip(label: item.type.name),
                    _MetaChip(label: categoryName),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  item.authorName,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colors.brandSecondary,
                      ),
                ),
                if (item.transliteration?.isNotEmpty ?? false) ...[
                  const SizedBox(height: 16),
                  Text(
                    item.transliteration!,
                    style: GoogleFonts.dmSans(
                      fontStyle: FontStyle.italic,
                      fontSize: 15 * scale,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.8),
                    ),
                  ),
                ],
                if (item.translation?.isNotEmpty ?? false) ...[
                  const SizedBox(height: 12),
                  Text(
                    item.translation!,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontSize: 16 * scale,
                          height: 1.5,
                        ),
                  ),
                ],
                if (item.sourceReference?.isNotEmpty ?? false) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Source: ${item.sourceReference}',
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      color: colors.brandSecondary,
                    ),
                  ),
                ],
                if (item.type == ContentType.video &&
                    (item.mediaUrl?.isNotEmpty ?? false) &&
                    !isPlayableVideoUrl(item.mediaUrl)) ...[
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () => _openExternal(item.mediaUrl!),
                    icon: const Icon(Icons.open_in_new_rounded),
                    label: const Text('Open video'),
                  ),
                ],
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _share(item),
                    icon: const Icon(Icons.ios_share_rounded),
                    label: const Text('Share'),
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'More like this',
                  style: GoogleFonts.dmSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                    color: colors.brandPrimary,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 6, bottom: 14),
                  width: 36,
                  height: 3,
                  decoration: BoxDecoration(
                    color: colors.accentGold,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                relatedAsync.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (e, _) => Text('Could not load related items: $e'),
                  data: (related) {
                    if (related.isEmpty) {
                      return Text(
                        'Nothing else in this category yet.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      );
                    }
                    return Column(
                      children: [
                        for (var i = 0; i < related.length; i++) ...[
                          if (i > 0) const SizedBox(height: 12),
                          ContentCard(
                            item: related[i],
                            enableHero: false,
                            isBookmarked:
                                bookmarks.contains(related[i].id),
                            onBookmark: () => ref
                                .read(bookmarkControllerProvider.notifier)
                                .toggle(related[i].id),
                            onTap: () =>
                                context.push('/content/${related[i].id}'),
                          ),
                        ],
                      ],
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _DetailHero extends StatelessWidget {
  const _DetailHero({
    required this.item,
    required this.scale,
  });

  final ContentItem item;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final colors = context.alamiyahColors;
    final thumb = item.thumbnailUrl ?? item.mediaUrl;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.title,
          maxLines: 4,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.dmSans(
            fontSize: 24 * scale,
            fontWeight: FontWeight.w700,
            color: colors.brandPrimary,
            height: 1.25,
          ),
        ),
        if (item.type == ContentType.text &&
            (item.arabicText?.isNotEmpty ?? false)) ...[
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colors.cardBackground,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              item.arabicText!,
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
              style: AppTheme.arabicStyle(context, fontSize: 30 * scale),
            ),
          ),
        ],
        if (item.type == ContentType.video &&
            isPlayableVideoUrl(item.mediaUrl)) ...[
          const SizedBox(height: 20),
          ContentVideoPlayer(url: item.mediaUrl!),
        ] else if (item.type != ContentType.text && thumb != null) ...[
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    thumb,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      color: colors.chipBackground,
                      alignment: Alignment.center,
                      child: Icon(Icons.broken_image_outlined,
                          color: colors.brandSecondary),
                    ),
                  ),
                  if (item.type == ContentType.video)
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.35),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.play_arrow_rounded,
                            color: Colors.white, size: 36),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.alamiyahColors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colors.chipBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colors.brandPrimary.withValues(alpha: 0.08),
        ),
      ),
      child: Text(
        label,
        style: GoogleFonts.dmSans(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
          color: colors.brandPrimary,
        ),
      ),
    );
  }
}
